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
import { Dashboard as DashboardIcon, ShoppingCart, Inventory, Assessment, People, Settings, VerifiedUser, Receipt, EventAvailable, Insights } from "@mui/icons-material";
import { Homepage } from "../../pages/Homepage";
import { Link as RouterLink, useLocation, useNavigate } from "react-router-dom"
import { useAuth } from "../../contexts/AuthContext"
import { getAccessibleRoutes } from "../../config/routes"

const drawerWidth = 280

// Mapeo de iconos centralizado
const routeIcons: Record<string, React.ReactElement> = {
  "/homepage": <DashboardIcon />,
  "/ventas": <ShoppingCart />,
  "/inventario": <Inventory />,
  "/compras": <Receipt />,
  "/reportes": <Assessment />,
  "/reportes/dashboard": <Insights />,
  "/eventos": <EventAvailable />,
  "/usuarios": <People />,
  "/privilegios": <VerifiedUser />,
  "/configuracion": <Settings />,
}

interface SidebarProps { open: boolean; onClose: () => void; onVentaOnlineClick?: () => void }
export const Sidebar: React.FC<SidebarProps> = ({
  open,
  onClose,
  onVentaOnlineClick
}) => {
  const location = useLocation()
  const navigate = useNavigate()
  const { hasPermission } = useAuth()

  // Lógica original para obtener rutas basadas en permisos
  const accessibleRoutes = getAccessibleRoutes().filter(route => route.inMenu)

  // Ordenar rutas: usuarios y privilegios al final
  const orderedRoutes = [
    ...accessibleRoutes.filter(r => r.path !== "/usuarios" && r.path !== "/privilegios"),
    ...accessibleRoutes.filter(r => r.path === "/usuarios" || r.path === "/privilegios"),
  ];

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
        {orderedRoutes.map((route) => (
          <ListItem key={route.path} disablePadding component={RouterLink} to={route.path}>
            <ListItemButton
              selected={location.pathname === route.path}
              sx={{
                backgroundColor: location.pathname === route.path ? "rgba(46, 125, 50, 0.08)" : "inherit",
              }}
            >
              <ListItemIcon
                sx={{
                  color: location.pathname === route.path ? "#2E7D32" : "#757575",
                }}
              >
                {routeIcons[route.path] || <Settings />}
              </ListItemIcon>
              <ListItemText
                primary={route.title}
                secondary={route.description}
                sx={{
                  color: location.pathname === route.path ? "#2E7D32" : "#212121",
                  "& .MuiListItemText-secondary": {
                    fontSize: "0.75rem",
                    opacity: 0.7,
                  },
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Drawer>
  )
}
