import { supabase } from "@/integrations/supabase/client";

// Fire-and-forget: refreshes a profile's recommendation embedding after a
// bio/fields change (or on signup). Never throws — a failure here must not
// affect the caller's own save/signup flow.
export function triggerProfileEmbed(userId: string) {
  supabase.functions.invoke("embed-profile", { body: { user_id: userId } }).catch((err) => {
    console.error("[embed-profile] trigger failed:", err);
  });
}
