import { useEffect } from "react";
import { Clock, ShieldX, ShieldCheck, LogOut, Loader2 } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";

interface Props {
  status: "pending" | "rejected";
  userId: string;
  signOut: () => void;
  refreshUser: () => Promise<void>;
}

export function VerificationGate({ status, userId, signOut, refreshUser }: Props) {
  // While pending, listen for admin approval on this profile row
  useEffect(() => {
    if (status !== "pending") return;

    const channel = supabase
      .channel(`verify-gate-${userId}`)
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "profiles", filter: `id=eq.${userId}` },
        async (payload) => {
          if ((payload.new as any)?.verification_status === "approved") {
            await refreshUser();
          }
        }
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [status, userId, refreshUser]);

  if (status === "pending") {
    return (
      <div className="min-h-screen gradient-bg flex flex-col items-center justify-center px-6 text-center">
        <div className="glass-strong rounded-3xl p-8 w-full max-w-sm sm:max-w-md space-y-5">
          {/* Animated icon */}
          <div className="mx-auto h-20 w-20 rounded-full bg-yellow-500/10 border-2 border-yellow-500/30 flex items-center justify-center">
            <Clock className="h-9 w-9 text-yellow-500 animate-pulse" />
          </div>

          <div className="space-y-2">
            <h2 className="text-xl font-bold text-foreground">Verification Pending</h2>
            <p className="text-sm text-muted-foreground leading-relaxed">
              Your student ID has been submitted and is waiting for admin review.
              You'll be let in automatically once approved — no need to refresh.
            </p>
          </div>

          {/* Live indicator */}
          <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-yellow-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-yellow-500" />
            </span>
            Listening for approval…
          </div>

          <button
            onClick={signOut}
            className="w-full flex items-center justify-center gap-2 py-2.5 rounded-2xl text-sm font-semibold text-muted-foreground glass hover:text-destructive transition-colors"
          >
            <LogOut className="h-4 w-4" />
            Sign out
          </button>
        </div>
      </div>
    );
  }

  // rejected
  return (
    <div className="min-h-screen gradient-bg flex flex-col items-center justify-center px-6 text-center">
      <div className="glass-strong rounded-3xl p-8 w-full max-w-sm sm:max-w-md space-y-5">
        <div className="mx-auto h-20 w-20 rounded-full bg-destructive/10 border-2 border-destructive/30 flex items-center justify-center">
          <ShieldX className="h-9 w-9 text-destructive" />
        </div>

        <div className="space-y-2">
          <h2 className="text-xl font-bold text-foreground">Verification Rejected</h2>
          <p className="text-sm text-muted-foreground leading-relaxed">
            Your student ID could not be verified. Please contact support or
            sign up again with a clearer photo.
          </p>
        </div>

        <button
          onClick={signOut}
          className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl bg-destructive text-destructive-foreground text-sm font-semibold shadow-sm active:scale-[0.98] transition-all"
        >
          <LogOut className="h-4 w-4" />
          Sign out
        </button>
      </div>
    </div>
  );
}
