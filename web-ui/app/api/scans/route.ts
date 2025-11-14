import { NextResponse } from "next/server"
import { scanManager } from "@/lib/scan-manager"

export async function GET() {
  try {
    const scans = scanManager.getAllScans()

    return NextResponse.json({
      success: true,
      scans,
    })
  } catch (error: any) {
    console.error("Failed to fetch scans:", error)
    return NextResponse.json(
      { error: error.message || "Failed to fetch scans" },
      { status: 500 }
    )
  }
}
