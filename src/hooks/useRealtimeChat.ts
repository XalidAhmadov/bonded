import { useEffect, useRef, useState, useCallback } from "react";
import { v4 as uuidv4 } from "uuid";
import { supabase } from "@/integrations/supabase/client";
import type { RealtimeChannel } from "@supabase/supabase-js";
import { toast } from "sonner";

export interface ChatMessage {
  id: string;
  chat_id: string;
  sender_id: string;
  body: string;
  created_at: string;
}

interface PresenceState {
  typing: Record<string, boolean>;
}

interface UseRealtimeChat {
  chatId: string;
  meId: string;
  otherUserId: string;
}

export const useRealtimeChat = ({ chatId, meId, otherUserId }: UseRealtimeChat) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [reads, setReads] = useState<Record<string, string>>({}); // message_id -> read_at by other user
  const [presence, setPresence] = useState<PresenceState>({ typing: {} });
  const [loading, setLoading] = useState(true);
  const channelRef = useRef<RealtimeChannel | null>(null);
  const typingTimeoutRef = useRef<number | null>(null);

  // Initial load
  useEffect(() => {
    let cancelled = false;
    (async () => {
      setLoading(true);
      const [{ data: msgs }, { data: r }] = await Promise.all([
        (supabase.from("messages") as any)
          .select("*")
          .eq("chat_id", chatId)
          .order("created_at", { ascending: true }),
        (supabase.from("message_reads") as any)
          .select("message_id, read_at, user_id")
          .eq("chat_id", chatId),
      ]);
      if (cancelled) return;
      setMessages((msgs ?? []) as ChatMessage[]);
      const map: Record<string, string> = {};
      (r ?? []).forEach((row: any) => {
        if (row.user_id === otherUserId) map[row.message_id] = row.read_at;
      });
      setReads(map);
      setLoading(false);
    })();
    return () => {
      cancelled = true;
    };
  }, [chatId, otherUserId]);

  // Realtime subscription: messages (broadcast + postgres_changes), reads, typing presence
  useEffect(() => {
    const channel = supabase.channel(`chat:${chatId}`, {
      config: { broadcast: { self: false }, presence: { key: meId } },
    });

    channel
      // Instant delivery via broadcast (fires before postgres WAL event)
      .on("broadcast", { event: "new_message" }, ({ payload }: { payload: ChatMessage }) => {
        setMessages((prev) => (prev.some((x) => x.id === payload.id) ? prev : [...prev, payload]));
      })
      // Postgres fallback / persistence confirmation
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "messages", filter: `chat_id=eq.${chatId}` },
        (payload) => {
          const m = payload.new as ChatMessage;
          setMessages((prev) => (prev.some((x) => x.id === m.id) ? prev : [...prev, m]));
        },
      )
      .on(
        "postgres_changes",
        { event: "INSERT", schema: "public", table: "message_reads", filter: `chat_id=eq.${chatId}` },
        (payload) => {
          const r = payload.new as { message_id: string; user_id: string; read_at: string };
          if (r.user_id === otherUserId) {
            setReads((prev) => ({ ...prev, [r.message_id]: r.read_at }));
          }
        },
      )
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "message_reads", filter: `chat_id=eq.${chatId}` },
        (payload) => {
          const r = payload.new as { message_id: string; user_id: string; read_at: string };
          if (r.user_id === otherUserId) {
            setReads((prev) => ({ ...prev, [r.message_id]: r.read_at }));
          }
        },
      )
      // Typing-only presence (online status is handled by useGlobalPresence)
      .on("presence", { event: "sync" }, () => {
        const state = channel.presenceState() as Record<string, Array<{ typing?: boolean }>>;
        const typing: Record<string, boolean> = {};
        Object.entries(state).forEach(([userId, metas]) => {
          typing[userId] = metas.some((m) => m.typing);
        });
        setPresence((prev) => ({ ...prev, typing }));
      })
      .on("presence", { event: "join" }, ({ key, newPresences }: { key: string; newPresences: Array<{ typing?: boolean }> }) => {
        setPresence((prev) => ({
          ...prev,
          typing: { ...prev.typing, [key]: newPresences.some((m) => m.typing) },
        }));
      })
      .on("presence", { event: "leave" }, ({ key }: { key: string }) => {
        setPresence((prev) => {
          const typing = { ...prev.typing };
          delete typing[key];
          return { ...prev, typing };
        });
      })
      .subscribe(async (status) => {
        if (status === "SUBSCRIBED") {
          await channel.track({ typing: false });
        }
      });

    channelRef.current = channel;
    return () => {
      supabase.removeChannel(channel);
      channelRef.current = null;
      if (typingTimeoutRef.current) window.clearTimeout(typingTimeoutRef.current);
    };
  }, [chatId, meId, otherUserId]);

  // Send message
  const send = useCallback(
    async (body: string) => {
      const trimmed = body.trim();
      if (!trimmed) return;
      channelRef.current?.track({ typing: false });
      const id = uuidv4();
      const optimistic: ChatMessage = { id, chat_id: chatId, sender_id: meId, body: trimmed, created_at: new Date().toISOString() };
      // Optimistic update for sender; broadcast for instant delivery to receiver
      setMessages((prev) => [...prev, optimistic]);
      channelRef.current?.send({ type: "broadcast", event: "new_message", payload: optimistic });
      const { error } = await (supabase.from("messages") as any)
        .insert({ id, chat_id: chatId, sender_id: meId, body: trimmed });
      if (error) {
        setMessages((prev) => prev.filter((m) => m.id !== id));
        console.error("send failed", error);
        toast.error(error.message || "Failed to send message");
      }
    },
    [chatId, meId],
  );

  // Typing indicator (debounced)
  const setTyping = useCallback(() => {
    const ch = channelRef.current;
    if (!ch) return;
    ch.track({ typing: true });
    if (typingTimeoutRef.current) window.clearTimeout(typingTimeoutRef.current);
    typingTimeoutRef.current = window.setTimeout(() => {
      ch.track({ typing: false });
    }, 2500);
  }, []);

  // Mark unread messages from other user as read
  const markRead = useCallback(async () => {
    const unread = messages.filter(
      (m) => m.sender_id === otherUserId && !reads[m.id],
    );
    if (unread.length === 0) return;
    const rows = unread.map((m) => ({
      message_id: m.id,
      user_id: meId,
      chat_id: chatId,
      read_at: new Date().toISOString(),
    }));
    const { error } = await (supabase.from("message_reads") as any)
      .upsert(rows, { onConflict: "message_id,user_id" });
    if (error) console.error("markRead failed", error);
  }, [messages, otherUserId, reads, meId, chatId]);

  return {
    messages,
    reads,
    loading,
    otherTyping: !!presence.typing[otherUserId],
    send,
    setTyping,
    markRead,
  };
};
