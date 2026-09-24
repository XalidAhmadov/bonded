import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export interface ProfileFieldTag {
  field_id: string;
  label: string;
  category_id: string;
  category_label: string;
}

async function fetchProfileFields(userId: string): Promise<ProfileFieldTag[]> {
  const { data, error } = await (supabase.from("profile_fields") as any)
    .select("field_id, fields(label, category_id, field_categories(label))")
    .eq("user_id", userId);
  if (error) throw error;

  return (data ?? []).map((row: any) => ({
    field_id: row.field_id,
    label: row.fields?.label ?? row.field_id,
    category_id: row.fields?.category_id ?? "",
    category_label: row.fields?.field_categories?.label ?? "",
  }));
}

export function useProfileFields(userId: string | null | undefined) {
  return useQuery({
    queryKey: ["profile-fields", userId],
    queryFn: () => fetchProfileFields(userId as string),
    enabled: !!userId,
  });
}

// Replaces a profile's full field selection atomically via the
// set_profile_fields RPC (validates ids + the 8-field cap, and leaves the
// previous selection untouched if it fails). Used on profile save and on
// signup — this is the only write path to profile_fields from the client.
export function useSaveProfileFields() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ userId, fieldIds }: { userId: string; fieldIds: string[] }) => {
      const { error } = await (supabase.rpc as any)("set_profile_fields", {
        p_user_id: userId,
        p_field_ids: fieldIds,
      });
      if (error) throw error;
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["profile-fields", variables.userId] });
    },
  });
}
