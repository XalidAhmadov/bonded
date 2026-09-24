-- =====================================================================
-- Migration: Education Schema Redesign
-- Created:   2026-06-01
--
-- Changes:
--   + CREATE  public.education_groups   (I / II / III / IV)
--   + CREATE  public.universities       (Azerbaijan universities)
--   + CREATE  public.specialties        (FK → universities, education_groups)
--   ~ ALTER   public.profiles           (add 3 FK cols, drop university + major)
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: education_groups
-- ─────────────────────────────────────────────────────────────────────
-- In the Azerbaijan DIM system, every specialty belongs to one of four
-- exam groups (bölmə) that determine which subjects a student must sit.
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.education_groups (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT         NOT NULL UNIQUE
                           CHECK (name IN ('I', 'II', 'III', 'IV', 'V')),
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

ALTER TABLE public.education_groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.education_groups REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.education_groups;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;


-- ─────────────────────────────────────────────────────────────────────
-- TABLE: universities
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.universities (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT         NOT NULL UNIQUE,
  short_name  TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_universities_short_name
  ON public.universities (short_name);

ALTER TABLE public.universities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.universities REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.universities;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;


-- ─────────────────────────────────────────────────────────────────────
-- REPAIR: drop any accidental unique-on-code-alone index
-- (the same specialty code legitimately appears at multiple universities)
-- ─────────────────────────────────────────────────────────────────────
DROP INDEX IF EXISTS public.idx_specialties_code;

-- ─────────────────────────────────────────────────────────────────────
-- TABLE: specialties
-- ─────────────────────────────────────────────────────────────────────
-- Each specialty belongs to exactly one university and one education
-- group. The (university_id, code) pair is unique — the same specialty
-- code may appear at multiple universities with different names.
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.specialties (
  id                  UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  university_id       UUID         NOT NULL
                      REFERENCES public.universities(id) ON DELETE CASCADE,
  education_group_id  UUID         NOT NULL
                      REFERENCES public.education_groups(id),
  code                TEXT         NOT NULL,
  name                TEXT         NOT NULL,
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
  UNIQUE (university_id, code)
);

CREATE INDEX IF NOT EXISTS idx_specialties_university
  ON public.specialties (university_id);

CREATE INDEX IF NOT EXISTS idx_specialties_edu_group
  ON public.specialties (education_group_id);

CREATE INDEX IF NOT EXISTS idx_specialties_code
  ON public.specialties (code);

-- composite index for the frontend query pattern:
-- "specialties WHERE university_id = ? AND education_group_id = ?"
CREATE INDEX IF NOT EXISTS idx_specialties_uni_group
  ON public.specialties (university_id, education_group_id);

ALTER TABLE public.specialties DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.specialties REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.specialties;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;


-- ─────────────────────────────────────────────────────────────────────
-- ALTER: profiles
-- ─────────────────────────────────────────────────────────────────────
-- Add new FK columns (nullable so existing rows are not broken).
-- Drop old free-text columns.
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS university_id      UUID
    REFERENCES public.universities(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS specialty_id       UUID
    REFERENCES public.specialties(id)  ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS education_group_id UUID
    REFERENCES public.education_groups(id);

-- Remove old indexes that covered the text columns (safe if absent)
DROP INDEX IF EXISTS idx_profiles_university;

CREATE INDEX IF NOT EXISTS idx_profiles_university_id
  ON public.profiles (university_id);

CREATE INDEX IF NOT EXISTS idx_profiles_specialty_id
  ON public.profiles (specialty_id);

CREATE INDEX IF NOT EXISTS idx_profiles_education_group_id
  ON public.profiles (education_group_id);

-- Drop the free-text columns.
-- WARNING: existing data in these columns is lost.
-- Run seed_data.sql first, then backfill profiles manually if needed.
ALTER TABLE public.profiles
  DROP COLUMN IF EXISTS university,
  DROP COLUMN IF EXISTS major;
