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
import { Download, Assessment, TrendingUp, PieChart, BarChart } from "@mui/icons-material"

interface Reporte {
  id: string
  nombre: string
  descripcion: string
  icono: React.ReactNode
  parametros?: string[]
}

const reportesDisponibles: Reporte[] = [
  {
    id: "ventas-diarias",
    nombre: "Reporte de Ventas Diarias",
    descripcion: "Resumen de ventas por día con detalles de productos y métodos de pago",
    icono: <TrendingUp />,
    parametros: ["fecha_inicio", "fecha_fin"],
  },
  {
    id: "inventario-actual",
    nombre: "Estado Actual del Inventario",
    descripcion: "Listado completo del inventario con stock actual y alertas",
    icono: <Assessment />,
  },
  {
    id: "productos-mas-vendidos",
    nombre: "Productos Más Vendidos",
    descripcion: "Ranking de productos por cantidad vendida en un período",
    icono: <BarChart />,
    parametros: ["fecha_inicio", "fecha_fin", "limite"],
  },
  {
    id: "clientes-frecuentes",
    nombre: "Clientes Más Frecuentes",
    descripcion: "Listado de clientes con mayor frecuencia de compra",
    icono: <PieChart />,
    parametros: ["fecha_inicio", "fecha_fin"],
  },
]

export const Reportes: React.FC = () => {
  const [reporteSeleccionado, setReporteSeleccionado] = useState<Reporte | null>(null)
  const [parametros, setParametros] = useState<{ [key: string]: string }>({})

  const handleDescargarReporte = (reporte: Reporte) => {
    console.log("Descargando reporte:", reporte.id, "con parámetros:", parametros)

    // Simular descarga
    const link = document.createElement("a")
    link.href = "#" // Aquí iría la URL del reporte generado
    link.download = `${reporte.id}-${new Date().toISOString().split("T")[0]}.pdf`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    alert(`Reporte "${reporte.nombre}" descargado exitosamente`)
  }

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
        <Grid item xs={12} md={8}>
          <Grid container spacing={2}>
            {reportesDisponibles.map((reporte) => (
              <Grid item xs={12} sm={6} key={reporte.id}>
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
        <Grid item xs={12} md={4}>
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
                {reporteSeleccionado.parametros && reporteSeleccionado.parametros.length > 0 && (
                  <Box sx={{ mb: 3 }}>
                    <Typography variant="subtitle2" gutterBottom>
                      Parámetros:
                    </Typography>

                    {reporteSeleccionado.parametros.map((parametro) => {
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
                        )
                      }

                      if (parametro === "limite") {
                        return (
                          <FormControl key={parametro} fullWidth sx={{ mb: 2 }}>
                            <InputLabel>Límite de Resultados</InputLabel>
                            <Select
                              value={parametros[parametro] || "10"}
                              onChange={(e) => handleParametroChange(parametro, e.target.value)}
                              label="Límite de Resultados"
                            >
                              <MenuItem value="10">10</MenuItem>
                              <MenuItem value="25">25</MenuItem>
                              <MenuItem value="50">50</MenuItem>
                              <MenuItem value="100">100</MenuItem>
                            </Select>
                          </FormControl>
                        )
                      }

                      return (
                        <TextField
                          key={parametro}
                          fullWidth
                          label={parametro}
                          value={parametros[parametro] || ""}
                          onChange={(e) => handleParametroChange(parametro, e.target.value)}
                          sx={{ mb: 2 }}
                        />
                      )
                    })}
                  </Box>
                )}

                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  startIcon={<Download />}
                  onClick={() => handleDescargarReporte(reporteSeleccionado)}
                  sx={{
                    backgroundColor: "#2E7D32",
                    "&:hover": { backgroundColor: "#1B5E20" },
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
