import type { Metadata } from "next";
import { Card } from "@/components/ui/card";
export const metadata: Metadata = { title: "Groups" };
export default function Page() {
  return <div className="mx-auto max-w-4xl py-10"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Abandix / foundation</div><h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">Groups</h1><Card className="mt-8 p-6"><div className="text-sm font-medium">Foundation boundary</div><p className="mt-2 text-sm leading-6 text-[var(--muted)]">Phase 4 will connect exploration groups, memberships, publications, history and sources.</p><p className="mt-4 text-xs leading-5 text-[var(--faint)]">This page is a real route in the application, but it does not pretend to have a backend feature that has not been implemented yet.</p></Card></div>;
}
