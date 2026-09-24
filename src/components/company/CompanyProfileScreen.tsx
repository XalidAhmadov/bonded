import { useEffect, useState } from "react";
import {
  Building2, LogOut, Pencil, Save, X, Loader2,
  Calendar, FileText, Moon, Sun,
} from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { useAuth } from "@/hooks/useAuth";
import { useDarkMode } from "@/hooks/useDarkMode";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

interface CompanyProfile {
  first_name: string;   // stores the company name
  bio: string | null;
  founded_date: string | null;
}

export const CompanyProfileScreen = () => {
  const { user, signOut } = useAuth();
  const { isDark, toggle: toggleDark } = useDarkMode();
  const [p, setP] = useState<CompanyProfile | null>(null);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  const [editBio, setEditBio] = useState("");
  const [editFounded, setEditFounded] = useState("");

  useEffect(() => {
    if (!user?.id) return;
    (supabase.from("profiles") as any)
      .select("first_name, bio, founded_date")
      .eq("id", user.id)
      .maybeSingle()
      .then(({ data, error }: { data: CompanyProfile | null; error: any }) => {
        if (error) { console.error("[CompanyProfile]", error); return; }
        setP(data);
        if (data) {
          setEditBio(data.bio ?? "");
          setEditFounded(data.founded_date ?? "");
        }
      });
  }, [user]);

  const startEditing = () => {
    if (p) {
      setEditBio(p.bio ?? "");
      setEditFounded(p.founded_date ?? "");
    }
    setEditing(true);
  };

  const cancelEditing = () => {
    if (p) {
      setEditBio(p.bio ?? "");
      setEditFounded(p.founded_date ?? "");
    }
    setEditing(false);
  };

  const saveProfile = async () => {
    if (!user?.id) return;
    setSaving(true);
    try {
      const { error } = await (supabase.from("profiles") as any)
        .update({
          bio:          editBio.trim() || null,
          founded_date: editFounded.trim() || null,
        })
        .eq("id", user.id);
      if (error) throw error;
      setP((prev) =>
        prev
          ? { ...prev, bio: editBio.trim() || null, founded_date: editFounded.trim() || null }
          : prev
      );
      setEditing(false);
      toast.success("Profile updated!");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to save");
    } finally {
      setSaving(false);
    }
  };

  if (!p) {
    return (
      <div className="h-[60vh] grid place-items-center">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="animate-fade-in pb-10">
      <AppHeader
        subtitle="Company"
        title="Profile"
        right={
          <div className="flex items-center gap-2">
            {!editing && (
              <button
                onClick={startEditing}
                className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
                aria-label="Edit profile"
              >
                <Pencil className="h-[18px] w-[18px] text-primary" strokeWidth={2.2} />
              </button>
            )}
            <button
              onClick={toggleDark}
              className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
            >
              {isDark ? (
                <Sun className="h-[18px] w-[18px] text-amber-400" strokeWidth={2.2} />
              ) : (
                <Moon className="h-[18px] w-[18px] text-foreground" strokeWidth={2.2} />
              )}
            </button>
            <button
              onClick={signOut}
              className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
              aria-label="Sign out"
            >
              <LogOut className="h-[18px] w-[18px] text-foreground" strokeWidth={2.2} />
            </button>
          </div>
        }
      />

      <div className="px-5 mt-4 max-w-2xl mx-auto">
        {editing ? (
          /* ─── Edit Mode ─── */
          <div className="glass-strong rounded-[2.5rem] p-6 relative overflow-hidden space-y-4">
            <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
            <div className="relative space-y-4">
              {/* Company Name — READ ONLY */}
              <div className="flex flex-col items-center gap-2 text-center">
                <div className="h-20 w-20 rounded-full bg-gradient-primary p-[3px] shadow-glow grid place-items-center">
                  <Building2 className="h-9 w-9 text-primary-foreground" strokeWidth={1.8} />
                </div>
                <h2 className="text-2xl font-bold text-foreground">{p.first_name}</h2>
                <p className="text-xs text-muted-foreground">Company name cannot be changed</p>
              </div>

              {/* Founded date — EDITABLE */}
              <div>
                <label className="text-xs font-semibold text-primary mb-1 flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  Founded Date (editable)
                </label>
                <input
                  type="text"
                  value={editFounded}
                  onChange={(e) => setEditFounded(e.target.value)}
                  placeholder="e.g. 2018, March 2020"
                  className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              {/* Bio — EDITABLE */}
              <div>
                <label className="text-xs font-semibold text-primary mb-1 flex items-center gap-1">
                  <Pencil className="h-3 w-3" />
                  Bio (editable)
                </label>
                <textarea
                  value={editBio}
                  onChange={(e) => setEditBio(e.target.value)}
                  placeholder="Tell us about your company…"
                  rows={5}
                  maxLength={500}
                  className="w-full bg-secondary rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
                />
                <p className="text-[10px] text-muted-foreground text-right mt-0.5">
                  {editBio.length}/500
                </p>
              </div>

              {/* Actions */}
              <div className="grid grid-cols-2 gap-2 pt-2">
                <button
                  onClick={cancelEditing}
                  className="flex items-center justify-center gap-1.5 py-3 rounded-xl font-semibold text-sm bg-secondary text-foreground hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors active:scale-95"
                >
                  <X className="h-4 w-4" />
                  Cancel
                </button>
                <button
                  onClick={saveProfile}
                  disabled={saving}
                  className="flex items-center justify-center gap-1.5 py-3 rounded-xl font-semibold text-sm bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 disabled:opacity-60 transition-all"
                >
                  {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                  Save
                </button>
              </div>
            </div>
          </div>
        ) : (
          /* ─── View Mode ─── */
          <div className="glass-strong rounded-[2.5rem] p-8 text-center relative overflow-hidden">
            <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
            <div className="relative">
              {/* Company icon */}
              <div className="mx-auto h-28 w-28 rounded-full bg-gradient-primary p-[3px] shadow-glow grid place-items-center">
                <Building2 className="h-12 w-12 text-primary-foreground" strokeWidth={1.6} />
              </div>

              <h2 className="mt-5 text-3xl font-bold tracking-tight text-foreground">
                {p.first_name}
              </h2>

              {p.founded_date && (
                <div className="mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary-soft">
                  <Calendar className="h-4 w-4 text-primary" strokeWidth={2.4} />
                  <span className="text-sm font-bold text-primary tracking-wide">
                    Founded {p.founded_date}
                  </span>
                </div>
              )}

              <div className="mt-2 inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-secondary ml-2">
                <Building2 className="h-3.5 w-3.5 text-muted-foreground" strokeWidth={2} />
                <span className="text-xs font-semibold text-muted-foreground">Company Account</span>
              </div>

              {p.bio && (
                <p className="mt-5 text-sm text-foreground/80 leading-relaxed max-w-prose mx-auto">
                  {p.bio}
                </p>
              )}

              {!p.bio && !p.founded_date && (
                <p className="mt-4 text-sm text-muted-foreground">
                  Tap the edit button to add your company bio and founded date.
                </p>
              )}

              {/* Email (read-only info) */}
              {(user as any)?.email && (
                <div className="mt-5 flex items-center justify-center gap-2">
                  <span className="text-xs text-muted-foreground">{(user as any).email}</span>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
