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
    permission: "ventas",
    title: "Ventas",
    description: "Gestión de ventas y punto de venta",
  },
  {
    path: "/inventario",
    permission: "inventario",
    title: "Inventario",
    description: "Gestión de inventario y productos",
  },
  {
    path: "/reportes",
    permission: "reportes",
    title: "Reportes",
    description: "Reportes y estadísticas",
  },
  {
    path: "/usuarios",
    permission: "usuarios",
    title: "Usuarios",
    description: "Gestión de usuarios y roles",
  },
  {
    path: "/configuracion",
    title: "Configuración",
    description: "Configuración del sistema",
  },
]

export const getAccessibleRoutes = (hasPermission: (permission: string) => boolean): RouteConfig[] => {
  return ROUTES.filter(route => {
    if (!route.permission) return true
    return hasPermission(route.permission)
  })
}

export const getFirstAccessibleRoute = (hasPermission: (permission: string) => boolean): string => {
  const accessibleRoutes = getAccessibleRoutes(hasPermission)
  return accessibleRoutes.length > 0 ? accessibleRoutes[0].path : "/dashboard"
}

export const checkRouteAccess = (path: string, hasPermission: (permission: string) => boolean): boolean => {
  const route = ROUTES.find(r => r.path === path)
  if (!route) return true // Rutas no configuradas permitidas por defecto
  if (!route.permission) return true
  return hasPermission(route.permission)
} 