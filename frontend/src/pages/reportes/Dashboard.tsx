import React, { useState } from "react";
import {
  Box,
  Typography,
  Paper,
  Grid,
  Card,
  CardContent,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from "@mui/material";
import {
  TrendingUp,
  BarChart,
  PeopleAlt,
  AccessTime,
  Warning,
  MonetizationOn,
  PieChart,
  Assessment,
  Store,
  Group,
} from "@mui/icons-material";
import { dashboardService } from "../../services/api";
import { PieChart as RechartsPieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer, BarChart as RechartsBarChart, Bar, XAxis, YAxis, CartesianGrid } from 'recharts';

// Definición de tipo para los indicadores
interface IndicadorDashboard {
  id: string;
  nombre: string;
  descripcion: string;
  icono: React.ReactNode;
  parametros: string[];
  grupo: string;
}

const indicadoresDashboard: IndicadorDashboard[] = [
  // Ventas
  {
    id: "ventas-totales",
    nombre: "Ventas Totales por Tienda",
    descripcion: "Muestra el total de ventas por tienda (online/presencial) en un periodo.",
    icono: <Store />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Ventas",
  },
  {
    id: "crecimiento-ventas",
    nombre: "Crecimiento de Ventas",
    descripcion: "Compara el crecimiento de ventas entre dos periodos.",
    icono: <TrendingUp />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Ventas",
  },
  {
    id: "ticket-promedio",
    nombre: "Ticket Promedio",
    descripcion: "Promedio de venta por ticket en un periodo.",
    icono: <BarChart />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Ventas",
  },
  {
    id: "volumen-unidades",
    nombre: "Volumen de Unidades Vendidas",
    descripcion: "Cantidad total de unidades vendidas en un periodo.",
    icono: <PieChart />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Ventas",
  },
  {
    id: "ventas-por-estilo",
    nombre: "Ventas por Estilo de Cerveza",
    descripcion: "Ventas agrupadas por tipo de cerveza en un periodo.",
    icono: <MonetizationOn />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Ventas",
  },
  // Clientes
  {
    id: "clientes-nuevos-vs-recurrentes",
    nombre: "Clientes Nuevos vs Recurrentes",
    descripcion: "Comparativo de clientes nuevos y recurrentes en el periodo.",
    icono: <Group />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Clientes",
  },
  {
    id: "tasa-retencion-clientes",
    nombre: "Tasa de Retención de Clientes",
    descripcion: "Porcentaje de clientes que repiten compras en el periodo.",
    icono: <PeopleAlt />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Clientes",
  },
  // Inventario y Operaciones
  {
    id: "rotacion-inventario",
    nombre: "Rotación de Inventario",
    descripcion: "Frecuencia de reposición de inventario en un periodo.",
    icono: <Assessment />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Inventario y Operaciones",
  },
  {
    id: "tasa-ruptura-stock",
    nombre: "Tasa de Ruptura de Stock",
    descripcion: "Porcentaje de veces que hubo quiebre de stock en un periodo.",
    icono: <Warning />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Inventario y Operaciones",
  },
  {
    id: "ventas-por-empleado",
    nombre: "Ventas por Empleado",
    descripcion: "Ventas totales realizadas por cada empleado en un periodo.",
    icono: <AccessTime />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Inventario y Operaciones",
  },
  // Reportes Clave
  {
    id: "grafico-tendencia-ventas",
    nombre: "Tendencia de Ventas (Gráfico)",
    descripcion: "Gráfico de tendencia de ventas en el periodo.",
    icono: <TrendingUp />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Reportes Clave",
  },
  {
    id: "grafico-ventas-por-canal",
    nombre: "Ventas por Canal (Gráfico)",
    descripcion: "Distribución de ventas por canal en el periodo.",
    icono: <PieChart />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Reportes Clave",
  },
  {
    id: "productos-mejor-rendimiento",
    nombre: "Productos de Mejor Rendimiento",
    descripcion: "Ranking de productos con mejor desempeño en el periodo.",
    icono: <BarChart />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Reportes Clave",
  },
  {
    id: "reporte-inventario-actual",
    nombre: "Inventario Actual",
    descripcion: "Estado actual del inventario en el periodo.",
    icono: <Store />,
    parametros: ["fecha_inicio", "fecha_fin"],
    grupo: "Reportes Clave",
  },
];

const grupos = [
  "Ventas",
  "Clientes",
  "Inventario y Operaciones",
  "Reportes Clave",
];

// Paleta de colores para los gráficos circulares
const pieColors = [
  '#2E7D32', '#66BB6A', '#A5D6A7', '#388E3C', '#81C784', '#C8E6C9', '#43A047', '#B9F6CA', '#00C853', '#B2FF59'
];

// Componente para renderizar un gráfico circular con recharts
const SimplePieChart = ({ data, dataKey, nameKey }: { data: any[], dataKey: string, nameKey: string }) => (
  <ResponsiveContainer width="100%" height={220}>
    <PieChart>
      <Pie
        data={data}
        dataKey={dataKey}
        nameKey={nameKey}
        cx="50%"
        cy="50%"
        outerRadius={80}
        label
      >
        {data.map((entry, idx) => (
          <Cell key={`cell-${idx}`} fill={pieColors[idx % pieColors.length]} />
        ))}
      </Pie>
      <Tooltip />
      <Legend />
    </PieChart>
  </ResponsiveContainer>
);

// Componente para renderizar un gráfico de barras con recharts
const SimpleBarChart = ({ data, xKey, yKey }: { data: any[], xKey: string, yKey: string }) => (
  <ResponsiveContainer width="100%" height={220}>
    <RechartsBarChart data={data}>
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey={xKey} />
      <YAxis />
      <Tooltip />
      <Legend />
      <Bar dataKey={yKey} fill="#2E7D32" />
    </RechartsBarChart>
  </ResponsiveContainer>
);

const Dashboard: React.FC = () => {
  const [indicadorSeleccionado, setIndicadorSeleccionado] = useState<IndicadorDashboard | null>(null);
  const [parametros, setParametros] = useState<Record<string, string>>({});
  const [resultado, setResultado] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleParametroChange = (parametro: string, valor: string) => {
    setParametros((prev) => ({ ...prev, [parametro]: valor }));
  };

  // Mapeo de id a función de servicio
  const fetchIndicador = async () => {
    if (!indicadorSeleccionado) return;
    setLoading(true);
    setError(null);
    setResultado(null);
    try {
      let res;
      const params = { fecha_inicio: parametros["fecha_inicio"], fecha_fin: parametros["fecha_fin"] };
      switch (indicadorSeleccionado.id) {
        case "ventas-totales":
          res = await dashboardService.ventasTotalesPorTienda(params);
          break;
        case "crecimiento-ventas":
          res = await dashboardService.crecimientoVentas(params);
          break;
        case "ticket-promedio":
          res = await dashboardService.ticketPromedio(params);
          break;
        case "volumen-unidades":
          res = await dashboardService.volumenUnidadesVendidas(params);
          break;
        case "ventas-por-estilo":
          res = await dashboardService.ventasPorEstilo(params);
          break;
        case "clientes-nuevos-vs-recurrentes":
          res = await dashboardService.clientesNuevosVsRecurrentes(params);
          break;
        case "tasa-retencion-clientes":
          res = await dashboardService.tasaRetencionClientes(params);
          break;
        case "rotacion-inventario":
          res = await dashboardService.rotacionInventario(params);
          break;
        case "tasa-ruptura-stock":
          res = await dashboardService.tasaRupturaStock(params);
          break;
        case "ventas-por-empleado":
          res = await dashboardService.ventasPorEmpleado(params);
          break;
        case "grafico-tendencia-ventas":
          res = await dashboardService.graficoTendenciaVentas(params);
          break;
        case "grafico-ventas-por-canal":
          res = await dashboardService.graficoVentasPorCanal(params);
          break;
        case "productos-mejor-rendimiento":
          res = await dashboardService.productosMejorRendimiento(params);
          break;
        case "reporte-inventario-actual":
          res = await dashboardService.reporteInventarioActual(params);
          break;
        default:
          setError("Indicador no implementado");
          setLoading(false);
          return;
      }
      if (res && res.success) {
        setResultado(res.data);
      } else {
        setError(res?.error || "Error al obtener datos");
      }
    } catch (err: any) {
      setError(err.message || "Error inesperado");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Centro de Indicadores
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
        Visualice y analice los indicadores clave del sistema
      </Typography>
      <Grid container spacing={3}>
        {/* Tarjetas de Indicadores */}
        <Grid size={{ xs: 12, md: 8 }}>
          {grupos.map((grupo) => (
            <Box key={grupo} sx={{ mb: 3 }}>
              <Typography variant="h6" sx={{ color: "#2E7D32", mb: 1, fontWeight: 600 }}>
                {grupo}
              </Typography>
              <Grid container spacing={2}>
                {indicadoresDashboard.filter((i) => i.grupo === grupo).map((indicador) => (
                  <Grid size={{ xs: 12, md: 4 }} key={indicador.id}>
                    <Card
                      sx={{
                        cursor: "pointer",
                        "&:hover": { boxShadow: 4 },
                        border: indicadorSeleccionado?.id === indicador.id ? "2px solid #2E7D32" : "1px solid #e0e0e0",
                      }}
                      onClick={() => setIndicadorSeleccionado(indicador)}
                    >
                      <CardContent>
                        <Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
                          <Box sx={{ color: "#2E7D32", mr: 2 }}>{indicador.icono}</Box>
                          <Typography variant="h6">{indicador.nombre}</Typography>
                        </Box>
                        <Typography variant="body2" color="text.secondary">
                          {indicador.descripcion}
                        </Typography>
                      </CardContent>
                    </Card>
                  </Grid>
                ))}
              </Grid>
            </Box>
          ))}
        </Grid>
        {/* Panel de Parámetros y Visualización */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2, position: "sticky", top: 20 }}>
            <Typography variant="h6" gutterBottom>
              Configuración del Indicador
            </Typography>
            {indicadorSeleccionado ? (
              <Box>
                <Typography variant="subtitle2" gutterBottom>
                  {indicadorSeleccionado.nombre}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  {indicadorSeleccionado.descripcion}
                </Typography>
                <Divider sx={{ mb: 2 }} />
                {/* Parámetros dinámicos */}
                <Box sx={{ mb: 3 }}>
                  <Typography variant="subtitle2" gutterBottom>
                    Parámetros:
                  </Typography>
                  {indicadorSeleccionado.parametros.map((parametro) => {
                    if (parametro === "fecha_inicio" || parametro === "fecha_fin") {
                      return (
                        <TextField
                          key={parametro}
                          fullWidth
                          label={parametro === "fecha_inicio" ? "Fecha Inicio" : "Fecha Fin"}
                          type="date"
                          value={parametros[parametro] || ""}
                          onChange={(e) => handleParametroChange(parametro, e.target.value)}
                          InputLabelProps={{ shrink: true }}
                          sx={{ mb: 2 }}
                        />
                      );
                    }
                    return null;
                  })}
                </Box>
                {/* Visualización de resultados */}
                <Paper variant="outlined" sx={{ p: 2, mb: 2, minHeight: 120, textAlign: "center" }}>
                  {loading ? (
                    <Typography variant="body2" color="text.secondary">Cargando...</Typography>
                  ) : error ? (
                    <Typography variant="body2" color="error">{error}</Typography>
                  ) : resultado ? (
                    // Mostrar gráficos de barras para todos los reportes clave
                    (indicadorSeleccionado.id === 'grafico-ventas-por-canal' && Array.isArray(resultado)) ? (
                      <SimpleBarChart data={resultado} xKey="Canal" yKey="Total Ventas" />
                    ) : (indicadorSeleccionado.id === 'productos-mejor-rendimiento' && Array.isArray(resultado)) ? (
                      <SimpleBarChart data={resultado} xKey="Producto" yKey="Unidades Vendidas" />
                    ) : (indicadorSeleccionado.id === 'reporte-inventario-actual' && Array.isArray(resultado)) ? (
                      <SimpleBarChart data={resultado} xKey="Producto" yKey="Stock Actual" />
                    ) : (indicadorSeleccionado.id === 'grafico-tendencia-ventas' && Array.isArray(resultado)) ? (
                      <SimpleBarChart data={resultado} xKey={Object.keys(resultado[0])[0]} yKey={Object.keys(resultado[0])[1]} />
                    ) : Array.isArray(resultado) && resultado.length > 0 && typeof resultado[0] === 'object' ? (
                      <TableContainer>
                        <Table size="small">
                          <TableHead>
                            <TableRow>
                              {Object.keys(resultado[0]).map((key) => (
                                <TableCell key={key} sx={{ fontWeight: 600 }}>{key}</TableCell>
                              ))}
                            </TableRow>
                          </TableHead>
                          <TableBody>
                            {resultado.map((row: any, idx: number) => (
                              <TableRow key={idx}>
                                {Object.keys(resultado[0]).map((key) => (
                                  <TableCell key={key}>{row[key]}</TableCell>
                                ))}
                              </TableRow>
                            ))}
                          </TableBody>
                        </Table>
                      </TableContainer>
                    ) : (
                      <pre style={{ textAlign: "left", whiteSpace: "pre-wrap", wordBreak: "break-word" }}>{JSON.stringify(resultado, null, 2)}</pre>
                    )
                  ) : (
                    <Typography variant="body2" color="text.secondary">
                      Aquí se mostrará el resultado del indicador seleccionado.
                    </Typography>
                  )}
                </Paper>
                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  sx={{ backgroundColor: "#2E7D32", '&:hover': { backgroundColor: "#1B5E20" } }}
                  onClick={fetchIndicador}
                  disabled={loading || !indicadorSeleccionado.parametros.every(p => parametros[p])}
                >
                  Visualizar Indicador
                </Button>
              </Box>
            ) : (
              <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 4 }}>
                Seleccione un indicador para configurar sus parámetros
              </Typography>
            )}
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard; 