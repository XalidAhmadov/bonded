"""
extract_admission.py
====================
One-time script: reads Azerbaijani DIM admission-book page images, extracts
university names, specialty codes, specialty names, and education groups via
EasyOCR, then outputs:
  • supabase/extracted_universities.csv
  • supabase/extracted_specialties.csv
  • supabase/extracted_seed.sql   (INSERT … ON CONFLICT DO NOTHING)

Usage
-----
  Place admission-book page images in  model/admission_pages/
  (any of: .jpg .jpeg .png .bmp .tiff)

  Then run from the repo root:
    python model/extract_admission.py

  Optional flags:
    --pages-dir   PATH    source directory  (default: model/admission_pages)
    --out-dir     PATH    output directory  (default: supabase)
    --lang        LANG    easyocr language  (default: az — Azerbaijani)
    --gpu                 use GPU (requires CUDA)

Dependencies (already in requirements for model/Modd.py):
  easyocr, opencv-python, numpy
  pip install easyocr opencv-python numpy
"""

from __future__ import annotations

import argparse
import csv
import os
import re
import sys
from pathlib import Path
from typing import NamedTuple

import cv2
import numpy as np

try:
    import easyocr
except ImportError:
    sys.exit("easyocr not installed.  Run: pip install easyocr")


# ─── Data structures ──────────────────────────────────────────────────────────

class Specialty(NamedTuple):
    university_short: str
    education_group: str   # 'I' | 'II' | 'III' | 'IV'
    code: str
    name: str


# ─── Regex patterns ───────────────────────────────────────────────────────────

# Specialty code: 6 digits, sometimes followed by .XX sub-codes
RE_CODE = re.compile(r"\b(\d{6})(?:\.\d+)*\b")

# Education group: standalone Roman numeral I–IV (case-insensitive for OCR errors)
RE_GROUP = re.compile(r"\b(IV|III|II|I)\b")

# University indicators in Azerbaijani DIM books
UNIVERSITY_KEYWORDS = [
    "universiteti", "institutu", "akademiyası", "məktəbi",
    "university", "institute", "academy",
]

# Known short-name lookup table (extended from seed_data.sql)
SHORT_NAME_MAP: dict[str, str] = {
    "bakı dövlət universiteti":                                   "BDU",
    "bdu":                                                         "BDU",
    "azərbaycan texniki universiteti":                            "AzTU",
    "aztu":                                                        "AzTU",
    "azərbaycan dövlət iqtisad universiteti":                     "UNEC",
    "unec":                                                        "UNEC",
    "azərbaycan tibb universiteti":                               "ATU",
    "atu":                                                         "ATU",
    "azərbaycan dövlət neft və sənaye universiteti":              "ADNSU",
    "adnsu":                                                       "ADNSU",
    "azərbaycan memarlıq və inşaat universiteti":                 "AMİU",
    "amiu":                                                        "AMİU",
    "azərbaycan dövlət pedaqoji universiteti":                    "ADPU",
    "adpu":                                                        "ADPU",
    "azərbaycan dillər universiteti":                             "ADU",
    "adu":                                                         "ADU",
    "azərbaycan dövlət bədən tərbiyəsi":                         "ADBTİA",
    "adbtia":                                                      "ADBTİA",
    "azərbaycan dövlət mədəniyyət":                               "ADMİU",
    "admiu":                                                       "ADMİU",
    "bakı ali neft məktəbi":                                      "BANM",
    "banm":                                                        "BANM",
    "ada university":                                              "ADA",
    "sumqayıt dövlət universiteti":                               "SDU",
    "sdu":                                                         "SDU",
    "gəncə dövlət universiteti":                                  "GDU",
    "gdu":                                                         "GDU",
    "lənkəran dövlət universiteti":                               "LDU",
    "ldu":                                                         "LDU",
    "naxçıvan dövlət universiteti":                               "NDU",
    "ndu":                                                         "NDU",
    "odlar yurdu universiteti":                                    "OYU",
    "xəzər universiteti":                                          "XU",
    "azərbaycan müəllimlər institutu":                            "AMİ",
    "azərbaycan kooperasiya universiteti":                        "AKU",
    "mingəçevir dövlət universiteti":                             "MDU",
    "şirvan dövlət universiteti":                                  "ŞDU",
    "azərbaycan dövlət aqrar universiteti":                       "ADAU",
    "adau":                                                        "ADAU",
    "azərbaycan dövlət dəniz akademiyası":                        "ADDA",
    "azərbaycan dövlət hüquq universiteti":                       "ADHU",
    "bakı musiqi akademiyası":                                     "BMA",
    "bma":                                                         "BMA",
    "azərbaycan güvənlik universiteti":                           "AGU",
}


# ─── Image pre-processing ─────────────────────────────────────────────────────

def preprocess(img: np.ndarray) -> np.ndarray:
    """Upscale small images, convert to grayscale, denoise, binarise."""
    h, w = img.shape[:2]
    if max(h, w) < 1800:
        scale = 1800 / max(h, w)
        img = cv2.resize(img, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) if img.ndim == 3 else img
    gray = cv2.fastNlMeansDenoising(gray, h=10)
    _, binarised = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return binarised


# ─── University detection ─────────────────────────────────────────────────────

def detect_university(line: str) -> str | None:
    """
    Returns a known short_name if `line` looks like a university header,
    or None if it looks like a table row.
    """
    lower = line.lower().strip()

    # Direct match in known map
    for key, short in SHORT_NAME_MAP.items():
        if key in lower:
            return short

    # Generic keyword match — signal that a new unknown university started
    for kw in UNIVERSITY_KEYWORDS:
        if kw in lower:
            return "__UNKNOWN__:" + line.strip()

    return None


# ─── Row extraction ───────────────────────────────────────────────────────────

def extract_rows(
    ocr_results: list[tuple],
    current_university: str,
) -> list[Specialty]:
    """
    Parse EasyOCR result list into Specialty records.

    easyocr returns a list of (bbox, text, confidence).
    We group by Y-coordinate to reconstruct table rows, then parse each row.
    """
    # Flatten into (y_center, x_left, text) tuples
    items: list[tuple[float, float, str]] = []
    for bbox, text, _conf in ocr_results:
        xs = [p[0] for p in bbox]
        ys = [p[1] for p in bbox]
        items.append((sum(ys) / 4, min(xs), text.strip()))

    if not items:
        return []

    # Sort by y then x
    items.sort(key=lambda t: (t[0], t[1]))

    # Group tokens within 20px vertically into logical rows
    rows: list[list[str]] = []
    current_row: list[str] = []
    prev_y = items[0][0]

    for y, _x, text in items:
        if abs(y - prev_y) > 20 and current_row:
            rows.append(current_row)
            current_row = []
        current_row.append(text)
        prev_y = y

    if current_row:
        rows.append(current_row)

    specialties: list[Specialty] = []

    for row_tokens in rows:
        row_text = " ".join(row_tokens)

        code_match = RE_CODE.search(row_text)
        if not code_match:
            continue

        code = code_match.group(1)

        group_match = RE_GROUP.search(row_text)
        group = group_match.group(1) if group_match else "I"

        # Specialty name = text after the code, strip the group and numbers
        after_code = row_text[code_match.end():].strip()
        after_code = RE_CODE.sub("", after_code)
        after_code = RE_GROUP.sub("", after_code)
        name = re.sub(r"\s{2,}", " ", after_code).strip(" .,;:-")

        if len(name) < 4:
            continue

        specialties.append(Specialty(
            university_short=current_university,
            education_group=group,
            code=code,
            name=name,
        ))

    return specialties


# ─── SQL generation ───────────────────────────────────────────────────────────

SQL_HEADER = """\
-- =====================================================================
-- Auto-generated by model/extract_admission.py
-- Run AFTER migration 20260601000000_education_schema.sql + seed_data.sql
-- =====================================================================

"""

SQL_UNIVERSITY_TEMPLATE = """\
INSERT INTO public.universities (name, short_name)
VALUES ({name!r}, {short!r})
ON CONFLICT (name) DO NOTHING;

"""

SQL_SPECIALTY_TEMPLATE = """\
INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, {code!r}, {name!r}
FROM   public.universities u, public.education_groups eg
WHERE  u.short_name = {short!r} AND eg.name = {group!r}
ON CONFLICT (university_id, code) DO NOTHING;
"""


def build_sql(
    universities: dict[str, str],
    specialties: list[Specialty],
) -> str:
    parts = [SQL_HEADER]

    for full_name, short in sorted(universities.items()):
        if short.startswith("__UNKNOWN__:"):
            parts.append(f"-- TODO: resolve university: {full_name}\n")
        else:
            parts.append(SQL_UNIVERSITY_TEMPLATE.format(name=full_name, short=short))

    parts.append("\n")

    for s in specialties:
        if s.university_short.startswith("__UNKNOWN__"):
            parts.append(f"-- SKIPPED (unknown university): {s}\n")
        else:
            parts.append(SQL_SPECIALTY_TEMPLATE.format(
                code=s.code, name=s.name,
                short=s.university_short, group=s.education_group,
            ))

    return "".join(parts)


# ─── Main ─────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Extract DIM admission data via OCR")
    parser.add_argument("--pages-dir", default="model/admission_pages",
                        help="Directory containing admission-book page images")
    parser.add_argument("--out-dir", default="supabase",
                        help="Directory to write output files")
    parser.add_argument("--lang", default="az",
                        help="EasyOCR language code (az=Azerbaijani)")
    parser.add_argument("--gpu", action="store_true",
                        help="Enable GPU acceleration")
    args = parser.parse_args()

    pages_dir = Path(args.pages_dir)
    out_dir   = Path(args.out_dir)

    if not pages_dir.exists():
        print(f"[INFO] Creating pages directory: {pages_dir}")
        pages_dir.mkdir(parents=True)
        print(f"[INFO] Place your admission-book images in {pages_dir}/ and re-run.")
        sys.exit(0)

    image_files = sorted(
        p for p in pages_dir.iterdir()
        if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".tif"}
    )

    if not image_files:
        print(f"[WARN] No images found in {pages_dir}/")
        sys.exit(0)

    print(f"[INFO] Loading EasyOCR (lang={args.lang}, gpu={args.gpu}) …")
    reader = easyocr.Reader([args.lang, "en"], gpu=args.gpu)

    all_specialties: list[Specialty] = []
    discovered_universities: dict[str, str] = {}  # full_name → short_name
    current_university = "UNKNOWN"

    for img_path in image_files:
        print(f"[INFO] Processing {img_path.name} …")
        raw = cv2.imread(str(img_path))
        if raw is None:
            print(f"[WARN]   Could not read image, skipping.")
            continue

        processed = preprocess(raw)
        results = reader.readtext(processed, detail=1, paragraph=False)

        for _bbox, text, _conf in results:
            uni = detect_university(text)
            if uni:
                current_university = uni
                if not uni.startswith("__UNKNOWN__"):
                    discovered_universities[text.strip()] = uni

        rows = extract_rows(results, current_university)
        all_specialties.extend(rows)
        print(f"[INFO]   → {len(rows)} specialties extracted (university: {current_university})")

    # Deduplicate specialties
    seen: set[tuple[str, str]] = set()
    unique_specialties: list[Specialty] = []
    for s in all_specialties:
        key = (s.university_short, s.code)
        if key not in seen:
            seen.add(key)
            unique_specialties.append(s)

    out_dir.mkdir(parents=True, exist_ok=True)

    # ── CSV: universities ────────────────────────────────────────────
    uni_csv = out_dir / "extracted_universities.csv"
    with open(uni_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["name", "short_name"])
        for full, short in sorted(discovered_universities.items()):
            if not short.startswith("__UNKNOWN__"):
                w.writerow([full, short])
    print(f"[OUT] {uni_csv}  ({len(discovered_universities)} universities)")

    # ── CSV: specialties ─────────────────────────────────────────────
    spec_csv = out_dir / "extracted_specialties.csv"
    with open(spec_csv, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["university_short_name", "education_group", "code", "name"])
        for s in unique_specialties:
            w.writerow([s.university_short, s.education_group, s.code, s.name])
    print(f"[OUT] {spec_csv}  ({len(unique_specialties)} specialties)")

    # ── SQL seed file ────────────────────────────────────────────────
    sql_out = out_dir / "extracted_seed.sql"
    with open(sql_out, "w", encoding="utf-8") as f:
        f.write(build_sql(discovered_universities, unique_specialties))
    print(f"[OUT] {sql_out}")

    print("\n[DONE] Review the output files, correct any OCR errors, then apply:")
    print(f"  psql $DATABASE_URL -f {sql_out}")


if __name__ == "__main__":
    main()
