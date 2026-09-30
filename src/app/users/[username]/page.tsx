import type { Metadata } from "next";
import { Card } from "@/components/ui/card";
export const metadata: Metadata = { title: "Profile" };
export default async function ProfilePage({ params }: { params: Promise<{ username: string }> }) { const { username } = await params; return <div className="mx-auto max-w-4xl py-10"><div className="text-xs uppercase tracking-[0.16em] text-[var(--faint)]">Profile</div><h1 className="mt-2 text-4xl font-semibold tracking-[-0.04em]">@{username}</h1><Card className="mt-8 p-6"><div className="text-sm font-medium">Profile data boundary</div><p className="mt-2 text-sm leading-6 text-[var(--muted)]">The public profile record will be fetched from `profiles` and contribution tables once the community phase is enabled.</p></Card></div>; }
