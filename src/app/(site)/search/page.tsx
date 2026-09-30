import type { Metadata } from "next";
import { Search } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

export const metadata: Metadata = { title: "Search" };

export default async function SearchPage({ searchParams }: { searchParams: Promise<{ q?: string }> }) {
  const params = await searchParams;
  const q = params.q?.trim() ?? "";
  return (
    <div className="grid gap-8">
      <div>
        <div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Search</div>
        <h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">Find a record</h1>
      </div>
      <Card className="p-5">
        <form className="flex gap-2" action="/search">
          <Input name="q" defaultValue={q} autoFocus placeholder="Place, report, person, group or source" aria-label="Search records" />
          <button aria-label="Submit search" className="min-h-11 shrink-0 rounded-md bg-[var(--accent)] px-4 text-sm font-medium text-[#1b201b] hover:bg-[var(--accent-strong)]"><Search size={15}/></button>
        </form>
      </Card>
      <Card className="p-6">
        <div className="text-sm font-medium">{q ? `Search execution boundary: “${q}”` : "Search is ready for the Phase 2 PostgreSQL query layer."}</div>
        <p className="mt-2 text-sm leading-6 text-[var(--muted)]">The foundation migration already includes GIN search indexes for places, reports, people, groups and sources. The live query and filter UI is deliberately reserved for Phase 2 so this route never falls back to fake local data.</p>
      </Card>
    </div>
  );
}
