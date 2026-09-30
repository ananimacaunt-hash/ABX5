"use client";

import { useState } from "react";
import type { FormEvent } from "react";
import { ArrowRight, LoaderCircle } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { authSchema } from "@/lib/validation/auth";

export function AuthForm({ nextPath = "/" }: { nextPath?: string }) {
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [username, setUsername] = useState("");
  const [pending, setPending] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setMessage(null);
    setError(null);

    const validation = authSchema.safeParse({ email, password, username: mode === "signup" ? username : undefined });
    if (!validation.success) {
      setError(validation.error.issues[0]?.message ?? "Please check the form.");
      setPending(false);
      return;
    }

    const supabase = createSupabaseBrowserClient();
    const result = mode === "signin"
      ? await supabase.auth.signInWithPassword({ email, password })
      : await supabase.auth.signUp({
          email,
          password,
          options: {
            data: { username: username.trim() || undefined },
            emailRedirectTo: `${window.location.origin}/auth/callback?next=${encodeURIComponent(nextPath)}`,
          },
        });

    if (result.error) {
      setError(result.error.message);
    } else if (mode === "signup" && !result.data.session) {
      setMessage("Account created. Check your email to confirm the address, then sign in.");
    } else {
      window.location.assign(nextPath);
    }
    setPending(false);
  }

  return (
    <form onSubmit={submit} className="grid gap-5">
      {mode === "signup" && (
        <label className="grid gap-2 text-sm">
          <span className="text-[var(--text)]">Username <span className="text-[var(--faint)]">(optional)</span></span>
          <Input value={username} onChange={(e) => setUsername(e.target.value)} autoComplete="username" placeholder="your_archive_name" maxLength={32} />
        </label>
      )}
      <label className="grid gap-2 text-sm">
        <span className="text-[var(--text)]">Email</span>
        <Input value={email} onChange={(e) => setEmail(e.target.value)} type="email" autoComplete="email" required placeholder="you@example.com" />
      </label>
      <label className="grid gap-2 text-sm">
        <span className="text-[var(--text)]">Password</span>
        <Input value={password} onChange={(e) => setPassword(e.target.value)} type="password" autoComplete={mode === "signin" ? "current-password" : "new-password"} minLength={8} required placeholder="At least 8 characters" />
      </label>
      {error && <p role="alert" className="rounded-md border border-[var(--danger-soft)] bg-[var(--danger-soft)] px-3 py-2 text-sm text-[var(--danger)]">{error}</p>}
      {message && <p role="status" className="rounded-md border border-[var(--accent-soft)] bg-[var(--accent-soft)] px-3 py-2 text-sm text-[var(--accent)]">{message}</p>}
      <Button type="submit" disabled={pending}>{pending ? <LoaderCircle className="animate-spin" size={16} /> : <ArrowRight size={16} />}{mode === "signin" ? "Sign in" : "Create account"}</Button>
      <button type="button" onClick={() => { setMode((v) => v === "signin" ? "signup" : "signin"); setError(null); setMessage(null); }} className="text-sm text-[var(--muted)] hover:text-[var(--text)]">
        {mode === "signin" ? "Need an account? Create one." : "Already have an account? Sign in."}
      </button>
    </form>
  );
}
