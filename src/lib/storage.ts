import "server-only";

import { z } from "zod";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

const bucketSchema = z.enum(["avatars", "place-media", "report-media"]);

export async function createSignedMediaUrl(bucket: string, path: string, expiresInSeconds = 600) {
  const safeBucket = bucketSchema.parse(bucket);
  if (!path || path.includes("..") || path.startsWith("/")) throw new Error("Invalid storage path");
  const supabase = createSupabaseAdminClient();
  const { data, error } = await supabase.storage.from(safeBucket).createSignedUrl(path, expiresInSeconds);
  if (error) throw error;
  return data.signedUrl;
}
