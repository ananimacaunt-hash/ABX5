import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Abandix — Archive the place, not the risk",
    template: "%s — Abandix",
  },
  description: "A community archive for abandoned places, reports, histories, sources, people and groups.",
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"),
  alternates: { canonical: "/" },
  openGraph: {
    title: "Abandix",
    description: "A community archive for places, reports, histories and sources.",
    type: "website",
    siteName: "Abandix",
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  themeColor: "#111211",
  colorScheme: "dark",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
