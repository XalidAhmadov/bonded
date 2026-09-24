# pyrefly: ignore [missing-import]
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
# pyrefly: ignore [missing-import]
import easyocr
import cv2
import numpy as np

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

reader = easyocr.Reader(['en'])

def evez(soz):
    h = {
        'ə': 'a', 'ğ': 'gh', 'ü': 'u',
        'ş': 'sh', 'ö': 'o', 'ç': 'ch',
        'ı': 'i', 'q':'g','Q':'G',
        'Ə': 'A', 'Ğ': 'G', 'Ü': 'U',
        'Ş': 'Sh', 'Ö': 'O', 'Ç': 'Ch',
        'İ': 'I'
    }
    return "".join(h.get(c, c) for c in soz)

@app.post("/compare")
async def compare(
    file: UploadFile = File(...),
    ad: str = Form(...),
    soyad: str = Form(...),
    uni: str = Form(...)
):
    image_bytes = await file.read()
    np_array = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_array, cv2.IMREAD_COLOR)

    if img is None:
        return {"success": False, "message": "Could not decode the image. Please upload a valid JPG or PNG."}

    # Resize to a consistent width for OCR while keeping aspect ratio
    max_width = 800
    h, w = img.shape[:2]
    if w > max_width:
        scale = max_width / w
        img = cv2.resize(img, (max_width, int(h * scale)))

    # Convert to RGB for EasyOCR
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    result = reader.readtext(img_rgb, detail=0)
    sozler_k = [s.strip() for s in result if s.strip()]

    if not sozler_k:
        return {"success": False, "message": "No text could be read from the image. Ensure the photo is clear and well-lit."}

    ad_yoxla = evez(ad.strip())
    soyad_yoxla = evez(soyad.strip())
    uni_yoxla = evez(uni.strip())

    all_text_lower = " ".join(sozler_k).lower()
    match = (
        ad_yoxla.lower() in all_text_lower and
        soyad_yoxla.lower() in all_text_lower and
        uni_yoxla.lower() in all_text_lower
    )

    return {
        "success": True,
        "ocr_text": sozler_k,
        "match": match
    }
