import { NextRequest, NextResponse } from "next/server"
import { scanManager } from "@/lib/scan-manager"

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const success = await scanManager.cancelScan(id)

    if (!success) {
      return NextResponse.json(
        { error: "Scan not found or already completed" },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      message: "Scan cancelled successfully",
    })
  } catch (error: any) {
    console.error("Failed to cancel scan:", error)
    return NextResponse.json(
      { error: error.message || "Failed to cancel scan" },
      { status: 500 }
    )
  }
}
