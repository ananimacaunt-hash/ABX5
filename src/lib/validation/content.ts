import { z } from "zod";

const httpsUrl = z.url().refine((value) => value.startsWith("https://") || value.startsWith("http://"), "Must be an http(s) URL");

export const placeInputSchema = z.object({
  title: z.string().trim().min(2).max(180),
  typeId: z.uuid(),
  country: z.string().trim().max(120),
  region: z.string().trim().max(160),
  city: z.string().trim().max(160),
  district: z.string().trim().max(160),
  description: z.string().trim().max(1000),
  history: z.string().trim().max(30_000),
  state: z.enum(["preserved", "partially_damaged", "hazardous_sections", "severely_damaged", "critical_condition", "nearly_destroyed", "destroyed", "unknown"]),
  visibility: z.enum(["public_exact", "public_approximate", "hidden", "sensitive"]),
  sourceUrl: httpsUrl.optional().or(z.literal("")),
});

export const reportInputSchema = z.object({
  placeId: z.uuid(),
  title: z.string().trim().min(2).max(240),
  occurredAt: z.coerce.date(),
  content: z.string().trim().min(1).max(50_000),
  anonymousDisplay: z.boolean(),
  sourceUrl: httpsUrl.optional().or(z.literal("")),
});

export const commentInputSchema = z.object({
  body: z.string().trim().min(1).max(5000),
});

export const correctionInputSchema = z.object({
  placeId: z.uuid(),
  fieldName: z.string().trim().min(1).max(80),
  proposedValue: z.string().trim().min(1).max(20_000),
  reason: z.string().trim().max(4000),
  sourceUrl: httpsUrl.optional().or(z.literal("")),
});
