import { notFound } from "next/navigation";
import type { Metadata } from "next";
export const metadata: Metadata = { title: "Report" };
export default async function DetailPage({ params }: { params: Promise<{ slug: string }> }) { const { slug } = await params; if (!slug) notFound(); return <div className="mx-auto max-w-5xl py-10"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Report / foundation</div><h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">{slug}</h1><p className="mt-4 max-w-2xl text-sm leading-6 text-[var(--muted)]">The live record renderer is implemented in the next functional phase; no fake database object is rendered here.</p></div>; }
