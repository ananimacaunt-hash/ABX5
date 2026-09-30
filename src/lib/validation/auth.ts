import { z } from "zod";

export const authSchema = z.object({
  email: z.email(),
  password: z.string().min(8).max(128),
  username: z.string().trim().regex(/^[a-zA-Z0-9_.-]{3,32}$/).optional().or(z.literal("")),
});
