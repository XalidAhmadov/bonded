-- =====================================================================
-- BONDED — Company Account System
-- Migration: 20260916000000_company_system.sql
-- =====================================================================
-- Adds:
--   1. account_type column on profiles ('student' | 'company')
--   2. founded_date column on profiles (used by company accounts)
--   3. Backfill existing profiles to 'student'
--   4. company_job_postings table
--   5. job_applications table
--   6. Grants and Realtime publication
-- =====================================================================

-- ─── 1. Extend profiles table ─────────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS account_type TEXT NOT NULL DEFAULT 'student',
  ADD COLUMN IF NOT EXISTS founded_date TEXT;

-- Backfill any existing rows where account_type might be null
UPDATE public.profiles
SET account_type = 'student'
WHERE account_type IS NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_account_type ON public.profiles (account_type);


-- ─── 2. Company job postings table ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.company_job_postings (
  id           UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  company_id   UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title        TEXT         NOT NULL,
  field        TEXT         NOT NULL,
  level        TEXT         NOT NULL,
  description  TEXT         NOT NULL,
  salary       TEXT,                        -- NULL = not specified
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_job_postings_company ON public.company_job_postings (company_id);
CREATE INDEX IF NOT EXISTS idx_job_postings_field   ON public.company_job_postings (field);


-- ─── 3. Job applications table ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.job_applications (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  job_id      UUID         NOT NULL REFERENCES public.company_job_postings(id) ON DELETE CASCADE,
  student_id  UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  message     TEXT,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT job_applications_job_student_unique UNIQUE (job_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_job_applications_job     ON public.job_applications (job_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_student ON public.job_applications (student_id);


-- ─── 4. Permissions (custom auth uses anon and authenticated roles) ───
ALTER TABLE public.company_job_postings DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications     DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.company_job_postings TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.job_applications     TO anon, authenticated, service_role;


-- ─── 5. Supabase Realtime ─────────────────────────────────────────────
ALTER TABLE public.company_job_postings REPLICA IDENTITY FULL;
ALTER TABLE public.job_applications     REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.company_job_postings;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;

  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.job_applications;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;
