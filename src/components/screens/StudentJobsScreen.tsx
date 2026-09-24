import { useEffect, useState, useCallback, useMemo } from "react";
import {
  Briefcase, Search, Loader2, ArrowLeft, Building2,
  Code2, ChevronDown, X, Check, Send,
} from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { IT_FIELDS, JOB_LEVELS } from "@/lib/itFields";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

interface JobPosting {
  id: string;
  company_id: string;
  title: string;
  field: string;
  level: string;
  description: string;
  salary: string | null;
  created_at: string;
  company_name: string;
}

type DetailView = JobPosting | null;

export const StudentJobsScreen = () => {
  const { user } = useAuth();
  const [jobs, setJobs] = useState<JobPosting[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedJob, setSelectedJob] = useState<DetailView>(null);

  // Filters
  const [searchQuery, setSearchQuery] = useState("");
  const [filterField, setFilterField] = useState("");
  const [filterLevel, setFilterLevel] = useState("");

  // Applications this student has already submitted
  const [appliedJobIds, setAppliedJobIds] = useState<Set<string>>(new Set());

  // Apply modal
  const [showApplyModal, setShowApplyModal] = useState(false);
  const [applyMessage, setApplyMessage] = useState("");
  const [applying, setApplying] = useState(false);

  const loadJobs = useCallback(async () => {
    setLoading(true);
    try {
      // Fetch all job postings
      const { data: jobData, error: jobErr } = await (supabase.from("company_job_postings") as any)
        .select("id, company_id, title, field, level, description, salary, created_at")
        .order("created_at", { ascending: false });

      if (jobErr) throw jobErr;

      if (!jobData || jobData.length === 0) {
        setJobs([]);
        return;
      }

      // Fetch company profiles for company names
      const companyIds = [...new Set((jobData as any[]).map((j: any) => j.company_id))];
      const { data: companyData } = await (supabase.from("profiles") as any)
        .select("id, first_name")
        .in("id", companyIds);

      const companyMap = new Map((companyData ?? []).map((c: any) => [c.id, c.first_name]));

      const mapped: JobPosting[] = (jobData as any[]).map((j: any) => ({
        ...j,
        company_name: companyMap.get(j.company_id) ?? "Company",
      }));

      setJobs(mapped);

      // Load this student's existing applications
      if (user?.id) {
        const { data: appData } = await (supabase.from("job_applications") as any)
          .select("job_id")
          .eq("student_id", user.id);
        setAppliedJobIds(new Set((appData ?? []).map((a: any) => a.job_id)));
      }
    } catch (err: any) {
      toast.error("Failed to load jobs");
    } finally {
      setLoading(false);
    }
  }, [user?.id]);

  useEffect(() => { loadJobs(); }, [loadJobs]);

  const filteredJobs = useMemo(() => {
    let result = jobs;
    if (filterField) result = result.filter((j) => j.field === filterField);
    if (filterLevel) result = result.filter((j) => j.level === filterLevel);
    if (searchQuery.trim()) {
      const q = searchQuery.trim().toLowerCase();
      result = result.filter(
        (j) =>
          j.title.toLowerCase().includes(q) ||
          j.company_name.toLowerCase().includes(q) ||
          j.field.toLowerCase().includes(q)
      );
    }
    return result;
  }, [jobs, filterField, filterLevel, searchQuery]);

  const handleApply = async () => {
    if (!user?.id || !selectedJob) return;
    setApplying(true);
    try {
      const { error } = await (supabase.from("job_applications") as any).insert({
        job_id: selectedJob.id,
        student_id: user.id,
        message: applyMessage.trim() || null,
      });
      if (error) {
        if (error.code === "23505") {
          toast.error("You have already applied for this job.");
        } else {
          throw error;
        }
        return;
      }
      setAppliedJobIds((prev) => new Set(prev).add(selectedJob.id));
      setShowApplyModal(false);
      setApplyMessage("");
      toast.success("Application submitted! 🎉");
    } catch (err: any) {
      toast.error(err.message ?? "Failed to submit application");
    } finally {
      setApplying(false);
    }
  };

  // ── Job Detail View ────────────────────────────────────────────────────────
  if (selectedJob) {
    const isApplied = appliedJobIds.has(selectedJob.id);
    return (
      <div className="animate-fade-in pb-8 max-w-3xl mx-auto">
        <div className="px-5 pt-5 pb-3 flex items-center gap-3">
          <button
            onClick={() => setSelectedJob(null)}
            className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform shrink-0"
            aria-label="Back"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div className="min-w-0">
            <h2 className="text-lg font-bold text-foreground truncate">{selectedJob.title}</h2>
            <p className="text-xs text-muted-foreground flex items-center gap-1">
              <Building2 className="h-3 w-3" />
              {selectedJob.company_name}
            </p>
          </div>
        </div>

        <div className="px-5 space-y-4">
          {/* Job info card */}
          <div className="glass-strong rounded-3xl p-5 space-y-4">
            <div className="flex items-center gap-3">
              <div className="h-14 w-14 rounded-2xl bg-gradient-primary grid place-items-center shadow-glow shrink-0">
                <Briefcase className="h-7 w-7 text-primary-foreground" strokeWidth={1.8} />
              </div>
              <div className="min-w-0">
                <h3 className="font-bold text-xl text-foreground truncate">{selectedJob.title}</h3>
                <p className="text-sm text-muted-foreground">{selectedJob.company_name}</p>
              </div>
            </div>

            <div className="flex flex-wrap gap-2">
              <span className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-primary-soft text-primary">
                <Code2 className="h-3.5 w-3.5" />
                {selectedJob.field}
              </span>
              <span className="text-xs font-semibold px-3 py-1.5 rounded-full bg-secondary text-muted-foreground">
                {selectedJob.level}
              </span>
              {selectedJob.salary && (
                <span className="text-xs font-semibold px-3 py-1.5 rounded-full bg-green-50 dark:bg-green-950/50 text-green-700 dark:text-green-400">
                  {selectedJob.salary}
                </span>
              )}
            </div>
          </div>

          {/* Description */}
          <div className="glass-strong rounded-3xl p-5">
            <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-3">
              Job Description
            </p>
            <p className="text-sm text-foreground leading-relaxed whitespace-pre-wrap">
              {selectedJob.description}
            </p>
          </div>

          {/* Apply button */}
          {isApplied ? (
            <div className="flex items-center justify-center gap-2 py-3.5 rounded-2xl bg-green-50 dark:bg-green-950/50 text-green-700 dark:text-green-400 font-semibold">
              <Check className="h-5 w-5" />
              Application Submitted
            </div>
          ) : (
            <button
              id={`apply-job-${selectedJob.id}`}
              onClick={() => setShowApplyModal(true)}
              className="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] transition-all"
            >
              <Send className="h-4 w-4" />
              Apply Now
            </button>
          )}
        </div>

        {/* Apply Modal */}
        {showApplyModal && (
          <div
            className="fixed inset-0 z-50 bg-black/50 grid place-items-end sm:place-items-center p-0 sm:p-5 animate-fade-in"
            onClick={() => !applying && setShowApplyModal(false)}
          >
            <div
              className="w-full sm:max-w-lg bg-background rounded-t-3xl sm:rounded-3xl p-6 space-y-4 shadow-2xl animate-slide-up"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between">
                <h2 className="text-xl font-bold text-foreground">Apply for Job</h2>
                <button
                  onClick={() => setShowApplyModal(false)}
                  disabled={applying}
                  className="h-9 w-9 grid place-items-center rounded-full glass hover:bg-secondary"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="glass-strong rounded-2xl p-4">
                <p className="font-semibold text-foreground">{selectedJob.title}</p>
                <p className="text-xs text-muted-foreground mt-0.5">{selectedJob.company_name}</p>
              </div>

              <div>
                <p className="text-xs font-semibold text-muted-foreground mb-1.5">
                  Message <span className="text-muted-foreground/60">(optional)</span>
                </p>
                <textarea
                  value={applyMessage}
                  onChange={(e) => setApplyMessage(e.target.value)}
                  placeholder="Introduce yourself, mention your experience, or ask a question…"
                  rows={4}
                  maxLength={1000}
                  className="w-full bg-secondary rounded-xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 resize-none"
                />
                <p className="text-[10px] text-muted-foreground text-right mt-0.5">{applyMessage.length}/1000</p>
              </div>

              <button
                onClick={handleApply}
                disabled={applying}
                className="w-full flex items-center justify-center gap-2 py-3.5 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.99] disabled:opacity-60 transition-all"
              >
                {applying ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
                Submit Application
              </button>
            </div>
          </div>
        )}
      </div>
    );
  }

  // ── Jobs List View ─────────────────────────────────────────────────────────
  return (
    <div className="animate-fade-in pb-4">
      <AppHeader
        subtitle="BONDED"
        title="Jobs"
      />

      {/* Search + Filters */}
      <div className="px-5 pb-4 space-y-3">
        <div className="glass rounded-2xl flex items-center gap-2 px-4 py-3">
          <Search className="h-4 w-4 text-muted-foreground shrink-0" />
          <input
            id="jobs-search-input"
            type="search"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search jobs, companies, fields…"
            className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery("")} className="h-5 w-5 grid place-items-center rounded-full hover:bg-secondary shrink-0">
              <X className="h-3 w-3 text-muted-foreground" />
            </button>
          )}
        </div>

        <div className="grid grid-cols-2 gap-2">
          {/* Field filter */}
          <div className="relative">
            <select
              id="jobs-filter-field"
              value={filterField}
              onChange={(e) => setFilterField(e.target.value)}
              className={cn(
                "w-full bg-secondary rounded-xl px-3 py-2.5 text-xs outline-none appearance-none cursor-pointer pr-7 truncate",
                !filterField ? "text-muted-foreground" : "text-foreground font-semibold"
              )}
            >
              <option value="">All Fields</option>
              {IT_FIELDS.map((f) => (
                <option key={f} value={f}>{f}</option>
              ))}
            </select>
            <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground pointer-events-none" />
          </div>

          {/* Level filter */}
          <div className="relative">
            <select
              id="jobs-filter-level"
              value={filterLevel}
              onChange={(e) => setFilterLevel(e.target.value)}
              className={cn(
                "w-full bg-secondary rounded-xl px-3 py-2.5 text-xs outline-none appearance-none cursor-pointer pr-7",
                !filterLevel ? "text-muted-foreground" : "text-foreground font-semibold"
              )}
            >
              <option value="">All Levels</option>
              {JOB_LEVELS.map((l) => (
                <option key={l} value={l}>{l}</option>
              ))}
            </select>
            <ChevronDown className="absolute right-2 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground pointer-events-none" />
          </div>
        </div>

        {(filterField || filterLevel) && (
          <button
            onClick={() => { setFilterField(""); setFilterLevel(""); }}
            className="flex items-center gap-1.5 text-xs font-semibold text-primary hover:underline"
          >
            <X className="h-3 w-3" />
            Clear filters
          </button>
        )}
      </div>

      {loading ? (
        <div className="h-48 grid place-items-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      ) : filteredJobs.length === 0 ? (
        <div className="px-5 mt-4">
          <div className="glass-strong rounded-3xl p-8 text-center space-y-4">
            <div className="mx-auto h-20 w-20 rounded-full bg-primary-soft grid place-items-center">
              <Briefcase className="h-9 w-9 text-primary" strokeWidth={1.8} />
            </div>
            <div>
              <h3 className="text-lg font-bold text-foreground">
                {jobs.length === 0 ? "No jobs posted yet" : "No jobs match your filters"}
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                {jobs.length === 0
                  ? "Check back later — companies will post internships and jobs here."
                  : "Try adjusting your search or filters."}
              </p>
            </div>
          </div>
        </div>
      ) : (
        <div className="px-5">
          <p className="text-xs font-semibold text-muted-foreground mb-3">
            {filteredJobs.length} job{filteredJobs.length !== 1 ? "s" : ""} available
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3.5">
            {filteredJobs.map((job, i) => {
              const isApplied = appliedJobIds.has(job.id);
              return (
                <button
                  key={job.id}
                  id={`job-card-${job.id}`}
                  onClick={() => setSelectedJob(job)}
                  style={{ animationDelay: `${i * 40}ms` }}
                  className="w-full glass-strong rounded-2xl p-4 text-left hover:scale-[1.01] active:scale-[0.99] transition-all animate-slide-up flex flex-col justify-between"
                >
                  <div className="flex items-start gap-3">
                    <div className="h-11 w-11 rounded-xl bg-gradient-primary grid place-items-center shadow-glow shrink-0">
                      <Briefcase className="h-5 w-5 text-primary-foreground" strokeWidth={2} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-bold text-foreground truncate">{job.title}</p>
                      <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5 truncate">
                        <Building2 className="h-3 w-3 shrink-0" />
                        {job.company_name}
                      </p>
                      <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5 truncate">
                        <Code2 className="h-3 w-3 shrink-0" />
                        {job.field}
                      </p>
                      <div className="flex items-center gap-2 mt-2 flex-wrap">
                        <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-secondary text-muted-foreground">
                          {job.level}
                        </span>
                        {job.salary && (
                          <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-green-50 dark:bg-green-950/50 text-green-700 dark:text-green-400">
                            {job.salary}
                          </span>
                        )}
                        {isApplied && (
                          <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-primary-soft text-primary flex items-center gap-1">
                            <Check className="h-3 w-3" />
                            Applied
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                  <p className="text-xs text-muted-foreground mt-3 leading-relaxed line-clamp-2">
                    {job.description}
                  </p>
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};
