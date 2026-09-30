import "server-only";

import { redirect } from "next/navigation";
import type { PermissionKey } from "@/types/domain";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function getCurrentUser() {
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.getUser();
  if (error) return null;
  return data.user;
}

export async function getCurrentPermissions(): Promise<PermissionKey[]> {
  const user = await getCurrentUser();
  if (!user) return [];

  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc("my_permissions");
  if (error || !Array.isArray(data)) return [];
  return data as PermissionKey[];
}


export async function hasPermission(permission: PermissionKey) {
  const user = await getCurrentUser();
  if (!user) return false;
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.rpc("has_permission", { required_permission: permission });
  return !error && Boolean(data);
}

export async function requireUser() {
  const user = await getCurrentUser();
  if (!user) redirect("/auth/sign-in?next=/");
  return user;
}

export async function requirePermission(permission: PermissionKey) {
  const allowed = await hasPermission(permission);
  if (!allowed) redirect("/forbidden");
}
