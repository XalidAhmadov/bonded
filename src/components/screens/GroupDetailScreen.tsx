import { useEffect, useState, useCallback, useRef } from "react";
import {
  ArrowLeft, Send, Users, Crown, ShieldCheck,
  X, Loader2, MessageCircle, Bell, Check,
  Settings, Palette, Type, FileText, Power, PowerOff, Paperclip, CheckCheck,
  UserMinus,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";

interface GroupInfo {
  id: string;
  name: string;
  description: string | null;
  color: string | null;
  created_by: string;
  is_public: boolean;
  chat_enabled: boolean;
  bio: string | null;
}

interface MemberInfo {
  user_id: string;
  role: string;
  first_name: string;
  last_name: string;
  avatar_url: string | null;
}

interface GroupMessage {
  id: string;
  group_id: string;
  sender_id: string;
  body: string;
  created_at: string;
  sender_name?: string;
}

interface JoinRequest {
  id: string;
  group_id: string;
  user_id: string;
  status: string;
  created_at: string;
  profile: {
    first_name: string;
    last_name: string;
    avatar_url: string | null;
    university: string;
  };
}

interface Props {
  groupId: string;
  onBack: () => void;
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

const formatTime = (iso: string) => {
  try { return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }); }
  catch { return ""; }
};

export const GroupDetailScreen = ({ groupId, onBack }: Props) => {
  const { user } = useAuth();
  const [group, setGroup] = useState<GroupInfo | null>(null);
  const [members, setMembers] = useState<MemberInfo[]>([]);
  const [messages, setMessages] = useState<GroupMessage[]>([]);
  const [loading, setLoading] = useState(true);
  const [text, setText] = useState("");
  const scrollRef = useRef<HTMLDivElement>(null);

  // Panels
  const [showMembers, setShowMembers] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [showJoinRequests, setShowJoinRequests] = useState(false);

  // Join requests state
  const [joinRequests, setJoinRequests] = useState<JoinRequest[]>([]);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);

  // Settings edit state
  const [editName, setEditName] = useState("");
  const [editColor, setEditColor] = useState("");
  const [editBio, setEditBio] = useState("");
  const [savingSettings, setSavingSettings] = useState(false);

  // Kick member state
  const [confirmKickUserId, setConfirmKickUserId] = useState<string | null>(null);
  const [kickingUserId, setKickingUserId] = useState<string | null>(null);

  const myRole = members.find((m) => m.user_id === user?.id)?.role ?? null;
  const isOwner = myRole === "owner";
  const isAdminOrOwner = myRole === "owner" || myRole === "admin";

  const loadGroup = useCallback(async () => {
    if (!user?.id) return;
    const [{ data: g }, { data: mems }, { data: msgs }] = await Promise.all([
      (supabase.from("groups") as any).select("*").eq("id", groupId).single(),
      (supabase.from("group_members") as any).select("user_id, role").eq("group_id", groupId),
      (supabase.from("group_messages") as any).select("*").eq("group_id", groupId).order("created_at", { ascending: true }),
    ]);
    setGroup(g);

    // Fetch profiles for members
    const userIds = (mems ?? []).map((m: any) => m.user_id);
    let profileMap = new Map<string, any>();
    if (userIds.length > 0) {
      const { data: profs } = await (supabase.from("profiles") as any)
        .select("id,first_name,last_name,avatar_url").in("id", userIds);
      profileMap = new Map((profs ?? []).map((p: any) => [p.id, p]));
    }

    const memberList: MemberInfo[] = (mems ?? []).map((m: any) => {
      const prof = profileMap.get(m.user_id);
      return {
        user_id: m.user_id,
        role: m.role,
        first_name: prof?.first_name ?? "Unknown",
        last_name: prof?.last_name ?? "",
        avatar_url: prof?.avatar_url ?? null,
      };
    });
    // Sort: owner first, then admins, then members
    memberList.sort((a, b) => {
      const order: Record<string, number> = { owner: 0, admin: 1, member: 2 };
      return (order[a.role] ?? 3) - (order[b.role] ?? 3);
    });
    setMembers(memberList);

    // Enrich messages with sender names
    const enriched: GroupMessage[] = (msgs ?? []).map((m: any) => ({
      ...m,
      sender_name: profileMap.get(m.sender_id)?.first_name ?? "Unknown",
    }));
    setMessages(enriched);

    // Initialize settings
    if (g) {
      setEditName(g.name);
      setEditColor(g.color ?? GROUP_COLORS[0]);
      setEditBio(g.bio ?? "");
    }

    setLoading(false);
  }, [groupId, user]);

  useEffect(() => { loadGroup(); }, [loadGroup]);

  // Load join requests for this group (admin/owner only)
  const loadJoinRequests = useCallback(async () => {
    const { data: reqs } = await (supabase.from("group_join_requests") as any)
      .select("*")
      .eq("group_id", groupId)
      .eq("status", "pending")
      .order("created_at", { ascending: false });
    if (!reqs || reqs.length === 0) { setJoinRequests([]); return; }
    const uids = reqs.map((r: any) => r.user_id);
    const { data: profs } = await (supabase.from("profiles") as any)
      .select("id,first_name,last_name,avatar_url,universities(name)")
      .in("id", uids);
    const pm = new Map((profs ?? []).map((p: any) => [p.id, p]));
    setJoinRequests(reqs.map((r: any) => {
      const prof = pm.get(r.user_id) as any;
      return {
        ...r,
        profile: prof
          ? {
              first_name: prof.first_name,
              last_name: prof.last_name,
              avatar_url: prof.avatar_url,
              university: prof.universities?.name ?? "",
            }
          : { first_name: "Unknown", last_name: "", avatar_url: null, university: "" },
      };
    }));
  }, [groupId]);

  useEffect(() => { loadJoinRequests(); }, [loadJoinRequests]);

  // Realtime for group messages + join requests
  useEffect(() => {
    const ch = supabase.channel(`group-detail:${groupId}`)
      .on("postgres_changes", { event: "INSERT", schema: "public", table: "group_messages", filter: `group_id=eq.${groupId}` }, () => loadGroup())
      .on("postgres_changes", { event: "*", schema: "public", table: "group_members", filter: `group_id=eq.${groupId}` }, () => loadGroup())
      .on("postgres_changes", { event: "*", schema: "public", table: "groups", filter: `id=eq.${groupId}` }, () => loadGroup())
      .on("postgres_changes", { event: "*", schema: "public", table: "group_join_requests", filter: `group_id=eq.${groupId}` }, () => loadJoinRequests())
      .subscribe();
    return () => { supabase.removeChannel(ch); };
  }, [groupId, loadGroup, loadJoinRequests]);

  // Autoscroll
  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages.length]);

  const sendMessage = async () => {
    const body = text.trim();
    if (!body || !user?.id) return;
    setText("");
    await (supabase.from("group_messages") as any).insert({ group_id: groupId, sender_id: user.id, body });
  };

  const toggleChat = async () => {
    if (!group) return;
    const newValue = !group.chat_enabled;
    const { error } = await (supabase.from("groups") as any)
      .update({ chat_enabled: newValue })
      .eq("id", groupId);
    if (error) {
      toast.error("Failed to toggle chat");
      return;
    }
    setGroup(prev => prev ? { ...prev, chat_enabled: newValue } : prev);
    toast.success(newValue ? "Chat enabled 💬" : "Chat disabled 🔇");
  };

  const saveSettings = async () => {
    if (!group) return;
    setSavingSettings(true);
    try {
      const { error } = await (supabase.from("groups") as any)
        .update({
          name: editName.trim() || group.name,
          color: editColor,
          bio: editBio.trim() || null,
        })
        .eq("id", groupId);
      if (error) throw error;
      setGroup(prev => prev ? {
        ...prev,
        name: editName.trim() || prev.name,
        color: editColor,
        bio: editBio.trim() || null,
      } : prev);
      setShowSettings(false);
      toast.success("Group settings saved! ✨");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to save");
    } finally {
      setSavingSettings(false);
    }
  };

  const approveRequest = async (req: JoinRequest) => {
    setActionLoadingId(req.id);
    try {
      // Add user as member (upsert to handle duplicates gracefully)
      const { error: memErr } = await (supabase.from("group_members") as any)
        .upsert(
          { group_id: groupId, user_id: req.user_id, role: "member" },
          { onConflict: "group_id,user_id", ignoreDuplicates: true }
        );
      if (memErr) throw memErr;
      // Mark request as approved
      await (supabase.from("group_join_requests") as any)
        .update({ status: "approved", reviewed_by: user?.id, reviewed_at: new Date().toISOString() })
        .eq("id", req.id);
      // Immediately remove from local state for instant UI feedback
      setJoinRequests(prev => prev.filter(r => r.id !== req.id));
      toast.success(`${req.profile.first_name} approved! ✅`);
      await loadGroup();
    } catch (e: any) {
      toast.error(e.message ?? "Failed to approve");
    } finally { setActionLoadingId(null); }
  };

  const rejectRequest = async (req: JoinRequest) => {
    setActionLoadingId(req.id);
    try {
      await (supabase.from("group_join_requests") as any)
        .update({ status: "rejected", reviewed_by: user?.id, reviewed_at: new Date().toISOString() })
        .eq("id", req.id);
      // Immediately remove from local state
      setJoinRequests(prev => prev.filter(r => r.id !== req.id));
      toast.success("Request rejected");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to reject");
    } finally { setActionLoadingId(null); }
  };

  const roleIcon = (role: string) => {
    if (role === "owner") return <Crown className="h-3.5 w-3.5 text-amber-500" />;
    if (role === "admin") return <ShieldCheck className="h-3.5 w-3.5 text-primary" />;
    return null;
  };

  /**
   * Remove/kick a member from the group.
   * Only admin or owner can do this. The owner cannot be kicked.
   */
  const removeMember = async (targetUserId: string) => {
    if (!user?.id) return;
    setKickingUserId(targetUserId);
    try {
      const { error } = await (supabase.from("group_members") as any)
        .delete()
        .eq("group_id", groupId)
        .eq("user_id", targetUserId);
      if (error) throw error;

      // Update local state immediately
      setMembers(prev => prev.filter(m => m.user_id !== targetUserId));
      setConfirmKickUserId(null);

      const targetMember = members.find(m => m.user_id === targetUserId);
      toast.success(`${targetMember?.first_name ?? "Member"} has been removed from the group`);
    } catch (e: any) {
      toast.error(e.message ?? "Failed to remove member");
    } finally {
      setKickingUserId(null);
    }
  };

  if (loading || !group) {
    return (
      <div className="fixed inset-0 z-40 bg-background grid place-items-center">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center p-0 sm:p-4 md:p-6 bg-gradient-to-br from-blue-50/80 via-white/60 to-sky-50/80 animate-fade-in">
      {/* Centered group chat container */}
      <div className="chat-container">
        {/* Header */}
        <header className="chat-header">
          <button onClick={onBack} className="h-10 w-10 grid place-items-center rounded-full hover:bg-primary-soft active:scale-95 shrink-0 transition-all" aria-label="Back">
            <ArrowLeft className="h-5 w-5 text-foreground" strokeWidth={2.4} />
          </button>
          <div className={`h-10 w-10 rounded-xl bg-gradient-to-br ${group.color ?? "from-amber-400 to-orange-500"} grid place-items-center shadow-sm shrink-0`}>
            <Users className="h-4 w-4 text-white" />
          </div>
          {/* Clickable group name → shows members */}
          <button onClick={() => setShowMembers(true)} className="flex-1 min-w-0 text-left hover:opacity-80 transition-opacity">
            <p className="font-semibold text-foreground leading-tight truncate">{group.name}</p>
            <p className="text-[11px] text-muted-foreground">
              {members.length} members · tap for info
            </p>
          </button>
          {isAdminOrOwner && (
            <>
              <button onClick={() => setShowJoinRequests(true)} className="relative h-9 w-9 grid place-items-center rounded-full hover:bg-primary-soft text-primary transition-colors" title="Join requests">
                <Bell className="h-4 w-4" />
                {joinRequests.length > 0 && (
                  <span className="absolute -top-0.5 -right-0.5 h-[18px] min-w-[18px] px-1 rounded-full bg-destructive text-destructive-foreground text-[9px] font-bold grid place-items-center shadow-sm">
                    {joinRequests.length}
                  </span>
                )}
              </button>
              <button onClick={() => setShowSettings(true)} className="h-9 w-9 grid place-items-center rounded-full hover:bg-primary-soft text-primary transition-colors" title="Group settings">
                <Settings className="h-4 w-4" />
              </button>
            </>
          )}
        </header>

        {/* Chat View */}
        {group.chat_enabled ? (
          <>
            {/* Messages */}
            <div ref={scrollRef} className="chat-messages">
              {messages.length === 0 ? (
                <div className="text-center text-muted-foreground text-sm py-8">No messages yet. Say something! 💬</div>
              ) : (
                <div className="space-y-1">
                  {/* Today badge */}
                  <div className="flex justify-center py-3">
                    <span className="chat-date-badge">Today</span>
                  </div>

                  {messages.map((m, i) => {
                    const sent = m.sender_id === user?.id;
                    const prev = messages[i - 1];
                    const groupedWithPrev = prev && prev.sender_id === m.sender_id;
                    const showSenderName = !sent && !groupedWithPrev;

                    return (
                      <div
                        key={m.id}
                        className={cn(
                          "flex flex-col",
                          sent ? "items-end" : "items-start",
                          groupedWithPrev ? "mt-[3px]" : "mt-3"
                        )}
                      >
                        {/* Sender name — shown above the bubble for incoming, non-grouped messages */}
                        {showSenderName && (
                          <p className="msg-sender-name">{m.sender_name}</p>
                        )}
                        <div className={cn("msg-bubble", sent ? "msg-bubble-sent" : "msg-bubble-received")}>
                          <p className="whitespace-pre-wrap break-words">{m.body}</p>
                          <div className="msg-time">
                            <span>{formatTime(m.created_at)}</span>
                            {sent && (
                              <CheckCheck className="h-3.5 w-3.5 text-primary" strokeWidth={2.5} />
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* Composer */}
            <div className="chat-composer">
              <div className="flex items-center gap-2">
                <div className="flex-1 flex items-center gap-2 bg-white dark:bg-secondary border border-border/60 rounded-full px-4 py-2.5 shadow-sm">
                  <input value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => e.key === "Enter" && sendMessage()} placeholder="Type a message..." className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground" />
                  <button className="text-muted-foreground hover:text-primary transition-colors" aria-label="Attach">
                    <Paperclip className="h-[18px] w-[18px]" strokeWidth={2} />
                  </button>
                </div>
                <button onClick={sendMessage} disabled={!text.trim()} className="h-10 w-10 grid place-items-center rounded-full bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 disabled:opacity-40 transition-all shrink-0" aria-label="Send">
                  <Send className="h-[18px] w-[18px]" strokeWidth={2.4} />
                </button>
              </div>
            </div>
          </>
        ) : (
          /* Chat Disabled */
          <div className="flex-1 grid place-items-center bg-secondary/30">
            <div className="text-center px-8">
              <div className="mx-auto h-16 w-16 rounded-full bg-secondary grid place-items-center mb-4">
                <MessageCircle className="h-7 w-7 text-muted-foreground" />
              </div>
              <h3 className="text-xl font-bold text-foreground">Chat is Disabled</h3>
              <p className="text-sm text-muted-foreground mt-2 max-w-md mx-auto">
                The group admin has turned off chat for this group. 
                {isAdminOrOwner && " You can turn it back on in Settings."}
              </p>
              {isAdminOrOwner && (
                <button
                  onClick={toggleChat}
                  className="mt-5 inline-flex items-center gap-2 px-6 py-3 rounded-full bg-gradient-primary text-primary-foreground font-semibold text-sm shadow-glow active:scale-95"
                >
                  <Power className="h-4 w-4" />
                  Enable Chat
                </button>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Members Panel (slide-in from right) */}
      {showMembers && (
        <div className="fixed inset-0 z-50 bg-black/40 animate-fade-in" onClick={() => { setShowMembers(false); setConfirmKickUserId(null); }}>
          <div
            className="absolute right-0 top-0 h-full w-full max-w-md bg-background shadow-2xl overflow-y-auto animate-slide-left"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="safe-top px-5 pt-4 pb-3 flex items-center justify-between border-b border-border/50">
              <h2 className="text-xl font-bold text-foreground">Members ({members.length})</h2>
              <button onClick={() => { setShowMembers(false); setConfirmKickUserId(null); }} className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary">
                <X className="h-4 w-4" />
              </button>
            </div>

            {group.bio && (
              <div className="px-5 py-3 border-b border-border/30">
                <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">Group Bio</p>
                <p className="text-sm text-foreground leading-relaxed">{group.bio}</p>
              </div>
            )}

            <div className="px-5 py-3 space-y-1.5">
              {members.map((m) => {
                const canKick = isAdminOrOwner && m.role !== "owner" && m.user_id !== user?.id;
                const isConfirming = confirmKickUserId === m.user_id;
                const isKicking = kickingUserId === m.user_id;

                return (
                  <div key={m.user_id} className="glass rounded-xl p-3">
                    <div className="flex items-center gap-3">
                      <img src={m.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${m.user_id}`} className="h-10 w-10 rounded-full bg-secondary" alt="" />
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-1.5">
                          <p className="font-semibold text-sm truncate">{m.first_name} {m.last_name}</p>
                          {roleIcon(m.role)}
                          {m.user_id === user?.id && <span className="text-[10px] text-muted-foreground">(you)</span>}
                        </div>
                        <p className="text-[11px] text-muted-foreground capitalize">{m.role}</p>
                      </div>
                      {canKick && !isConfirming && (
                        <button
                          onClick={() => setConfirmKickUserId(m.user_id)}
                          className="h-8 w-8 grid place-items-center rounded-full hover:bg-red-50 dark:hover:bg-red-950/50 text-muted-foreground hover:text-red-600 dark:hover:text-red-400 transition-colors"
                          title="Remove member"
                        >
                          <UserMinus className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                    {/* Kick confirmation */}
                    {isConfirming && canKick && (
                      <div className="mt-2 flex gap-2 animate-slide-up">
                        <button
                          onClick={() => setConfirmKickUserId(null)}
                          className="flex-1 flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-secondary text-foreground active:scale-95 transition-all"
                        >
                          <X className="h-3.5 w-3.5" />
                          Cancel
                        </button>
                        <button
                          onClick={() => removeMember(m.user_id)}
                          disabled={isKicking}
                          className="flex-1 flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-red-50 dark:bg-red-950/50 text-red-600 dark:text-red-400 hover:bg-red-100 transition-colors active:scale-95 disabled:opacity-60"
                        >
                          {isKicking ? (
                            <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          ) : (
                            <UserMinus className="h-3.5 w-3.5" />
                          )}
                          Remove
                        </button>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Join Requests Panel (admin/owner only) */}
      {showJoinRequests && isAdminOrOwner && (
        <div className="fixed inset-0 z-50 bg-black/40 animate-fade-in" onClick={() => setShowJoinRequests(false)}>
          <div
            className="absolute right-0 top-0 h-full w-full max-w-md bg-background shadow-2xl overflow-y-auto animate-slide-left"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="safe-top px-5 pt-4 pb-3 flex items-center justify-between border-b border-border/50">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-full bg-gradient-primary grid place-items-center shadow-glow">
                  <Bell className="h-3.5 w-3.5 text-primary-foreground" />
                </div>
                <h2 className="text-xl font-bold text-foreground">Join Requests</h2>
              </div>
              <button onClick={() => setShowJoinRequests(false)} className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary">
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="px-5 py-3 space-y-2">
              {joinRequests.length === 0 ? (
                <div className="text-center py-8">
                  <Users className="h-8 w-8 mx-auto mb-2 text-muted-foreground/40" />
                  <p className="text-sm text-muted-foreground font-semibold">No pending requests</p>
                  <p className="text-xs text-muted-foreground mt-0.5">When someone requests to join, it'll show here.</p>
                </div>
              ) : (
                joinRequests.map((req) => (
                  <div key={req.id} className="glass rounded-2xl p-3 animate-slide-up">
                    <div className="flex items-center gap-3">
                      <img src={req.profile.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${req.user_id}`} className="h-11 w-11 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0" alt="" />
                      <div className="flex-1 min-w-0">
                        <h4 className="font-semibold text-sm text-foreground truncate">{req.profile.first_name} {req.profile.last_name}</h4>
                        <p className="text-[11px] text-muted-foreground truncate">{req.profile.university}</p>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-2 mt-2.5">
                      <button
                        onClick={() => approveRequest(req)}
                        disabled={actionLoadingId === req.id}
                        className="flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all disabled:opacity-60"
                      >
                        {actionLoadingId === req.id ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : <Check className="h-3.5 w-3.5" />}
                        Approve
                      </button>
                      <button
                        onClick={() => rejectRequest(req)}
                        disabled={actionLoadingId === req.id}
                        className="flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-secondary text-foreground hover:bg-red-50 hover:text-red-600 transition-colors active:scale-95 disabled:opacity-60"
                      >
                        <X className="h-3.5 w-3.5" />
                        Reject
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* Settings Modal (admin/owner only) */}
      {showSettings && isAdminOrOwner && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => setShowSettings(false)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 space-y-4 max-h-[85vh] overflow-y-auto animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Settings className="h-5 w-5 text-primary" />
                <h2 className="text-xl font-bold text-foreground">Group Settings</h2>
              </div>
              <button onClick={() => setShowSettings(false)} className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary">
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Chat Toggle */}
            <div className="glass rounded-2xl p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {group.chat_enabled ? (
                    <div className="h-10 w-10 rounded-xl bg-green-50 grid place-items-center">
                      <Power className="h-5 w-5 text-green-600" />
                    </div>
                  ) : (
                    <div className="h-10 w-10 rounded-xl bg-red-50 grid place-items-center">
                      <PowerOff className="h-5 w-5 text-red-500" />
                    </div>
                  )}
                  <div>
                    <p className="font-semibold text-sm text-foreground">Group Chat</p>
                    <p className="text-[11px] text-muted-foreground">
                      {group.chat_enabled ? "Chat is active" : "Chat is disabled"}
                    </p>
                  </div>
                </div>
                <button
                  onClick={toggleChat}
                  className={cn(
                    "px-4 py-2 rounded-full text-xs font-semibold transition-all active:scale-95",
                    group.chat_enabled
                      ? "bg-red-50 text-red-600 hover:bg-red-100"
                      : "bg-gradient-primary text-primary-foreground shadow-glow"
                  )}
                >
                  {group.chat_enabled ? "Turn Off" : "Turn On"}
                </button>
              </div>
            </div>

            {/* Group Name */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-1 block flex items-center gap-1">
                <Type className="h-3 w-3" /> Group Name
              </label>
              <input
                value={editName}
                onChange={(e) => setEditName(e.target.value)}
                placeholder="Group name"
                className="w-full bg-secondary rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
            </div>

            {/* Group Bio */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-1 block flex items-center gap-1">
                <FileText className="h-3 w-3" /> Group Bio
              </label>
              <textarea
                value={editBio}
                onChange={(e) => setEditBio(e.target.value)}
                placeholder="What's this group about?"
                rows={3}
                maxLength={300}
                className="w-full bg-secondary rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
              />
              <p className="text-[10px] text-muted-foreground text-right mt-0.5">{editBio.length}/300</p>
            </div>

            {/* Color Theme */}
            <div>
              <label className="text-xs font-semibold text-muted-foreground mb-1 block flex items-center gap-1">
                <Palette className="h-3 w-3" /> Color Theme
              </label>
              <div className="flex flex-wrap gap-2">
                {GROUP_COLORS.map((c) => (
                  <button
                    key={c}
                    onClick={() => setEditColor(c)}
                    className={cn(
                      "h-8 w-8 rounded-full bg-gradient-to-br transition-all",
                      c,
                      editColor === c ? "ring-2 ring-primary ring-offset-2 scale-110" : "opacity-70 hover:opacity-100"
                    )}
                  />
                ))}
              </div>
            </div>

            {/* Save Button */}
            <button
              onClick={saveSettings}
              disabled={savingSettings || !editName.trim()}
              className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-95 disabled:opacity-60 transition-all"
            >
              {savingSettings ? <Loader2 className="h-4 w-4 animate-spin" /> : <Settings className="h-4 w-4" />}
              Save Settings
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
