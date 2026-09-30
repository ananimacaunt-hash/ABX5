"use client";

import Link from "next/link";
import { LayoutDashboard, MoreHorizontal, Shield } from "lucide-react";
import { useState } from "react";
import type { PermissionKey } from "@/types/domain";

export function MobileAdminNav({ permissions }: { permissions: PermissionKey[] }) {
  const [open, setOpen] = useState(false);
  const extra = [
    ["/admin/reports", "Reports", "content.moderate"],
    ["/admin/places", "Places", "places.manage"],
    ["/admin/users", "Users", "users.manage"],
    ["/admin/moderation", "Moderation", "content.moderate"],
    ["/admin/logs", "Audit logs", "audit.read"],
    ["/admin/settings", "Settings", "settings.manage"],
  ] as const;
  return (
    <div className="fixed inset-x-0 bottom-0 z-50 border-t border-[var(--line)] bg-[color:var(--surface)/0.98] p-2 lg:hidden">
      <div className="grid grid-cols-3 gap-1">
        <Link href="/admin" className="flex min-h-12 flex-col items-center justify-center gap-1 rounded-md text-[11px] text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]"><LayoutDashboard size={17}/><span>Dashboard</span></Link>
        <Link href="/admin/moderation" className="flex min-h-12 flex-col items-center justify-center gap-1 rounded-md text-[11px] text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]"><Shield size={17}/><span>Moderation</span></Link>
        <button onClick={() => setOpen((v) => !v)} className="flex min-h-12 flex-col items-center justify-center gap-1 rounded-md text-[11px] text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]"><MoreHorizontal size={17}/><span>More</span></button>
      </div>
      {open && <div className="absolute inset-x-2 bottom-16 grid gap-1 rounded-xl border border-[var(--line)] bg-[var(--surface)] p-2 shadow-2xl">
        {extra.filter(([, , permission]) => permissions.includes(permission)).map(([href, label]) => <Link onClick={() => setOpen(false)} key={href} href={href} className="rounded-md px-3 py-3 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">{label}</Link>)}
      </div>}
    </div>
  );
}
