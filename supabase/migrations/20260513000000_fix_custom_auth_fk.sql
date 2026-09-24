-- Fix FK constraints that still reference auth.users instead of profiles.
-- The app uses custom auth (profiles table), not Supabase Auth.
-- Users registered via custom auth only exist in profiles, not auth.users,
-- so any FK to auth.users blocks their writes.

-- messages.sender_id
ALTER TABLE public.messages
  DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;

ALTER TABLE public.messages
  ADD CONSTRAINT messages_sender_id_fkey
  FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- chat_participants.user_id
ALTER TABLE public.chat_participants
  DROP CONSTRAINT IF EXISTS chat_participants_user_id_fkey;

ALTER TABLE public.chat_participants
  ADD CONSTRAINT chat_participants_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- message_reads.user_id
ALTER TABLE public.message_reads
  DROP CONSTRAINT IF EXISTS message_reads_user_id_fkey;

ALTER TABLE public.message_reads
  ADD CONSTRAINT message_reads_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- profiles.id still references auth.users from the original migration.
-- Drop that too so custom-auth registrations can insert without an auth.users row.
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_id_fkey;
