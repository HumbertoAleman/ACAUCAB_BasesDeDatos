"use client"

import type React from "react"
import { useState } from "react"
import { Box, IconButton, useMediaQuery, useTheme } from "@mui/material"
import { Menu } from "@mui/icons-material"
import { Navbar } from "./Navbar"
import { Sidebar } from "./Sidebar"

interface LayoutProps {
  children: React.ReactNode
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down("md"))

  const handleSidebarToggle = () => {
    setSidebarOpen(!sidebarOpen)
  }

  return (
    <Box sx={{ display: "flex", flexDirection: "column", minHeight: "100vh" }}>
      <Navbar />

      <Box sx={{ display: "flex", flex: 1 }}>
        <Box sx={{ p: 1 }}>
          <IconButton color="inherit" aria-label="open drawer" onClick={handleSidebarToggle} sx={{ color: "#2E7D32" }}>
            <Menu />
          </IconButton>
        </Box>

        <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

        <Box
          component="main"
          sx={{
            flexGrow: 1,
            p: 3,
            backgroundColor: "#f5f5f5",
            minHeight: "calc(100vh - 64px)",
          }}
        >
          {children}
        </Box>
      </Box>
    </Box>
  )
}
