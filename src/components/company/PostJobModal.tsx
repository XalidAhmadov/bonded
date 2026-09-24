import { useState, useMemo } from "react";
import { X, Check, Search, ChevronDown } from "lucide-react";
import { IT_FIELDS, JOB_LEVELS } from "@/lib/itFields";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";

interface PostJobModalProps {
  onClose: () => void;
  onCreated: () => void;
}

export const PostJobModal = ({ onClose, onCreated }: PostJobModalProps) => {
  const { user } = useAuth();
  const [title, setTitle] = useState("");
  const [field, setField] = useState("");
  const [level, setLevel] = useState("");
  const [description, setDescription] = useState("");
  const [salary, setSalary] = useState("");
  const [busy, setBusy] = useState(false);

  // Field picker state
  const [showFieldPicker, setShowFieldPicker] = useState(false);
  const [fieldSearch, setFieldSearch] = useState("");

  const filteredFields = useMemo(() => {
    const q = fieldSearch.trim().toLowerCase();
    if (!q) return IT_FIELDS;
    return IT_FIELDS.filter((f) => f.toLowerCase().includes(q));
  }, [fieldSearch]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim())       { toast.error("Job title is required"); return; }
    if (!field)              { toast.error("Please select a field"); return; }
    if (!level)              { toast.error("Please select a level"); return; }
    if (!description.trim()) { toast.error("Job description is required"); return; }

    setBusy(true);
    try {
      const { error } = await (supabase.from("company_job_postings") as any).insert({
        company_id:  user!.id,
        title:       title.trim(),
        field:       field,
        level:       level,
        description: description.trim(),
        salary:      salary.trim() || null,
      });
      if (error) throw error;
      toast.success("Job posted successfully!");
      onCreated();
      onClose();
    } catch (err: any) {
      toast.error(err.message ?? "Failed to post job");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-black/50 grid place-items-end sm:place-items-center p-0 sm:p-5 animate-fade-in"
      onClick={onClose}
    >
      <div
        className="w-full sm:max-w-lg md:max-w-xl bg-background rounded-t-3xl sm:rounded-3xl p-6 space-y-4 max-h-[90vh] flex flex-col shadow-2xl animate-slide-up sm:animate-scale-in"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between shrink-0">
          <h2 className="text-xl font-bold text-foreground">Post a Job</h2>
          <button
            onClick={onClose}
            className="h-9 w-9 grid place-items-center rounded-full glass hover:bg-secondary"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-3 overflow-y-auto flex-1 pr-0.5" style={{ scrollbarWidth: "none" }}>
          {/* Title */}
          <input
            required
            placeholder="Position / Job Title *"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
          />

          {/* Field picker */}
          <div>
            <p className="text-xs font-semibold text-muted-foreground mb-1.5">Field / Specialization *</p>
            {field ? (
              <div className="flex items-center gap-2">
                <span className="flex-1 text-sm font-medium text-foreground bg-primary-soft text-primary px-4 py-3 rounded-2xl">
                  {field}
                </span>
                <button
                  type="button"
                  onClick={() => setField("")}
                  className="h-10 w-10 grid place-items-center rounded-full bg-secondary hover:bg-destructive/10 hover:text-destructive transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => { setShowFieldPicker(true); setFieldSearch(""); }}
                className="w-full flex items-center justify-between gap-2 px-4 py-3 rounded-2xl bg-secondary text-muted-foreground text-sm hover:bg-primary-soft hover:text-primary transition-colors"
              >
                <span>Select field…</span>
                <ChevronDown className="h-4 w-4" />
              </button>
            )}
          </div>

          {/* Level */}
          <div>
            <p className="text-xs font-semibold text-muted-foreground mb-1.5">Experience Level *</p>
            <div className="relative">
              <select
                value={level}
                onChange={(e) => setLevel(e.target.value)}
                className={`w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 appearance-none pr-10 cursor-pointer ${!level ? "text-muted-foreground" : "text-foreground"}`}
              >
                <option value="" disabled>Select level…</option>
                {JOB_LEVELS.map((l) => (
                  <option key={l} value={l}>{l}</option>
                ))}
              </select>
              <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
            </div>
          </div>

          {/* Description */}
          <div>
            <p className="text-xs font-semibold text-muted-foreground mb-1.5">Job Description *</p>
            <textarea
              required
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Responsibilities, requirements, and other details…"
              rows={5}
              maxLength={3000}
              className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
            />
            <p className="text-[10px] text-muted-foreground text-right mt-0.5">{description.length}/3000</p>
          </div>

          {/* Salary (optional) */}
          <div>
            <p className="text-xs font-semibold text-muted-foreground mb-1.5">
              Salary <span className="text-muted-foreground/60">(optional)</span>
            </p>
            <input
              type="text"
              placeholder="e.g. $1,500/month, $60k–$80k/year, Competitive"
              value={salary}
              onChange={(e) => setSalary(e.target.value)}
              className="w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40"
            />
          </div>

          {/* Submit */}
          <button
            type="submit"
            disabled={busy}
            className="w-full mt-1 flex items-center justify-center gap-2 py-3.5 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60 shrink-0"
          >
            {busy ? <Loader2 className="h-4 w-4 animate-spin" /> : <Check className="h-4 w-4" />}
            Post Job
          </button>
        </form>
      </div>

      {/* Field Picker Sub-modal */}
      {showFieldPicker && (
        <div
          className="fixed inset-0 z-[60] bg-black/40 grid place-items-center p-5"
          onClick={() => setShowFieldPicker(false)}
        >
          <div
            className="w-full max-w-md sm:max-w-lg bg-background rounded-3xl p-5 space-y-3 max-h-[80vh] flex flex-col shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between shrink-0">
              <h3 className="text-lg font-bold text-foreground">Select Field</h3>
              <button onClick={() => setShowFieldPicker(false)} className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary">
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="flex items-center gap-2 bg-secondary rounded-xl px-3 py-2.5 shrink-0">
              <Search className="h-4 w-4 text-muted-foreground shrink-0" />
              <input
                autoFocus
                type="search"
                value={fieldSearch}
                onChange={(e) => setFieldSearch(e.target.value)}
                placeholder="Search IT fields…"
                className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
              />
            </div>
            <div className="flex-1 overflow-y-auto space-y-1 -mx-1 px-1" style={{ scrollbarWidth: "thin" }}>
              {filteredFields.map((f) => (
                <button
                  key={f}
                  type="button"
                  onClick={() => { setField(f); setShowFieldPicker(false); }}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-left text-sm transition-all ${
                    field === f ? "bg-primary-soft text-primary font-semibold" : "text-foreground hover:bg-secondary"
                  }`}
                >
                  <div className={`h-5 w-5 rounded-md border-2 grid place-items-center shrink-0 transition-all ${
                    field === f ? "bg-gradient-primary border-primary shadow-glow" : "border-border"
                  }`}>
                    {field === f && <Check className="h-3 w-3 text-white" strokeWidth={3} />}
                  </div>
                  <span className="truncate">{f}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
