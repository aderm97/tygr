// Scan Configuration Types
export interface ScanConfig {
  targets: TargetInfo[]
  instruction?: string
  runName: string
  llmConfig: LLMConfig
}

export interface TargetInfo {
  type: "url" | "repository" | "local_code" | "domain"
  original: string
  details: Record<string, any>
}

export interface LLMConfig {
  model: string
  apiKey: string
  apiBase?: string
  perplexityApiKey?: string
}

// Scan Status Types
export type ScanStatus = "queued" | "running" | "completed" | "failed" | "cancelled"

export interface Scan {
  id: string
  runName: string
  status: ScanStatus
  targets: TargetInfo[]
  instruction?: string
  createdAt: Date
  startedAt?: Date
  completedAt?: Date
  progress: number
  vulnerabilitiesFound: number
  agentCount: number
  llmCalls: number
  tokensUsed: number
}

// Vulnerability Types
export type Severity = "critical" | "high" | "medium" | "low" | "info"

export interface Vulnerability {
  id: string
  scanId: string
  reportId: string
  title: string
  severity: Severity
  description: string
  impact: string
  remediation: string
  poc?: string
  cwe?: string
  cvss?: number
  foundAt: Date
  status: "open" | "confirmed" | "false_positive" | "fixed"
}

// Real-Time Event Types
export type EventType =
  | "scan_started"
  | "scan_progress"
  | "vulnerability_found"
  | "agent_state_change"
  | "tool_execution"
  | "llm_call"
  | "scan_completed"
  | "scan_failed"
  | "log"

export interface ScanEvent {
  type: EventType
  scanId: string
  timestamp: Date
  data: any
}

export interface LogEvent {
  type: "log"
  scanId: string
  timestamp: Date
  data: {
    level: "info" | "warning" | "error" | "debug"
    message: string
    source?: string
  }
}

export interface VulnerabilityFoundEvent {
  type: "vulnerability_found"
  scanId: string
  timestamp: Date
  data: {
    reportId: string
    title: string
    severity: Severity
    content: string
  }
}

export interface ProgressEvent {
  type: "scan_progress"
  scanId: string
  timestamp: Date
  data: {
    progress: number
    currentActivity: string
  }
}

// Agent Types
export interface AgentActivity {
  agentId: string
  agentType: string
  status: "idle" | "working" | "waiting" | "completed"
  currentTask?: string
  toolsUsed: string[]
  findingsCount: number
}

// Configuration Types
export interface AppConfig {
  llm: {
    model: string
    apiKey: string
    apiBase?: string
  }
  perplexity?: {
    apiKey: string
  }
  docker: {
    image: string
    pullOnStartup: boolean
  }
  maxConcurrentScans: number
}

// Export Types
export type ExportFormat = "json" | "markdown" | "pdf" | "sarif"

export interface ExportRequest {
  scanId: string
  format: ExportFormat
  includePoCs: boolean
}

// Dashboard Statistics
export interface DashboardStats {
  totalScans: number
  activeScans: number
  totalVulnerabilities: number
  criticalFindings: number
  avgScanDuration: number
  recentScans: Scan[]
}
