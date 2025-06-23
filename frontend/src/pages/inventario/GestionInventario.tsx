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
import { Search, Edit, Delete, ShoppingCart, Refresh, CheckCircle, Warning } from "@mui/icons-material"
import { getProductosInventario, updateInventarioItem } from "../../services/api";
import type { ProductoInventario } from "../../interfaces/ventas";

const updateStock = async (id_inventario: number, nuevo_stock: number) => {
    return { success: true };
}

const deleteInventarioItem = async (id_inventario: number) => {
    return { success: true };
}

const orderRestock = async (id_inventario: number, cantidad: number) => {
    return { success: true };
}

export const GestionInventario: React.FC = () => {
  const [inventario, setInventario] = useState<ProductoInventario[]>([]);
  const [loading, setLoading] = useState(true);
  const [busqueda, setBusqueda] = useState("");
  const [filtroEstado, setFiltroEstado] = useState<string>("");
  
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [restockModalOpen, setRestockModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<ProductoInventario | null>(null);
  const [editedStock, setEditedStock] = useState("");
  const [cantidadRestock, setCantidadRestock] = useState("");

  const TAM_PAGINA = 25;
  const [paginaActual, setPaginaActual] = useState(1);

  const cargarInventario = async () => {
    setLoading(true);
    const data = await getProductosInventario();
    // Mapeo de campos para que coincidan con ProductoInventario
    const inventarioMapeado = (data as any[]).map((item, idx) => ({
      ...item,
      nombre_cerv: item.nombre_producto,
      nombre_pres: item.nombre_presentacion,
      cant_pres: Number(item.stock_actual),
      precio_actual_pres: Number(item.precio_usd),
      _key: `${item.nombre_producto}-${item.nombre_presentacion}-${item.lugar_tienda}-${idx}`
    })) as any[];
    setInventario(inventarioMapeado as any);
    setLoading(false);
  };

  useEffect(() => {
    cargarInventario();
  }, []);

  // Resetear página cuando cambian filtros o búsqueda
  useEffect(() => {
    setPaginaActual(1);
  }, [busqueda, filtroEstado]);

  const inventarioFiltrado = inventario.filter((item) => {
    const cumpleBusqueda =
      (item.nombre_cerv?.toLowerCase() ?? "").includes(busqueda.toLowerCase()) ||
      (item.nombre_pres?.toLowerCase() ?? "").includes(busqueda.toLowerCase());
    const cumpleEstado = filtroEstado === "" || item.estado === filtroEstado;
    return cumpleBusqueda && cumpleEstado;
  });

  const totalPaginas = Math.ceil(inventarioFiltrado.length / TAM_PAGINA);
  const productosPagina = inventarioFiltrado.slice(
    (paginaActual - 1) * TAM_PAGINA,
    paginaActual * TAM_PAGINA
  );

  // --- MANEJO DE MODALES Y ACCIONES ---
  const handleOpenEditModal = (item: ProductoInventario) => {
    setSelectedItem(item);
    setEditedStock(item.cant_pres.toString());
    setEditModalOpen(true);
  };
  
  const handleOpenRestockModal = (item: ProductoInventario) => {
    setSelectedItem(item);
    setCantidadRestock("");
    setRestockModalOpen(true);
  }

  const handleSaveStock = async () => {
    if (!selectedItem || editedStock === "") return;
    const nuevoStockNum = parseInt(editedStock, 10);
    if (!isNaN(nuevoStockNum)) {
      await updateInventarioItem({
        fk_cerv_pres_1: selectedItem.fk_cerv_pres_1,
        fk_cerv_pres_2: selectedItem.fk_cerv_pres_2,
        fk_tien: 1,
        fk_luga_tien: selectedItem.fk_luga_tien,
        cant_pres: nuevoStockNum,
      });
      setEditModalOpen(false);
      await cargarInventario();
    }
  };

  const handleConfirmRestock = async () => {
    if (!selectedItem || cantidadRestock === "") return;
    const cantidadNum = parseInt(cantidadRestock, 10);
    if (!isNaN(cantidadNum) && cantidadNum > 0) {
        await orderRestock(selectedItem.fk_cerv_pres_1, cantidadNum);
        setRestockModalOpen(false);
        alert(`Solicitud de reposición para ${cantidadNum} unidades de ${selectedItem.nombre_cerv} - ${selectedItem.nombre_pres} enviada.`);
    }
  }

  const handleDelete = async (id: number) => {
    if (window.confirm("¿Está seguro de que desea eliminar este registro del inventario?")) {
        await deleteInventarioItem(id);
        await cargarInventario();
    }
  }
  
  const handleOrderRestock = (item: ProductoInventario) => {
    alert(`Se ha iniciado una orden de reposición para: ${item.nombre_cerv} - ${item.nombre_pres}`);
    // Aquí se implementaría la lógica para la orden de reposición
  }

  // --- HELPERS DE UI ---
  const getEstadoChip = (estado: ProductoInventario['estado']) => {
    const color = estado === "Disponible" ? "success" : estado === "Bajo Stock" ? "warning" : "error";
    const icon = estado === "Disponible" ? <CheckCircle /> : <Warning />;
    return <Chip icon={icon} label={estado} color={color} size="small" />;
  };

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" gutterBottom>Gestión de Inventario</Typography>
        <Button variant="outlined" startIcon={<Refresh />} onClick={cargarInventario}>Actualizar</Button>
      </Box>

      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid size={{ xs: 12, md: 8 }}>
            <TextField fullWidth placeholder="Buscar por producto o presentación..." value={busqueda} onChange={(e) => setBusqueda(e.target.value)}
              InputProps={{ startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} /> }}
            />
          </Grid>
          <Grid size={{ xs: 12, md: 4 }}>
            <FormControl fullWidth>
              <InputLabel>Filtrar por Estado</InputLabel>
              <Select
                value={filtroEstado}
                onChange={(e) => setFiltroEstado(e.target.value)}
                label="Filtrar por Estado"
              >
                <MenuItem value="">Todos los estados</MenuItem>
                <MenuItem value="Disponible">Disponible</MenuItem>
                <MenuItem value="Bajo Stock">Bajo Stock</MenuItem>
                <MenuItem value="Agotado">Agotado</MenuItem>
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
              <TableCell>Presentación</TableCell>
              <TableCell>Miembro Proveedor</TableCell>
              <TableCell align="center">Stock</TableCell>
              <TableCell align="right">Precio ($)</TableCell>
              <TableCell>Lugar Tienda</TableCell>
              <TableCell align="center">Estado</TableCell>
              <TableCell align="center">Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {productosPagina.map((item: any) => (
              <TableRow key={item._key}>
                <TableCell sx={{ fontWeight: 'bold' }}>{item.nombre_cerv}</TableCell>
                <TableCell>{item.nombre_pres}</TableCell>
                <TableCell>{item.miembro_proveedor}</TableCell>
                <TableCell align="center">{item.cant_pres}</TableCell>
                <TableCell align="right">
                  {typeof item.precio_actual_pres === "number"
                    ? item.precio_actual_pres.toFixed(2)
                    : "N/A"}
                </TableCell>
                <TableCell>{item.lugar_tienda}</TableCell>
                <TableCell align="center">{getEstadoChip(item.estado)}</TableCell>
                <TableCell align="center">
                  <Stack direction="row" spacing={1} justifyContent="center">
                    <Tooltip title="Editar Stock">
                      <IconButton size="small" onClick={() => handleOpenEditModal(item)}><Edit /></IconButton>
                    </Tooltip>
                    <Tooltip title="Eliminar Registro">
                      <IconButton size="small" color="error" onClick={() => handleDelete(item.fk_cerv_pres_1)}><Delete /></IconButton>
                    </Tooltip>
                  </Stack>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Paginación debajo de la tabla */}
      <Box sx={{ display: 'flex', justifyContent: 'center', my: 2 }}>
        <Pagination
          count={totalPaginas}
          page={paginaActual}
          onChange={(_, value) => setPaginaActual(value)}
          color="primary"
          shape="rounded"
          showFirstButton
          showLastButton
        />
      </Box>

      {/* Modal de Edición de Stock */}
      <Dialog open={editModalOpen} onClose={() => setEditModalOpen(false)}>
        <DialogTitle>Editar Stock</DialogTitle>
        <DialogContent sx={{ pt: '20px !important' }}>
          <Typography variant="h6">{selectedItem?.nombre_cerv} - {selectedItem?.nombre_pres}</Typography>
          <TextField
            autoFocus margin="dense" label="Nuevo Stock" type="number" fullWidth
            value={editedStock} onChange={(e) => setEditedStock(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditModalOpen(false)}>Cancelar</Button>
          <Button onClick={handleSaveStock} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>
      
      {/* Modal de Reposición (Restock) */}
      {/* Eliminado: ya no se usa */}
    </Box>
  )
}
