-- =========================================================
-- BONDED CONNECTIONS — Full Production Schema
-- Created: 2026-05-04
-- Description: Complete schema with group auto-assignment,
--   entrance scores, chat toggle, and all required features.
-- =========================================================

-- =========================================================
-- 1. PROFILES — Add new registration fields
-- =========================================================
DO $$
BEGIN
  -- Add entrance_score column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='entrance_score') THEN
    ALTER TABLE public.profiles ADD COLUMN entrance_score NUMERIC DEFAULT 0;
  END IF;

  -- Add group_number column (used internally for auto-assignment, hidden from UI)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='profiles' AND column_name='group_number') THEN
    ALTER TABLE public.profiles ADD COLUMN group_number INTEGER;
  END IF;
END $$;

-- =========================================================
-- 2. GROUPS — Add chat_enabled and bio columns
-- =========================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='groups' AND column_name='chat_enabled') THEN
    ALTER TABLE public.groups ADD COLUMN chat_enabled BOOLEAN NOT NULL DEFAULT true;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='groups' AND column_name='bio') THEN
    ALTER TABLE public.groups ADD COLUMN bio TEXT DEFAULT '';
  END IF;
END $$;

-- =========================================================
-- 3. GROUP MESSAGES — Create if not exists
-- =========================================================
CREATE TABLE IF NOT EXISTS public.group_messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_group_messages_group ON public.group_messages(group_id, created_at);

-- =========================================================
-- 4. GROUP JOIN REQUESTS — Create if not exists
-- =========================================================
CREATE TABLE IF NOT EXISTS public.group_join_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_group_join_requests_group ON public.group_join_requests(group_id);
CREATE INDEX IF NOT EXISTS idx_group_join_requests_user ON public.group_join_requests(user_id);

-- =========================================================
-- 5. Enable Realtime for new/modified tables
-- =========================================================
ALTER TABLE public.group_messages REPLICA IDENTITY FULL;
ALTER TABLE public.group_join_requests REPLICA IDENTITY FULL;

-- =========================================================
-- 6. Disable RLS on all tables (custom auth, not Supabase Auth)
-- =========================================================
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_participants DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reads DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_invitations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_join_requests DISABLE ROW LEVEL SECURITY;
