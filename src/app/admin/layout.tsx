import { AdminShell } from "@/components/layout/admin-shell";
import { requirePermission, getCurrentPermissions } from "@/lib/auth/permissions";

export const metadata = {
  title: "Control room",
  robots: { index: false, follow: false },
};

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  await requirePermission("content.moderate");
  const permissions = await getCurrentPermissions();
  return <AdminShell permissions={permissions}>{children}</AdminShell>;
}
