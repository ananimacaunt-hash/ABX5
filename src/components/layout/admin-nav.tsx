import Link from "next/link";
import { Activity, BookOpen, Boxes, FileClock, FileText, Flag, Group, LayoutDashboard, MapPin, Settings, Shield, Users } from "lucide-react";
import type { ComponentType } from "react";
import type { PermissionKey } from "@/types/domain";

const items: Array<{ href: string; label: string; icon: ComponentType<{ size?: number }>; permission?: PermissionKey }> = [
  { href: "/admin", label: "Dashboard", icon: LayoutDashboard },
  { href: "/admin/reports", label: "Reports", icon: FileText, permission: "content.moderate" },
  { href: "/admin/posts", label: "Posts", icon: BookOpen, permission: "content.moderate" },
  { href: "/admin/places", label: "Places", icon: MapPin, permission: "places.manage" },
  { href: "/admin/users", label: "Users", icon: Users, permission: "users.manage" },
  { href: "/admin/sources", label: "Sources", icon: Boxes, permission: "sources.manage" },
  { href: "/admin/people", label: "People", icon: Users, permission: "people.manage" },
  { href: "/admin/groups", label: "Groups", icon: Group, permission: "groups.manage" },
  { href: "/admin/moderation", label: "Moderation", icon: Shield, permission: "content.moderate" },
  { href: "/admin/logs", label: "Audit logs", icon: FileClock, permission: "audit.read" },
  { href: "/admin/settings", label: "Settings", icon: Settings, permission: "settings.manage" },
];

export function AdminNav({ permissions }: { permissions: PermissionKey[] }) {
  return (
    <aside className="hidden w-64 shrink-0 border-r border-[var(--line)] bg-[var(--surface)] p-4 lg:block">
      <div className="mb-5 flex items-center gap-2 px-2 text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]"><Activity size={14} />Control room</div>
      <nav className="grid gap-1" aria-label="Admin navigation">
        {items.filter((item) => !item.permission || permissions.includes(item.permission)).map(({ href, label, icon: Icon }) => (
          <Link key={href} href={href} className="flex min-h-10 items-center gap-3 rounded-md px-3 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">
            <Icon size={16} aria-hidden />
            <span>{label}</span>
          </Link>
        ))}
      </nav>
      <div className="mt-8 rounded-md border border-[var(--line)] bg-[var(--surface-2)] p-3 text-xs leading-5 text-[var(--muted)]">
        Moderator metadata is restricted to authorized roles. Exact sensitive coordinates are stored separately from public location data.
      </div>
    </aside>
  );
}
