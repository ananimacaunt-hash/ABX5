import { Card } from "@/components/ui/card";
import { requirePermission } from "@/lib/auth/permissions";

export default async function SettingsAdminPage() {
  await requirePermission("settings.manage");
  return (
    <div className="grid gap-7">
      <div><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Control room / settings</div><h1 className="mt-2 text-3xl font-semibold capitalize tracking-[-0.03em]">settings</h1></div>
      <Card className="p-6">
        <div className="text-sm font-medium">Phase 1 module boundary</div>
        <p className="mt-2 max-w-2xl text-sm leading-6 text-[var(--muted)]">This route is real and permission-gated, but the data actions are intentionally not mocked. The module will consume the PostgreSQL tables from the foundation migration in its designated phase.</p>
      </Card>
    </div>
  );
}
