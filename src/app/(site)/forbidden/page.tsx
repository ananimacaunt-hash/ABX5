export default function ForbiddenPage() {
  return (
    <div className="mx-auto max-w-2xl py-20 text-center">
      <div className="text-xs uppercase tracking-[0.16em] text-[var(--danger)]">403</div>
      <h1 className="mt-3 text-4xl font-semibold">Access denied</h1>
      <p className="mx-auto mt-4 max-w-lg text-sm leading-6 text-[var(--muted)]">Your current account does not have permission for this resource. Privileged access is checked on the server and enforced again by PostgreSQL RLS.</p>
    </div>
  );
}
