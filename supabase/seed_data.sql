-- =====================================================================
-- BONDED CONNECTIONS — Reference Data Seed
-- Generated from: butun_ixtisaslar_1.pdf (2025, Groups I–V)
-- Safe to re-run (WHERE NOT EXISTS guards everywhere).
-- Run AFTER applying migration 20260601000000_education_schema.sql
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
-- 0. WIPE existing reference data so stale rows don't linger
--    profiles.specialty_id / university_id are ON DELETE SET NULL so
--    existing user profiles are not deleted — just their FK is cleared.
-- ─────────────────────────────────────────────────────────────────────
DELETE FROM public.specialties;
DELETE FROM public.universities;
DELETE FROM public.education_groups;


-- ─────────────────────────────────────────────────────────────────────
-- 1. Repair unique constraint on specialties.code (code is per-university)
-- ─────────────────────────────────────────────────────────────────────
DO $$
BEGIN
  BEGIN
    ALTER TABLE public.specialties DROP CONSTRAINT idx_specialties_code;
  EXCEPTION WHEN undefined_object THEN NULL;
  END;
  BEGIN
    DROP INDEX IF EXISTS public.idx_specialties_code;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END $$;
CREATE INDEX IF NOT EXISTS idx_specialties_code ON public.specialties (code);


-- ─────────────────────────────────────────────────────────────────────
-- 1. Education groups (I–V)
-- ─────────────────────────────────────────────────────────────────────
INSERT INTO public.education_groups (name)
SELECT v FROM unnest(ARRAY['I','II','III','IV','V']) AS v
WHERE NOT EXISTS (SELECT 1 FROM public.education_groups WHERE name = v);


-- ─────────────────────────────────────────────────────────────────────
-- 2. Universities
-- ─────────────────────────────────────────────────────────────────────
INSERT INTO public.universities (name, short_name)
SELECT '"Azərbaycan" Universiteti', 'AU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = '"Azərbaycan" Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT '"Odlar Yurdu" Universiteti', 'OYU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = '"Odlar Yurdu" Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'ADA Universiteti', 'ADA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'ADA Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dillər Universiteti', 'ADU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dillər Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Aqrar Universiteti', 'ADAU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Aqrar Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası', 'ADBTA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Dəniz Akademiyası', 'ADDA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Dəniz Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti', 'ADMİU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Neft və Sənaye Universiteti', 'ADNSU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Pedaqoji Universiteti', 'ADPU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Pedaqoji Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət Rəssamlıq Akademiyası', 'ADRA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Dövlət İqtisad Universiteti', 'UNEC'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Dövlət İqtisad Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Kooperasiya Universiteti', 'AKU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Kooperasiya Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Memarlıq və İnşaat Universiteti', 'AzMİU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Memarlıq və İnşaat Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Milli Konservatoriyası', 'AMK'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Milli Konservatoriyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası', 'ADIDA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Texniki Universiteti', 'ATU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Texniki Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Texnologiya Universiteti', 'ATU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Texnologiya Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Tibb Universiteti', 'ATibU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Tibb Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Turizm və Menecment Universiteti', 'ATMU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Turizm və Menecment Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan İdman Akademiyası', 'AİA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan İdman Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan İlahiyyat İnstitutu', 'Aİİ'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan İlahiyyat İnstitutu');

INSERT INTO public.universities (name, short_name)
SELECT 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası', 'AƏSMA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Ali Neft Məktəbi', 'BANM'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Ali Neft Məktəbi');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Avrasiya Universiteti', 'BAU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Avrasiya Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Biznes Universiteti', 'BBU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Biznes Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Dövlət Universiteti', 'BDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Mühəndislik Universiteti', 'BMU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Mühəndislik Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Qızlar Universiteti', 'BQU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Qızlar Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Slavyan Universiteti', 'BSU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Slavyan Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Bakı Xoreoqrafiya Akademiyası', 'BXA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Bakı Xoreoqrafiya Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Dövlət Gömrük Komitəsinin Akademiyası', 'DGKA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Dövlət Gömrük Komitəsinin Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Gəncə Dövlət Universiteti', 'GDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Gəncə Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Lənkəran Dövlət Universiteti', 'LDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Lənkəran Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Milli Aviasiya Akademiyası', 'MAA'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Milli Aviasiya Akademiyası');

INSERT INTO public.universities (name, short_name)
SELECT 'Mingəçevir Dövlət Universiteti', 'MDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Mingəçevir Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Naxçıvan Dövlət Aqrar Universiteti', 'NDAU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Naxçıvan Dövlət Aqrar Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Naxçıvan Dövlət Universiteti', 'NDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Naxçıvan Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Naxçıvan Müəllimlər İnstitutu', 'NMİ'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Naxçıvan Müəllimlər İnstitutu');

INSERT INTO public.universities (name, short_name)
SELECT 'Qarabağ Universiteti', 'QU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Qarabağ Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Qərbi Kaspi Universiteti', 'QKU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Qərbi Kaspi Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Sumqayıt Dövlət Universiteti', 'SDU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Sumqayıt Dövlət Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Türkiyə-Azərbaycan Universiteti', 'TAU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Türkiyə-Azərbaycan Universiteti');

INSERT INTO public.universities (name, short_name)
SELECT 'Xəzər Universiteti', 'XU'
WHERE NOT EXISTS (SELECT 1 FROM public.universities WHERE name = 'Xəzər Universiteti');



-- ─────────────────────────────────────────────────────────────────────
-- 3. Specialties
-- ─────────────────────────────────────────────────────────────────────
INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111114', 'Fizika müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111114'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111147', 'İnformatika (rəqəmsal bacarıqlar) müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111147'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111163', 'Riyaziyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111163'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111196', 'Fizika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111196'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111228', 'Geologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111228'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111236', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111236'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111269', 'Mexanika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111269'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111277', 'Riyaziyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111277'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111317', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111317'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111325', 'Geologiya və geofizika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111325'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111341', 'Geomatika və geodeziya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111341'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111358', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111358'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111374', 'Kimya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111374'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111399', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111399'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111414', 'Meliorasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111414'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111422', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111422'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111439', 'Mühəndislik fizikası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111439'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111447', 'Torpaqşünaslıq və aqrokimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111447'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111455', 'Yerquruluşu və daşınmaz əmlakın kadastrı'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111455'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111139', 'Fizika müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111139'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111188', 'Riyaziyyat müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111188'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111211', 'Fizika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111211'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111252', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111252'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111293', 'Riyaziyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111293'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111333', 'Geologiya və geofizika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111333'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111382', 'Kimya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111382'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112735', 'Riyaziyyat müəllimliyi (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112735'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112743', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112743'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114111', 'Geologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114111'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114128', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114128'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114152', 'Cihaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114152'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114193', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114193'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114233', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114233'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114258', 'Energetika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114258'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114282', 'Geologiya və geofizika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114282'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114314', 'Həyat fəaliyyətinin təhlükəsizliyi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114314'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114322', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114322'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114355', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114355'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114371', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114371'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114396', 'Kimya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114396'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114436', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114436'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114469', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114469'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114485', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114485'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114517', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114517'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114525', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114525'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114533', 'Mexanika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114533'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114558', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114558'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114574', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114574'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114582', 'Mühəndislik fizikası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114582'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114599', 'Neft-qaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114599'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114639', 'Proseslərin avtomatlaşdırılması mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114639'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114663', 'Radiotexnika və telekommunikasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114663'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114688', 'Sənaye mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114688'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114144', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114144'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114177', 'Cihaz mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114177'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114185', 'Data analitikası (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114185'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114225', 'Ekologiya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114225'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114241', 'Elektrik və elektronika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114241'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114274', 'Energetika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114274'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114299', 'Geologiya və geofizika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114299'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114347', 'İnformasiya texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114347'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114363', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114363'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114388', 'İnşaat mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114388'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114428', 'Kimya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114428'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114452', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114452'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114477', 'Qida mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114477'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114493', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114493'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114541', 'Mexanika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114541'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114556', 'Mexatronika və robototexnika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114556'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114622', 'Neft-qaz mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114622'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114655', 'Proseslərin avtomatlaşdırılması mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114655'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114671', 'Radiotexnika və telekommunikasiya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114671'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '114696', 'Sənaye mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '114696'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116112', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116112'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116218', 'İnformasiya texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116218'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116267', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116267'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116291', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116291'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116315', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116315'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116478', 'Radiotexnika və telekommunikasiya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116478'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116137', 'Aerokosmik mühəndislik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116137'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116145', 'Cihaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116145'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116153', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116153'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116194', 'Həyat fəaliyyətinin təhlükəsizliyi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116194'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116234', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116234'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116242', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116242'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116275', 'Kimya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116275'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116283', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116283'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116356', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116356'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116331', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116372', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116389', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116389'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116397', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116397'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116412', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116412'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116429', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116429'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116437', 'Metallurgiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116437'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116445', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116445'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116453', 'Nəqliyyat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116453'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116494', 'Sənaye mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116518', 'Xüsusi rabitə vasitələri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116518'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116526', 'Silah sistemləri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116534', 'Sistemlər mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116534'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116161', 'Elektrik və elektronika mühəndisliyi (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116161'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116364', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116364'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116486', 'Radiotexnika və telekommunikasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116486'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116129', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116129'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116178', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116178'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116186', 'Energetika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116186'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116226', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116226'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116646', 'Proseslərin avtomatlaşdırılması mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116646'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118113', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118113'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118146', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118146'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118162', 'Geomatika və geodeziya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118162'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118179', 'Həyat fəaliyyətinin təhlükəsizliyi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118179'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118187', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118187'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118227', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118227'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118243', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118243'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118284', 'Kommunikasiya sistemləri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118284'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118324', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118324'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118332', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118332'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118349', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118349'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118357', 'Mexanika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118357'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118365', 'Meliorasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118365'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118381', 'Neft-qaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118381'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118398', 'Nəqliyyat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118398'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118413', 'Nəqliyyat tikintisi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118413'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118421', 'Proseslərin avtomatlaşdırılması mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118421'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118462', 'Yerquruluşu və daşınmaz əmlakın kadastrı'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118462'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118479', 'Yerquruluşu və daşınmaz əmlakın kadastrı'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118479'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118487', 'Memarlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118487'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118276', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118276'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118316', 'Kommunikasiya sistemləri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118316'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118438', 'Sənaye mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118438'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118446', 'İnşaatçılıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118446'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118138', 'Ekologiya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118138'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118154', 'Elektrik və elektronika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118154'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118219', 'İnformasiya texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118219'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118235', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118235'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118251', 'İnşaat mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118251'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118268', 'İnşaat mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118268'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118292', 'Kommunikasiya sistemləri mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118292'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118519', 'Memarlnq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118519'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121815', 'Fizika müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121815'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121831', 'İnformatika (rəqəmsal bacarıqlar) müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121831'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121856', 'Riyaziyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121856'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121872', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121872'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121897', 'Texnologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121897'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121823', 'Fizika müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121823'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121848', 'İnformatika (rəqəmsal bacarıqlar) müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121848'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121864', 'Riyaziyyat müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121864'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122374', 'Fizika müəllimliyi (Naxçıvan filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122374'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122382', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (Naxçıvan filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122382'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122455', 'İnformatika (rəqəmsal bacarıqlar) müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122455'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122463', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122463'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122569', 'Riyaziyyat müəllimliyi (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122569'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122577', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122577'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122593', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122593'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122714', 'Riyaziyyat müəllimliyi (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122714'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122722', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122722'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123119', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123119'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123135', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123135'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123143', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123143'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123151', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123151'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123184', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123184'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123224', 'Kommunikasiya sistemləri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123224'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123232', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123232'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123257', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123257'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123265', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123265'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128125', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128125'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128182', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128182'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128214', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128214'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128247', 'Energetika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128247'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128255', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128255'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128288', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128288'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128311', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128311'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128328', 'Kimya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128328'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128344', 'Kommunikasiya sistemləri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128344'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128352', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128352'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128377', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128377'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128385', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128385'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128417', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128417'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128425', 'Mexanika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128425'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128441', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128441'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128474', 'Nəqliyyat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128474'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128482', 'Nəqliyyat tikintisi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128482'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128499', 'Proseslərin avtomatlaşdırılması mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128499'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128522', 'Radiotexnika və telekommunikasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128522'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128539', 'Sənaye mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128539'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128555', 'İnşaatçılıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128555'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128563', 'İnşaatçılıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128563'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128571', 'İnşaatçılıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128571'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128199', 'Ekologiya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128199'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128222', 'Elektrik və elektronika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128222'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128263', 'İnformasiya texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128263'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128296', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128296'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128117', 'Fizika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128117'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128133', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128133'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128158', 'Riyaziyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128158'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128166', 'Data analitikası (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128166'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128336', 'Kimya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128336'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128281', 'Mədən mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128281'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128298', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128298'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129113', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129113'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131113', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131113'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131121', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131121'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131138', 'Riyaziyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131138'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131154', 'Elektrik və elektronika mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131154'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131162', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131162'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131179', 'İnformasiya texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131179'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131187', 'Kənd təsərrüfatı texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131187'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131195', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131195'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131219', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131219'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131227', 'Qida texnologiyaları (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131227'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131235', 'Memarlnq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131235'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131243', 'İnşaatçılıq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131243'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131251', 'Heyvandarlnq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131251'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131268', 'Heyvandarlnq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131268'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138112', 'Aerokosmik mühəndislik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138112'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138145', 'Aviasiya təhlükəsizliyi mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138145'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138161', 'Cihaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138161'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138186', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138186'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138218', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138218'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138234', 'Energetika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138234'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138259', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138259'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138283', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138283'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138323', 'Materiallar mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138323'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138331', 'Mexanika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138348', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138348'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138372', 'Mühəndislik fizikası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138389', 'Proseslərin avtomatlaşdırılması mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138389'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138397', 'Radiotexnika və telekommunikasiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138397'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136111', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136111'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139117', 'Dnniz naviqasiyasn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139117'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139125', 'Dnniz naviqasiyasn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139125'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139141', 'Dnniz naviqasiyasn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139141'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139158', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139158'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139166', 'Gnmi energetik qurnularnnnn istismarn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139166'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139174', 'Gnmi energetik qurnularnnnn istismarn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139174'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139182', 'Gnmi energetik qurnularnnnn istismarn mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139182'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '139199', 'Gnmiqaynrma və gnmi tnmiri mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Dəniz Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '139199'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141117', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141117'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141125', 'Kompüter elmləri (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141125'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141133', 'Data analitikası (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141133'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141141', 'Data analitikası (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141141'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141158', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141158'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141166', 'İnformasiya təhlükəsizliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141166'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141174', 'Kimya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141174'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141182', 'Kimya mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141182'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141199', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141199'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141214', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141214'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141222', 'Neft-qaz mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141222'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141239', 'Neft-qaz mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141239'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141247', 'Proseslərin avtomatlaşdırılması mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141247'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141255', 'Proseslərin avtomatlaşdırılması mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141255'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143515', 'Riyaziyyat və informatika müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143515'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143523', 'Texnologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143523'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143515', 'Riyaziyyat və informatika (rəqəmsal bacarıqlar) müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143515'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157211', 'Riyaziyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157211'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157213', 'Data analitikası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157213'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157214', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157214'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157215', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157215'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157219', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157219'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157221', 'Riyaziyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157221'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157372', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Türkiyə-Azərbaycan Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '175713', 'Kompüter mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '175713'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '175721', 'Qida mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '175721'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '175738', 'Sənaye mühəndisliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '175738'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152117', 'Riyaziyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152117'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152125', 'Riyaziyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152125'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152133', 'Data analitikası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152133'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152141', 'Elektrik və elektronika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152141'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152158', 'İnşaat mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152158'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152166', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152166'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152174', 'Logistika və nəqliyyat texnologiyaları mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152174'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152182', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'I'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152182'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111463', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111463'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111488', 'Sosiologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111488'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111528', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111528'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111536', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111536'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111544', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111544'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111577', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111577'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111593', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111593'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111617', 'Coğrafiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111617'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111625', 'Hidrometeorologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111625'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111633', 'Statistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111633'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111641', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111641'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111511', 'Sosiologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111511'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111569', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111569'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111585', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111585'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111658', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111658'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112751', 'Tarix və coğrafiya müəllimliyi (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112751'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112768', 'Turizm işinin təşkili (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112768'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112776', 'Turizm işinin təşkili (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112776'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116542', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116542'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116559', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116559'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116575', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116575'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116591', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116591'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116615', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116615'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116623', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116623'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116631', 'Statistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116631'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116648', 'Nəqliyyatda servis (avtomobil)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116648'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116567', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116567'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '116583', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texniki Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '116583'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118527', 'Davamlı inkişaf'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118527'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118535', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118535'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118543', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118543'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118551', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118551'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118568', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118568'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118576', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118576'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118584', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118584'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118616', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118616'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118624', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118624'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118592', 'Marketinq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118592'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121929', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121929'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121937', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121937'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121945', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121945'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122399', 'Tarix və coğrafiya müəllimliyi (Şamaxı filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122399'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122471', 'Tarix və coğrafiya müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122471'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122658', 'Tarix və coğrafiya müəllimliyi (Cəlilabad filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122658'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122739', 'Coğrafiya müəllimliyi (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Neft və Sənaye Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122739'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123346', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123346'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123354', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123354'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123395', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123395'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123419', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123419'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123451', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123451'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123468', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123468'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123484', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123484'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123492', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123492'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123549', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123549'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123557', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123557'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123613', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123613'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123621', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123621'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123646', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123646'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123654', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123654'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123687', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123687'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123695', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123695'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123743', 'Statistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123743'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123338', 'Beynəlxalq ticarnt və logistika (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123338'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123387', 'Biznesin idarə edilmnsi (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123387'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123443', 'Dövlət və bələdiyyə idarəetməsi (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123443'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123476', 'İİqtisadiyyat (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123476'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123524', 'Beynəlxalq ticarnt və logistika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123524'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123532', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123532'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123598', 'Marketinq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123598'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123679', 'Mühasibat (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123679'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123379', 'Beynəlxalq ticarnt və logistika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123379'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123435', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123435'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123558', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123558'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123735', 'Mühasibat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123735'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128588', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128588'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128596', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128596'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128611', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128611'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128628', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128628'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128652', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128652'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128669', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128669'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128677', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128677'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128693', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128693'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128717', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128717'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128733', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128733'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128741', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128741'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128758', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128758'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128766', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128766'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128774', 'Mühasibat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128774'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128725', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128725'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128636', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128636'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128685', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128685'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128799', 'Nəqliyyatda servis (avtomobil nəqliyyatn üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128799'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128814', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128814'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131276', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131276'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131284', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131284'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131292', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131292'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129138', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129138'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129154', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129154'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129179', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129179'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129195', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129195'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136128', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136128'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136136', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136136'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136144', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136144'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136152', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136152'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136169', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136169'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136177', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136177'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136185', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136185'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136193', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136193'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136217', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136217'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136233', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136233'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138445', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138445'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138478', 'Hidrometeorologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138478'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138437', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138437'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138461', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138461'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138453', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138453'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141263', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141263'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141271', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141271'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141288', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141288'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141296', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Ali Neft Məktəbi' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141296'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141539', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141539'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141547', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141547'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141555', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141555'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141563', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141563'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142332', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142332'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142349', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142349'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142357', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142357'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142373', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142373'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142381', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142381'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142392', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142392'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142454', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142454'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142462', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142462'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142413', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142413'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142421', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142421'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142438', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142438'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142446', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142446'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142536', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142536'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148327', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148327'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148335', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148335'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148343', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148343'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148351', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148351'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148368', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148368'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148376', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148376'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148384', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148384'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148392', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148392'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148416', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148416'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148424', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148424'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148432', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148432'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148449', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148449'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148457', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148457'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148465', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148465'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148473', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148473'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148481', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148481'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148498', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148498'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149275', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149275'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149283', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149283'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149291', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149291'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149315', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149315'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149323', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149323'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149331', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149348', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149348'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149356', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149356'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149364', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149364'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149372', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149389', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149389'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149397', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149397'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149412', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149412'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149429', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149429'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149437', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149437'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149445', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149445'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149453', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149453'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149461', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149461'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145216', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145216'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145224', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145224'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145232', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145232'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145249', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145249'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145257', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145257'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145265', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145265'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145273', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145273'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145281', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145281'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145298', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145298'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145313', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145313'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145321', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145321'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145338', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145338'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145346', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145346'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145354', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145354'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145362', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145362'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145379', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145379'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151315', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151315'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151323', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151323'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151331', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151348', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151348'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151356', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151356'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151364', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151364'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151372', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151389', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151389'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151397', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151397'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151412', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151412'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151429', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151429'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151437', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151437'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151445', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151445'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151453', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151453'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154175', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154175'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154183', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154183'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154191', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154191'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154215', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154215'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154223', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154223'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154272', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154272'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154289', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154289'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154297', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154297'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154312', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154312'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154329', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154329'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154337', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154337'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154345', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154345'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154353', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154353'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154361', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154361'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154231', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154231'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154248', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154248'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154256', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154256'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154264', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154264'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154378', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154378'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155155', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155155'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155163', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155163'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155171', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155171'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155196', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155196'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155228', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155228'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155244', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155244'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155252', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155252'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155277', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155277'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155285', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155285'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155317', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155317'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155325', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155325'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155188', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155188'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155211', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155211'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155236', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155236'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155269', 'Marketinq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155269'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155293', 'Mühasibat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155293'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155333', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155333'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158217', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158217'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158233', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158233'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158225', 'Beynəlxalq ticarnt və logistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158225'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158241', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158241'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158266', 'Tarix və coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158266'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158274', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158274'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158282', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158282'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158299', 'Maliyyə (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158299'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158314', 'Marketinq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158314'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158322', 'Menecment (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158322'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158339', 'Mühasibat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158339'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158347', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158347'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151461', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151461'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151478', 'Turizm bələdçiliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151478'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151486', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151486'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151494', 'Turizm işinin təşkili (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142454', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Aqrar Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142454'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142462', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Aqrar Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142462'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157123', 'Kompüter elmləri'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157123'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157131', 'Cihaz mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157131'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157148', 'Ekologiya mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157148'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157164', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157164'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157189', 'İnformasiya təhlükəsizliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157189'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157212', 'Kompüter mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157212'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157229', 'Qida mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157229'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157245', 'Mexatronika və robototexnika mühəndisliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157245'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157253', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157253'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157261', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157261'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157278', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157278'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157286', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157286'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157294', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157294'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157318', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157318'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157326', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157326'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157334', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157334'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157342', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157342'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157359', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157359'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157367', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157367'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162112', 'İnformasiya texnologiyaları'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162112'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162129', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162129'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162145', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162145'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162153', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162153'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162161', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162161'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162178', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162178'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162186', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162186'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162194', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162194'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162218', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162218'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162226', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162226'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162234', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162234'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162137', 'Biznesin idarə edilmnsi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162137'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163117', 'Riyaziyyat və informatika müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163117'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163125', 'Coğrafiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163125'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163133', 'Riyaziyyat və informatika müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163133'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163141', 'Xarici dil müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163141'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164357', 'Turizm işinin təşkili'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164357'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164162', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164162'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164251', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164251'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164284', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164284'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164324', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164324'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165272', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165272'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165289', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165289'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165297', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165297'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '171185', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '171185'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '171193', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '171193'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165134', 'Biznesin idarə edilmnsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165134'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165142', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165142'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165159', 'Dövlət və bələdiyyə idarəetməsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165159'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165167', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165167'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165175', 'İİqtisadiyyat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165175'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165191', 'Maliyyə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165191'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165215', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165215'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165223', 'Marketinq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165223'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165231', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165231'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165248', 'Menecment'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165248'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165256', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165256'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165264', 'Mühasibat'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165264'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165183', 'İİqtisadiyyat (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Biznes Universiteti' AND eg.name = 'II'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165183'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111666', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111666'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111682', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111682'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111699', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111699'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111739', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111739'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111755', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111755'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111788', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111788'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111828', 'Fəlsəfə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111828'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111836', 'Filologiya (ərəb dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111836'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111844', 'Filologiya (fars dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111844'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111852', 'Filologiya (türk dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111852'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111869', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111869'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111877', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111877'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111885', 'Filologiya (alman dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111885'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111893', 'Filologiya (fransnz dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111893'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111917', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111917'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111941', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111941'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111958', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111958'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111999', 'Kitabxanaçılıq və informasiya fəaliyyəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111999'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112127', 'Politologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112127'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112143', 'Regionşünaslıq (Qafqaz ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112143'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112151', 'Regionşünaslıq (Amerika üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112151'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112168', 'Regionşünaslıq (ərəb ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112168'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112176', 'Regionşünaslıq (nran üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112176'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112184', 'Regionşünaslıq (Türkiyn üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112184'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112192', 'Regionşünaslıq (nsrail üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112192'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112216', 'Regionşünaslıq (Pakistan üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112216'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112224', 'Regionşünaslıq (Koreya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112224'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112232', 'Regionşünaslıq (Yaponiya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112232'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112346', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112346'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112354', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112354'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112387', 'Tərcümə (ərəb dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112387'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112395', 'Tərcümə (fars dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112395'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112419', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112419'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112427', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112427'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112451', 'Jurnalistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112451'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112722', 'Tarix müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112722'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111771', 'Beynəlxalq münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111771'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111811', 'Dövlət və ictimai münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111811'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '111982', 'Hüquqşünaslıq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '111982'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112119', 'Kitabxanaçılıq və informasiya fəaliyyəti (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112119'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112321', 'Regionşünaslıq (Qafqaz ölknlnri üzrə, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112321'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112338', 'Regionşünaslıq (Amerika üzrə, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112338'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112379', 'Tarix (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112379'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112443', 'Sosial iş (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112443'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112476', 'Jurnalistika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112476'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112784', 'Məktəbəqədər təhsil (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112784'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112792', 'Filologiya (Azərbaycan dili və ədəbiyyat, Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112792'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112816', 'Filologiya (Azərbaycan dili və ədəbiyyat, Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112816'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112824', 'Tarix (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112824'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112832', 'Tarix (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112832'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112849', 'Sosial iş (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112849'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112857', 'Sosial iş (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112857'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121053', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121053'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121961', 'Dil və ədəbiyyat müəllimliyi (türk dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121961'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121986', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121986'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121994', 'Xarici dil müəllimliyi (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121994'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122114', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122114'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122147', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122147'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122171', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122171'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122211', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122211'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122236', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122236'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122252', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122252'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122269', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122269'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122139', 'Xüsusi pedaqogika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122139'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122163', 'İbtidai sinif müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122163'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122196', 'Məktəbəqədər təhsil (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122196'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122414', 'Azərbaycan dili və ədəbiyyat müəllimliyi (Şamaxı filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122414'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122422', 'Məktəbəqədər təhsil (Şamaxı filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122422'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122439', 'Tarix müəllimliyi (Şamaxı filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122439'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122447', 'Təhsildən sosial-psixoloji xidmət (Şamaxı filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122447'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122488', 'Azərbaycan dili və ədəbiyyat müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122488'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122496', 'Xarici dil müəllimliyi (ingilis dili üzrə, İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122496'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122511', 'İbtidai sinif müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122511'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122528', 'Məktəbəqədər təhsil (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122528'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122536', 'Tarix müəllimliyi (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122536'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122544', 'Təhsildən sosial-psixoloji xidmət (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122544'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122552', 'Sosial iş (İnki filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122552'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122585', 'Azərbaycan dili və ədəbiyyat müəllimliyi (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122585'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122617', 'Məktəbəqədər təhsil (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122617'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122625', 'Tarix müəllimliyi (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122625'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122633', 'Təhsildən sosial-psixoloji xidmət (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122633'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122641', 'Sosial iş (Ağcabədi filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122641'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122666', 'Azərbaycan dili və ədəbiyyat müəllimliyi (Cəlilabad filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122666'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122674', 'İbtidai sinif müəllimliyi (Cəlilabad filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122674'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122682', 'Məktəbəqədər təhsil (Cəlilabad filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122682'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122699', 'Təhsildən sosial-psixoloji xidmət (Cəlilabad filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122699'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122747', 'Azərbaycan dili və ədəbiyyat müəllimliyi (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122747'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122755', 'Xarici dil müəllimliyi (ingilis dili üzrə, Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122755'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123768', 'Məktəbəqədər təhsil (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123768'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123784', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123784'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123792', 'Sosial iş (Quba filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123792'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123751', 'Beynəlxalq münasibətlər (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123751'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126116', 'Azərbaycan dili və ədəbiyyat müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126116'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126124', 'Dil və ədəbiyyat müəllimliyi (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126124'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126132', 'Dil və ədəbiyyat müəllimliyi (alman dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126132'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126149', 'Dil və ədəbiyyat müəllimliyi (fransnz dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126149'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126181', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126181'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126198', 'Xarici dil müəllimliyi (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126198'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126213', 'Xarici dil müəllimliyi (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126213'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126262', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126262'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126287', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126287'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126295', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126295'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126335', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126335'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126343', 'Filologiya (alman dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126343'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126351', 'Filologiya (fransnz dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126351'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126368', 'Filologiya (ispan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126368'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126376', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126376'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126432', 'Regionşünaslıq (Böyük Britaniya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126432'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126457', 'Regionşünaslıq (Almaniya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126457'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126465', 'Regionşünaslıq (Amerika üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126465'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126473', 'Regionşünaslıq (Norveç üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126473'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126481', 'Regionşünaslıq (Qafqaz ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126481'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126498', 'Regionşünaslıq (nsrail və Yaxnn nnrq ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126498'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126513', 'Regionşünaslıq (Yaponiya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126513'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126521', 'Regionşünaslıq (ərəb ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126521'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126538', 'Regionşünaslıq (Çin üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126538'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126546', 'Regionşünaslıq (Cnnubi Amerika üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126546'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126554', 'Regionşünaslıq (Mnrknzi və nnrqi Avropa üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126554'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126562', 'Regionşünaslıq (Rusiya üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126562'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126579', 'Regionşünaslıq (Türkiyn üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126579'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126587', 'Regionşünaslıq (Balkan ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126587'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126595', 'Regionşünaslıq (Afrika üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126595'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126619', 'Regionşünaslıq (Hindistan üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126619'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126627', 'Regionşünaslıq (Pakistan üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126627'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126765', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126765'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126773', 'Tərcümə (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126773'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126781', 'Tərcümə (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126781'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126798', 'Tərcümə (ispan dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126798'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126813', 'Tərcümə (Koreya dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126813'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126821', 'Tərcümə (rus dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126821'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126838', 'Tərcümə (ərəb dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126838'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126846', 'Tərcümə (ermnni dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126846'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126279', 'Məktəbəqədər təhsil (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126279'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126327', 'Beynəlxalq münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126327'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126749', 'Regionşünaslıq (Böyük Britaniya üzrə, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126749'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126757', 'Regionşünaslıq (Amerika üzrə, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126757'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '126919', 'Jurnalistika (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dillər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '126919'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127112', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127112'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127137', 'Xarici dil müəllimliyi (rus dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127137'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127145', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127145'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127153', 'Xarici dil müəllimliyi (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127153'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127161', 'Xarici dil müəllimliyi (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127161'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127194', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127194'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127226', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127226'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127242', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127242'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127275', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127275'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127291', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127291'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127315', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127315'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127331', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127348', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127348'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127356', 'Filologiya (türk dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127356'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127397', 'Regionşünaslıq (Xəzəryanı ölknlnr üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127397'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127412', 'Regionşünaslıq (nnrqi Avropa ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127412'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127429', 'Regionşünaslıq (Balkan ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127429'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127437', 'Regionşünaslıq (Mnrknzi Asiya ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127437'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127445', 'Regionşünaslıq (Qnrbi Avropa ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127445'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127453', 'Tərcümə (Azərbaycan dili-ingilis dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127453'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127461', 'Tərcümə (Azərbaycan dili-rus dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127461'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127478', 'Tərcümə (Azərbaycan dili-bolqar dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127478'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127486', 'Tərcümə (Azərbaycan dili-yunan dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127486'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127494', 'Tərcümə (Azərbaycan dili-alman dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127518', 'Tərcümə (Azərbaycan dili-çex dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127518'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127526', 'Tərcümə (Azərbaycan dili-polyak dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127534', 'Tərcümə (Azərbaycan dili-Ukrayna dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127534'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127542', 'Tərcümə (Azərbaycan dili-fransnz dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127542'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127575', 'Jurnalistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127575'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129227', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129227'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129243', 'Dövlət və ictimai münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129243'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129268', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129268'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '129284', 'Politologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Respublikası Prezidentinin yanında Dövlət İdarəçilik Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '129284'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131332', 'Beynəlxalq münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131332'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131349', 'Dövlət və ictimai münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131349'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131357', 'Hüquqşünaslıq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131357'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131365', 'Kommunikasiya və rəqəmsal media (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131365'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134143', 'Kitabxanaçılıq və informasiya fəaliyyəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134143'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134151', 'ədəbi yaradıcılıq və ekran dramaturqiyası'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134151'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134168', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134168'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134184', 'Sənətşünaslıq (teatrnünaslnq)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134184'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134192', 'Sənətşünaslıq (kinonünaslnq)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134192'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134216', 'Sənətşünaslıq (təsviri sənətin tarixi və nəzəriyyəsi)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134216'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134232', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134232'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135123', 'Sənətşünaslıq (təsviri incnsənət tarixi və nəzəriyyəsi, incnsənət əsərlərinin bərpası və ekspertizasn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135123'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136241', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136241'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136258', 'Tərcümə (ingilis dili-Azərbaycan dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136258'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136266', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136266'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136274', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Turizm və Menecment Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136274'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138486', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138486'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138494', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '138526', 'Hüquqşünaslıq (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Milli Aviasiya Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '138526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '141563', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Dövlət Gömrük Komitəsinin Akademiyası' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '141563'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152288', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152288'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152296', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152296'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152311', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152311'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152328', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152328'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152336', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152336'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152344', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152344'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152352', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152352'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142479', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142479'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142487', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142487'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142495', 'Xarici dil müəllimliyi (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142495'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142519', 'Xarici dil müəllimliyi (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142519'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142527', 'Xarici dil müəllimliyi (rus dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142527'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142535', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142535'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142543', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142543'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142568', 'Dövlət və ictimai münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142568'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142576', 'Filologiya (Azərbaycan dili və ədəbiyyat üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142576'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142584', 'Filologiya (Azərbaycan dili və ədəbiyyat üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142584'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142592', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142592'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142616', 'Hüquqşünaslıq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142616'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142624', 'Kitabxanaçılıq və informasiya fəaliyyəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142624'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142632', 'Kitabxanaçılıq və informasiya fəaliyyəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142632'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142649', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142649'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142657', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142657'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142665', 'Tərcümə (ingilis dili-Azərbaycan dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142665'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142673', 'Tərcümə (fars dili-Azərbaycan dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142673'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142681', 'Tərcümə (ərəb dili-Azərbaycan dili)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142681'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142698', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142698'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142713', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142713'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142721', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142721'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142738', 'Jurnalistika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142738'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142551', 'Beynəlxalq münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142551'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143531', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143531'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143548', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143548'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143556', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143556'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143564', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143564'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143572', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143572'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143589', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143589'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143597', 'Kitabxanaçılıq və informasiya fəaliyyəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143597'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145387', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145387'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145395', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145395'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145419', 'Xarici dil müəllimliyi (rus dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145419'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145427', 'Xarici dil müəllimliyi (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145427'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145435', 'Xarici dil müəllimliyi (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145435'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145451', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145451'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145468', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145468'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145476', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145476'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145484', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145484'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145492', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145492'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145516', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145516'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145524', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145524'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145532', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145532'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148513', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148513'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148521', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148521'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148538', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148538'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148546', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148546'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148554', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148554'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148562', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148562'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148579', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148579'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148587', 'Filologiya (Azərbaycan dili və ədəbiyyat üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148587'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148595', 'Politologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148595'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148619', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148619'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148627', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148627'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148635', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148635'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149478', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149478'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149486', 'Dil və ədəbiyyat müəllimliyi (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149486'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149494', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149526', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149534', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149534'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149542', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149542'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149559', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149559'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149567', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149567'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149575', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149575'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149583', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149583'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151518', 'Azərbaycan dili və ədəbiyyatı müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151518'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151526', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151534', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151534'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151542', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151542'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151559', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151559'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151567', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151567'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151575', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151575'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151583', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151583'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151591', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151591'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157431', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157431'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157456', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157456'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157464', 'Fəlsəfə'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157464'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157472', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157472'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157489', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157489'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157512', 'Regionşünaslıq (Amerika, Böyük Britaniya, Almaniya və Çin üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157512'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157529', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157529'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157537', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157537'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157545', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157545'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157561', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157561'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157553', 'Sosial iş (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157553'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157497', 'Regionşünaslıq (Amerika, Böyük Britaniya, Almaniya və Çin üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157497'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '153113', 'Dinnünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İlahiyyat İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '153113'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '153121', 'nslamnünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İlahiyyat İnstitutu' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '153121'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158371', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158371'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158396', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158396'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158428', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158428'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158363', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158363'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158388', 'İbtidai sinif müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158388'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158411', 'Beynəlxalq münasibətlər (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158411'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158436', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158436'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158444', 'Politologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158444'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158452', 'Regionşünaslıq (Amerika, Avropa, Asiya və nnrq ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158452'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158469', 'Tərcümə (ingilis, ərəb, fars və çin dillnri, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158469'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162291', 'Regionşünaslıq (ABn və Kanada)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162291'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162315', 'Regionşünaslıq (Avropa ölknlnri)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162315'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162331', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162331'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162348', 'Tərcümə (alman dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162348'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162356', 'Tərcümə (fransnz dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162356'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162364', 'Tərcümə (ərəb dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162364'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162372', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162372'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162389', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162389'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163141', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163141'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163158', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163158'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163166', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163166'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163174', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163174'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163182', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163182'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163199', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163199'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163214', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163214'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164381', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164381'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164398', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164398'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164413', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164413'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164421', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164421'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164446', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164446'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164454', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164454'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164462', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164462'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164438', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164438'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154386', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154386'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154394', 'Regionşünaslıq (Avropa ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154394'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154418', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154418'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154426', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154426'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154434', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154434'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154442', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154442'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155341', 'Xüsusi pedaqogika'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155341'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155358', 'Təhsildən sosial-psixoloji xidmət'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155358'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155366', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155366'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155374', 'Dövlət və ictimai münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155374'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155382', 'Fəlsəfə'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155382'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155399', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155399'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155414', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155414'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155422', 'Politologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155422'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155439', 'Regionşünaslıq (Avropa ölknlnri üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155439'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155447', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155447'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155455', 'Tərcümə (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155455'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155463', 'Muzey, arxiv işi və abidələrin qorunması'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155463'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155471', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155471'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155488', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155488'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '155496', 'Sosial iş (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Azərbaycan" Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '155496'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149494', 'Xarici dil müəllimliyi (ingilis dili üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149494'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149526', 'İbtidai sinif müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149526'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149534', 'Məktəbəqədər təhsil'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149534'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149542', 'Tarix müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149542'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149567', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149567'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149575', 'Tarix'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149575'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149583', 'Sosial iş'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149583'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162242', 'Beynəlxalq münasibətlər'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162242'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162267', 'Filologiya (Azərbaycan dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162267'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162275', 'Filologiya (türk dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162275'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '162283', 'Filologiya (ingilis dili və ədəbiyyatı üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'III'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '162283'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112464', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112464'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112516', 'Kimya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112516'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112532', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112532'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112549', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112549'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112573', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112573'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112581', 'Biotexnologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112581'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112613', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112613'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112646', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112646'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112679', 'Kimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112679'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112719', 'Su bioehtiyatlarn və akvakultura'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112719'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112727', 'Bitki mühafiznsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112727'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112565', 'Psixologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112565'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112598', 'Biologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112598'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112638', 'Biotexnologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112638'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112662', 'Ekologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112662'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112695', 'Kimya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112695'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112865', 'Kimya və biologiya müəllimliyi (Qazax filialı)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112865'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121126', 'nczaçnlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121126'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121142', 'Fizioterapiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121142'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121175', 'Tibb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121175'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121191', 'Tibb bacnsn (qardann) ini'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121191'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121289', 'Stomatologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121289'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121312', 'Tibb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121312'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '121337', 'Tibb (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '121337'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123824', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123824'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127591', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127591'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '127615', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Slavyan Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '127615'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137149', 'Fiziologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Əmək və Sosial Münasibətlər Akademiyası' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137149'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128822', 'Biotexnologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128822'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128839', 'Kimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128839'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128847', 'Kimya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Tibb Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128847'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152269', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152269'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152377', 'Kimya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152377'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152385', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152385'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152393', 'Tibb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152393'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152417', 'Tibb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152417'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142746', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142746'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142754', 'Kimya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142754'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142762', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142762'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142779', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142779'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142787', 'Kimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142787'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142795', 'Baytarlnq tnbabnti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142795'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142819', 'nczaçnlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142819'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142827', 'nctimai sanlamlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142827'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142835', 'Tibb bacnsn (qardann) ini'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142835'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142843', 'Stomatologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142843'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142851', 'Tibb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142851'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142868', 'Tibb (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142868'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148643', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148643'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148651', 'Kimya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148651'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148676', 'Kimya və biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148676'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148684', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148684'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148692', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148692'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148716', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148716'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148724', 'Kimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148724'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148668', 'Kimya müəllimliyi (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148668'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149591', 'Kimya və biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149591'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '149615', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Mingəçevir Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '149615'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145549', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145549'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145557', 'Kimya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145557'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145565', 'Kimya və biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145565'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145573', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145573'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145581', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145581'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145598', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145598'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145613', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145613'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145621', 'Kimya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145621'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151615', 'Kimya və biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151615'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151623', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151623'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151631', 'Bançnlnq və tnrnvnzçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151631'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151648', 'Baytarlnq tnbabnti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151648'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157578', 'Psixologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157578'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157594', 'Biologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157594'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144625', 'Biotexnologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144625'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144633', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144633'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144641', 'Su bioehtiyatlarn və akvakultura'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144641'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144666', 'Bançnlnq və tnrnvnzçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144666'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144674', 'Bançnlnq və tnrnvnzçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144674'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144699', 'Baytarlnq tnbabnti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144699'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144747', 'Bitki mühafiznsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144747'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144755', 'nczaçnlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144755'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144658', 'Bançnlnq və tnrnvnzçilik (tədris türk dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144658'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '144722', 'Baytarlnq tnbabnti (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Aqrar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '144722'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '154459', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Kooperasiya Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '154459'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158477', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158477'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158485', 'Kimya və biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158485'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158493', 'Psixologiya (tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158493'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158525', 'Baytarlnq tnbabnti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158525'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157586', 'Biologiya müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157586'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157618', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157618'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157626', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157626'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157634', 'Su bioehtiyatlarn və akvakultura'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157634'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164487', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164487'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164495', 'Biologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164495'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164519', 'Ekologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Qızlar Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164519'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '163222', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texnologiya Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '163222'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '165272', 'Psixologiya'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Avrasiya Universiteti' AND eg.name = 'IV'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '165272'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '112873', 'Dizayn (interyer dizayn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '112873'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118632', 'Dizayn (interyer dizayn, qrafik dizayn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118632'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '118657', 'Dizayn (interyer dizayn, qrafik dizayn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Memarlıq və İnşaat Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '118657'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122325', 'Fiziki tnrbiyn və çannrnnaqndnrki haznrlnq müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122325'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122341', 'Musiqi müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122341'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '122358', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Pedaqoji Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '122358'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '123849', 'Dizayn (geyim dizaynn, mühit dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət İqtisad Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '123849'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128855', 'Dekorativ-tntbiqi snnat (sahnlnr üzrə)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128855'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128863', 'Dizayn (interyer dizaynn, qrafik dizaynn, sənaye dizaynn, geyim dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128863'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '128871', 'Dizayn (interyer dizaynn, qrafik dizaynn, sənaye dizaynn, geyim dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Mühəndislik Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '128871'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131373', 'Dizayn (interyer dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131373'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '131381', 'Dizayn (kommunikasiya dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'ADA Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '131381'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134249', 'Musiqi müəllimliyi (fortepiano, klarnet, saksafon, fleyta, znrb alntlnri, tar, kamança, saz, qanun, nanara, balaban,'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134249'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134257', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134257'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134273', 'Aktyor sənəti (dram teatr və kino aktyoru, musiqili teatr aktyoru)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134273'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134281', 'Aktyor sənəti (dram teatr və kino aktyoru, musiqili teatr aktyoru)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134281'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134298', 'Aktyor sənəti (dram teatr və kino aktyoru, musiqili teatr aktyoru)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134298'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134321', 'Dekorativ-tntbiqi snnat (bndii xalça, bndii toxuculuq)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134321'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134346', 'Dizayn (interyer dizaynn, qrafik dizayn və geyim dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134346'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134362', 'Instrumental ifaçnlnq (fortepiano, violin, viola, qanun, vokal, xor dirijorlunu, musiqi nəzəriyyəsi)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134362'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134379', 'Instrumental ifaçnlnq (tar, kamança, qanun, nanara, balaban, saz)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134379'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134395', 'Qrafika'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134395'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134427', 'Musiqinünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134427'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134443', 'Operator sənəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134443'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134451', 'Operator sənəti'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134451'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134484', 'Populyar musiqi və caz ifaçnlnnn (vokal)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134484'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134492', 'Rejissorluq (televiziya rejissoru, kino rejissoru, teatr rejissoru, animasiya rejissoru)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134492'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134524', 'Rnngkarlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134524'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '134549', 'Vokal sənəti (akademik vokal)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Mədəniyyət və İncəsənət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '134549'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133114', 'Musiqi müəllimliyi (fleyta, tar, kamança, qanun, balaban, saz, qoboy, klarnet, faqot, valtorna, truba, trombon, znrb'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133114'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133122', 'Dirijorluq (xalq çalnn alntlnri orkestrinin dirijorlunu)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133122'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133139', 'Dirijorluq (xor dirijorlunu)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133139'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133147', 'Dirijorluq (xor dirijorlunu)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133147'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133155', 'Instrumental ifaçnlnq (tar, kamança, qanun, nanara, klarnet)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133155'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133163', 'Musiqinünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133163'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133171', 'Populyar musiqi və caz ifaçnlnnn (vokal, alntlnr üzrə: fortepiano, violin, akkordeon, klarnet, saksofon, fleyta,'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133171'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133188', 'Vokal sənəti (xannndnlik)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133188'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '133196', 'Vokal sənəti (milli vokal)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Milli Konservatoriyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '133196'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135148', 'Dekorativ-tntbiqi snnat (bndii xalça, bndii toxuculuq, bndii metal, keramika və nünn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135148'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135156', 'Dizayn (interyer dizayn, geyim dizaynn, qrafik dizayn, kukla rassamn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135156'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135164', 'Heyknltnranlnq (monumental heyknltnranlnq, dnzgah heyknltnranlnnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135164'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135172', 'Qrafika (dnzgah qrafikasn, kitab qrafikasn, plakat, tntbiqi və illüstrasiyasn, rnssam)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135172'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '135189', 'Rnngkarlnq (monumental rnngkarlnq, dnzgah rnngkarlnnn, teatr dekorasiyasn rnngkarlnnn, kino rassamn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '135189'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136517', 'Xoreoqrafiya sənəti (milli rnqs, modern rnqs, balet pedaqogikasn, baletmeyster sənəti, rnqs müəllimliyi)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Xoreoqrafiya Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136517'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136525', 'Xoreoqrafiya sənəti (milli rnqs, modern rnqs, balet pedaqogikasn, baletmeyster sənəti, rnqs müəllimliyi)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Xoreoqrafiya Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136525'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '136533', 'Instrumental ifaçnlnq (nanara, qarmon)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Bakı Xoreoqrafiya Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '136533'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137149', 'Fiziki tnrbiyn və çannrnnaqndnrki haznrlnq müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137149'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137165', 'Adaptiv bndnn tnrbiynsi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137165'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137173', 'Kütlnvi-sanlamlandnrncn idman'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137173'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137181', 'Kütlnvi-sanlamlandnrncn idman'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137181'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137198', 'Ümumi fiziki haznrlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137198'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137213', 'Ümumi fiziki haznrlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137213'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137229', 'Mnnqçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137229'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137237', 'Mnnqçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137237'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137245', 'Mnnqçilik'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Bədən Tərbiyəsi və İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137245'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137238', 'Mnnqçilik (kanoe və avarçnkmn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137238'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137246', 'Mnnqçilik (basketbol, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137246'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137254', 'Mnnqçilik (cüdo, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137254'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137262', 'Mnnqçilik (gimnastika, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137262'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137279', 'Mnnqçilik (yunan-Roma gülnni, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137279'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137287', 'Mnnqçilik (handbol, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137287'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137295', 'Mnnqçilik (taekvando, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137295'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137319', 'Mnnqçilik (voleybol, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137319'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137327', 'Mnnqçilik (annrlnqqaldnrma, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137327'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137335', 'Mnnqçilik (atncnlnq, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137335'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137343', 'Mnnqçilik (badminton, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137343'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137351', 'Mnnqçilik (boks, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137351'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137368', 'Mnnqçilik (futbol, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137368'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137376', 'Mnnqçilik (snrbnst gülnn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137376'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137384', 'Mnnqçilik (kamandan oxatma, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137384'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137392', 'Mnnqçilik (qnlnncoynatma, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137392'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137416', 'Mnnqçilik (stolüstü tennis, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137416'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137424', 'Mnnqçilik (tennis, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137424'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137432', 'Mnnqçilik (üzgüçülük, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137432'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137449', 'Mnnqçilik (veloped, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan İdman Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137449'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137651', 'Mnnqçilik (snrbnst gülnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137651'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137668', 'Mnnqçilik (snrbnst gülnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137668'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137676', 'Mnnqçilik (yunan-Roma gülnni)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137676'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137684', 'Mnnqçilik (yunan-Roma gülnni)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137684'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137692', 'Mnnqçilik (handbol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137692'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137716', 'Mnnqçilik (handbol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137716'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137724', 'Mnnqçilik (kamandan oxatma)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137724'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137732', 'Mnnqçilik (karate)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137732'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137757', 'Mnnqçilik (karate)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137757'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137765', 'Mnnqçilik (qnn idman növlnri)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137765'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137773', 'Mnnqçilik (nahmat)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137773'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137781', 'Mnnqçilik (sambo)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137781'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137813', 'Mnnqçilik (stolüstü tennis)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137813'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137821', 'Mnnqçilik (taekvando)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137821'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137838', 'Mnnqçilik (taekvando)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137838'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137846', 'Mnnqçilik (tennis)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137846'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137854', 'Mnnqçilik (triatlon)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137854'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137862', 'Mnnqçilik (üzgüçülük)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137862'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137879', 'Mnnqçilik (üzgüçülük)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137879'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137887', 'Mnnqçilik (veloped)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137887'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137895', 'Mnnqçilik (veloped)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137895'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137919', 'Mnnqçilik (voleybol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137919'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137927', 'Mnnqçilik (voleybol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137927'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137635', 'Mnnqçilik (gimnastika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137635'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137643', 'Mnnqçilik (gimnastika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137643'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '137627', 'Mnnqçilik (futbol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Dövlət Rəssamlıq Akademiyası' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '137627'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152425', 'Musiqi müəllimliyi (fortepiano)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152425'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152433', 'Musiqi müəllimliyi (fleyta, qoboy, klarnet, faqot, valtorna, truba, trombon, znrb alntlnri, violin, viola, violonçel,'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152433'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152441', 'Bnstnkarlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152441'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152458', 'Dekorativ-tntbiqi snnat (bndii xalça, kuklalar, keramika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152458'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152466', 'Dizayn (interyer dizayn, qrafik dizayn, geyim dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152466'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152474', 'Instrumental ifaçnlnq (fortepiano)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152474'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152482', 'Instrumental ifaçnlnq (fleyta, qoboy, klarnet, faqot, valtorna, truba, trombon, znrb alntlnri, violin, viola, violonçel,'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152482'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152499', 'Instrumental ifaçnlnq (tar, kamança, saz, nanara, qanun, balaban)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152499'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152514', 'Musiqinünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152514'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152522', 'Vokal sənəti (xannndn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152522'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '152539', 'Vokal sənəti (akademik vokal, milli vokal)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qarabağ Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '152539'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142876', 'Dizayn (interyer dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142876'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142884', 'Fiziki tnrbiyn və çannrnnaqndnrki haznrlnq müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142884'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142892', 'Musiqi müəllimliyi (fortepiano, tar, kamança, qanun, nanara)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142892'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142916', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142916'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142924', 'Aktyor sənəti (teatr və kino aktyorlunu, musiqili teatr aktyorlunu)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142924'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142932', 'Bnstnkarlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142932'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142949', 'Dirijorluq (xor dirijorlunu, nnfas alntlnri orkestrinin dirijorlunu)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142949'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142957', 'Instrumental ifaçnlnq (tar, kamança, qarmon, balaban, qanun, nanara, saz)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142957'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142965', 'Instrumental ifaçnlnq (tar, kamança, qarmon, balaban, qanun, nanara)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142965'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142973', 'Instrumental ifaçnlnq (fortepiano)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142973'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142981', 'Instrumental ifaçnlnq (violin, viola, violonçel, kontrabas)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142981'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '142998', 'Instrumental ifaçnlnq (fleyta, qoboy, valtorna, truba, trombon, klarnet, saksofon, tuba, znrb alntlnri)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '142998'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143118', 'Musiqinünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143118'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143126', 'Musiqinünaslnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143126'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143134', 'Rnngkarlnq'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143134'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143142', 'Vokal sənəti (xannndnlik, milli vokal)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143142'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143159', 'Mnnqçilik (atletika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143159'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143167', 'Mnnqçilik (atletika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143167'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143175', 'Mnnqçilik (snrbnst gülnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143175'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143183', 'Mnnqçilik (snrbnst gülnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143183'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143191', 'Mnnqçilik (voleybol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143191'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143215', 'Mnnqçilik (voleybol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143215'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '143612', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Naxçıvan Müəllimlər İnstitutu' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '143612'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145638', 'Fiziki tnrbiyn və çannrnnaqndnrki haznrlnq müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145638'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145646', 'Musiqi müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145646'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145654', 'Musiqi müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145654'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145662', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145662'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145679', 'Mnnqçilik (futbol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145679'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145687', 'Mnnqçilik (futbol)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145687'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145695', 'Mnnqçilik (atletika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145695'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145719', 'Mnnqçilik (atletika)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145719'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145727', 'Mnnqçilik (boks)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145727'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145735', 'Mnnqçilik (snrbnst gülnn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145735'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '145743', 'Mnnqçilik (yunan-Roma gülnni)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Gəncə Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '145743'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '148732', 'Fiziki tnrbiyn və çannrnnaqndnrki haznrlnq müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Sumqayıt Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '148732'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151656', 'Musiqi müəllimliyi (fortepiano, tar, kamança, qanun, violin, klarnet, balaban, nanara, gitara, vokal, xor dirijorlunu,'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Lənkəran Dövlət Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151656'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157642', 'Dizayn (interyer dizayn, qrafik dizayn və sənaye dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157642'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '157659', 'Dizayn (interyer dizaynn, qrafik dizayn və sənaye dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Qərbi Kaspi Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '157659'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164527', 'Dizayn (interyer dizaynn, qrafik dizayn və geyim dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texnologiya Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164527'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '164535', 'Dizayn (interyer dizayn, qrafik dizayn və geyim dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Azərbaycan Texnologiya Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '164535'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158541', 'Dizayn (qrafik dizayn, interyer dizaynn və landnaft dizaynn)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158541'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158566', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158566'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '158558', 'Dizayn (qrafik dizayn, interyer dizaynn və landnaft dizaynn, tədris ingilis dilində)'
FROM public.universities u, public.education_groups eg
WHERE u.name = '"Odlar Yurdu" Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '158558'
  );

INSERT INTO public.specialties (university_id, education_group_id, code, name)
SELECT u.id, eg.id, '151664', 'Tnsviri incnsənət müəllimliyi'
FROM public.universities u, public.education_groups eg
WHERE u.name = 'Xəzər Universiteti' AND eg.name = 'V'
  AND NOT EXISTS (
    SELECT 1 FROM public.specialties s
    WHERE s.university_id = u.id AND s.code = '151664'
  );

