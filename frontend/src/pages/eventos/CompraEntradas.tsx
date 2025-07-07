import React, { useState, useEffect } from 'react';
import { getTasaActual, procesarVenta, procesarVentaEntrada } from '../../services/api';
import type { Evento, RegistroEvento } from '../../interfaces/eventos';
import type { DetalleEntrada, PagoVenta } from '../../interfaces/ventas';
import {
  Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, Select, MenuItem, FormControl, InputLabel,
  Button, Box, Typography, Grid, IconButton, CircularProgress, Radio, RadioGroup, FormControlLabel, Checkbox, Divider, Stack, Alert
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import { useAuth } from '../../contexts/AuthContext';

interface CompraEntradasProps {
  isOpen: boolean;
  onClose: () => void;
  evento: Evento | null;
}

interface FormData {
  fk_even: number;
  fk_juez?: number | null;
  fk_clie?: string | null;
  fk_miem?: string | null;
  cantidad_entradas: number;
}

const CompraEntradas: React.FC<CompraEntradasProps> = ({ isOpen, onClose, evento }) => {
  const { user } = useAuth();
  const [cantidad, setCantidad] = useState(1);
  const [tasa, setTasa] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [camposTarjeta, setCamposTarjeta] = useState({ numero_tarj: '', fecha_venci_tarj: '', cvv_tarj: '', nombre_titu_tarj: '', credito: false });
  const [resumen, setResumen] = useState<any>(null);
  const [procesando, setProcesando] = useState(false);
  const [mensajeExito, setMensajeExito] = useState<string | null>(null);

  useEffect(() => {
    if (isOpen && evento) {
      setCantidad(1);
      setCamposTarjeta({ numero_tarj: '', fecha_venci_tarj: '', cvv_tarj: '', nombre_titu_tarj: '', credito: false });
      setResumen(null);
      setProcesando(false);
      getTasaActual().then(t => setTasa(Array.isArray(t) ? t[0] : t));
    }
  }, [isOpen, evento]);

  useEffect(() => {
    if (evento && tasa) {
      const subtotal = (evento.precio_entrada_even || 0) * cantidad;
      const iva = subtotal * 0.16;
      const total = subtotal + iva;
      const totalBs = total * tasa.tasa_dolar_bcv;
      setResumen({ subtotal, iva, total, totalBs, tasa: tasa.tasa_dolar_bcv });
    }
  }, [cantidad, evento, tasa]);

  if (!isOpen || !evento) return null;
  if (!user || (!user.fk_clie && !user.fk_miem)) {
    return (
      <Dialog open={isOpen} onClose={onClose} maxWidth="sm" fullWidth>
        <DialogTitle>Comprar Entradas</DialogTitle>
        <DialogContent>
          <Typography>Debes iniciar sesión como cliente o miembro para comprar entradas.</Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>Cerrar</Button>
        </DialogActions>
      </Dialog>
    );
  }

  const handleCantidadChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    let val = Math.max(1, Math.min(Number(e.target.value), evento.cant_entradas_evento));
    setCantidad(val);
  };

  const handleTarjetaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setCamposTarjeta(prev => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
  };

  const handlePagar = async () => {
    if (!resumen || !tasa) return;
    if (!camposTarjeta.numero_tarj || !camposTarjeta.fecha_venci_tarj || !camposTarjeta.cvv_tarj || !camposTarjeta.nombre_titu_tarj) {
      alert('Completa todos los datos de la tarjeta');
      return;
    }
    setProcesando(true);
    setMensajeExito(null);
    try {
      const ventaEntradaData = {
        fecha_vent: new Date().toISOString().split('T')[0],
        iva_vent: resumen.iva,
        base_imponible_vent: resumen.subtotal,
        total_vent: resumen.total,
        online: true,
        fk_clie: user.fk_clie || '',
        fk_even: evento.cod_even,
        items: [{
          cant_deta_entr: cantidad,
          precio_unitario_entr: evento.precio_entrada_even || 0,
          fk_even: evento.cod_even
        } as Partial<DetalleEntrada>],
        pagos: [{
          metodo_pago: {
            cod_meto_pago: 2,
            tipo: 'Tarjeta',
            numero_tarj: Number(camposTarjeta.numero_tarj),
            fecha_venci_tarj: camposTarjeta.fecha_venci_tarj,
            cvv_tarj: Number(camposTarjeta.cvv_tarj),
            nombre_titu_tarj: camposTarjeta.nombre_titu_tarj,
            credito: camposTarjeta.credito
          },
          monto: resumen.totalBs,
          fecha_pago: new Date().toISOString().split('T')[0],
          fk_tasa: tasa.cod_tasa
        } as PagoVenta]
      };
      const resultado = await procesarVentaEntrada(ventaEntradaData);
      if (resultado.success && resultado.cod_vent) {
        setMensajeExito(`¡Compra realizada exitosamente! Código de venta: ${resultado.cod_vent}`);
        setTimeout(() => {
          setMensajeExito(null);
          onClose(); // El padre debe recargar eventos
        }, 2000);
      } else {
        alert('Error al procesar la compra: ' + (resultado.message || ''));
      }
    } catch (error) {
      alert('Error inesperado al procesar la compra');
    } finally {
      setProcesando(false);
    }
  };

  return (
    <Dialog open={isOpen} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        Comprar Entradas - {evento.nombre_even}
        <IconButton onClick={onClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <DialogContent dividers>
        <Stack spacing={2}>
          <Box>
            <Typography variant="subtitle1" gutterBottom>Información del Evento</Typography>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <Typography variant="body2"><b>Fecha:</b> {new Date(evento.fecha_hora_ini_even).toLocaleDateString()} <b>Hora:</b> {new Date(evento.fecha_hora_ini_even).toLocaleTimeString()}</Typography>
              <Typography variant="body2"><b>Dirección:</b> {evento.direccion_even}</Typography>
            </Stack>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <Typography variant="body2"><b>Precio:</b> ${evento.precio_entrada_even || 'Gratis'}</Typography>
              <Typography variant="body2"><b>Entradas disponibles:</b> {evento.cant_entradas_evento}</Typography>
            </Stack>
          </Box>
          <Divider />
          <TextField
            label="Cantidad de Entradas"
            type="number"
            value={cantidad}
            onChange={handleCantidadChange}
            inputProps={{ min: 1, max: evento.cant_entradas_evento }}
            fullWidth
          />
          <Divider />
          {resumen && (
            <Box>
              <Typography variant="subtitle2">Resumen de Compra</Typography>
              <Stack direction="row" spacing={2}>
                <Typography>Subtotal: <b>${resumen.subtotal.toFixed(2)}</b></Typography>
                <Typography>IVA (16%): <b>${resumen.iva.toFixed(2)}</b></Typography>
              </Stack>
              <Stack direction="row" spacing={2}>
                <Typography>Total: <b>${resumen.total.toFixed(2)}</b></Typography>
                <Typography>Total en Bs: <b>{resumen.totalBs.toFixed(2)}</b> (Tasa: {resumen.tasa})</Typography>
              </Stack>
            </Box>
          )}
          <Divider />
          <Box>
            <Typography variant="subtitle2">Pago con Tarjeta</Typography>
            <Stack spacing={1}>
              <TextField label="Número de Tarjeta" name="numero_tarj" value={camposTarjeta.numero_tarj} onChange={handleTarjetaChange} fullWidth />
              <TextField label="Fecha de Vencimiento" name="fecha_venci_tarj" value={camposTarjeta.fecha_venci_tarj} onChange={handleTarjetaChange} fullWidth />
              <TextField label="CVV" name="cvv_tarj" value={camposTarjeta.cvv_tarj} onChange={handleTarjetaChange} fullWidth />
              <TextField label="Nombre del Titular" name="nombre_titu_tarj" value={camposTarjeta.nombre_titu_tarj} onChange={handleTarjetaChange} fullWidth />
              <FormControlLabel control={<Checkbox name="credito" checked={camposTarjeta.credito} onChange={handleTarjetaChange} />} label="¿Es tarjeta de crédito?" />
            </Stack>
          </Box>
          {mensajeExito && <Alert severity="success">{mensajeExito}</Alert>}
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="secondary">Cancelar</Button>
        <Button onClick={handlePagar} color="primary" variant="contained" disabled={procesando || cantidad < 1 || cantidad > evento.cant_entradas_evento}>
          {procesando ? 'Procesando...' : 'Pagar'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default CompraEntradas; 