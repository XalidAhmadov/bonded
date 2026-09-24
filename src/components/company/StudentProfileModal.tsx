import { useState } from "react";
import {
  X, GraduationCap, BookOpen, Code2, Trophy,
  Briefcase, Calendar, FileText, Loader2,
} from "lucide-react";

interface StudentProfile {
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
}

interface StudentProfileModalProps {
  student: StudentProfile;
  onClose: () => void;
  // Optional: message sent with the application
  applicationMessage?: string | null;
}

export const StudentProfileModal = ({ student, onClose, applicationMessage }: StudentProfileModalProps) => {
  const avatar =
    student.avatar_url ??
    `https://api.dicebear.com/7.x/avataaars/svg?seed=${student.id}`;

  return (
    <div
      className="fixed inset-0 z-[60] bg-black/50 grid place-items-center p-5 animate-fade-in"
      onClick={onClose}
    >
      <div
        className="w-full max-w-md sm:max-w-lg bg-background rounded-3xl overflow-hidden shadow-2xl animate-scale-in flex flex-col max-h-[90vh]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Close button */}
        <div className="flex justify-end p-4 pb-0 shrink-0">
          <button
            onClick={onClose}
            className="h-9 w-9 grid place-items-center rounded-full glass hover:bg-secondary"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="overflow-y-auto flex-1 px-6 pb-6 space-y-4" style={{ scrollbarWidth: "none" }}>
          {/* Avatar + Name */}
          <div className="text-center">
            <div className="mx-auto h-24 w-24 rounded-full bg-gradient-primary p-[3px] shadow-glow">
              <img
                src={avatar}
                alt={student.first_name}
                className="h-full w-full rounded-full bg-white object-cover"
              />
            </div>
            <h2 className="mt-4 text-2xl font-bold text-foreground">
              {student.first_name}{" "}
              <span className="text-primary">{student.last_name}</span>
            </h2>

            {student.profession && (
              <div className="mt-2 inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-accent">
                <Briefcase className="h-3.5 w-3.5 text-primary" strokeWidth={2.4} />
                <span className="text-sm font-semibold text-primary">{student.profession}</span>
              </div>
            )}
          </div>

          {/* Academic info */}
          <div className="space-y-2">
            {student.universities?.name && (
              <div className="flex items-center gap-3 px-4 py-3 rounded-2xl bg-secondary/60">
                <GraduationCap className="h-4 w-4 text-primary shrink-0" strokeWidth={2.4} />
                <div>
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">University</p>
                  <p className="text-sm font-medium text-foreground">{student.universities.name}</p>
                </div>
              </div>
            )}
            {student.specialties?.name && (
              <div className="flex items-center gap-3 px-4 py-3 rounded-2xl bg-secondary/60">
                <BookOpen className="h-4 w-4 text-primary shrink-0" strokeWidth={2.4} />
                <div>
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Specialty</p>
                  <p className="text-sm font-medium text-foreground">
                    {[student.specialties.name, student.year].filter(Boolean).join(" · ")}
                  </p>
                </div>
              </div>
            )}
            {student.entrance_score != null && student.entrance_score > 0 && (
              <div className="flex items-center gap-3 px-4 py-3 rounded-2xl bg-amber-50 dark:bg-amber-950/50">
                <Trophy className="h-4 w-4 text-amber-500 shrink-0" strokeWidth={2.4} />
                <div>
                  <p className="text-[10px] font-semibold text-muted-foreground uppercase tracking-wider">Entrance Score</p>
                  <p className="text-sm font-bold text-amber-600 dark:text-amber-400">{student.entrance_score}</p>
                </div>
              </div>
            )}
          </div>

          {/* Bio */}
          {student.bio && (
            <div>
              <h3 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-2 flex items-center gap-1.5">
                <FileText className="h-3.5 w-3.5" /> About
              </h3>
              <p className="text-sm text-foreground/80 leading-relaxed">{student.bio}</p>
            </div>
          )}

          {/* IT Fields */}
          {student.interests && student.interests.length > 0 && (
            <div>
              <h3 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-2 flex items-center gap-1.5">
                <Code2 className="h-3.5 w-3.5" /> IT Fields
              </h3>
              <div className="flex flex-wrap gap-2">
                {student.interests.map((tag) => (
                  <span
                    key={tag}
                    className="px-3 py-1.5 rounded-xl bg-primary-soft text-primary text-xs font-semibold"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Application message if provided */}
          {applicationMessage && (
            <div>
              <h3 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-2 flex items-center gap-1.5">
                <Calendar className="h-3.5 w-3.5" /> Cover Letter / Message
              </h3>
              <p className="text-sm text-foreground/80 leading-relaxed bg-secondary/60 rounded-xl px-4 py-3">
                {applicationMessage}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
