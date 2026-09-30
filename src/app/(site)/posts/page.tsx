import type { Metadata } from "next";
import { Card } from "@/components/ui/card";
export const metadata: Metadata = { title: "Community posts" };
export default function PostsPage() { return <div className="mx-auto max-w-4xl py-10"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Community</div><h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">Posts</h1><Card className="mt-8 p-6"><div className="text-sm font-medium">Structured discussions</div><p className="mt-2 text-sm leading-6 text-[var(--muted)]">Posts are stored as first-class records so discussions can later be moderated, cited and linked without relying on an ephemeral feed.</p></Card></div>; }
