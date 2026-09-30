import Link from "next/link";
import { Archive, Compass, FileText, Home, Search } from "lucide-react";

const items = [
  ["/", "Home", Home],
  ["/explore", "Explore", Compass],
  ["/reports", "Reports", FileText],
  ["/archive", "Archive", Archive],
  ["/search", "Search", Search],
] as const;

export function MobileNav() {
  return (
    <nav className="fixed inset-x-0 bottom-0 z-40 border-t border-[var(--line)] bg-[color:var(--surface)/0.96] px-2 pb-[env(safe-area-inset-bottom)] pt-2 backdrop-blur-lg lg:hidden" aria-label="Mobile primary navigation">
      <div className="mx-auto grid max-w-lg grid-cols-5 gap-1">
        {items.map(([href, label, Icon]) => (
          <Link key={href} href={href} className="flex min-h-14 flex-col items-center justify-center gap-1 rounded-md text-[11px] text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">
            <Icon size={17} aria-hidden />
            {label}
          </Link>
        ))}
      </div>
    </nav>
  );
}
