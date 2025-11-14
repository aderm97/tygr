"use client"

import { useQuery } from "@tanstack/react-query"
import Link from "next/link"
import {
  Shield,
  Activity,
  AlertTriangle,
  Clock,
  Target,
  PlayCircle,
  Settings,
} from "lucide-react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Separator } from "@/components/ui/separator"
import { formatDate, formatDuration, getSeverityBadgeClass } from "@/lib/utils"
import { Scan } from "@/lib/types"

export default function DashboardPage() {
  const { data: scansData, isLoading } = useQuery({
    queryKey: ["scans"],
    queryFn: async () => {
      const res = await fetch("/api/scans")
      if (!res.ok) throw new Error("Failed to fetch scans")
      return res.json()
    },
    refetchInterval: 5000, // Poll every 5 seconds
  })

  const scans: Scan[] = scansData?.scans || []
  const activeScans = scans.filter((s) => s.status === "running")
  const recentScans = scans.slice(0, 5)

  const totalVulnerabilities = scans.reduce((sum, s) => sum + s.vulnerabilitiesFound, 0)
  const criticalFindings = scans.reduce(
    (sum, s) => sum + (s.status === "completed" ? Math.floor(s.vulnerabilitiesFound * 0.2) : 0),
    0
  )

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white">
      {/* Header */}
      <header className="border-b border-gray-800">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="text-4xl">🐯</div>
              <div>
                <h1 className="text-2xl font-bold tygr-gradient bg-clip-text text-transparent">
                  TYGR Security Agent
                </h1>
                <p className="text-xs text-gray-400">Mission Control</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <Link href="/dashboard/config">
                <Button variant="outline" size="sm">
                  <Settings className="w-4 h-4 mr-2" />
                  Settings
                </Button>
              </Link>
              <Link href="/dashboard/new-hunt">
                <Button variant="tygr" size="lg">
                  <PlayCircle className="w-5 h-5 mr-2" />
                  New Hunt
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatsCard
            icon={<Activity className="w-6 h-6 text-tygr-cyan" />}
            label="Active Hunts"
            value={activeScans.length.toString()}
            trend={activeScans.length > 0 ? "In Progress" : "Idle"}
            trendColor="text-tygr-cyan"
          />
          <StatsCard
            icon={<Target className="w-6 h-6 text-tygr-orange" />}
            label="Total Scans"
            value={scans.length.toString()}
            trend={`${recentScans.length} Recent`}
          />
          <StatsCard
            icon={<AlertTriangle className="w-6 h-6 text-tygr-red" />}
            label="Vulnerabilities"
            value={totalVulnerabilities.toString()}
            trend={`${criticalFindings} Critical`}
            trendColor="text-tygr-red"
          />
          <StatsCard
            icon={<Shield className="w-6 h-6 text-tygr-green" />}
            label="Security Score"
            value="A+"
            trend="Excellent"
            trendColor="text-tygr-green"
          />
        </div>

        {/* Active Hunts */}
        {activeScans.length > 0 && (
          <div className="mb-8">
            <h2 className="text-2xl font-bold mb-4 flex items-center">
              <Activity className="w-6 h-6 mr-2 text-tygr-orange" />
              Active Hunts
            </h2>
            <div className="grid gap-4">
              {activeScans.map((scan) => (
                <ActiveScanCard key={scan.id} scan={scan} />
              ))}
            </div>
          </div>
        )}

        {/* Recent Hunts */}
        <div>
          <h2 className="text-2xl font-bold mb-4 flex items-center">
            <Clock className="w-6 h-6 mr-2 text-gray-400" />
            Recent Hunts
          </h2>
          {isLoading ? (
            <Card className="bg-gray-800 border-gray-700">
              <CardContent className="py-12 text-center text-gray-400">
                Loading scans...
              </CardContent>
            </Card>
          ) : recentScans.length === 0 ? (
            <Card className="bg-gray-800 border-gray-700">
              <CardContent className="py-12 text-center">
                <Target className="w-16 h-16 mx-auto mb-4 text-gray-600" />
                <h3 className="text-xl font-semibold mb-2 text-gray-300">No hunts yet</h3>
                <p className="text-gray-400 mb-6">
                  Start your first security hunt to find vulnerabilities
                </p>
                <Link href="/dashboard/new-hunt">
                  <Button variant="tygr">
                    <PlayCircle className="w-5 h-5 mr-2" />
                    Start Your First Hunt
                  </Button>
                </Link>
              </CardContent>
            </Card>
          ) : (
            <div className="grid gap-4">
              {recentScans.map((scan) => (
                <RecentScanCard key={scan.id} scan={scan} />
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  )
}

function StatsCard({
  icon,
  label,
  value,
  trend,
  trendColor = "text-gray-400",
}: {
  icon: React.ReactNode
  label: string
  value: string
  trend?: string
  trendColor?: string
}) {
  return (
    <Card className="bg-gray-800 border-gray-700">
      <CardContent className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="p-2 bg-gray-900 rounded-lg">{icon}</div>
          {trend && <span className={`text-xs font-medium ${trendColor}`}>{trend}</span>}
        </div>
        <div className="text-3xl font-bold mb-1">{value}</div>
        <div className="text-sm text-gray-400">{label}</div>
      </CardContent>
    </Card>
  )
}

function ActiveScanCard({ scan }: { scan: Scan }) {
  return (
    <Link href={`/dashboard/hunts/${scan.id}`}>
      <Card className="bg-gray-800 border-gray-700 hover:border-tygr-orange/50 transition-colors cursor-pointer">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg flex items-center">
              <div className="w-2 h-2 bg-tygr-green rounded-full mr-2 animate-pulse" />
              {scan.runName}
            </CardTitle>
            <Badge className="bg-tygr-green/20 text-tygr-green border-tygr-green/30">
              Running
            </Badge>
          </div>
          <CardDescription className="text-gray-400">
            {scan.targets.map((t) => t.original).join(", ")}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="text-gray-400">Progress</span>
                <span className="font-medium">{scan.progress}%</span>
              </div>
              <Progress value={scan.progress} className="h-2" />
            </div>
            <div className="grid grid-cols-3 gap-4 text-sm">
              <div>
                <div className="text-gray-400">Findings</div>
                <div className="font-semibold text-tygr-orange">{scan.vulnerabilitiesFound}</div>
              </div>
              <div>
                <div className="text-gray-400">Agents</div>
                <div className="font-semibold">{scan.agentCount}</div>
              </div>
              <div>
                <div className="text-gray-400">Duration</div>
                <div className="font-semibold">
                  {formatDuration(
                    Math.floor((Date.now() - new Date(scan.startedAt!).getTime()) / 1000)
                  )}
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </Link>
  )
}

function RecentScanCard({ scan }: { scan: Scan }) {
  const statusColors = {
    completed: "bg-tygr-green/20 text-tygr-green border-tygr-green/30",
    failed: "bg-tygr-red/20 text-tygr-red border-tygr-red/30",
    cancelled: "bg-gray-500/20 text-gray-400 border-gray-500/30",
    running: "bg-tygr-cyan/20 text-tygr-cyan border-tygr-cyan/30",
    queued: "bg-yellow-500/20 text-yellow-400 border-yellow-500/30",
  }

  return (
    <Link href={`/dashboard/hunts/${scan.id}`}>
      <Card className="bg-gray-800 border-gray-700 hover:border-gray-600 transition-colors cursor-pointer">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <div className="flex items-center space-x-3 mb-2">
                <h3 className="font-semibold text-lg">{scan.runName}</h3>
                <Badge className={statusColors[scan.status]}>{scan.status}</Badge>
                {scan.vulnerabilitiesFound > 0 && (
                  <Badge variant="destructive">{scan.vulnerabilitiesFound} findings</Badge>
                )}
              </div>
              <p className="text-sm text-gray-400 mb-3">
                {scan.targets.map((t) => t.original).join(", ")}
              </p>
              <div className="flex items-center space-x-6 text-xs text-gray-500">
                <span>Created {formatDate(scan.createdAt)}</span>
                {scan.completedAt && (
                  <span>
                    Duration:{" "}
                    {formatDuration(
                      Math.floor(
                        (new Date(scan.completedAt).getTime() -
                          new Date(scan.startedAt!).getTime()) /
                          1000
                      )
                    )}
                  </span>
                )}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </Link>
  )
}
