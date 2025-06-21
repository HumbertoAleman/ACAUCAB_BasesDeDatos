export interface RouteConfig {
  path: string
  permission?: string
  title: string
  icon?: string
  description?: string
}

export const ROUTES: RouteConfig[] = [
  {
    path: "/dashboard",
    title: "Dashboard",
    description: "Panel principal del sistema",
  },
  {
    path: "/ventas",
    permission: "venta_read",
    title: "Ventas",
    description: "Gestión de ventas y punto de venta",
  },
  {
    path: "/inventario",
    permission: "inventario_read",
    title: "Inventario",
    description: "Gestión de inventario y productos",
  },
  {
    path: "/reportes",
    permission: "reporte_read",
    title: "Reportes",
    description: "Reportes y estadísticas",
  },
  {
    path: "/usuarios",
    permission: "usuario_read",
    title: "Usuarios",
    description: "Gestión de usuarios y roles",
  },
]

export const getAccessibleRoutes = (): RouteConfig[] => {
  return ROUTES
}

export const getFirstAccessibleRoute = (): string => {
  const accessibleRoutes = ROUTES
  return accessibleRoutes.length > 0 ? accessibleRoutes[0].path : "/dashboard"
}

export const checkRouteAccess = (): boolean => {
  return true
} 