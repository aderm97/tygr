import { NextRequest, NextResponse } from "next/server"
import { scanManager } from "@/lib/scan-manager"
import { ScanConfig } from "@/lib/types"

export async function POST(request: NextRequest) {
  try {
    const config: ScanConfig = await request.json()

    // Validate configuration
    if (!config.targets || config.targets.length === 0) {
      return NextResponse.json(
        { error: "At least one target is required" },
        { status: 400 }
      )
    }

    if (!config.llmConfig || !config.llmConfig.model || !config.llmConfig.apiKey) {
      return NextResponse.json(
        { error: "LLM configuration is required" },
        { status: 400 }
      )
    }

    if (!config.runName) {
      return NextResponse.json(
        { error: "Run name is required" },
        { status: 400 }
      )
    }

    const scanId = await scanManager.startScan(config)

    return NextResponse.json({
      success: true,
      scanId,
      message: "Scan started successfully",
    })
  } catch (error: any) {
    console.error("Failed to start scan:", error)
    return NextResponse.json(
      { error: error.message || "Failed to start scan" },
      { status: 500 }
    )
  }
}
