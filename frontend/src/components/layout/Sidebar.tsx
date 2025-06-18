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
import { getAccessibleRoutes } from "../../config/routes"

const drawerWidth = 280

interface SidebarProps {
  open: boolean
  onClose: () => void
}

// Mapeo de iconos para las rutas
const routeIcons: Record<string, React.ReactNode> = {
  "/dashboard": <Dashboard />,
  "/ventas": <ShoppingCart />,
  "/inventario": <Inventory />,
  "/reportes": <Assessment />,
  "/usuarios": <People />,
  "/configuracion": <Settings />,
}

export const Sidebar: React.FC<SidebarProps> = ({ open, onClose }) => {
  const navigate = useNavigate()
  const location = useLocation()
  const { hasPermission } = useAuth()

  const handleNavigation = (path: string) => {
    navigate(path)
    onClose()
  }

  // Obtener rutas accesibles según los permisos del usuario
  const accessibleRoutes = getAccessibleRoutes(hasPermission)

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
        {accessibleRoutes.map((route) => (
          <ListItem key={route.path} disablePadding>
            <ListItemButton
              selected={location.pathname === route.path}
              onClick={() => handleNavigation(route.path)}
              sx={{
                "&.Mui-selected": {
                  backgroundColor: "#E8F5E8",
                  "&:hover": {
                    backgroundColor: "#E8F5E8",
                  },
                },
              }}
            >
              <ListItemIcon sx={{ color: location.pathname === route.path ? "#2E7D32" : "inherit" }}>
                {routeIcons[route.path] || <Settings />}
              </ListItemIcon>
              <ListItemText
                primary={route.title}
                secondary={route.description}
                sx={{ 
                  color: location.pathname === route.path ? "#2E7D32" : "inherit",
                  "& .MuiListItemText-secondary": {
                    fontSize: "0.75rem",
                    opacity: 0.7,
                  }
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Drawer>
  )
}
