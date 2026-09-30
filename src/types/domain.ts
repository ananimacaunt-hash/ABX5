export type PermissionKey =
  | "content.read"
  | "content.create"
  | "content.update_own"
  | "content.moderate"
  | "places.manage"
  | "sources.manage"
  | "people.manage"
  | "groups.manage"
  | "users.manage"
  | "roles.manage"
  | "audit.read"
  | "settings.manage";

export type AppRole = "user" | "moderator" | "admin";
