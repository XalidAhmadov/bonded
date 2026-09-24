-- ═══════════════════════════════════════════════════════════════
-- Group Join Requests Table
-- Stores pending/approved/rejected requests from users wanting
-- to join a group. Admins review and approve/reject manually.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS group_join_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL,
  user_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_by UUID,
  reviewed_at TIMESTAMPTZ,
  UNIQUE(group_id, user_id)
);

-- Disable RLS (matching existing tables in this project)
ALTER TABLE group_join_requests DISABLE ROW LEVEL SECURITY;
