import { useEffect, useState, useCallback, useMemo } from "react";
import { Sparkles, UserPlus, Check, X, Clock, Users, Loader2, Search, Bell, UserMinus, MessageCircle, Lock } from "lucide-react";
import { v4 as uuidv4 } from "uuid";
import { AppHeader } from "@/components/AppHeader";
import { cn } from "@/lib/utils";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";
import type { ChatListItem } from "./MessagesScreen";

interface UserProfile {
  id: string;
  first_name: string;
  last_name: string;
  university_id: string | null;
  universities: { name: string } | null;
  specialty_id: string | null;
  specialties: { name: string } | null;
  year: string | null;
  avatar_url: string | null;
  bio: string | null;
  interests: string[] | null;
  profession: string | null;
  entrance_score: number | null;
  message_privacy: "all" | "only_friends" | null;
}

interface FriendRequest {
  id: string;
  requester_id: string;
  addressee_id: string;
  status: string;
  created_at: string;
  profile: UserProfile;
}

interface Props {
  onRequestCountChange?: (count: number) => void;
  onOpenChat?: (chat: ChatListItem) => void;
}

export const SuggestedScreen = ({
  onRequestCountChange,
  onOpenChat,
}: Props) => {
  const { user } = useAuth();
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [incomingRequests, setIncomingRequests] = useState<FriendRequest[]>([]);
  const [sentIds, setSentIds] = useState<Set<string>>(new Set());
  const [friendIds, setFriendIds] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  // User Search
  const [searchQuery, setSearchQuery] = useState("");

  // Request popup
  const [showRequestPopup, setShowRequestPopup] = useState(false);

  // User profile modal
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);

  // Unfriend confirmation
  const [confirmUnfriend, setConfirmUnfriend] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!user?.id) return;
    setLoading(true);

    const tbl = supabase.from("friendships") as any;

    // Get all friendships involving the current user
    const [{ data: sentRows }, { data: receivedRows }] = await Promise.all([
      tbl.select("*").eq("requester_id", user.id),
      tbl.select("*").eq("addressee_id", user.id),
    ]);

    const sent = new Set<string>();
    const friends = new Set<string>();
    const pendingIncoming: string[] = [];

    (sentRows ?? []).forEach((r: any) => {
      if (r.status === "accepted") friends.add(r.addressee_id);
      else if (r.status === "pending") sent.add(r.addressee_id);
    });
    (receivedRows ?? []).forEach((r: any) => {
      if (r.status === "accepted") friends.add(r.requester_id);
      else if (r.status === "pending") pendingIncoming.push(r.requester_id);
    });

    setSentIds(sent);
    setFriendIds(friends);

    // Load all users (exclude self)
    const { data: allUsers } = await (supabase.from("profiles") as any)
      .select("id,first_name,last_name,university_id,universities(name),specialty_id,specialties(name),year,avatar_url,bio,interests,profession,entrance_score,message_privacy")
      .neq("id", user.id)
      .eq("account_type", "student");
    setUsers(allUsers ?? []);

    // Build incoming requests with profile data
    if (pendingIncoming.length > 0) {
      const pendingReceivedRows = (receivedRows ?? []).filter(
        (r: any) => r.status === "pending"
      );
      const profileMap = new Map(
        (allUsers ?? []).map((p: UserProfile) => [p.id, p])
      );
      const requests: FriendRequest[] = pendingReceivedRows.map((r: any) => ({
        ...r,
        profile: profileMap.get(r.requester_id) ?? {
          id: r.requester_id,
          first_name: "Unknown",
          last_name: "",
          university_id: null,
          universities: null,
          specialty_id: null,
          specialties: null,
          year: null,
          avatar_url: null,
          bio: null,
          interests: null,
          profession: null,
          entrance_score: null,
        },
      }));
      setIncomingRequests(requests);
      onRequestCountChange?.(requests.length);
    } else {
      setIncomingRequests([]);
      onRequestCountChange?.(0);
    }

    setLoading(false);
  }, [user, onRequestCountChange]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Realtime: refresh on friendship changes
  useEffect(() => {
    if (!user?.id) return;
    const ch = supabase
      .channel(`friendships:${user.id}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "friendships" },
        () => loadData()
      )
      .subscribe();
    return () => {
      supabase.removeChannel(ch);
    };
  }, [user, loadData]);

  const sendFriendRequest = async (targetId: string) => {
    if (!user?.id) return;
    setActionLoading(targetId);
    try {
      const { error } = await (supabase.from("friendships") as any).insert({
        requester_id: user.id,
        addressee_id: targetId,
        status: "pending",
      });
      if (error) throw error;
      setSentIds((prev) => new Set(prev).add(targetId));
      toast.success("Friend request sent!");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to send request");
    } finally {
      setActionLoading(null);
    }
  };

  const withdrawRequest = async (targetId: string) => {
    if (!user?.id) return;
    setActionLoading(targetId);
    try {
      const { error } = await (supabase.from("friendships") as any)
        .delete()
        .eq("requester_id", user.id)
        .eq("addressee_id", targetId)
        .eq("status", "pending");
      if (error) throw error;
      setSentIds((prev) => {
        const next = new Set(prev);
        next.delete(targetId);
        return next;
      });
      toast.success("Friend request withdrawn");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to withdraw");
    } finally {
      setActionLoading(null);
    }
  };

  const unfriend = async (targetId: string) => {
    if (!user?.id) return;
    setActionLoading(targetId);
    try {
      const tbl = supabase.from("friendships") as any;
      await Promise.all([
        tbl.delete().eq("requester_id", user.id).eq("addressee_id", targetId),
        tbl.delete().eq("requester_id", targetId).eq("addressee_id", user.id),
      ]);
      setFriendIds((prev) => {
        const next = new Set(prev);
        next.delete(targetId);
        return next;
      });
      setConfirmUnfriend(null);
      setSelectedUser(null);
      toast.success("Removed from friends");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to unfriend");
    } finally {
      setActionLoading(null);
    }
  };

  const respondToRequest = async (
    requestId: string,
    status: "accepted" | "rejected"
  ) => {
    setActionLoading(requestId);
    try {
      const { error } = await (supabase.from("friendships") as any)
        .update({ status, updated_at: new Date().toISOString() })
        .eq("id", requestId);
      if (error) throw error;
      toast.success(
        status === "accepted" ? "Friend request accepted! 🎉" : "Request declined"
      );
      await loadData();
    } catch (e: any) {
      toast.error(e.message ?? "Failed to respond");
    } finally {
      setActionLoading(null);
    }
  };

  const handleOpenChatWithUser = async (targetUser: UserProfile) => {
    if (!user?.id || !onOpenChat) return;
    
    // Check recipient privacy
    const privacy = targetUser.message_privacy ?? "all";
    const isFriend = friendIds.has(targetUser.id);
    if (privacy === "only_friends" && !isFriend) {
      toast.error("This user only accepts messages from friends.");
      return;
    }

    try {
      // Check if chat already exists
      const { data: myParts } = await (supabase.from("chat_participants") as any)
        .select("chat_id")
        .eq("user_id", user.id);
      
      const myChatIds = (myParts ?? []).map((p: any) => p.chat_id);
      if (myChatIds.length > 0) {
        const { data: commonPart } = await (supabase.from("chat_participants") as any)
          .select("chat_id")
          .in("chat_id", myChatIds)
          .eq("user_id", targetUser.id)
          .maybeSingle();

        if (commonPart) {
          const chatItem: ChatListItem = {
            id: commonPart.chat_id,
            participant: {
              id: targetUser.id,
              first_name: targetUser.first_name,
              last_name: targetUser.last_name,
              avatar_url: targetUser.avatar_url,
              university: targetUser.universities?.name ?? "",
            },
            last_message: null,
            last_message_at: null,
            unread_count: 0,
          };
          setSelectedUser(null);
          onOpenChat(chatItem);
          return;
        }
      }

      // No existing chat — create new
      const newChatId = uuidv4();
      const { data: newChat, error: chatErr } = await (supabase.from("chats") as any)
        .insert({ id: newChatId, last_message: null, last_message_at: null })
        .select("id")
        .single();
      if (chatErr || !newChat?.id) throw chatErr ?? new Error("Chat creation failed — no ID returned.");

      const { error: partErr } = await (supabase.from("chat_participants") as any)
        .insert([
          { chat_id: newChat.id, user_id: user.id },
          { chat_id: newChat.id, user_id: targetUser.id },
        ]);
      if (partErr) {
        // Cleanup orphaned chat
        await (supabase.from("chats") as any).delete().eq("id", newChat.id);
        throw partErr;
      }

      const chatItem: ChatListItem = {
        id: newChat.id,
        participant: {
          id: targetUser.id,
          first_name: targetUser.first_name,
          last_name: targetUser.last_name,
          avatar_url: targetUser.avatar_url,
          university: targetUser.universities?.name ?? "",
        },
        last_message: null,
        last_message_at: null,
        unread_count: 0,
      };
      setSelectedUser(null);
      onOpenChat(chatItem);
    } catch (e: any) {
      console.error("handleOpenChatWithUser failed", e);
      toast.error(e.message ?? "Could not open conversation");
    }
  };

  const avatar = (u: UserProfile) =>
    u.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${u.id}`;

  // Filter out friends and self from discover list
  const discoverUsers = users.filter(
    (u) => !friendIds.has(u.id) && !sentIds.has(u.id)
  );

  // Also filter out users who have sent us a pending request (they show in Requests popup)
  const pendingRequesterIds = new Set(
    incomingRequests.map((r) => r.requester_id)
  );
  const filteredDiscoverUsers = discoverUsers.filter(
    (u) => !pendingRequesterIds.has(u.id)
  );

  // Search filter: match first_name or last_name
  const searchedUsers = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    if (!q) return filteredDiscoverUsers;
    return filteredDiscoverUsers.filter((u) => {
      const fullName = `${u.first_name} ${u.last_name}`.toLowerCase();
      return fullName.includes(q);
    });
  }, [searchQuery, filteredDiscoverUsers]);

  // Also search in sent-pending list
  const searchedPending = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    const pendingUsers = users.filter((u) => sentIds.has(u.id));
    if (!q) return pendingUsers;
    return pendingUsers.filter((u) => {
      const fullName = `${u.first_name} ${u.last_name}`.toLowerCase();
      return fullName.includes(q);
    });
  }, [searchQuery, users, sentIds]);



  return (
    <div className="animate-fade-in">
      <AppHeader
        subtitle="BONDED"
        title="Network"
        right={
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowRequestPopup(true)}
              className="relative h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label="Friend requests"
              title="Friend requests"
            >
              <Bell className="h-[18px] w-[18px] text-primary" strokeWidth={2.2} />
              {incomingRequests.length > 0 && (
                <span className="absolute -top-1 -right-1 h-5 min-w-5 px-1 rounded-full bg-gradient-primary text-primary-foreground text-[10px] font-bold grid place-items-center shadow-glow animate-scale-in">
                  {incomingRequests.length}
                </span>
              )}
            </button>
          </div>
        }
      />

      {/* Discover Content — main view, no tabs */}
      {loading ? (
        <div className="px-5 py-12 text-center text-muted-foreground text-sm">
          <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2" />
          Loading…
        </div>
      ) : (
        <div className="px-5 space-y-4">
          {/* Search Bar */}
          <div className="glass rounded-2xl flex items-center gap-2 px-4 py-3">
            <Search className="h-4 w-4 text-muted-foreground shrink-0" />
            <input
              type="search"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search students..."
              className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="h-5 w-5 grid place-items-center rounded-full hover:bg-secondary shrink-0"
              >
                <X className="h-3 w-3 text-muted-foreground" />
              </button>
            )}
          </div>

          {searchQuery.trim() ? (
            // Search results mode
            <div>
              <p className="text-xs text-muted-foreground mb-3">
                {searchedPending.length + searchedUsers.length} result{searchedPending.length + searchedUsers.length !== 1 ? "s" : ""} for "{searchQuery.trim()}"
              </p>

              {/* Pending results */}
              {searchedPending.length > 0 && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-3">
                  {searchedPending.map((p, i) => (
                    <article
                      key={p.id}
                      style={{ animationDelay: `${i * 60}ms` }}
                      className="glass rounded-2xl p-4 animate-slide-up"
                    >
                      <div className="flex items-center gap-3">
                        <img
                          src={avatar(p)}
                          alt={p.first_name}
                          className="h-12 w-12 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0"
                        />
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-[15px] text-foreground truncate">
                            {p.first_name} {p.last_name}
                          </h3>
                          <p className="text-[11px] text-muted-foreground truncate">
                            {p.universities?.name ?? ""}
                          </p>
                        </div>
                        <button
                          onClick={() => withdrawRequest(p.id)}
                          disabled={actionLoading === p.id}
                          className="flex items-center gap-1 text-xs font-semibold text-amber-600 bg-amber-50 dark:bg-amber-950/50 px-3 py-1.5 rounded-full hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95 disabled:opacity-60 shrink-0"
                        >
                          {actionLoading === p.id ? (
                            <Loader2 className="h-3 w-3 animate-spin" />
                          ) : (
                            <Clock className="h-3 w-3" />
                          )}
                          Pending
                        </button>
                      </div>
                    </article>
                  ))}
                </div>
              )}

              {/* Discoverable results */}
              {searchedUsers.length > 0 && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 xl:grid-cols-3 gap-3.5 mb-3">
                  {searchedUsers.map((p, i) => (
                    <article
                      key={p.id}
                      style={{ animationDelay: `${(i + searchedPending.length) * 60}ms` }}
                      className="glass rounded-3xl p-5 animate-slide-up cursor-pointer hover:shadow-glow transition-shadow flex flex-col justify-between"
                      onClick={() => setSelectedUser(p)}
                    >
                      <div className="flex items-start gap-4">
                        <img
                          src={avatar(p)}
                          alt={p.first_name}
                          className="h-16 w-16 rounded-2xl bg-secondary ring-2 ring-white shadow-soft shrink-0"
                        />
                        <div className="flex-1 min-w-0">
                          <h3 className="font-bold text-lg text-foreground leading-tight">
                            {p.first_name} {p.last_name}
                          </h3>
                          <p className="text-xs text-muted-foreground mt-0.5">
                            {p.universities?.name ?? ""}
                          </p>
                          {(p.profession || p.specialties?.name || p.year) && (
                            <p className="text-xs text-primary font-semibold mt-0.5">
                              {[p.profession, p.specialties?.name, p.year].filter(Boolean).join(" · ")}
                            </p>
                          )}
                        </div>
                      </div>
                      <div className="mt-4" onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => sendFriendRequest(p.id)}
                          disabled={actionLoading === p.id}
                          className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all disabled:opacity-60"
                        >
                          {actionLoading === p.id ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                          ) : (
                            <UserPlus className="h-4 w-4" />
                          )}
                          Send Friend Request
                        </button>
                      </div>
                    </article>
                  ))}
                </div>
              )}

              {searchedUsers.length === 0 && searchedPending.length === 0 && (
                <div className="glass-strong rounded-3xl p-8 text-center">
                  <Search className="h-8 w-8 mx-auto mb-3 text-muted-foreground/40" />
                  <h3 className="font-bold text-foreground">No users found</h3>
                  <p className="text-sm text-muted-foreground mt-1">
                    Try a different name or check spelling
                  </p>
                </div>
              )}
            </div>
          ) : (
            // Normal browse mode
            <>
              <p className="text-sm text-muted-foreground -mt-1 mb-2">
                Students with shared interests at your university.
              </p>

              {/* Sent pending requests */}
              {Array.from(sentIds).length > 0 && (
                <div className="mb-4">
                  <h3 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-3 flex items-center gap-2">
                    <Clock className="h-3.5 w-3.5" />
                    Pending Sent
                  </h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 mb-2">
                    {users
                      .filter((u) => sentIds.has(u.id))
                      .map((p, i) => (
                        <article
                          key={p.id}
                          style={{ animationDelay: `${i * 60}ms` }}
                          className="glass rounded-2xl p-4 animate-slide-up"
                        >
                          <div className="flex items-center gap-3">
                            <img
                              src={avatar(p)}
                              alt={p.first_name}
                              className="h-12 w-12 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0"
                            />
                            <div className="flex-1 min-w-0">
                              <h3 className="font-semibold text-[15px] text-foreground truncate">
                                {p.first_name} {p.last_name}
                              </h3>
                              <p className="text-[11px] text-muted-foreground truncate">
                                {p.universities?.name ?? ""}
                              </p>
                            </div>
                            <button
                              onClick={() => withdrawRequest(p.id)}
                              disabled={actionLoading === p.id}
                              className="flex items-center gap-1 text-xs font-semibold text-amber-600 bg-amber-50 dark:bg-amber-950/50 px-3 py-1.5 rounded-full hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95 disabled:opacity-60 shrink-0"
                            >
                              {actionLoading === p.id ? (
                                <Loader2 className="h-3 w-3 animate-spin" />
                              ) : (
                                <Clock className="h-3 w-3" />
                              )}
                              Pending
                            </button>
                          </div>
                        </article>
                      ))}
                  </div>
                </div>
              )}

              {/* Discover Users */}
              {filteredDiscoverUsers.length === 0 ? (
                <div className="glass-strong rounded-3xl p-8 text-center">
                  <div className="mx-auto h-12 w-12 rounded-full bg-gradient-primary grid place-items-center shadow-glow mb-3">
                    <Sparkles className="h-5 w-5 text-primary-foreground" />
                  </div>
                  <h3 className="font-bold text-foreground">No new people to discover</h3>
                  <p className="text-sm text-muted-foreground mt-1">
                    You've connected with everyone! Check back later.
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 xl:grid-cols-3 gap-3.5">
                  {filteredDiscoverUsers.map((p, i) => (
                    <article
                      key={p.id}
                      style={{ animationDelay: `${i * 60}ms` }}
                      className="glass rounded-3xl p-5 animate-slide-up cursor-pointer hover:shadow-glow transition-shadow flex flex-col justify-between"
                      onClick={() => setSelectedUser(p)}
                    >
                      <div>
                        <div className="flex items-start gap-4">
                          <img
                            src={avatar(p)}
                            alt={p.first_name}
                            className="h-16 w-16 rounded-2xl bg-secondary ring-2 ring-white shadow-soft shrink-0"
                          />
                          <div className="flex-1 min-w-0">
                            <h3 className="font-bold text-lg text-foreground leading-tight">
                              {p.first_name} {p.last_name}
                            </h3>
                            <p className="text-xs text-muted-foreground mt-0.5">
                              {p.universities?.name ?? ""}
                            </p>
                            {(p.profession || p.specialties?.name || p.year) && (
                              <p className="text-xs text-primary font-semibold mt-0.5">
                                {[p.profession, p.specialties?.name, p.year]
                                  .filter(Boolean)
                                  .join(" · ")}
                              </p>
                            )}
                          </div>
                        </div>

                        {p.interests && p.interests.length > 0 && (
                          <div className="flex flex-wrap gap-1.5 mt-4">
                            {p.interests.map((tag) => (
                              <span
                                key={tag}
                                className="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-primary-soft text-primary"
                              >
                                {tag}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>

                      <div className="mt-4" onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => sendFriendRequest(p.id)}
                          disabled={actionLoading === p.id}
                          className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all disabled:opacity-60"
                        >
                          {actionLoading === p.id ? (
                            <Loader2 className="h-4 w-4 animate-spin" />
                          ) : (
                            <UserPlus className="h-4 w-4" />
                          )}
                          Send Friend Request
                        </button>
                      </div>
                    </article>
                  ))}
                </div>
              )}
            </>
          )}
        </div>
      )}

      {/* Friend Requests Popup Modal */}
      {showRequestPopup && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-start justify-center pt-20 p-5 animate-fade-in" onClick={() => setShowRequestPopup(false)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-5 space-y-3 max-h-[75vh] flex flex-col animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-full bg-gradient-primary grid place-items-center shadow-glow">
                  <Bell className="h-3.5 w-3.5 text-primary-foreground" />
                </div>
                <h2 className="text-lg font-bold text-foreground">Friend Requests</h2>
              </div>
              <button
                onClick={() => setShowRequestPopup(false)}
                className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto space-y-2">
              {incomingRequests.length === 0 ? (
                <div className="text-center py-8">
                  <Users className="h-8 w-8 mx-auto mb-2 text-muted-foreground/40" />
                  <p className="text-sm text-muted-foreground font-semibold">No pending requests</p>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    When someone sends you a friend request, it'll show up here.
                  </p>
                </div>
              ) : (
                incomingRequests.map((req, i) => (
                  <div
                    key={req.id}
                    style={{ animationDelay: `${i * 50}ms` }}
                    className="glass rounded-2xl p-3 animate-slide-up"
                  >
                    <div className="flex items-center gap-3">
                      <img
                        src={avatar(req.profile)}
                        alt={req.profile.first_name}
                        className="h-11 w-11 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0"
                      />
                      <div className="flex-1 min-w-0">
                        <h4 className="font-semibold text-sm text-foreground truncate">
                          {req.profile.first_name} {req.profile.last_name}
                        </h4>
                        <p className="text-[11px] text-muted-foreground truncate">
                          {req.profile.universities?.name ?? ""}
                        </p>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-2 mt-2.5">
                      <button
                        onClick={() => respondToRequest(req.id, "accepted")}
                        disabled={actionLoading === req.id}
                        className="flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all disabled:opacity-60"
                      >
                        {actionLoading === req.id ? (
                          <Loader2 className="h-3.5 w-3.5 animate-spin" />
                        ) : (
                          <Check className="h-3.5 w-3.5" />
                        )}
                        Accept
                      </button>
                      <button
                        onClick={() => respondToRequest(req.id, "rejected")}
                        disabled={actionLoading === req.id}
                        className="flex items-center justify-center gap-1 py-2 rounded-xl font-semibold text-xs bg-secondary text-foreground hover:bg-red-50 hover:text-red-600 transition-colors active:scale-95 disabled:opacity-60"
                      >
                        <X className="h-3.5 w-3.5" />
                        Decline
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* User Profile Modal */}
      {selectedUser && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => { setSelectedUser(null); setConfirmUnfriend(null); }}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 animate-scale-in relative overflow-hidden max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
            <button
              onClick={() => { setSelectedUser(null); setConfirmUnfriend(null); }}
              className="absolute top-4 right-4 h-8 w-8 grid place-items-center rounded-full hover:bg-secondary z-10"
            >
              <X className="h-4 w-4" />
            </button>

            <div className="relative text-center">
              <div className="mx-auto h-20 w-20 rounded-full bg-gradient-primary p-[3px] shadow-glow">
                <img
                  src={avatar(selectedUser)}
                  alt={selectedUser.first_name}
                  className="h-full w-full rounded-full bg-white object-cover"
                />
              </div>

              <h2 className="mt-4 text-2xl font-bold text-foreground">
                {selectedUser.first_name}{" "}
                <span className="text-primary">{selectedUser.last_name}</span>
              </h2>

              <p className="text-sm text-muted-foreground mt-1">
                {selectedUser.universities?.name ?? ""}
              </p>

              {(selectedUser.profession || selectedUser.specialties?.name) && (
                <p className="text-xs text-primary font-semibold mt-1">
                  {[selectedUser.profession, selectedUser.specialties?.name].filter(Boolean).join(" · ")}
                </p>
              )}

              {selectedUser.bio && (
                <div className="mt-4 bg-secondary/60 rounded-2xl p-4 text-left">
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">Bio</p>
                  <p className="text-sm text-foreground leading-relaxed">
                    {selectedUser.bio}
                  </p>
                </div>
              )}

              {selectedUser.interests && selectedUser.interests.length > 0 && (
                <div className="flex flex-wrap gap-1.5 mt-4 justify-center">
                  {selectedUser.interests.map((tag) => (
                    <span
                      key={tag}
                      className="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-primary-soft text-primary"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              )}

              <div className="mt-5" onClick={(e) => e.stopPropagation()}>
                {friendIds.has(selectedUser.id) ? (
                  <div className="space-y-2">
                    {onOpenChat && (
                      <button
                        onClick={() => handleOpenChatWithUser(selectedUser)}
                        className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all"
                      >
                        <MessageCircle className="h-4 w-4" />
                        Send Message
                      </button>
                    )}
                    {confirmUnfriend === selectedUser.id ? (
                      <div className="flex gap-2 w-full">
                        <button
                          onClick={() => setConfirmUnfriend(null)}
                          className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl font-semibold text-xs bg-secondary text-foreground active:scale-95 transition-all"
                        >
                          <X className="h-3.5 w-3.5" />
                          Cancel
                        </button>
                        <button
                          onClick={() => unfriend(selectedUser.id)}
                          disabled={actionLoading === selectedUser.id}
                          className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl font-semibold text-xs bg-red-50 dark:bg-red-950/50 text-red-600 dark:text-red-400 hover:bg-red-100 transition-colors active:scale-95 disabled:opacity-60"
                        >
                          {actionLoading === selectedUser.id ? (
                            <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          ) : (
                            <UserMinus className="h-3.5 w-3.5" />
                          )}
                          Unfriend
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => setConfirmUnfriend(selectedUser.id)}
                        className="w-full flex items-center justify-center gap-1.5 py-2 rounded-xl font-medium text-xs text-muted-foreground hover:text-red-500 transition-colors"
                      >
                        <Check className="h-3.5 w-3.5 text-success" />
                        Friends (click to remove)
                      </button>
                    )}
                  </div>
                ) : (
                  <div className="space-y-2">
                    {sentIds.has(selectedUser.id) ? (
                      <button
                        onClick={() => withdrawRequest(selectedUser.id)}
                        disabled={actionLoading === selectedUser.id}
                        className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-amber-50 dark:bg-amber-950/50 text-amber-600 dark:text-amber-400 hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95 disabled:opacity-60"
                      >
                        {actionLoading === selectedUser.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <UserMinus className="h-4 w-4" />
                        )}
                        Withdraw Request
                      </button>
                    ) : (
                      <button
                        onClick={() => sendFriendRequest(selectedUser.id)}
                        disabled={actionLoading === selectedUser.id}
                        className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-all disabled:opacity-60"
                      >
                        {actionLoading === selectedUser.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <UserPlus className="h-4 w-4" />
                        )}
                        Send Friend Request
                      </button>
                    )}

                    {/* Direct message if recipient allows messages from all */}
                    {onOpenChat && (
                      selectedUser.message_privacy !== "only_friends" ? (
                        <button
                          onClick={() => handleOpenChatWithUser(selectedUser)}
                          className="w-full flex items-center justify-center gap-1.5 py-2 rounded-xl font-semibold text-xs bg-secondary hover:bg-primary-soft text-primary transition-all active:scale-95"
                        >
                          <MessageCircle className="h-3.5 w-3.5" />
                          Direct Message
                        </button>
                      ) : (
                        <p className="text-[11px] text-muted-foreground text-center flex items-center justify-center gap-1 pt-1">
                          <Lock className="h-3 w-3" />
                          Accepts messages only from friends
                        </p>
                      )
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
