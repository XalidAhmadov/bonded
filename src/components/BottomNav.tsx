import { MessageCircle, Users, Briefcase, User, Globe2 } from "lucide-react";
import { cn } from "@/lib/utils";

export type Tab = "network" | "groups" | "messages" | "jobs" | "profile";

interface BottomNavProps {
  active: Tab;
  onChange: (tab: Tab) => void;
  friendRequestCount?: number;
  unreadMessageCount?: number;
  unreadSenderCount?: number;
  groupInvitationCount?: number;
}

const tabs: { id: Tab; label: string; Icon: typeof MessageCircle }[] = [
  { id: "network",  label: "Network",  Icon: Globe2 },
  { id: "groups",   label: "Groups",   Icon: Users },
  { id: "messages", label: "Messages", Icon: MessageCircle },
  { id: "jobs",     label: "Jobs",     Icon: Briefcase },
  { id: "profile",  label: "Profile",  Icon: User },
];

export const BottomNav = ({ active, onChange, friendRequestCount = 0, unreadMessageCount = 0, unreadSenderCount = 0, groupInvitationCount = 0 }: BottomNavProps) => {
  const badgeCount = (id: Tab): number => {
    if (id === "network") return friendRequestCount;
    if (id === "messages") return unreadMessageCount;
    if (id === "groups") return groupInvitationCount;
    return 0;
  };

  return (
    <nav className="fixed bottom-0 inset-x-0 z-50 px-3 pb-3 pt-2 safe-bottom pointer-events-none">
      {/* Unread sender indicator above the nav bar */}
      {unreadSenderCount > 0 && active !== "messages" && (
        <div className="mx-auto w-full max-w-md sm:max-w-lg mb-2 pointer-events-auto animate-slide-up">
          <button
            onClick={() => onChange("messages")}
            className="w-full flex items-center justify-center gap-2 py-2 px-4 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold text-xs shadow-glow active:scale-[0.98] transition-all"
          >
            <MessageCircle className="h-3.5 w-3.5" />
            {unreadSenderCount === 1
              ? "1 person sent new messages"
              : `${unreadSenderCount} people sent new messages`}
          </button>
        </div>
      )}
      <div className="glass-strong mx-auto w-full max-w-md sm:max-w-lg md:max-w-xl rounded-3xl px-2.5 py-2 pointer-events-auto shadow-glass">
        <ul className="grid grid-cols-5 gap-1">
          {tabs.map(({ id, label, Icon }) => {
            const isActive = active === id;
            const count = badgeCount(id);
            return (
              <li key={id}>
                <button
                  type="button"
                  onClick={() => onChange(id)}
                  aria-label={label}
                  aria-current={isActive ? "page" : undefined}
                  className={cn(
                    "w-full flex flex-col items-center gap-1 rounded-2xl py-2 px-1 transition-all duration-300 relative",
                    isActive
                      ? "bg-gradient-primary text-primary-foreground shadow-glow scale-[1.02]"
                      : "text-muted-foreground hover:text-primary hover:bg-primary-soft"
                  )}
                >
                  <Icon className={cn("transition-all", isActive ? "h-5 w-5" : "h-[22px] w-[22px]")} strokeWidth={isActive ? 2.4 : 2} />
                  <span className={cn("text-[10px] font-semibold tracking-wide", isActive ? "opacity-100" : "opacity-80")}>
                    {label}
                  </span>
                  {count > 0 && (
                    <span className="absolute -top-1 -right-0.5 h-[18px] min-w-[18px] px-1 rounded-full bg-destructive text-destructive-foreground text-[9px] font-bold grid place-items-center shadow-sm">
                      {count > 99 ? "99+" : count}
                    </span>
                  )}
                </button>
              </li>
            );
          })}
        </ul>
      </div>
    </nav>
  );
};
