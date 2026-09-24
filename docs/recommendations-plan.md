# Feature: Multi-category fields + recommendation system for the Network page

Read CLAUDE.md first, but trust the actual code over it (it may be outdated, e.g. the undocumented Jobs tab).

## Goal
1. Generalize "IT Fields" into a multi-category field system: IT, Business, and more categories later (Design, Science, etc.) without code changes.
2. The Network page must NOT list all users anymore. It shows only recommended students with similar fields, the same or related major, and a similar background. Approach: rule-based scoring + semantic embeddings now, with event logging so we can learn from real behavior later.

Do NOT implement the Projects feature here. That's a separate task.

## Step 0 — Explore and plan first (do not write code yet)
Read: SuggestedScreen.tsx (Network page), ProfileScreen.tsx and the profile edit form (avatar, bio, "IT Fields" picker), useAuth.tsx, the friendship logic, useNotificationCounts.ts, supabase/migrations/, complete_schema.sql, types.ts, and any existing Supabase Edge Functions.
Find out:
- Which column currently stores IT fields, its type, whether it stores labels or slugs, and where the fixed list of IT field options lives in code.
- Where major, university and group_number come from (registration) and whether they can be empty.
- How friend requests are created and accepted.
Then give me a short plan, including the data migration for existing IT fields, and WAIT for my approval.

## 1. Field catalog (new migration + append to complete_schema.sql + update types.ts)
- field_categories: id text pk (slug, e.g. 'it', 'business'), label text, sort_order int, is_active bool default true.
- fields: id text pk (slug), category_id fk field_categories, label text, sort_order int, is_active bool default true.
- profile_fields: user_id fk profiles (on delete cascade), field_id fk fields, created_at, primary key (user_id, field_id).
- Seed categories: IT, Business.
- Seed IT fields from the existing hard-coded IT field list (same labels, generated slugs).
- Seed Business fields (starter list, I may adjust later): Marketing, Digital Marketing, Sales, Finance, Accounting, Entrepreneurship & Startups, Product Management, Project Management, Business Analysis, Human Resources, Supply Chain & Logistics, E-commerce, Consulting.
- Data migration: move every user's existing IT field values into profile_fields (map labels to the new slugs). Report any values that couldn't be mapped. Only drop the old column after the migration is verified, and tell me before dropping it.
- Max 8 fields per user in total, enforced both in the UI and by a DB trigger.
- Keep RLS disabled like all other tables (custom auth).

## 2. Profile edit UI
- Rename the section "IT Fields (editable)" → "Fields (editable)".
- Extend the existing picker (don't build a new one from scratch): category tabs or sections (IT, Business, ...) loaded from field_categories/fields, a search input, and a counter "3 / 8 selected".
- Selected chips keep the current chip style and show a small category label (e.g. "Business · Marketing") — no new colors.
- Everything that reads IT fields today (Network cards, etc.) must read from profile_fields instead.

## 3. Recommendation tables
- Enable the `vector` extension (pgvector).
- profile_embeddings: user_id (pk, fk profiles, on delete cascade), embedding vector(1536), source_hash text, updated_at.
- recommendation_events: id, user_id, candidate_id, event_type check ('impression','profile_opened','request_sent','request_accepted','request_rejected','dismissed'), score numeric, created_at. Indexes on (user_id, candidate_id) and (event_type, created_at).
- recommendation_config: single row holding the scoring weights (section 5), so they can be tuned without redeploying.
- Trigger on friendships that inserts request_sent / request_accepted / request_rejected events automatically, so the friendship code doesn't need to change.
- Grant execute on new functions to anon and authenticated.

## 4. Embeddings
- Supabase Edge Function `embed-profile`: takes a user_id, loads the profile, builds the text:
  "Major: {major}. Fields: IT: {it fields}; Business: {business fields}. Bio: {bio}"
  (group fields by category, skip empty parts, skip the bio if it's shorter than 20 characters). Computes a SHA-256 hash of the text; if it differs from source_hash, calls OpenAI `text-embedding-3-small` and upserts profile_embeddings.
- The OpenAI key lives ONLY in Supabase secrets (OPENAI_API_KEY). Never in a VITE_ variable or any frontend code.
- Call it after a successful profile save (bio or fields changed) and after signup. Fire-and-forget: if it fails, the profile save must still succeed.
- Add a one-off backfill for all existing profiles (run it after the field migration) and tell me how to run it.

## 5. Scoring — Postgres function `get_recommendations(p_user_id uuid, p_limit int default 20, p_offset int default 0)`
Candidate generation:
- Exclude: the user themself; anyone with a friendship row in either direction (pending, accepted, or rejected); anyone the user dismissed in the last 30 days.
- If the user's university is set: same-university candidates only. If it's empty: all universities.

Score per candidate (weights read from recommendation_config):
- shared_fields: Jaccard similarity of field sets across all categories — 0.30
- category_overlap: Jaccard similarity of the users' category sets (partial credit, e.g. both in Business with different fields) — 0.10
- semantic: 1 - cosine distance between embeddings (`<=>`) — 0.25
- same_major: 1 if equal — 0.15
- mutual_friends: min(count, 5) / 5 over accepted friendships — 0.10
- same_group: 1 if same group_number — 0.05
- score_closeness: 1 - least(abs(entrance_score diff) / 50, 1) — 0.05
If a component is unavailable (e.g. either side has no embedding or no fields), drop it and renormalize by the sum of the remaining weights.

Return: candidate id, first/last name, avatar_url, major, fields (with category), final score, and reason data: shared_fields (array of labels), shared_categories (array), mutual_friends_count, same_major (bool). Order by score desc.

## 6. Network page UI (SuggestedScreen)
- Replace the "all users" grid with results from `get_recommendations` (20 at a time, "Show more" loads the next page). Keep the existing card design.
- Up to 3 reason chips per card, in priority order: "3 shared fields", "Both in Business" (only if no shared fields in that category), "2 mutual friends", "Same major". Highlight the shared field tags on the card.
- "Not interested" (X) button on each card → logs a `dismissed` event and removes the card with an animation.
- Log `impression` events for rendered cards (batched, once per card per session) and `profile_opened` when a profile is opened.
- Search bar stays but does not list everyone: results only when the query has at least 3 characters, matching first/last name, max 10 results. Empty query → recommendations.
- If the current user has no fields and no bio, show a banner: "Add your fields and bio to get better recommendations", with a button that opens profile edit. Still show recommendations based on major and group.
- Invalidate the recommendations query after the user saves their profile.

## 7. Conventions (must follow)
- TanStack Query for fetching and mutations; the existing `supabase.from(...) as any` / `supabase.rpc(...) as any` pattern.
- Current user = `user` from useAuth (a profiles row).
- Design: only existing glass utilities and HSL CSS variables, no new hardcoded colors, verify dark mode, mobile-first.
- UI text in English, matching existing strings.
- Do not touch the Python backend, the Jobs feature, or the friendship flow logic (events come from the DB trigger).

## 8. Done criteria
- `npm run lint`, `npm run test`, `npm run build` pass.
- Vitest tests for pure helpers (e.g. building reason chips from the RPC result, the 8-field limit in the picker).
- Final summary: files changed, migration SQL for the Supabase SQL editor (in the correct order), the field-migration report, how to deploy the Edge Function and set OPENAI_API_KEY, how to run the backfill, and a manual test checklist with 4 accounts:
  - A and B share 2 IT fields; C has different Business fields only; D has the same Business category as C but different fields.
  - A must see B ranked above C; C must see D with a "Both in Business" chip; dismissing B removes them from A's list.
- Mention this known limitation (don't fix now): because auth is custom and RLS is off, hiding users on the Network page is UI-level only; the anon key can still read the whole profiles table. Real privacy requires Supabase Auth + RLS.

---

## Addendum (given mid-Section-2, before Section 3)

> "I will add some fields beside IT and Business later — like Art and others — but not now. I will categorize according to their header like IT, Business, Art. Consider this."

Confirmed already satisfied by the Section 1 design: `field_categories`/`fields` are DB rows, not code, so adding a category like "Art" later is purely an `INSERT` — no app code changes needed. `FieldPickerModal`'s category tabs are driven entirely by `field_categories`, so a new category just appears.
