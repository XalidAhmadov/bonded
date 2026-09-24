# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
npm run dev           # Start Vite frontend + Python backend concurrently
npm run dev:frontend  # Vite dev server only (port 5173)
npm run dev:backend   # Python FastAPI server only (port 8000)
npm run build         # Production build
npm run lint          # ESLint
npm run test          # Run Vitest tests once
npm run test:watch    # Vitest in watch mode
```

To run a single test file: `npx vitest run src/test/example.test.ts`

The Python backend requires: `fastapi`, `uvicorn`, `ultralytics`, `opencv-python`, `easyocr`, `numpy`. Run from the repo root (the `model/` directory must be the working directory when uvicorn resolves `model.Modd`).

## Architecture

**BONDED** is a mobile-first React SPA for university student social networking. Stack: React 18 + TypeScript + Vite + Tailwind CSS + Supabase (database + realtime) + TanStack Query + shadcn/ui.

### Auth model (custom — not Supabase Auth)

Users register directly into the `profiles` table with email + plaintext password. On login/signup, the profile's UUID is stored in `localStorage` under `bonded_user_id`. The `AuthProvider` in `src/hooks/useAuth.tsx` fetches the profile from Supabase on mount using that stored ID. There are no JWTs, no Supabase Auth sessions. RLS is **disabled** on all tables; the anon key has full read/write access.

### Navigation model

The app has two routes: `/` (main app, requires auth) and `/auth`. Within `/`, navigation is NOT react-router–based. `src/pages/Index.tsx` manages a `tab` state (`"messages" | "groups" | "discover" | "profile"`) and renders the active screen inline. Screens (`MessagesScreen`, `GroupsScreen`, `SuggestedScreen`, `ProfileScreen`) are always mounted when their tab is active.

`ChatRoom` and `GroupDetailScreen` are full-screen overlays rendered via `fixed inset-0` on top of the tab screens, controlled by `activeChat` and `activeGroupId` state in `Index.tsx`. The `BottomNav` is hidden while either overlay is open.

### Key files

| Path | Purpose |
|------|---------|
| `src/hooks/useAuth.tsx` | Auth context — `user` is the full profile row, not a Supabase auth user |
| `src/hooks/useRealtimeChat.ts` | All realtime logic for 1:1 chats: messages, read receipts, presence, typing |
| `src/hooks/useGlobalPresence.ts` | App-wide presence on channel `app:presence`; returns `isOnline(userId: string) => boolean` |
| `src/hooks/useNotificationCounts.ts` | Real-time badge counts for friend requests, unread messages, group invitations |
| `src/hooks/useDarkMode.tsx` | Dark mode context; persists to `localStorage` under key `bonded_theme` |
| `src/integrations/supabase/client.ts` | Supabase client (configured from `VITE_SUPABASE_URL` + `VITE_SUPABASE_PUBLISHABLE_KEY`) |
| `src/integrations/supabase/types.ts` | Generated DB type definitions |
| `src/pages/Auth.tsx` | Signup/signin — also handles auto-assigning users to academic groups based on `group_number` |
| `src/components/screens/ChatRoom.tsx` | 1:1 private chat UI, uses `useRealtimeChat` |
| `src/components/screens/GroupDetailScreen.tsx` | Group chat + member management + join request approval |
| `src/components/screens/GroupsScreen.tsx` | Group list, create group, discover/request-to-join public groups |
| `src/components/screens/SuggestedScreen.tsx` | User discovery, send/accept friend requests |
| `model/Modd.py` | Python FastAPI backend — student ID card verification via YOLOv8 + EasyOCR |

### Database schema

Core tables (all in `public`, RLS disabled):

- `profiles` — one row per user: `id`, `first_name`, `last_name`, `email`, `password`, `university`, `major`, `group_number`, `entrance_score`, `avatar_url`, `bio`
- `chats` + `chat_participants` — 1:1 chat rooms and their members
- `messages` — chat messages (`chat_id`, `sender_id`, `body`)
- `message_reads` — read receipts (`message_id`, `user_id`, `chat_id`)
- `friendships` — friend requests: `requester_id`, `addressee_id`, `status` (`pending`/`accepted`/`rejected`)
- `groups` — `name`, `description`, `color` (Tailwind gradient string), `is_public`, `chat_enabled`, `created_by`
- `group_members` — `group_id`, `user_id`, `role` (`owner`/`admin`/`member`)
- `group_join_requests` — `group_id`, `user_id`, `status` (`pending`/`approved`/`rejected`)
- `group_invitations` — `group_id`, `invitee_id`, `status` (`pending`/`accepted`/`rejected`)
- `group_messages` — group chat messages

Group admin is dynamically recalculated: the member with the highest `entrance_score` becomes `owner`.

Migration SQL lives in `supabase/migrations/`. `supabase/complete_schema.sql` is a full reset-and-rebuild script for applying schema from scratch.

### Python backend (model/Modd.py)

FastAPI server on port 8000. Single endpoint: `POST /compare` — accepts a multipart form with an image file plus `ad` (first name), `soyad` (last name), and `uni` (university) fields. It runs YOLOv8 object detection to crop a detected region (student ID card), then EasyOCR to extract text, and returns `{ success, match, ocr_text }`. The `evez()` helper transliterates Azerbaijani characters to ASCII before comparison. The model file `yolov8n.pt` must be present in the `model/` directory.

### Supabase realtime

`useRealtimeChat` subscribes to a channel named `chat:<chatId>` with three event types:
1. `postgres_changes` on `messages` — appends new messages
2. `postgres_changes` on `message_reads` — updates read receipt state
3. `presence` — tracks online status and typing indicator (debounced 2.5 s)

`GroupDetailScreen` uses the same pattern on a `group:<groupId>` channel.

### TypeScript pattern

Supabase queries commonly use `as any` casts (`supabase.from("table") as any`) to bypass TypeScript's "type instantiation is excessively deep" error with the generated types. This is intentional and expected throughout the codebase.

### Design system

Custom glassmorphism design defined in `src/index.css`. Key utility classes: `glass`, `glass-strong`, `gradient-bg`, `bg-gradient-primary`, `shadow-glow`. All colors use HSL CSS variables. The primary color is Apple-style blue (#007AFF). Dark mode variables are defined in `.dark`. Do not introduce new color values outside the CSS variable system.

### Environment variables

Required in `.env`:
```
VITE_SUPABASE_URL=
VITE_SUPABASE_PUBLISHABLE_KEY=
```
