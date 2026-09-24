import { useMemo, useState } from "react";
import { Search, X, Check, Tags, Loader2 } from "lucide-react";
import { useFieldCatalog } from "@/hooks/useFieldCatalog";

const DEFAULT_MAX = 8;

/* ─── Selected chips + "open picker" trigger — used in edit forms ─── */
export const FieldChips = ({
  selectedIds,
  onRemove,
  onOpenPicker,
  max = DEFAULT_MAX,
}: {
  selectedIds: string[];
  onRemove: (fieldId: string) => void;
  onOpenPicker: () => void;
  max?: number;
}) => {
  const { data: catalog } = useFieldCatalog();

  return (
    <>
      {selectedIds.length > 0 && (
        <div className="flex flex-wrap gap-1.5 mb-2">
          {selectedIds.map((id) => {
            const info = catalog?.byId.get(id);
            return (
              <button
                key={id}
                type="button"
                onClick={() => onRemove(id)}
                className="text-[11px] font-semibold px-2.5 py-1 rounded-full bg-primary-soft text-primary flex items-center gap-1 hover:bg-red-50 hover:text-red-600 dark:hover:bg-red-950/50 dark:hover:text-red-400 transition-colors group"
              >
                {info && (
                  <span className="text-[9px] font-bold uppercase tracking-wide opacity-60">
                    {info.category_label} ·
                  </span>
                )}
                {info?.label ?? id}
                <X className="h-2.5 w-2.5 opacity-0 group-hover:opacity-100 transition-opacity" />
              </button>
            );
          })}
        </div>
      )}
      <button
        type="button"
        onClick={onOpenPicker}
        className="w-full flex items-center justify-center gap-1.5 py-2.5 rounded-xl font-semibold text-sm bg-secondary text-foreground hover:bg-primary-soft hover:text-primary transition-colors active:scale-95"
      >
        <Tags className="h-4 w-4" />
        {selectedIds.length > 0 ? `${selectedIds.length} / ${max} selected · Add more` : "Select Fields"}
      </button>
    </>
  );
};

/* ─── Field Picker Modal — category tabs (DB-driven) + search ─── */
export const FieldPickerModal = ({
  selected,
  onToggle,
  onClose,
  max = DEFAULT_MAX,
}: {
  selected: string[];
  onToggle: (fieldId: string) => void;
  onClose: () => void;
  max?: number;
}) => {
  const { data: catalog, isLoading } = useFieldCatalog();
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [search, setSearch] = useState("");

  const categories = catalog?.categories ?? [];
  const currentCategoryId = activeCategory ?? categories[0]?.id ?? null;

  const filtered = useMemo(() => {
    const fieldsInCategory = currentCategoryId ? catalog?.fieldsByCategory.get(currentCategoryId) ?? [] : [];
    const q = search.trim().toLowerCase();
    if (!q) return fieldsInCategory;
    return fieldsInCategory.filter((f) => f.label.toLowerCase().includes(q));
  }, [search, catalog, currentCategoryId]);

  const atMax = selected.length >= max;

  return (
    <div
      className="fixed inset-0 z-50 bg-black/40 grid place-items-center p-5 animate-fade-in"
      onClick={onClose}
    >
      <div
        className="w-full max-w-md sm:max-w-lg glass-strong rounded-3xl p-5 space-y-3 max-h-[80vh] flex flex-col animate-scale-in"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-gradient-primary grid place-items-center shadow-glow">
              <Tags className="h-3.5 w-3.5 text-primary-foreground" />
            </div>
            <h2 className="text-lg font-bold text-foreground">Fields</h2>
            <span className="text-xs font-semibold text-primary bg-primary-soft px-2 py-0.5 rounded-full">
              {selected.length} / {max}
            </span>
          </div>
          <button
            onClick={onClose}
            className="h-8 w-8 grid place-items-center rounded-full hover:bg-secondary"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Category tabs — driven entirely by field_categories, new categories just appear */}
        {categories.length > 0 && (
          <div className="flex gap-1.5 overflow-x-auto pb-1 -mx-1 px-1" style={{ scrollbarWidth: "thin" }}>
            {categories.map((cat) => (
              <button
                key={cat.id}
                type="button"
                onClick={() => { setActiveCategory(cat.id); setSearch(""); }}
                className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-semibold transition-colors ${
                  currentCategoryId === cat.id
                    ? "bg-gradient-primary text-primary-foreground shadow-glow"
                    : "bg-secondary text-muted-foreground hover:bg-primary-soft hover:text-primary"
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>
        )}

        {/* Search */}
        <div className="glass rounded-xl flex items-center gap-2 px-3 py-2.5">
          <Search className="h-4 w-4 text-muted-foreground shrink-0" />
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search fields…"
            className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
            autoFocus
          />
          {search && (
            <button
              onClick={() => setSearch("")}
              className="h-5 w-5 grid place-items-center rounded-full hover:bg-secondary shrink-0"
            >
              <X className="h-3 w-3 text-muted-foreground" />
            </button>
          )}
        </div>

        {/* Fields List */}
        <div className="flex-1 overflow-y-auto space-y-1 -mx-1 px-1" style={{ scrollbarWidth: "thin" }}>
          {isLoading ? (
            <div className="py-8 text-center">
              <Loader2 className="h-5 w-5 animate-spin mx-auto text-primary" />
            </div>
          ) : filtered.length === 0 ? (
            <div className="text-center py-8">
              <Search className="h-8 w-8 mx-auto mb-2 text-muted-foreground/40" />
              <p className="text-sm text-muted-foreground font-semibold">No fields found</p>
              <p className="text-xs text-muted-foreground mt-0.5">Try a different search term</p>
            </div>
          ) : (
            filtered.map((field) => {
              const isSelected = selected.includes(field.id);
              const disabled = !isSelected && atMax;
              return (
                <button
                  key={field.id}
                  type="button"
                  disabled={disabled}
                  onClick={() => onToggle(field.id)}
                  className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-left text-sm transition-all active:scale-[0.99] ${
                    isSelected
                      ? "bg-primary-soft text-primary font-semibold"
                      : disabled
                        ? "text-muted-foreground/50 cursor-not-allowed"
                        : "text-foreground hover:bg-secondary"
                  }`}
                >
                  <div
                    className={`h-5 w-5 rounded-md border-2 grid place-items-center shrink-0 transition-all ${
                      isSelected ? "bg-gradient-primary border-primary shadow-glow" : "border-border"
                    }`}
                  >
                    {isSelected && <Check className="h-3 w-3 text-white" strokeWidth={3} />}
                  </div>
                  <span className="truncate">{field.label}</span>
                </button>
              );
            })
          )}
        </div>

        {/* Done Button */}
        <button
          onClick={onClose}
          className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold shadow-glow active:scale-95 transition-all"
        >
          <Check className="h-4 w-4" />
          Done ({selected.length} selected)
        </button>
      </div>
    </div>
  );
};
