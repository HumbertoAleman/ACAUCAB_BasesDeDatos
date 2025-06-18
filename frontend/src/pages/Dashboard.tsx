import type React from "react"
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Paper,
  Avatar,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  Chip,
} from "@mui/material"
import { TrendingUp, People, Inventory, ShoppingCart, LocalBar, Event, AttachMoney, Warning } from "@mui/icons-material"

const StatCard: React.FC<{
  title: string
  value: string
  icon: React.ReactNode
  color: string
  subtitle?: string
}> = ({ title, value, icon, color, subtitle }) => (
  <Card sx={{ height: "100%" }}>
    <CardContent>
      <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <Box>
          <Typography color="textSecondary" gutterBottom variant="overline">
            {title}
          </Typography>
          <Typography variant="h4" component="div" sx={{ fontWeight: "bold" }}>
            {value}
          </Typography>
          {subtitle && (
            <Typography variant="body2" color="textSecondary">
              {subtitle}
            </Typography>
          )}
        </Box>
        <Avatar sx={{ backgroundColor: color, width: 56, height: 56 }}>{icon}</Avatar>
      </Box>
    </CardContent>
  </Card>
)

export const Dashboard: React.FC = () => {
  const recentSales = [
    { id: 1, client: "Hotel Caracas", amount: "Bs. 2,500.00", time: "Hace 2 horas" },
    { id: 2, client: "Restaurante El Parador", amount: "Bs. 1,800.00", time: "Hace 4 horas" },
    { id: 3, client: "Bodega Central", amount: "Bs. 3,200.00", time: "Hace 6 horas" },
  ]

  const lowStockItems = [
    { name: "Destilo Amber Ale", stock: 85, status: "warning" },
    { name: "Benitz Pale Ale", stock: 45, status: "critical" },
    { name: "Mito Candileja", stock: 92, status: "warning" },
  ]

  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Dashboard
      </Typography>

      <Grid container spacing={3}>
        {/* Estadísticas principales */}
        <Grid size={{ xs: 12, sm: 6, md:3 }}>
          <StatCard
            title="Ventas del Día"
            value="Bs. 12,450"
            icon={<AttachMoney />}
            color="#4CAF50"
            subtitle="+15% vs ayer"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md:3 }}>
          <StatCard
            title="Clientes Activos"
            value="1,234"
            icon={<People />}
            color="#2196F3"
            subtitle="89 nuevos este mes"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md:3 }}>
          <StatCard
            title="Productos en Stock"
            value="45,678"
            icon={<Inventory />}
            color="#FF9800"
            subtitle="12 productos bajo mínimo"
          />
        </Grid>

        <Grid size={{ xs: 12, sm: 6, md:3 }}>
          <StatCard
            title="Órdenes Pendientes"
            value="23"
            icon={<ShoppingCart />}
            color="#9C27B0"
            subtitle="5 para entrega hoy"
          />
        </Grid>

        {/* Ventas recientes */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}>
              <TrendingUp />
              Ventas Recientes
            </Typography>
            <List>
              {recentSales.map((sale) => (
                <ListItem key={sale.id}>
                  <ListItemAvatar>
                    <Avatar sx={{ backgroundColor: "#E8F5E8", color: "#2E7D32" }}>
                      <ShoppingCart />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText primary={sale.client} secondary={sale.time} />
                  <Typography variant="h6" sx={{ color: "#2E7D32", fontWeight: "bold" }}>
                    {sale.amount}
                  </Typography>
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>

        {/* Alertas de inventario */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}>
              <Warning />
              Alertas de Inventario
            </Typography>
            <List>
              {lowStockItems.map((item, index) => (
                <ListItem key={index}>
                  <ListItemAvatar>
                    <Avatar sx={{ backgroundColor: "#FFF3E0", color: "#F57C00" }}>
                      <LocalBar />
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText primary={item.name} secondary={`${item.stock} unidades restantes`} />
                  <Chip
                    label={item.status === "critical" ? "Crítico" : "Bajo"}
                    color={item.status === "critical" ? "error" : "warning"}
                    size="small"
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>

        {/* Próximos eventos */}
        <Grid size={{ xs: 12 }}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}>
              <Event />
              Próximos Eventos
            </Typography>
            <Grid container spacing={2}>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" color="primary">
                      Festival de Cerveza Artesanal
                    </Typography>
                    <Typography color="textSecondary">15 de Abril, 2024</Typography>
                    <Typography variant="body2">Plaza Venezuela, Caracas</Typography>
                    <Chip label="Confirmado" color="success" size="small" sx={{ mt: 1 }} />
                  </CardContent>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" color="primary">
                      Taller de Cata
                    </Typography>
                    <Typography color="textSecondary">22 de Abril, 2024</Typography>
                    <Typography variant="body2">Sede ACAUCAB</Typography>
                    <Chip label="Planificando" color="warning" size="small" sx={{ mt: 1 }} />
                  </CardContent>
                </Card>
              </Grid>
              <Grid size={{ xs: 12, md: 4 }}>
                <Card variant="outlined">
                  <CardContent>
                    <Typography variant="h6" color="primary">
                      UBirra 2024
                    </Typography>
                    <Typography color="textSecondary">5 de Mayo, 2024</Typography>
                    <Typography variant="body2">Plaza Mickey, Caracas</Typography>
                    <Chip label="En preparación" color="info" size="small" sx={{ mt: 1 }} />
                  </CardContent>
                </Card>
              </Grid>
            </Grid>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  )
}
