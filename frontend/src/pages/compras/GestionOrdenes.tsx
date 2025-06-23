"use client"

import type React from "react"
import { useState, useEffect } from "react"
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
  Tooltip,
  Stack,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Pagination,
} from "@mui/material"
import { Search, Refresh, CheckCircle, Pending, Cancel } from "@mui/icons-material"
import { getCompras, setCompraPagada } from '../../services/api';

// Interfaces - Se deberian mover a su propio archivo en /interfaces
interface OrdenCompra {
  id: number
  producto: string
  fecha: string
  cantidad: number
  precioTotal: number
  miembro: string
  estatus: "Por aprobar" | "Compra Pagada" | "Cancelada"
}

// Datos de ejemplo
const ordenesDeEjemplo: OrdenCompra[] = [
  { id: 1, producto: "Cerveza IPA", fecha: "2024-05-20", cantidad: 100, precioTotal: 150.0, miembro: "Proveedor A", estatus: "Por aprobar" },
  { id: 2, producto: "Cerveza Stout", fecha: "2024-05-19", cantidad: 200, precioTotal: 200.5, miembro: "Proveedor B", estatus: "Compra Pagada" },
  { id: 3, producto: "Cerveza Lager", fecha: "2024-05-18", cantidad: 50, precioTotal: 120.75, miembro: "Proveedor A", estatus: "Por aprobar" },
  { id: 4, producto: "Cerveza Amber Ale", fecha: "2024-05-17", cantidad: 80, precioTotal: 180.0, miembro: "Proveedor C", estatus: "Cancelada" },
]

export const GestionOrdenes: React.FC = () => {
  const [ordenes, setOrdenes] = useState<OrdenCompra[]>([]);
  const [loading, setLoading] = useState(true);
  const [busqueda, setBusqueda] = useState("");
  const [filtroEstatus, setFiltroEstatus] = useState<string>("");

  const [confirmModalOpen, setConfirmModalOpen] = useState(false);
  const [selectedOrden, setSelectedOrden] = useState<OrdenCompra | null>(null);

  const TAM_PAGINA = 10;
  const [paginaActual, setPaginaActual] = useState(1);

  const cargarOrdenes = async () => {
    setLoading(true);
    // Obtener datos reales de la API
    const compras = await getCompras();
    // Mapear los datos a la estructura de la tabla
    const ordenes = compras.map((c: any, idx: number) => ({
      id: idx + 1,
      producto: c.nombre_cerv,
      fecha: c.fecha_comp,
      cantidad: c.cant_deta_comp,
      precioTotal: parseFloat(c.total_comp),
      miembro: c.denom_comercial_miem,
      estatus: c.nombre_estatus as 'Por aprobar' | 'Compra Pagada',
    }));
    setOrdenes(ordenes);
    setLoading(false);
  };

  useEffect(() => {
    cargarOrdenes();
  }, []);

  useEffect(() => {
    setPaginaActual(1);
  }, [busqueda, filtroEstatus]);

  const ordenesFiltradas = ordenes.filter((orden) => {
    const cumpleBusqueda =
      orden.producto.toLowerCase().includes(busqueda.toLowerCase()) ||
      orden.miembro.toLowerCase().includes(busqueda.toLowerCase());
    const cumpleEstatus = filtroEstatus === "" || orden.estatus === filtroEstatus;
    return cumpleBusqueda && cumpleEstatus;
  });

  const totalPaginas = Math.ceil(ordenesFiltradas.length / TAM_PAGINA);
  const ordenesPagina = ordenesFiltradas.slice(
    (paginaActual - 1) * TAM_PAGINA,
    paginaActual * TAM_PAGINA
  );

  const handleOpenConfirmModal = (orden: OrdenCompra) => {
    setSelectedOrden(orden);
    setConfirmModalOpen(true);
  };

  const handleMarcarComoPagada = async () => {
    if (!selectedOrden) return;
    const ok = await setCompraPagada(selectedOrden.id);
    if (ok) {
      setOrdenes(prev => prev.map(o => o.id === selectedOrden.id ? { ...o, estatus: 'Compra Pagada' as const } : o));
    }
    setConfirmModalOpen(false);
  };
  
  const getEstatusChip = (estatus: OrdenCompra['estatus']) => {
    const color = estatus === "Compra Pagada" ? "success" : estatus === "Por aprobar" ? "warning" : "error";
    const icon = estatus === "Compra Pagada" ? <CheckCircle /> : estatus === "Por aprobar" ? <Pending /> : <Cancel />;
    return <Chip icon={icon} label={estatus} color={color} size="small" />;
  };

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" gutterBottom>Gestión de Órdenes de Compra</Typography>
        <Button variant="outlined" startIcon={<Refresh />} onClick={cargarOrdenes}>Actualizar</Button>
      </Box>

      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid size={{ xs: 12, md: 8 }}>
            <TextField fullWidth placeholder="Buscar por producto o miembro..." value={busqueda} onChange={(e) => setBusqueda(e.target.value)}
              InputProps={{ startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} /> }}
            />
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <FormControl fullWidth>
              <InputLabel>Filtrar por Estatus</InputLabel>
              <Select
                value={filtroEstatus}
                onChange={(e) => setFiltroEstatus(e.target.value)}
                label="Filtrar por Estatus"
              >
                <MenuItem value="">Todos los estatus</MenuItem>
                <MenuItem value="Por aprobar">Por aprobar</MenuItem>
                <MenuItem value="Compra Pagada">Compra Pagada</MenuItem>
              </Select>
            </FormControl>
          </Grid>
        </Grid>
      </Paper>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Producto</TableCell>
              <TableCell>Fecha</TableCell>
              <TableCell align="right">Cantidad</TableCell>
              <TableCell align="right">Precio Total ($)</TableCell>
              <TableCell>Miembro</TableCell>
              <TableCell align="center">Estatus</TableCell>
              <TableCell align="center">Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading ? (
                <TableRow>
                    <TableCell colSpan={7} align="center">Cargando...</TableCell>
                </TableRow>
            ) : ordenesPagina.map((orden) => (
              <TableRow key={orden.id}>
                <TableCell sx={{ fontWeight: 'bold' }}>{orden.producto}</TableCell>
                <TableCell>{new Date(orden.fecha).toLocaleDateString()}</TableCell>
                <TableCell align="right">{orden.cantidad}</TableCell>
                <TableCell align="right">{orden.precioTotal.toFixed(2)}</TableCell>
                <TableCell>{orden.miembro}</TableCell>
                <TableCell align="center">{getEstatusChip(orden.estatus)}</TableCell>
                <TableCell align="center">
                  {orden.estatus === 'Por aprobar' && (
                    <Tooltip title="Marcar como Pagada">
                      <Button variant="contained" size="small" onClick={() => handleOpenConfirmModal(orden)}>
                        Marcar Pagada
                      </Button>
                    </Tooltip>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {totalPaginas > 1 && (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
          <Pagination count={totalPaginas} page={paginaActual} onChange={(_, p) => setPaginaActual(p)} color="primary" />
        </Box>
      )}

      {/* Modal de Confirmación */}
      <Dialog open={confirmModalOpen} onClose={() => setConfirmModalOpen(false)}>
        <DialogTitle>Confirmar Acción</DialogTitle>
        <DialogContent>
          <Typography>¿Está seguro de que desea marcar esta orden como <b>Compra Pagada</b>?</Typography>
          <Typography variant="caption" color="text.secondary" display="block" mt={1}>
            Esta acción no se puede deshacer.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setConfirmModalOpen(false)}>Cancelar</Button>
          <Button onClick={handleMarcarComoPagada} color="primary" variant="contained">Confirmar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
} 