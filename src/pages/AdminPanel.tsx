import { useEffect, useState } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import { Check, X, Clock, ArrowLeft, Loader2, ShieldCheck, AlertCircle } from "lucide-react";

interface VerificationRequest {
  id: string;
  user_id: string;
  first_name: string;
  last_name: string;
  university: string;
  image_data: string;
  status: string;
  created_at: string;
  reviewer_note: string | null;
}

const STATUS_COLORS: Record<string, string> = {
  pending: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/40 dark:text-yellow-300",
  approved: "bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300",
  rejected: "bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-300",
};

const STATUS_ICONS: Record<string, React.ReactNode> = {
  pending: <Clock className="h-3 w-3" />,
  approved: <Check className="h-3 w-3" />,
  rejected: <X className="h-3 w-3" />,
};

interface Props {
  /** When provided the panel renders as an overlay; back button calls this instead of navigate */
  onBack?: () => void;
}

export default function AdminPanel({ onBack }: Props = {}) {
  const { user, loading } = useAuth();
  const navigate = useNavigate();
  const [requests, setRequests] = useState<VerificationRequest[]>([]);
  const [fetching, setFetching] = useState(true);
  const [actionId, setActionId] = useState<string | null>(null);
  const [rejectNotes, setRejectNotes] = useState<Record<string, string>>({});
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [filter, setFilter] = useState<"all" | "pending" | "approved" | "rejected">("pending");
  const [fullscreenImage, setFullscreenImage] = useState<string | null>(null);

  const fetchRequests = async () => {
    const { data, error } = await (supabase.from("verification_requests") as any)
      .select("*")
      .order("created_at", { ascending: false });

    if (!error) setRequests(data ?? []);
    setFetching(false);
  };

  useEffect(() => {
    if (!user) return;
    fetchRequests();

    const channel = supabase
      .channel("admin-verification")
      .on("postgres_changes", { event: "*", schema: "public", table: "verification_requests" }, fetchRequests)
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [user]);

  const approve = async (req: VerificationRequest) => {
    setActionId(req.id);
    try {
      await (supabase.from("verification_requests") as any)
        .update({ status: "approved", reviewed_at: new Date().toISOString() })
        .eq("id", req.id);
      await (supabase.from("profiles") as any)
        .update({ verification_status: "approved" })
        .eq("id", req.user_id);
      toast.success(`✓ Approved successfully — ${req.first_name} ${req.last_name}`);
    } catch {
      toast.error("Action failed");
    } finally {
      setActionId(null);
    }
  };

  const reject = async (req: VerificationRequest) => {
    setActionId(req.id);
    const note = rejectNotes[req.id] ?? "";
    try {
      await (supabase.from("verification_requests") as any)
        .update({ status: "rejected", reviewed_at: new Date().toISOString(), reviewer_note: note || null })
        .eq("id", req.id);
      await (supabase.from("profiles") as any)
        .update({ verification_status: "rejected" })
        .eq("id", req.user_id);
      toast.error(`✗ Rejected — ${req.first_name} ${req.last_name}`);
    } catch {
      toast.error("Action failed");
    } finally {
      setActionId(null);
    }
  };

  const handleBack = () => (onBack ? onBack() : navigate("/"));

  // Standalone page guards (skipped when used as overlay inside Index)
  if (!onBack) {
    if (loading) {
      return (
        <div className="min-h-screen gradient-bg grid place-items-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      );
    }
    if (!user) return <Navigate to="/auth" replace />;
    if (!(user as any).is_admin) {
      return (
        <div className="min-h-screen gradient-bg grid place-items-center px-5">
          <div className="glass-strong rounded-3xl p-8 max-w-sm sm:max-w-md w-full text-center space-y-4">
            <AlertCircle className="h-10 w-10 text-destructive mx-auto" />
            <h2 className="text-xl font-bold">Access Denied</h2>
            <p className="text-sm text-muted-foreground">You don't have admin privileges.</p>
            <button onClick={handleBack} className="w-full py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold">
              Go Back
            </button>
          </div>
        </div>
      );
    }
  }

  const filtered = filter === "all" ? requests : requests.filter((r) => r.status === filter);
  const counts = {
    all: requests.length,
    pending: requests.filter((r) => r.status === "pending").length,
    approved: requests.filter((r) => r.status === "approved").length,
    rejected: requests.filter((r) => r.status === "rejected").length,
  };

  return (
    <>
    {/* Fullscreen photo viewer */}
    {fullscreenImage && (
      <div
        className="fixed inset-0 z-[100] bg-black/95 flex items-center justify-center p-4 animate-fade-in"
        onClick={() => setFullscreenImage(null)}
      >
        <button
          className="absolute top-4 right-4 h-10 w-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
          onClick={() => setFullscreenImage(null)}
        >
          <X className="h-5 w-5" />
        </button>
        <img
          src={fullscreenImage}
          alt="Student ID"
          className="max-w-full max-h-full object-contain rounded-2xl shadow-2xl"
          onClick={(e) => e.stopPropagation()}
        />
        <p className="absolute bottom-6 text-white/50 text-xs">Tap anywhere to close</p>
      </div>
    )}

    <div className="min-h-screen gradient-bg overflow-auto">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 py-6 pb-16">
        {/* Header */}
        <div className="flex items-center gap-3 mb-6">
          <button
            onClick={handleBack}
            className="h-9 w-9 rounded-2xl glass flex items-center justify-center text-muted-foreground hover:text-primary transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <h1 className="text-xl font-bold flex items-center gap-2">
              <ShieldCheck className="h-5 w-5 text-primary" />
              Verification Admin
            </h1>
            <p className="text-xs text-muted-foreground">{counts.pending} pending review</p>
          </div>
        </div>

        {/* Filter tabs */}
        <div className="flex gap-2 mb-4 overflow-x-auto pb-1">
          {(["pending", "approved", "rejected", "all"] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`flex-shrink-0 px-3 py-1.5 rounded-xl text-xs font-semibold capitalize transition-all ${
                filter === f
                  ? "bg-gradient-primary text-primary-foreground shadow-glow"
                  : "glass text-muted-foreground hover:text-primary"
              }`}
            >
              {f} ({counts[f]})
            </button>
          ))}
        </div>

        {/* Request list */}
        {fetching ? (
          <div className="flex justify-center py-12">
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="glass-strong rounded-3xl p-10 text-center text-muted-foreground text-sm">
            No {filter === "all" ? "" : filter} requests.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3.5">
            {filtered.map((req) => {
              const isExpanded = expandedId === req.id;
              const isActing = actionId === req.id;
              return (
                <div key={req.id} className="glass-strong rounded-3xl overflow-hidden">
                  <button
                    className="w-full flex items-center gap-3 p-4 text-left"
                    onClick={() => setExpandedId(isExpanded ? null : req.id)}
                  >
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-sm truncate">{req.first_name} {req.last_name}</p>
                      <p className="text-xs text-muted-foreground truncate">{req.university}</p>
                      <p className="text-[10px] text-muted-foreground mt-0.5">
                        {new Date(req.created_at).toLocaleString()}
                      </p>
                    </div>
                    <span className={`flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold capitalize flex-shrink-0 ${STATUS_COLORS[req.status]}`}>
                      {STATUS_ICONS[req.status]}
                      {req.status}
                    </span>
                  </button>

                  {isExpanded && (
                    <div className="px-4 pb-4 space-y-3 border-t border-border/40 pt-3">
                      <img
                        src={req.image_data}
                        alt="Student ID"
                        className="w-full rounded-2xl object-contain max-h-64 bg-secondary cursor-zoom-in active:scale-[0.98] transition-transform"
                        onClick={() => setFullscreenImage(req.image_data)}
                        title="Tap to view full screen"
                      />
                      {req.reviewer_note && (
                        <p className="text-xs text-muted-foreground italic">Note: {req.reviewer_note}</p>
                      )}
                      {req.status === "pending" && (
                        <div className="space-y-2">
                          <input
                            type="text"
                            placeholder="Rejection reason (optional)"
                            value={rejectNotes[req.id] ?? ""}
                            onChange={(e) => setRejectNotes((prev) => ({ ...prev, [req.id]: e.target.value }))}
                            className="w-full bg-secondary rounded-xl px-3 py-2 text-xs outline-none focus:ring-2 focus:ring-primary/40"
                          />
                          <div className="flex gap-2">
                            <button
                              onClick={() => approve(req)}
                              disabled={isActing}
                              className="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-2xl bg-green-500 text-white text-sm font-semibold hover:bg-green-600 active:scale-[0.98] disabled:opacity-60 transition-all"
                            >
                              {isActing ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
                              Approve
                            </button>
                            <button
                              onClick={() => reject(req)}
                              disabled={isActing}
                              className="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-2xl bg-destructive text-destructive-foreground text-sm font-semibold hover:opacity-90 active:scale-[0.98] disabled:opacity-60 transition-all"
                            >
                              {isActing ? <Loader2 className="h-4 w-4 animate-spin" /> : <X className="h-4 w-4" />}
                              Reject
                            </button>
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
    </>
  );
}
