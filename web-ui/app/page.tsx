import Link from "next/link"
import { ArrowRight, Shield, Zap, Target, Code2 } from "lucide-react"

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-black text-white">
      {/* Header */}
      <header className="border-b border-gray-800">
        <div className="container mx-auto px-4 py-6 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="text-4xl">🐯</div>
            <div>
              <h1 className="text-2xl font-bold tygr-gradient bg-clip-text text-transparent">
                TYGR Security Agent
              </h1>
              <p className="text-xs text-gray-400">AI-Powered Penetration Testing</p>
            </div>
          </div>
          <Link
            href="/dashboard"
            className="px-6 py-2 tygr-gradient rounded-lg font-semibold hover:opacity-90 transition-opacity"
          >
            Launch Dashboard
          </Link>
        </div>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-20">
        <div className="text-center max-w-4xl mx-auto mb-16">
          <div className="inline-flex items-center space-x-2 px-4 py-2 rounded-full bg-tygr-orange/10 border border-tygr-orange/30 mb-6">
            <Shield className="w-4 h-4 text-tygr-orange" />
            <span className="text-sm font-medium text-tygr-orange">Enterprise-Grade Security Testing</span>
          </div>

          <h2 className="text-6xl font-bold mb-6 leading-tight">
            Autonomous AI Agents for
            <span className="tygr-gradient bg-clip-text text-transparent"> Security Testing</span>
          </h2>

          <p className="text-xl text-gray-400 mb-8 leading-relaxed">
            TYGR Security Agent deploys teams of AI-powered security experts to test your applications.
            Find vulnerabilities faster with real validation and proof-of-concepts.
          </p>

          <div className="flex items-center justify-center space-x-4">
            <Link
              href="/dashboard"
              className="group px-8 py-4 tygr-gradient rounded-lg font-semibold text-lg flex items-center space-x-2 hover:opacity-90 transition-opacity"
            >
              <span>Start Your First Hunt</span>
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Link>
            <Link
              href="/docs"
              className="px-8 py-4 bg-gray-800 border border-gray-700 rounded-lg font-semibold text-lg hover:bg-gray-700 transition-colors"
            >
              View Documentation
            </Link>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mt-20">
          <FeatureCard
            icon={<Target className="w-8 h-8 text-tygr-orange" />}
            title="Multi-Target Scanning"
            description="Test multiple targets simultaneously - repositories, web apps, APIs, and infrastructure."
          />
          <FeatureCard
            icon={<Zap className="w-8 h-8 text-tygr-cyan" />}
            title="Real-Time Results"
            description="Watch as AI agents discover vulnerabilities in real-time with live progress monitoring."
          />
          <FeatureCard
            icon={<Shield className="w-8 h-8 text-tygr-green" />}
            title="Validated PoCs"
            description="Get actual proof-of-concept exploits, not false positives. Every finding is validated."
          />
          <FeatureCard
            icon={<Code2 className="w-8 h-8 text-tygr-red" />}
            title="Auto-Remediation"
            description="Receive actionable fix recommendations and auto-generated patches for discovered issues."
          />
        </div>

        {/* Stats Section */}
        <div className="mt-20 grid grid-cols-3 gap-8 max-w-3xl mx-auto">
          <StatCard number="15+" label="Agent Types" />
          <StatCard number="100+" label="Vulnerability Classes" />
          <StatCard number="99%" label="Accuracy Rate" />
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-gray-800 mt-20">
        <div className="container mx-auto px-4 py-8 text-center text-gray-500 text-sm">
          <p>© 2024 TYGR Security Platform. Built for security professionals.</p>
          <p className="mt-2">
            <a href="https://tygrsecurity.com" className="hover:text-tygr-orange transition-colors">
              tygrsecurity.com
            </a>
          </p>
        </div>
      </footer>
    </div>
  )
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode
  title: string
  description: string
}) {
  return (
    <div className="p-6 rounded-xl bg-gray-800/50 border border-gray-700 hover:border-tygr-orange/50 transition-colors">
      <div className="mb-4">{icon}</div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-sm text-gray-400">{description}</p>
    </div>
  )
}

function StatCard({ number, label }: { number: string; label: string }) {
  return (
    <div className="text-center">
      <div className="text-4xl font-bold tygr-gradient bg-clip-text text-transparent mb-2">
        {number}
      </div>
      <div className="text-gray-400 text-sm">{label}</div>
    </div>
  )
}
