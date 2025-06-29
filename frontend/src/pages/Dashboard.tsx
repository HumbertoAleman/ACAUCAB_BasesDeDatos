import type React from "react"
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Avatar,
} from "@mui/material"
import { Link as RouterLink, useNavigate } from "react-router-dom"
import {
  Dashboard as DashboardIcon,
  ShoppingCart,
  Inventory,
  Assessment,
  People,
  Settings,
  VerifiedUser,
  Receipt,
} from "@mui/icons-material"
import { ROUTES } from "../config/routes"

const routeIcons: Record<string, React.ReactElement> = {
  "/dashboard": <DashboardIcon />,
  "/ventas": <ShoppingCart />,
  "/inventario": <Inventory />,
  "/compras": <Receipt />,
  "/reportes": <Assessment />,
  "/usuarios": <People />,
  "/privilegios": <VerifiedUser />,
  "/configuracion": <Settings />,
}

const routeColors: Record<string, string> = {
  "/dashboard": "#2E7D32",
  "/ventas": "#4CAF50",
  "/inventario": "#FF9800",
  "/compras": "#9C27B0",
  "/reportes": "#2196F3",
  "/usuarios": "#00ACC1",
  "/privilegios": "#F44336",
  "/configuracion": "#607D8B",
}

export const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  // Solo módulos principales (inMenu)
  const mainRoutes = ROUTES.filter(r => r.inMenu && r.path !== "/dashboard")

  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Bienvenido al Sistema ACAUCAB
      </Typography>
      <Typography variant="body1" sx={{ mb: 4, color: "#555" }}>
        Accede rápidamente a los módulos principales del sistema:
      </Typography>
      <Grid container spacing={3}>
        {mainRoutes.map(route => (
          <Grid key={route.path} size={{ xs: 12, sm: 6, md: 4, lg: 3 }}>
            <Card
              component={RouterLink}
              to={route.path}
              sx={{
                textDecoration: "none",
                transition: "box-shadow 0.2s, transform 0.2s",
                boxShadow: 3,
                borderRadius: 3,
                '&:hover': {
                  boxShadow: 8,
                  transform: "scale(1.04)",
                },
                height: 220,
                minWidth: 220,
                display: "flex",
                flexDirection: "column",
                justifyContent: "center",
                alignItems: "center",
                background: `linear-gradient(135deg, ${routeColors[route.path] || "#2E7D32"}22 0%, #fff 100%)`,
                p: 3,
              }}
            >
              <Avatar sx={{ bgcolor: routeColors[route.path] || "#2E7D32", width: 64, height: 64, mb: 2, mx: "auto" }}>
                {routeIcons[route.path] || <Settings />}
              </Avatar>
              <CardContent sx={{ textAlign: "center", p: 0, width: "100%" }}>
                <Typography variant="h6" sx={{ fontWeight: "bold", color: routeColors[route.path] || "#2E7D32", mb: 1 }}>
                  {route.title}
                </Typography>
                <Typography variant="body2" color="textSecondary" sx={{ px: 1 }}>
                  {route.description}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        ))}
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 3 }}>
          <Card sx={{ minWidth: 200, cursor: 'pointer' }} onClick={() => navigate('/venta-online')}>
            <CardContent sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <ShoppingCart sx={{ fontSize: 40, color: 'primary.main', mb: 1 }} />
              <Typography variant="h6">Venta Online</Typography>
              <Typography variant="body2" color="text.secondary">Punto de venta para clientes online</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  )
}
