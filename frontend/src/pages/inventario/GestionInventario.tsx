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
} from "@mui/material"
import { Search, Edit, Delete, ShoppingCart, Refresh, CheckCircle, Warning } from "@mui/icons-material"

// Interfaz para la estructura de datos que esperamos de la API
export interface InventarioCompleto {
  id_inventario: number;
  nombre_producto: string;
  nombre_presentacion: string;
  stock_actual: number;
  precio_usd: number;
  lugar_tienda: string;
  miembro_proveedor: string;
  estado: "Disponible" | "Bajo Stock" | "Agotado";
}

// TODO: Crear un hook e integrar con la API real
const fetchInventario = async (): Promise<InventarioCompleto[]> => {
  // Datos de ejemplo simulando la respuesta de la API
  return [
    { id_inventario: 1, nombre_producto: "IPA", nombre_presentacion: "Botella 330ml", stock_actual: 100, precio_usd: 5.50, lugar_tienda: "Estante A1", miembro_proveedor: "Cervecería Tovar", estado: "Disponible" },
    { id_inventario: 2, nombre_producto: "Stout", nombre_presentacion: "Lata 473ml", stock_actual: 15, precio_usd: 6.00, lugar_tienda: "Nevera Principal", miembro_proveedor: "Cervecería Destilo", estado: "Bajo Stock" },
    { id_inventario: 3, nombre_producto: "Lager", nombre_presentacion: "Barril 5L", stock_actual: 0, precio_usd: 45.00, lugar_tienda: "Almacén Frío", miembro_proveedor: "Cervecería Regional", estado: "Agotado" },
  ];
};

const updateStock = async (id_inventario: number, nuevo_stock: number) => {
    console.log(`Enviando al backend - Actualizar stock para ${id_inventario} a ${nuevo_stock}`);
    // Aquí iría la llamada real a la API, ej: api.put(`/inventario/${id_inventario}`, { stock: nuevo_stock })
    return { success: true };
}

const deleteInventarioItem = async (id_inventario: number) => {
    console.log(`Enviando al backend - Eliminar item de inventario ${id_inventario}`);
    // Aquí iría la llamada real a la API, ej: api.delete(`/inventario/${id_inventario}`)
    return { success: true };
}

const orderRestock = async (id_inventario: number, cantidad: number) => {
    console.log(`Enviando al backend - Orden de reposición para item ${id_inventario}, cantidad: ${cantidad}`);
    return { success: true };
}

export const GestionInventario: React.FC = () => {
  const [inventario, setInventario] = useState<InventarioCompleto[]>([]);
  const [loading, setLoading] = useState(true);
  const [busqueda, setBusqueda] = useState("");
  const [filtroEstado, setFiltroEstado] = useState<string>("");
  
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [restockModalOpen, setRestockModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<InventarioCompleto | null>(null);
  const [editedStock, setEditedStock] = useState("");
  const [cantidadRestock, setCantidadRestock] = useState("");

  const cargarInventario = async () => {
    setLoading(true);
    const data = await fetchInventario();
    setInventario(data);
    setLoading(false);
  };

  useEffect(() => {
    cargarInventario();
  }, []);

  const inventarioFiltrado = inventario.filter((item) => {
    const cumpleBusqueda = item.nombre_producto.toLowerCase().includes(busqueda.toLowerCase()) ||
      item.nombre_presentacion.toLowerCase().includes(busqueda.toLowerCase());
    
    const cumpleEstado = filtroEstado === "" || item.estado === filtroEstado;
    
    return cumpleBusqueda && cumpleEstado;
  });

  // --- MANEJO DE MODALES Y ACCIONES ---
  const handleOpenEditModal = (item: InventarioCompleto) => {
    setSelectedItem(item);
    setEditedStock(item.stock_actual.toString());
    setEditModalOpen(true);
  };
  
  const handleOpenRestockModal = (item: InventarioCompleto) => {
    setSelectedItem(item);
    setCantidadRestock("");
    setRestockModalOpen(true);
  }

  const handleSaveStock = async () => {
    if (!selectedItem || editedStock === "") return;
    const nuevoStockNum = parseInt(editedStock, 10);
    if (!isNaN(nuevoStockNum)) {
        await updateStock(selectedItem.id_inventario, nuevoStockNum);
        setEditModalOpen(false);
        await cargarInventario();
    }
  };

  const handleConfirmRestock = async () => {
    if (!selectedItem || cantidadRestock === "") return;
    const cantidadNum = parseInt(cantidadRestock, 10);
    if (!isNaN(cantidadNum) && cantidadNum > 0) {
        await orderRestock(selectedItem.id_inventario, cantidadNum);
        setRestockModalOpen(false);
        alert(`Solicitud de reposición para ${cantidadNum} unidades de ${selectedItem.nombre_producto} enviada.`);
    }
  }

  const handleDelete = async (id: number) => {
    if (window.confirm("¿Está seguro de que desea eliminar este registro del inventario?")) {
        await deleteInventarioItem(id);
        await cargarInventario();
    }
  }
  
  const handleOrderRestock = (item: InventarioCompleto) => {
    alert(`Se ha iniciado una orden de reposición para: ${item.nombre_producto} - ${item.nombre_presentacion}`);
    // Aquí se implementaría la lógica para la orden de reposición
  }

  // --- HELPERS DE UI ---
  const getEstadoChip = (estado: InventarioCompleto['estado']) => {
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
            {inventarioFiltrado.map((item) => (
              <TableRow key={item.id_inventario}>
                <TableCell sx={{ fontWeight: 'bold' }}>{item.nombre_producto}</TableCell>
                <TableCell>{item.nombre_presentacion}</TableCell>
                <TableCell>{item.miembro_proveedor}</TableCell>
                <TableCell align="center">{item.stock_actual}</TableCell>
                <TableCell align="right">{item.precio_usd.toFixed(2)}</TableCell>
                <TableCell>{item.lugar_tienda}</TableCell>
                <TableCell align="center">{getEstadoChip(item.estado)}</TableCell>
                <TableCell align="center">
                  <Stack direction="row" spacing={1} justifyContent="center">
                    <Tooltip title="Editar Stock">
                      <IconButton size="small" onClick={() => handleOpenEditModal(item)}><Edit /></IconButton>
                    </Tooltip>
                    <Tooltip title="Ordenar Reposición">
                      <IconButton size="small" color="primary" onClick={() => handleOpenRestockModal(item)}><ShoppingCart /></IconButton>
                    </Tooltip>
                    <Tooltip title="Eliminar Registro">
                      <IconButton size="small" color="error" onClick={() => handleDelete(item.id_inventario)}><Delete /></IconButton>
                    </Tooltip>
                  </Stack>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Modal de Edición de Stock */}
      <Dialog open={editModalOpen} onClose={() => setEditModalOpen(false)}>
        <DialogTitle>Editar Stock</DialogTitle>
        <DialogContent sx={{ pt: '20px !important' }}>
          <Typography variant="h6">{selectedItem?.nombre_producto} - {selectedItem?.nombre_presentacion}</Typography>
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
      <Dialog open={restockModalOpen} onClose={() => setRestockModalOpen(false)}>
        <DialogTitle>Ordenar Reposición</DialogTitle>
        <DialogContent sx={{ pt: '20px !important' }}>
          <Typography variant="h6">{selectedItem?.nombre_producto} - {selectedItem?.nombre_presentacion}</Typography>
          <Typography variant="body2" color="text.secondary">Stock actual: {selectedItem?.stock_actual}</Typography>
          <TextField autoFocus margin="dense" label="Cantidad a solicitar" type="number" fullWidth value={cantidadRestock} onChange={(e) => setCantidadRestock(e.target.value)} sx={{ mt: 2 }} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRestockModalOpen(false)}>Cancelar</Button>
          <Button onClick={handleConfirmRestock} variant="contained" disabled={!cantidadRestock}>Solicitar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
