import Link from "next/link";

export function SiteFooter() {
  return (
    <footer className="border-t border-[var(--line)] bg-[var(--surface)]">
      <div className="mx-auto grid max-w-[1440px] gap-8 px-4 py-10 sm:px-6 md:grid-cols-3 lg:px-8">
        <div>
          <div className="font-semibold text-[var(--text)]">Abandix</div>
          <p className="mt-2 max-w-sm text-sm leading-6 text-[var(--muted)]">
            A community archive for places, reports, sources and histories. Document, don't exploit.
          </p>
        </div>
        <div className="grid gap-2 text-sm text-[var(--muted)]">
          <span className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Project</span>
          <Link href="/about" className="hover:text-[var(--text)]">About</Link>
          <Link href="/guidelines" className="hover:text-[var(--text)]">Guidelines</Link>
        </div>
        <div className="grid gap-2 text-sm text-[var(--muted)]">
          <span className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Legal</span>
          <Link href="/privacy" className="hover:text-[var(--text)]">Privacy</Link>
          <Link href="/terms" className="hover:text-[var(--text)]">Terms</Link>
          <span className="pt-2 text-xs text-[var(--faint)]">NoxVenn — Abandix Administrator</span>
        </div>
      </div>
    </footer>
  );
}
