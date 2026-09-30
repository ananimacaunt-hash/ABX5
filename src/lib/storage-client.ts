"use client";

import { z } from "zod";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

const bucketSchema = z.enum(["avatars", "place-media", "report-media"]);
const allowedMimes = new Set(["image/jpeg", "image/png", "image/webp", "image/avif"]);
export const DEFAULT_UPLOAD_MAX_BYTES = 15_728_640;

function extensionForMime(mime: string) {
  return { "image/jpeg": "jpg", "image/png": "png", "image/webp": "webp", "image/avif": "avif" }[mime];
}

export async function uploadUserImage(bucket: string, file: File, maxBytes = DEFAULT_UPLOAD_MAX_BYTES) {
  const safeBucket = bucketSchema.parse(bucket);
  if (!allowedMimes.has(file.type)) throw new Error("Unsupported image type.");
  if (file.size <= 0 || file.size > maxBytes) throw new Error("Image exceeds the configured size limit.");

  const supabase = createSupabaseBrowserClient();
  const { data: { user }, error: userError } = await supabase.auth.getUser();
  if (userError || !user) throw new Error("You must be signed in to upload media.");

  const extension = extensionForMime(file.type);
  if (!extension) throw new Error("Unsupported image type.");
  const path = `${user.id}/${crypto.randomUUID()}.${extension}`;
  const { error } = await supabase.storage.from(safeBucket).upload(path, file, {
    cacheControl: "31536000",
    contentType: file.type,
    upsert: false,
  });
  if (error) throw error;
  return { bucket: safeBucket, path, mimeType: file.type, byteSize: file.size };
}
