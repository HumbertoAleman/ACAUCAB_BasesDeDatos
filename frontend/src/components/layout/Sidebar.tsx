"use client"

import type React from "react"
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  Box,
  Typography,
} from "@mui/material"
import { Dashboard, ShoppingCart, Inventory, Assessment, People, Settings } from "@mui/icons-material"
import { useNavigate, useLocation } from "react-router-dom"
import { useAuth } from "../../contexts/AuthContext"

const drawerWidth = 280

interface SidebarProps {
  open: boolean
  onClose: () => void
}

interface MenuItem {
  text: string
  icon: React.ReactNode
  path: string
  permission?: string
}

const menuItems: MenuItem[] = [
  { text: "Dashboard", icon: <Dashboard />, path: "/dashboard" },
  { text: "Ventas", icon: <ShoppingCart />, path: "/ventas", permission: "ventas" },
  { text: "Inventario", icon: <Inventory />, path: "/inventario", permission: "inventario" },
  { text: "Reportes", icon: <Assessment />, path: "/reportes", permission: "reportes" },
  { text: "Usuarios", icon: <People />, path: "/usuarios", permission: "usuarios" },
  { text: "Configuración", icon: <Settings />, path: "/configuracion" },
]

export const Sidebar: React.FC<SidebarProps> = ({ open, onClose }) => {
  const navigate = useNavigate()
  const location = useLocation()
  const { hasPermission } = useAuth()

  const handleNavigation = (path: string) => {
    navigate(path)
    onClose()
  }

  const filteredMenuItems = menuItems.filter((item) => {
    if (!item.permission) return true
    return hasPermission(item.permission)
  })

  return (
    <Drawer
      variant="temporary"
      open={open}
      onClose={onClose}
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        "& .MuiDrawer-paper": {
          width: drawerWidth,
          boxSizing: "border-box",
        },
      }}
    >
      <Box sx={{ p: 2, backgroundColor: "#2E7D32", color: "white" }}>
        <Typography variant="h6" component="div">
          ACAUCAB
        </Typography>
        <Typography variant="body2" sx={{ opacity: 0.8 }}>
          Cerveza Artesanal
        </Typography>
      </Box>

      <Divider />

      <List>
        {filteredMenuItems.map((item) => (
          <ListItem key={item.text} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => handleNavigation(item.path)}
              sx={{
                "&.Mui-selected": {
                  backgroundColor: "#E8F5E8",
                  "&:hover": {
                    backgroundColor: "#E8F5E8",
                  },
                },
              }}
            >
              <ListItemIcon sx={{ color: location.pathname === item.path ? "#2E7D32" : "inherit" }}>
                {item.icon}
              </ListItemIcon>
              <ListItemText
                primary={item.text}
                sx={{ color: location.pathname === item.path ? "#2E7D32" : "inherit" }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Drawer>
  )
}
