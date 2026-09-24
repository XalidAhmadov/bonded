import { useEffect, useState } from "react";
import { ArrowLeft, Loader2, Users, GraduationCap, Code2, User } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { StudentProfileModal } from "./StudentProfileModal";
import { toast } from "sonner";

interface Application {
  id: string;
  student_id: string;
  message: string | null;
  created_at: string;
  profile: {
    id: string;
    first_name: string;
    last_name: string;
    avatar_url: string | null;
    bio: string | null;
    interests: string[] | null;
    universities: { name: string } | null;
    specialties: { name: string } | null;
    entrance_score: number | null;
    profession: string | null;
    year: string | null;
  } | null;
}

interface JobApplicationsViewProps {
  jobId: string;
  jobTitle: string;
  onBack: () => void;
}

export const JobApplicationsView = ({ jobId, jobTitle, onBack }: JobApplicationsViewProps) => {
  const [applications, setApplications] = useState<Application[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedStudent, setSelectedStudent] = useState<Application["profile"] | null>(null);
  const [selectedMessage, setSelectedMessage] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      setLoading(true);
      try {
        const { data: rawApps, error: rawErr } = await (supabase.from("job_applications") as any)
          .select("id, student_id, message, created_at")
          .eq("job_id", jobId)
          .order("created_at", { ascending: false });

        if (rawErr) throw rawErr;

        if (rawApps && rawApps.length > 0) {
          const studentIds = rawApps.map((a: any) => a.student_id);
          const { data: profs, error: profErr } = await (supabase.from("profiles") as any)
            .select(`
              id, first_name, last_name, avatar_url, bio, interests, 
              entrance_score, profession, year, 
              universities(name), specialties(name)
            `)
            .in("id", studentIds);

          if (profErr) throw profErr;

          const profMap = new Map((profs ?? []).map((pr: any) => [pr.id, pr]));
          setApplications(
            rawApps.map((a: any) => ({
              ...a,
              profile: profMap.get(a.student_id) ?? null,
            }))
          );
        } else {
          setApplications([]);
        }
      } catch (err: any) {
        toast.error("Failed to load applications");
        console.error("[JobApplicationsView] Error loading applications:", err);
      } finally {
        setLoading(false);
      }
    })();
  }, [jobId]);

  const openStudent = (app: Application) => {
    const p = app.profile || (app as any).profiles;
    if (!p) return;
    setSelectedStudent(p);
    setSelectedMessage(app.message);
  };

  return (
    <div className="animate-fade-in pb-4">
      {/* Header */}
      <div className="px-5 pt-5 pb-3 flex items-center gap-3">
        <button
          onClick={onBack}
          className="h-10 w-10 grid place-items-center rounded-full glass active:scale-95 transition-transform shrink-0"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <div className="min-w-0">
          <h2 className="text-lg font-bold text-foreground truncate">{jobTitle}</h2>
          <p className="text-xs text-muted-foreground">Applications</p>
        </div>
      </div>

      {loading ? (
        <div className="h-48 grid place-items-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      ) : applications.length === 0 ? (
        <div className="h-48 flex flex-col items-center justify-center gap-3 px-6 text-center">
          <div className="h-16 w-16 rounded-full bg-secondary grid place-items-center">
            <Users className="h-7 w-7 text-muted-foreground" />
          </div>
          <p className="font-semibold text-foreground">No applications yet</p>
          <p className="text-sm text-muted-foreground">Students who apply will appear here.</p>
        </div>
      ) : (
        <div className="px-5">
          <p className="text-xs font-semibold text-muted-foreground mb-3">
            {applications.length} application{applications.length !== 1 ? "s" : ""}
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
            {applications.map((app) => {
              const p = app.profile || (app as any).profiles;
              if (!p) return null;
              const avatar =
                p.avatar_url ??
                `https://api.dicebear.com/7.x/avataaars/svg?seed=${p.id}`;
              return (
                <button
                  key={app.id}
                  onClick={() => openStudent(app)}
                  className="w-full glass-strong rounded-2xl p-4 flex items-center gap-3 text-left hover:scale-[1.01] active:scale-[0.99] transition-all"
                >
                  <img
                    src={avatar}
                    alt={p.first_name}
                    className="h-12 w-12 rounded-full bg-white object-cover shrink-0 border-2 border-primary/20"
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-foreground truncate">
                      {p.first_name} {p.last_name}
                    </p>
                    {p.universities?.name && (
                      <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5 truncate">
                        <GraduationCap className="h-3 w-3 shrink-0" />
                        {p.universities.name}
                      </p>
                    )}
                    {p.interests && p.interests.length > 0 && (
                      <p className="text-xs text-primary flex items-center gap-1 mt-0.5 truncate">
                        <Code2 className="h-3 w-3 shrink-0" />
                        {p.interests.slice(0, 2).join(", ")}
                        {p.interests.length > 2 ? ` +${p.interests.length - 2}` : ""}
                      </p>
                    )}
                  </div>
                  <User className="h-4 w-4 text-muted-foreground shrink-0" />
                </button>
              );
            })}
          </div>
        </div>
      )}

      {selectedStudent && (
        <StudentProfileModal
          student={selectedStudent}
          applicationMessage={selectedMessage}
          onClose={() => { setSelectedStudent(null); setSelectedMessage(null); }}
        />
      )}
    </div>
  );
};
