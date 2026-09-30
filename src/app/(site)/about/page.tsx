import type { Metadata } from "next";
export const metadata: Metadata = { title: "About" };

export default function AboutPage() {
  return <article className="mx-auto max-w-3xl py-8"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">About Abandix</div><h1 className="mt-3 text-4xl font-semibold tracking-[-0.04em]">A place for records to stay useful.</h1><div className="mt-7 grid gap-6 text-base leading-8 text-[var(--muted)]"><p>Abandix is designed as a structured archive and community platform for abandoned places, reports, sources and historical context.</p><p>The primary record is the place itself. Reports, source links, people, groups and timeline events attach to that record instead of disappearing into an endless chronological feed.</p><p>Public information is deliberately separated from sensitive operational metadata. Exact coordinates for sensitive places are not part of the ordinary public dataset.</p><p><strong className="text-[var(--text)]">NoxVenn — Abandix Administrator</strong></p></div></article>;
}
