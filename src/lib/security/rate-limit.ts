export interface RateLimitResult {
  allowed: boolean;
  limit: number;
  remaining: number;
  resetAt: Date;
}

export interface RateLimitKey {
  namespace: "auth" | "comment" | "report" | "correction" | "content-report" | "upload";
  subject: string;
}

export interface RateLimitStore {
  check(key: RateLimitKey, limit: number, windowMs: number): Promise<RateLimitResult>;
}

/**
 * Production seam for Upstash/Redis/edge-backed throttling.
 * The app should call this boundary rather than embedding a provider-specific
 * rate-limit client throughout forms and route handlers.
 */
export function makeRateLimitKey(namespace: RateLimitKey["namespace"], subject: string): RateLimitKey {
  return { namespace, subject: `${namespace}:${subject}` };
}
