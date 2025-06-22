"use client"

import type React from "react"
import { useState, useEffect } from "react"
import {
  Box,
  Grid,
  Paper,
  Typography,
  TextField,
  Button,
  Card,
  CardContent,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Divider,
  Alert,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Stepper,
  Step,
  StepLabel,
  StepContent,
  Pagination,
} from "@mui/material"
import { 
  Add, 
  Remove, 
  Delete, 
  Payment, 
  Search, 
  ShoppingCart, 
  ExpandMore,
  Person,
  AttachMoney,
  CreditCard,
  LocalOffer,
  Receipt
} from "@mui/icons-material"
import type { ProductoInventario, ClienteDetallado, TasaVenta, MetodoPagoCompleto, ItemVenta, PagoVenta, ResumenVenta } from "../../interfaces/ventas"
import { 
  getProductosInventario, 
  getClientesDetallados, 
  getTasaActual, 
  getMetodosPago, 
  procesarVenta 
} from "../../services/api"

export const PuntoVenta: React.FC = () => {
  // Estados para datos
  const [productos, setProductos] = useState<ProductoInventario[]>([])
  const [clientes, setClientes] = useState<ClienteDetallado[]>([])
  const [tasaActual, setTasaActual] = useState<TasaVenta | null>(null)
  const [metodosPago, setMetodosPago] = useState<MetodoPagoCompleto[]>([])
  
  // Estados para la venta
  const [busquedaProducto, setBusquedaProducto] = useState("")
  const [clienteSeleccionado, setClienteSeleccionado] = useState<ClienteDetallado | null>(null)
  const [itemsVenta, setItemsVenta] = useState<ItemVenta[]>([])
  const [resumenVenta, setResumenVenta] = useState<ResumenVenta | null>(null)
  
  // Estados para el proceso de pago
  const [dialogPago, setDialogPago] = useState(false)
  const [pasoActual, setPasoActual] = useState(0)
  const [pagos, setPagos] = useState<PagoVenta[]>([])
  const [metodoPagoSeleccionado, setMetodoPagoSeleccionado] = useState<MetodoPagoCompleto | null>(null)
  const [montoPago, setMontoPago] = useState("")
  
  // Campos específicos para métodos de pago
  const [camposTarjeta, setCamposTarjeta] = useState({
    numero_tarj: "",
    fecha_venci_tarj: "",
    cvv_tarj: "",
    nombre_titu_tarj: "",
    credito: false
  })
  const [camposCheque, setCamposCheque] = useState({
    numero_cheque: "",
    numero_cuenta_cheque: "",
    fk_banc: "",
    nombre_banco: ""
  })
  const [denominacionEfectivo, setDenominacionEfectivo] = useState("USD")
  const [puntosUsar, setPuntosUsar] = useState("")
  
  // Estados de carga
  const [loading, setLoading] = useState(true)
  const [procesandoVenta, setProcesandoVenta] = useState(false)

  const TAM_PAGINA = 25;
  const [paginaActual, setPaginaActual] = useState(1);

  // Cargar datos iniciales
  useEffect(() => {
    const cargarDatos = async () => {
      try {
        setLoading(true)
        const [productosData, clientesData, tasaData, metodosData] = await Promise.all([
          getProductosInventario(),
          getClientesDetallados(),
          getTasaActual(),
          getMetodosPago()
        ])
        
        setProductos(productosData)
        setClientes(clientesData)
        setTasaActual(tasaData)
        setMetodosPago(metodosData)
      } catch (error) {
        console.error('Error cargando datos:', error)
      } finally {
        setLoading(false)
      }
    }
    
    cargarDatos()
  }, [])

  useEffect(() => {
    setPaginaActual(1);
  }, [productos, busquedaProducto]);

  // Filtrar productos
  const productosFiltered = productos.filter((producto) =>
    (producto.nombre_cerv?.toLowerCase() ?? "").includes(busquedaProducto.toLowerCase()) ||
    (producto.tipo_cerveza?.toLowerCase() ?? "").includes(busquedaProducto.toLowerCase())
  )

  const totalPaginas = Math.ceil(productosFiltered.length / TAM_PAGINA);
  const productosPagina = productosFiltered.slice(
    (paginaActual - 1) * TAM_PAGINA,
    paginaActual * TAM_PAGINA
  );

  // Calcular resumen de venta
  useEffect(() => {
    if (tasaActual && itemsVenta.length > 0) {
      const subtotal = itemsVenta.reduce((total, item) => total + item.subtotal, 0)
      const iva = subtotal * 0.16
      const total = subtotal + iva
      const totalBs = total * tasaActual.tasa_dolar_bcv
      const puntosGenerados = Math.floor(total * 10) // 10 puntos por USD

      setResumenVenta({
        subtotal,
        iva,
        total,
        total_usd: total,
        total_bs: totalBs,
        tasa_actual: tasaActual.tasa_dolar_bcv,
        puntos_generados: puntosGenerados,
        fecha_venta: new Date().toISOString().split('T')[0]
      })
    } else {
      setResumenVenta(null)
    }
  }, [itemsVenta, tasaActual])

  // Funciones para manejar productos
  const agregarProducto = (producto: ProductoInventario) => {
    if (producto.cant_pres <= 0) return

    const itemExistente = itemsVenta.find((item) => 
      item.producto.fk_cerv_pres_1 === producto.fk_cerv_pres_1 &&
      item.producto.fk_cerv_pres_2 === producto.fk_cerv_pres_2 &&
      item.producto.fk_tien === producto.fk_tien &&
      item.producto.fk_luga_tien === producto.fk_luga_tien
    )

    if (itemExistente) {
      if (itemExistente.cantidad < producto.cant_pres) {
        setItemsVenta(
          itemsVenta.map((item) =>
            item === itemExistente
              ? {
                  ...item,
                  cantidad: item.cantidad + 1,
                  subtotal: (item.cantidad + 1) * item.precio_unitario,
                }
              : item,
          ),
        )
      }
    } else {
      const nuevoItem: ItemVenta = {
        producto,
        cantidad: 1,
        precio_unitario: producto.precio_actual_pres,
        subtotal: producto.precio_actual_pres,
      }
      setItemsVenta([...itemsVenta, nuevoItem])
    }
  }

  const modificarCantidad = (item: ItemVenta, nuevaCantidad: number) => {
    if (nuevaCantidad <= 0) {
      setItemsVenta(itemsVenta.filter((i) => i !== item))
    } else if (nuevaCantidad <= item.producto.cant_pres) {
      setItemsVenta(
        itemsVenta.map((i) =>
          i === item
            ? {
                ...i,
                cantidad: nuevaCantidad,
                subtotal: nuevaCantidad * i.precio_unitario,
              }
            : i,
        ),
      )
    }
  }

  const eliminarItem = (item: ItemVenta) => {
    setItemsVenta(itemsVenta.filter((i) => i !== item))
  }

  // Funciones para el proceso de pago
  const iniciarPago = () => {
    setPagos([])
    setPasoActual(0)
    setMetodoPagoSeleccionado(null)
    setMontoPago("")
    setCamposTarjeta({
      numero_tarj: "",
      fecha_venci_tarj: "",
      cvv_tarj: "",
      nombre_titu_tarj: "",
      credito: false
    })
    setCamposCheque({
      numero_cheque: "",
      numero_cuenta_cheque: "",
      fk_banc: "",
      nombre_banco: ""
    })
    setDenominacionEfectivo("USD")
    setPuntosUsar("")
    setDialogPago(true)
  }

  const agregarPago = () => {
    if (!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0) return

    const monto = parseFloat(montoPago)
    
    // Crear método de pago con campos específicos
    const metodoPagoCompleto: MetodoPagoCompleto = {
      ...metodoPagoSeleccionado,
      ...(metodoPagoSeleccionado.tipo === "Tarjeta" && {
        numero_tarj: parseInt(camposTarjeta.numero_tarj),
        fecha_venci_tarj: camposTarjeta.fecha_venci_tarj,
        cvv_tarj: parseInt(camposTarjeta.cvv_tarj),
        nombre_titu_tarj: camposTarjeta.nombre_titu_tarj,
        credito: camposTarjeta.credito
      }),
      ...(metodoPagoSeleccionado.tipo === "Cheque" && {
        numero_cheque: parseInt(camposCheque.numero_cheque),
        numero_cuenta_cheque: parseInt(camposCheque.numero_cuenta_cheque),
        fk_banc: parseInt(camposCheque.fk_banc),
        nombre_banco: camposCheque.nombre_banco
      }),
      ...(metodoPagoSeleccionado.tipo === "Efectivo" && {
        denominacion_efec: denominacionEfectivo
      })
    }

    const nuevoPago: PagoVenta = {
      metodo_pago: metodoPagoCompleto,
      monto,
      fecha_pago: new Date().toISOString().split('T')[0],
      fk_tasa: tasaActual?.cod_tasa || 1
    }

    setPagos([...pagos, nuevoPago])
    
    // Limpiar campos para el siguiente pago
    setMetodoPagoSeleccionado(null)
    setMontoPago("")
    setCamposTarjeta({
      numero_tarj: "",
      fecha_venci_tarj: "",
      cvv_tarj: "",
      nombre_titu_tarj: "",
      credito: false
    })
    setCamposCheque({
      numero_cheque: "",
      numero_cuenta_cheque: "",
      fk_banc: "",
      nombre_banco: ""
    })
    setDenominacionEfectivo("USD")
    setPuntosUsar("")
    
    // Solo ir al paso de confirmación si el pago está completo
    if (montoRestante - monto <= 0.01) {
      setPasoActual(1)
    }
  }

  const eliminarPago = (index: number) => {
    setPagos(pagos.filter((_, i) => i !== index))
  }

  const montoTotalPagos = pagos.reduce((total, pago) => total + pago.monto, 0)
  const montoRestante = (resumenVenta?.total || 0) - montoTotalPagos

  const procesarVentaFinal = async () => {
    if (!resumenVenta || montoRestante > 0.01) {
      alert('El monto total de los pagos debe ser igual al total de la venta')
      return
    }

    setProcesandoVenta(true)
    try {
      const ventaCompleta = {
        fecha_vent: resumenVenta.fecha_venta,
        iva_vent: resumenVenta.iva,
        base_imponible_vent: resumenVenta.subtotal,
        total_vent: resumenVenta.total,
        online: false,
        fk_clie: clienteSeleccionado?.rif_clie,
        fk_tien: 1, // Tienda por defecto
        items: itemsVenta,
        pagos,
        tasa_dia: tasaActual || undefined,
        puntos_generados: resumenVenta.puntos_generados,
        total_usd: resumenVenta.total_usd,
        total_bs: resumenVenta.total_bs
      }

      const resultado = await procesarVenta(ventaCompleta)
      
      if (resultado.success) {
        alert(`Venta procesada exitosamente. Código: ${resultado.cod_vent}`)
        // Limpiar formulario
        setItemsVenta([])
        setClienteSeleccionado(null)
        setPagos([])
        setDialogPago(false)
        setPasoActual(0)
      } else {
        alert(`Error al procesar la venta: ${resultado.message}`)
      }
    } catch (error) {
      alert('Error inesperado al procesar la venta')
    } finally {
      setProcesandoVenta(false)
    }
  }

  const getNombreCliente = (cliente: ClienteDetallado) => {
    if (cliente.tipo_clie === "Natural") {
      return `${cliente.primer_nom_natu || ""} ${cliente.primer_ape_natu || ""}`.trim()
    } else {
      return cliente.razon_social_juri || ""
    }
  }

  const getEstadoChip = (estado: ProductoInventario['estado']) => {
    const color = estado === "Disponible" ? "success" : estado === "Bajo Stock" ? "warning" : "error"
    return <Chip label={estado} color={color} size="small" />
  }

  if (loading) {
    return (
      <Box sx={{ p: 3, textAlign: 'center' }}>
        <Typography>Cargando punto de venta...</Typography>
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Punto de Venta
      </Typography>

      {/* Información de tasa y fecha */}
      {tasaActual && (
        <Alert severity="info" sx={{ mb: 2 }}>
          <Typography variant="body2">
            Tasa BCV: {tasaActual.tasa_dolar_bcv.toFixed(2)} Bs/USD | 
            Tasa Punto: {tasaActual.tasa_punto.toFixed(2)} Bs/USD | 
            Fecha: {tasaActual.fecha_ini_tasa}
          </Typography>
        </Alert>
      )}

      <Grid container spacing={3}>
        {/* Panel de Productos */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper sx={{ p: 2, mb: 2 }}>
            <TextField
              fullWidth
              placeholder="Buscar productos por nombre o tipo..."
              value={busquedaProducto}
              onChange={(e) => setBusquedaProducto(e.target.value)}
              InputProps={{
                startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} />,
              }}
            />
          </Paper>

          <Grid container spacing={2}>
            {productosPagina.map((producto) => (
              <Grid size={{ xs: 12, md: 4, sm: 6 }} key={`${producto.fk_cerv_pres_1}-${producto.fk_cerv_pres_2}-${producto.fk_tien}-${producto.fk_luga_tien}`}>
                <Card
                  sx={{
                    cursor: producto.cant_pres > 0 ? "pointer" : "default",
                    "&:hover": { boxShadow: producto.cant_pres > 0 ? 4 : 1 },
                    opacity: producto.cant_pres === 0 ? 0.5 : 1,
                  }}
                  onClick={() => producto.cant_pres > 0 && agregarProducto(producto)}
                >
                  <CardContent>
                    <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                      <Box sx={{ width: 50, height: 50, bgcolor: 'grey.200', borderRadius: 1, mr: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Typography variant="caption" color="text.secondary">🍺</Typography>
                      </Box>
                      <Box sx={{ flex: 1 }}>
                        <Typography variant="subtitle2" noWrap>{producto.nombre_cerv}</Typography>
                        <Typography variant="body2" color="text.secondary" noWrap>
                          {producto.tipo_cerveza} - {producto.nombre_pres}
                        </Typography>
                      </Box>
                    </Box>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 1 }}>
                      <Typography variant="h6" color="primary">
                        ${producto.precio_actual_pres.toFixed(2)}
                      </Typography>
                      {getEstadoChip(producto.estado)}
                    </Box>
                    <Typography variant="body2" color="text.secondary" noWrap>
                      Stock: {producto.cant_pres} | {producto.lugar_tienda}
                    </Typography>
                    <Typography variant="caption" color="text.secondary" noWrap>
                      {producto.miembro_proveedor}
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
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
        </Grid>

        {/* Panel de Venta */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2, position: "sticky", top: 20 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}>
              <ShoppingCart />
              Carrito de Venta
            </Typography>

            {/* Selección de Cliente */}
            <FormControl fullWidth sx={{ mb: 2 }}>
              <InputLabel>Cliente (Opcional)</InputLabel>
              <Select
                value={clienteSeleccionado?.rif_clie || ""}
                onChange={(e) => {
                  const cliente = clientes.find((c) => c.rif_clie === e.target.value)
                  setClienteSeleccionado(cliente || null)
                }}
                label="Cliente (Opcional)"
              >
                <MenuItem value="">Sin cliente</MenuItem>
                {clientes.map((cliente) => (
                  <MenuItem key={cliente.rif_clie} value={cliente.rif_clie}>
                    <Box>
                      <Typography variant="body2">{getNombreCliente(cliente)}</Typography>
                      <Typography variant="caption" color="text.secondary">
                        {cliente.tipo_clie} | Puntos: {cliente.puntos_acumulados || 0}
                      </Typography>
                    </Box>
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <Divider sx={{ mb: 2 }} />

            {/* Items de Venta */}
            <Box sx={{ maxHeight: 300, overflowY: "auto", mb: 2 }}>
              {itemsVenta.length === 0 ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 2 }}>
                  No hay productos en el carrito
                </Typography>
              ) : (
                itemsVenta.map((item, index) => (
                  <Box key={index} sx={{ mb: 2, p: 1, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                    <Typography variant="subtitle2" noWrap>{item.producto.nombre_cerv}</Typography>
                    <Typography variant="caption" color="text.secondary" noWrap>
                      {item.producto.nombre_pres}
                    </Typography>
                    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mt: 1 }}>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <IconButton size="small" onClick={() => modificarCantidad(item, item.cantidad - 1)}>
                          <Remove />
                        </IconButton>
                        <Typography>{item.cantidad}</Typography>
                        <IconButton 
                          size="small" 
                          onClick={() => modificarCantidad(item, item.cantidad + 1)}
                          disabled={item.cantidad >= item.producto.cant_pres}
                        >
                          <Add />
                        </IconButton>
                      </Box>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <Typography variant="body2">${item.subtotal.toFixed(2)}</Typography>
                        <IconButton size="small" color="error" onClick={() => eliminarItem(item)}>
                          <Delete />
                        </IconButton>
                      </Box>
                    </Box>
                  </Box>
                ))
              )}
            </Box>

            {/* Totales */}
            {resumenVenta && (
              <>
                <Divider sx={{ mb: 2 }} />
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Subtotal:</Typography>
                    <Typography>${resumenVenta.subtotal.toFixed(2)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>IVA (16%):</Typography>
                    <Typography>${resumenVenta.iva.toFixed(2)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Total USD:</Typography>
                    <Typography variant="h6" color="primary">
                      ${resumenVenta.total_usd.toFixed(2)}
                    </Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Total Bs:</Typography>
                    <Typography variant="h6" color="secondary">
                      {resumenVenta.total_bs.toFixed(2)} Bs
                    </Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Puntos a generar:</Typography>
                    <Typography variant="body2" color="success.main">
                      +{resumenVenta.puntos_generados} pts
                    </Typography>
                  </Box>
                </Box>

                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  startIcon={<Payment />}
                  onClick={iniciarPago}
                  sx={{ backgroundColor: "#2E7D32", "&:hover": { backgroundColor: "#1B5E20" } }}
                >
                  Procesar Venta
                </Button>
              </>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Dialog de Pago Múltiple */}
      <Dialog open={dialogPago} onClose={() => setDialogPago(false)} maxWidth="md" fullWidth>
        <DialogTitle>Procesar Pago Múltiple</DialogTitle>
        <DialogContent>
          <Stepper activeStep={pasoActual} orientation="vertical">
            <Step>
              <StepLabel>Agregar Métodos de Pago</StepLabel>
              <StepContent>
                <Box sx={{ mb: 2 }}>
                  <Typography variant="h6">Total a Pagar: ${resumenVenta?.total.toFixed(2)}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    Monto restante: ${montoRestante.toFixed(2)}
                  </Typography>
                </Box>

                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <FormControl fullWidth>
                      <InputLabel>Método de Pago</InputLabel>
                      <Select 
                        value={metodoPagoSeleccionado?.cod_meto_pago || ""} 
                        onChange={(e) => {
                          const metodo = metodosPago.find(m => m.cod_meto_pago === e.target.value)
                          setMetodoPagoSeleccionado(metodo || null)
                        }}
                        label="Método de Pago"
                      >
                        {metodosPago.map((metodo) => (
                          <MenuItem key={metodo.cod_meto_pago} value={metodo.cod_meto_pago}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                              {metodo.tipo === "Efectivo" && <AttachMoney />}
                              {metodo.tipo === "Tarjeta" && <CreditCard />}
                              {metodo.tipo === "Punto_Canjeo" && <LocalOffer />}
                              {metodo.tipo === "Cheque" && <Receipt />}
                              <Typography>{metodo.tipo}</Typography>
                            </Box>
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  </Grid>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <TextField
                      fullWidth
                      label="Monto"
                      type="number"
                      value={montoPago}
                      onChange={(e) => setMontoPago(e.target.value)}
                      inputProps={{ min: 0, max: montoRestante, step: 0.01 }}
                    />
                  </Grid>
                </Grid>

                {/* Campos específicos según el método de pago */}
                {metodoPagoSeleccionado?.tipo === "Tarjeta" && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Información de Tarjeta</Typography>
                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Número de Tarjeta"
                          value={camposTarjeta.numero_tarj}
                          onChange={(e) => setCamposTarjeta({...camposTarjeta, numero_tarj: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 3 }}>
                        <TextField
                          fullWidth
                          label="Fecha Vencimiento"
                          placeholder="MM/YY"
                          value={camposTarjeta.fecha_venci_tarj}
                          onChange={(e) => setCamposTarjeta({...camposTarjeta, fecha_venci_tarj: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 3 }}>
                        <TextField
                          fullWidth
                          label="CVV"
                          value={camposTarjeta.cvv_tarj}
                          onChange={(e) => setCamposTarjeta({...camposTarjeta, cvv_tarj: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 8 }}>
                        <TextField
                          fullWidth
                          label="Nombre del Titular"
                          value={camposTarjeta.nombre_titu_tarj}
                          onChange={(e) => setCamposTarjeta({...camposTarjeta, nombre_titu_tarj: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 4 }}>
                        <FormControl fullWidth>
                          <InputLabel>Tipo</InputLabel>
                          <Select
                            value={camposTarjeta.credito ? "credito" : "debito"}
                            onChange={(e) => setCamposTarjeta({...camposTarjeta, credito: e.target.value === "credito"})}
                            label="Tipo"
                          >
                            <MenuItem value="debito">Débito</MenuItem>
                            <MenuItem value="credito">Crédito</MenuItem>
                          </Select>
                        </FormControl>
                      </Grid>
                    </Grid>
                  </Box>
                )}

                {metodoPagoSeleccionado?.tipo === "Cheque" && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Información de Cheque</Typography>
                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Número de Cheque"
                          value={camposCheque.numero_cheque}
                          onChange={(e) => setCamposCheque({...camposCheque, numero_cheque: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Número de Cuenta"
                          value={camposCheque.numero_cuenta_cheque}
                          onChange={(e) => setCamposCheque({...camposCheque, numero_cuenta_cheque: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Banco"
                          value={camposCheque.nombre_banco}
                          onChange={(e) => setCamposCheque({...camposCheque, nombre_banco: e.target.value})}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="ID Banco"
                          type="number"
                          value={camposCheque.fk_banc}
                          onChange={(e) => setCamposCheque({...camposCheque, fk_banc: e.target.value})}
                        />
                      </Grid>
                    </Grid>
                  </Box>
                )}

                {metodoPagoSeleccionado?.tipo === "Efectivo" && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Información de Efectivo</Typography>
                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <FormControl fullWidth>
                          <InputLabel>Denominación</InputLabel>
                          <Select
                            value={denominacionEfectivo}
                            onChange={(e) => setDenominacionEfectivo(e.target.value)}
                            label="Denominación"
                          >
                            <MenuItem value="USD">Dólares (USD)</MenuItem>
                            <MenuItem value="BS">Bolívares (BS)</MenuItem>
                            <MenuItem value="EUR">Euros (EUR)</MenuItem>
                          </Select>
                        </FormControl>
                      </Grid>
                    </Grid>
                  </Box>
                )}

                {metodoPagoSeleccionado?.tipo === "Punto_Canjeo" && clienteSeleccionado && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Canje de Puntos</Typography>
                    <Alert severity="info" sx={{ mb: 2 }}>
                      Puntos disponibles: {clienteSeleccionado.puntos_acumulados || 0}
                    </Alert>
                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Puntos a usar"
                          type="number"
                          value={puntosUsar}
                          onChange={(e) => setPuntosUsar(e.target.value)}
                          inputProps={{ max: clienteSeleccionado.puntos_acumulados || 0 }}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <Typography variant="body2" sx={{ mt: 2 }}>
                          Valor en USD: ${(parseInt(puntosUsar) / 100).toFixed(2)} (100 puntos = $1 USD)
                        </Typography>
                      </Grid>
                    </Grid>
                  </Box>
                )}

                <Box sx={{ mt: 2 }}>
                  <Button 
                    variant="contained" 
                    onClick={agregarPago}
                    disabled={!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0}
                  >
                    Agregar Pago
                  </Button>
                  {pagos.length > 0 && (
                    <Button 
                      variant="outlined" 
                      onClick={() => setPasoActual(1)}
                      sx={{ ml: 1 }}
                    >
                      Ver Pagos ({pagos.length})
                    </Button>
                  )}
                </Box>
              </StepContent>
            </Step>

            <Step>
              <StepLabel>Confirmar Pagos</StepLabel>
              <StepContent>
                <Typography variant="h6" gutterBottom>Pagos Registrados:</Typography>
                <List>
                  {pagos.map((pago, index) => (
                    <ListItem key={index}>
                      <ListItemText
                        primary={`${pago.metodo_pago.tipo} - $${pago.monto.toFixed(2)}`}
                        secondary={`Fecha: ${pago.fecha_pago}`}
                      />
                      <ListItemSecondaryAction>
                        <IconButton edge="end" onClick={() => eliminarPago(index)}>
                          <Delete />
                        </IconButton>
                      </ListItemSecondaryAction>
                    </ListItem>
                  ))}
                </List>

                <Box sx={{ mt: 2 }}>
                  <Typography variant="h6">
                    Total pagos: ${montoTotalPagos.toFixed(2)}
                  </Typography>
                  <Typography variant="body2" color={montoRestante > 0.01 ? "error" : "success.main"}>
                    {montoRestante > 0.01 
                      ? `Falta: $${montoRestante.toFixed(2)}` 
                      : "Pago completo"
                    }
                  </Typography>
                </Box>

                <Box sx={{ mt: 2 }}>
                  <Button 
                    variant="contained" 
                    onClick={procesarVentaFinal}
                    disabled={montoRestante > 0.01 || procesandoVenta}
                  >
                    {procesandoVenta ? "Procesando..." : "Confirmar Venta"}
                  </Button>
                  <Button 
                    variant="outlined" 
                    onClick={() => setPasoActual(0)}
                    sx={{ ml: 1 }}
                  >
                    Agregar Más Pagos
                  </Button>
                </Box>
              </StepContent>
            </Step>
          </Stepper>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogPago(false)}>Cancelar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
