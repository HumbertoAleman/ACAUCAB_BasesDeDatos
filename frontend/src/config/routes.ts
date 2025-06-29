import { GestionInventario } from "../pages/inventario/GestionInventario";
import { RegistroMiembro } from "../pages/miembros/RegistroMiembro";
import { Reportes } from "../pages/reportes/Reportes";
import { GestionUsuarios } from "../pages/usuarios/GestionUsuarios";
import { PuntoVenta } from "../pages/ventas/PuntoVenta";
import { GestionPrivilegios } from "../pages/privilegios/GestionPrivilegios";
import { GestionOrdenes } from "../pages/compras/GestionOrdenes";
import CarritoOnline from '../pages/carrito';
import CheckoutOnline from '../pages/checkout';

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
    path: "/dashboard",
    title: "Dashboard",
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
    path: '/carrito',
    title: 'Carrito',
    description: 'Carrito de compras online',
    component: CarritoOnline,
    inMenu: false,
  },
  {
    path: '/checkout',
    title: 'Checkout',
    description: 'Confirmar compra online',
    component: CheckoutOnline,
    inMenu: false,
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