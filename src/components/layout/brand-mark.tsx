import Link from "next/link";

export function BrandMark() {
  return (
    <Link href="/" className="group inline-flex items-center gap-3" aria-label="Abandix home">
      <span className="grid size-8 place-items-center rounded-md border border-[var(--line-strong)] bg-[var(--surface-2)] text-xs font-semibold tracking-tight text-[var(--text)] transition group-hover:border-[var(--accent)]">
        A
      </span>
      <span className="font-semibold tracking-tight text-[var(--text)]">Abandix</span>
    </Link>
  );
}
