import { useEffect, useRef, useState } from "react";
import { ArrowLeft, Phone, Video, Send, Paperclip, Check, CheckCheck } from "lucide-react";
import { cn } from "@/lib/utils";
import { useRealtimeChat } from "@/hooks/useRealtimeChat";
import type { ChatListItem } from "@/components/screens/MessagesScreen";

interface Props {
  chat: ChatListItem;
  meId: string;
  isOnline: (userId: string) => boolean;
  onBack: () => void;
}

const formatTime = (iso: string) => {
  try {
    return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch {
    return "";
  }
};

export const ChatRoom = ({ chat, meId, isOnline, onBack }: Props) => {
  const [text, setText] = useState("");
  const scrollRef = useRef<HTMLDivElement>(null);
  const { messages, reads, loading, otherTyping, send, setTyping, markRead } =
    useRealtimeChat({ chatId: chat.id, meId, otherUserId: chat.participant.id });
  const otherOnline = isOnline(chat.participant.id);

  // autoscroll on new message / typing
  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages.length, otherTyping]);

  // mark messages read when chat is open or messages arrive
  useEffect(() => {
    markRead();
  }, [messages, markRead]);

  const handleSend = async () => {
    const body = text.trim();
    if (!body) return;
    setText("");
    await send(body);
  };

  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center p-0 sm:p-4 md:p-6 bg-gradient-to-br from-blue-50/80 via-white/60 to-sky-50/80 animate-fade-in">
      {/* Centered chat container */}
      <div className="chat-container">
        {/* Header */}
        <header className="chat-header">
          <button
            onClick={onBack}
            className="h-10 w-10 grid place-items-center rounded-full hover:bg-primary-soft active:scale-95 transition-all shrink-0"
            aria-label="Back"
          >
            <ArrowLeft className="h-5 w-5 text-foreground" strokeWidth={2.4} />
          </button>
          <div className="relative shrink-0">
            <img
              src={chat.participant.avatar_url ?? `https://api.dicebear.com/7.x/avataaars/svg?seed=${chat.participant.id}`}
              alt={chat.participant.first_name}
              className="h-10 w-10 rounded-full bg-secondary ring-2 ring-white object-cover"
            />
            {otherOnline && (
              <span className="absolute bottom-0 right-0 h-2.5 w-2.5 rounded-full bg-success ring-2 ring-white" />
            )}
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-semibold text-foreground leading-tight truncate">
              {chat.participant.first_name} {chat.participant.last_name}
            </p>
            <p className={cn(
              "text-[11px] font-medium",
              otherTyping ? "text-primary" : otherOnline ? "text-success" : "text-muted-foreground"
            )}>
              {otherTyping ? "typing…" : otherOnline ? "Online" : "Offline"}
            </p>
          </div>
          <button className="h-10 w-10 grid place-items-center rounded-full hover:bg-primary-soft text-primary transition-colors" aria-label="Call">
            <Phone className="h-[18px] w-[18px]" strokeWidth={2.2} />
          </button>
          <button className="h-10 w-10 grid place-items-center rounded-full hover:bg-primary-soft text-primary transition-colors" aria-label="Video">
            <Video className="h-[18px] w-[18px]" strokeWidth={2.2} />
          </button>
        </header>

        {/* Messages area */}
        <div ref={scrollRef} className="chat-messages">
          {loading ? (
            <div className="text-center text-muted-foreground text-sm py-8">Loading…</div>
          ) : messages.length === 0 ? (
            <div className="text-center text-muted-foreground text-sm py-8">
              Say hi to {chat.participant.first_name} 👋
            </div>
          ) : (
            <div className="space-y-1">
              {/* Today badge */}
              <div className="flex justify-center py-3">
                <span className="chat-date-badge">Today</span>
              </div>

              {messages.map((m, i) => {
                const sent = m.sender_id === meId;
                const prev = messages[i - 1];
                const groupedWithPrev = prev && prev.sender_id === m.sender_id;
                const next = messages[i + 1];
                const isLastInGroup = !next || next.sender_id !== m.sender_id;
                const wasRead = sent && !!reads[m.id];

                return (
                  <div
                    key={m.id}
                    className={cn(
                      "flex",
                      sent ? "justify-end" : "justify-start",
                      groupedWithPrev ? "mt-[3px]" : "mt-3"
                    )}
                  >
                    <div className={cn("msg-bubble", sent ? "msg-bubble-sent" : "msg-bubble-received")}>
                      <p className="whitespace-pre-wrap break-words">{m.body}</p>
                      <div className="msg-time">
                        <span>{formatTime(m.created_at)}</span>
                        {sent && isLastInGroup && (
                          wasRead ? (
                            <CheckCheck className="h-3.5 w-3.5 text-primary" strokeWidth={2.5} />
                          ) : (
                            <Check className="h-3.5 w-3.5 text-muted-foreground" strokeWidth={2.5} />
                          )
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* Typing bubble */}
          {otherTyping && (
            <div className="flex justify-start mt-2 animate-fade-in">
              <div className="msg-bubble msg-bubble-received">
                <div className="flex items-center gap-1">
                  <span className="h-1.5 w-1.5 rounded-full bg-muted-foreground/60 animate-bounce [animation-delay:-0.3s]" />
                  <span className="h-1.5 w-1.5 rounded-full bg-muted-foreground/60 animate-bounce [animation-delay:-0.15s]" />
                  <span className="h-1.5 w-1.5 rounded-full bg-muted-foreground/60 animate-bounce" />
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Composer */}
        <div className="chat-composer">
          <div className="flex items-center gap-2">
            <div className="flex-1 flex items-center gap-2 bg-white dark:bg-secondary border border-border/60 rounded-full px-4 py-2.5 shadow-sm">
              <input
                value={text}
                onChange={(e) => {
                  setText(e.target.value);
                  setTyping();
                }}
                onKeyDown={(e) => e.key === "Enter" && handleSend()}
                placeholder="Type a message..."
                className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
              />
              <button className="text-muted-foreground hover:text-primary transition-colors" aria-label="Attach">
                <Paperclip className="h-[18px] w-[18px]" strokeWidth={2} />
              </button>
            </div>
            <button
              onClick={handleSend}
              disabled={!text.trim()}
              className="h-10 w-10 grid place-items-center rounded-full bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 disabled:opacity-40 disabled:shadow-none transition-all shrink-0"
              aria-label="Send"
            >
              <Send className="h-[18px] w-[18px]" strokeWidth={2.4} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
