import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export interface FieldCategory {
  id: string;
  label: string;
  sort_order: number;
}

export interface FieldOption {
  id: string;
  label: string;
  category_id: string;
}

export interface FieldCatalogEntry extends FieldOption {
  category_label: string;
}

export interface FieldCatalog {
  categories: FieldCategory[];
  fieldsByCategory: Map<string, FieldOption[]>;
  byId: Map<string, FieldCatalogEntry>;
}

async function fetchFieldCatalog(): Promise<FieldCatalog> {
  const [{ data: categories, error: catErr }, { data: fields, error: fieldErr }] = await Promise.all([
    (supabase.from("field_categories") as any)
      .select("id, label, sort_order")
      .eq("is_active", true)
      .order("sort_order", { ascending: true }),
    (supabase.from("fields") as any)
      .select("id, label, category_id, sort_order")
      .eq("is_active", true)
      .order("sort_order", { ascending: true }),
  ]);
  if (catErr) throw catErr;
  if (fieldErr) throw fieldErr;

  const categoryLabelById = new Map<string, string>((categories ?? []).map((c: any) => [c.id, c.label]));
  const fieldsByCategory = new Map<string, FieldOption[]>();
  const byId = new Map<string, FieldCatalogEntry>();

  (fields ?? []).forEach((f: any) => {
    const option: FieldOption = { id: f.id, label: f.label, category_id: f.category_id };
    if (!fieldsByCategory.has(f.category_id)) fieldsByCategory.set(f.category_id, []);
    fieldsByCategory.get(f.category_id)!.push(option);
    byId.set(f.id, { ...option, category_label: categoryLabelById.get(f.category_id) ?? f.category_id });
  });

  return { categories: categories ?? [], fieldsByCategory, byId };
}

// Field categories/fields rarely change — cache generously.
export function useFieldCatalog() {
  return useQuery({
    queryKey: ["field-catalog"],
    queryFn: fetchFieldCatalog,
    staleTime: 10 * 60 * 1000,
  });
}
