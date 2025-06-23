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
    parametros: ["año", "mes", "modalidad_horas"],
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

  const handleDescargarReporte = (reporte: Reporte) => {
    // Aquí iría la lógica para generar y descargar el reporte
    alert(`Descargando: ${reporte.nombre} con parámetros ${JSON.stringify(parametros)}`)
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
                {reporteSeleccionado.parametros && reporteSeleccionado.parametros.length > 0 && (
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
                      if (parametro === "mes") {
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

                      if (parametro === "modalidad_horas") {
                        return (
                          <FormControl key={parametro} fullWidth sx={{ mb: 2 }}>
                            <InputLabel>Modalidad</InputLabel>
                            <Select
                              value={parametros[parametro] || "diaria"}
                              onChange={(e) => handleParametroChange(parametro, e.target.value)}
                              label="Modalidad"
                            >
                              <MenuItem value="diaria">Diaria</MenuItem>
                              <MenuItem value="semanal">Semanal</MenuItem>
                              <MenuItem value="mensual">Mensual</MenuItem>
                              <MenuItem value="semestral">Semestral</MenuItem>
                              <MenuItem value="anual">Anual</MenuItem>
                            </Select>
                          </FormControl>
                        )
                      }

                      return null
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
