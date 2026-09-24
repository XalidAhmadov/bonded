import { useEffect, useState, useCallback } from "react";
import { Plus, Briefcase, Users, Code2, Loader2, Trash2, ChevronRight } from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";
import { PostJobModal } from "./PostJobModal";
import { JobApplicationsView } from "./JobApplicationsView";
import { toast } from "sonner";

interface JobPosting {
  id: string;
  title: string;
  field: string;
  level: string;
  description: string;
  salary: string | null;
  created_at: string;
  application_count?: number;
}

export const CompanyJobsScreen = () => {
  const { user } = useAuth();
  const [jobs, setJobs] = useState<JobPosting[]>([]);
  const [loading, setLoading] = useState(true);
  const [showPostModal, setShowPostModal] = useState(false);
  const [activeJobId, setActiveJobId] = useState<string | null>(null);
  const [activeJobTitle, setActiveJobTitle] = useState<string>("");
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const loadJobs = useCallback(async () => {
    if (!user?.id) return;
    setLoading(true);
    try {
      const { data, error } = await (supabase.from("company_job_postings") as any)
        .select("*")
        .eq("company_id", user.id)
        .order("created_at", { ascending: false });
      if (error) throw error;

      // Fetch application counts for each job
      const jobsWithCounts = await Promise.all(
        (data ?? []).map(async (job: JobPosting) => {
          const { count } = await (supabase.from("job_applications") as any)
            .select("id", { count: "exact", head: true })
            .eq("job_id", job.id);
          return { ...job, application_count: count ?? 0 };
        })
      );
      setJobs(jobsWithCounts);
    } catch (err: any) {
      toast.error("Failed to load jobs");
    } finally {
      setLoading(false);
    }
  }, [user?.id]);

  useEffect(() => { loadJobs(); }, [loadJobs]);

  const deleteJob = async (jobId: string) => {
    if (!confirm("Delete this job posting? All applications will be lost.")) return;
    setDeletingId(jobId);
    try {
      const { error } = await (supabase.from("company_job_postings") as any)
        .delete()
        .eq("id", jobId);
      if (error) throw error;
      setJobs((prev) => prev.filter((j) => j.id !== jobId));
      toast.success("Job deleted");
    } catch (err: any) {
      toast.error("Failed to delete job");
    } finally {
      setDeletingId(null);
    }
  };

  // If viewing a specific job's applications
  if (activeJobId) {
    return (
      <JobApplicationsView
        jobId={activeJobId}
        jobTitle={activeJobTitle}
        onBack={() => { setActiveJobId(null); setActiveJobTitle(""); loadJobs(); }}
      />
    );
  }

  return (
    <div className="animate-fade-in pb-4">
      <AppHeader
        subtitle="Company"
        title="Job Postings"
        right={
          <button
            onClick={() => setShowPostModal(true)}
            className="h-10 w-10 grid place-items-center rounded-full bg-gradient-primary text-primary-foreground shadow-glow active:scale-95 transition-transform"
            aria-label="Post a job"
          >
            <Plus className="h-5 w-5" strokeWidth={2.5} />
          </button>
        }
      />

      {loading ? (
        <div className="h-48 grid place-items-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      ) : jobs.length === 0 ? (
        <div className="px-5 mt-8">
          <div className="glass-strong rounded-3xl p-8 text-center space-y-4">
            <div className="mx-auto h-20 w-20 rounded-full bg-primary-soft grid place-items-center">
              <Briefcase className="h-9 w-9 text-primary" strokeWidth={1.8} />
            </div>
            <div>
              <h3 className="text-lg font-bold text-foreground">No jobs posted yet</h3>
              <p className="text-sm text-muted-foreground mt-1">
                Post your first job or internship to start receiving applications.
              </p>
            </div>
            <button
              onClick={() => setShowPostModal(true)}
              className="inline-flex items-center gap-2 px-6 py-3 rounded-2xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-[0.98] transition-all"
            >
              <Plus className="h-4 w-4" />
              Post a Job
            </button>
          </div>
        </div>
      ) : (
        <div className="px-5 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3.5 mt-2">
          {jobs.map((job) => (
            <div key={job.id} className="glass-strong rounded-2xl overflow-hidden flex flex-col justify-between">
              {/* Main job info — tap to view applications */}
              <button
                onClick={() => { setActiveJobId(job.id); setActiveJobTitle(job.title); }}
                className="w-full p-4 flex items-start gap-3 text-left hover:bg-primary-soft/30 transition-colors"
              >
                <div className="h-11 w-11 rounded-xl bg-gradient-primary grid place-items-center shadow-glow shrink-0">
                  <Briefcase className="h-5 w-5 text-primary-foreground" strokeWidth={2} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-foreground truncate">{job.title}</p>
                  <p className="text-xs text-muted-foreground mt-0.5 flex items-center gap-1.5 truncate">
                    <Code2 className="h-3 w-3 shrink-0" />
                    {job.field}
                  </p>
                  <div className="flex items-center gap-2 mt-1.5 flex-wrap">
                    <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-secondary text-muted-foreground">
                      {job.level}
                    </span>
                    {job.salary && (
                      <span className="text-[11px] font-semibold px-2.5 py-0.5 rounded-full bg-green-50 dark:bg-green-950/50 text-green-700 dark:text-green-400">
                        {job.salary}
                      </span>
                    )}
                  </div>
                </div>
                <ChevronRight className="h-4 w-4 text-muted-foreground mt-1 shrink-0" />
              </button>

              {/* Application count + delete */}
              <div className="border-t border-border/50 px-4 py-2.5 flex items-center justify-between">
                <button
                  onClick={() => { setActiveJobId(job.id); setActiveJobTitle(job.title); }}
                  className="flex items-center gap-1.5 text-xs font-semibold text-primary hover:underline"
                >
                  <Users className="h-3.5 w-3.5" />
                  {job.application_count} application{job.application_count !== 1 ? "s" : ""}
                </button>
                <button
                  onClick={() => deleteJob(job.id)}
                  disabled={deletingId === job.id}
                  className="flex items-center gap-1 text-xs text-muted-foreground hover:text-destructive transition-colors px-2 py-1 rounded-lg hover:bg-destructive/10"
                >
                  {deletingId === job.id
                    ? <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    : <Trash2 className="h-3.5 w-3.5" />}
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {showPostModal && (
        <PostJobModal
          onClose={() => setShowPostModal(false)}
          onCreated={loadJobs}
        />
      )}
    </div>
  );
};
