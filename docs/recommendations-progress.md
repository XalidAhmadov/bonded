# Recommendations feature — progress log

Full spec: [`docs/recommendations-plan.md`](./recommendations-plan.md) (all 8 sections, verbatim).

> **Note for the next session:** the "PENDING BEFORE SECTION 3" list below was drafted
> by the user assuming items (a)–(c) were still outstanding. In fact all of (a), (b) and
> (c) were completed and verified in this same session, a few messages before the
> "stop for today" request came in. Only (d) — reporting *actual* migration numbers —
> is genuinely still open, because it requires running SQL against the live Supabase
> project, which this session has no access to. Read the "Fix-round" subsection below
> before assuming any of a–c still need doing.

## Sections completed

### Section 1 — Field catalog ✅
- `supabase/migrations/20260922000000_field_categories.sql` (new): `field_categories`,
  `fields`, `profile_fields` tables; seeds 135 IT fields (from the old hardcoded
  `IT_FIELDS` list) + 13 starter Business fields; backfills `profiles.interests` →
  `profile_fields`; two verification `SELECT`s (unmapped values, users already over 8
  fields); 8-field cap trigger (`trg_profile_fields_limit`, statement-level w/
  transition table); grants + realtime.
- `supabase/complete_schema.sql`: same schema + seed data appended (section 12),
  **without** the backfill/verification queries (not meaningful on a fresh DB).
- `src/integrations/supabase/types.ts`: added `field_categories`, `fields`,
  `profile_fields` table types.
- Corrected an assumption from the original spec: there is **no `major` column** in
  `profiles`. Field of study is `specialty_id → specialties.name` (specialty is
  university-scoped). Proposed using `specialty_id` equality as the Section 5
  "same_major" signal — stated but not yet explicitly confirmed by the user (they
  replied with the categorization note below instead of objecting). **Revisit before
  writing Section 5's scoring function.**

### Section 2 — Profile edit UI ✅
- New `src/hooks/useFieldCatalog.ts` — `useFieldCatalog()`, TanStack Query, fetches
  `field_categories`/`fields`, returns categories + `fieldsByCategory` + `byId` lookup.
- New `src/hooks/useProfileFields.ts` — `useProfileFields(userId)` (read) and
  `useSaveProfileFields()` (write, see Fix-round below for how it saves).
- New `src/components/FieldPicker.tsx` — `FieldPickerModal` (category tabs driven
  entirely by `field_categories` — a future "Art" category needs zero code changes,
  see addendum in the plan doc) and `FieldChips` (selected chips + "n / 8 selected"
  trigger), replacing two duplicate hardcoded picker implementations.
- `src/components/screens/ProfileScreen.tsx` — view/edit now use `profile_fields` via
  the hooks above instead of `profiles.interests`.
- `src/pages/Auth.tsx` (signup) — same picker; writes fields after the profile row is
  created. **Caught a real bug while truncating the old duplicate picker component out
  of this file: the truncation initially deleted the trailing `export default
  AuthPage;`, which would have broken the whole route. Fixed before moving on** — worth
  double-checking this file's tail if anything about routing/imports looks off later.
- `src/components/screens/MessagesScreen.tsx` — bonus fix, not strictly required by
  the spec: the friend-profile modal (opened from the Messages tab's Friends list) also
  switched from `profiles.interests` to live `profile_fields`, since it's a single
  on-demand query (no N+1 risk) and would otherwise have silently gone stale forever.

**Deliberately left untouched in Section 2:**
- `src/components/screens/SuggestedScreen.tsx` (Network page cards + profile modal)
  still reads `profiles.interests` for display. Deferred to Section 6, where the
  `get_recommendations` RPC will return each candidate's fields directly — wiring
  `profile_fields` reads into the soon-to-be-replaced "list all users" code now would
  be throwaway work.
- Company/Jobs screens (`CompanyStudentSearch.tsx`, `JobApplicationsView.tsx`,
  `StudentProfileModal.tsx`, `PostJobModal.tsx`, `src/lib/itFields.ts`) — untouched
  per the spec ("do not touch the Jobs feature"). See the Fix-round below for how they
  keep working without modification.

### Fix-round (between Section 2 and Section 3) ✅ — all done
The user flagged 4 issues after reviewing Section 2. All fixed and verified in this
session:

**(a) Jobs regression fixed — `profiles.interests` is now auto-synced, not stale.**
- `supabase/migrations/20260922020000_jobs_sync_and_atomic_fields.sql` (new):
  - `COMMENT ON COLUMN public.profiles.interests` documenting it as a read-only,
    trigger-synced mirror kept only for Jobs.
  - `sync_profile_interests()` + `trg_sync_profile_interests` (`AFTER INSERT OR UPDATE
    OR DELETE ON profile_fields`, row-level): rewrites `profiles.interests` for the
    affected user from **all** of their `profile_fields` (every category, not just IT —
    confirmed this against `CompanyStudentSearch.tsx`, which matches by exact label
    string via `s.interests.includes(selectedField)`, so the array must contain
    `fields.label` values, not slugs).
  - One-off `UPDATE` in the migration to sync all existing profiles immediately
    (idempotent, safe to re-run).
- Same function/trigger/comment appended to `complete_schema.sql` (section 13),
  without the one-off `UPDATE` (not needed on a fresh empty DB).
- **Not yet independently re-verified against a live DB** (no DB access from this
  session) that `CompanyStudentSearch` finds a student after a Business-field edit —
  logically it must work (interests array now includes Business labels too), but this
  should get an eyeball check once the migration is actually applied.

**(b) Atomic field writes.**
- Added `set_profile_fields(p_user_id uuid, p_field_ids text[])` Postgres function
  (same migration file): de-dupes input, rejects >8 fields, validates every id exists
  and is active in `fields`, then replaces the selection (`DELETE` + `INSERT`) — all
  inside one function invocation. Validation happens *before* any write, so a rejected
  call leaves the user's previous fields untouched.
- `GRANT EXECUTE ... TO anon, authenticated, service_role` (matches the custom-auth
  permission pattern used everywhere else in this schema).
- `src/hooks/useProfileFields.ts` → `useSaveProfileFields()` now calls
  `supabase.rpc("set_profile_fields", ...)` instead of doing client-side
  delete-then-insert. `ProfileScreen.tsx` and `Auth.tsx` needed no further changes —
  they already called this hook, so they picked up the atomic path automatically.
  **No direct client writes to `profile_fields` remain anywhere in `src/`.**
- Added the RPC's shape to `types.ts` (`Functions.set_profile_fields`).

**(c) Tests fixed and added.**
- `node_modules` was corrupted (missing `@jridgewell/sourcemap-codec`'s `.mjs`,
  unrelated to any code change here). Fixed with `rm -rf node_modules && npm install`.
  `npx vitest run` now works.
- New `src/components/FieldPicker.test.tsx` — 6 tests (React Testing Library, mocks
  `useFieldCatalog`) covering the 8-field cap: unselected fields become disabled at the
  cap, an already-selected field stays removable at the cap, selection works normally
  under the cap, a custom `max` prop is respected, and `FieldChips`' "n / max selected"
  counter / empty-state text.
- Full verification run in this session: `npm run lint` clean, `npx tsc --noEmit`
  clean, `npm run build` clean, `npx vitest run` → 7/7 passing (1 pre-existing example
  test + the new 6).

**(d) Section 1 migration report — still genuinely open.**
This session has no credentials/access to the live Supabase project
(`zvrfeicnodziovzbpult`), so the two verification queries at the bottom of
`20260922000000_field_categories.sql` have not actually been run. **Next session (or
the user) needs to run both migrations in the Supabase SQL editor, in this order:**
1. `20260922000000_field_categories.sql`
2. `20260922020000_jobs_sync_and_atomic_fields.sql`

...then report back:
- How many `profile_fields` rows the backfill created (i.e. how many interests values
  migrated).
- The output of the "unmapped value" verification `SELECT` (expected: 0 rows, since
  `interests` only ever came from the `IT_FIELDS` picker — but not yet confirmed
  against real data).
- The output of the "profiles already over 8 fields" verification `SELECT` (informational
  only — the cap trigger only governs future writes, existing over-cap rows are left
  as-is).

### Section 3 — Recommendation tables ✅
- `supabase/migrations/20260922030000_recommendation_tables.sql` (new):
  - `CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;`
  - `profile_embeddings` (`user_id` pk/fk, `extensions.vector(1536)`, `source_hash`,
    `updated_at`). No ANN index (ivfflat/hnsw) added yet — `get_recommendations`
    (Section 5) narrows candidates by university/relationship first, so a sequential
    scan over that already-small set is fine at this app's scale; noted in a comment
    for later if the candidate pool grows.
  - `recommendation_events` (`event_type` CHECK'd to the 6 values from the spec,
    nullable `score`), with the two indexes the spec asked for:
    `(user_id, candidate_id)` and `(event_type, created_at)`.
  - `recommendation_config` — single-row table (boolean singleton PK idiom,
    `id boolean primary key check (id = true)`) holding the 7 Section-5 weights as
    columns, pre-seeded with the spec's default values (0.30/0.10/0.25/0.15/0.10/0.05/0.05).
  - `log_friendship_recommendation_event()` + `trg_log_friendship_recommendation_event`
    (`AFTER INSERT OR UPDATE ON friendships`, row-level): auto-logs `request_sent` on a
    new pending row, `request_accepted`/`request_rejected` on a status transition.
    `SuggestedScreen.tsx`'s friend-request code was not touched, as required.
  - RLS disabled + `GRANT ALL` to `anon, authenticated, service_role` on all three
    tables (matching the rest of the schema). No `GRANT EXECUTE` yet — no RPC function
    exists for these tables until Section 4 (`embed-profile`) and Section 5
    (`get_recommendations`).
- Same DDL appended to `complete_schema.sql` (section 14).
- `types.ts` — added `profile_embeddings`, `recommendation_events`,
  `recommendation_config` table types. `embedding` typed as `string | null` (Supabase
  JS has no native `vector` mapping; will get exercised for real in Section 4).
- Verified: lint, `tsc --noEmit`, `npm run build`, `npx vitest run` (7/7) all still pass.
  This section is pure new DDL/trigger — nothing in `src/` besides the type additions
  was touched, so no new tests were needed for it.

### Section 4 — Embeddings ✅ (provider switched: Gemini free tier, not OpenAI)
The user asked to use Gemini's free model instead of OpenAI. Since Section 4 hadn't
been written yet, this was a clean swap, not a rewrite:
- **`profile_embeddings.embedding` changed from `vector(1536)` to `vector(768)`**
  in both `20260922030000_recommendation_tables.sql` and `complete_schema.sql`
  (edited in place — safe, since neither had been applied to the live DB yet). 768 is
  Gemini's `text-embedding-004` output size. If the migration *has* actually been run
  against Supabase already, this edit alone won't reach it — would need an
  `ALTER COLUMN ... TYPE vector(768)` follow-up migration plus a full re-embed instead.
- New `supabase/functions/embed-profile/index.ts`: builds the spec's
  `"Major: {specialty}. Fields: IT: {..}; Business: {..}. Bio: {bio}"` text (specialty
  name stands in for "major", same substitution as elsewhere; groups `profile_fields`
  by category; skips bio under 20 chars), SHA-256 hashes it, skips the Gemini call
  entirely if the hash matches `source_hash` (unchanged) or if there's no embeddable
  content at all, otherwise calls Gemini's `text-embedding-004:embedContent` REST
  endpoint (`taskType: "SEMANTIC_SIMILARITY"`, symmetric — fits matching two profiles
  against each other, unlike the asymmetric `RETRIEVAL_*` task types) and upserts.
  `GEMINI_API_KEY` is read from `Deno.env` only.
  - Deliberately does **not** copy `seed-demo-users`' `supabase.auth.getUser()` caller
    check — that check assumes real Supabase Auth sessions, which this app doesn't
    have (custom auth). Gatekeeping is the same as every other table here: the
    Supabase platform's own JWT check on the anon key, nothing extra.
  - Doubles as the one-off backfill: `POST { "backfill": true }` loops every
    `account_type = 'student'` profile with a 200ms pace between calls (free-tier rate
    limit headroom), instead of a separate function or script.
- New `src/lib/embedProfile.ts` — `triggerProfileEmbed(userId)`, fire-and-forget
  (`.catch()` swallows errors, logs to console, never throws to the caller). Called
  from `ProfileScreen.saveProfile` (after the fields mutation succeeds) and from
  `Auth.tsx`'s student signup (after the profile row + fields are created).
- Verified: lint, `tsc --noEmit`, `npm run build`, `npx vitest run` (7/7) all pass.
  No new tests added for the edge function itself — it's Deno code outside Vitest's
  reach; would need Deno's own test runner or an integration test against a live
  function, neither set up in this repo.

**Still needed from the user before this actually works:**
1. Get a free Gemini API key from Google AI Studio.
2. Set it as a Supabase secret: `supabase secrets set GEMINI_API_KEY=<key>` (or via the
   Supabase dashboard → Edge Functions → Secrets).
3. Deploy the function: `supabase functions deploy embed-profile`.
4. After migrations 1–3 are applied, run the backfill once: `curl -X POST
   'https://<project-ref>.functions.supabase.co/embed-profile' -H 'Authorization:
   Bearer <anon-or-service-key>' -H 'Content-Type: application/json' -d
   '{"backfill": true}'`.

## Migrations to run (in order, not yet applied as far as this session knows)
1. `supabase/migrations/20260922000000_field_categories.sql`
2. `supabase/migrations/20260922020000_jobs_sync_and_atomic_fields.sql`
3. `supabase/migrations/20260922030000_recommendation_tables.sql`

(`supabase/complete_schema.sql` has the fresh-install equivalent of all three, for a
from-scratch DB reset instead of incremental migrations.)

## Open decisions / things to confirm before Section 5 (scoring)
- **same_major scoring signal**: proposed `specialty_id` equality (university-scoped)
  since no `major` column exists. Not yet explicitly confirmed.
- Section 1's migration numbers (see (d) above) — confirm no unmapped values before
  trusting the backfill.
- The Jobs-feature consequence of syncing *all* categories (not just IT) into
  `profiles.interests`: `CompanyStudentSearch`'s dropdown filter only offers IT labels,
  but the interests array (and the tag chips it renders) will now also contain
  Business labels. This is intentional per the user's explicit "including Business
  fields" instruction, but is a visible behavior change in a screen the plan says not
  to touch code-wise.
- `recommendation_config`'s weight values are stored but nothing reads them yet —
  `get_recommendations` (Section 5) needs to actually select from this table rather
  than hardcoding the weights.

## Next up
Section 5 (`get_recommendations` Postgres scoring function) — not started. This is
where the `same_major`/`specialty_id` open question actually gets used, so worth a
definite answer before writing it. Waiting for the user before beginning.
