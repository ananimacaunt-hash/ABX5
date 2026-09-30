import type { HTMLAttributes, ReactNode } from "react";

export function Card({ className = "", children, ...props }: HTMLAttributes<HTMLDivElement> & { children: ReactNode }) {
  return (
    <div className={`rounded-xl border border-[var(--line)] bg-[var(--surface)] shadow-[0_12px_30px_rgba(0,0,0,0.16)] ${className}`} {...props}>
      {children}
    </div>
  );
}
