"use client"

import React, { useState, useEffect } from "react"
import {
  Box, Grid, Paper, Typography, TextField, Button, Card, CardContent, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, FormControl, InputLabel, Select, MenuItem, Chip, Divider, Alert, List, ListItem, ListItemText, ListItemSecondaryAction, Stepper, Step, StepLabel, StepContent, Pagination
} from "@mui/material"
import { Add, Remove, Delete, Payment, Search, ShoppingCart, CreditCard, Close } from "@mui/icons-material"
import type { ProductoInventario, TasaVenta, MetodoPagoCompleto, ItemVenta, PagoVenta, ResumenVenta } from "../../interfaces/ventas"
import { getProductosInventario, getTasaActual, procesarVenta, getBancos, getTableData, getCarrito, createCarrito, addItemsToCarrito } from "../../services/api"
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
    // Cargar carrito guardado si existe
    const cargarCarritoGuardado = async () => {
      if (!user?.username) return;
      const carrito = await getCarrito(user.username);
      if (carrito && carrito.items && Array.isArray(carrito.items) && carrito.items.length > 0) {
        setItemsVenta(carrito.items.map((item: any) => ({
          producto: item.producto,
          cantidad: item.cantidad,
          precio_unitario: item.precio_unitario,
          subtotal: item.subtotal
        })));
      }
    };
    cargarCarritoGuardado();
  }, [user?.username]);

  const agregarProducto = (producto: any) => {
    const itemExistente = itemsVenta.find((item) => (item.producto as any)._key === (producto as any)._key);
    if (itemExistente) {
      setItemsVenta(
        itemsVenta.map((item) =>
          (item.producto as any)._key === (producto as any)._key
            ? { ...item, cantidad: item.cantidad + 1, subtotal: (item.cantidad + 1) * item.precio_unitario }
            : item,
        ),
      );
    } else {
      const nuevoItem = { producto, cantidad: 1, precio_unitario: producto.precio_actual_pres, subtotal: producto.precio_actual_pres };
      setItemsVenta([...itemsVenta, nuevoItem]);
    }
  };
  const modificarCantidad = (item: any, nuevaCantidad: number) => {
    if (nuevaCantidad <= 0) {
      setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
    } else {
      setItemsVenta(
        itemsVenta.map((i) =>
          (i.producto as any)._key === (item.producto as any)._key
            ? { ...i, cantidad: nuevaCantidad, subtotal: nuevaCantidad * i.precio_unitario }
            : i,
        ),
      );
    }
  };
  const eliminarItem = (item: any) => {
    setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
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
    const montoTotalPagosBs = pagos.reduce((total, pago) => total + pago.monto, 0);
    const montoRestanteBs = (resumenVenta?.total_bs || 0) - montoTotalPagosBs;
    if (!resumenVenta || !tasaActual || montoRestanteBs > 0.01) {
      alert('Debes agregar un pago completo con tarjeta.');
      return;
    }
    setProcesandoVenta(true);
    try {
      const apiItems = itemsVenta.map((item) => ({
        fk_cerv_pres_1: (item.producto as any).fk_cerv_pres_1,
        fk_cerv_pres_2: (item.producto as any).fk_cerv_pres_2,
        fk_tien: 1,
        fk_luga_tien: 1,
        cantidad: item.cantidad,
      }));
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
        fk_clie: user?.username,
        fk_tien: 1,
        items: apiItems,
        pagos: apiPagos,
      };
      const resultado = await procesarVenta(ventaData as any);
      if (resultado.success) {
        alert(`Venta online procesada exitosamente. Código: ${resultado.cod_vent}`);
        setItemsVenta([]);
        setPagos([]);
        setDialogPago(false);
        if (onClose) onClose();
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
  const guardarComoPresupuesto = async () => {
    if (!resumenVenta || !tasaActual) {
      alert('No hay productos en el carrito.');
      return;
    }
    setProcesandoVenta(true);
    try {
      const apiItems = itemsVenta.map((item) => ({
        producto: item.producto,
        cantidad: item.cantidad,
        precio_unitario: item.precio_unitario,
        subtotal: item.subtotal
      }));
      const carritoData = {
        usuario: user?.username,
        fecha: new Date().toISOString().split('T')[0],
        items: apiItems,
        resumen: resumenVenta
      };
      let resultado;
      // Verificar si ya existe un carrito para el usuario
      const carritoExistente = user?.username ? await getCarrito(user.username) : null;
      if (!user?.username) {
        alert('No hay usuario autenticado.');
        setProcesandoVenta(false);
        return;
      }
      if (!carritoExistente || carritoExistente.error) {
        // Si no existe, crear el carrito
        resultado = await createCarrito(user.username, carritoData);
      } else {
        // Si existe, actualizar los items
        resultado = await addItemsToCarrito(user.username, apiItems);
      }
      if (resultado && !resultado.error) {
        alert('Carrito guardado exitosamente.');
        setItemsVenta([]);
        if (window.location) window.location.href = '/dashboard';
      } else {
        alert(`Error al guardar el carrito: ${resultado?.message || resultado?.error || 'Error desconocido'}`);
      }
    } catch (error) {
      alert('Error inesperado al guardar el carrito');
    } finally {
      setProcesandoVenta(false);
    }
  };
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
            Tasa BCV: {Number(tasaActual.tasa_dolar_bcv).toFixed(2)} Bs/USD | Tasa Punto: {Number(tasaActual.tasa_punto).toFixed(2)} Bs/USD | Fecha: {tasaActual.fecha_ini_tasa}
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
              <Button fullWidth variant="contained" size="large" startIcon={<Payment />} onClick={iniciarPago} sx={{ backgroundColor: "#2E7D32", "&:hover": { backgroundColor: "#1B5E20" } }}>Pagar con Tarjeta</Button>
              <Button fullWidth variant="outlined" size="large" sx={{ mt: 1 }} onClick={guardarComoPresupuesto} disabled={procesandoVenta}>Guardar y Salir</Button></>)}
            {itemsVenta.length > 0 && (<Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}><Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Total:</Typography><Typography variant="h6" color="primary">${typeof totalCarrito === 'number' ? totalCarrito.toFixed(2) : totalCarrito}</Typography></Box>)}
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
                    <FormControl fullWidth>
                      <InputLabel>Método de Pago</InputLabel>
                      <Select value={metodoPagoSeleccionado?.cod_meto_pago || ""} onChange={(e) => { const metodo = metodosPagoDisponibles.find(m => m.cod_meto_pago === e.target.value); setMetodoPagoSeleccionado(metodo || null); }} label="Método de Pago">
                        {metodosPagoDisponibles.map((metodo) => (<MenuItem key={metodo.cod_meto_pago} value={metodo.cod_meto_pago}><Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}><CreditCard /><Typography>Tarjeta</Typography></Box></MenuItem>))}
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField fullWidth label="Monto" type="number" value={montoPago} onChange={(e) => setMontoPago(e.target.value)} inputProps={{ min: 0, step: 0.01 }} />
                  </Grid>
                </Grid>
                {metodoPagoSeleccionado?.tipo === "Tarjeta" && (<Box sx={{ mt: 2 }}><Typography variant="h6" gutterBottom>Información de Tarjeta</Typography><Grid container spacing={2}><Grid size={{ xs: 12, md: 6 }}><TextField fullWidth label="Número de Tarjeta" value={camposTarjeta.numero_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, numero_tarj: e.target.value})} /></Grid><Grid size={{ xs: 12, md: 3 }}><TextField fullWidth label="Fecha Vencimiento" placeholder="MM/YY" value={camposTarjeta.fecha_venci_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, fecha_venci_tarj: e.target.value})} /></Grid><Grid size={{ xs: 12, md: 3 }}><TextField fullWidth label="CVV" value={camposTarjeta.cvv_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, cvv_tarj: e.target.value})} /></Grid><Grid size={{ xs: 12, md: 8 }}><TextField fullWidth label="Nombre del Titular" value={camposTarjeta.nombre_titu_tarj} onChange={(e) => setCamposTarjeta({...camposTarjeta, nombre_titu_tarj: e.target.value})} /></Grid><Grid size={{ xs: 12, md: 4 }}><FormControl fullWidth><InputLabel>Tipo</InputLabel><Select value={camposTarjeta.credito ? "credito" : "debito"} onChange={(e) => setCamposTarjeta({...camposTarjeta, credito: e.target.value === "credito"})} label="Tipo"><MenuItem value="debito">Débito</MenuItem><MenuItem value="credito">Crédito</MenuItem></Select></FormControl></Grid></Grid></Box>)}
                <Box sx={{ mt: 2 }}><Button variant="contained" onClick={agregarPago} disabled={!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0 || pagos.length >= 1}>Agregar Pago</Button>{pagos.length > 0 && (<Button variant="outlined" onClick={() => setPasoActual(1)} sx={{ ml: 1 }}>Confirmar Pago</Button>)}</Box>
              </StepContent>
            </Step>
            <Step>
              <StepLabel>Confirmar Pago</StepLabel>
              <StepContent>
                <Typography variant="h6" gutterBottom>Pago Registrado:</Typography>
                <List>{pagos.map((pago, index) => (<ListItem key={index}><ListItemText primary={`Tarjeta - ${pago.monto.toFixed(2)} Bs`} secondary={`Fecha: ${pago.fecha_pago}`} /><ListItemSecondaryAction><IconButton edge="end" onClick={() => eliminarPago(index)}><Delete /></IconButton></ListItemSecondaryAction></ListItem>))}</List>
                <Box sx={{ mt: 2 }}><Typography variant="h6">Total pago: {pagos.reduce((total, pago) => total + pago.monto, 0).toFixed(2)} Bs</Typography><Typography variant="body2" color="success.main">Pago completo</Typography></Box>
                <Box sx={{ mt: 2 }}><Button variant="contained" onClick={procesarVentaFinal} disabled={procesandoVenta}>{procesandoVenta ? "Procesando..." : "Confirmar Venta Online"}</Button><Button variant="outlined" onClick={() => setPasoActual(0)} sx={{ ml: 1 }}>Modificar Pago</Button></Box>
              </StepContent>
            </Step>
          </Stepper>
        </DialogContent>
        <DialogActions><Button onClick={() => setDialogPago(false)}>Cancelar</Button></DialogActions>
      </Dialog>
    </Box>
  )
}

export default PuntoVentaOnline; 