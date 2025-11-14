import { NextRequest, NextResponse } from "next/server"
import { scanManager } from "@/lib/scan-manager"

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const scan = scanManager.getScan(id)

    if (!scan) {
      return NextResponse.json(
        { error: "Scan not found" },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      scan,
    })
  } catch (error: any) {
    console.error("Failed to fetch scan:", error)
    return NextResponse.json(
      { error: error.message || "Failed to fetch scan" },
      { status: 500 }
    )
  }
}
