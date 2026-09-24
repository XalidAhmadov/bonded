import { useState } from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { Loader2 } from "lucide-react";
import { CompanyBottomNav, type CompanyTab } from "@/components/company/CompanyBottomNav";
import { CompanyJobsScreen } from "@/components/company/CompanyJobsScreen";
import { CompanyStudentSearch } from "@/components/company/CompanyStudentSearch";
import { CompanyProfileScreen } from "@/components/company/CompanyProfileScreen";

const CompanyPortal = () => {
  const { user, loading } = useAuth();
  const [tab, setTab] = useState<CompanyTab>("jobs");

  if (loading) {
    return (
      <div className="min-h-screen gradient-bg grid place-items-center">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) return <Navigate to="/auth" replace />;

  // Only company accounts can access the company portal
  if ((user as any).account_type !== "company") {
    return <Navigate to="/" replace />;
  }

  return (
    <div className="company-theme">
      <div className="min-h-screen gradient-bg">
        <main className="mx-auto w-full max-w-5xl min-h-screen pb-28 px-2 sm:px-4 md:px-6 lg:px-8 relative transition-all">
          {tab === "jobs" && <CompanyJobsScreen />}
          {tab === "search" && <CompanyStudentSearch />}
          {tab === "profile" && <CompanyProfileScreen />}
          <CompanyBottomNav active={tab} onChange={setTab} />
        </main>
      </div>
    </div>
  );
};

export default CompanyPortal;

