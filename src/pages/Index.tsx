import { useState } from "react";
import { Navigate } from "react-router-dom";
import { BottomNav, type Tab } from "@/components/BottomNav";
import { MessagesScreen, type ChatListItem } from "@/components/screens/MessagesScreen";
import { GroupsScreen } from "@/components/screens/GroupsScreen";
import { ProfileScreen } from "@/components/screens/ProfileScreen";
import { ChatRoom } from "@/components/screens/ChatRoom";
import { GroupDetailScreen } from "@/components/screens/GroupDetailScreen";
import { VerificationGate } from "@/components/screens/VerificationGate";
import { NetworkScreen } from "@/components/screens/NetworkScreen";
import { StudentJobsScreen } from "@/components/screens/StudentJobsScreen";
import AdminPanel from "@/pages/AdminPanel";
import { useAuth } from "@/hooks/useAuth";
import { useGlobalPresence } from "@/hooks/useGlobalPresence";
import { useNotificationCounts } from "@/hooks/useNotificationCounts";
import { Loader2 } from "lucide-react";

const Index = () => {
  const { user, loading, signOut, refreshUser } = useAuth();
  const isOnline = useGlobalPresence(user?.id ?? null);
  const [tab, setTab] = useState<Tab>("network");
  const [activeChat, setActiveChat] = useState<ChatListItem | null>(null);
  const [activeGroupId, setActiveGroupId] = useState<string | null>(null);
  const [showAdminPanel, setShowAdminPanel] = useState(false);

  const { friendRequestCount, unreadMessageCount, unreadSenderCount, groupInvitationCount } = useNotificationCounts(user?.id ?? null);

  // Whether we're in a chat view (private or group) or admin panel
  const isChatOpen = !!activeChat || !!activeGroupId || showAdminPanel;

  if (loading) {
    return (
      <div className="min-h-screen gradient-bg grid place-items-center">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }
  if (!user) return <Navigate to="/auth" replace />;

  // Company accounts have their own portal
  if ((user as any).account_type === "company") return <Navigate to="/company" replace />;

  const verificationStatus = user.verification_status ?? "approved";
  if (verificationStatus === "pending" || verificationStatus === "rejected") {
    return (
      <VerificationGate
        status={verificationStatus}
        userId={user.id}
        signOut={signOut}
        refreshUser={refreshUser}
      />
    );
  }

  return (
    <div className="min-h-screen gradient-bg">
      <main className="mx-auto w-full max-w-5xl min-h-screen pb-28 px-2 sm:px-4 md:px-6 lg:px-8 relative transition-all">
        {tab === "network" && <NetworkScreen onOpenChat={setActiveChat} />}
        {tab === "groups" && <GroupsScreen onOpenGroup={setActiveGroupId} />}
        {tab === "messages" && <MessagesScreen onOpenChat={setActiveChat} />}
        {tab === "jobs" && <StudentJobsScreen />}
        {tab === "profile" && (
          <ProfileScreen onOpenAdmin={user.is_admin ? () => setShowAdminPanel(true) : undefined} />
        )}
      </main>

      {/* Bottom nav is hidden when a chat or group detail is open */}
      {!isChatOpen && (
        <BottomNav
          active={tab}
          onChange={setTab}
          friendRequestCount={friendRequestCount}
          unreadMessageCount={unreadMessageCount}
          unreadSenderCount={unreadSenderCount}
          groupInvitationCount={groupInvitationCount}
        />
      )}

      {/* Admin panel — always mounted for admins so data preloads in background */}
      {user.is_admin && (
        <div className={showAdminPanel ? "fixed inset-0 z-50" : "hidden"}>
          <AdminPanel onBack={() => setShowAdminPanel(false)} />
        </div>
      )}

      {activeChat && (
        <ChatRoom
          chat={activeChat}
          meId={user.id}
          isOnline={isOnline}
          onBack={() => setActiveChat(null)}
        />
      )}

      {activeGroupId && (
        <GroupDetailScreen
          groupId={activeGroupId}
          onBack={() => setActiveGroupId(null)}
        />
      )}
    </div>
  );
};

export default Index;
