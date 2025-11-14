import { spawn, ChildProcess } from "child_process"
import { EventEmitter } from "events"
import { Scan, ScanConfig, ScanStatus, ScanEvent } from "./types"
import path from "path"

export class ScanManager extends EventEmitter {
  private activateScans: Map<string, ChildProcess> = new Map()
  private scanData: Map<string, Scan> = new Map()

  async startScan(config: ScanConfig): Promise<string> {
    const scanId = config.runName

    // Build environment variables
    const env: Record<string, string> = {
      ...process.env as Record<string, string>,
      TYGR_LLM: config.llmConfig.model,
      LLM_API_KEY: config.llmConfig.apiKey,
    }

    if (config.llmConfig.apiBase) {
      env.LLM_API_BASE = config.llmConfig.apiBase
    }

    if (config.llmConfig.perplexityApiKey) {
      env.PERPLEXITY_API_KEY = config.llmConfig.perplexityApiKey
    }

    // Build CLI arguments
    const args = [
      "-n", // non-interactive
      "--run-name",
      config.runName,
    ]

    // Add targets
    for (const target of config.targets) {
      args.push("--target", target.original)
    }

    // Add instruction if provided
    if (config.instruction) {
      args.push("--instruction", config.instruction)
    }

    // Initialize scan data
    const scan: Scan = {
      id: scanId,
      runName: config.runName,
      status: "running",
      targets: config.targets,
      instruction: config.instruction,
      createdAt: new Date(),
      startedAt: new Date(),
      progress: 0,
      vulnerabilitiesFound: 0,
      agentCount: 0,
      llmCalls: 0,
      tokensUsed: 0,
    }

    this.scanData.set(scanId, scan)

    try {
      // Spawn TYGR CLI process
      const process = spawn("tygr", args, {
        env: env as NodeJS.ProcessEnv,
        cwd: path.join(__dirname, "../../.."), // TYGR root directory
      })

      this.activateScans.set(scanId, process)

      // Handle stdout
      process.stdout?.on("data", (data) => {
        const output = data.toString()
        this.handleScanOutput(scanId, output)
      })

      // Handle stderr
      process.stderr?.on("data", (data) => {
        const error = data.toString()
        this.emitEvent(scanId, {
          type: "log",
          scanId,
          timestamp: new Date(),
          data: {
            level: "error",
            message: error,
          },
        })
      })

      // Handle process exit
      process.on("exit", (code) => {
        const scan = this.scanData.get(scanId)
        if (scan) {
          scan.status = code === 0 ? "completed" : "failed"
          scan.completedAt = new Date()
          this.scanData.set(scanId, scan)

          this.emitEvent(scanId, {
            type: code === 0 ? "scan_completed" : "scan_failed",
            scanId,
            timestamp: new Date(),
            data: { exitCode: code },
          })
        }
        this.activateScans.delete(scanId)
      })

      this.emitEvent(scanId, {
        type: "scan_started",
        scanId,
        timestamp: new Date(),
        data: { config },
      })

      return scanId
    } catch (error) {
      scan.status = "failed"
      this.scanData.set(scanId, scan)
      throw error
    }
  }

  async cancelScan(scanId: string): Promise<boolean> {
    const process = this.activateScans.get(scanId)
    if (!process) return false

    process.kill("SIGTERM")

    const scan = this.scanData.get(scanId)
    if (scan) {
      scan.status = "cancelled"
      scan.completedAt = new Date()
      this.scanData.set(scanId, scan)
    }

    this.activateScans.delete(scanId)
    return true
  }

  getScan(scanId: string): Scan | undefined {
    return this.scanData.get(scanId)
  }

  getAllScans(): Scan[] {
    return Array.from(this.scanData.values()).sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
    )
  }

  private handleScanOutput(scanId: string, output: string) {
    const scan = this.scanData.get(scanId)
    if (!scan) return

    // Parse output for structured events
    const lines = output.split("\n")

    for (const line of lines) {
      if (!line.trim()) continue

      // Emit log event
      this.emitEvent(scanId, {
        type: "log",
        scanId,
        timestamp: new Date(),
        data: {
          level: "info",
          message: line,
        },
      })

      // Try to parse as JSON (for structured events)
      try {
        const event = JSON.parse(line)
        if (event.type) {
          this.emitEvent(scanId, event)
        }
      } catch {
        // Not JSON, just regular log output
      }

      // Parse vulnerability findings
      if (line.includes("VULNERABILITY FOUND")) {
        scan.vulnerabilitiesFound++
        this.scanData.set(scanId, scan)
      }
    }
  }

  private emitEvent(scanId: string, event: ScanEvent) {
    this.emit("scan_event", scanId, event)
  }
}

// Singleton instance
export const scanManager = new ScanManager()
