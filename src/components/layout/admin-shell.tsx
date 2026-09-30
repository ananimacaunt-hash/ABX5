import type { ReactNode } from "react";
import { ShieldCheck } from "lucide-react";
import { BrandMark } from "./brand-mark";
import { SignOutButton } from "@/components/auth/sign-out-button";
import { AdminNav } from "./admin-nav";
import { MobileAdminNav } from "./mobile-admin-nav";
import type { PermissionKey } from "@/types/domain";

export function AdminShell({ children, permissions }: { children: ReactNode; permissions: PermissionKey[] }) {
  return (
    <div className="min-h-screen bg-[var(--background)] text-[var(--text)]">
      <header className="sticky top-0 z-40 flex min-h-16 items-center justify-between border-b border-[var(--line)] bg-[color:var(--surface)/0.96] px-4 backdrop-blur-xl sm:px-6">
        <div className="flex items-center gap-4"><BrandMark /><span className="hidden text-xs uppercase tracking-[0.18em] text-[var(--faint)] sm:inline">Control room</span></div>
        <div className="flex items-center gap-2"><div className="hidden items-center gap-2 text-xs text-[var(--muted)] sm:inline-flex"><ShieldCheck size={15} />Permission-checked</div><SignOutButton /></div>
      </header>
      <div className="mx-auto flex max-w-[1600px]">
        <AdminNav permissions={permissions} />
        <main className="min-w-0 flex-1 px-4 pb-24 pt-7 sm:px-6 lg:px-8 lg:pb-10">{children}</main>
      </div>
      <MobileAdminNav permissions={permissions} />
    </div>
  );
}
