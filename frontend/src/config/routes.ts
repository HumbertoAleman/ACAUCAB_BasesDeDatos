import { GestionInventario } from "../pages/inventario/GestionInventario";
import { RegistroMiembro } from "../pages/miembros/RegistroMiembro";
import { Reportes } from "../pages/reportes/Reportes";
import { GestionUsuarios } from "../pages/usuarios/GestionUsuarios";
import { PuntoVenta } from "../pages/ventas/PuntoVenta";
import { GestionPrivilegios } from "../pages/privilegios/GestionPrivilegios";
import { GestionOrdenes } from "../pages/compras/GestionOrdenes";
import PuntoVentaOnline from '../pages/ventas/PuntoVentaOnline';
import GestionEventos from '../pages/eventos/GestionEventos';
import Dashboard from "../pages/reportes/Dashboard";

export interface RouteConfig {
  path: string
  permission?: string
  title: string
  icon?: string
  description?: string
  component?: React.ComponentType<any>
  inMenu: boolean
}

export const ROUTES: RouteConfig[] = [
  {
    path: "/homepage",
    title: "Homepage",
    description: "Panel principal del sistema",
    inMenu: true,
  },
  {
    path: "/ventas",
    permission: "venta_read",
    title: "Ventas",
    description: "Gestión de ventas y punto de venta",
    inMenu: true,
  },
  {
    path: "/inventario",
    permission: "inventario_read",
    title: "Inventario",
    description: "Gestión de inventario y productos",
    inMenu: true,
  },
  {
    path: "/compras",
    permission: "inventario_read",
    title: "Órdenes de Compra",
    description: "Gestión de órdenes de reposición",
    inMenu: true,
  },
  {
    path: "/reportes",
    permission: "reporte_read",
    title: "Reportes",
    description: "Reportes y estadísticas",
    inMenu: true,
  },
  {
    path: "/reportes/dashboard",
    permission: "reporte_read",
    title: "Dashboard",
    description: "Dashboard de indicadores",
    component: Dashboard,
    inMenu: true,
  },
  {
    path: "/usuarios",
    permission: "usuario_read",
    title: "Usuarios",
    icon: "people",
    description: "Gestión de usuarios y roles",
    component: GestionUsuarios,
    inMenu: true,
  },
  {
    path: "/privilegios",
    title: "Privilegios",
    icon: "verified_user",
    description: "Gestión de privilegios por rol",
    component: GestionPrivilegios,
    inMenu: true,
  },
  {
    path: "/miembros/registro",
    title: "Registro de Miembros",
    component: RegistroMiembro,
    inMenu: false,
  },
  {
    path: "/eventos",
    permission: "evento_read",
    title: "Eventos",
    icon: "event",
    description: "Gestión de eventos y entradas",
    component: GestionEventos,
    inMenu: true,
  },
  {
    path: '/ventas-online',
    title: 'Venta Online',
    description: 'Punto de venta para clientes online',
    component: PuntoVentaOnline,
    inMenu: false,
  },
]

export const getAccessibleRoutes = (): RouteConfig[] => {
  return ROUTES
}

export const getFirstAccessibleRoute = (hasPermission: (perm: string) => boolean): string => {
  for (const route of ROUTES) {
    if (!route.permission || hasPermission(route.permission)) {
      return route.path;
    }
  }
  return "/homepage";
}

export const checkRouteAccess = (path: string, hasPermission: (perm: string) => boolean): boolean => {
  const route = ROUTES.find(r => r.path === path);
  if (!route) return false;
  if (!route.permission) return true;
  return hasPermission(route.permission);
} 