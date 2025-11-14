# TYGR Security Agent - Web UI

A state-of-the-art Next.js web application that provides a professional UI for the TYGR Security Platform. Built with Next.js 15, TypeScript, TailwindCSS, and shadcn/ui.

## 🐯 Features

### Mission Control Dashboard
- **Real-time Scan Monitoring**: Watch security hunts in progress with live updates
- **Active Hunt Tracking**: Monitor multiple concurrent scans with progress indicators
- **Hunt History**: Browse and analyze past security assessments
- **Statistics Overview**: View key metrics and security scores

### Hunt Configuration Wizard (Coming Soon)
- **Multi-Target Support**: Test repositories, web apps, APIs, and infrastructure
- **Custom Instructions**: Define focus areas and test credentials
- **Profile Presets**: Quick Prowl, Deep Stalk, API Hunter, Auth Ambush
- **Smart Validation**: Real-time target validation and reachability checks

### Live Hunt Monitor (Coming Soon)
- **Real-Time Streaming**: SSE-based event streaming for instant updates
- **Vulnerability Feed**: Live discovery of security issues as they're found
- **Agent Activity**: Watch AI agents collaborate and execute tools
- **Terminal Output**: Full ANSI-colored CLI output with search

### Intelligence Center (Coming Soon)
- **Vulnerability Analysis**: Detailed findings with PoCs and remediation
- **Attack Graph Visualization**: Interactive attack chain mapping
- **Code Diff Viewer**: Side-by-side vulnerable vs. fixed code
- **Export Capabilities**: PDF, SARIF, JSON, Markdown reports

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Docker (running)
- TYGR CLI installed (in parent directory)
- LLM API key (OpenAI, Anthropic, or local model)

### Installation

```bash
# Install dependencies
npm install

# Configure environment (optional)
cp .env.example .env
# Edit .env with your configuration

# Run development server
npm run dev

# Open browser
# Navigate to http://localhost:3000
```

### Production Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

## 🎨 TYGR Brand Design System

### Color Palette

```typescript
// Primary Colors
tygr-orange: #FF6B35  // Main brand color
tygr-black: #000000   // Dark backgrounds
tygr-gray: #2d3748    // Secondary dark

// Accent Colors
tygr-cyan: #00d9ff    // Info/Active states
tygr-green: #10b981   // Success/Safe
tygr-red: #ef4444     // Critical/Danger

// Severity Colors
critical: Red (#ef4444)
high: Orange (#fb923c)
medium: Yellow (#fbbf24)
low: Blue (#3b82f6)
info: Gray (#6b7280)
```

### Typography

- **Sans Serif**: Inter (UI text)
- **Monospace**: JetBrains Mono (code, logs, terminal)

### Components

Built with shadcn/ui and Radix UI primitives:
- Button, Card, Badge, Input
- Progress, Separator, Tooltip
- Dialog, Dropdown, Select, Tabs
- Toast notifications (sonner)

## 📁 Project Structure

```
web-ui/
├── app/                    # Next.js App Router
│   ├── api/               # API routes
│   │   ├── scans/        # Scan management endpoints
│   │   └── config/       # Configuration endpoints
│   ├── dashboard/        # Dashboard pages
│   │   ├── page.tsx      # Mission Control
│   │   ├── new-hunt/     # Hunt Configuration Wizard
│   │   ├── hunts/[id]/   # Hunt details & monitor
│   │   └── config/       # Settings
│   ├── layout.tsx        # Root layout
│   ├── page.tsx          # Landing page
│   ├── globals.css       # Global styles
│   └── providers.tsx     # React Query provider
├── components/
│   ├── ui/               # shadcn/ui components
│   └── [feature]/        # Feature-specific components
├── lib/
│   ├── types/            # TypeScript type definitions
│   ├── utils.ts          # Utility functions
│   └── scan-manager.ts   # Scan process management
├── public/               # Static assets
├── package.json
├── tsconfig.json
├── tailwind.config.ts
└── next.config.js
```

## 🔧 API Routes

### Scan Management

- `POST /api/scans/start` - Start a new security hunt
- `GET /api/scans` - List all hunts
- `GET /api/scans/[id]` - Get hunt details
- `GET /api/scans/[id]/stream` - SSE stream for real-time events
- `POST /api/scans/[id]/cancel` - Cancel a running hunt

### Configuration (Coming Soon)

- `GET /api/config` - Get application configuration
- `POST /api/config` - Update configuration
- `POST /api/config/validate` - Validate LLM connection

## 🛠️ Development

### Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript 5.6
- **Styling**: TailwindCSS 3.4 + shadcn/ui
- **State Management**:
  - TanStack Query v5 (server state)
  - Zustand (client state)
- **UI Components**: Radix UI primitives
- **Animations**: Framer Motion
- **Charts**: Recharts
- **Notifications**: sonner
- **Date Handling**: date-fns

### Scripts

```bash
npm run dev          # Development server (port 3000)
npm run build        # Production build
npm start            # Production server
npm run lint         # ESLint
npm run type-check   # TypeScript check
```

### Environment Variables

Create `.env.local` for local development:

```env
# Optional: Pre-configure LLM settings
NEXT_PUBLIC_DEFAULT_LLM_MODEL=openai/gpt-5
NEXT_PUBLIC_DEFAULT_LLM_API_BASE=

# Docker configuration
NEXT_PUBLIC_DOCKER_IMAGE=ghcr.io/aderm97/tygr-sandbox:latest
```

## 🔄 Integration with TYGR CLI

The web UI spawns TYGR CLI as a subprocess for each hunt:

```typescript
import { spawn } from 'child_process'

const process = spawn('tygr', [
  '-n',  // non-interactive
  '--target', target,
  '--instruction', instruction,
  '--run-name', runName
], {
  env: {
    TYGR_LLM: config.llm,
    LLM_API_KEY: config.apiKey,
    LLM_API_BASE: config.apiBase
  }
})
```

### Real-Time Event Streaming

Server-Sent Events (SSE) stream hunt progress:

```typescript
const eventSource = new EventSource(`/api/scans/${scanId}/stream`)

eventSource.addEventListener('message', (event) => {
  const data = JSON.parse(event.data)

  switch (data.type) {
    case 'vulnerability_found':
      // Update vulnerability list
      break
    case 'scan_progress':
      // Update progress bar
      break
    case 'log':
      // Append to terminal
      break
  }
})
```

## 🎯 Roadmap

### Phase 1: Foundation ✅
- [x] Next.js project setup
- [x] TYGR brand design system
- [x] API routes for scan management
- [x] Mission Control dashboard
- [x] Basic scan listing and monitoring

### Phase 2: Core Features (In Progress)
- [ ] Hunt Configuration Wizard
- [ ] Live Hunt Monitor with streaming
- [ ] Configuration management
- [ ] Scan history persistence (SQLite)

### Phase 3: Advanced Features
- [ ] Intelligence Center
- [ ] Vulnerability analysis and PoC viewer
- [ ] Attack graph visualization
- [ ] Code diff viewer
- [ ] Export capabilities (PDF, SARIF)

### Phase 4: Enterprise Features
- [ ] Multi-user authentication
- [ ] Role-based access control
- [ ] Team collaboration
- [ ] Audit logging
- [ ] Webhook integrations
- [ ] Custom detection rules

### Phase 5: Platform Enhancements
- [ ] Knowledge Base
- [ ] Vulnerability library
- [ ] Remediation playbooks
- [ ] Compliance mapping (OWASP, CWE, SANS)
- [ ] CI/CD integration guides

## 🤝 Contributing

Contributions are welcome! This web UI is part of the TYGR Security Platform.

See the main [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## 📝 License

Apache 2.0 - See [LICENSE](../LICENSE) for details.

## 🔗 Links

- **TYGR CLI**: [../README.md](../README.md)
- **Website**: https://tygrsecurity.com
- **Documentation**: Coming soon
- **GitHub**: https://github.com/aderm97/tygr

---

**Built with ❤️ for security professionals**

🐯 TYGR Security Platform - AI-Powered Security Testing
