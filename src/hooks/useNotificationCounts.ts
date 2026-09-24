import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export function useNotificationCounts(userId: string | null) {
  const [friendRequestCount, setFriendRequestCount] = useState(0);
  const [unreadMessageCount, setUnreadMessageCount] = useState(0);
  const [unreadSenderCount, setUnreadSenderCount] = useState(0);
  const [groupInvitationCount, setGroupInvitationCount] = useState(0);

  useEffect(() => {
    if (!userId) return;

    async function fetchCounts() {
      // Friend request count
      const { count: frCount } = await (supabase.from("friendships") as any)
        .select("*", { count: "exact", head: true })
        .eq("addressee_id", userId)
        .eq("status", "pending");

      setFriendRequestCount(frCount ?? 0);

      // Group invitation count
      const { count: giCount } = await (supabase.from("group_invitations") as any)
        .select("*", { count: "exact", head: true })
        .eq("invitee_id", userId)
        .eq("status", "pending");

      setGroupInvitationCount(giCount ?? 0);

      // Unread messages: get actual message rows so we can count distinct senders
      // First, get all chats the user participates in
      const { data: parts } = await (supabase.from("chat_participants") as any)
        .select("chat_id")
        .eq("user_id", userId);
      const chatIds = (parts ?? []).map((p: any) => p.chat_id);

      if (chatIds.length === 0) {
        setUnreadMessageCount(0);
        setUnreadSenderCount(0);
        return;
      }

      // Get all messages from others in those chats
      const { data: msgs } = await (supabase.from("messages") as any)
        .select("id, sender_id")
        .in("chat_id", chatIds)
        .neq("sender_id", userId);

      // Get read receipts for the current user
      const { data: myReads } = await (supabase.from("message_reads") as any)
        .select("message_id")
        .in("chat_id", chatIds)
        .eq("user_id", userId);

      const readSet = new Set((myReads ?? []).map((r: any) => r.message_id));
      const unreadMessages = (msgs ?? []).filter((m: any) => !readSet.has(m.id));
      const distinctSenders = new Set(unreadMessages.map((m: any) => m.sender_id));

      setUnreadMessageCount(unreadMessages.length);
      setUnreadSenderCount(distinctSenders.size);
    }

    fetchCounts();

    const channel = supabase
      .channel(`notif-counts-${userId}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "friendships" }, fetchCounts)
      .on("postgres_changes", { event: "*", schema: "public", table: "messages" }, fetchCounts)
      .on("postgres_changes", { event: "*", schema: "public", table: "message_reads" }, fetchCounts)
      .on("postgres_changes", { event: "*", schema: "public", table: "group_invitations" }, fetchCounts)
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [userId]);

  return { friendRequestCount, unreadMessageCount, unreadSenderCount, groupInvitationCount };
}
