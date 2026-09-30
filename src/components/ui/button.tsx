import type { ButtonHTMLAttributes, ReactNode } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "solid" | "outline" | "ghost";
  size?: "sm" | "md";
  children: ReactNode;
}

export function Button({
  className = "",
  variant = "solid",
  size = "md",
  children,
  ...props
}: ButtonProps) {
  const styles = {
    solid: "bg-[var(--accent)] text-white hover:bg-[var(--accent-strong)]",
    outline:
      "border border-[var(--line-strong)] bg-transparent text-[var(--text)] hover:bg-[var(--surface-2)]",
    ghost:
      "bg-transparent text-[var(--muted)] hover:bg-[var(--surface-2)] hover:text-[var(--text)]",
  }[variant];

  const sizeClass =
    size === "sm" ? "min-h-9 px-3 text-sm" : "min-h-10 px-4 text-sm";

  return (
    <button
      className={`inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--accent)] disabled:cursor-not-allowed disabled:opacity-50 ${sizeClass} ${styles} ${className}`}
      {...props}
    />
  );
}
