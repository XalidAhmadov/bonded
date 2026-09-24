import { SuggestedScreen } from "./SuggestedScreen";
import { type ChatListItem } from "./MessagesScreen";

interface NetworkScreenProps {
  onOpenChat: (chat: ChatListItem) => void;
}

export const NetworkScreen = ({ onOpenChat }: NetworkScreenProps) => {
  return (
    <div className="animate-fade-in relative">
      <SuggestedScreen onOpenChat={onOpenChat} />
    </div>
  );
};
