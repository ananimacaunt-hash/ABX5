import Link from "next/link";
import { ArrowUpRight, Archive, Clock3, FileText, MapPin, Search, ShieldCheck } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

const signals = [
  { label: "Objects", value: "—", note: "Connect Supabase to load live archive counts." },
  { label: "Reports", value: "—", note: "The report pipeline is introduced in Phase 3." },
  { label: "Sources", value: "—", note: "Source-first records arrive in the archive phase." },
];

export default function HomePage() {
  return (
    <div className="grid gap-10">
      <section className="archive-grid overflow-hidden rounded-2xl border border-[var(--line)] bg-[var(--surface)]">
        <div className="grid gap-10 px-5 py-8 sm:px-8 sm:py-10 lg:grid-cols-[1.4fr_.6fr] lg:px-12 lg:py-14">
          <div>
            <div className="mb-5 flex flex-wrap items-center gap-2"><Badge tone="accent">Community archive</Badge><span className="text-xs text-[var(--faint)]">Foundation / Phase 1</span></div>
            <h1 className="max-w-4xl text-4xl font-semibold tracking-[-0.04em] sm:text-5xl lg:text-6xl">Preserve the record.<br />Leave the risk behind.</h1>
            <p className="mt-6 max-w-2xl text-base leading-7 text-[var(--muted)] sm:text-lg">Abandix brings abandoned places, field reports, histories and original sources into a structured archive. The goal is not ownership of a location. It is continuity of knowledge.</p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link href="/explore" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-md border border-[var(--line-strong)] bg-[var(--surface-2)] px-4 text-sm font-medium hover:bg-[var(--surface-3)]">Explore archive <ArrowUpRight size={15} /></Link>
              <Link href="/guidelines" className="inline-flex min-h-11 items-center justify-center rounded-md px-4 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">Read documentation guidelines</Link>
            </div>
          </div>
          <div className="lg:border-l lg:border-[var(--line)] lg:pl-10">
            <div className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Archive signal</div>
            <div className="mt-4 grid divide-y divide-[var(--line)] rounded-xl border border-[var(--line)] bg-[var(--surface-2)]">
              {signals.map((signal) => <div key={signal.label} className="grid grid-cols-[5rem_1fr] gap-4 p-4 sm:grid-cols-[6rem_1fr]"><div className="font-mono text-2xl text-[var(--text)]">{signal.value}</div><div><div className="text-sm font-medium">{signal.label}</div><p className="mt-1 text-xs leading-5 text-[var(--faint)]">{signal.note}</p></div></div>)}
            </div>
          </div>
        </div>
      </section>

      <section className="grid gap-4 lg:grid-cols-[1fr_1fr]">
        <Card className="overflow-hidden">
          <div className="border-b border-[var(--line)] px-5 py-4"><div className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Start with a place</div><h2 className="mt-1 text-2xl font-semibold tracking-[-0.02em]">Build a history, not a bookmark.</h2></div>
          <div className="grid gap-3 p-5">
            {[['Place record','Identity, type, condition, visibility and authorship'],['Timeline','Events and state changes with dates and sources'],['Evidence','Reports, original links, citations and corrections']].map(([title,note]) => <div key={title} className="flex gap-3 rounded-lg border border-[var(--line)] bg-[var(--surface-2)] p-4"><MapPin size={17} className="mt-0.5 shrink-0 text-[var(--accent)]"/><div><div className="text-sm font-medium">{title}</div><div className="mt-1 text-sm leading-6 text-[var(--muted)]">{note}</div></div></div>)}
          </div>
        </Card>
        <Card className="overflow-hidden">
          <div className="border-b border-[var(--line)] px-5 py-4"><div className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Find the record</div><h2 className="mt-1 text-2xl font-semibold tracking-[-0.02em]">Search without the noise.</h2></div>
          <div className="p-5">
            <form action="/search" className="flex gap-2"><div className="relative flex-1"><Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--faint)]"/><Input name="q" className="pl-9" placeholder="Place, report, person, source…" aria-label="Search Abandix" /></div><button className="min-h-11 rounded-md border border-[var(--line-strong)] bg-[var(--surface-3)] px-4 text-sm font-medium hover:bg-[var(--surface-2)]">Search</button></form>
            <div className="mt-6 grid gap-3 text-sm text-[var(--muted)]"><Link href="/explore" className="flex items-center justify-between rounded-lg border border-[var(--line)] px-4 py-3 hover:bg-[var(--surface-2)]"><span className="flex items-center gap-3"><Archive size={16} />Browse places</span><ArrowUpRight size={14}/></Link><Link href="/reports" className="flex items-center justify-between rounded-lg border border-[var(--line)] px-4 py-3 hover:bg-[var(--surface-2)]"><span className="flex items-center gap-3"><FileText size={16} />Browse reports</span><ArrowUpRight size={14}/></Link></div>
          </div>
        </Card>
      </section>

      <section className="grid gap-4 sm:grid-cols-3">
        {[['Documentary first','Facts, claims, dates and sources stay visibly separated.'],['Coordinate-aware','Exact sensitive locations live outside the public location dataset.'],['Moderated archive','Corrections and reports create a history of what changed — and why.']].map(([title,text], index) => <div key={title} className="rounded-xl border border-[var(--line)] bg-[var(--surface)] p-5"><div className="mb-4 text-xs font-mono text-[var(--faint)]">0{index+1}</div><div className="flex items-center gap-2 text-sm font-medium"><ShieldCheck size={15} className="text-[var(--accent)]"/>{title}</div><p className="mt-2 text-sm leading-6 text-[var(--muted)]">{text}</p></div>)}
      </section>

      <section className="border-t border-[var(--line)] pt-8">
        <div className="flex flex-wrap items-center justify-between gap-4"><div><div className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Archive principle</div><p className="mt-2 max-w-2xl text-sm leading-6 text-[var(--muted)]">The visible record should outlive the visit. Abandix treats reports as evidence, sources as provenance and corrections as part of the history.</p></div><div className="flex items-center gap-2 text-xs text-[var(--faint)]"><Clock3 size={14}/>Structured data, not a disposable feed.</div></div>
      </section>
    </div>
  );
}
