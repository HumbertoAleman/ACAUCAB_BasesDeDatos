import { sql } from 'bun';
import { CORS_HEADERS } from '../globals';

export class DashboardService {
  // 1. Indicadores de Ventas
  static async ventasTotalesPorTienda(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM periodo_ventas_totales(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async crecimientoVentas(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM crecimiento_ventas(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async ticketPromedio(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM ticket_promedio_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async volumenUnidadesVendidas(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM volumen_unidades_vendidas_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async ventasPorEstilo(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM ventas_por_estilo_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  // 2. Indicadores de Clientes
  static async clientesNuevosVsRecurrentes(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM clientes_nuevos_vs_recurrentes(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async tasaRetencionClientes(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM tasa_retencion_clientes(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  // 3. Indicadores de Inventario y Operaciones
  static async rotacionInventario(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM rotacion_inventario_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async tasaRupturaStock(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM tasa_ruptura_stock_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async ventasPorEmpleado(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM ventas_por_empleado_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  // 4. Reportes Clave
  static async graficoTendenciaVentas(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM tendencia_ventas_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async graficoVentasPorCanal(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM ventas_por_canal_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async productosMejorRendimiento(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM productos_mejor_rendimiento_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }

  static async reporteInventarioActual(req: Request) {
    try {
      const url = new URL(req.url);
      const fecha_inicio = url.searchParams.get('fecha_inicio');
      const fecha_fin = url.searchParams.get('fecha_fin');
      const result = await sql`SELECT * FROM inventario_actual_periodo(${fecha_inicio}::date, ${fecha_fin}::date)`;
      return Response.json({ success: true, data: result }, CORS_HEADERS);
    } catch (error) {
      return Response.json({ success: false, error: error instanceof Error ? error.message : 'Error desconocido' }, CORS_HEADERS);
    }
  }
}

export const dashboardRoutes = () => ({
  '/api/dashboard/ventas-totales': { GET: DashboardService.ventasTotalesPorTienda, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/crecimiento-ventas': { GET: DashboardService.crecimientoVentas, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/ticket-promedio': { GET: DashboardService.ticketPromedio, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/volumen-unidades': { GET: DashboardService.volumenUnidadesVendidas, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/ventas-por-estilo': { GET: DashboardService.ventasPorEstilo, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/clientes-nuevos-vs-recurrentes': { GET: DashboardService.clientesNuevosVsRecurrentes, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/tasa-retencion-clientes': { GET: DashboardService.tasaRetencionClientes, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/rotacion-inventario': { GET: DashboardService.rotacionInventario, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/tasa-ruptura-stock': { GET: DashboardService.tasaRupturaStock, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/ventas-por-empleado': { GET: DashboardService.ventasPorEmpleado, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/grafico-tendencia-ventas': { GET: DashboardService.graficoTendenciaVentas, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/grafico-ventas-por-canal': { GET: DashboardService.graficoVentasPorCanal, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/productos-mejor-rendimiento': { GET: DashboardService.productosMejorRendimiento, OPTIONS: () => new Response('', CORS_HEADERS) },
  '/api/dashboard/inventario-actual': {
    GET: DashboardService.reporteInventarioActual,
    OPTIONS: () => new Response('', CORS_HEADERS),
  },
}); 