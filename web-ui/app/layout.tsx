import type { Metadata } from "next"
import "./globals.css"
import { Providers } from "./providers"

export const metadata: Metadata = {
  title: "TYGR Security Agent - AI-Powered Penetration Testing",
  description: "Professional security testing platform with autonomous AI agents. Find vulnerabilities faster with real validation and proof-of-concepts.",
  keywords: ["security", "penetration testing", "vulnerability scanner", "AI", "TYGR"],
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="font-sans antialiased">
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}
