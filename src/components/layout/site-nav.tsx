"use client";

import Link from "next/link";
import { Menu, Search, X } from "lucide-react";
import { useState } from "react";
import { BrandMark } from "./brand-mark";

const links = [
  ["/", "Home"],
  ["/explore", "Explore"],
  ["/reports", "Reports"],
  ["/archive", "Archive"],
  ["/about", "About"],
] as const;

export function SiteNav() {
  const [open, setOpen] = useState(false);
  return (
    <header className="sticky top-0 z-40 border-b border-[var(--line)] bg-[color:var(--background)/0.94] backdrop-blur-xl">
      <div className="mx-auto flex min-h-16 max-w-[1440px] items-center justify-between px-4 sm:px-6 lg:px-8">
        <BrandMark />
        <nav className="hidden items-center gap-1 lg:flex" aria-label="Primary navigation">
          {links.map(([href, label]) => (
            <Link key={href} href={href} className="rounded-md px-3 py-2 text-sm text-[var(--muted)] transition hover:bg-[var(--surface-2)] hover:text-[var(--text)]">
              {label}
            </Link>
          ))}
        </nav>
        <div className="hidden items-center gap-2 lg:flex">
          <Link href="/search" className="inline-flex min-h-10 items-center gap-2 rounded-md border border-[var(--line)] px-3.5 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">
            <Search size={15} aria-hidden />
            Search
            <span className="ml-2 hidden rounded border border-[var(--line)] px-1.5 py-0.5 font-mono text-[10px] xl:inline">/</span>
          </Link>
          <Link href="/auth/sign-in" className="inline-flex min-h-10 items-center justify-center rounded-md border border-[var(--line-strong)] px-4 text-sm font-medium text-[var(--text)] hover:bg-[var(--surface-2)]">Sign in</Link>
        </div>
        <button className="inline-flex size-10 items-center justify-center rounded-md border border-[var(--line)] text-[var(--text)] lg:hidden" onClick={() => setOpen((v) => !v)} aria-label={open ? "Close menu" : "Open menu"} aria-expanded={open}>
          {open ? <X size={18} /> : <Menu size={18} />}
        </button>
      </div>
      {open && (
        <div className="border-t border-[var(--line)] px-4 py-3 lg:hidden">
          <nav className="grid gap-1" aria-label="Mobile navigation">
            {links.map(([href, label]) => (
              <Link key={href} href={href} onClick={() => setOpen(false)} className="rounded-md px-3 py-3 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">
                {label}
              </Link>
            ))}
            <Link href="/search" onClick={() => setOpen(false)} className="rounded-md px-3 py-3 text-sm text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]">Search</Link>
            <Link href="/auth/sign-in" onClick={() => setOpen(false)} className="mt-1 rounded-md border border-[var(--line-strong)] px-3 py-3 text-sm text-[var(--text)]">Sign in</Link>
          </nav>
        </div>
      )}
    </header>
  );
}
