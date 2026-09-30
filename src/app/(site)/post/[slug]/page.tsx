import type { Metadata } from "next";
import { notFound } from "next/navigation";
export const metadata: Metadata = { title: "Community post" };
export default async function PostPage({ params }: { params: Promise<{ slug: string }> }) { const { slug } = await params; if (!slug) notFound(); return <div className="mx-auto max-w-4xl py-10"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Community post / foundation</div><h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">{slug}</h1><p className="mt-4 max-w-2xl text-sm leading-6 text-[var(--muted)]">The live PostgreSQL post renderer and threaded discussion UI are implemented in the community phase.</p></div>; }
