"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Paper,
  Typography,
  Button,
  Grid,
  Card,
  CardContent,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
} from "@mui/material"
import {
  Download,
  Assessment,
  TrendingUp,
  PieChart,
  BarChart,
  PeopleAlt,
  AccessTime,
  Warning,
  MonetizationOn,
  CreditCard,
} from "@mui/icons-material"

interface Reporte {
  id: string
  nombre: string
  descripcion: string
  icono: React.ReactNode
  parametros?: string[]
}

const reportesDisponibles: Reporte[] = [
  {
    id: "clientes-nuevos",
    nombre: "Reporte de Registros de Clientes Nuevos",
    descripcion:
      "Detalla la cantidad de personas jurídicas y naturales que se han registrado en un período dado (Mensual/Trimestral).",
    icono: <PeopleAlt />,
    parametros: ["año", "modalidad_cliente"],
  },
  {
    id: "horas-laboradas",
    nombre: "Horas Laboradas por Empleado",
    descripcion:
      "Consolida las horas de entrada y salida de cada empleado para calcular sus horas trabajadas en un período de tiempo.",
    icono: <AccessTime />,
    parametros: ["año", "modalidad_horas"],
  },
  {
    id: "inventario-critico",
    nombre: "Productos en Nivel Crítico de Inventario",
    descripcion:
      "Lista todos los productos que han alcanzado el umbral de cien (100) unidades disponibles.",
    icono: <Warning />,
  },
  {
    id: "rentabilidad-cerveza",
    nombre: "Rentabilidad por Tipo de Cerveza",
    descripcion: "Ganancias generadas por cada tipo de cerveza (Lager, Ale, Trigo, Belga, etc.).",
    icono: <MonetizationOn />,
  },
  {
    id: "metodos-pago-online",
    nombre: "Análisis de Métodos de Pago Online",
    descripcion:
      "Muestra la proporción de uso de cada tipo de tarjeta de crédito en las transacciones de compra a través de internet.",
    icono: <CreditCard />,
  },
]

export const Reportes: React.FC = () => {
  const [reporteSeleccionado, setReporteSeleccionado] = useState<Reporte | null>(null)
  const [parametros, setParametros] = useState<{ [key: string]: string }>({})
  const API_BASE = "http://localhost:3000"

  const getDownloadLink = (reporte: Reporte) => {
    if (reporte.id === "clientes-nuevos") {
      const year = parametros["año"];
      const modalidad = parametros["modalidad_cliente"];
      if (!year || !modalidad) return null;
      return `/api/reportes/periodo_tipo_cliente/pdf?year=${year}&modalidad=${modalidad}`;
    }
    if (reporte.id === "horas-laboradas") {
      const year = parametros["año"];
      const modalidad = parametros["modalidad_horas"];
      if (!year || !modalidad) return null;
      let month = "";
      let trimonth = "";
      if (modalidad === "trimestral") {
        trimonth = parametros["trimestre"] || "";
        if (!trimonth || !["1","2","3","4"].includes(trimonth)) return null;
      } else {
        month = parametros["mes"] || "";
        const mesNum = parseInt(month, 10);
        if (!month || isNaN(mesNum) || mesNum < 1 || mesNum > 12) return null;
      }
      return `/api/reportes/consolidar_horas/pdf?year=${year}&month=${month}&trimonth=${trimonth}&modalidad=${modalidad}`;
    }
    if (reporte.id === "inventario-critico") {
      return "/api/reportes/productos_reposicion/pdf";
    }
    if (reporte.id === "rentabilidad-cerveza") {
      return "/api/reportes/rentabilidad_por_tipo/pdf";
    }
    if (reporte.id === "metodos-pago-online") {
      return "/api/reportes/proporcion_tarjetas/pdf";
    }
    return null;
  };

  const isDownloadEnabled = (reporte: Reporte) => {
    if (reporte.id === "clientes-nuevos") {
      return Boolean(parametros["año"] && parametros["modalidad_cliente"]);
    }
    if (reporte.id === "horas-laboradas") {
      const year = parametros["año"];
      const modalidad = parametros["modalidad_horas"];
      if (!year || !modalidad) return false;
      if (modalidad === "trimestral") {
        const trimonth = parametros["trimestre"];
        return Boolean(trimonth && ["1","2","3","4"].includes(trimonth));
      } else {
        const mes = parametros["mes"];
        const mesNum = parseInt(mes, 10);
        return Boolean(mes && !isNaN(mesNum) && mesNum >= 1 && mesNum <= 12);
      }
    }
    // Los otros reportes no requieren parámetros
    return true;
  };

  const descargarPDF = async (url: string, filename: string) => {
    try {
      const response = await fetch(url);
      if (!response.ok) {
        alert("Error al generar el PDF");
        return;
      }
      const blob = await response.blob();
      const blobUrl = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = blobUrl;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(blobUrl);
    } catch (error) {
      alert("Error al descargar el PDF");
    }
  };

  const getFileName = (reporte: Reporte) => {
    switch (reporte.id) {
      case "clientes-nuevos":
        return "registro_clientes.pdf";
      case "horas-laboradas":
        return "horas_laboradas.pdf";
      case "inventario-critico":
        return "productos_criticos.pdf";
      case "rentabilidad-cerveza":
        return "rentabilidad_cerveza.pdf";
      case "metodos-pago-online":
        return "proporcion_tarjetas.pdf";
      default:
        return "reporte.pdf";
    }
  };

  const handleDescargarReporte = async (reporte: Reporte) => {
    const link = getDownloadLink(reporte);
    if (!link) return;
    const filename = getFileName(reporte);
    console.log('Descargando reporte desde:', API_BASE + link);
    await descargarPDF(API_BASE + link, filename);
  };

  const handleParametroChange = (parametro: string, valor: string) => {
    setParametros((prev) => ({
      ...prev,
      [parametro]: valor,
    }))
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Centro de Reportes
      </Typography>

      <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
        Genere y descargue reportes del sistema en formato PDF
      </Typography>

      <Grid container spacing={3}>
        {/* Lista de Reportes */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Grid container spacing={2}>
            {reportesDisponibles.map((reporte) => (
              <Grid size={{ xs: 12, sm: 6 }} key={reporte.id}>
                <Card
                  sx={{
                    cursor: "pointer",
                    "&:hover": { boxShadow: 4 },
                    border: reporteSeleccionado?.id === reporte.id ? "2px solid #2E7D32" : "1px solid #e0e0e0",
                  }}
                  onClick={() => setReporteSeleccionado(reporte)}
                >
                  <CardContent>
                    <Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
                      <Box sx={{ color: "#2E7D32", mr: 2 }}>{reporte.icono}</Box>
                      <Typography variant="h6">{reporte.nombre}</Typography>
                    </Box>
                    <Typography variant="body2" color="text.secondary">
                      {reporte.descripcion}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Grid>

        {/* Panel de Parámetros */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2, position: "sticky", top: 20 }}>
            <Typography variant="h6" gutterBottom>
              Configuración del Reporte
            </Typography>

            {reporteSeleccionado ? (
              <Box>
                <Typography variant="subtitle2" gutterBottom>
                  {reporteSeleccionado.nombre}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  {reporteSeleccionado.descripcion}
                </Typography>

                <Divider sx={{ mb: 2 }} />

                {/* Parámetros del Reporte */}
                {reporteSeleccionado.id === "horas-laboradas" ? (
                  <Box sx={{ mb: 3 }}>
                    <Typography variant="subtitle2" gutterBottom>
                      Parámetros:
                    </Typography>
                    <TextField
                      fullWidth
                      label="Año"
                      type="number"
                      placeholder="Ej. 2024"
                      value={parametros["año"] || ""}
                      onChange={(e) => handleParametroChange("año", e.target.value)}
                      InputLabelProps={{ shrink: true }}
                      sx={{ mb: 2 }}
                    />
                    <FormControl fullWidth sx={{ mb: 2 }}>
                      <InputLabel>Modalidad</InputLabel>
                      <Select
                        value={parametros["modalidad_horas"] || "diario"}
                        onChange={(e) => handleParametroChange("modalidad_horas", e.target.value)}
                        label="Modalidad"
                      >
                        <MenuItem value="diaria">Diaria</MenuItem>
                        <MenuItem value="diario">Diario</MenuItem>
                        <MenuItem value="semanal">Semanal</MenuItem>
                        <MenuItem value="mensual">Mensual</MenuItem>
                        <MenuItem value="semestral">Semestral</MenuItem>
                        <MenuItem value="anual">Anual</MenuItem>
                        <MenuItem value="trimestral">Trimestral</MenuItem>
                      </Select>
                    </FormControl>
                    {parametros["modalidad_horas"] === "trimestral" ? (
                      <FormControl fullWidth sx={{ mb: 2 }}>
                        <InputLabel>Trimestre</InputLabel>
                        <Select
                          value={parametros["trimestre"] || "1"}
                          onChange={(e) => handleParametroChange("trimestre", e.target.value)}
                          label="Trimestre"
                        >
                          <MenuItem value="1">1</MenuItem>
                          <MenuItem value="2">2</MenuItem>
                          <MenuItem value="3">3</MenuItem>
                          <MenuItem value="4">4</MenuItem>
                        </Select>
                      </FormControl>
                    ) : parametros["modalidad_horas"] ? (
                      <TextField
                        fullWidth
                        label="Mes"
                        type="number"
                        placeholder="Ej. 7"
                        value={parametros["mes"] || ""}
                        onChange={(e) => handleParametroChange("mes", e.target.value)}
                        InputLabelProps={{ shrink: true }}
                        sx={{ mb: 2 }}
                      />
                    ) : null}
                  </Box>
                ) : (
                  reporteSeleccionado.parametros && reporteSeleccionado.parametros.length > 0 && (
                    <Box sx={{ mb: 3 }}>
                      <Typography variant="subtitle2" gutterBottom>
                        Parámetros:
                      </Typography>
                      {reporteSeleccionado.parametros.map((parametro) => {
                        if (parametro === "año") {
                          return (
                            <TextField
                              key={parametro}
                              fullWidth
                              label="Año"
                              type="number"
                              placeholder="Ej. 2024"
                              value={parametros[parametro] || ""}
                              onChange={(e) => handleParametroChange(parametro, e.target.value)}
                              InputLabelProps={{ shrink: true }}
                              sx={{ mb: 2 }}
                            />
                          )
                        }
                        if (parametro === "modalidad_horas") {
                          return (
                            <FormControl key={parametro} fullWidth sx={{ mb: 2 }}>
                              <InputLabel>Modalidad</InputLabel>
                              <Select
                                value={parametros[parametro] || "diario"}
                                onChange={(e) => handleParametroChange(parametro, e.target.value)}
                                label="Modalidad"
                              >
                                <MenuItem value="diaria">Diaria</MenuItem>
                                <MenuItem value="diario">Diario</MenuItem>
                                <MenuItem value="semanal">Semanal</MenuItem>
                                <MenuItem value="mensual">Mensual</MenuItem>
                                <MenuItem value="semestral">Semestral</MenuItem>
                                <MenuItem value="anual">Anual</MenuItem>
                                <MenuItem value="trimestral">Trimestral</MenuItem>
                              </Select>
                            </FormControl>
                          )
                        }
                        if (parametro === "trimestre" && parametros["modalidad_horas"] === "trimestral") {
                          return (
                            <FormControl key={parametro} fullWidth sx={{ mb: 2 }}>
                              <InputLabel>Trimestre</InputLabel>
                              <Select
                                value={parametros["trimestre"] || "1"}
                                onChange={(e) => handleParametroChange("trimestre", e.target.value)}
                                label="Trimestre"
                              >
                                <MenuItem value="1">1</MenuItem>
                                <MenuItem value="2">2</MenuItem>
                                <MenuItem value="3">3</MenuItem>
                                <MenuItem value="4">4</MenuItem>
                              </Select>
                            </FormControl>
                          )
                        }
                        if (parametro === "mes" && parametros["modalidad_horas"] !== "trimestral") {
                          return (
                            <TextField
                              key={parametro}
                              fullWidth
                              label="Mes"
                              type="number"
                              placeholder="Ej. 7"
                              value={parametros[parametro] || ""}
                              onChange={(e) => handleParametroChange(parametro, e.target.value)}
                              InputLabelProps={{ shrink: true }}
                              sx={{ mb: 2 }}
                            />
                          )
                        }
                        if (parametro === "modalidad_cliente") {
                          return (
                            <FormControl key={parametro} fullWidth sx={{ mb: 2 }}>
                              <InputLabel>Modalidad</InputLabel>
                              <Select
                                value={parametros[parametro] || "mensual"}
                                onChange={(e) => handleParametroChange(parametro, e.target.value)}
                                label="Modalidad"
                              >
                                <MenuItem value="mensual">Mensual</MenuItem>
                                <MenuItem value="trimestral">Trimestral</MenuItem>
                              </Select>
                            </FormControl>
                          )
                        }
                        return null
                      })}
                    </Box>
                  )
                )}

                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  startIcon={<Download />}
                  onClick={() => handleDescargarReporte(reporteSeleccionado)}
                  disabled={!isDownloadEnabled(reporteSeleccionado)}
                  sx={{
                    backgroundColor: isDownloadEnabled(reporteSeleccionado) ? "#2E7D32" : "#A5D6A7",
                    "&:hover": { backgroundColor: isDownloadEnabled(reporteSeleccionado) ? "#1B5E20" : "#A5D6A7" },
                  }}
                >
                  Descargar Reporte PDF
                </Button>
              </Box>
            ) : (
              <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 4 }}>
                Seleccione un reporte para configurar sus parámetros
              </Typography>
            )}
          </Paper>
        </Grid>
      </Grid>
    </Box>
  )
}
