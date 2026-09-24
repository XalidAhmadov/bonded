import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  GraduationCap,
  BookOpen,
  LogOut,
  Loader2,
  Pencil,
  Save,
  X,
  Briefcase,
  Trophy,
  Moon,
  Sun,
  Tags,
  ShieldCheck,
  Clock,
  AlertCircle,
  Lock,
  Globe,
} from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { FieldChips, FieldPickerModal } from "@/components/FieldPicker";
import { useAuth } from "@/hooks/useAuth";
import { useDarkMode } from "@/hooks/useDarkMode";
import { useProfileFields, useSaveProfileFields } from "@/hooks/useProfileFields";
import { supabase } from "@/integrations/supabase/client";
import { triggerProfileEmbed } from "@/lib/embedProfile";
import { toast } from "sonner";

const AVATAR_OPTIONS = [
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Jasper",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Luna",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Lily",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Max",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Mia",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Oscar",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Sofia",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Liam",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Emma",
  "https://api.dicebear.com/7.x/avataaars/svg?seed=Noah",
];

interface Profile {
  first_name: string;
  last_name: string;
  university_id: string | null;
  universities: { name: string } | null;
  specialty_id: string | null;
  specialties: { name: string } | null;
  year: string | null;
  avatar_url: string | null;
  bio: string | null;
  profession: string | null;
  entrance_score: number | null;
  message_privacy: "all" | "only_friends";
}

interface ProfileScreenProps {
  onOpenAdmin?: () => void;
}

export const ProfileScreen = ({ onOpenAdmin }: ProfileScreenProps = {}) => {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const { isDark, toggle: toggleDark } = useDarkMode();
  const [p, setP] = useState<Profile | null>(null);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [privacySaving, setPrivacySaving] = useState(false);

  const [editBio, setEditBio] = useState("");
  const [editAvatarUrl, setEditAvatarUrl] = useState<string | null>(null);
  const [editFieldIds, setEditFieldIds] = useState<string[]>([]);
  const [showFieldPicker, setShowFieldPicker] = useState(false);

  const { data: profileFields = [] } = useProfileFields(user?.id);
  const saveFieldsMutation = useSaveProfileFields();

  useEffect(() => {
    if (!user?.id) return;

    (supabase.from("profiles") as any)
      .select(
        "first_name,last_name,university_id,universities(name),specialty_id,specialties(name),year,avatar_url,bio,profession,entrance_score,message_privacy"
      )
      .eq("id", user.id)
      .maybeSingle()
      .then(({ data, error }: { data: Profile | null; error: any }) => {
        if (error) { console.error("[ProfileScreen] fetch error:", error); return; }
        // Default to 'all' if column doesn't exist yet
        if (data && !data.message_privacy) data.message_privacy = "all";
        setP(data);
        if (data) {
          setEditBio(data.bio ?? "");
        }
      });
  }, [user]);

  const setMessagePrivacy = async (value: "all" | "only_friends") => {
    if (!user?.id || !p) return;
    setPrivacySaving(true);
    try {
      const { error } = await (supabase.from("profiles") as any)
        .update({ message_privacy: value })
        .eq("id", user.id);
      if (error) throw error;
      setP((prev) => prev ? { ...prev, message_privacy: value } : prev);
      toast.success(value === "all" ? "Anyone can message you" : "Only friends can message you");
    } catch (e: any) {
      toast.error(e.message ?? "Failed to update privacy");
    } finally {
      setPrivacySaving(false);
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem("bonded_user_id");
    navigate("/auth", { replace: true });
    window.location.reload();
  };

  const startEditing = () => {
    if (p) {
      setEditBio(p.bio ?? "");
      setEditAvatarUrl(p.avatar_url);
      setEditFieldIds(profileFields.map((f) => f.field_id));
    }
    setEditing(true);
  };

  const cancelEditing = () => {
    if (p) {
      setEditBio(p.bio ?? "");
      setEditAvatarUrl(p.avatar_url);
      setEditFieldIds(profileFields.map((f) => f.field_id));
    }
    setEditing(false);
  };

  const saveProfile = async () => {
    if (!user?.id) return;
    setSaving(true);
    try {
      const { error } = await (supabase.from("profiles") as any)
        .update({
          bio: editBio.trim() || null,
          avatar_url: editAvatarUrl,
        })
        .eq("id", user.id);
      if (error) throw error;
      await saveFieldsMutation.mutateAsync({ userId: user.id, fieldIds: editFieldIds });
      triggerProfileEmbed(user.id);
      setP((prev) =>
        prev ? {
          ...prev,
          bio: editBio.trim() || null,
          avatar_url: editAvatarUrl,
        } : prev
      );
      setEditing(false);
      toast.success("Profile updated! ✨");
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

  const avatar =
    p.avatar_url ??
    `https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.id ?? "me"}`;

  return (
    <div className="animate-fade-in pb-10">
      <AppHeader
        subtitle="Account"
        title="Profile"
        right={
          <div className="flex items-center gap-2">
            {!editing && (
              <button
                onClick={startEditing}
                className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
                aria-label="Edit profile"
              >
                <Pencil
                  className="h-[18px] w-[18px] text-primary"
                  strokeWidth={2.2}
                />
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
              onClick={handleSignOut}
              className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform"
            >
              <LogOut
                className="h-[18px] w-[18px] text-foreground"
                strokeWidth={2.2}
              />
            </button>
          </div>
        }
      />

      {/* Verification status banner */}
      {(user as any)?.verification_status !== "approved" && (
        <div className="px-5 mt-3">
          {(user as any)?.verification_status === "rejected" ? (
            <div className="flex items-center gap-2.5 px-4 py-3 rounded-2xl bg-destructive/10 border border-destructive/20 text-destructive text-xs font-semibold">
              <AlertCircle className="h-4 w-4 flex-shrink-0" />
              ID verification rejected. Please contact admin.
            </div>
          ) : (
            <div className="flex items-center gap-2.5 px-4 py-3 rounded-2xl bg-yellow-500/10 border border-yellow-500/20 text-yellow-600 dark:text-yellow-400 text-xs font-semibold">
              <Clock className="h-4 w-4 flex-shrink-0" />
              ID verification pending admin review.
            </div>
          )}
        </div>
      )}

      {/* Admin panel link */}
      {(user as any)?.is_admin && onOpenAdmin && (
        <div className="px-5 mt-3">
          <button
            onClick={onOpenAdmin}
            className="w-full flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground text-sm font-semibold shadow-glow active:scale-[0.98] transition-all"
          >
            <ShieldCheck className="h-4 w-4" />
            Open Admin Panel
          </button>
        </div>
      )}

      <div className="px-5 mt-4 max-w-2xl mx-auto">
        {editing ? (
          /* ─── Edit Mode: Bio Only ─── */
          <div className="glass-strong rounded-[2.5rem] p-6 relative overflow-hidden">
            <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
            <div className="relative space-y-4">
              {/* Avatar picker */}
              <div className="flex flex-col items-center gap-3">
                <div className="h-20 w-20 rounded-full bg-gradient-primary p-[3px] shadow-glow">
                  <img
                    src={
                      editAvatarUrl ??
                      `https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.id ?? "me"}`
                    }
                    alt={p.first_name}
                    className="h-full w-full rounded-full bg-white object-cover"
                  />
                </div>
                <div>
                  <p className="text-xs font-semibold text-muted-foreground mb-2 text-center">
                    Choose avatar
                  </p>
                  <div
                    className="flex gap-2 overflow-x-auto pb-1"
                    style={{ scrollbarWidth: "none" }}
                  >
                    {AVATAR_OPTIONS.map((url) => (
                      <button
                        key={url}
                        type="button"
                        onClick={() => setEditAvatarUrl(url)}
                        className={`flex-shrink-0 h-11 w-11 rounded-full overflow-hidden border-2 transition-all bg-white ${
                          editAvatarUrl === url
                            ? "border-primary shadow-glow scale-110"
                            : "border-transparent opacity-60 hover:opacity-90"
                        }`}
                      >
                        <img src={url} alt="avatar option" className="h-full w-full" />
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Name — READ ONLY */}
              <div className="text-center">
                <h2 className="text-2xl font-bold text-foreground">
                  {p.first_name} <span className="text-primary">{p.last_name}</span>
                </h2>
                <p className="text-xs text-muted-foreground mt-1">
                  Name, university, and other fields cannot be changed
                </p>
              </div>

              {/* Read-only fields displayed as info */}
              <div className="grid grid-cols-2 gap-2">
                <div className="bg-secondary/60 rounded-xl px-3 py-2.5">
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">University</p>
                  <p className="text-sm text-foreground font-medium truncate">{p.universities?.name ?? ""}</p>
                </div>
                {p.specialties?.name && (
                  <div className="bg-secondary/60 rounded-xl px-3 py-2.5">
                    <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Major</p>
                    <p className="text-sm text-foreground font-medium truncate">{p.specialties.name}</p>
                  </div>
                )}
                {p.profession && (
                  <div className="bg-secondary/60 rounded-xl px-3 py-2.5">
                    <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Profession</p>
                    <p className="text-sm text-foreground font-medium truncate">{p.profession}</p>
                  </div>
                )}
                {p.entrance_score != null && p.entrance_score > 0 && (
                  <div className="bg-secondary/60 rounded-xl px-3 py-2.5">
                    <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Entrance Score</p>
                    <p className="text-sm text-foreground font-medium truncate">{p.entrance_score}</p>
                  </div>
                )}
                {p.year && (
                  <div className="bg-secondary/60 rounded-xl px-3 py-2.5">
                    <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Year</p>
                    <p className="text-sm text-foreground font-medium truncate">{p.year}</p>
                  </div>
                )}
              </div>

              {/* Bio — EDITABLE */}
              <div>
                <label className="text-xs font-semibold text-primary mb-1 block flex items-center gap-1">
                  <Pencil className="h-3 w-3" />
                  Bio (editable)
                </label>
                <textarea
                  value={editBio}
                  onChange={(e) => setEditBio(e.target.value)}
                  placeholder="Tell us about yourself…"
                  rows={4}
                  maxLength={300}
                  className="w-full bg-secondary rounded-xl px-3 py-2.5 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
                />
                <p className="text-[10px] text-muted-foreground text-right mt-0.5">
                  {editBio.length}/300
                </p>
              </div>

              {/* Fields — EDITABLE */}
              <div>
                <label className="text-xs font-semibold text-primary mb-1 block flex items-center gap-1">
                  <Tags className="h-3 w-3" />
                  Fields (editable)
                </label>
                <FieldChips
                  selectedIds={editFieldIds}
                  onRemove={(id) => setEditFieldIds((prev) => prev.filter((f) => f !== id))}
                  onOpenPicker={() => setShowFieldPicker(true)}
                />
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
                  {saving ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Save className="h-4 w-4" />
                  )}
                  Save
                </button>
              </div>
            </div>
          </div>
        ) : (
          /* ─── View Mode ─── */
          <>
            <div className="glass-strong rounded-[2.5rem] p-8 text-center relative overflow-hidden">
              <div className="absolute -top-16 -right-16 h-40 w-40 rounded-full bg-primary/20 blur-3xl" />
              <div className="relative">
                <div className="mx-auto h-28 w-28 rounded-full bg-gradient-primary p-[3px] shadow-glow">
                  <img
                    src={avatar}
                    alt={p.first_name}
                    className="h-full w-full rounded-full bg-white object-cover"
                  />
                </div>

                <h2 className="mt-5 text-3xl font-bold tracking-tight text-foreground">
                  {p.first_name}{" "}
                  <span className="text-primary">{p.last_name}</span>
                </h2>

                {p.profession && (
                  <div className="mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-accent">
                    <Briefcase
                      className="h-4 w-4 text-primary"
                      strokeWidth={2.4}
                    />
                    <span className="text-sm font-bold text-primary tracking-wide">
                      {p.profession}
                    </span>
                  </div>
                )}

                {p.universities?.name && (
                  <div className="mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary-soft">
                    <GraduationCap
                      className="h-4 w-4 text-primary"
                      strokeWidth={2.4}
                    />
                    <span className="text-sm font-bold text-primary tracking-wide">
                      {p.universities.name}
                    </span>
                  </div>
                )}

                {(p.specialties?.name || p.year) && (
                  <div className="mt-3 flex items-center justify-center gap-2 text-sm text-muted-foreground">
                    <BookOpen className="h-3.5 w-3.5" />
                    <span className="font-medium">
                      {[p.specialties?.name, p.year].filter(Boolean).join(" · ")}
                    </span>
                  </div>
                )}

                {p.entrance_score != null && p.entrance_score > 0 && (
                  <div className="mt-3 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-amber-50 dark:bg-amber-950/50">
                    <Trophy
                      className="h-4 w-4 text-amber-500"
                      strokeWidth={2.4}
                    />
                    <span className="text-sm font-bold text-amber-600 dark:text-amber-400 tracking-wide">
                      Entrance Score: {p.entrance_score}
                    </span>
                  </div>
                )}

                {p.bio && (
                  <p className="mt-5 text-sm text-foreground/80 leading-relaxed max-w-prose mx-auto">
                    {p.bio}
                  </p>
                )}

                {/* Fields — inside the profile card */}
                {profileFields.length > 0 && (
                  <div className="mt-6">
                    <h3 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-3 flex items-center justify-center gap-1.5">
                      <Tags className="h-3.5 w-3.5" />
                      Fields
                    </h3>
                    <div className="flex flex-wrap gap-2 justify-center">
                      {profileFields.map((f) => (
                        <span
                          key={f.field_id}
                          className="px-4 py-2 rounded-2xl bg-secondary text-foreground text-sm font-medium"
                        >
                          <span className="text-[9px] font-bold uppercase tracking-wide text-muted-foreground mr-1">
                            {f.category_label} ·
                          </span>
                          {f.label}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* ─── Message Privacy Setting ─── */}
            <div className="mt-4 glass-strong rounded-2xl p-4">
              <div className="flex items-center gap-2 mb-3">
                <Lock className="h-4 w-4 text-muted-foreground" />
                <p className="text-sm font-bold text-foreground">Message Privacy</p>
              </div>
              <p className="text-xs text-muted-foreground mb-3">
                Control who can send you direct messages.
              </p>
              <div className="grid grid-cols-2 gap-2">
                <button
                  id="privacy-all-btn"
                  onClick={() => !privacySaving && setMessagePrivacy("all")}
                  disabled={privacySaving}
                  className={`flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm transition-all active:scale-95 disabled:opacity-60 ${
                    (p.message_privacy ?? "all") === "all"
                      ? "bg-gradient-primary text-primary-foreground shadow-glow"
                      : "bg-secondary text-muted-foreground hover:bg-primary-soft hover:text-primary"
                  }`}
                >
                  <Globe className="h-4 w-4" />
                  All
                </button>
                <button
                  id="privacy-friends-btn"
                  onClick={() => !privacySaving && setMessagePrivacy("only_friends")}
                  disabled={privacySaving}
                  className={`flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm transition-all active:scale-95 disabled:opacity-60 ${
                    p.message_privacy === "only_friends"
                      ? "bg-gradient-primary text-primary-foreground shadow-glow"
                      : "bg-secondary text-muted-foreground hover:bg-primary-soft hover:text-primary"
                  }`}
                >
                  {privacySaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Lock className="h-4 w-4" />}
                  Only Friends
                </button>
              </div>
              {p.message_privacy === "only_friends" && (
                <p className="text-[11px] text-muted-foreground mt-2 text-center">
                  Only people you've accepted as friends can message you.
                </p>
              )}
            </div>
          </>
        )}
      </div>

      {/* Fields Picker Modal */}
      {showFieldPicker && (
        <FieldPickerModal
          selected={editFieldIds}
          onToggle={(fieldId) => {
            setEditFieldIds((prev) =>
              prev.includes(fieldId)
                ? prev.filter((f) => f !== fieldId)
                : [...prev, fieldId]
            );
          }}
          onClose={() => setShowFieldPicker(false)}
        />
      )}
    </div>
  );
};
