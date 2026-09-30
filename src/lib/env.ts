import { z } from "zod";

const envSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(20),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(20).optional(),
  NEXT_PUBLIC_SITE_URL: z.url().default("http://localhost:3000"),
  ABANDIX_UPLOAD_MAX_BYTES: z.coerce.number().int().positive().default(15_728_640),
  ABANDIX_MODERATION_RETENTION_DAYS: z.coerce.number().int().positive().default(90),
});

export function getPublicEnv() {
  return envSchema.pick({
    NEXT_PUBLIC_SUPABASE_URL: true,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: true,
  }).parse({
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  });
}

export function getServerEnv() {
  return envSchema.parse({
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
    NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
    ABANDIX_UPLOAD_MAX_BYTES: process.env.ABANDIX_UPLOAD_MAX_BYTES,
    ABANDIX_MODERATION_RETENTION_DAYS: process.env.ABANDIX_MODERATION_RETENTION_DAYS,
  });
}
