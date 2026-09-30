import type { ReactNode } from "react";

export function Badge({ children, tone = "neutral" }: { children: ReactNode; tone?: "neutral" | "accent" | "warning" | "danger" }) {
  const styles = {
    neutral: "border-[var(--line)] bg-[var(--surface-2)] text-[var(--muted)]",
    accent: "border-[var(--accent-soft)] bg-[var(--accent-soft)] text-[var(--accent)]",
    warning: "border-[var(--warning-soft)] bg-[var(--warning-soft)] text-[var(--warning)]",
    danger: "border-[var(--danger-soft)] bg-[var(--danger-soft)] text-[var(--danger)]",
  }[tone];
  return <span className={`inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-medium tracking-wide ${styles}`}>{children}</span>;
}
