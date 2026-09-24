import { cn } from "@/lib/utils";

interface AppHeaderProps {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
  className?: string;
}

export const AppHeader = ({ title, subtitle, right, className }: AppHeaderProps) => (
  <header className={cn("safe-top px-5 pt-4 pb-3 flex items-end justify-between gap-3", className)}>
    <div>
      {subtitle && <p className="text-xs font-semibold uppercase tracking-[0.14em] text-primary/80">{subtitle}</p>}
      {title && <h1 className="text-3xl font-bold tracking-tight text-foreground">{title}</h1>}
    </div>
    {right}
  </header>
);
