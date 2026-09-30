import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  const base = process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000";
  return { rules: { userAgent: "*", allow: ["/", "/places/", "/reports/", "/people/", "/groups/", "/sources/"], disallow: ["/admin/", "/auth/", "/api/", "/users/me"] }, sitemap: `${base}/sitemap.xml` };
}
