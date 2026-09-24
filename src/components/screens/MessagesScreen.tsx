import { useEffect, useMemo, useState, useCallback, useRef } from "react";
import { v4 as uuidv4 } from "uuid";
import { Search, MessageSquarePlus, Loader2, Sparkles, X, UserPlus, UsersRound, GraduationCap, BookOpen, Trophy, Code2 } from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { cn } from "@/lib/utils";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { useProfileFields } from "@/hooks/useProfileFields";
import { toast } from "sonner";

export interface ChatListItem {
  id: string;
  participant: {
    id: string;
    first_name: string;
    last_name: string;
    avatar_url: string | null;
    university: string;
  };
  last_message: string | null;
  last_message_at: string | null;
  unread_count: number;
}

interface FriendProfile {
  id: string;
  first_name: string;
  last_name: string;
  avatar_url: string | null;
  university: string;
  major?: string | null;
  bio?: string | null;
  interests?: string[] | null;
  profession?: string | null;
  entrance_score?: number | null;
  is_friend?: boolean;
  message_privacy?: string | null;
}

interface Props {
  onOpenChat: (chat: ChatListItem) => void;
}

const formatRelative = (iso: string | null) => {
  if (!iso) return "";
  const d = new Date(iso);
  const diff = Date.now() - d.getTime();
  const min = Math.floor(diff / 60000);
  if (min < 1) return "now";
  if (min < 60) return `${min}m`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h`;
  const day = Math.floor(hr / 24);
  if (day === 1) return "Yesterday";
  if (day < 7) return `${day}d`;
  return d.toLocaleDateString([], { month: "short", day: "numeric" });
};

export const MessagesScreen = ({ onOpenChat }: Props) => {
  const { user } = useAuth();
  const [query, setQuery] = useState("");
  const [chats, setChats] = useState<ChatListItem[]>([]);
  const [loading, setLoading] = useState(true);

  // New chat modal
  const [showNewChat, setShowNewChat] = useState(false);
  const [newChatQuery, setNewChatQuery] = useState("");
  const [friendsList, setFriendsList] = useState<FriendProfile[]>([]);
  const [friendsLoading, setFriendsLoading] = useState(false);
  const [startingChat, setStartingChat] = useState<string | null>(null);

  // Search people when searching from main input
  const [peopleSearchResults, setPeopleSearchResults] = useState<FriendProfile[]>([]);
  const [searchingPeople, setSearchingPeople] = useState(false);

  // Friends list overlay
  const [showFriendsList, setShowFriendsList] = useState(false);
  const [allFriends, setAllFriends] = useState<FriendProfile[]>([]);
  const [allFriendsLoading, setAllFriendsLoading] = useState(false);
  const [selectedFriend, setSelectedFriend] = useState<FriendProfile | null>(null);
  const { data: selectedFriendFields = [] } = useProfileFields(selectedFriend?.id);

  const loadingRef = useRef(false);

  const loadChats = useCallback(async () => {
    if (!user || loadingRef.current) return;
    loadingRef.current = true;
    try {
      const { data: parts } = await (supabase.from("chat_participants") as any)
        .select("chat_id")
        .eq("user_id", user.id);
      const ids = (parts ?? []).map((p: any) => p.chat_id);
      if (ids.length === 0) {
        setChats([]);
        setLoading(false);
        return;
      }
      const [{ data: chatRows }, { data: allParts }, { data: myReads }] = await Promise.all([
        (supabase.from("chats") as any).select("*").in("id", ids).order("last_message_at", {
          ascending: false,
          nullsFirst: false,
        }),
        (supabase.from("chat_participants") as any).select("chat_id, user_id").in("chat_id", ids),
        (supabase.from("message_reads") as any).select("message_id, chat_id").in("chat_id", ids).eq("user_id", user.id),
      ]);

      const otherIds = (allParts ?? [])
        .filter((p: any) => p.user_id !== user.id)
        .map((p: any) => p.user_id);
      const { data: profiles } = await (supabase.from("profiles") as any)
        .select("id, first_name, last_name, avatar_url, university")
        .in("id", otherIds.length ? otherIds : ["00000000-0000-0000-0000-000000000000"]);

      const { data: msgs } = await (supabase.from("messages") as any)
        .select("id, chat_id, sender_id")
        .in("chat_id", ids)
        .neq("sender_id", user.id);
      const readSet = new Set((myReads ?? []).map((r: any) => r.message_id));
      const unreadByChat: Record<string, number> = {};
      (msgs ?? []).forEach((m: any) => {
        if (!readSet.has(m.id)) {
          unreadByChat[m.chat_id] = (unreadByChat[m.chat_id] ?? 0) + 1;
        }
      });

      const profileMap = new Map((profiles ?? []).map((p: any) => [p.id, p]));
      const partnerByChat = new Map<string, string>();
      (allParts ?? []).forEach((p: any) => {
        if (p.user_id !== user.id) partnerByChat.set(p.chat_id, p.user_id);
      });

      const list: ChatListItem[] = (chatRows ?? []).map((c: any) => {
        const partnerId = partnerByChat.get(c.id);
        const prof: any = partnerId ? profileMap.get(partnerId) : undefined;
        return {
          id: c.id,
          participant: {
            id: partnerId ?? "",
            first_name: prof?.first_name ?? "Unknown",
            last_name: prof?.last_name ?? "",
            avatar_url: prof?.avatar_url ?? null,
            university: prof?.university ?? "",
          },
          last_message: c.last_message,
          last_message_at: c.last_message_at,
          unread_count: unreadByChat[c.id] ?? 0,
        };
      });
      setChats(list);
      setLoading(false);
    } catch (e) {
      console.error("loadChats failed", e);
      setLoading(false);
    } finally {
      loadingRef.current = false;
    }
  }, [user]);

  useEffect(() => {
    setLoading(true);
    loadChats();
  }, [loadChats]);

  // Realtime: refresh on new messages or read receipts (debounced to batch rapid events)
  useEffect(() => {
    if (!user) return;
    let debounceTimer: ReturnType<typeof setTimeout> | null = null;
    const scheduleReload = () => {
      if (debounceTimer) clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => loadChats(), 400);
    };
    const ch = supabase
      .channel(`messages-list:${user.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "messages" }, scheduleReload)
      .on("postgres_changes", { event: "*", schema: "public", table: "message_reads" }, scheduleReload)
      .on("postgres_changes", { event: "*", schema: "public", table: "chats" }, scheduleReload)
      .subscribe();
    return () => {
      if (debounceTimer) clearTimeout(debounceTimer);
      supabase.removeChannel(ch);
    };
  }, [user, loadChats]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return chats;
    return chats.filter(
      (c) =>
        `${c.participant.first_name} ${c.participant.last_name}`.toLowerCase().includes(q) ||
        (c.last_message ?? "").toLowerCase().includes(q),
    );
  }, [query, chats]);

  // Search people who are messageable (respecting privacy: 'all' or friends if 'only_friends')
  useEffect(() => {
    const q = query.trim().toLowerCase();
    if (!q || !user?.id) {
      setPeopleSearchResults([]);
      return;
    }

    const timer = setTimeout(async () => {
      setSearchingPeople(true);
      try {
        const tbl = supabase.from("friendships") as any;
        const [{ data: sent }, { data: received }, { data: matchedProfiles }] = await Promise.all([
          tbl.select("addressee_id").eq("requester_id", user.id).eq("status", "accepted"),
          tbl.select("requester_id").eq("addressee_id", user.id).eq("status", "accepted"),
          (supabase.from("profiles") as any)
            .select("id, first_name, last_name, avatar_url, university, universities(name), message_privacy, account_type")
            .neq("id", user.id)
            .or(`first_name.ilike.%${q}%,last_name.ilike.%${q}%`)
            .limit(20),
        ]);

        const friendIdSet = new Set<string>([
          ...(sent ?? []).map((r: any) => r.addressee_id),
          ...(received ?? []).map((r: any) => r.requester_id),
        ]);

        const existingChatPartnerIds = new Set(chats.map((c) => c.participant.id));

        const list: FriendProfile[] = (matchedProfiles ?? [])
          .filter((p: any) => {
            if (p.account_type === "company") return false;
            if (existingChatPartnerIds.has(p.id)) return false;
            const isFriend = friendIdSet.has(p.id);
            const privacy = p.message_privacy ?? "all";
            // If only_friends, must be friend. If all, can message.
            if (privacy === "only_friends") {
              return isFriend;
            }
            return true;
          })
          .map((p: any) => ({
            id: p.id,
            first_name: p.first_name,
            last_name: p.last_name,
            avatar_url: p.avatar_url,
            university: p.universities?.name ?? p.university ?? "",
            is_friend: friendIdSet.has(p.id),
            message_privacy: p.message_privacy ?? "all",
          }));

        setPeopleSearchResults(list);
      } catch (err) {
        console.error("Search people error:", err);
      } finally {
        setSearchingPeople(false);
      }
    }, 250);

    return () => clearTimeout(timer);
  }, [query, user?.id, chats]);

  // Load people who we can start a new chat with (friends + open-privacy students)
  const openNewChat = async () => {
    if (!user?.id) return;
    setShowNewChat(true);
    setFriendsLoading(true);
    setNewChatQuery("");

    try {
      const tbl = supabase.from("friendships") as any;
      const [{ data: sent }, { data: received }, { data: allProfiles }] = await Promise.all([
        tbl.select("addressee_id").eq("requester_id", user.id).eq("status", "accepted"),
        tbl.select("requester_id").eq("addressee_id", user.id).eq("status", "accepted"),
        (supabase.from("profiles") as any)
          .select("id, first_name, last_name, avatar_url, university, universities(name), message_privacy, account_type")
          .neq("id", user.id)
          .order("first_name", { ascending: true }),
      ]);

      const friendIdSet = new Set<string>([
        ...(sent ?? []).map((r: any) => r.addressee_id),
        ...(received ?? []).map((r: any) => r.requester_id),
      ]);

      // Filter out friends/people who already have an active chat
      const existingChatPartnerIds = new Set(chats.map((c) => c.participant.id));

      const list: FriendProfile[] = (allProfiles ?? [])
        .filter((p: any) => {
          if (p.account_type === "company") return false;
          if (existingChatPartnerIds.has(p.id)) return false;
          const isFriend = friendIdSet.has(p.id);
          const privacy = p.message_privacy ?? "all";
          if (privacy === "only_friends") {
            return isFriend;
          }
          return true;
        })
        .map((p: any) => ({
          id: p.id,
          first_name: p.first_name,
          last_name: p.last_name,
          avatar_url: p.avatar_url,
          university: p.universities?.name ?? p.university ?? "",
          is_friend: friendIdSet.has(p.id),
          message_privacy: p.message_privacy ?? "all",
        }));

      setFriendsList(list);
    } catch (e) {
      console.error("openNewChat error", e);
      toast.error("Failed to load contacts");
    } finally {
      setFriendsLoading(false);
    }
  };

  /**
   * FIX: Chat creation with proper FK constraint handling.
   *
   * The original bug: "insert or update on table 'chat_participants' violates
   * foreign key constraint 'chat_participants_chat_id_fkey'"
   *
   * Root cause: The chat_participants insert referenced a chat_id that didn't
   * exist yet because:
   *   1) The chats table insert may have silently failed (RLS, missing columns)
   *   2) The client-generated UUID was not matching the server-side expectation
   *
   * Fix: Generate the UUID on the client side and pass it explicitly so both
   * the chats insert and the chat_participants insert use the exact same ID.
   * We also verify the chat row actually exists before inserting participants.
   */
  const startChat = async (targetId: string) => {
    if (!user?.id) return;

    // Check if already in active chats
    const existing = chats.find((c) => c.participant.id === targetId);
    if (existing) {
      setShowNewChat(false);
      onOpenChat(existing);
      return;
    }

    setStartingChat(targetId);
    try {
      // Step 0: Check recipient's message privacy setting
      const { data: recipientProfile } = await (supabase.from("profiles") as any)
        .select("id, first_name, last_name, avatar_url, university, universities(name), message_privacy")
        .eq("id", targetId)
        .maybeSingle();

      const recipientPrivacy = recipientProfile?.message_privacy ?? "all";

      if (recipientPrivacy === "only_friends") {
        // Check if we are friends with this person
        const { data: friendship } = await (supabase.from("friendships") as any)
          .select("id")
          .eq("status", "accepted")
          .or(`and(requester_id.eq.${user.id},addressee_id.eq.${targetId}),and(requester_id.eq.${targetId},addressee_id.eq.${user.id})`)
          .maybeSingle();

        if (!friendship) {
          toast.error("This user only accepts messages from friends.");
          return;
        }
      }

      // Check in DB if there is already a chat between these two
      const { data: myParts } = await (supabase.from("chat_participants") as any)
        .select("chat_id")
        .eq("user_id", user.id);
      const myChatIds = (myParts ?? []).map((p: any) => p.chat_id);

      if (myChatIds.length > 0) {
        const { data: commonPart } = await (supabase.from("chat_participants") as any)
          .select("chat_id")
          .in("chat_id", myChatIds)
          .eq("user_id", targetId)
          .maybeSingle();

        if (commonPart) {
          const chatItem: ChatListItem = {
            id: commonPart.chat_id,
            participant: {
              id: targetId,
              first_name: recipientProfile?.first_name ?? "Unknown",
              last_name: recipientProfile?.last_name ?? "",
              avatar_url: recipientProfile?.avatar_url ?? null,
              university: recipientProfile?.universities?.name ?? recipientProfile?.university ?? "",
            },
            last_message: null,
            last_message_at: null,
            unread_count: 0,
          };
          setShowNewChat(false);
          onOpenChat(chatItem);
          return;
        }
      }

      // Step 1: Generate a deterministic chat ID on the client
      const chatId = uuidv4();

      // Step 2: Create the chat row with the explicit ID
      const { data: chat, error: chatErr } = await (supabase.from("chats") as any)
        .insert({ id: chatId, last_message: null, last_message_at: null })
        .select("id")
        .single();

      if (chatErr) {
        console.error("Chat creation failed:", chatErr);
        throw new Error("Failed to create chat: " + chatErr.message);
      }

      if (!chat?.id) {
        throw new Error("Chat was created but no ID was returned. Check RLS policies.");
      }

      // Step 3: Verify the chat row exists before inserting participants
      const { data: verify } = await (supabase.from("chats") as any)
        .select("id")
        .eq("id", chat.id)
        .single();

      if (!verify) {
        throw new Error("Chat row not found after creation.");
      }

      // Step 4: Add both participants (now the FK will succeed)
      const { error: partErr } = await (supabase.from("chat_participants") as any)
        .insert([
          { chat_id: chat.id, user_id: user.id },
          { chat_id: chat.id, user_id: targetId },
        ]);

      if (partErr) {
        console.error("Participant insert failed:", partErr);
        // Cleanup: delete the orphaned chat
        await (supabase.from("chats") as any).delete().eq("id", chat.id);
        throw new Error("Failed to add participants: " + partErr.message);
      }

      // Step 5: Open the chat
      const friend = friendsList.find((f) => f.id === targetId)
        || allFriends.find((f) => f.id === targetId)
        || peopleSearchResults.find((f) => f.id === targetId);

      const chatItem: ChatListItem = {
        id: chat.id,
        participant: {
          id: targetId,
          first_name: friend?.first_name ?? recipientProfile?.first_name ?? "Unknown",
          last_name: friend?.last_name ?? recipientProfile?.last_name ?? "",
          avatar_url: friend?.avatar_url ?? recipientProfile?.avatar_url ?? null,
          university: friend?.university ?? recipientProfile?.universities?.name ?? "",
        },
        last_message: null,
        last_message_at: null,
        unread_count: 0,
      };

      setShowNewChat(false);
      onOpenChat(chatItem);
      toast.success("Chat started! 💬");
      await loadChats();
    } catch (e: any) {
      console.error("startChat error:", e);
      toast.error(e.message ?? "Failed to create chat");
    } finally {
      setStartingChat(null);
    }
  };

  // Load ALL friends for the friends list overlay
  const openFriendsList = async () => {
    if (!user?.id) return;
    setShowFriendsList(true);
    setAllFriendsLoading(true);

    const tbl = supabase.from("friendships") as any;
    const [{ data: sent }, { data: received }] = await Promise.all([
      tbl.select("addressee_id").eq("requester_id", user.id).eq("status", "accepted"),
      tbl.select("requester_id").eq("addressee_id", user.id).eq("status", "accepted"),
    ]);

    const friendIds = [
      ...(sent ?? []).map((r: any) => r.addressee_id),
      ...(received ?? []).map((r: any) => r.requester_id),
    ];

    if (friendIds.length > 0) {
      const { data: profiles } = await (supabase.from("profiles") as any)
        .select("id,first_name,last_name,avatar_url,university,major,bio,interests,profession,entrance_score")
        .in("id", friendIds);
      setAllFriends(profiles ?? []);
    } else {
      setAllFriends([]);
    }
    setAllFriendsLoading(false);
  };

  return (
    <div className="animate-fade-in">
      <AppHeader
        subtitle="BONDED"
        title="Messages"
        right={
          <div className="flex items-center gap-2">
            <button
              onClick={openNewChat}
              className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label="New chat"
              title="New conversation"
            >
              <MessageSquarePlus className="h-[18px] w-[18px] text-primary" strokeWidth={2.2} />
            </button>
            <button
              onClick={openFriendsList}
              className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label="Friends list"
              title="View friends"
            >
              <UsersRound className="h-[18px] w-[18px] text-primary" strokeWidth={2.2} />
            </button>
          </div>
        }
      />

      <div className="px-5 pb-3">
        <div className="glass rounded-2xl flex items-center gap-2 px-4 py-3">
          <Search className="h-4 w-4 text-muted-foreground" />
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search chats and people"
            className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
          />
        </div>
      </div>

      {loading ? (
        <div className="px-5 py-12 text-center text-muted-foreground text-sm">
          <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2" />
          Loading conversations…
        </div>
      ) : chats.length === 0 ? (
        <div className="px-5 mt-4">
          <div className="glass-strong rounded-3xl p-8 text-center">
            <div className="mx-auto h-12 w-12 rounded-full bg-gradient-primary grid place-items-center shadow-glow mb-3">
              <Sparkles className="h-5 w-5 text-primary-foreground" />
            </div>
            <h3 className="font-bold text-foreground">No conversations yet</h3>
            <p className="text-sm text-muted-foreground mt-1">
              Add friends from the Friends tab, then start chatting!
            </p>
            <button
              onClick={openNewChat}
              className="mt-4 inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-gradient-primary text-primary-foreground font-semibold text-sm shadow-glow active:scale-95"
            >
              <MessageSquarePlus className="h-4 w-4" />
              New Conversation
            </button>
          </div>
        </div>
      ) : (
        <ul className="px-3 space-y-1.5">
          {filtered.map((chat, i) => (
            <li key={chat.id} style={{ animationDelay: `${i * 40}ms` }} className="animate-slide-up">
              <button
                onClick={() => onOpenChat(chat)}
                className="w-full flex items-center gap-3 px-3 py-3 rounded-2xl hover:bg-primary-soft active:scale-[0.99] transition-all text-left"
              >
                <div className="relative shrink-0">
                  <img
                    src={chat.participant.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${chat.participant.id}`}
                    alt={chat.participant.first_name}
                    className="h-12 w-12 rounded-full bg-secondary ring-2 ring-white shadow-soft"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <p className="font-semibold text-[15px] text-foreground truncate">
                      {chat.participant.first_name} {chat.participant.last_name}
                    </p>
                    <span
                      className={cn(
                        "text-[11px] shrink-0",
                        chat.unread_count
                          ? "text-primary font-semibold"
                          : "text-muted-foreground",
                      )}
                    >
                      {formatRelative(chat.last_message_at)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between gap-2 mt-0.5">
                    <p
                      className={cn(
                        "text-sm truncate",
                        chat.unread_count
                          ? "text-foreground font-medium"
                          : "text-muted-foreground",
                      )}
                    >
                      {chat.last_message ?? "Say hi 👋"}
                    </p>
                    {chat.unread_count > 0 && (
                      <span className="shrink-0 h-5 min-w-5 px-1.5 rounded-full bg-gradient-primary text-primary-foreground text-[11px] font-bold grid place-items-center shadow-glow">
                        {chat.unread_count}
                      </span>
                    )}
                  </div>
                </div>
              </button>
            </li>
          ))}
          {filtered.length === 0 && peopleSearchResults.length === 0 && !searchingPeople && (
            <li className="text-center text-muted-foreground text-sm py-12">
              No conversations or people match "{query}"
            </li>
          )}

          {/* People matching search (who can be messaged) */}
          {query.trim() && peopleSearchResults.length > 0 && (
            <li className="pt-3 pb-2 list-none">
              <p className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground px-3 mb-2">
                Start a new conversation
              </p>
              <div className="space-y-1">
                {peopleSearchResults.map((person) => (
                  <div
                    key={person.id}
                    onClick={() => startChat(person.id)}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-2xl hover:bg-primary-soft active:scale-[0.99] transition-all cursor-pointer"
                  >
                    <img
                      src={person.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${person.id}`}
                      alt={person.first_name}
                      className="h-11 w-11 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0"
                    />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className="font-semibold text-sm text-foreground truncate">
                          {person.first_name} {person.last_name}
                        </p>
                        {person.is_friend && (
                          <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-primary-soft text-primary shrink-0">
                            Friend
                          </span>
                        )}
                      </div>
                      <p className="text-xs text-muted-foreground truncate">{person.university}</p>
                    </div>
                    {startingChat === person.id ? (
                      <Loader2 className="h-4 w-4 animate-spin text-primary shrink-0" />
                    ) : (
                      <MessageSquarePlus className="h-4 w-4 text-primary shrink-0" />
                    )}
                  </div>
                ))}
              </div>
            </li>
          )}
        </ul>
      )}

      {/* New Chat Modal */}
      {showNewChat && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => setShowNewChat(false)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 space-y-4 max-h-[80vh] flex flex-col animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold text-foreground">New Conversation</h2>
                <p className="text-xs text-muted-foreground mt-0.5">
                  Select a friend or open student to chat with
                </p>
              </div>
              <button
                onClick={() => setShowNewChat(false)}
                className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Search within contacts */}
            <div className="glass rounded-xl flex items-center gap-2 px-3 py-2">
              <Search className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
              <input
                type="search"
                value={newChatQuery}
                onChange={(e) => setNewChatQuery(e.target.value)}
                placeholder="Search by name or university…"
                className="flex-1 bg-transparent outline-none text-xs placeholder:text-muted-foreground"
              />
              {newChatQuery && (
                <button onClick={() => setNewChatQuery("")} className="h-4 w-4 grid place-items-center rounded-full hover:bg-secondary">
                  <X className="h-3 w-3 text-muted-foreground" />
                </button>
              )}
            </div>

            <div className="flex-1 overflow-y-auto space-y-2">
              {friendsLoading ? (
                <div className="py-8 text-center">
                  <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2 text-primary" />
                  <p className="text-sm text-muted-foreground">Loading…</p>
                </div>
              ) : (
                (() => {
                  const q = newChatQuery.trim().toLowerCase();
                  const list = q
                    ? friendsList.filter(
                        (f) =>
                          `${f.first_name} ${f.last_name}`.toLowerCase().includes(q) ||
                          f.university.toLowerCase().includes(q)
                      )
                    : friendsList;

                  if (list.length === 0) {
                    return (
                      <div className="text-center text-muted-foreground text-sm py-8">
                        <UserPlus className="h-8 w-8 mx-auto mb-2 opacity-40" />
                        <p className="font-semibold text-foreground">No students available</p>
                        <p className="text-xs mt-1">
                          {q ? "No matches found" : "Connect with more students in the Network tab."}
                        </p>
                      </div>
                    );
                  }

                  return list.map((f) => (
                    <button
                      key={f.id}
                      onClick={() => startChat(f.id)}
                      disabled={startingChat === f.id}
                      className="w-full flex items-center gap-3 p-3 rounded-xl bg-secondary/50 hover:bg-primary-soft transition-colors text-left disabled:opacity-60"
                    >
                      <img
                        src={
                          f.avatar_url ??
                          `https://api.dicebear.com/7.x/avataaars/svg?seed=${f.id}`
                        }
                        alt={f.first_name}
                        className="h-10 w-10 rounded-full bg-secondary ring-1 ring-border shrink-0"
                      />
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <p className="font-semibold text-sm text-foreground truncate">
                            {f.first_name} {f.last_name}
                          </p>
                          {f.is_friend && (
                            <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-primary-soft text-primary shrink-0">
                              Friend
                            </span>
                          )}
                        </div>
                        <p className="text-xs text-muted-foreground truncate">
                          {f.university}
                        </p>
                      </div>
                      {startingChat === f.id ? (
                        <Loader2 className="h-4 w-4 animate-spin text-primary shrink-0" />
                      ) : (
                        <MessageSquarePlus className="h-4 w-4 text-primary shrink-0" />
                      )}
                    </button>
                  ));
                })()
              )}
            </div>
          </div>
        </div>
      )}

      {/* Friends List Overlay */}
      {showFriendsList && (
        <div className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => { setShowFriendsList(false); setSelectedFriend(null); }}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 space-y-4 max-h-[80vh] flex flex-col animate-scale-in"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="h-8 w-8 rounded-full bg-gradient-primary grid place-items-center shadow-glow">
                  <UsersRound className="h-3.5 w-3.5 text-primary-foreground" />
                </div>
                <h2 className="text-xl font-bold text-foreground">My Friends</h2>
                {allFriends.length > 0 && (
                  <span className="text-xs font-semibold text-primary bg-primary-soft px-2 py-0.5 rounded-full">
                    {allFriends.length}
                  </span>
                )}
              </div>
              <button
                onClick={() => { setShowFriendsList(false); setSelectedFriend(null); }}
                className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto space-y-2">
              {allFriendsLoading ? (
                <div className="py-8 text-center">
                  <Loader2 className="h-5 w-5 animate-spin mx-auto mb-2 text-primary" />
                  <p className="text-sm text-muted-foreground">Loading friends…</p>
                </div>
              ) : allFriends.length === 0 ? (
                <div className="text-center text-muted-foreground text-sm py-8">
                  <UsersRound className="h-8 w-8 mx-auto mb-2 opacity-40" />
                  <p className="font-semibold text-foreground">No friends yet</p>
                  <p className="text-xs mt-1">Go to the Discover tab to find and add friends.</p>
                </div>
              ) : (
                allFriends.map((f) => (
                  <div
                    key={f.id}
                    className="w-full flex items-center gap-3 p-3 rounded-xl bg-secondary/50 hover:bg-primary-soft transition-colors"
                  >
                    <button
                      onClick={() => setSelectedFriend(f)}
                      className="flex items-center gap-3 flex-1 min-w-0 text-left"
                    >
                      <img
                        src={f.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${f.id}`}
                        alt={f.first_name}
                        className="h-10 w-10 rounded-full bg-secondary ring-2 ring-white shadow-soft shrink-0"
                      />
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-sm text-foreground truncate">
                          {f.first_name} {f.last_name}
                        </p>
                        <p className="text-xs text-muted-foreground truncate">{f.university}</p>
                      </div>
                    </button>
                    <button
                      onClick={() => {
                        // Check if chat already exists
                        const existingChat = chats.find((c) => c.participant.id === f.id);
                        if (existingChat) {
                          setShowFriendsList(false);
                          setSelectedFriend(null);
                          onOpenChat(existingChat);
                        } else {
                          // Start new chat
                          setShowFriendsList(false);
                          setSelectedFriend(null);
                          startChat(f.id);
                        }
                      }}
                      className="h-9 w-9 grid place-items-center rounded-full bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-transform shrink-0"
                      title="Send message"
                    >
                      <MessageSquarePlus className="h-4 w-4" />
                    </button>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      )}

      {/* Friend Profile Modal */}
      {selectedFriend && (
        <div className="fixed inset-0 z-[60] bg-black/40 grid place-items-center p-5 animate-fade-in" onClick={() => setSelectedFriend(null)}>
          <div
            className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-6 animate-scale-in relative overflow-hidden max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
            <button
              onClick={() => setSelectedFriend(null)}
              className="absolute top-4 right-4 h-8 w-8 grid place-items-center rounded-full hover:bg-secondary z-10"
            >
              <X className="h-4 w-4" />
            </button>
            <div className="relative text-center">
              <div className="mx-auto h-20 w-20 rounded-full bg-gradient-primary p-[3px] shadow-glow">
                <img
                  src={selectedFriend.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${selectedFriend.id}`}
                  alt={selectedFriend.first_name}
                  className="h-full w-full rounded-full bg-white object-cover"
                />
              </div>
              <h2 className="mt-4 text-2xl font-bold text-foreground">
                {selectedFriend.first_name}{" "}
                <span className="text-primary">{selectedFriend.last_name}</span>
              </h2>
              {selectedFriend.university && (
                <div className="mt-2 inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-primary-soft">
                  <GraduationCap className="h-3.5 w-3.5 text-primary" />
                  <span className="text-xs font-semibold text-primary">{selectedFriend.university}</span>
                </div>
              )}
              {(selectedFriend.profession || selectedFriend.major) && (
                <p className="text-xs text-primary font-semibold mt-1.5">
                  {[selectedFriend.profession, selectedFriend.major].filter(Boolean).join(" · ")}
                </p>
              )}
              {selectedFriend.entrance_score != null && selectedFriend.entrance_score > 0 && (
                <div className="mt-2 inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-amber-50 dark:bg-amber-950/50">
                  <Trophy className="h-3.5 w-3.5 text-amber-500" />
                  <span className="text-xs font-semibold text-amber-600 dark:text-amber-400">Score: {selectedFriend.entrance_score}</span>
                </div>
              )}
              {selectedFriend.bio && (
                <div className="mt-3 bg-secondary/60 rounded-2xl p-3 text-left">
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider mb-1">Bio</p>
                  <p className="text-sm text-foreground leading-relaxed">{selectedFriend.bio}</p>
                </div>
              )}
              {selectedFriendFields.length > 0 && (
                <div className="flex flex-wrap gap-1.5 mt-3 justify-center">
                  {selectedFriendFields.map((f) => (
                    <span key={f.field_id} className="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-primary-soft text-primary">
                      <span className="opacity-60">{f.category_label} · </span>
                      {f.label}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
