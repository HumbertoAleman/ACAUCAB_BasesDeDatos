"use client"

import React, { useState, useEffect } from "react"
import {
  Box, Grid, Paper, Typography, TextField, Button, Card, CardContent, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, FormControl, InputLabel, Select, MenuItem, Chip, Divider, Alert, List, ListItem, ListItemText, ListItemSecondaryAction, Stepper, Step, StepLabel, StepContent, Pagination
} from "@mui/material"
import { Add, Remove, Delete, Payment, Search, ShoppingCart, CreditCard, Close, Receipt } from "@mui/icons-material"
import type { ProductoInventario, TasaVenta, MetodoPagoCompleto, ItemVenta, PagoVenta, ResumenVenta } from "../../interfaces/ventas"
import { getProductosInventario, getTasaActual, procesarVenta, getBancos, getTableData, getCarrito, createCarrito, addItemsToCarrito, deleteCarrito, removeItemsFromCarrito } from "../../services/api"
import { useAuth } from '../../contexts/AuthContext'

interface PuntoVentaOnlineProps {
  onClose?: () => void;
}

const PuntoVentaOnline: React.FC<PuntoVentaOnlineProps> = ({ onClose }) => {
  const [productos, setProductos] = useState<ProductoInventario[]>([])
  const [tasaActual, setTasaActual] = useState<TasaVenta | null>(null)
  const [busquedaProducto, setBusquedaProducto] = useState("")
  const [itemsVenta, setItemsVenta] = useState<ItemVenta[]>([])
  const [resumenVenta, setResumenVenta] = useState<ResumenVenta | null>(null)
  const [dialogPago, setDialogPago] = useState(false)
  const [pasoActual, setPasoActual] = useState(0)
  const [pagos, setPagos] = useState<PagoVenta[]>([])
  const [metodoPagoSeleccionado, setMetodoPagoSeleccionado] = useState<MetodoPagoCompleto | null>(null)
  const [montoPago, setMontoPago] = useState("")
  const [camposTarjeta, setCamposTarjeta] = useState({ numero_tarj: "", fecha_venci_tarj: "", cvv_tarj: "", nombre_titu_tarj: "", credito: false })
  const [loading, setLoading] = useState(true)
  const [procesandoVenta, setProcesandoVenta] = useState(false)
  const TAM_PAGINA = 25;
  const [paginaActual, setPaginaActual] = useState(1);
  const metodosPagoDisponibles: MetodoPagoCompleto[] = [ { cod_meto_pago: 2, tipo: "Tarjeta", credito: true } ];
  const { user } = useAuth();
  const [idVentaFactura, setIdVentaFactura] = useState<string | null>(null)
  const [openDialogFactura, setOpenDialogFactura] = useState(false)

  // Verifica si el usuario es cliente
  const esCliente = !!user?.fk_clie;

  useEffect(() => {
    const cargarProductos = async () => {
      try {
        setLoading(true);
        const [productosData, cervezas, presentaciones, lugaresTienda] = await Promise.all([
          getProductosInventario(),
          getTableData('Cerveza'),
          getTableData('Presentacion'),
          getTableData('Lugar_Tienda')
        ]);
        const productosMapeados = (productosData as any[]).map((item, idx) => {
          const cerveza = cervezas.find(c => c.nombre_cerv === item.nombre_producto);
          const presentacion = presentaciones.find(p => p.nombre_pres === item.nombre_presentacion);
          const lugarTienda = lugaresTienda.find(l => l.nombre_luga_tien === item.lugar_tienda);
          return {
            ...item,
            fk_cerv_pres_1: cerveza?.cod_cerv,
            fk_cerv_pres_2: presentacion?.cod_pres,
            fk_luga_tien: lugarTienda?.cod_luga_tien,
            fk_tien: 1,
            nombre_cerv: item.nombre_producto,
            nombre_pres: item.nombre_presentacion,
            cant_pres: Number(item.stock_actual),
            precio_actual_pres: Number(item.precio_usd),
            _key: `${item.nombre_producto}-${item.nombre_presentacion}-${item.lugar_tienda}-${idx}`
          }
        });
        setProductos(productosMapeados);
      } catch (error) {
        setProductos([]);
      } finally {
        setLoading(false);
      }
    };
    cargarProductos();
  }, []);

  useEffect(() => {
    const cargarTasa = async () => {
      try {
        const tasa = await getTasaActual();
        setTasaActual(Array.isArray(tasa) ? tasa[0] : tasa);
      } catch {
        setTasaActual(null);
      }
    };
    cargarTasa();
  }, []);

  useEffect(() => {
    if (tasaActual && itemsVenta.length > 0) {
      const subtotal = itemsVenta.reduce((total, item) => total + item.subtotal, 0);
      const iva = subtotal * 0.16;
      const total = subtotal + iva;
      const totalBs = total * tasaActual.tasa_dolar_bcv;
      const puntosGenerados = Math.floor(totalBs);
      setResumenVenta({ subtotal, iva, total, total_usd: total, total_bs: totalBs, tasa_actual: tasaActual.tasa_dolar_bcv, puntos_generados: puntosGenerados, fecha_venta: tasaActual.fecha_ini_tasa });
    } else {
      setResumenVenta(null);
    }
  }, [itemsVenta, tasaActual]);

  useEffect(() => {
    // Solo reconstruir el carrito si la lista de productos ya está cargada
    if (!esCliente || !productos || productos.length === 0) return;
    const cargarCarritoGuardado = async () => {
      if (!user?.fk_clie) {
        setItemsVenta([]);
        return;
      }
      
      const carrito = await getCarrito(user.fk_clie);
      
      // Verificar si el carrito existe y tiene items válidos
      if (carrito && 
          !carrito.error && 
          carrito.items && 
          Array.isArray(carrito.items) && 
          carrito.items.length > 0) {
        setItemsVenta(carrito.items.map((item: any, idx: number) => {
          // Usa SIEMPRE los IDs del backend si existen
          let fk_cerv_pres_1 = item.cerveza ?? item.fk_inve_tien_1;
          let fk_cerv_pres_2 = item.presentacion ?? item.fk_inve_tien_2;
          let fk_luga_tien = item.lugar_tien ?? item.fk_inve_tien_4 ?? 1;

          let producto = {
            fk_cerv_pres_1,
            fk_cerv_pres_2,
            fk_luga_tien,
            nombre_cerv: item.nombre_cerv || 'Producto no disponible',
            nombre_pres: item.nombre_pres || '',
            _key: `fallback-${idx}`
          };

          // Si falta algún ID, intenta buscarlo por nombre en la lista de productos
          if (!fk_cerv_pres_1 || !fk_cerv_pres_2) {
            const prod = productos.find(p =>
              p.nombre_cerv === item.nombre_cerv &&
              p.nombre_pres === item.nombre_pres
            );
            if (prod) {
              producto.fk_cerv_pres_1 = prod.fk_cerv_pres_1;
              producto.fk_cerv_pres_2 = prod.fk_cerv_pres_2;
              producto.fk_luga_tien = prod.fk_luga_tien ?? 1;
              producto._key = prod._key || '';
            }
          }

          const precio_unitario = typeof item.precio_unitario === 'number' && !isNaN(item.precio_unitario)
            ? item.precio_unitario
            : 0;
          const cantidad = typeof item.cantidad === 'number' && !isNaN(item.cantidad) ? item.cantidad : 1;
          return {
            producto,
            cantidad,
            precio_unitario,
            subtotal: precio_unitario * cantidad
          };
        }));
      } else {
        // Si no hay carrito, hay error, o está vacío, limpiar la interfaz
        setItemsVenta([]);
      }
    };
    cargarCarritoGuardado();
  // eslint-disable-next-line
  }, [user?.fk_clie, productos]);

  const agregarProducto = async (producto: any) => {
    try {
      const itemExistente = itemsVenta.find((item) => (item.producto as any)._key === (producto as any)._key);
      if (itemExistente) {
        const nuevaCantidad = itemExistente.cantidad + 1;
        const itemsActualizados = itemsVenta.map((item) =>
          (item.producto as any)._key === (producto as any)._key
            ? { ...item, cantidad: nuevaCantidad, subtotal: nuevaCantidad * item.precio_unitario }
            : item,
        );
        setItemsVenta(itemsActualizados);
        
        // Actualizar en backend
        if (user?.fk_clie) {
          const itemToUpdate = [{
            cerveza: producto.fk_cerv_pres_1,
            presentacion: producto.fk_cerv_pres_2,
            lugar_tien: producto.fk_luga_tien,
            precio_unitario: producto.precio_actual_pres,
            cantidad: nuevaCantidad,
            tienda: 1
          }];
          await addItemsToCarrito(user.fk_clie, itemToUpdate);
        }
      } else {
        const nuevoItem = { producto, cantidad: 1, precio_unitario: producto.precio_actual_pres, subtotal: producto.precio_actual_pres };
        setItemsVenta([...itemsVenta, nuevoItem]);
        
        // Agregar en backend
        if (user?.fk_clie) {
          const itemToAdd = [{
            cerveza: producto.fk_cerv_pres_1,
            presentacion: producto.fk_cerv_pres_2,
            lugar_tien: producto.fk_luga_tien,
            precio_unitario: producto.precio_actual_pres,
            cantidad: 1,
            tienda: 1
          }];
          await addItemsToCarrito(user.fk_clie, itemToAdd);
        }
      }
    } catch (error) {
      console.error('Error al agregar producto:', error);
    }
  };
  const modificarCantidad = async (item: any, nuevaCantidad: number) => {
    try {
      if (nuevaCantidad <= 0) {
        // Eliminar item
        setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
        // Actualizar en backend
        if (user?.fk_clie) {
          const itemToRemove = [{
            cerveza: item.producto.fk_cerv_pres_1,
            presentacion: item.producto.fk_cerv_pres_2,
            lugar_tien: item.producto.fk_luga_tien
          }];
          await removeItemsFromCarrito(user.fk_clie, itemToRemove);
        }
      } else {
        // Actualizar cantidad
        const itemsActualizados = itemsVenta.map((i) =>
          (i.producto as any)._key === (item.producto as any)._key
            ? { ...i, cantidad: nuevaCantidad, subtotal: nuevaCantidad * i.precio_unitario }
            : i,
        );
        setItemsVenta(itemsActualizados);
        
        // Actualizar en backend
        if (user?.fk_clie) {
          const itemToUpdate = [{
            cerveza: item.producto.fk_cerv_pres_1,
            presentacion: item.producto.fk_cerv_pres_2,
            lugar_tien: item.producto.fk_luga_tien,
            precio_unitario: item.precio_unitario,
            cantidad: nuevaCantidad,
            tienda: 1
          }];
          await addItemsToCarrito(user.fk_clie, itemToUpdate);
        }
      }
    } catch (error) {
      console.error('Error al modificar cantidad:', error);
    }
  };
  const eliminarItem = async (item: any) => {
    try {
      setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
      
      // Actualizar en backend
      if (user?.fk_clie) {
        const itemToRemove = [{
          cerveza: item.producto.fk_cerv_pres_1,
          presentacion: item.producto.fk_cerv_pres_2,
          lugar_tien: item.producto.fk_luga_tien
        }];
        await removeItemsFromCarrito(user.fk_clie, itemToRemove);
      }
    } catch (error) {
      console.error('Error al eliminar item:', error);
    }
  };
  const iniciarPago = () => {
    setDialogPago(true);
    setPasoActual(0);
    setPagos([]);
    setMetodoPagoSeleccionado(null);
    setMontoPago("");
    setCamposTarjeta({ numero_tarj: "", fecha_venci_tarj: "", cvv_tarj: "", nombre_titu_tarj: "", credito: false });
  };
  const agregarPago = () => {
    if (!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0) return;
    if (pagos.length >= 1) return;
    if (metodoPagoSeleccionado.tipo !== 'Tarjeta') return;
    const montoBs = parseFloat(montoPago);
    const montoTotalPagosBs = pagos.reduce((total, pago) => total + pago.monto, 0);
    const montoRestanteBs = (resumenVenta?.total_bs || 0) - montoTotalPagosBs;
    if (montoBs > montoRestanteBs + 0.01) return;
    const metodoPagoCompleto: MetodoPagoCompleto = {
      ...metodoPagoSeleccionado,
      numero_tarj: parseInt(camposTarjeta.numero_tarj),
      fecha_venci_tarj: camposTarjeta.fecha_venci_tarj,
      cvv_tarj: parseInt(camposTarjeta.cvv_tarj),
      nombre_titu_tarj: camposTarjeta.nombre_titu_tarj,
      credito: camposTarjeta.credito
    };
    const nuevoPago: PagoVenta = {
      metodo_pago: metodoPagoCompleto,
      monto: montoBs,
      fecha_pago: new Date().toISOString().split('T')[0],
      fk_tasa: tasaActual?.cod_tasa || 1
    };
    setPagos([nuevoPago]);
    setMetodoPagoSeleccionado(null);
    setMontoPago("");
    setCamposTarjeta({ numero_tarj: "", fecha_venci_tarj: "", cvv_tarj: "", nombre_titu_tarj: "", credito: false });
  };
  const procesarVentaFinal = async () => {
    // Evitar doble envío
    if (procesandoVenta) return;
    
    const montoTotalPagosBs = pagos.reduce((total, pago) => total + pago.monto, 0);
    const montoRestanteBs = (resumenVenta?.total_bs || 0) - montoTotalPagosBs;
    if (!resumenVenta || !tasaActual || montoRestanteBs > 0.01) {
      alert('Debes agregar un pago completo con tarjeta.');
      return;
    }
    setProcesandoVenta(true);
    try {
      // En el nuevo flujo, NO enviamos los items porque ya están en el carrito
      // Solo enviamos los pagos y los totales para actualizar la venta existente
      const apiPagos = pagos.map((pago) => {
        const pagoData: any = {
          tipo: pago.metodo_pago.tipo,
          monto: pago.monto / tasaActual.tasa_dolar_bcv,
        };
        if (pago.metodo_pago.tipo === "Tarjeta") {
          pagoData.numero_tarj = pago.metodo_pago.numero_tarj;
          pagoData.fecha_venci_tarj = pago.metodo_pago.fecha_venci_tarj;
          pagoData.cvv_tarj = pago.metodo_pago.cvv_tarj;
          pagoData.nombre_titu_tarj = pago.metodo_pago.nombre_titu_tarj;
          pagoData.credito = pago.metodo_pago.credito;
        }
        return pagoData;
      });
      
      const ventaData = {
        fecha_vent: new Date().toISOString().split('T')[0],
        iva_vent: resumenVenta.iva,
        base_imponible_vent: resumenVenta.subtotal,
        online: true,
        fk_clie: user?.fk_clie || 0,
        fk_tien: 1,
        items: [], // No enviamos items, ya están en el carrito
        pagos: apiPagos,
      };
      
      const resultado = await procesarVenta(ventaData as any);
      if (resultado.success) {
        setIdVentaFactura(String(resultado.cod_vent))
        setOpenDialogFactura(true)
        return
      } else {
        alert(`Error al procesar la venta: ${resultado.message}`);
      }
    } catch (error) {
      alert('Error inesperado al procesar la venta');
    } finally {
      setProcesandoVenta(false);
    }
  };
  const getEstadoChip = (estado: ProductoInventario['estado']) => {
    const color = estado === "Disponible" ? "success" : estado === "Bajo Stock" ? "warning" : "error";
    return <Chip label={estado} color={color} size="small" />;
  };
  const eliminarPago = (index: number) => {
    setPagos(pagos.filter((_, i) => i !== index));
  };
  const productosFiltrados = productos.filter(producto =>
    producto.nombre_cerv.toLowerCase().includes(busquedaProducto.toLowerCase()) ||
    producto.nombre_pres.toLowerCase().includes(busquedaProducto.toLowerCase()) ||
    producto.tipo_cerveza.toLowerCase().includes(busquedaProducto.toLowerCase())
  );
  const totalPaginas = Math.ceil(productosFiltrados.length / TAM_PAGINA);
  const productosPagina = productosFiltrados.slice(
    (paginaActual - 1) * TAM_PAGINA,
    paginaActual * TAM_PAGINA
  );
  const totalCarrito = itemsVenta.reduce((total, item) => total + (typeof item.subtotal === 'number' ? item.subtotal : Number(item.subtotal) || 0), 0);
  const guardarComoPresupuesto = async (redirigir = true) => {
    if (!esCliente) {
      alert('Solo los usuarios cliente pueden usar el carrito online.');
      return;
    }
    if (!resumenVenta || !tasaActual) {
      alert('No hay productos en el carrito.');
      return;
    }
    setProcesandoVenta(true);
    try {
      const apiItemsCarrito = itemsVenta.map(mapItemToCarrito);
      const apiItemsVenta = itemsVenta.map(mapItemToVenta);
      const carritoData = {
        usuario: user?.username,
        fecha: new Date().toISOString().split('T')[0],
        items: apiItemsCarrito,
        resumen: resumenVenta
      };
      let resultado;
      const carritoExistente = await getCarrito(user.fk_clie!);
      if (!carritoExistente || carritoExistente.error) {
        await createCarrito(user.fk_clie!);
        resultado = await addItemsToCarrito(user.fk_clie!, apiItemsCarrito);
      } else {
        resultado = await addItemsToCarrito(user.fk_clie!, apiItemsCarrito);
      }
      if (resultado && !resultado.error) {
        if (redirigir) {
          alert('Carrito guardado exitosamente.');
          setItemsVenta([]);
          if (window.location) window.location.href = '/homepage';
        }
      } else {
        alert(`Error al guardar el carrito: ${resultado?.message || resultado?.error || 'Error desconocido'}`);
      }
    } catch (error) {
      alert('Error inesperado al guardar el carrito');
    } finally {
      setProcesandoVenta(false);
    }
  };
  // Define los mapeos fuera de las funciones
  const mapItemToCarrito = (item: any) => ({
    cerveza: item.producto.fk_cerv_pres_1,
    presentacion: item.producto.fk_cerv_pres_2,
    lugar_tien: item.producto.fk_luga_tien,
    precio_unitario: item.precio_unitario,
    cantidad: item.cantidad,
    tienda: 1
  });
  const mapItemToVenta = (item: any) => ({
    fk_cerv_pres_1: item.producto.fk_cerv_pres_1,
    fk_cerv_pres_2: item.producto.fk_cerv_pres_2,
    fk_tien: 1,
    fk_luga_tien: item.producto.fk_luga_tien,
    cantidad: item.cantidad
  });
  if (loading) {
    return (
      <Box sx={{ p: 3, textAlign: 'center', minHeight: '100vh', backgroundColor: '#f5f5f5' }}>
        <Typography>Cargando punto de venta online...</Typography>
      </Box>
    )
  }
  return (
    <Box sx={{ minHeight: '100vh', p: 3, backgroundColor: '#f5f5f5' }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
          Punto de Venta Online
        </Typography>
      </Box>
      {tasaActual && (
        <Alert severity="info" sx={{ mb: 2 }}>
          <Typography variant="body2">
            Tasa BCV: {Number(tasaActual.tasa_dolar_bcv).toFixed(2)} Bs/USD | Tasa Punto: {Number(tasaActual.tasa_punto).toFixed(2)} Bs/USD | Fecha: {new Date(tasaActual.fecha_ini_tasa).toLocaleDateString('es-ES')}
          </Typography>
        </Alert>
      )}
      <Grid container spacing={3}>
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper sx={{ p: 2, mb: 2 }}>
            <TextField
              fullWidth
              placeholder="Buscar productos por nombre o tipo..."
              value={busquedaProducto}
              onChange={(e) => setBusquedaProducto(e.target.value)}
              InputProps={{ startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} /> }}
            />
          </Paper>
          <Grid container spacing={2}>
            {productosPagina.map((producto: any) => (
              <Grid size={{ xs: 12, md: 4, sm: 6 }} key={(producto as any)._key}>
                <Card sx={{ cursor: "pointer", "&:hover": { boxShadow: 4 } }} onClick={() => agregarProducto(producto)}>
                  <CardContent>
                    <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                      <Box sx={{ width: 50, height: 50, bgcolor: 'grey.200', borderRadius: 1, mr: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Typography variant="caption" color="text.secondary">🍺</Typography>
                      </Box>
                      <Box sx={{ flex: 1 }}>
                        <Typography variant="subtitle2" noWrap>{producto.nombre_cerv}</Typography>
                        <Typography variant="body2" color="text.secondary" noWrap>{producto.tipo_cerveza} - {producto.nombre_pres}</Typography>
                      </Box>
                    </Box>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 1 }}>
                      <Typography variant="h6" color="primary">${typeof producto.precio_actual_pres === 'number' ? producto.precio_actual_pres.toFixed(2) : (Number(producto.precio_actual_pres) ? Number(producto.precio_actual_pres).toFixed(2) : producto.precio_actual_pres)}</Typography>
                      {getEstadoChip(producto.estado)}
                    </Box>
                    <Typography variant="caption" color="text.secondary" noWrap>{producto.miembro_proveedor}</Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
          <Box sx={{ display: 'flex', justifyContent: 'center', my: 2 }}>
            <Pagination count={totalPaginas} page={paginaActual} onChange={(_, value) => setPaginaActual(value)} color="primary" shape="rounded" showFirstButton showLastButton />
          </Box>
        </Grid>
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2, position: "sticky", top: 20 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}><ShoppingCart />Carrito de Venta Online</Typography>
            {itemsVenta.length > 0 && (
              <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 1 }}>
                <IconButton color="error" size="small" title="Vaciar carrito" onClick={async () => {
                  if (user?.fk_clie) await deleteCarrito(user.fk_clie);
                  setItemsVenta([]);
                }}>
                  <Delete />
                </IconButton>
              </Box>
            )}
            <Paper elevation={2} sx={{ mb: 2, p: 2, bgcolor: '#f5f5f5' }}>
              <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>Cliente Online</Typography>
              <Typography variant="body2"><b>Usuario:</b> {user?.username || 'N/A'}</Typography>
              <Typography variant="body2"><b>Tipo de Venta:</b> Online</Typography>
            </Paper>
            <Box sx={{ maxHeight: 300, overflowY: "auto", mb: 2 }}>
              {itemsVenta.length === 0 ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 2 }}>No hay productos en el carrito</Typography>
              ) : (
                itemsVenta.map((item: any) => (
                  <Box key={String((item.producto as any)._key)} sx={{ mb: 2, p: 1, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                    <Typography variant="subtitle2" noWrap>{item.producto.nombre_cerv}</Typography>
                    <Typography variant="caption" color="text.secondary" noWrap>{item.producto.nombre_pres}</Typography>
                    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mt: 1 }}>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <IconButton size="small" onClick={() => modificarCantidad(item, item.cantidad - 1)}><Remove /></IconButton>
                        <TextField type="number" size="small" value={item.cantidad} onChange={e => { let val = parseInt(e.target.value); if (isNaN(val)) val = 1; if (val < 1) val = 1; modificarCantidad(item, val); }} inputProps={{ min: 1, style: { width: 40, textAlign: 'center' } }} sx={{ mx: 1, width: 60 }} />
                        <IconButton size="small" onClick={() => modificarCantidad(item, item.cantidad + 1)}><Add /></IconButton>
                      </Box>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <Typography variant="body2">${typeof item.subtotal === 'number' ? item.subtotal.toFixed(2) : (Number(item.subtotal) ? Number(item.subtotal).toFixed(2) : item.subtotal)}</Typography>
                        <IconButton size="small" color="error" onClick={() => eliminarItem(item)}><Delete /></IconButton>
                      </Box>
                    </Box>
                  </Box>
                ))
              )}
            </Box>
            {resumenVenta && (<><Divider sx={{ mb: 2 }} />
              <Box sx={{ mb: 2 }}>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>Subtotal:</Typography><Typography>${typeof resumenVenta.subtotal === 'number' ? resumenVenta.subtotal.toFixed(2) : (Number(resumenVenta.subtotal) ? Number(resumenVenta.subtotal).toFixed(2) : resumenVenta.subtotal)}</Typography></Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>IVA (16%):</Typography><Typography>${typeof resumenVenta.iva === 'number' ? resumenVenta.iva.toFixed(2) : (Number(resumenVenta.iva) ? Number(resumenVenta.iva).toFixed(2) : resumenVenta.iva)}</Typography></Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>Total USD:</Typography><Typography variant="h6" color="primary">${typeof resumenVenta.total_usd === 'number' ? resumenVenta.total_usd.toFixed(2) : (Number(resumenVenta.total_usd) ? Number(resumenVenta.total_usd).toFixed(2) : resumenVenta.total_usd)}</Typography></Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>Total Bs:</Typography><Typography variant="h6" color="secondary">{typeof resumenVenta.total_bs === 'number' ? resumenVenta.total_bs.toFixed(2) : (Number(resumenVenta.total_bs) ? Number(resumenVenta.total_bs).toFixed(2) : resumenVenta.total_bs)} Bs</Typography></Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>Puntos a generar:</Typography><Typography variant="body2" color="success.main">+{typeof resumenVenta.puntos_generados === 'number' ? resumenVenta.puntos_generados.toFixed(0) : (Number(resumenVenta.puntos_generados) ? Number(resumenVenta.puntos_generados).toFixed(0) : resumenVenta.puntos_generados)} pts</Typography></Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}><Typography>Fecha de compra:</Typography><Typography variant="body2">{resumenVenta.fecha_venta ? new Date(resumenVenta.fecha_venta).toLocaleDateString() : 'N/A'}</Typography></Box>
              </Box>
              <Button fullWidth variant="contained" size="large" startIcon={<Payment />} onClick={async () => {
                await guardarComoPresupuesto(false);
                iniciarPago();
              }} sx={{ backgroundColor: "#2E7D32", "&:hover": { backgroundColor: "#1B5E20" } }}>Pagar con Tarjeta</Button>
              <Button fullWidth variant="outlined" size="large" sx={{ mt: 1 }} onClick={() => guardarComoPresupuesto()} disabled={!esCliente || procesandoVenta}>Guardar y Salir</Button></>)}
            {itemsVenta.length > 0 && resumenVenta && (<Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}><Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Total:</Typography><Typography variant="h6" color="primary">${typeof resumenVenta.total === 'number' ? resumenVenta.total.toFixed(2) : resumenVenta.total}</Typography></Box>)}
            {resumenVenta && resumenVenta.id_venta && (
              <Button
                variant="outlined"
                color="primary"
                startIcon={<Receipt />}
                onClick={() => {
                  window.open(`/api/factura/producto/pdf?id_venta=${resumenVenta.id_venta}`, '_blank');
                }}
              >
                Descargar Factura
              </Button>
            )}
          </Paper>
        </Grid>
      </Grid>
      <Dialog open={dialogPago} onClose={() => setDialogPago(false)} maxWidth="md" fullWidth>
        <DialogTitle>Procesar Pago con Tarjeta</DialogTitle>
        <DialogContent>
          <Stepper activeStep={pasoActual} orientation="vertical">
            <Step>
              <StepLabel>Información de Tarjeta</StepLabel>
              <StepContent>
                <Box sx={{ mb: 2 }}>
                  <Typography variant="h6">Total a Pagar: ${typeof resumenVenta?.total === 'number' ? resumenVenta?.total.toFixed(2) : (Number(resumenVenta?.total) ? Number(resumenVenta?.total).toFixed(2) : resumenVenta?.total)}</Typography>
                  <Typography variant="body2" color="text.secondary">Solo se permite pago con tarjeta para ventas online</Typography>
                </Box>
                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField
                      fullWidth
                      label="Método de Pago"
                      value="Tarjeta"
                      InputProps={{ readOnly: true, startAdornment: <CreditCard sx={{ mr: 1 }} /> }}
                    />
                  </Grid>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField
                      fullWidth
                      label="Monto"
                      type="number"
                      value={typeof resumenVenta?.total_bs === 'number' ? resumenVenta.total_bs.toFixed(2) : ''}
                      InputProps={{ readOnly: true }}
                    />
                  </Grid>
                </Grid>
                <Box sx={{ mt: 2 }}>
                  <Typography variant="h6" gutterBottom>Información de Tarjeta</Typography>
                  <Grid container spacing={2}>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Número de Tarjeta" value={camposTarjeta.numero_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, numero_tarj: e.target.value})} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 3 }}>
                      <TextField fullWidth label="Fecha Vencimiento" placeholder="MM/YY" value={camposTarjeta.fecha_venci_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, fecha_venci_tarj: e.target.value})} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 3 }}>
                      <TextField fullWidth label="CVV" value={camposTarjeta.cvv_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, cvv_tarj: e.target.value})} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 8 }}>
                      <TextField fullWidth label="Nombre del Titular" value={camposTarjeta.nombre_titu_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, nombre_titu_tarj: e.target.value})} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 4 }}>
                      <FormControl fullWidth>
                        <InputLabel>Tipo</InputLabel>
                        <Select value={camposTarjeta.credito ? "credito" : "debito"} onChange={(e) => setCamposTarjeta({...camposTarjeta, credito: e.target.value === "credito"})} label="Tipo">
                          <MenuItem value="debito">Débito</MenuItem>
                          <MenuItem value="credito">Crédito</MenuItem>
                        </Select>
                      </FormControl>
                    </Grid>
                  </Grid>
                </Box>
                <Box sx={{ mt: 2 }}>
                  <Button
                    variant="contained"
                    onClick={() => {
                      // Crear el pago único automáticamente
                      const pagoUnico = {
                        metodo_pago: {
                          cod_meto_pago: 2,
                          tipo: "Tarjeta" as const,
                          numero_tarj: camposTarjeta.numero_tarj ? parseInt(camposTarjeta.numero_tarj) : undefined,
                          fecha_venci_tarj: camposTarjeta.fecha_venci_tarj,
                          cvv_tarj: camposTarjeta.cvv_tarj ? parseInt(camposTarjeta.cvv_tarj) : undefined,
                          nombre_titu_tarj: camposTarjeta.nombre_titu_tarj,
                          credito: camposTarjeta.credito
                        },
                        monto: resumenVenta?.total_bs || 0,
                        fecha_pago: new Date().toISOString().split('T')[0],
                        fk_tasa: tasaActual?.cod_tasa || 1
                      };
                      setPagos([pagoUnico]);
                      setPasoActual(1);
                    }}
                    disabled={
                      !camposTarjeta.numero_tarj ||
                      !camposTarjeta.fecha_venci_tarj ||
                      !camposTarjeta.cvv_tarj ||
                      !camposTarjeta.nombre_titu_tarj
                    }
                  >
                    Confirmar Pago
                  </Button>
                </Box>
              </StepContent>
            </Step>
            <Step>
              <StepLabel>Confirmar Pago</StepLabel>
              <StepContent>
                <Typography variant="h6" gutterBottom>Pago Registrado:</Typography>
                <List>{pagos.map((pago, index) => (<ListItem key={index}><ListItemText primary={`Tarjeta - ${pago.monto.toFixed(2)} Bs`} secondary={`Fecha: ${pago.fecha_pago}`} /></ListItem>))}</List>
                <Box sx={{ mt: 2 }}><Typography variant="h6">Total pago: {pagos.reduce((total, pago) => total + pago.monto, 0).toFixed(2)} Bs</Typography><Typography variant="body2" color="success.main">Pago completo</Typography></Box>
                <Box sx={{ mt: 2 }}><Button variant="contained" onClick={procesarVentaFinal} disabled={procesandoVenta}>{procesandoVenta ? "Procesando..." : "Confirmar Venta Online"}</Button><Button variant="outlined" onClick={() => setPasoActual(0)} sx={{ ml: 1 }} disabled={procesandoVenta}>Modificar Pago</Button></Box>
              </StepContent>
            </Step>
          </Stepper>
        </DialogContent>
        <DialogActions><Button onClick={() => setDialogPago(false)}>Cancelar</Button></DialogActions>
      </Dialog>
      {/* Dialog de éxito y descarga de factura */}
      <Dialog open={openDialogFactura} onClose={() => {
        setOpenDialogFactura(false)
        setIdVentaFactura(null)
        setItemsVenta([])
        setPagos([])
        setDialogPago(false)
        setPasoActual(0)
      }}>
        <DialogTitle>Venta procesada exitosamente</DialogTitle>
        <DialogContent>
          <Typography>La venta fue registrada correctamente.</Typography>
          {idVentaFactura && (
            <Button
              variant="outlined"
              color="primary"
              startIcon={<Receipt />}
              sx={{ mt: 2, width: '100%' }}
              onClick={() => {
                window.open(`http://localhost:3000/api/factura/producto/pdf?id_venta=${idVentaFactura}`, '_blank')
              }}
            >
              Descargar Factura
            </Button>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => {
            setOpenDialogFactura(false)
            setIdVentaFactura(null)
            setItemsVenta([])
            setPagos([])
            setDialogPago(false)
            setPasoActual(0)
          }} color="primary">Cerrar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default PuntoVentaOnline; 