import type { LucideIcon } from "lucide-react";
import { Activity, Clock3, FileWarning, MapPin, ShieldCheck, UsersRound } from "lucide-react";

import { Card } from "@/components/ui/card";

type AdminModule = {
  label: string;
  note: string;
};

type AdminPanel = {
  title: string;
  text: string;
  icon: LucideIcon;
};

const modules: AdminModule[] = [
  { label: "Pending reports", note: "Queue is connected to public.content_reports." },
  { label: "Pending submissions", note: "Moderation states live on content tables; no local mock state." },
  { label: "New places", note: "Places are created as draft/pending unless a privileged workflow publishes them." },
  { label: "Technical metadata", note: "Restricted to moderation permissions and retention policy." },
];

const panels: AdminPanel[] = [
  { title: "Review queue", text: "Start with reports, corrections and moderation decisions.", icon: FileWarning },
  { title: "Archive integrity", text: "Place state changes and source provenance are designed to remain auditable.", icon: MapPin },
  { title: "Accounts", text: "Profiles use pseudonyms; privileged roles are modeled separately.", icon: UsersRound },
];

export default function AdminDashboard() {
  return (
    <div className="grid gap-7">
      <div>
        <div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Control room / Overview</div>
        <div className="mt-2 flex flex-wrap items-end justify-between gap-3">
          <h1 className="text-3xl font-semibold tracking-[-0.03em]">Abandix operations</h1>
          <span className="inline-flex items-center gap-2 text-xs text-[var(--faint)]">
            <Activity size={14} aria-hidden="true" />
            live permissions, not UI flags
          </span>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {modules.map((module, i) => (
          <Card key={module.label} className="p-5">
            <div className="flex items-center justify-between">
              <span className="text-xs uppercase tracking-[0.14em] text-[var(--faint)]">0{i + 1}</span>
              <ShieldCheck size={15} className="text-[var(--accent)]" aria-hidden="true" />
            </div>
            <div className="mt-7 text-sm font-medium">{module.label}</div>
            <p className="mt-2 text-sm leading-6 text-[var(--muted)]">{module.note}</p>
          </Card>
        ))}
      </div>

      <section className="grid gap-4 lg:grid-cols-3">
        {panels.map(({ title, text, icon: Icon }) => (
          <Card key={title} className="p-5">
            <Icon size={18} className="text-[var(--accent)]" aria-hidden="true" />
            <div className="mt-4 font-medium">{title}</div>
            <p className="mt-2 text-sm leading-6 text-[var(--muted)]">{text}</p>
          </Card>
        ))}
      </section>

      <div className="flex items-center gap-2 border-t border-[var(--line)] pt-5 text-xs text-[var(--faint)]">
        <Clock3 size={14} aria-hidden="true" />
        Phase 1 establishes the control room shell; content review tools are implemented against the same schema in Phase 5.
      </div>
    </div>
  );
}
