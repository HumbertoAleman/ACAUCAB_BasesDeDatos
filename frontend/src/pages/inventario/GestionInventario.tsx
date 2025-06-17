"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from "@mui/material"
import { Search, Add, Edit, Warning, CheckCircle } from "@mui/icons-material"
import type { InventarioTienda } from "../../interfaces"

// Datos de ejemplo basados en las interfaces
const inventarioEjemplo: (InventarioTienda & { nombre_cerv: string; estado: string })[] = [
  {
    fk_cerv_pres_1: 1,
    fk_cerv_pres_2: 1,
    fk_tien: 1,
    fk_luga_tien: 1,
    cant_pres: 45,
    precio_actual_pres: 8.5,
    nombre_cerv: "Pale Ale Artesanal",
    estado: "Disponible",
  },
  {
    fk_cerv_pres_1: 2,
    fk_cerv_pres_2: 1,
    fk_tien: 1,
    fk_luga_tien: 2,
    cant_pres: 15,
    precio_actual_pres: 9.0,
    nombre_cerv: "IPA Tropical",
    estado: "Bajo Stock",
  },
  {
    fk_cerv_pres_1: 3,
    fk_cerv_pres_2: 1,
    fk_tien: 1,
    fk_luga_tien: 3,
    cant_pres: 0,
    precio_actual_pres: 12.0,
    nombre_cerv: "Stout Imperial",
    estado: "Agotado",
  },
]

export const GestionInventario: React.FC = () => {
  const [busqueda, setBusqueda] = useState("")
  const [filtroEstado, setFiltroEstado] = useState("")
  const [dialogRestock, setDialogRestock] = useState(false)
  const [productoSeleccionado, setProductoSeleccionado] = useState<(typeof inventarioEjemplo)[0] | null>(null)
  const [cantidadRestock, setCantidadRestock] = useState("")

  const inventarioFiltrado = inventarioEjemplo.filter((item) => {
    const matchNombre = item.nombre_cerv.toLowerCase().includes(busqueda.toLowerCase())
    const matchEstado = filtroEstado === "" || item.estado === filtroEstado
    return matchNombre && matchEstado
  })

  const handleRestock = (producto: (typeof inventarioEjemplo)[0]) => {
    setProductoSeleccionado(producto)
    setDialogRestock(true)
  }

  const confirmarRestock = () => {
    console.log("Restock:", {
      producto: productoSeleccionado,
      cantidad: cantidadRestock,
    })
    setDialogRestock(false)
    setCantidadRestock("")
    setProductoSeleccionado(null)
    alert("Solicitud de restock enviada")
  }

  const getEstadoColor = (estado: string) => {
    switch (estado) {
      case "Disponible":
        return "success"
      case "Bajo Stock":
        return "warning"
      case "Agotado":
        return "error"
      default:
        return "default"
    }
  }

  const getEstadoIcon = (estado: string) => {
    switch (estado) {
      case "Disponible":
        return <CheckCircle />
      case "Bajo Stock":
      case "Agotado":
        return <Warning />
      default:
        return null
    }
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Gestión de Inventario
      </Typography>

      {/* Filtros */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              placeholder="Buscar productos..."
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              InputProps={{
                startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} />,
              }}
            />
          </Grid>
          <Grid item xs={12} md={4}>
            <FormControl fullWidth>
              <InputLabel>Filtrar por Estado</InputLabel>
              <Select value={filtroEstado} onChange={(e) => setFiltroEstado(e.target.value)} label="Filtrar por Estado">
                <MenuItem value="">Todos</MenuItem>
                <MenuItem value="Disponible">Disponible</MenuItem>
                <MenuItem value="Bajo Stock">Bajo Stock</MenuItem>
                <MenuItem value="Agotado">Agotado</MenuItem>
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={12} md={2}>
            <Button fullWidth variant="outlined" startIcon={<Add />}>
              Nuevo Producto
            </Button>
          </Grid>
        </Grid>
      </Paper>

      {/* Tabla de Inventario */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Producto</TableCell>
              <TableCell align="center">Stock Actual</TableCell>
              <TableCell align="center">Precio</TableCell>
              <TableCell align="center">Ubicación</TableCell>
              <TableCell align="center">Estado</TableCell>
              <TableCell align="center">Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {inventarioFiltrado.map((item, index) => (
              <TableRow key={index}>
                <TableCell>
                  <Typography variant="subtitle2">{item.nombre_cerv}</Typography>
                </TableCell>
                <TableCell align="center">
                  <Typography
                    variant="body2"
                    color={item.cant_pres <= 20 ? "error" : "inherit"}
                    sx={{ fontWeight: item.cant_pres <= 20 ? "bold" : "normal" }}
                  >
                    {item.cant_pres}
                  </Typography>
                </TableCell>
                <TableCell align="center">${item.precio_actual_pres.toFixed(2)}</TableCell>
                <TableCell align="center">Ubicación {item.fk_luga_tien}</TableCell>
                <TableCell align="center">
                  <Chip
                    icon={getEstadoIcon(item.estado)}
                    label={item.estado}
                    color={getEstadoColor(item.estado) as any}
                    size="small"
                  />
                </TableCell>
                <TableCell align="center">
                  <IconButton size="small" color="primary" onClick={() => handleRestock(item)}>
                    <Add />
                  </IconButton>
                  <IconButton size="small" color="secondary">
                    <Edit />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog de Restock */}
      <Dialog open={dialogRestock} onClose={() => setDialogRestock(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Solicitar Restock</DialogTitle>
        <DialogContent>
          {productoSeleccionado && (
            <Box>
              <Typography variant="h6" gutterBottom>
                {productoSeleccionado.nombre_cerv}
              </Typography>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Stock actual: {productoSeleccionado.cant_pres} unidades
              </Typography>

              <TextField
                fullWidth
                label="Cantidad a solicitar"
                type="number"
                value={cantidadRestock}
                onChange={(e) => setCantidadRestock(e.target.value)}
                sx={{ mt: 2 }}
              />
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogRestock(false)}>Cancelar</Button>
          <Button variant="contained" onClick={confirmarRestock} disabled={!cantidadRestock}>
            Solicitar Restock
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
