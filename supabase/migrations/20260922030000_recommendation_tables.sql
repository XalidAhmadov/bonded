-- =====================================================================
-- BONDED — Recommendation tables (Section 3)
-- Migration: 20260922030000_recommendation_tables.sql
-- =====================================================================
-- Adds:
--   1. pgvector extension + profile_embeddings (one row per profile)
--   2. recommendation_events (impression/profile_opened/request_*/dismissed)
--   3. recommendation_config (single row of tunable scoring weights)
--   4. Trigger on friendships that auto-logs request_sent/accepted/rejected
--      events, so SuggestedScreen's friend-request code stays untouched.
--
-- No RPC functions here yet (embed-profile edge function is Section 4,
-- get_recommendations is Section 5) — EXECUTE grants for those come with
-- those migrations.
-- =====================================================================

-- ─── 1. Embeddings ──────────────────────────────────────────────────────
-- Dimension is 768 to match Gemini's free-tier "text-embedding-004" model
-- (Section 4's embed-profile function). If the embedding model ever
-- changes to one with a different output size, this column needs a new
-- migration (ALTER COLUMN ... TYPE vector(N)) and a full re-embed.
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

CREATE TABLE IF NOT EXISTS public.profile_embeddings (
  user_id      UUID          NOT NULL PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  embedding    extensions.vector(768),
  source_hash  TEXT,
  updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- No ANN index (ivfflat/hnsw) yet — get_recommendations (Section 5) narrows
-- candidates by university/relationship first, so a sequential scan over
-- that narrowed set is fine at this app's scale. Add one later if the
-- candidate pool per query grows large enough to need it.


-- ─── 2. Recommendation events ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.recommendation_events (
  id            UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id       UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  candidate_id  UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  event_type    TEXT         NOT NULL CHECK (event_type IN (
                                'impression', 'profile_opened', 'request_sent',
                                'request_accepted', 'request_rejected', 'dismissed'
                              )),
  score         NUMERIC,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_recommendation_events_user_candidate
  ON public.recommendation_events (user_id, candidate_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_events_type_created
  ON public.recommendation_events (event_type, created_at);


-- ─── 3. Recommendation config (single tunable row) ──────────────────────
CREATE TABLE IF NOT EXISTS public.recommendation_config (
  id                        BOOLEAN      NOT NULL DEFAULT true PRIMARY KEY CHECK (id = true),
  weight_shared_fields      NUMERIC      NOT NULL DEFAULT 0.30,
  weight_category_overlap   NUMERIC      NOT NULL DEFAULT 0.10,
  weight_semantic           NUMERIC      NOT NULL DEFAULT 0.25,
  weight_same_major         NUMERIC      NOT NULL DEFAULT 0.15,
  weight_mutual_friends     NUMERIC      NOT NULL DEFAULT 0.10,
  weight_same_group         NUMERIC      NOT NULL DEFAULT 0.05,
  weight_score_closeness    NUMERIC      NOT NULL DEFAULT 0.05,
  updated_at                TIMESTAMPTZ  NOT NULL DEFAULT now()
);

INSERT INTO public.recommendation_config (id) VALUES (true) ON CONFLICT (id) DO NOTHING;


-- ─── 4. Auto-log friendship events (friendship code stays untouched) ────
CREATE OR REPLACE FUNCTION public.log_friendship_recommendation_event()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.status = 'pending' THEN
      INSERT INTO public.recommendation_events (user_id, candidate_id, event_type)
      VALUES (NEW.requester_id, NEW.addressee_id, 'request_sent');
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.status = 'accepted' AND OLD.status IS DISTINCT FROM 'accepted' THEN
      INSERT INTO public.recommendation_events (user_id, candidate_id, event_type)
      VALUES (NEW.requester_id, NEW.addressee_id, 'request_accepted');
    ELSIF NEW.status = 'rejected' AND OLD.status IS DISTINCT FROM 'rejected' THEN
      INSERT INTO public.recommendation_events (user_id, candidate_id, event_type)
      VALUES (NEW.requester_id, NEW.addressee_id, 'request_rejected');
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_friendship_recommendation_event ON public.friendships;
CREATE TRIGGER trg_log_friendship_recommendation_event
AFTER INSERT OR UPDATE ON public.friendships
FOR EACH ROW
EXECUTE FUNCTION public.log_friendship_recommendation_event();


-- ─── 5. Permissions (custom auth uses anon and authenticated roles) ────
ALTER TABLE public.profile_embeddings   DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_config DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.profile_embeddings    TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.recommendation_events TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.recommendation_config TO anon, authenticated, service_role;
