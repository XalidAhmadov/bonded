import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { FieldPickerModal, FieldChips } from "./FieldPicker";
import { useFieldCatalog, type FieldCatalog } from "@/hooks/useFieldCatalog";

vi.mock("@/hooks/useFieldCatalog", async () => {
  const actual = await vi.importActual<typeof import("@/hooks/useFieldCatalog")>(
    "@/hooks/useFieldCatalog"
  );
  return { ...actual, useFieldCatalog: vi.fn() };
});

const mockCatalog: FieldCatalog = {
  categories: [
    { id: "it", label: "IT", sort_order: 1 },
    { id: "business", label: "Business", sort_order: 2 },
  ],
  fieldsByCategory: new Map([
    [
      "it",
      [
        { id: "it-a", label: "Field A", category_id: "it" },
        { id: "it-b", label: "Field B", category_id: "it" },
        { id: "it-c", label: "Field C", category_id: "it" },
      ],
    ],
    ["business", [{ id: "biz-a", label: "Biz A", category_id: "business" }]],
  ]),
  byId: new Map([
    ["it-a", { id: "it-a", label: "Field A", category_id: "it", category_label: "IT" }],
    ["it-b", { id: "it-b", label: "Field B", category_id: "it", category_label: "IT" }],
    ["it-c", { id: "it-c", label: "Field C", category_id: "it", category_label: "IT" }],
    ["biz-a", { id: "biz-a", label: "Biz A", category_id: "business", category_label: "Business" }],
  ]),
};

const fillerIds = (n: number) => Array.from({ length: n }, (_, i) => `filler-${i}`);

describe("FieldPickerModal — 8 field limit", () => {
  beforeEach(() => {
    vi.mocked(useFieldCatalog).mockReturnValue({ data: mockCatalog, isLoading: false } as any);
  });

  it("disables unselected fields once 8 are selected", () => {
    const onToggle = vi.fn();
    render(<FieldPickerModal selected={fillerIds(8)} onToggle={onToggle} onClose={() => {}} />);

    const fieldButton = screen.getByRole("button", { name: "Field A" });
    expect(fieldButton).toBeDisabled();

    fireEvent.click(fieldButton);
    expect(onToggle).not.toHaveBeenCalled();
  });

  it("still allows deselecting an already-selected field while at the cap", () => {
    const onToggle = vi.fn();
    const selected = ["it-a", ...fillerIds(7)];
    render(<FieldPickerModal selected={selected} onToggle={onToggle} onClose={() => {}} />);

    const fieldButton = screen.getByRole("button", { name: "Field A" });
    expect(fieldButton).not.toBeDisabled();

    fireEvent.click(fieldButton);
    expect(onToggle).toHaveBeenCalledWith("it-a");
  });

  it("allows selecting a new field while under the cap", () => {
    const onToggle = vi.fn();
    render(<FieldPickerModal selected={fillerIds(3)} onToggle={onToggle} onClose={() => {}} />);

    const fieldButton = screen.getByRole("button", { name: "Field A" });
    expect(fieldButton).not.toBeDisabled();

    fireEvent.click(fieldButton);
    expect(onToggle).toHaveBeenCalledWith("it-a");
  });

  it("respects a custom max", () => {
    const onToggle = vi.fn();
    render(
      <FieldPickerModal selected={fillerIds(2)} onToggle={onToggle} onClose={() => {}} max={2} />
    );

    const fieldButton = screen.getByRole("button", { name: "Field A" });
    expect(fieldButton).toBeDisabled();
  });
});

describe("FieldChips — 8 field limit counter", () => {
  beforeEach(() => {
    vi.mocked(useFieldCatalog).mockReturnValue({ data: mockCatalog, isLoading: false } as any);
  });

  it("shows the count against the max once the cap is reached", () => {
    render(
      <FieldChips selectedIds={fillerIds(8)} onRemove={() => {}} onOpenPicker={() => {}} />
    );
    expect(screen.getByText(/8 \/ 8 selected/)).toBeInTheDocument();
  });

  it("prompts to select fields when none are chosen", () => {
    render(<FieldChips selectedIds={[]} onRemove={() => {}} onOpenPicker={() => {}} />);
    expect(screen.getByText("Select Fields")).toBeInTheDocument();
  });
});
