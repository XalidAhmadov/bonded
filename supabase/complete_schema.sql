-- =====================================================================
-- BONDED PLATFORM — Complete Unified Database Schema
-- =====================================================================
-- Covers ALL spheres of the application:
--   1. Education System (DIM Exam Groups, Universities, Specialties)
--   2. User Profiles & Custom Auth (Students, Companies, Admins)
--   3. Student ID Verification System (Admin Verification)
--   4. Direct 1:1 Messaging & Read Receipts
--   5. Social Graph (Friendships & Connection Requests)
--   6. Student Groups, Group Chat, Members, Invitations & Join Requests
--   7. Company Portal, Job & Internship Postings, Job Applications
--   8. Automated Triggers & Functions (updated_at, chat preview bumping)
--   9. Permissions (Custom Auth: anon, authenticated, service_role)
--  10. Supabase Realtime Publication for live updates
--  11. Initial Reference Seed Data (DIM Exam Groups & Azerbaijan Universities)
--
-- Safe & Idempotent: Uses IF NOT EXISTS and ON CONFLICT to allow running
-- on both fresh projects and existing databases without data loss.
-- =====================================================================


-- =====================================================================
-- 1. EDUCATION SYSTEM
-- =====================================================================

-- ─── 1a. Education Groups (DIM Groups I–V) ───────────────────────────
CREATE TABLE IF NOT EXISTS public.education_groups (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT         NOT NULL UNIQUE CHECK (name IN ('I', 'II', 'III', 'IV', 'V')),
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ─── 1b. Universities ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.universities (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT         NOT NULL UNIQUE,
  short_name  TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_universities_short_name 
  ON public.universities (short_name);

-- ─── 1c. Specialties ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.specialties (
  id                  UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  university_id       UUID         NOT NULL REFERENCES public.universities(id) ON DELETE CASCADE,
  education_group_id  UUID         NOT NULL REFERENCES public.education_groups(id),
  code                TEXT         NOT NULL,
  name                TEXT         NOT NULL,
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT specialties_uni_code_unique UNIQUE (university_id, code)
);

CREATE INDEX IF NOT EXISTS idx_specialties_university  ON public.specialties (university_id);
CREATE INDEX IF NOT EXISTS idx_specialties_edu_group   ON public.specialties (education_group_id);
CREATE INDEX IF NOT EXISTS idx_specialties_code        ON public.specialties (code);
CREATE INDEX IF NOT EXISTS idx_specialties_uni_group   ON public.specialties (university_id, education_group_id);


-- =====================================================================
-- 2. USER PROFILES & CUSTOM AUTH
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id                  UUID         NOT NULL PRIMARY KEY, -- Client-generated UUID (custom auth)
  first_name          TEXT         NOT NULL DEFAULT '',
  last_name           TEXT         NOT NULL DEFAULT '',
  email               TEXT         UNIQUE,
  password            TEXT,
  university_id       UUID         REFERENCES public.universities(id) ON DELETE SET NULL,
  specialty_id        UUID         REFERENCES public.specialties(id)  ON DELETE SET NULL,
  education_group_id  UUID         REFERENCES public.education_groups(id) ON DELETE SET NULL,
  year                TEXT,
  entrance_score      NUMERIC      DEFAULT 0,
  group_number        INTEGER,
  avatar_url          TEXT,
  bio                 TEXT,
  interests           TEXT[]       DEFAULT '{}',
  profession          TEXT,
  is_admin            BOOLEAN      DEFAULT false,
  verification_status TEXT         DEFAULT 'pending',    -- 'pending' | 'approved' | 'rejected'
  account_type        TEXT         NOT NULL DEFAULT 'student', -- 'student' | 'company'
  founded_date        TEXT,                              -- For company accounts
  last_seen           TIMESTAMPTZ  DEFAULT now(),
  created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Ensure all existing profiles have these columns if table was created earlier
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_admin            BOOLEAN      DEFAULT false,
  ADD COLUMN IF NOT EXISTS verification_status TEXT         DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS account_type        TEXT         NOT NULL DEFAULT 'student',
  ADD COLUMN IF NOT EXISTS founded_date        TEXT;

UPDATE public.profiles SET account_type = 'student' WHERE account_type IS NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_email              ON public.profiles (email);
CREATE INDEX IF NOT EXISTS idx_profiles_university_id      ON public.profiles (university_id);
CREATE INDEX IF NOT EXISTS idx_profiles_specialty_id       ON public.profiles (specialty_id);
CREATE INDEX IF NOT EXISTS idx_profiles_education_group_id ON public.profiles (education_group_id);
CREATE INDEX IF NOT EXISTS idx_profiles_group_number       ON public.profiles (group_number);
CREATE INDEX IF NOT EXISTS idx_profiles_account_type       ON public.profiles (account_type);
CREATE INDEX IF NOT EXISTS idx_profiles_verification       ON public.profiles (verification_status);


-- =====================================================================
-- 3. STUDENT VERIFICATION SYSTEM
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.verification_requests (
  id             UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id        UUID         REFERENCES public.profiles(id) ON DELETE CASCADE,
  first_name     TEXT         NOT NULL,
  last_name      TEXT         NOT NULL,
  university     TEXT         NOT NULL,
  image_data     TEXT         NOT NULL,
  status         TEXT         NOT NULL DEFAULT 'pending', -- 'pending' | 'approved' | 'rejected'
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
  reviewed_at    TIMESTAMPTZ,
  reviewer_note  TEXT
);

CREATE INDEX IF NOT EXISTS idx_verification_requests_user   ON public.verification_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status ON public.verification_requests (status);


-- =====================================================================
-- 4. DIRECT 1:1 MESSAGING & READ RECEIPTS
-- =====================================================================

-- ─── 4a. Chats ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chats (
  id               UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  last_message     TEXT,
  last_message_at  TIMESTAMPTZ,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ─── 4b. Chat Participants ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_participants (
  chat_id    UUID         NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id    UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  joined_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_participants_user ON public.chat_participants (user_id);

-- ─── 4c. Messages ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.messages (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id     UUID         NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id   UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body        TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_chat_created ON public.messages (chat_id, created_at);

-- ─── 4d. Message Read Receipts ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.message_reads (
  message_id  UUID         NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  user_id     UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  chat_id     UUID         NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  read_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (message_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_message_reads_chat_user ON public.message_reads (chat_id, user_id);


-- =====================================================================
-- 5. SOCIAL GRAPH (FRIENDSHIPS & REQUESTS)
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.friendships (
  id             UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  requester_id   UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  addressee_id   UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status         TEXT         NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT friendships_req_addr_unique UNIQUE (requester_id, addressee_id),
  CONSTRAINT friendships_no_self_friend CHECK (requester_id != addressee_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_requester ON public.friendships (requester_id);
CREATE INDEX IF NOT EXISTS idx_friendships_addressee ON public.friendships (addressee_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status    ON public.friendships (status);


-- =====================================================================
-- 6. STUDENT GROUPS & COMMUNITIES
-- =====================================================================

-- ─── 6a. Groups ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.groups (
  id            UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name          TEXT         NOT NULL,
  description   TEXT         DEFAULT '',
  color         TEXT         DEFAULT 'from-blue-400 to-blue-600',
  bio           TEXT         DEFAULT '',
  created_by    UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  is_public     BOOLEAN      NOT NULL DEFAULT true,
  chat_enabled  BOOLEAN      NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_groups_created_by ON public.groups (created_by);
CREATE INDEX IF NOT EXISTS idx_groups_name       ON public.groups (name);

-- ─── 6b. Group Members ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.group_members (
  group_id   UUID         NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id    UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role       TEXT         NOT NULL DEFAULT 'member'
                          CHECK (role IN ('owner', 'admin', 'member')),
  joined_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_group_members_user ON public.group_members (user_id);

-- ─── 6c. Group Messages ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.group_messages (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id    UUID         NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  sender_id   UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body        TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_group_messages_group_created ON public.group_messages (group_id, created_at);

-- ─── 6d. Group Invitations ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.group_invitations (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id    UUID         NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  inviter_id  UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  invitee_id  UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status      TEXT         NOT NULL DEFAULT 'pending'
                           CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT group_invitations_unique UNIQUE (group_id, invitee_id)
);

CREATE INDEX IF NOT EXISTS idx_group_invitations_invitee ON public.group_invitations (invitee_id);

-- ─── 6e. Group Join Requests ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.group_join_requests (
  id          UUID         NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id    UUID         NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id     UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status      TEXT         NOT NULL DEFAULT 'pending'
                           CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT group_join_requests_unique UNIQUE (group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_group_join_requests_group ON public.group_join_requests (group_id);
CREATE INDEX IF NOT EXISTS idx_group_join_requests_user  ON public.group_join_requests (user_id);


-- =====================================================================
-- 7. COMPANY PORTAL (JOBS & APPLICATIONS)
-- =====================================================================

-- ─── 7a. Company Job Postings ────────────────────────────────────────
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

-- ─── 7b. Job Applications ────────────────────────────────────────────
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


-- =====================================================================
-- 8. FUNCTIONS & TRIGGERS
-- =====================================================================

-- ─── 8a. updated_at auto-setter ──────────────────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_groups_updated_at ON public.groups;
CREATE TRIGGER trg_groups_updated_at
  BEFORE UPDATE ON public.groups
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_friendships_updated_at ON public.friendships;
CREATE TRIGGER trg_friendships_updated_at
  BEFORE UPDATE ON public.friendships
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ─── 8b. Auto-bump chat preview on new message ───────────────────────
CREATE OR REPLACE FUNCTION public.bump_chat_on_message()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE public.chats
    SET last_message    = NEW.body,
        last_message_at = NEW.created_at
    WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bump_chat_on_message ON public.messages;
CREATE TRIGGER trg_bump_chat_on_message
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.bump_chat_on_message();

-- ─── 8c. Helper: Check chat participation ────────────────────────────
CREATE OR REPLACE FUNCTION public.is_chat_participant(_chat_id UUID, _user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.chat_participants
    WHERE chat_id = _chat_id AND user_id = _user_id
  );
$$;


-- =====================================================================
-- 9. PERMISSIONS & SECURITY
-- =====================================================================
-- Matches BONDED custom authentication model (anon & authenticated have full access)

ALTER TABLE public.education_groups     DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.universities         DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.specialties          DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles             DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats                DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_participants    DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages             DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reads        DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships          DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups               DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members        DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_messages       DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_invitations    DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_join_requests  DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_job_postings  DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applications      DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.education_groups     TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.universities         TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.specialties          TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.profiles             TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.verification_requests TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.chats                TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.chat_participants    TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.messages             TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.message_reads        TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.friendships          TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.groups               TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.group_members        TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.group_messages       TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.group_invitations    TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.group_join_requests  TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.company_job_postings  TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.job_applications      TO anon, authenticated, service_role;


-- =====================================================================
-- 10. REALTIME PUBLICATION
-- =====================================================================

ALTER TABLE public.education_groups     REPLICA IDENTITY FULL;
ALTER TABLE public.universities         REPLICA IDENTITY FULL;
ALTER TABLE public.specialties          REPLICA IDENTITY FULL;
ALTER TABLE public.profiles             REPLICA IDENTITY FULL;
ALTER TABLE public.verification_requests REPLICA IDENTITY FULL;
ALTER TABLE public.chats                REPLICA IDENTITY FULL;
ALTER TABLE public.chat_participants    REPLICA IDENTITY FULL;
ALTER TABLE public.messages             REPLICA IDENTITY FULL;
ALTER TABLE public.message_reads        REPLICA IDENTITY FULL;
ALTER TABLE public.friendships          REPLICA IDENTITY FULL;
ALTER TABLE public.groups               REPLICA IDENTITY FULL;
ALTER TABLE public.group_members        REPLICA IDENTITY FULL;
ALTER TABLE public.group_messages       REPLICA IDENTITY FULL;
ALTER TABLE public.group_invitations    REPLICA IDENTITY FULL;
ALTER TABLE public.group_join_requests  REPLICA IDENTITY FULL;
ALTER TABLE public.company_job_postings  REPLICA IDENTITY FULL;
ALTER TABLE public.job_applications      REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.education_groups; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.universities; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.specialties; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.verification_requests; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.chats; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_participants; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.messages; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.message_reads; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.friendships; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.groups; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.group_members; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.group_messages; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.group_invitations; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.group_join_requests; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.company_job_postings; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.job_applications; EXCEPTION WHEN duplicate_object THEN NULL; END;
END $$;


-- =====================================================================
-- 11. BASELINE REFERENCE SEED DATA
-- =====================================================================

-- ─── 11a. DIM Education Groups (I, II, III, IV, V) ───────────────────
INSERT INTO public.education_groups (name) VALUES
  ('I'),
  ('II'),
  ('III'),
  ('IV'),
  ('V')
ON CONFLICT (name) DO NOTHING;

-- ─── 11b. Universities of Azerbaijan ─────────────────────────────────
INSERT INTO public.universities (name, short_name) VALUES
  ('Bakı Dövlət Universiteti', 'BDU'),
  ('Azərbaycan Texniki Universiteti', 'AzTU'),
  ('Azərbaycan Dövlət İqtisad Universiteti', 'UNEC'),
  ('Azərbaycan Tibb Universiteti', 'ATU'),
  ('Azərbaycan Dövlət Neft və Sənaye Universiteti', 'ADNSU'),
  ('Azərbaycan Memarlıq və İnşaat Universiteti', 'AMİU'),
  ('Azərbaycan Dövlət Pedaqoji Universiteti', 'ADPU'),
  ('Azərbaycan Dillər Universiteti', 'ADU'),
  ('Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası', 'ADBTİA'),
  ('Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti', 'ADMİU'),
  ('Bakı Ali Neft Məktəbi', 'BANM'),
  ('ADA University', 'ADA'),
  ('Sumqayıt Dövlət Universiteti', 'SDU'),
  ('Gəncə Dövlət Universiteti', 'GDU'),
  ('Lənkəran Dövlət Universiteti', 'LDU'),
  ('Naxçıvan Dövlət Universiteti', 'NDU'),
  ('Odlar Yurdu Universiteti', 'OYU'),
  ('Xəzər Universiteti', 'XU'),
  ('Azərbaycan Müəllimlər İnstitutu', 'AMİ'),
  ('Azərbaycan Kooperasiya Universiteti', 'AKU'),
  ('Mingəçevir Dövlət Universiteti', 'MDU'),
  ('Şirvan Dövlət Universiteti', 'ŞDU'),
  ('Azərbaycan Dövlət Aqrar Universiteti', 'ADAU'),
  ('Azərbaycan Dövlət Dəniz Akademiyası', 'ADDA'),
  ('Azərbaycan Dövlət Hüquq Universiteti', 'ADHU'),
  ('Bakı Musiqi Akademiyası', 'BMA'),
  ('Azərbaycan Güvənlik Universiteti', 'AGU')
ON CONFLICT (name) DO NOTHING;


-- =====================================================================
-- 12. FIELD CATEGORIES (generalizes "IT Fields" into a catalog)
-- =====================================================================
-- See supabase/migrations/20260922000000_field_categories.sql for the
-- full commentary (backfill, verification queries, 8-field cap trigger).

CREATE TABLE IF NOT EXISTS public.field_categories (
  id          TEXT         NOT NULL PRIMARY KEY,
  label       TEXT         NOT NULL,
  sort_order  INTEGER      NOT NULL DEFAULT 0,
  is_active   BOOLEAN      NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

INSERT INTO public.field_categories (id, label, sort_order) VALUES
  ('it', 'IT', 1),
  ('business', 'Business', 2)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.fields (
  id           TEXT         NOT NULL PRIMARY KEY,
  category_id  TEXT         NOT NULL REFERENCES public.field_categories(id) ON DELETE CASCADE,
  label        TEXT         NOT NULL,
  sort_order   INTEGER      NOT NULL DEFAULT 0,
  is_active    BOOLEAN      NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  CONSTRAINT fields_category_label_unique UNIQUE (category_id, label)
);

CREATE INDEX IF NOT EXISTS idx_fields_category ON public.fields (category_id);

-- IT fields — seeded 1:1 from the current hardcoded IT_FIELDS list
INSERT INTO public.fields (id, category_id, label, sort_order) VALUES
  ('it-frontend-development', 'it', 'Frontend Development', 1),
  ('it-backend-development', 'it', 'Backend Development', 2),
  ('it-full-stack-development', 'it', 'Full Stack Development', 3),
  ('it-web-development', 'it', 'Web Development', 4),
  ('it-mobile-development', 'it', 'Mobile Development', 5),
  ('it-android-development', 'it', 'Android Development', 6),
  ('it-ios-development', 'it', 'iOS Development', 7),
  ('it-cross-platform-development', 'it', 'Cross Platform Development', 8),
  ('it-desktop-application-development', 'it', 'Desktop Application Development', 9),
  ('it-game-development', 'it', 'Game Development', 10),
  ('it-game-engine-development', 'it', 'Game Engine Development', 11),
  ('it-ar-development', 'it', 'AR Development', 12),
  ('it-vr-development', 'it', 'VR Development', 13),
  ('it-xr-development', 'it', 'XR Development', 14),
  ('it-ui-design', 'it', 'UI Design', 15),
  ('it-ux-design', 'it', 'UX Design', 16),
  ('it-product-design', 'it', 'Product Design', 17),
  ('it-graphic-programming', 'it', 'Graphic Programming', 18),
  ('it-computer-graphics', 'it', 'Computer Graphics', 19),
  ('it-animation-programming', 'it', 'Animation Programming', 20),
  ('it-software-engineering', 'it', 'Software Engineering', 21),
  ('it-software-architecture', 'it', 'Software Architecture', 22),
  ('it-api-development', 'it', 'API Development', 23),
  ('it-microservices-engineering', 'it', 'Microservices Engineering', 24),
  ('it-enterprise-software-development', 'it', 'Enterprise Software Development', 25),
  ('it-saas-development', 'it', 'SaaS Development', 26),
  ('it-embedded-systems', 'it', 'Embedded Systems', 27),
  ('it-firmware-development', 'it', 'Firmware Development', 28),
  ('it-robotics', 'it', 'Robotics', 29),
  ('it-iot-development', 'it', 'IoT Development', 30),
  ('it-mechatronics-programming', 'it', 'Mechatronics Programming', 31),
  ('it-automation-engineering', 'it', 'Automation Engineering', 32),
  ('it-industrial-software-engineering', 'it', 'Industrial Software Engineering', 33),
  ('it-plc-programming', 'it', 'PLC Programming', 34),
  ('it-cyber-security', 'it', 'Cyber Security', 35),
  ('it-ethical-hacking', 'it', 'Ethical Hacking', 36),
  ('it-penetration-testing', 'it', 'Penetration Testing', 37),
  ('it-red-teaming', 'it', 'Red Teaming', 38),
  ('it-blue-teaming', 'it', 'Blue Teaming', 39),
  ('it-purple-teaming', 'it', 'Purple Teaming', 40),
  ('it-digital-forensics', 'it', 'Digital Forensics', 41),
  ('it-malware-analysis', 'it', 'Malware Analysis', 42),
  ('it-reverse-engineering', 'it', 'Reverse Engineering', 43),
  ('it-cryptography', 'it', 'Cryptography', 44),
  ('it-application-security', 'it', 'Application Security', 45),
  ('it-cloud-security', 'it', 'Cloud Security', 46),
  ('it-network-security', 'it', 'Network Security', 47),
  ('it-information-security', 'it', 'Information Security', 48),
  ('it-soc-analysis', 'it', 'SOC Analysis', 49),
  ('it-threat-hunting', 'it', 'Threat Hunting', 50),
  ('it-incident-response', 'it', 'Incident Response', 51),
  ('it-osint', 'it', 'OSINT', 52),
  ('it-network-engineering', 'it', 'Network Engineering', 53),
  ('it-network-administration', 'it', 'Network Administration', 54),
  ('it-system-administration', 'it', 'System Administration', 55),
  ('it-linux-administration', 'it', 'Linux Administration', 56),
  ('it-windows-administration', 'it', 'Windows Administration', 57),
  ('it-virtualization', 'it', 'Virtualization', 58),
  ('it-cloud-computing', 'it', 'Cloud Computing', 59),
  ('it-cloud-architecture', 'it', 'Cloud Architecture', 60),
  ('it-devops', 'it', 'DevOps', 61),
  ('it-devsecops', 'it', 'DevSecOps', 62),
  ('it-site-reliability-engineering', 'it', 'Site Reliability Engineering', 63),
  ('it-infrastructure-engineering', 'it', 'Infrastructure Engineering', 64),
  ('it-platform-engineering', 'it', 'Platform Engineering', 65),
  ('it-kubernetes-engineering', 'it', 'Kubernetes Engineering', 66),
  ('it-database-administration', 'it', 'Database Administration', 67),
  ('it-database-engineering', 'it', 'Database Engineering', 68),
  ('it-data-engineering', 'it', 'Data Engineering', 69),
  ('it-big-data-engineering', 'it', 'Big Data Engineering', 70),
  ('it-business-intelligence', 'it', 'Business Intelligence', 71),
  ('it-data-analysis', 'it', 'Data Analysis', 72),
  ('it-data-science', 'it', 'Data Science', 73),
  ('it-statistical-computing', 'it', 'Statistical Computing', 74),
  ('it-artificial-intelligence', 'it', 'Artificial Intelligence', 75),
  ('it-ai-engineering', 'it', 'AI Engineering', 76),
  ('it-machine-learning', 'it', 'Machine Learning', 77),
  ('it-deep-learning', 'it', 'Deep Learning', 78),
  ('it-reinforcement-learning', 'it', 'Reinforcement Learning', 79),
  ('it-generative-ai', 'it', 'Generative AI', 80),
  ('it-computer-vision', 'it', 'Computer Vision', 81),
  ('it-nlp', 'it', 'NLP', 82),
  ('it-speech-recognition', 'it', 'Speech Recognition', 83),
  ('it-recommendation-systems', 'it', 'Recommendation Systems', 84),
  ('it-mlops', 'it', 'MLOps', 85),
  ('it-prompt-engineering', 'it', 'Prompt Engineering', 86),
  ('it-ai-research', 'it', 'AI Research', 87),
  ('it-bioinformatics', 'it', 'Bioinformatics', 88),
  ('it-computational-biology', 'it', 'Computational Biology', 89),
  ('it-health-informatics', 'it', 'Health Informatics', 90),
  ('it-fintech-development', 'it', 'FinTech Development', 91),
  ('it-blockchain-development', 'it', 'Blockchain Development', 92),
  ('it-smart-contract-development', 'it', 'Smart Contract Development', 93),
  ('it-web3-development', 'it', 'Web3 Development', 94),
  ('it-quantitative-computing', 'it', 'Quantitative Computing', 95),
  ('it-quantum-computing', 'it', 'Quantum Computing', 96),
  ('it-telecom-engineering', 'it', 'Telecom Engineering', 97),
  ('it-gis-development', 'it', 'GIS Development', 98),
  ('it-geographic-information-systems', 'it', 'Geographic Information Systems', 99),
  ('it-cad-software-development', 'it', 'CAD Software Development', 100),
  ('it-erp-development', 'it', 'ERP Development', 101),
  ('it-crm-development', 'it', 'CRM Development', 102),
  ('it-qa-engineering', 'it', 'QA Engineering', 103),
  ('it-software-testing', 'it', 'Software Testing', 104),
  ('it-test-automation', 'it', 'Test Automation', 105),
  ('it-accessibility-engineering', 'it', 'Accessibility Engineering', 106),
  ('it-human-computer-interaction', 'it', 'Human Computer Interaction', 107),
  ('it-technical-support', 'it', 'Technical Support', 108),
  ('it-it-support', 'it', 'IT Support', 109),
  ('it-solutions-architecture', 'it', 'Solutions Architecture', 110),
  ('it-technical-consulting', 'it', 'Technical Consulting', 111),
  ('it-research-engineering', 'it', 'Research Engineering', 112),
  ('it-compiler-engineering', 'it', 'Compiler Engineering', 113),
  ('it-operating-system-development', 'it', 'Operating System Development', 114),
  ('it-browser-engineering', 'it', 'Browser Engineering', 115),
  ('it-kernel-development', 'it', 'Kernel Development', 116),
  ('it-distributed-systems-engineering', 'it', 'Distributed Systems Engineering', 117),
  ('it-high-performance-computing', 'it', 'High Performance Computing', 118),
  ('it-parallel-computing', 'it', 'Parallel Computing', 119),
  ('it-scientific-computing', 'it', 'Scientific Computing', 120),
  ('it-audio-engineering', 'it', 'Audio Engineering', 121),
  ('it-video-processing', 'it', 'Video Processing', 122),
  ('it-streaming-systems-engineering', 'it', 'Streaming Systems Engineering', 123),
  ('it-search-engine-engineering', 'it', 'Search Engine Engineering', 124),
  ('it-ecommerce-engineering', 'it', 'Ecommerce Engineering', 125),
  ('it-payment-systems-engineering', 'it', 'Payment Systems Engineering', 126),
  ('it-adtech-engineering', 'it', 'AdTech Engineering', 127),
  ('it-edtech-development', 'it', 'EdTech Development', 128),
  ('it-legaltech-development', 'it', 'LegalTech Development', 129),
  ('it-govtech-development', 'it', 'GovTech Development', 130),
  ('it-space-software-engineering', 'it', 'Space Software Engineering', 131),
  ('it-autonomous-systems-engineering', 'it', 'Autonomous Systems Engineering', 132),
  ('it-drone-software-development', 'it', 'Drone Software Development', 133),
  ('it-simulation-engineering', 'it', 'Simulation Engineering', 134),
  ('it-digital-twin-engineering', 'it', 'Digital Twin Engineering', 135)
ON CONFLICT (id) DO NOTHING;

-- Business fields — starter list
INSERT INTO public.fields (id, category_id, label, sort_order) VALUES
  ('business-marketing', 'business', 'Marketing', 1),
  ('business-digital-marketing', 'business', 'Digital Marketing', 2),
  ('business-sales', 'business', 'Sales', 3),
  ('business-finance', 'business', 'Finance', 4),
  ('business-accounting', 'business', 'Accounting', 5),
  ('business-entrepreneurship-and-startups', 'business', 'Entrepreneurship & Startups', 6),
  ('business-product-management', 'business', 'Product Management', 7),
  ('business-project-management', 'business', 'Project Management', 8),
  ('business-business-analysis', 'business', 'Business Analysis', 9),
  ('business-human-resources', 'business', 'Human Resources', 10),
  ('business-supply-chain-and-logistics', 'business', 'Supply Chain & Logistics', 11),
  ('business-e-commerce', 'business', 'E-commerce', 12),
  ('business-consulting', 'business', 'Consulting', 13)
ON CONFLICT (id) DO NOTHING;


CREATE TABLE IF NOT EXISTS public.profile_fields (
  user_id     UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  field_id    TEXT         NOT NULL REFERENCES public.fields(id)   ON DELETE CASCADE,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, field_id)
);

CREATE INDEX IF NOT EXISTS idx_profile_fields_field ON public.profile_fields (field_id);

CREATE OR REPLACE FUNCTION public.enforce_profile_fields_limit()
RETURNS TRIGGER AS $$
DECLARE
  bad_user UUID;
  bad_count INTEGER;
BEGIN
  SELECT pf.user_id, COUNT(*) INTO bad_user, bad_count
  FROM public.profile_fields pf
  WHERE pf.user_id IN (SELECT DISTINCT user_id FROM new_rows)
  GROUP BY pf.user_id
  HAVING COUNT(*) > 8
  LIMIT 1;

  IF bad_user IS NOT NULL THEN
    RAISE EXCEPTION 'Profile % would have % fields selected — the max is 8', bad_user, bad_count
      USING ERRCODE = '23514';
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profile_fields_limit ON public.profile_fields;
CREATE TRIGGER trg_profile_fields_limit
AFTER INSERT ON public.profile_fields
REFERENCING NEW TABLE AS new_rows
FOR EACH STATEMENT
EXECUTE FUNCTION public.enforce_profile_fields_limit();

ALTER TABLE public.field_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fields           DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_fields   DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.field_categories TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.fields           TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.profile_fields   TO anon, authenticated, service_role;

ALTER TABLE public.field_categories REPLICA IDENTITY FULL;
ALTER TABLE public.fields           REPLICA IDENTITY FULL;
ALTER TABLE public.profile_fields   REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.field_categories; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.fields; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.profile_fields; EXCEPTION WHEN duplicate_object THEN NULL; END;
END $$;


-- =====================================================================
-- 13. JOBS SYNC + ATOMIC FIELD WRITES
-- =====================================================================
-- See supabase/migrations/20260922020000_jobs_sync_and_atomic_fields.sql
-- for full commentary.

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

  DELETE FROM public.profile_fields WHERE user_id = p_user_id;

  IF v_count > 0 THEN
    INSERT INTO public.profile_fields (user_id, field_id)
    SELECT p_user_id, unnest(v_ids);
  END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.set_profile_fields(UUID, TEXT[]) TO anon, authenticated, service_role;


-- =====================================================================
-- 14. RECOMMENDATION TABLES
-- =====================================================================
-- See supabase/migrations/20260922030000_recommendation_tables.sql for
-- full commentary.

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

CREATE TABLE IF NOT EXISTS public.profile_embeddings (
  user_id      UUID          NOT NULL PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  embedding    extensions.vector(768),
  source_hash  TEXT,
  updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);

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

ALTER TABLE public.profile_embeddings    DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_events DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_config DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.profile_embeddings    TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.recommendation_events TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.recommendation_config TO anon, authenticated, service_role;
