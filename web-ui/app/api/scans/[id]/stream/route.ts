import { NextRequest } from "next/server"
import { scanManager } from "@/lib/scan-manager"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params

  // Verify scan exists
  const scan = scanManager.getScan(id)
  if (!scan) {
    return new Response("Scan not found", { status: 404 })
  }

  // Create SSE stream
  const encoder = new TextEncoder()
  const stream = new ReadableStream({
    start(controller) {
      // Send initial connection message
      const data = `data: ${JSON.stringify({ type: "connected", scanId: id })}\n\n`
      controller.enqueue(encoder.encode(data))

      // Listen for scan events
      const eventListener = (scanId: string, event: any) => {
        if (scanId === id) {
          const data = `data: ${JSON.stringify(event)}\n\n`
          controller.enqueue(encoder.encode(data))
        }
      }

      scanManager.on("scan_event", eventListener)

      // Cleanup on close
      request.signal.addEventListener("abort", () => {
        scanManager.off("scan_event", eventListener)
        controller.close()
      })
    },
  })

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    },
  })
}
