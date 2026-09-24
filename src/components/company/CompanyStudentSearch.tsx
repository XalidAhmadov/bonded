import { useEffect, useState, useCallback, useMemo } from "react";
import { Search, Loader2, Users, ChevronDown, X } from "lucide-react";
import { AppHeader } from "@/components/AppHeader";
import { supabase } from "@/integrations/supabase/client";
import { IT_FIELDS } from "@/lib/itFields";
import { StudentProfileModal } from "./StudentProfileModal";

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

export const CompanyStudentSearch = () => {
  const [students, setStudents] = useState<StudentProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedField, setSelectedField] = useState("");
  const [selectedStudent, setSelectedStudent] = useState<StudentProfile | null>(null);

  const loadStudents = useCallback(async () => {
    setLoading(true);
    try {
      const query = (supabase.from("profiles") as any)
        .select(
          "id, first_name, last_name, avatar_url, bio, interests, entrance_score, profession, year, universities(name), specialties(name)"
        )
        .or("account_type.eq.student,account_type.is.null")
        .eq("verification_status", "approved")
        .order("created_at", { ascending: false })
        .limit(200);

      const { data, error } = await query;
      if (error) throw error;
      setStudents(data ?? []);
    } catch (err: any) {
      console.error("[CompanyStudentSearch] load error:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadStudents(); }, [loadStudents]);

  // Client-side filtering (fast for typical list sizes)
  const filtered = useMemo(() => {
    let list = students;

    // Filter by IT field
    if (selectedField) {
      list = list.filter(
        (s) => s.interests && s.interests.includes(selectedField)
      );
    }

    // Filter by name search
    const q = searchQuery.trim().toLowerCase();
    if (q) {
      list = list.filter((s) =>
        `${s.first_name} ${s.last_name}`.toLowerCase().includes(q)
      );
    }

    return list;
  }, [students, selectedField, searchQuery]);

  return (
    <div className="animate-fade-in pb-4">
      <AppHeader subtitle="Company" title="Browse Students" />

      {/* Filters */}
      <div className="px-5 mt-2 space-y-2">
        {/* Name search */}
        <div className="flex items-center gap-2 glass rounded-2xl px-4 py-3">
          <Search className="h-4 w-4 text-muted-foreground shrink-0" />
          <input
            type="search"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by name…"
            className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery("")}
              className="h-5 w-5 grid place-items-center rounded-full hover:bg-secondary shrink-0"
            >
              <X className="h-3 w-3 text-muted-foreground" />
            </button>
          )}
        </div>

        {/* Field filter */}
        <div className="relative">
          <select
            value={selectedField}
            onChange={(e) => setSelectedField(e.target.value)}
            className={`w-full bg-secondary rounded-2xl px-4 py-3 text-sm outline-none focus:ring-2 focus:ring-primary/40 appearance-none pr-10 cursor-pointer transition-colors ${
              selectedField ? "text-foreground" : "text-muted-foreground"
            }`}
          >
            <option value="">All IT Fields</option>
            {IT_FIELDS.map((f) => (
              <option key={f} value={f}>{f}</option>
            ))}
          </select>
          <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
        </div>

        {/* Result count */}
        <p className="text-xs text-muted-foreground px-1">
          {loading ? "Loading…" : `${filtered.length} student${filtered.length !== 1 ? "s" : ""} found`}
          {selectedField && !loading && ` in "${selectedField}"`}
        </p>
      </div>

      {/* Results */}
      {loading ? (
        <div className="h-48 grid place-items-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </div>
      ) : filtered.length === 0 ? (
        <div className="h-48 flex flex-col items-center justify-center gap-3 px-6 text-center">
          <div className="h-16 w-16 rounded-full bg-secondary grid place-items-center">
            <Users className="h-7 w-7 text-muted-foreground" />
          </div>
          <p className="font-semibold text-foreground">No students found</p>
          <p className="text-sm text-muted-foreground">
            {selectedField ? `No students have selected "${selectedField}" as their field.` : "Try adjusting your search."}
          </p>
        </div>
      ) : (
        <div className="px-5 mt-2 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
          {filtered.map((student) => {
            const avatar =
              student.avatar_url ??
              `https://api.dicebear.com/7.x/avataaars/svg?seed=${student.id}`;
            return (
              <button
                key={student.id}
                onClick={() => setSelectedStudent(student)}
                className="w-full glass-strong rounded-2xl p-4 flex items-center gap-3 text-left hover:scale-[1.01] active:scale-[0.99] transition-all"
              >
                <img
                  src={avatar}
                  alt={student.first_name}
                  className="h-12 w-12 rounded-full bg-white object-cover shrink-0 border-2 border-primary/20"
                />
                <div className="flex-1 min-w-0">
                  <p className="font-semibold text-foreground truncate">
                    {student.first_name} {student.last_name}
                  </p>
                  {student.universities?.name && (
                    <p className="text-xs text-muted-foreground truncate mt-0.5">
                      {student.universities.name}
                    </p>
                  )}
                  {student.interests && student.interests.length > 0 && (
                    <div className="flex gap-1.5 mt-1.5 flex-wrap">
                      {student.interests.slice(0, 3).map((tag) => (
                        <span
                          key={tag}
                          className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${
                            tag === selectedField
                              ? "bg-primary text-primary-foreground"
                              : "bg-primary-soft text-primary"
                          }`}
                        >
                          {tag}
                        </span>
                      ))}
                      {student.interests.length > 3 && (
                        <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-secondary text-muted-foreground">
                          +{student.interests.length - 3}
                        </span>
                      )}
                    </div>
                  )}
                </div>
              </button>
            );
          })}
        </div>
      )}

      {selectedStudent && (
        <StudentProfileModal
          student={selectedStudent}
          onClose={() => setSelectedStudent(null)}
        />
      )}
    </div>
  );
};
