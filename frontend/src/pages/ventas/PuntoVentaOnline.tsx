import React, { useState, useEffect } from "react";
import {
  Box, Grid, Paper, Typography, TextField, Button, Card, CardContent, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, FormControl, InputLabel, Select, MenuItem, Chip, Divider, Alert, List, ListItem, ListItemText, ListItemSecondaryAction, Accordion, AccordionSummary, AccordionDetails, Stepper, Step, StepLabel, StepContent, Pagination
} from "@mui/material";
import { Add, Remove, Delete, Payment, Search, ShoppingCart, ExpandMore, Person, AttachMoney, CreditCard, LocalOffer, Receipt } from "@mui/icons-material";
import type { ProductoInventario, TasaVenta, MetodoPagoCompleto, ItemVenta, PagoVenta, ResumenVenta } from "../../interfaces/ventas";
import { getClientesDetallados, getTasaActual, getMetodosPago, procesarVenta, getBancos } from "../../services/api";
import { useAuth } from '../../contexts/AuthContext';

const PuntoVentaOnline: React.FC = () => {
  const [productos, setProductos] = useState<ProductoInventario[]>([]);
  const [tasaActual, setTasaActual] = useState<TasaVenta | null>(null);
  const [bancos, setBancos] = useState<any[]>([]);
  const [busquedaProducto, setBusquedaProducto] = useState("");
  const [itemsVenta, setItemsVenta] = useState<ItemVenta[]>([]);
  const [resumenVenta, setResumenVenta] = useState<ResumenVenta | null>(null);
  const [dialogPago, setDialogPago] = useState(false);
  const [pasoActual, setPasoActual] = useState(0);
  const [pagos, setPagos] = useState<PagoVenta[]>([]);
  const [metodoPagoSeleccionado, setMetodoPagoSeleccionado] = useState<MetodoPagoCompleto | null>(null);
  const [montoPago, setMontoPago] = useState("");
  const [camposTarjeta, setCamposTarjeta] = useState({ numero_tarj: "", fecha_venci_tarj: "", cvv_tarj: "", nombre_titu_tarj: "", credito: false });
  const [camposCheque, setCamposCheque] = useState({ numero_cheque: "", numero_cuenta_cheque: "", fk_banc: 0, nombre_banco: "" });
  const [denominacionEfectivo, setDenominacionEfectivo] = useState("USD");
  const [puntosUsar, setPuntosUsar] = useState("");
  const [loading, setLoading] = useState(true);
  const [procesandoVenta, setProcesandoVenta] = useState(false);
  const TAM_PAGINA = 25;
  const [paginaActual, setPaginaActual] = useState(1);
  const { user } = useAuth();

  // Métodos de pago solo tarjeta para venta online
  const metodosPagoDisponibles: MetodoPagoCompleto[] = [
    { cod_meto_pago: 2, tipo: "Tarjeta", credito: true },
  ];

  // Cargar productos desde /api/disponibilidad
  useEffect(() => {
    const cargarProductos = async () => {
      try {
        setLoading(true);
        const response = await fetch("/api/disponibilidad");
        const productosData = await response.json();
        // Mapear a ProductoInventario, ignorando stock y lugar
        const productosMapeados = (productosData as any[]).map((item, idx) => ({
          ...item,
          fk_cerv_pres_1: item.fk_cerv_pres_1,
          fk_cerv_pres_2: item.fk_cerv_pres_2,
          fk_tien: 1,
          fk_luga_tien: 1,
          nombre_cerv: item.nombre_cerv,
          nombre_pres: item.nombre_pres,
          capacidad_pres: item.capacidad_pres,
          tipo_cerveza: item.tipo_cerveza,
          miembro_proveedor: item.miembro_proveedor,
          cant_pres: 0, // No mostrar stock
          precio_actual_pres: item.precio_actual_pres,
          lugar_tienda: '',
          estado: 'Disponible',
          _key: `${item.nombre_cerv}-${item.nombre_pres}-${idx}`
        }));
        setProductos(productosMapeados);
      } catch (error) {
        setProductos([]);
      } finally {
        setLoading(false);
      }
    };
    cargarProductos();
  }, []);

  // Cargar tasa y bancos
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
    getBancos().then(setBancos).catch(() => setBancos([]));
  }, []);

  // Calcular resumen de venta
  useEffect(() => {
    if (tasaActual && itemsVenta.length > 0) {
      const subtotal = itemsVenta.reduce((total, item) => total + item.subtotal, 0);
      const iva = subtotal * 0.16;
      const total = subtotal + iva;
      const totalBs = total * tasaActual.tasa_dolar_bcv;
      const puntosGenerados = Math.floor(totalBs);
      setResumenVenta({
        subtotal,
        iva,
        total,
        total_usd: total,
        total_bs: totalBs,
        tasa_actual: tasaActual.tasa_dolar_bcv,
        puntos_generados: puntosGenerados,
        fecha_venta: tasaActual.fecha_ini_tasa
      });
    } else {
      setResumenVenta(null);
    }
  }, [itemsVenta, tasaActual]);

  // Funciones para manejar productos
  const agregarProducto = (producto: any) => {
    const itemExistente = itemsVenta.find((item) => (item.producto as any)._key === (producto as any)._key);
    if (itemExistente) {
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
    } else {
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

  const agregarPago = () => {
    if (!metodoPagoSeleccionado || !montoPago || parseFloat(montoPago) <= 0) return;
    let montoBs = parseFloat(montoPago);
    // Solo un pago permitido
    if (pagos.length >= 1) return;
    // Solo tarjeta permitido
    if (metodoPagoSeleccionado.tipo !== 'Tarjeta') return;
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
    if (!resumenVenta || !tasaActual || pagos.length !== 1 || pagos[0].metodo_pago.tipo !== 'Tarjeta') {
      alert('Debes agregar un único pago con tarjeta.');
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
      } else {
        alert(`Error al procesar la venta: ${resultado.message}`);
      }
    } catch (error) {
      alert('Error inesperado al procesar la venta');
    } finally {
      setProcesandoVenta(false);
    }
  };

  return (
    <div>
      {/* En el render, en el selector de método de pago: */}
      <FormControl fullWidth sx={{ mb: 2 }} required>
        <InputLabel>Método de Pago</InputLabel>
        <Select
          value={metodoPagoSeleccionado?.cod_meto_pago || ""}
          onChange={(e) => {
            const metodo = metodosPagoDisponibles.find(m => m.cod_meto_pago === e.target.value)
            setMetodoPagoSeleccionado(metodo || null)
          }}
          label="Método de Pago"
        >
          {metodosPagoDisponibles.map((metodo) => (
            <MenuItem key={metodo.cod_meto_pago} value={metodo.cod_meto_pago}>
              Tarjeta
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {/* Botón para agregar pago: */}
      <Button
        onClick={agregarPago}
        disabled={pagos.length >= 1 || !metodoPagoSeleccionado || metodoPagoSeleccionado.tipo !== 'Tarjeta' || !montoPago || parseFloat(montoPago) <= 0}
      >
        Agregar Pago
      </Button>

      {/* Botón de finalizar compra: */}
      <Button
        fullWidth
        variant="contained"
        size="large"
        color="success"
        onClick={procesarVentaFinal}
        disabled={pagos.length !== 1 || pagos[0]?.metodo_pago.tipo !== 'Tarjeta' || procesandoVenta}
      >
        Finalizar Compra Online
      </Button>
    </div>
  );
};

export default PuntoVentaOnline; 