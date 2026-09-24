-- =====================================================================
-- BONDED — Sync profiles.interests for Jobs + atomic field writes
-- Migration: 20260922020000_jobs_sync_and_atomic_fields.sql
-- =====================================================================
-- Fixes two issues from the field_categories migration:
--
--   1. The Jobs feature (CompanyStudentSearch, JobApplicationsView,
--      StudentProfileModal, PostJobModal) reads/filters on
--      profiles.interests directly and is explicitly out of scope to
--      modify. Since ProfileScreen/Auth now write to profile_fields
--      only, interests would go stale. This adds a trigger that keeps
--      profiles.interests mirrored from profile_fields (as an array of
--      field LABELS across ALL categories — CompanyStudentSearch does
--      `s.interests.includes(selectedField)` against IT_FIELDS labels,
--      so the format must match exactly).
--
--   2. Client-side delete-then-insert for saving a profile's fields is
--      not atomic. Adds set_profile_fields(uuid, text[]) — validates
--      the field ids, enforces the 8-field cap, and replaces the
--      selection in one transaction. This becomes the ONLY write path
--      to profile_fields; ProfileScreen and Auth call it via RPC
--      instead of writing to the table directly.
-- =====================================================================

-- ─── 1. Keep profiles.interests mirrored from profile_fields ──────────
COMMENT ON COLUMN public.profiles.interests IS
  'Read-only, auto-synced copy of profile_fields (all categories, as field labels) — kept ONLY for the Jobs feature (CompanyStudentSearch / JobApplicationsView / StudentProfileModal), which matches on this column directly. Do not write to it from the client; profile_fields is the source of truth. Synced by trg_sync_profile_interests on public.profile_fields.';

CREATE OR REPLACE FUNCTION public.sync_profile_interests()
RETURNS TRIGGER AS $$
DECLARE
  target_user UUID := COALESCE(NEW.user_id, OLD.user_id);
BEGIN
  UPDATE public.profiles
  SET interests = COALESCE((
    SELECT array_agg(f.label ORDER BY fc.sort_order, f.sort_order, f.label)
    FROM public.profile_fields pf
    JOIN public.fields f ON f.id = pf.field_id
    JOIN public.field_categories fc ON fc.id = f.category_id
    WHERE pf.user_id = target_user
  ), '{}')
  WHERE id = target_user;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_profile_interests ON public.profile_fields;
CREATE TRIGGER trg_sync_profile_interests
AFTER INSERT OR UPDATE OR DELETE ON public.profile_fields
FOR EACH ROW
EXECUTE FUNCTION public.sync_profile_interests();

-- One-off sync for all existing profiles (safe to re-run: idempotent).
UPDATE public.profiles p
SET interests = COALESCE((
  SELECT array_agg(f.label ORDER BY fc.sort_order, f.sort_order, f.label)
  FROM public.profile_fields pf
  JOIN public.fields f ON f.id = pf.field_id
  JOIN public.field_categories fc ON fc.id = f.category_id
  WHERE pf.user_id = p.id
), '{}');


-- ─── 2. Atomic field writes ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_profile_fields(p_user_id UUID, p_field_ids TEXT[])
RETURNS void AS $$
DECLARE
  v_ids TEXT[] := COALESCE((SELECT ARRAY(SELECT DISTINCT unnest(p_field_ids))), '{}');
  v_count INTEGER := COALESCE(array_length(v_ids, 1), 0);
  v_valid_count INTEGER;
BEGIN
  IF v_count > 8 THEN
    RAISE EXCEPTION 'A profile can have at most 8 fields selected (got %)', v_count
      USING ERRCODE = '23514';
  END IF;

  IF v_count > 0 THEN
    SELECT COUNT(*) INTO v_valid_count
    FROM public.fields f
    WHERE f.id = ANY(v_ids) AND f.is_active = true;

    IF v_valid_count <> v_count THEN
      RAISE EXCEPTION 'One or more field ids are invalid or inactive'
        USING ERRCODE = '23503';
    END IF;
  END IF;

  -- Everything below runs as one statement-function invocation: if either
  -- check above raised, nothing here executes and the user's previous
  -- fields are untouched.
  DELETE FROM public.profile_fields WHERE user_id = p_user_id;

  IF v_count > 0 THEN
    INSERT INTO public.profile_fields (user_id, field_id)
    SELECT p_user_id, unnest(v_ids);
  END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.set_profile_fields(UUID, TEXT[]) TO anon, authenticated, service_role;
