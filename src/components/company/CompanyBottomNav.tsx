import { Briefcase, Search, User } from "lucide-react";
import { cn } from "@/lib/utils";

export type CompanyTab = "jobs" | "search" | "profile";

interface CompanyBottomNavProps {
  active: CompanyTab;
  onChange: (tab: CompanyTab) => void;
}

const tabs: { id: CompanyTab; label: string; Icon: typeof Briefcase }[] = [
  { id: "jobs",    label: "Jobs",    Icon: Briefcase },
  { id: "search",  label: "Students", Icon: Search },
  { id: "profile", label: "Profile",  Icon: User },
];

export const CompanyBottomNav = ({ active, onChange }: CompanyBottomNavProps) => (
  <nav className="fixed bottom-0 inset-x-0 z-50 px-3 pb-3 pt-2 safe-bottom">
    <div className="glass-strong mx-auto w-full max-w-md sm:max-w-lg md:max-w-xl rounded-3xl px-2.5 py-2 shadow-glass">
      <ul className="grid grid-cols-3 gap-1">
        {tabs.map(({ id, label, Icon }) => {
          const isActive = active === id;
          return (
            <li key={id}>
              <button
                type="button"
                onClick={() => onChange(id)}
                aria-label={label}
                aria-current={isActive ? "page" : undefined}
                className={cn(
                  "w-full flex flex-col items-center gap-1 rounded-2xl py-2 px-1 transition-all duration-300",
                  isActive
                    ? "bg-gradient-primary text-primary-foreground shadow-glow scale-[1.02]"
                    : "text-muted-foreground hover:text-primary hover:bg-primary-soft"
                )}
              >
                <Icon className={cn("transition-all", isActive ? "h-5 w-5" : "h-[22px] w-[22px]")} strokeWidth={isActive ? 2.4 : 2} />
                <span className={cn("text-[10px] font-semibold tracking-wide", isActive ? "opacity-100" : "opacity-80")}>
                  {label}
                </span>
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  </nav>
);
