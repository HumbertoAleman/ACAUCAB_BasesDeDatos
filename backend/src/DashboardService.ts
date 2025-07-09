import { sql } from 'bun';
import { CORS_HEADERS } from '../globals';

export class DashboardService {
  // 1. Indicadores de Ventas
  static async ventasTotalesPorTienda(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const trimonth = Number(url.searchParams.get('trimonth'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM periodo_ventas_totales(${year}, ${month}, ${trimonth}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async crecimientoVentas(req: Request) {
    const url = new URL(req.url);
    const ini = url.searchParams.get('ini');
    const fin = url.searchParams.get('fin');
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM crecimiento_ventas(${ini}, ${fin}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async ticketPromedio(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM ticket_promedio_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async volumenUnidadesVendidas(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM volumen_unidades_vendidas_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async ventasPorEstilo(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM ventas_por_estilo_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  // 2. Indicadores de Clientes
  static async clientesNuevosVsRecurrentes(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM clientes_nuevos_vs_recurrentes(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async tasaRetencionClientes(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM tasa_retencion_clientes(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  // 3. Indicadores de Inventario y Operaciones
  static async rotacionInventario(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM rotacion_inventario_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async tasaRupturaStock(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM tasa_ruptura_stock_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async ventasPorEmpleado(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const month = Number(url.searchParams.get('month'));
    const modalidad = url.searchParams.get('modalidad') || 'mensual';
    const result = await sql`SELECT * FROM ventas_por_empleado_periodo(${year}, ${month}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  // 4. Reportes Clave
  static async graficoTendenciaVentas(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM tendencia_ventas_periodo(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async graficoVentasPorCanal(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM ventas_por_canal_periodo(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async tablaProductosMejorRendimiento(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM productos_mejor_rendimiento_periodo(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }

  static async reporteInventarioActual(req: Request) {
    const url = new URL(req.url);
    const year = Number(url.searchParams.get('year'));
    const modalidad = url.searchParams.get('modalidad') || 'anual';
    const result = await sql`SELECT * FROM inventario_actual_periodo(${year}, ${modalidad})`;
    return Response.json(result, CORS_HEADERS);
  }
}

export const dashboardRoutes = () => ({
  '/api/dashboard/ventas-totales': { GET: DashboardService.ventasTotalesPorTienda },
  '/api/dashboard/crecimiento-ventas': { GET: DashboardService.crecimientoVentas },
  '/api/dashboard/ticket-promedio': { GET: DashboardService.ticketPromedio },
  '/api/dashboard/volumen-unidades': { GET: DashboardService.volumenUnidadesVendidas },
  '/api/dashboard/ventas-por-estilo': { GET: DashboardService.ventasPorEstilo },
  '/api/dashboard/clientes-nuevos-vs-recurrentes': { GET: DashboardService.clientesNuevosVsRecurrentes },
  '/api/dashboard/tasa-retencion-clientes': { GET: DashboardService.tasaRetencionClientes },
  '/api/dashboard/rotacion-inventario': { GET: DashboardService.rotacionInventario },
  '/api/dashboard/tasa-ruptura-stock': { GET: DashboardService.tasaRupturaStock },
  '/api/dashboard/ventas-por-empleado': { GET: DashboardService.ventasPorEmpleado },
  '/api/dashboard/grafico-tendencia-ventas': { GET: DashboardService.graficoTendenciaVentas },
  '/api/dashboard/grafico-ventas-por-canal': { GET: DashboardService.graficoVentasPorCanal },
  '/api/dashboard/productos-mejor-rendimiento': { GET: DashboardService.tablaProductosMejorRendimiento },
  '/api/dashboard/inventario-actual': { GET: DashboardService.reporteInventarioActual },
}); 