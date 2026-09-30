import type { Metadata } from "next";
import { AuthForm } from "@/components/auth/auth-form";
import { Card } from "@/components/ui/card";

export const metadata: Metadata = { title: "Sign in" };

export default async function SignInPage({ searchParams }: { searchParams: Promise<{ next?: string }> }) {
  const params = await searchParams;
  const nextPath = params.next && params.next.startsWith("/") ? params.next : "/";
  return (
    <div className="mx-auto grid min-h-[calc(100vh-12rem)] max-w-5xl items-center gap-10 lg:grid-cols-[1fr_420px]">
      <section>
        <div className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--faint)]">Abandix account</div>
        <h1 className="mt-3 max-w-2xl text-4xl font-semibold tracking-[-0.04em] sm:text-5xl">Contribute without needing to use your real name.</h1>
        <p className="mt-5 max-w-xl text-base leading-7 text-[var(--muted)]">Usernames are pseudonyms. The public site can display anonymous reports while the private account relationship remains available to authorized moderators.</p>
      </section>
      <Card className="p-6 sm:p-7"><AuthForm nextPath={nextPath} /></Card>
    </div>
  );
}
