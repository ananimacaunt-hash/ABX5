import type { ReactNode } from "react";
import { SiteFooter } from "./site-footer";
import { SiteNav } from "./site-nav";
import { MobileNav } from "./mobile-nav";

export function SiteShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-[var(--background)] text-[var(--text)]">
      <SiteNav />
      <main className="mx-auto min-h-[calc(100vh-4rem)] max-w-[1440px] px-4 pb-24 pt-8 sm:px-6 lg:px-8 lg:pb-12 lg:pt-10">
        {children}
      </main>
      <SiteFooter />
      <MobileNav />
    </div>
  );
}
