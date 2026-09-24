import { useEffect, useState, useMemo } from "react";
import { v4 as uuidv4 } from "uuid";
import { useNavigate } from "react-router-dom";
import {
  Loader2, Sparkles, ArrowLeft, ArrowRight, X,
  Tags, Upload, ShieldCheck, ChevronDown,
  Building2, GraduationCap,
} from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { FieldChips, FieldPickerModal } from "@/components/FieldPicker";
import { useSaveProfileFields } from "@/hooks/useProfileFields";
import { triggerProfileEmbed } from "@/lib/embedProfile";
import { toast } from "sonner";

type Mode = "signin" | "signup";
type AccountType = "student" | "company";
type Step = 1 | 2;

type University     = { id: string; name: string; short_name: string };
type EducationGroup = { id: string; name: string };
type Specialty      = { id: string; name: string; code: string; education_group_id: string };

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

// ─── Shared select wrapper ────────────────────────────────────────────────────

const SelectField = ({
  value, onChange, disabled, placeholder, children, loading,
}: {
  value: string;
  onChange: (v: string) => void;
  disabled?: boolean;
  placeholder: string;
  children: React.ReactNode;
  loading?: boolean;
}) => (
  <div className="relative">
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      disabled={disabled || loading}
      className={`w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 appearance-none pr-10 cursor-pointer transition-opacity ${
        (!value) ? "text-muted-foreground" : "text-foreground"
      } ${disabled || loading ? "opacity-50 cursor-not-allowed" : ""}`}
    >
      <option value="" disabled>{loading ? "Loading…" : placeholder}</option>
      {children}
    </select>
    {loading ? (
      <Loader2 className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground animate-spin pointer-events-none" />
    ) : (
      <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
    )}
  </div>
);

// ─── Main component ───────────────────────────────────────────────────────────

const AuthPage = () => {
  const navigate = useNavigate();
  const { user, loading: authLoading, refreshUser } = useAuth();
  const [mode, setMode] = useState<Mode>("signup");
  const [step, setStep] = useState<Step>(1);

  // ── Account type ───────────────────────────────────────────────────
  const [accountType, setAccountType] = useState<AccountType>("student");

  // ── Step 1 fields (shared + student-specific) ──────────────────────
  const [email, setEmail]               = useState("");
  const [password, setPassword]         = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [firstName, setFirstName]       = useState("");
  const [lastName, setLastName]         = useState("");
  const [universityId, setUniversityId] = useState("");
  const [verificationImage, setVerificationImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  // ── Step 1 fields (company-specific) ──────────────────────────────
  const [companyName, setCompanyName] = useState("");

  // ── Step 2 fields (student) ────────────────────────────────────────
  const [educationGroupId, setEducationGroupId] = useState("");
  const [specialtyId, setSpecialtyId]           = useState("");
  const [groupNumber, setGroupNumber]           = useState("");
  const [entranceScore, setEntranceScore]       = useState("");
  const [selectedAvatar, setSelectedAvatar]     = useState(AVATAR_OPTIONS[0]);
  const [bio, setBio]                           = useState("");
  const [fieldIds, setFieldIds]                 = useState<string[]>([]);

  // ── Step 2 fields (company) ────────────────────────────────────────
  const [foundedDate, setFoundedDate]   = useState("");
  const [companyBio, setCompanyBio]     = useState("");

  // ── Reference data ─────────────────────────────────────────────────
  const [universities, setUniversities]     = useState<University[]>([]);
  const [educationGroups, setEducationGroups] = useState<EducationGroup[]>([]);
  const [specialties, setSpecialties]       = useState<Specialty[]>([]);
  const [loadingRef, setLoadingRef]         = useState(true);
  const [loadingSpec, setLoadingSpec]       = useState(false);

  // ── Field picker ──────────────────────────────────────────────────
  const [showFieldPicker, setShowFieldPicker] = useState(false);
  const saveFieldsMutation = useSaveProfileFields();

  const [busy, setBusy] = useState(false);

  // ── Derived ────────────────────────────────────────────────────────
  const selectedUniversity = useMemo(
    () => universities.find((u) => u.id === universityId),
    [universities, universityId],
  );

  // ── Redirect if already logged in ─────────────────────────────────
  useEffect(() => {
    if (!authLoading && user) {
      if ((user as any).account_type === "company") {
        navigate("/company", { replace: true });
      } else {
        navigate("/", { replace: true });
      }
    }
  }, [user, authLoading, navigate]);

  // ── Fetch universities + education groups once ─────────────────────
  useEffect(() => {
    (async () => {
      try {
        const [uniRes, grpRes] = await Promise.all([
          (supabase.from("universities") as any).select("id, name, short_name").order("name"),
          (supabase.from("education_groups") as any).select("id, name").order("name"),
        ]);
        if (uniRes.error)  console.error("[Auth] universities fetch error:", uniRes.error);
        if (grpRes.error)  console.error("[Auth] education_groups fetch error:", grpRes.error);
        if (uniRes.data)   setUniversities(uniRes.data);
        if (grpRes.data)   setEducationGroups(grpRes.data);
        if (!uniRes.data?.length) {
          toast.error("University list not found — run the migration and seed first.", { duration: 8000 });
        }
      } catch (err) {
        console.error("[Auth] reference data fetch failed:", err);
      } finally {
        setLoadingRef(false);
      }
    })();
  }, []);

  // ── Fetch specialties when university or group changes ─────────────
  useEffect(() => {
    if (!universityId) {
      setSpecialties([]);
      setSpecialtyId("");
      return;
    }
    (async () => {
      setLoadingSpec(true);
      setSpecialtyId("");
      let q = (supabase.from("specialties") as any)
        .select("id, name, code, education_group_id")
        .eq("university_id", universityId)
        .order("code");
      if (educationGroupId) q = q.eq("education_group_id", educationGroupId);
      const { data } = await q;
      setSpecialties(data ?? []);
      setLoadingSpec(false);
    })();
  }, [universityId, educationGroupId]);

  // ── Auto-assign group (unchanged) ─────────────────────────────────
  const autoAssignGroup = async (userId: string, groupNum: number, score: number) => {
    const groupTable   = supabase.from("groups") as any;
    const memberTable  = supabase.from("group_members") as any;
    const profileTable = supabase.from("profiles") as any;
    const groupName    = `Group ${groupNum}`;

    const { data: existingGroup } = await groupTable
      .select("id")
      .eq("name", groupName)
      .eq("is_public", false)
      .maybeSingle();

    let groupId: string;

    if (existingGroup) {
      groupId = existingGroup.id;
      await memberTable.insert({ group_id: groupId, user_id: userId, role: "member" });

      const { data: members } = await memberTable.select("user_id").eq("group_id", groupId);
      if (members?.length) {
        const memberIds = members.map((m: any) => m.user_id);
        const { data: profiles } = await profileTable.select("id, entrance_score").in("id", memberIds);
        if (profiles?.length) {
          const sorted     = profiles.sort((a: any, b: any) => (b.entrance_score ?? 0) - (a.entrance_score ?? 0));
          const newAdminId = sorted[0].id;
          for (const member of members) {
            await memberTable
              .update({ role: member.user_id === newAdminId ? "owner" : "member" })
              .eq("group_id", groupId)
              .eq("user_id", member.user_id);
          }
        }
      }
    } else {
      const { data: newGroup, error: gErr } = await groupTable
        .insert({
          name: groupName,
          description: `Auto-created group for group ${groupNum}`,
          color: "from-indigo-400 to-purple-500",
          created_by: userId,
          is_public: false,
          chat_enabled: true,
          bio: "",
        })
        .select("id")
        .single();
      if (gErr) { console.error("Failed to create group:", gErr); return; }
      groupId = newGroup.id;
      await memberTable.insert({ group_id: groupId, user_id: userId, role: "owner" });
    }
  };

  // ── Image handler ──────────────────────────────────────────────────
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setVerificationImage(file);
      const reader = new FileReader();
      reader.onloadend = () => setImagePreview(reader.result as string);
      reader.readAsDataURL(file);
    }
  };

  // ── Validation ─────────────────────────────────────────────────────
  const validateStep1 = (): boolean => {
    if (accountType === "company") {
      if (!companyName.trim())    { toast.error("Company name is required"); return false; }
      if (!email.trim())          { toast.error("Email is required"); return false; }
      if (password.length < 6)    { toast.error("Password must be at least 6 characters"); return false; }
      if (password !== confirmPassword) { toast.error("Passwords do not match"); return false; }
      return true;
    }
    if (!firstName.trim())    { toast.error("First name is required"); return false; }
    if (!lastName.trim())     { toast.error("Last name is required"); return false; }
    if (!universityId)        { toast.error("Please select your university"); return false; }
    if (!email.trim())        { toast.error("Email is required"); return false; }
    if (password.length < 6)  { toast.error("Password must be at least 6 characters"); return false; }
    if (password !== confirmPassword) { toast.error("Passwords do not match"); return false; }
    if (!verificationImage)   { toast.error("Please upload your student ID photo"); return false; }
    return true;
  };

  const validateStep2 = (): boolean => {
    if (accountType === "company") {
      // Founded date and bio are both optional for companies
      return true;
    }
    if (!specialtyId)         { toast.error("Please select your specialty"); return false; }
    if (!groupNumber.trim())  { toast.error("Group number is required"); return false; }
    if (!entranceScore.trim()){ toast.error("Entrance score is required"); return false; }
    return true;
  };

  const goToStep2 = () => { if (validateStep1()) setStep(2); };

  // ── Submit ─────────────────────────────────────────────────────────
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (mode === "signup" && step === 1) { goToStep2(); return; }
    if (mode === "signup" && !validateStep2()) return;

    setBusy(true);
    try {
      const profileTable = supabase.from("profiles") as any;

      if (mode === "signup") {
        // ── Company registration ───────────────────────────────────
        if (accountType === "company") {
          const { data, error } = await profileTable
            .insert({
              id:                  uuidv4(),
              first_name:          companyName.trim(),
              last_name:           "",
              email:               email.trim().toLowerCase(),
              password:            password,
              bio:                 companyBio.trim() || null,
              founded_date:        foundedDate.trim() || null,
              account_type:        "company",
              verification_status: "approved",
            })
            .select()
            .single();

          if (error) throw error;
          localStorage.setItem("bonded_user_id", data.id);
          await refreshUser();
          toast.success("Company account created!");
          navigate("/company", { replace: true });
          return;
        }

        // ── Student registration (unchanged) ───────────────────────
        const scoreNum = parseFloat(entranceScore) || 0;
        const groupNum = parseInt(groupNumber) || 0;

        const { data, error } = await profileTable
          .insert({
            id:                  uuidv4(),
            first_name:          firstName,
            last_name:           lastName,
            university_id:       universityId || null,
            specialty_id:        specialtyId  || null,
            education_group_id:  educationGroupId || null,
            group_number:        groupNum || null,
            entrance_score:      scoreNum,
            email:               email.trim().toLowerCase(),
            password:            password,
            bio:                 bio.trim() || (selectedUniversity ? "New student at " + selectedUniversity.name : "New student"),
            avatar_url:          selectedAvatar,
            account_type:        "student",
          })
          .select()
          .single();

        if (error) throw error;

        if (fieldIds.length > 0) {
          await saveFieldsMutation.mutateAsync({ userId: data.id, fieldIds });
        }
        triggerProfileEmbed(data.id);

        localStorage.setItem("bonded_user_id", data.id);
        await refreshUser();

        if (imagePreview) {
          await (supabase.from("verification_requests") as any).insert({
            user_id:    data.id,
            first_name: firstName.trim(),
            last_name:  lastName.trim(),
            university: selectedUniversity?.name ?? "",
            image_data: imagePreview,
            status:     "pending",
          });
        }

        if (groupNum > 0) await autoAssignGroup(data.id, groupNum, scoreNum);

        toast.success("Account created! Your ID is pending admin verification.");
        navigate("/", { replace: true });
      } else {
        // ── Sign in ────────────────────────────────────────────────
        const { data, error } = await profileTable
          .select("*")
          .eq("email", email.trim().toLowerCase())
          .maybeSingle();

        if (error) throw error;
        if (!data)  throw new Error("No account found with this email.");
        if (data.password !== password) throw new Error("Incorrect password. Please try again.");

        localStorage.setItem("bonded_user_id", data.id);
        await refreshUser();
        toast.success("Welcome back!");
        if ((data as any).account_type === "company") {
          navigate("/company", { replace: true });
        } else {
          navigate("/", { replace: true });
        }
      }
    } catch (err: any) {
      toast.error(err.message ?? "Something went wrong");
    } finally {
      setBusy(false);
    }
  };

  const switchMode = () => { setMode((m) => (m === "signup" ? "signin" : "signup")); setStep(1); setAccountType("student"); };

  // ── Render ─────────────────────────────────────────────────────────
  return (
    <div className="min-h-screen gradient-bg grid place-items-center px-5 py-10">
      <div className="w-full max-w-md sm:max-w-lg transition-all">
        {/* Header */}
        <div className="text-center mb-6">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary-soft text-primary text-xs font-bold uppercase tracking-widest">
            <Sparkles className="h-3.5 w-3.5" /> BONDED
          </div>
          <h1 className="mt-4 text-3xl font-bold text-foreground tracking-tight">
            {mode === "signup"
              ? step === 1
                ? accountType === "company" ? "Register as Company" : "Create your account"
                : accountType === "company" ? "Company details" : "Complete your profile"
              : "Welcome back"}
          </h1>
          <p className="mt-1.5 text-sm text-muted-foreground">
            {mode === "signup"
              ? step === 1
                ? accountType === "company"
                  ? "Step 1 of 2 — Account credentials"
                  : "Step 1 of 2 — Identity & credentials"
                : accountType === "company"
                  ? "Step 2 of 2 — Basic company information"
                  : "Step 2 of 2 — Academic details"
              : "Sign in to keep the conversation going."}
          </p>
          {mode === "signup" && (
            <div className="flex items-center justify-center gap-2 mt-3">
              <div className={`h-2 w-8 rounded-full transition-all ${step >= 1 ? "bg-gradient-primary shadow-glow" : "bg-secondary"}`} />
              <div className={`h-2 w-8 rounded-full transition-all ${step >= 2 ? "bg-gradient-primary shadow-glow" : "bg-secondary"}`} />
            </div>
          )}
        </div>

        <form onSubmit={handleSubmit} className="glass-strong rounded-3xl p-6 space-y-3">

          {/* ── ACCOUNT TYPE SELECTOR ── */}
          {mode === "signup" && step === 1 && (
            <div className="grid grid-cols-2 gap-2 mb-1">
              <button
                type="button"
                onClick={() => { setAccountType("student"); }}
                className={`flex items-center justify-center gap-2 py-3 rounded-2xl font-semibold text-sm transition-all ${
                  accountType === "student"
                    ? "bg-gradient-primary text-primary-foreground shadow-glow"
                    : "bg-secondary text-muted-foreground hover:text-foreground"
                }`}
              >
                <GraduationCap className="h-4 w-4" />
                Student
              </button>
              <button
                type="button"
                onClick={() => { setAccountType("company"); }}
                className={`flex items-center justify-center gap-2 py-3 rounded-2xl font-semibold text-sm transition-all ${
                  accountType === "company"
                    ? "bg-gradient-primary text-primary-foreground shadow-glow"
                    : "bg-secondary text-muted-foreground hover:text-foreground"
                }`}
              >
                <Building2 className="h-4 w-4" />
                Company
              </button>
            </div>
          )}

          {/* ── COMPANY STEP 1 ── */}
          {mode === "signup" && step === 1 && accountType === "company" && (
            <>
              <input
                required
                placeholder="Company Name"
                value={companyName}
                onChange={(e) => setCompanyName(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                minLength={6}
                type="password"
                placeholder="Password (6+ chars)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                minLength={6}
                type="password"
                placeholder="Confirm password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className={`w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 ${
                  confirmPassword && password !== confirmPassword
                    ? "focus:ring-destructive/40 border border-destructive/30"
                    : "focus:ring-primary/40"
                }`}
              />
              {confirmPassword && password !== confirmPassword && (
                <p className="text-xs text-destructive font-medium -mt-1 ml-1">Passwords do not match</p>
              )}
              <button
                type="submit"
                className="w-full mt-2 inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60"
              >
                Continue
                <ArrowRight className="h-4 w-4" />
              </button>
            </>
          )}

          {/* ── COMPANY STEP 2 ── */}
          {mode === "signup" && step === 2 && accountType === "company" && (
            <>
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5">Founded Date <span className="text-muted-foreground/60">(optional)</span></p>
                <input
                  type="text"
                  placeholder="e.g. 2018, March 2020"
                  value={foundedDate}
                  onChange={(e) => setFoundedDate(e.target.value)}
                  className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5">Bio <span className="text-muted-foreground/60">(optional)</span></p>
                <textarea
                  value={companyBio}
                  onChange={(e) => setCompanyBio(e.target.value)}
                  placeholder="Tell us about your company…"
                  rows={4}
                  maxLength={500}
                  className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
                />
                <p className="text-[10px] text-muted-foreground text-right mt-0.5">{companyBio.length}/500</p>
              </div>
              <div className="grid grid-cols-2 gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setStep(1)}
                  className="inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-secondary text-foreground font-semibold active:scale-[0.99]"
                >
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </button>
                <button
                  type="submit"
                  disabled={busy}
                  className="inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60"
                >
                  {busy && <Loader2 className="h-4 w-4 animate-spin" />}
                  Create account
                </button>
              </div>
            </>
          )}

          {/* ── STUDENT STEP 1 ── */}
          {mode === "signup" && step === 1 && accountType === "student" && (
            <>
              <div className="grid grid-cols-2 gap-2">
                <input
                  required
                  placeholder="First name"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  className="bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
                <input
                  required
                  placeholder="Last name"
                  value={lastName}
                  onChange={(e) => setLastName(e.target.value)}
                  className="bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              {/* University dropdown */}
              <SelectField
                value={universityId}
                onChange={(v) => { setUniversityId(v); setSpecialtyId(""); }}
                placeholder="Select university"
                loading={loadingRef}
              >
                {universities.map((u) => (
                  <option key={u.id} value={u.id}>{u.name}</option>
                ))}
              </SelectField>

              <input
                required
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                minLength={6}
                type="password"
                placeholder="Password (6+ chars)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                minLength={6}
                type="password"
                placeholder="Confirm password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className={`w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 ${
                  confirmPassword && password !== confirmPassword
                    ? "focus:ring-destructive/40 border border-destructive/30"
                    : "focus:ring-primary/40"
                }`}
              />
              {confirmPassword && password !== confirmPassword && (
                <p className="text-xs text-destructive font-medium -mt-1 ml-1">Passwords do not match</p>
              )}

              {/* Student ID upload */}
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5 flex items-center gap-1">
                  <ShieldCheck className="h-3 w-3" /> Student ID — sent to admin for review
                </p>
                <label
                  className={`relative flex flex-col items-center justify-center w-full rounded-2xl border-2 border-dashed cursor-pointer transition-all ${
                    imagePreview
                      ? "border-primary/40 bg-primary-soft"
                      : "border-border hover:border-primary/30 hover:bg-secondary/50"
                  } ${imagePreview ? "p-2" : "p-5"}`}
                >
                  <input type="file" accept="image/*" onChange={handleImageChange} className="sr-only" />
                  {imagePreview ? (
                    <div className="relative w-full">
                      <img src={imagePreview} alt="Preview" className="w-full max-h-32 object-contain rounded-xl" />
                      <button
                        type="button"
                        onClick={(e) => { e.preventDefault(); setVerificationImage(null); setImagePreview(null); }}
                        className="absolute -top-1 -right-1 h-6 w-6 rounded-full bg-destructive text-white grid place-items-center shadow-md hover:scale-110 transition-transform"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </div>
                  ) : (
                    <>
                      <Upload className="h-6 w-6 text-muted-foreground mb-1" />
                      <p className="text-xs text-muted-foreground font-medium">Upload your student ID photo</p>
                      <p className="text-[10px] text-muted-foreground/60 mt-0.5">JPG, PNG — must show name & university</p>
                    </>
                  )}
                </label>
              </div>

              <button
                type="submit"
                className="w-full mt-2 inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60"
              >
                Continue
                <ArrowRight className="h-4 w-4" />
              </button>
            </>
          )}

          {/* ── STUDENT STEP 2 ── */}
          {mode === "signup" && step === 2 && accountType === "student" && (
            <>
              {/* Education group → specialty cascade */}
              <div className="space-y-2">
                <p className="text-xs font-semibold text-muted-foreground flex items-center gap-1">
                  Academic specialisation
                  {selectedUniversity && (
                    <span className="ml-auto font-normal text-muted-foreground/70 truncate max-w-[180px] sm:max-w-[280px]">
                      {selectedUniversity.short_name}
                    </span>
                  )}
                </p>

                {/* Education group */}
                <SelectField
                  value={educationGroupId}
                  onChange={(v) => { setEducationGroupId(v); setSpecialtyId(""); }}
                  placeholder="Select education group (I / II / III / IV / V)"
                  loading={loadingRef}
                >
                  {educationGroups.map((g) => (
                    <option key={g.id} value={g.id}>Group {g.name}</option>
                  ))}
                </SelectField>

                {/* Specialty — filtered by university + group */}
                <SelectField
                  value={specialtyId}
                  onChange={setSpecialtyId}
                  placeholder={
                    !universityId
                      ? "Select university first"
                      : specialties.length === 0 && !loadingSpec
                      ? "No specialties for this selection"
                      : "Select specialty"
                  }
                  disabled={!universityId || (specialties.length === 0 && !loadingSpec)}
                  loading={loadingSpec}
                >
                  {specialties.map((s) => (
                    <option key={s.id} value={s.id}>{s.code} — {s.name}</option>
                  ))}
                </SelectField>

                {!educationGroupId && universityId && !loadingSpec && specialties.length > 0 && (
                  <p className="text-[11px] text-muted-foreground/70 ml-1">
                    Showing all {specialties.length} specialties for this university. Select a group to narrow down.
                  </p>
                )}
              </div>

              {/* Fields — multi-select (optional) */}
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5 flex items-center gap-1">
                  <Tags className="h-3 w-3" /> Fields <span className="text-muted-foreground/60">(optional)</span>
                </p>
                <FieldChips
                  selectedIds={fieldIds}
                  onRemove={(id) => setFieldIds((prev) => prev.filter((f) => f !== id))}
                  onOpenPicker={() => setShowFieldPicker(true)}
                />
              </div>

              <div className="grid grid-cols-2 gap-2">
                <input
                  required
                  type="number"
                  min="1"
                  placeholder="Group number *"
                  value={groupNumber}
                  onChange={(e) => setGroupNumber(e.target.value)}
                  className="bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
                <input
                  required
                  type="number"
                  step="0.01"
                  min="0"
                  placeholder="Entrance score *"
                  value={entranceScore}
                  onChange={(e) => setEntranceScore(e.target.value)}
                  className="bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              {/* Avatar picker */}
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-2">
                  Choose an avatar <span className="text-muted-foreground/60">(optional)</span>
                </p>
                <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
                  {AVATAR_OPTIONS.map((url) => (
                    <button
                      key={url}
                      type="button"
                      onClick={() => setSelectedAvatar(url)}
                      className={`flex-shrink-0 h-12 w-12 rounded-full overflow-hidden border-2 transition-all bg-white ${
                        selectedAvatar === url
                          ? "border-primary shadow-glow scale-110"
                          : "border-transparent opacity-60 hover:opacity-90"
                      }`}
                    >
                      <img src={url} alt="avatar option" className="h-full w-full" />
                    </button>
                  ))}
                </div>
              </div>

              {/* Bio */}
              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5">
                  Bio <span className="text-muted-foreground/60">(optional)</span>
                </p>
                <textarea
                  value={bio}
                  onChange={(e) => setBio(e.target.value)}
                  placeholder="Tell us about yourself…"
                  rows={3}
                  maxLength={300}
                  className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
                />
                <p className="text-[10px] text-muted-foreground text-right mt-0.5">{bio.length}/300</p>
              </div>

              <div className="grid grid-cols-2 gap-2 pt-1">
                <button
                  type="button"
                  onClick={() => setStep(1)}
                  className="inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-secondary text-foreground font-semibold active:scale-[0.99]"
                >
                  <ArrowLeft className="h-4 w-4" />
                  Back
                </button>
                <button
                  type="submit"
                  disabled={busy}
                  className="inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60"
                >
                  {busy && <Loader2 className="h-4 w-4 animate-spin" />}
                  Create account
                </button>
              </div>
            </>
          )}

          {/* ── SIGN IN ── */}
          {mode === "signin" && (
            <>
              <input
                required
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <input
                required
                minLength={6}
                type="password"
                placeholder="Password (6+ chars)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
              />
              <button
                type="submit"
                disabled={busy}
                className="w-full mt-2 inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60"
              >
                {busy && <Loader2 className="h-4 w-4 animate-spin" />}
                Sign in
              </button>
            </>
          )}

          <button
            type="button"
            onClick={switchMode}
            className="w-full text-sm text-muted-foreground hover:text-primary transition-colors py-1"
          >
            {mode === "signup"
              ? "Already have an account? Sign in"
              : "New here? Create an account"}
          </button>
        </form>
      </div>

      {/* Fields Picker Modal */}
      {showFieldPicker && (
        <FieldPickerModal
          selected={fieldIds}
          onToggle={(fieldId) =>
            setFieldIds((prev) =>
              prev.includes(fieldId) ? prev.filter((f) => f !== fieldId) : [...prev, fieldId]
            )
          }
          onClose={() => setShowFieldPicker(false)}
        />
      )}
    </div>
  );
};

export default AuthPage;
