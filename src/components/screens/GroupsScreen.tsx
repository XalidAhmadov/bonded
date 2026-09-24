import { useEffect, useState, useCallback } from "react";
import { v4 as uuidv4 } from "uuid";
import {
  Users, Globe, ChevronRight, Loader2, Crown, ShieldCheck,
  Plus, X, Palette, Clock, LogIn, Send, Bell, Check,
} from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { cn } from "@/lib/utils";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";

interface GroupData {
  id: string;
  name: string;
  description: string | null;
  color: string | null;
  created_by: string;
  is_public: boolean;
  chat_enabled: boolean;
  bio: string | null;
  created_at: string;
  member_count: number;
  my_role: string | null;
}

type SubTab = "my" | "discover";

interface Props {
  onOpenGroup: (groupId: string) => void;
}

const GROUP_COLORS = [
  "from-blue-400 to-blue-600",
  "from-sky-400 to-blue-500",
  "from-cyan-400 to-blue-500",
  "from-blue-500 to-indigo-500",
  "from-indigo-400 to-purple-500",
  "from-violet-400 to-purple-600",
  "from-emerald-400 to-teal-500",
  "from-amber-400 to-orange-500",
];

export const GroupsScreen = ({ onOpenGroup }: Props) => {
  const { user } = useAuth();
  const [subTab, setSubTab] = useState<SubTab>("my");
  const [myGroups, setMyGroups] = useState<GroupData[]>([]);
  const [discoverGroups, setDiscoverGroups] = useState<GroupData[]>([]);
  const [loading, setLoading] = useState(true);

  // Join request state — tracks which groups the user has pending requests for
  const [pendingRequestGroupIds, setPendingRequestGroupIds] = useState<Set<string>>(new Set());
  const [sendingRequest, setSendingRequest] = useState<string | null>(null);
  const [withdrawingRequest, setWithdrawingRequest] = useState<string | null>(null);

  // Create group modal state
  const [showCreateGroup, setShowCreateGroup] = useState(false);
  const [newGroupName, setNewGroupName] = useState("");
  const [newGroupDescription, setNewGroupDescription] = useState("");
  const [newGroupColor, setNewGroupColor] = useState(GROUP_COLORS[0]);

  // Group invitations state
  const [showInvitations, setShowInvitations] = useState(false);
  const [invitations, setInvitations] = useState<any[]>([]);
  const [invitationsLoading, setInvitationsLoading] = useState(false);
  const [respondingInvite, setRespondingInvite] = useState<string | null>(null);
  const [newGroupPublic, setNewGroupPublic] = useState(true);
  const [creatingGroup, setCreatingGroup] = useState(false);

  const loadGroups = useCallback(async () => {
    if (!user?.id) return;
    setLoading(true);

    const [{ data: allGroups }, { data: allMembers }, { data: myRequests }] = await Promise.all([
      (supabase.from("groups") as any).select("*"),
      (supabase.from("group_members") as any).select("group_id, user_id, role"),
      (supabase.from("group_join_requests") as any)
        .select("group_id, status")
        .eq("user_id", user.id)
        .eq("status", "pending"),
    ]);

    const memberCountMap: Record<string, number> = {};
    const myRoleMap: Record<string, string> = {};

    (allMembers ?? []).forEach((m: any) => {
      memberCountMap[m.group_id] = (memberCountMap[m.group_id] ?? 0) + 1;
      if (m.user_id === user.id) myRoleMap[m.group_id] = m.role;
    });

    const groups: GroupData[] = (allGroups ?? []).map((g: any) => ({
      ...g,
      member_count: memberCountMap[g.id] ?? 0,
      my_role: myRoleMap[g.id] ?? null,
    }));

    setMyGroups(groups.filter((g) => g.my_role !== null));
    setDiscoverGroups(groups.filter((g) => g.my_role === null && g.is_public));

    // Track pending join requests
    const pendingIds = new Set<string>(
      (myRequests ?? []).map((r: any) => r.group_id)
    );
    setPendingRequestGroupIds(pendingIds);

    setLoading(false);
  }, [user]);

  useEffect(() => { loadGroups(); }, [loadGroups]);

  useEffect(() => {
    if (!user?.id) return;
    const ch = supabase
      .channel(`groups:${user.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "groups" }, () => loadGroups())
      .on("postgres_changes", { event: "*", schema: "public", table: "group_members" }, () => loadGroups())
      .on("postgres_changes", { event: "*", schema: "public", table: "group_join_requests" }, () => loadGroups())
      .subscribe();
    return () => { supabase.removeChannel(ch); };
  }, [user, loadGroups]);

  /**
   * Send a join request to a group.
   * Creates a row in group_join_requests with status "pending".
   */
  const sendJoinRequest = async (groupId: string) => {
    if (!user?.id) return;
    setSendingRequest(groupId);
    try {
      const { error } = await (supabase.from("group_join_requests") as any)
        .insert({
          group_id: groupId,
          user_id: user.id,
          status: "pending",
        });

      if (error) {
        // Handle duplicate request gracefully
        if (error.code === "23505") {
          toast.info("You already sent a join request for this group.");
          setPendingRequestGroupIds(prev => new Set(prev).add(groupId));
        } else {
          throw error;
        }
      } else {
        setPendingRequestGroupIds(prev => new Set(prev).add(groupId));
        toast.success("Join request sent! ✉️");
      }
    } catch (e: any) {
      console.error("sendJoinRequest error:", e);
      toast.error(e.message ?? "Failed to send request");
    } finally {
      setSendingRequest(null);
    }
  };

  /**
   * Withdraw/cancel a pending join request.
   * Deletes the row from group_join_requests.
   */
  const withdrawJoinRequest = async (groupId: string) => {
    if (!user?.id) return;
    setWithdrawingRequest(groupId);
    try {
      const { error } = await (supabase.from("group_join_requests") as any)
        .delete()
        .eq("group_id", groupId)
        .eq("user_id", user.id)
        .eq("status", "pending");

      if (error) throw error;

      setPendingRequestGroupIds(prev => {
        const next = new Set(prev);
        next.delete(groupId);
        return next;
      });
      toast.success("Join request withdrawn");
    } catch (e: any) {
      console.error("withdrawJoinRequest error:", e);
      toast.error(e.message ?? "Failed to withdraw request");
    } finally {
      setWithdrawingRequest(null);
    }
  };

  const createGroup = async () => {
    if (!user?.id || !newGroupName.trim()) return;
    setCreatingGroup(true);
    try {
      const groupId = uuidv4();

      // Step 1: Create the group
      const { data: newGroup, error: groupErr } = await (supabase.from("groups") as any)
        .insert({
          id: groupId,
          name: newGroupName.trim(),
          description: newGroupDescription.trim() || null,
          color: newGroupColor,
          created_by: user.id,
          is_public: newGroupPublic,
          chat_enabled: true,
          bio: null,
        })
        .select("id")
        .single();

      if (groupErr) {
        console.error("Group creation failed:", groupErr);
        throw new Error("Failed to create group: " + groupErr.message);
      }

      if (!newGroup?.id) {
        throw new Error("Group was created but no ID was returned.");
      }

      // Step 2: Add the creator as the owner
      const { error: memberErr } = await (supabase.from("group_members") as any)
        .insert({
          group_id: newGroup.id,
          user_id: user.id,
          role: "owner",
        });

      if (memberErr) {
        console.error("Member insert failed:", memberErr);
        // Cleanup: delete orphaned group
        await (supabase.from("groups") as any).delete().eq("id", newGroup.id);
        throw new Error("Failed to add you as owner: " + memberErr.message);
      }

      // Reset form
      setNewGroupName("");
      setNewGroupDescription("");
      setNewGroupColor(GROUP_COLORS[0]);
      setNewGroupPublic(true);
      setShowCreateGroup(false);

      toast.success("Group created! 🎉");
      await loadGroups();

      // Open the newly created group
      onOpenGroup(newGroup.id);
    } catch (e: any) {
      console.error("createGroup error:", e);
      toast.error(e.message ?? "Failed to create group");
    } finally {
      setCreatingGroup(false);
    }
  };

  /** Card for groups the user is already a member of — clicking opens the group */
  const MyGroupCard = ({ g }: { g: GroupData }) => (
    <button
      onClick={() => onOpenGroup(g.id)}
      className="w-full glass rounded-2xl p-4 flex items-center gap-3 hover:shadow-glow transition-all text-left"
    >
      <div className={`h-12 w-12 rounded-2xl bg-gradient-to-br ${g.color ?? "from-blue-400 to-blue-600"} grid place-items-center shadow-glow shrink-0`}>
        <Users className="h-5 w-5 text-white" strokeWidth={2.4} />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-1.5">
          <p className="font-semibold text-[15px] text-foreground truncate">{g.name}</p>
          {g.my_role === "owner" && <Crown className="h-3.5 w-3.5 text-amber-500 shrink-0" />}
          {g.my_role === "admin" && <ShieldCheck className="h-3.5 w-3.5 text-primary shrink-0" />}
        </div>
        {g.description && <p className="text-xs text-muted-foreground truncate">{g.description}</p>}
        <div className="flex items-center gap-2 mt-0.5">
          <p className="text-[11px] text-primary font-semibold">
            {g.member_count} {g.member_count === 1 ? "member" : "members"}
          </p>
          {!g.chat_enabled && (
            <span className="text-[10px] font-semibold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-full">
              Chat Off
            </span>
          )}
        </div>
      </div>
      <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
    </button>
  );

  /** Card for discoverable groups — shows "Request to Join", "Pending" with withdraw, etc. */
  const DiscoverGroupCard = ({ g }: { g: GroupData }) => {
    const isPending = pendingRequestGroupIds.has(g.id);
    const isSending = sendingRequest === g.id;
    const isWithdrawing = withdrawingRequest === g.id;

    return (
      <div className="w-full glass rounded-2xl p-4 text-left">
        <div className="flex items-center gap-3">
          <div className={`h-12 w-12 rounded-2xl bg-gradient-to-br ${g.color ?? "from-blue-400 to-blue-600"} grid place-items-center shadow-glow shrink-0`}>
            <Users className="h-5 w-5 text-white" strokeWidth={2.4} />
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-semibold text-[15px] text-foreground truncate">{g.name}</p>
            {g.description && <p className="text-xs text-muted-foreground truncate">{g.description}</p>}
            <p className="text-[11px] text-primary font-semibold mt-0.5">
              {g.member_count} {g.member_count === 1 ? "member" : "members"}
            </p>
          </div>
        </div>

        <div className="mt-3">
          {isPending ? (
            <div className="flex gap-2">
              <div className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl font-semibold text-sm bg-amber-50 text-amber-600 dark:bg-amber-950/50 dark:text-amber-400">
                <Clock className="h-4 w-4" />
                Pending
              </div>
              <button
                onClick={() => withdrawJoinRequest(g.id)}
                disabled={isWithdrawing}
                className="flex items-center justify-center gap-1.5 px-4 py-2.5 rounded-xl font-semibold text-sm bg-secondary text-foreground hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95 disabled:opacity-60"
              >
                {isWithdrawing ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <X className="h-4 w-4" />
                )}
                Withdraw
              </button>
            </div>
          ) : (
            <button
              onClick={() => sendJoinRequest(g.id)}
              disabled={isSending}
              className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 disabled:opacity-60 transition-all"
            >
              {isSending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Send className="h-4 w-4" />
              )}
              Request to Join
            </button>
          )}
        </div>
      </div>
    );
  };

  // Load group invitations for the current user
  const openInvitations = async () => {
    if (!user?.id) return;
    setShowInvitations(true);
    setInvitationsLoading(true);
    try {
      const { data } = await (supabase.from("group_invitations") as any)
        .select("*")
        .eq("invitee_id", user.id)
        .eq("status", "pending");

      if (data && data.length > 0) {
        // Fetch group names and inviter names
        const groupIds = [...new Set(data.map((inv: any) => inv.group_id))];
        const inviterIds = [...new Set(data.map((inv: any) => inv.inviter_id))];
        const [{ data: groups }, { data: inviters }] = await Promise.all([
          (supabase.from("groups") as any).select("id,name,color").in("id", groupIds),
          (supabase.from("profiles") as any).select("id,first_name,last_name,avatar_url").in("id", inviterIds),
        ]);
        const groupMap = new Map((groups ?? []).map((g: any) => [g.id, g]));
        const inviterMap = new Map((inviters ?? []).map((p: any) => [p.id, p]));
        const enriched = data.map((inv: any) => ({
          ...inv,
          group: groupMap.get(inv.group_id) ?? { name: "Unknown Group", color: "from-blue-400 to-blue-600" },
          inviter: inviterMap.get(inv.inviter_id) ?? { first_name: "Unknown", last_name: "" },
        }));
        setInvitations(enriched);
      } else {
        setInvitations([]);
      }
    } catch (e) {
      console.error("Failed to load invitations", e);
    } finally {
      setInvitationsLoading(false);
    }
  };

  // Load invitations on mount
  useEffect(() => {
    if (user?.id) {
      (async () => {
        const { data } = await (supabase.from("group_invitations") as any)
          .select("id")
          .eq("invitee_id", user.id)
          .eq("status", "pending");
        setInvitations((data ?? []).map((d: any) => ({ ...d, group: {}, inviter: {} })));
      })();
    }
  }, [user?.id]);

  const respondToInvitation = async (invId: string, accept: boolean) => {
    if (!user?.id) return;
    setRespondingInvite(invId);
    try {
      if (accept) {
        // Find the invitation to get group_id
        const inv = invitations.find((i: any) => i.id === invId);
        if (inv) {
          // Add user as member
          await (supabase.from("group_members") as any).insert({
            group_id: inv.group_id,
            user_id: user.id,
            role: "member",
          });
        }
      }
      // Update invitation status
      await (supabase.from("group_invitations") as any)
        .update({ status: accept ? "accepted" : "rejected" })
        .eq("id", invId);

      toast.success(accept ? "Invitation accepted! 🎉" : "Invitation declined");
      setInvitations((prev) => prev.filter((i: any) => i.id !== invId));
      if (accept) await loadGroups();
    } catch (e: any) {
      toast.error(e.message ?? "Failed to respond");
    } finally {
      setRespondingInvite(null);
    }
  };

  return (
    <div className="animate-fade-in pb-2">
      <AppHeader
        subtitle="Communities"
        title="Groups"
        right={
          <div className="flex items-center gap-2">
            <button
              onClick={openInvitations}
              className="relative h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label="Group invitations"
              title="Group invitations"
            >
              <Bell className="h-[18px] w-[18px] text-primary" strokeWidth={2.2} />
              {invitations.length > 0 && !showInvitations && (
                <span className="absolute -top-1 -right-1 h-5 min-w-5 px-1 rounded-full bg-gradient-primary text-primary-foreground text-[10px] font-bold grid place-items-center shadow-glow animate-scale-in">
                  {invitations.length}
                </span>
              )}
            </button>
            <button
              onClick={() => setShowCreateGroup(true)}
              className="h-10 w-10 grid place-items-center rounded-full bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-transform"
              aria-label="Create new group"
              title="Create new group"
            >
              <Plus className="h-[18px] w-[18px]" strokeWidth={2.4} />
            </button>
          </div>
        }
      />

      {/* Sub-tabs */}
      <div className="px-5 mb-4">
        <div className="glass rounded-2xl p-1 flex gap-1">
          <button onClick={() => setSubTab("my")} className={cn("flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl text-sm font-semibold transition-all", subTab === "my" ? "bg-gradient-primary text-primary-foreground shadow-glow" : "text-muted-foreground hover:text-primary")}>
            <Users className="h-3.5 w-3.5" /> My Groups
          </button>
          <button onClick={() => setSubTab("discover")} className={cn("flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl text-sm font-semibold transition-all", subTab === "discover" ? "bg-gradient-primary text-primary-foreground shadow-glow" : "text-muted-foreground hover:text-primary")}>
            <Globe className="h-3.5 w-3.5" /> Discover
          </button>
        </div>
      </div>

      {loading ? (
        <div className="px-5 py-12 text-center text-muted-foreground text-sm">
          <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2" /> Loading groups…
        </div>
      ) : subTab === "my" ? (
        <section className="px-5 mb-6">
          {myGroups.length === 0 ? (
            <div className="glass-strong rounded-3xl p-8 text-center">
              <div className="mx-auto h-12 w-12 rounded-full bg-gradient-primary grid place-items-center shadow-glow mb-3">
                <Users className="h-5 w-5 text-primary-foreground" />
              </div>
              <h3 className="font-bold text-foreground">No groups yet</h3>
              <p className="text-sm text-muted-foreground mt-1">Create a group or discover public groups to join.</p>
              <button
                onClick={() => setShowCreateGroup(true)}
                className="mt-4 inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-gradient-primary text-primary-foreground font-semibold text-sm shadow-glow active:scale-95"
              >
                <Plus className="h-4 w-4" />
                Create Group
              </button>
            </div>
          ) : (
            <ul className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 xl:grid-cols-3 gap-3">
              {myGroups.map((g, i) => (
                <li key={g.id} style={{ animationDelay: `${i * 50}ms` }} className="animate-slide-up">
                  <MyGroupCard g={g} />
                </li>
              ))}
            </ul>
          )}
        </section>
      ) : (
        <section className="px-5 mb-6">
          {discoverGroups.length === 0 ? (
            <div className="glass-strong rounded-3xl p-8 text-center">
              <div className="mx-auto h-12 w-12 rounded-full bg-secondary grid place-items-center mb-3">
                <Globe className="h-5 w-5 text-muted-foreground" />
              </div>
              <h3 className="font-bold text-foreground">No groups to discover</h3>
              <p className="text-sm text-muted-foreground mt-1">All public groups are already yours!</p>
            </div>
          ) : (
            <ul className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 xl:grid-cols-3 gap-3">
              {discoverGroups.map((g, i) => (
                <li key={g.id} style={{ animationDelay: `${i * 50}ms` }} className="animate-slide-up">
                  <DiscoverGroupCard g={g} />
                </li>
              ))}
            </ul>
          )}
        </section>
      )}

      {/* Create Group Modal */}
      {showCreateGroup && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => setShowCreateGroup(false)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 space-y-5 max-h-[85vh] overflow-y-auto animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-gradient-primary grid place-items-center shadow-glow">
                  <Users className="h-4 w-4 text-primary-foreground" />
                </div>
                <h2 className="text-xl font-bold text-foreground">Create Group</h2>
              </div>
              <button
                onClick={() => setShowCreateGroup(false)}
                className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Group Name */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-1.5 block">
                Group Name <span className="text-destructive">*</span>
              </label>
              <input
                value={newGroupName}
                onChange={(e) => setNewGroupName(e.target.value)}
                placeholder="Enter group name..."
                maxLength={60}
                className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 transition-shadow"
              />
            </div>

            {/* Group Description */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-1.5 block">
                Description <span className="text-muted-foreground/60">(optional)</span>
              </label>
              <textarea
                value={newGroupDescription}
                onChange={(e) => setNewGroupDescription(e.target.value)}
                placeholder="What's this group about?"
                rows={3}
                maxLength={200}
                className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none transition-shadow"
              />
              <p className="text-[10px] text-muted-foreground text-right mt-0.5">{newGroupDescription.length}/200</p>
            </div>

            {/* Color Theme */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-2 block flex items-center gap-1">
                <Palette className="h-3 w-3" /> Color Theme
              </label>
              <div className="flex flex-wrap gap-2.5">
                {GROUP_COLORS.map((c) => (
                  <button
                    key={c}
                    onClick={() => setNewGroupColor(c)}
                    className={cn(
                      "h-9 w-9 rounded-full bg-gradient-to-br transition-all",
                      c,
                      newGroupColor === c
                        ? "ring-2 ring-primary ring-offset-2 scale-110"
                        : "opacity-60 hover:opacity-100 hover:scale-105"
                    )}
                  />
                ))}
              </div>
            </div>

            {/* Visibility */}
            <div className="glass rounded-2xl p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-primary-soft grid place-items-center">
                    <Globe className="h-5 w-5 text-primary" />
                  </div>
                  <div>
                    <p className="font-semibold text-sm text-foreground">Public Group</p>
                    <p className="text-[11px] text-muted-foreground">
                      {newGroupPublic ? "Anyone can discover and request to join" : "Only invited users can join"}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setNewGroupPublic(!newGroupPublic)}
                  className={cn(
                    "w-12 h-7 rounded-full transition-all relative",
                    newGroupPublic ? "bg-primary" : "bg-secondary"
                  )}
                >
                  <span
                    className={cn(
                      "absolute top-0.5 h-6 w-6 rounded-full bg-white shadow-sm transition-all",
                      newGroupPublic ? "left-[calc(100%-1.625rem)]" : "left-0.5"
                    )}
                  />
                </button>
              </div>
            </div>

            {/* Preview */}
            <div className="glass rounded-2xl p-4 flex items-center gap-3">
              <div className={`h-12 w-12 rounded-2xl bg-gradient-to-br ${newGroupColor} grid place-items-center shadow-glow shrink-0`}>
                <Users className="h-5 w-5 text-white" strokeWidth={2.4} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-[15px] text-foreground truncate">
                  {newGroupName.trim() || "Group Preview"}
                </p>
                {newGroupDescription.trim() && (
                  <p className="text-xs text-muted-foreground truncate">{newGroupDescription.trim()}</p>
                )}
                <p className="text-[11px] text-primary font-semibold mt-0.5">1 member</p>
              </div>
            </div>

            {/* Create Button */}
            <button
              onClick={createGroup}
              disabled={creatingGroup || !newGroupName.trim()}
              className="w-full flex items-center justify-center gap-2 py-3.5 rounded-xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-95 disabled:opacity-60 transition-all"
            >
              {creatingGroup ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Plus className="h-4 w-4" />
              )}
              Create Group
            </button>
          </div>
        </div>
      )}

      {/* Group Invitations Modal */}
      {showInvitations && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => setShowInvitations(false)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 space-y-4 max-h-[80vh] flex flex-col animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-full bg-gradient-primary grid place-items-center shadow-glow">
                  <Bell className="h-3.5 w-3.5 text-primary-foreground" />
                </div>
                <h2 className="text-xl font-bold text-foreground">Group Invitations</h2>
                {invitations.length > 0 && (
                  <span className="text-xs font-semibold text-primary bg-primary-soft px-2 py-0.5 rounded-full">
                    {invitations.length}
                  </span>
                )}
              </div>
              <button
                onClick={() => setShowInvitations(false)}
                className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto space-y-2">
              {invitationsLoading ? (
                <div className="py-8 text-center">
                  <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2 text-primary" />
                  <p className="text-sm text-muted-foreground">Loading invitations…</p>
                </div>
              ) : invitations.length === 0 ? (
                <div className="text-center text-muted-foreground text-sm py-8">
                  <Bell className="h-8 w-8 mx-auto mb-2 opacity-40" />
                  <p className="font-semibold text-foreground">No pending invitations</p>
                  <p className="text-xs mt-1">When someone invites you to a group, it will appear here.</p>
                </div>
              ) : (
                invitations.map((inv: any) => (
                  <div key={inv.id} className="bg-secondary/50 rounded-xl p-4 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className={`h-10 w-10 rounded-xl bg-gradient-to-br ${inv.group?.color ?? 'from-blue-400 to-blue-600'} grid place-items-center shadow-soft shrink-0`}>
                        <Users className="h-4 w-4 text-white" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-sm text-foreground truncate">{inv.group?.name ?? 'Group'}</p>
                        <p className="text-xs text-muted-foreground truncate">
                          Invited by {inv.inviter?.first_name ?? ''} {inv.inviter?.last_name ?? ''}
                        </p>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <button
                        onClick={() => respondToInvitation(inv.id, false)}
                        disabled={respondingInvite === inv.id}
                        className="flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-secondary text-foreground hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95 disabled:opacity-60"
                      >
                        <X className="h-3.5 w-3.5" />
                        Decline
                      </button>
                      <button
                        onClick={() => respondToInvitation(inv.id, true)}
                        disabled={respondingInvite === inv.id}
                        className="flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 disabled:opacity-60 transition-all"
                      >
                        {respondingInvite === inv.id ? (
                          <Loader2 className="h-3.5 w-3.5 animate-spin" />
                        ) : (
                          <Check className="h-3.5 w-3.5" />
                        )}
                        Accept
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
