-- =====================================================================
-- BONDED — Field Categories (generalizes "IT Fields" into a catalog)
-- Migration: 20260922000000_field_categories.sql
-- =====================================================================
-- Adds:
--   1. field_categories table (IT, Business, ... more later — no code
--      changes needed to add a category, just insert a row)
--   2. fields table (seeded from the existing 135 hardcoded IT fields
--      in src/lib/itFields.ts / Auth.tsx / ProfileScreen.tsx, plus a
--      starter Business list)
--   3. profile_fields join table (replaces profiles.interests)
--   4. 8-fields-per-profile cap, enforced by trigger
--   5. Backfill of existing profiles.interests -> profile_fields
--   6. Verification query for any interests values that didn't map
--
-- NOTE: profiles.interests is intentionally NOT dropped by this
-- migration. Keep both in sync (or read-only from the old column)
-- until the backfill below has been verified against production data.
-- A follow-up migration will drop the column once confirmed.
-- =====================================================================

-- ─── 1. Field categories ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.field_categories (
  id          TEXT         NOT NULL PRIMARY KEY,          -- slug, e.g. 'it'
  label       TEXT         NOT NULL,
  sort_order  INTEGER      NOT NULL DEFAULT 0,
  is_active   BOOLEAN      NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

INSERT INTO public.field_categories (id, label, sort_order) VALUES
  ('it', 'IT', 1),
  ('business', 'Business', 2)
ON CONFLICT (id) DO NOTHING;


-- ─── 2. Fields ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.fields (
  id           TEXT         NOT NULL PRIMARY KEY,          -- slug, e.g. 'it-frontend-development'
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


-- ─── 3. Profile <-> Field join table ───────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profile_fields (
  user_id     UUID         NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  field_id    TEXT         NOT NULL REFERENCES public.fields(id)   ON DELETE CASCADE,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, field_id)
);

CREATE INDEX IF NOT EXISTS idx_profile_fields_field ON public.profile_fields (field_id);


-- ─── 4. Backfill from profiles.interests (labels) -> profile_fields ────
-- Only maps against the 'it' category, since interests only ever held
-- IT field labels up to this point.
INSERT INTO public.profile_fields (user_id, field_id)
SELECT p.id, f.id
FROM public.profiles p
CROSS JOIN LATERAL unnest(p.interests) AS interest_label
JOIN public.fields f
  ON f.category_id = 'it' AND f.label = interest_label
ON CONFLICT (user_id, field_id) DO NOTHING;

-- Verification: any interests values that did NOT map to a field.
-- Run this manually after the migration and review the output —
-- these are the "unmapped values" the plan calls for a report on.
-- (Expected to return 0 rows if interests only ever came from the
-- IT_FIELDS picker.)
SELECT p.id AS user_id, p.first_name, p.last_name, interest_label AS unmapped_value
FROM public.profiles p
CROSS JOIN LATERAL unnest(p.interests) AS interest_label
LEFT JOIN public.fields f
  ON f.category_id = 'it' AND f.label = interest_label
WHERE f.id IS NULL;

-- Verification: any profile that already has more than 8 distinct IT
-- fields (possible since there was no cap before this migration). The
-- new trigger below only governs future writes, so these are left as-is.
SELECT user_id, COUNT(*) AS field_count
FROM public.profile_fields
GROUP BY user_id
HAVING COUNT(*) > 8;


-- ─── 5. Enforce max 8 fields per profile ────────────────────────────────
-- Statement-level trigger (with a transition table) so it correctly
-- validates bulk inserts (e.g. saving several fields at once from the
-- picker), not just single-row inserts.
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


-- ─── 6. Permissions (custom auth uses anon and authenticated roles) ────
ALTER TABLE public.field_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fields           DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_fields   DISABLE ROW LEVEL SECURITY;

GRANT ALL ON TABLE public.field_categories TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.fields           TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.profile_fields   TO anon, authenticated, service_role;


-- ─── 7. Realtime ─────────────────────────────────────────────────────
ALTER TABLE public.field_categories REPLICA IDENTITY FULL;
ALTER TABLE public.fields           REPLICA IDENTITY FULL;
ALTER TABLE public.profile_fields   REPLICA IDENTITY FULL;

DO $$
BEGIN
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.field_categories; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.fields; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.profile_fields; EXCEPTION WHEN duplicate_object THEN NULL; END;
END $$;
