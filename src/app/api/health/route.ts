import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({ service: "abandix", status: "ok", phase: 1, timestamp: new Date().toISOString() });
}
