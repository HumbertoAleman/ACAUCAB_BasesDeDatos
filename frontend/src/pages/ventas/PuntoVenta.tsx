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
  procesarVenta,
  getTableData
} from "../../services/api"

export const PuntoVenta: React.FC = () => {
  // Estados para datos
  const [productos, setProductos] = useState<ProductoInventario[]>([])
  const [clientes, setClientes] = useState<ClienteDetallado[]>([])
  const [tasaActual, setTasaActual] = useState<TasaVenta | null>(null)
  
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

  // Estado para mostrar el equivalente en Bs y vuelto en efectivo USD
  const [equivalenteBs, setEquivalenteBs] = useState(0);
  const [vueltoBs, setVueltoBs] = useState(0);

  // Métodos de pago fijos definidos en el frontend
  const metodosPagoFijos: MetodoPagoCompleto[] = [
    { cod_meto_pago: 1, tipo: "Efectivo", denominacion_efec: "USD" },
    { cod_meto_pago: 2, tipo: "Tarjeta", credito: true },
    { cod_meto_pago: 3, tipo: "Punto_Canjeo" },
    { cod_meto_pago: 4, tipo: "Cheque", nombre_banco: "Banco de Venezuela" },
  ];

  // Cargar datos iniciales
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
            fk_tien: 1, // Hardcodeado porque el inventario es de la tienda 1
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

  // Cargar clientes al montar el componente
  useEffect(() => {
    const cargarClientes = async () => {
      try {
        const clientesData = await getClientesDetallados();
        // Si viene como array de arrays, aplanar
        const clientesFlat = Array.isArray(clientesData[0]) ? clientesData.flat() : clientesData;
        // Mapeo para asegurar tipos correctos y nombre visible
        const clientesMapeados = (clientesFlat || []).map(cliente => ({
          ...cliente,
          puntos_acumulados: Number(cliente.puntos_acumulados) || 0,
          telefonos: Array.isArray(cliente.telefonos)
            ? cliente.telefonos
            : cliente.telefonos
              ? [cliente.telefonos]
              : [],
          correos: Array.isArray(cliente.correos)
            ? cliente.correos
            : cliente.correos
              ? [cliente.correos]
              : [],
          display_name:
            cliente.tipo_clie === 'Natural'
              ? `${cliente.primer_nom_natu || ''} ${cliente.primer_ape_natu || ''}`.trim() || cliente.rif_clie
              : cliente.razon_social_juri || cliente.rif_clie,
        }));
        setClientes(clientesMapeados);
      } catch (error) {
        setClientes([]);
      }
    };
    cargarClientes();
  }, []);

  // Cargar tasa al montar el componente
  useEffect(() => {
    const cargarTasa = async () => {
      try {
        const tasas = await getTasaActual();
        // Si el endpoint retorna un array, tomar la última tasa (más reciente)
        const tasa = Array.isArray(tasas) ? tasas[tasas.length - 1] : tasas;
        setTasaActual({
          ...tasa,
          tasa_dolar_bcv: Number(tasa.tasa_dolar_bcv),
          tasa_punto: Number(tasa.tasa_punto),
        });
      } catch (error) {
        setTasaActual(null);
      }
    };
    cargarTasa();
  }, []);

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
      const subtotal = itemsVenta.reduce((total, item) => total + item.subtotal, 0);
      const iva = subtotal * 0.16;
      const total = subtotal + iva;
      const totalBs = total * tasaActual.tasa_dolar_bcv;
      const puntosGenerados = Math.floor(totalBs); // Puntos = total en Bs
      setResumenVenta({
        subtotal,
        iva,
        total,
        total_usd: total,
        total_bs: totalBs,
        tasa_actual: tasaActual.tasa_dolar_bcv,
        puntos_generados: puntosGenerados,
        fecha_venta: tasaActual.fecha_ini_tasa // Fecha de la tasa como fecha de compra
      });
    } else {
      setResumenVenta(null);
    }
  }, [itemsVenta, tasaActual]);

  // Funciones para manejar productos
  const agregarProducto = (producto: any) => {
    if (producto.cant_pres <= 0) return;
    const itemExistente = itemsVenta.find((item) => (item.producto as any)._key === (producto as any)._key);
    if (itemExistente) {
      if (itemExistente.cantidad < producto.cant_pres) {
        setItemsVenta(
          itemsVenta.map((item) =>
            (item.producto as any)._key === (producto as any)._key
              ? {
                  ...item,
                  cantidad: item.cantidad + 1,
                  subtotal: (item.cantidad + 1) * item.precio_unitario,
                }
              : item,
          ),
        );
      }
    } else {
      const nuevoItem = {
        producto,
        cantidad: 1,
        precio_unitario: producto.precio_actual_pres,
        subtotal: producto.precio_actual_pres,
      };
      setItemsVenta([...itemsVenta, nuevoItem]);
    }
  };

  const modificarCantidad = (item: any, nuevaCantidad: number) => {
    if (nuevaCantidad <= 0) {
      setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
    } else if (nuevaCantidad <= item.producto.cant_pres) {
      setItemsVenta(
        itemsVenta.map((i) =>
          (i.producto as any)._key === (item.producto as any)._key
            ? {
                ...i,
                cantidad: nuevaCantidad,
                subtotal: nuevaCantidad * i.precio_unitario,
              }
            : i,
        ),
      );
    }
  };

  const eliminarItem = (item: any) => {
    setItemsVenta(itemsVenta.filter((i) => (i.producto as any)._key !== (item.producto as any)._key));
  };

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
    setCamposCheque({ numero_cheque: "", numero_cuenta_cheque: "", nombre_banco: "", fk_banc: "" })
    setDenominacionEfectivo("USD")
    setPuntosUsar("")
    setDialogPago(true)
  }

  // Al ingresar monto de efectivo en USD, calcular equivalente en Bs y vuelto
  useEffect(() => {
    if (metodoPagoSeleccionado?.tipo === "Efectivo" && denominacionEfectivo === "USD" && montoPago && tasaActual) {
      const montoUSD = parseFloat(montoPago);
      const eqBs = montoUSD * tasaActual.tasa_dolar_bcv;
      setEquivalenteBs(eqBs);
      const restante = (resumenVenta?.total_bs || 0) - pagos.reduce((total, pago) => total + pago.monto, 0);
      setVueltoBs(eqBs > restante ? eqBs - restante : 0);
    } else {
      setEquivalenteBs(0);
      setVueltoBs(0);
    }
  }, [montoPago, denominacionEfectivo, metodoPagoSeleccionado, tasaActual, resumenVenta, pagos]);

  const agregarPago = () => {
    if (!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0) return;
    let montoBs = 0;
    if (metodoPagoSeleccionado.tipo === "Efectivo" && denominacionEfectivo === "USD" && tasaActual) {
      montoBs = parseFloat(montoPago) * tasaActual.tasa_dolar_bcv;
    } else {
      montoBs = parseFloat(montoPago);
    }
    // Validar que no se pase del monto restante en Bs
    const montoTotalPagosBs = pagos.reduce((total, pago) => total + pago.monto, 0);
    const montoRestanteBs = (resumenVenta?.total_bs || 0) - montoTotalPagosBs;
    if (montoBs > montoRestanteBs + 0.01) return;
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
        nombre_banco: camposCheque.nombre_banco
      }),
      ...(metodoPagoSeleccionado.tipo === "Efectivo" && {
        denominacion_efec: denominacionEfectivo
      })
    };
    const nuevoPago: PagoVenta = {
      metodo_pago: metodoPagoCompleto,
      monto: montoBs,
      fecha_pago: new Date().toISOString().split('T')[0],
      fk_tasa: tasaActual?.cod_tasa || 1
    };
    setPagos([...pagos, nuevoPago]);
    setMetodoPagoSeleccionado(null);
    setMontoPago("");
    setCamposTarjeta({ numero_tarj: "", fecha_venci_tarj: "", cvv_tarj: "", nombre_titu_tarj: "", credito: false });
    setCamposCheque({ numero_cheque: "", numero_cuenta_cheque: "", nombre_banco: "", fk_banc: "" });
    setDenominacionEfectivo("USD");
    setPuntosUsar("");
  };

  const montoTotalPagosBs = pagos.reduce((total, pago) => total + pago.monto, 0);
  const montoRestanteBs = (resumenVenta?.total_bs || 0) - montoTotalPagosBs;

  const procesarVentaFinal = async () => {
    if (!resumenVenta || !tasaActual || montoRestanteBs > 0.01) {
      alert('El monto total de los pagos debe ser igual al total de la venta y la tasa debe estar disponible.')
      return
    }

    setProcesandoVenta(true)
    try {
      const apiItems: {
        fk_cerv_pres_1: number;
        fk_cerv_pres_2: number;
        fk_tien: number;
        fk_luga_tien: number;
        cantidad: number;
      }[] = itemsVenta.map((item) => ({
        fk_cerv_pres_1: (item.producto as any).fk_cerv_pres_1,
        fk_cerv_pres_2: (item.producto as any).fk_cerv_pres_2,
        fk_tien: 1, // Fijo según la especificación
        fk_luga_tien: (item.producto as any).fk_luga_tien,
        cantidad: item.cantidad,
      }));

      const apiPagos: {
        tipo: "Efectivo" | "Punto_Canjeo" | "Tarjeta" | "Cheque";
        monto: number;
        [x: string]: any;
      }[] = pagos.map((pago) => {
        const pagoData: any = {
          tipo: pago.metodo_pago.tipo,
          monto: pago.monto / tasaActual.tasa_dolar_bcv,
        };

        // Agregar detalles específicos del método de pago
        if (pago.metodo_pago.tipo === "Tarjeta") {
          pagoData.numero_tarj = pago.metodo_pago.numero_tarj;
          pagoData.fecha_venci_tarj = pago.metodo_pago.fecha_venci_tarj;
          pagoData.cvv_tarj = pago.metodo_pago.cvv_tarj;
          pagoData.nombre_titu_tarj = pago.metodo_pago.nombre_titu_tarj;
          pagoData.credito = pago.metodo_pago.credito;
        } else if (pago.metodo_pago.tipo === "Cheque") {
          pagoData.numero_cheque = pago.metodo_pago.numero_cheque;
          pagoData.numero_cuenta_cheque = pago.metodo_pago.numero_cuenta_cheque;
          pagoData.fk_banc = pago.metodo_pago.fk_banc;
        } else if (pago.metodo_pago.tipo === "Efectivo") {
          pagoData.denominacion_efec = pago.metodo_pago.denominacion_efec;
        }

        return pagoData;
      });

      const ventaData = {
        fecha_vent: new Date().toISOString().split('T')[0],
        iva_vent: resumenVenta.iva,
        base_imponible_vent: resumenVenta.subtotal,
        online: false,
        fk_clie: clienteSeleccionado?.rif_clie || null,
        fk_tien: 1,
        items: apiItems,
        pagos: apiPagos,
      };

      const resultado = await procesarVenta(ventaData as any)
      
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

  // Función para mostrar el nombre del cliente o fallback
  const getNombreCliente = (cliente: ClienteDetallado) => {
    if (!cliente) return '-';
    if (cliente.tipo_clie === 'Natural') {
      const nombre = `${cliente.primer_nom_natu || ''} ${cliente.primer_ape_natu || ''}`.trim();
      return nombre || cliente.rif_clie || '-';
    } else {
      return cliente.razon_social_juri || cliente.rif_clie || '-';
    }
  };

  const getEstadoChip = (estado: ProductoInventario['estado']) => {
    const color = estado === "Disponible" ? "success" : estado === "Bajo Stock" ? "warning" : "error"
    return <Chip label={estado} color={color} size="small" />
  }

  // Calcula el total del carrito
  const totalCarrito = itemsVenta.reduce((total, item) => total + (typeof item.subtotal === 'number' ? item.subtotal : Number(item.subtotal) || 0), 0);

  // Justo aquí, dentro del componente:
  const eliminarPago = (index: number) => {
    setPagos(pagos.filter((_, i) => i !== index));
  };

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
            {productosPagina.map((producto: any) => (
              <Grid size={{ xs: 12, md: 4, sm: 6 }} key={(producto as any)._key}>
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
                        ${typeof producto.precio_actual_pres === 'number' ? producto.precio_actual_pres.toFixed(2) : (Number(producto.precio_actual_pres) ? Number(producto.precio_actual_pres).toFixed(2) : producto.precio_actual_pres)}
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
            <FormControl fullWidth sx={{ mb: 2 }} required>
              <InputLabel>Cliente</InputLabel>
              <Select
                value={clienteSeleccionado?.rif_clie || ""}
                onChange={(e) => {
                  const cliente = clientes.find((c) => c.rif_clie === e.target.value)
                  setClienteSeleccionado(cliente || null)
                }}
                label="Cliente"
                error={!clienteSeleccionado}
              >
                {clientes.map((cliente) => (
                  <MenuItem key={cliente.rif_clie} value={cliente.rif_clie}>
                    <Box>
                      <Typography variant="body2">{cliente.display_name || cliente.rif_clie}</Typography>
                      <Typography variant="caption" color="text.secondary">
                        {cliente.tipo_clie || 'N/A'} | Puntos: {typeof cliente.puntos_acumulados === 'number' ? cliente.puntos_acumulados : 'N/A'}
                      </Typography>
                    </Box>
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            {/* Tarjeta con datos del cliente seleccionado */}
            {clienteSeleccionado && (
              <Paper elevation={2} sx={{ mb: 2, p: 2, bgcolor: '#f5f5f5' }}>
                <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>
                  Datos del Cliente
                </Typography>
                <Typography variant="body2">
                  <b>Nombre/Razón Social:</b> {clienteSeleccionado.display_name || clienteSeleccionado.rif_clie}
                </Typography>
                <Typography variant="body2">
                  <b>Tipo:</b> {clienteSeleccionado.tipo_clie || 'N/A'}
                </Typography>
                <Typography variant="body2">
                  <b>RIF:</b> {clienteSeleccionado.rif_clie || 'N/A'}
                </Typography>
                <Typography variant="body2">
                  <b>Dirección Fiscal:</b> {clienteSeleccionado.direccion_fiscal_clie || 'N/A'}
                </Typography>
                <Typography variant="body2">
                  <b>Teléfonos:</b> {clienteSeleccionado.telefonos && clienteSeleccionado.telefonos.length > 0 ? clienteSeleccionado.telefonos.join(', ') : 'N/A'}
                </Typography>
                <Typography variant="body2">
                  <b>Correos:</b> {clienteSeleccionado.correos && clienteSeleccionado.correos.length > 0 ? clienteSeleccionado.correos.join(', ') : 'N/A'}
                </Typography>
                <Typography variant="body2">
                  <b>Puntos acumulados:</b> {typeof clienteSeleccionado.puntos_acumulados === 'number' ? clienteSeleccionado.puntos_acumulados : 'N/A'}
                </Typography>
              </Paper>
            )}

            {/* Items de Venta */}
            <Box sx={{ maxHeight: 300, overflowY: "auto", mb: 2 }}>
              {itemsVenta.length === 0 ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 2 }}>
                  No hay productos en el carrito
                </Typography>
              ) : (
                itemsVenta.map((item: any) => (
                  <Box key={String((item.producto as any)._key)} sx={{ mb: 2, p: 1, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                    <Typography variant="subtitle2" noWrap>{item.producto.nombre_cerv}</Typography>
                    <Typography variant="caption" color="text.secondary" noWrap>
                      {item.producto.nombre_pres}
                    </Typography>
                    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mt: 1 }}>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <IconButton size="small" onClick={() => modificarCantidad(item, item.cantidad - 1)}>
                          <Remove />
                        </IconButton>
                        <TextField
                          type="number"
                          size="small"
                          value={item.cantidad}
                          onChange={e => {
                            let val = parseInt(e.target.value);
                            if (isNaN(val)) val = 1;
                            if (val < 1) val = 1;
                            if (val > item.producto.cant_pres) val = item.producto.cant_pres;
                            modificarCantidad(item, val);
                          }}
                          inputProps={{ min: 1, max: item.producto.cant_pres, style: { width: 40, textAlign: 'center' } }}
                          sx={{ mx: 1, width: 60 }}
                        />
                        <IconButton 
                          size="small" 
                          onClick={() => modificarCantidad(item, item.cantidad + 1)}
                          disabled={item.cantidad >= item.producto.cant_pres}
                        >
                          <Add />
                        </IconButton>
                      </Box>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <Typography variant="body2">${typeof item.subtotal === 'number' ? item.subtotal.toFixed(2) : (Number(item.subtotal) ? Number(item.subtotal).toFixed(2) : item.subtotal)}</Typography>
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
                    <Typography>${typeof resumenVenta.subtotal === 'number' ? resumenVenta.subtotal.toFixed(2) : (Number(resumenVenta.subtotal) ? Number(resumenVenta.subtotal).toFixed(2) : resumenVenta.subtotal)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>IVA (16%):</Typography>
                    <Typography>${typeof resumenVenta.iva === 'number' ? resumenVenta.iva.toFixed(2) : (Number(resumenVenta.iva) ? Number(resumenVenta.iva).toFixed(2) : resumenVenta.iva)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Total USD:</Typography>
                    <Typography variant="h6" color="primary">
                      ${typeof resumenVenta.total_usd === 'number' ? resumenVenta.total_usd.toFixed(2) : (Number(resumenVenta.total_usd) ? Number(resumenVenta.total_usd).toFixed(2) : resumenVenta.total_usd)}
                    </Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Total Bs:</Typography>
                    <Typography variant="h6" color="secondary">
                      {typeof resumenVenta.total_bs === 'number' ? resumenVenta.total_bs.toFixed(2) : (Number(resumenVenta.total_bs) ? Number(resumenVenta.total_bs).toFixed(2) : resumenVenta.total_bs)} Bs
                    </Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Puntos a generar:</Typography>
                    <Typography variant="body2" color="success.main">
                      +{typeof resumenVenta.puntos_generados === 'number' ? resumenVenta.puntos_generados.toFixed(0) : (Number(resumenVenta.puntos_generados) ? Number(resumenVenta.puntos_generados).toFixed(0) : resumenVenta.puntos_generados)} pts
                    </Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Fecha de compra:</Typography>
                    <Typography variant="body2">
                      {resumenVenta.fecha_venta ? new Date(resumenVenta.fecha_venta).toLocaleDateString() : 'N/A'}
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
                  disabled={!clienteSeleccionado}
                >
                  Pagar
                </Button>
              </>
            )}

            {itemsVenta.length > 0 && (
              <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Total:</Typography>
                <Typography variant="h6" color="primary">${typeof totalCarrito === 'number' ? totalCarrito.toFixed(2) : totalCarrito}</Typography>
              </Box>
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
                  <Typography variant="h6">Total a Pagar: ${typeof resumenVenta?.total === 'number' ? resumenVenta?.total.toFixed(2) : (Number(resumenVenta?.total) ? Number(resumenVenta?.total).toFixed(2) : resumenVenta?.total)}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    Monto restante: {typeof montoRestanteBs === 'number' ? montoRestanteBs.toFixed(2) : (Number(montoRestanteBs) ? Number(montoRestanteBs).toFixed(2) : montoRestanteBs)} Bs
                  </Typography>
                </Box>

                <Grid container spacing={2}>
                  <Grid size={{ xs: 12, md: 6 }}>
                    <FormControl fullWidth>
                      <InputLabel>Método de Pago</InputLabel>
                      <Select 
                        value={metodoPagoSeleccionado?.cod_meto_pago || ""} 
                        onChange={(e) => {
                          const metodo = metodosPagoFijos.find(m => m.cod_meto_pago === e.target.value)
                          setMetodoPagoSeleccionado(metodo || null)
                        }}
                        label="Método de Pago"
                      >
                        {metodosPagoFijos.map((metodo) => (
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
                      inputProps={{ min: 0, max: montoRestanteBs, step: 0.01 }}
                    />
                  </Grid>
                </Grid>

                {/* En el modal de pago, debajo del input de monto para efectivo USD, mostrar el equivalente en Bs y el vuelto si corresponde */}
                {metodoPagoSeleccionado?.tipo === "Efectivo" && denominacionEfectivo === "USD" && equivalenteBs > 0 && (
                  <Box sx={{ mt: 1 }}>
                    <Typography variant="body2" color="text.secondary">
                      Equivalente: {equivalenteBs.toFixed(2)} Bs
                    </Typography>
                    {vueltoBs > 0 && (
                      <Typography variant="body2" color="success.main">
                        Vuelto: {vueltoBs.toFixed(2)} Bs
                      </Typography>
                    )}
                  </Box>
                )}

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
                    <TextField
                      fullWidth
                      label="Número de Cheque"
                      value={camposCheque.numero_cheque}
                      onChange={(e) => setCamposCheque({ ...camposCheque, numero_cheque: e.target.value })}
                      sx={{ mb: 2 }}
                    />
                    <TextField
                      fullWidth
                      label="Número de Cuenta"
                      value={camposCheque.numero_cuenta_cheque}
                      onChange={(e) => setCamposCheque({ ...camposCheque, numero_cuenta_cheque: e.target.value })}
                      sx={{ mb: 2 }}
                    />
                    <TextField
                      fullWidth
                      label="Banco"
                      value={camposCheque.nombre_banco}
                      onChange={(e) => setCamposCheque({ ...camposCheque, nombre_banco: e.target.value })}
                    />
                  </Box>
                )}

                {metodoPagoSeleccionado?.tipo === "Efectivo" && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Información de Efectivo</Typography>
                    <FormControl fullWidth>
                      <InputLabel>Denominación</InputLabel>
                      <Select
                        value={denominacionEfectivo}
                        onChange={(e) => setDenominacionEfectivo(e.target.value)}
                        label="Denominación"
                      >
                        <MenuItem value="USD">Dólares (USD)</MenuItem>
                        <MenuItem value="BS">Bolívares (BS)</MenuItem>
                      </Select>
                    </FormControl>
                  </Box>
                )}

                {metodoPagoSeleccionado?.tipo === "Punto_Canjeo" && clienteSeleccionado && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="h6" gutterBottom>Canje de Puntos</Typography>
                    <Alert severity="info" sx={{ mb: 2 }}>
                      Puntos disponibles: {clienteSeleccionado.puntos_acumulados || 0}
                    </Alert>
                    <TextField
                      fullWidth
                      label="Puntos a usar"
                      type="number"
                      value={puntosUsar}
                      onChange={(e) => {
                        const val = e.target.value;
                        if (Number(val) <= (clienteSeleccionado.puntos_acumulados || 0)) {
                          setPuntosUsar(val);
                        }
                      }}
                      inputProps={{ max: clienteSeleccionado.puntos_acumulados || 0, min: 0 }}
                    />
                  </Box>
                )}

                <Box sx={{ mt: 2 }}>
                  <Button 
                    variant="contained" 
                    onClick={agregarPago}
                    disabled={
                      !metodoPagoSeleccionado ||
                      !montoPago ||
                      parseFloat(montoPago) <= 0 ||
                      (metodoPagoSeleccionado.tipo === "Efectivo" && denominacionEfectivo === "USD" && (parseFloat(montoPago) * (tasaActual?.tasa_dolar_bcv || 1) > montoRestanteBs + 0.01)) ||
                      (metodoPagoSeleccionado.tipo === "Efectivo" && denominacionEfectivo === "BS" && parseFloat(montoPago) > montoRestanteBs + 0.01) ||
                      (metodoPagoSeleccionado.tipo === "Punto_Canjeo" && parseFloat(montoPago) > (clienteSeleccionado?.puntos_acumulados || 0) )
                    }
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
                        primary={
                          pago.metodo_pago.tipo === "Efectivo" && pago.metodo_pago.denominacion_efec === "USD"
                            ? `Efectivo (USD) - $${(pago.monto / (tasaActual?.tasa_dolar_bcv || 1)).toFixed(2)} | ${pago.monto.toFixed(2)} Bs`
                            : pago.metodo_pago.tipo === "Efectivo" && pago.metodo_pago.denominacion_efec === "BS"
                              ? `Efectivo (BS) - ${pago.monto.toFixed(2)} Bs`
                              : pago.metodo_pago.tipo === "Punto_Canjeo"
                                ? `Puntos - ${pago.monto.toFixed(2)} Bs`
                                : `${pago.metodo_pago.tipo} - ${pago.monto.toFixed(2)} Bs`
                        }
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
                    Total pagos: {typeof montoTotalPagosBs === 'number' ? montoTotalPagosBs.toFixed(2) : montoTotalPagosBs} Bs
                  </Typography>
                  <Typography variant="body2" color={typeof montoRestanteBs === 'number' ? (montoRestanteBs > 0.01 ? "error" : "success.main") : montoRestanteBs > 0.01 ? "error" : "success.main"}>
                    {typeof montoRestanteBs === 'number' ? (montoRestanteBs > 0.01 ? `Falta: ${montoRestanteBs.toFixed(2)} Bs` : "Pago completo") : montoRestanteBs > 0.01 ? String(montoRestanteBs) : "Pago completo"}
                  </Typography>
                </Box>

                <Box sx={{ mt: 2 }}>
                  <Button 
                    variant="contained" 
                    onClick={procesarVentaFinal}
                    disabled={typeof montoRestanteBs === 'number' ? (montoRestanteBs > 0.01 || procesandoVenta) : montoRestanteBs > 0.01 || procesandoVenta}
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
