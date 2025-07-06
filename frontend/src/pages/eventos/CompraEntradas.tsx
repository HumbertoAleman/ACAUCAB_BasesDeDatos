import React, { useState, useEffect } from 'react';
import { getClientesDetallados, getEmpleados, getMiembros, createRegistroEvento } from '../../services/api';
import type { Evento, RegistroEvento } from '../../interfaces/eventos';
import type { ClienteDetallado } from '../../interfaces/ventas';
import type { Miembro } from '../../interfaces/miembros';
import {
  Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, Select, MenuItem, FormControl, InputLabel,
  Button, Box, Typography, Grid, IconButton, CircularProgress, Radio, RadioGroup, FormControlLabel
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';

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
  const [formData, setFormData] = useState<FormData>({
    fk_even: 0,
    fk_juez: null,
    fk_clie: null,
    fk_miem: null,
    cantidad_entradas: 1
  });

  const [clientes, setClientes] = useState<ClienteDetallado[]>([]);
  const [empleados, setEmpleados] = useState<any[]>([]);
  const [miembros, setMiembros] = useState<Miembro[]>([]);
  const [loading, setLoading] = useState(false);
  const [tipoParticipante, setTipoParticipante] = useState<'cliente' | 'empleado' | 'miembro'>('cliente');

  useEffect(() => {
    if (isOpen && evento) {
      setFormData(prev => ({ ...prev, fk_even: evento.cod_even }));
      loadData();
    }
  }, [isOpen, evento]);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Cargar clientes
      const clientes = await getClientesDetallados();
      setClientes(clientes);

      // Cargar empleados
      const empleados = await getEmpleados();
      setEmpleados(empleados);

      // Cargar miembros
      const miembros = await getMiembros();
      setMiembros(miembros);
    } catch (error) {
      console.error('Error cargando datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    if (name === 'cantidad_entradas') {
      setFormData(prev => ({ ...prev, cantidad_entradas: Number(value) }));
    } else if (name === 'fk_juez') {
      setFormData(prev => ({ ...prev, fk_juez: value ? Number(value) : null }));
    } else if (name === 'fk_clie') {
      setFormData(prev => ({ ...prev, fk_clie: value || null }));
    } else if (name === 'fk_miem') {
      setFormData(prev => ({ ...prev, fk_miem: value || null }));
    }
  };

  const handleTipoParticipanteChange = (tipo: 'cliente' | 'empleado' | 'miembro') => {
    setTipoParticipante(tipo);
    setFormData(prev => ({
      ...prev,
      fk_juez: null,
      fk_clie: null,
      fk_miem: null
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!evento) {
      alert('No hay evento seleccionado');
      return;
    }

    if (formData.cantidad_entradas <= 0) {
      alert('La cantidad de entradas debe ser mayor a 0');
      return;
    }

    if (formData.cantidad_entradas > evento.cant_entradas_evento) {
      alert(`Solo hay ${evento.cant_entradas_evento} entradas disponibles`);
      return;
    }

    // Validar que se haya seleccionado un participante
    const participanteSeleccionado = 
      (tipoParticipante === 'cliente' && formData.fk_clie) ||
      (tipoParticipante === 'empleado' && formData.fk_juez) ||
      (tipoParticipante === 'miembro' && formData.fk_miem);

    if (!participanteSeleccionado) {
      alert('Debe seleccionar un participante');
      return;
    }

    try {
      setLoading(true);
      
      const registroData: RegistroEvento = {
        cod_regi_even: 0, // Se genera automáticamente
        fk_even: evento.cod_even,
        fk_juez: tipoParticipante === 'empleado' ? formData.fk_juez || null : null,
        fk_clie: tipoParticipante === 'cliente' ? formData.fk_clie || null : null,
        fk_miem: tipoParticipante === 'miembro' ? formData.fk_miem || null : null,
        fecha_hora_regi_even: new Date().toISOString()
      };

      const response = await createRegistroEvento(registroData);

      if (response) {
        alert('Entrada registrada exitosamente');
        onClose();
      } else {
        alert('Error al registrar la entrada');
      }
    } catch (error) {
      console.error('Error registrando entrada:', error);
      alert('Error al registrar la entrada');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setFormData({
      fk_even: 0,
      fk_juez: null,
      fk_clie: null,
      fk_miem: null,
      cantidad_entradas: 1
    });
    setTipoParticipante('cliente');
    onClose();
  };

  if (!isOpen || !evento) return null;

  return (
    <Dialog open={isOpen} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography variant="h5">Comprar Entradas - {evento.nombre_even}</Typography>
        <IconButton onClick={handleClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <DialogContent dividers>
        <Box sx={{ mb: 2 }}>
          <Typography variant="subtitle1" gutterBottom>Información del Evento</Typography>
          <Grid container spacing={2}>
            <Grid item xs={6}><Typography variant="body2"><b>Fecha:</b> {new Date(evento.fecha_hora_ini_even).toLocaleDateString()}</Typography></Grid>
            <Grid item xs={6}><Typography variant="body2"><b>Hora:</b> {new Date(evento.fecha_hora_ini_even).toLocaleTimeString()}</Typography></Grid>
            <Grid item xs={12}><Typography variant="body2"><b>Dirección:</b> {evento.direccion_even}</Typography></Grid>
            <Grid item xs={6}><Typography variant="body2"><b>Precio:</b> ${evento.precio_entrada_even || 'Gratis'}</Typography></Grid>
            <Grid item xs={6}><Typography variant="body2"><b>Entradas disponibles:</b> {evento.cant_entradas_evento}</Typography></Grid>
          </Grid>
        </Box>
        <Box component="form" onSubmit={handleSubmit}>
          <FormControl component="fieldset" sx={{ mb: 2 }}>
            <Typography variant="subtitle2">Tipo de Participante *</Typography>
            <RadioGroup row value={tipoParticipante} onChange={e => handleTipoParticipanteChange(e.target.value as any)}>
              <FormControlLabel value="cliente" control={<Radio />} label="Cliente" />
              <FormControlLabel value="empleado" control={<Radio />} label="Empleado/Juez" />
              <FormControlLabel value="miembro" control={<Radio />} label="Miembro" />
            </RadioGroup>
          </FormControl>
          <FormControl fullWidth required sx={{ mb: 2 }}>
            <InputLabel>{`Seleccionar ${tipoParticipante === 'cliente' ? 'Cliente' : tipoParticipante === 'empleado' ? 'Empleado/Juez' : 'Miembro'}`}</InputLabel>
            <Select
              name={tipoParticipante === 'cliente' ? 'fk_clie' : tipoParticipante === 'empleado' ? 'fk_juez' : 'fk_miem'}
              value={tipoParticipante === 'cliente' ? formData.fk_clie || '' : tipoParticipante === 'empleado' ? formData.fk_juez || '' : formData.fk_miem || ''}
              onChange={handleInputChange}
              label={`Seleccionar ${tipoParticipante === 'cliente' ? 'Cliente' : tipoParticipante === 'empleado' ? 'Empleado/Juez' : 'Miembro'}`}
            >
              <MenuItem value="">Seleccione un {tipoParticipante}</MenuItem>
              {tipoParticipante === 'cliente' && clientes.map(cliente => (
                <MenuItem key={cliente.rif_clie} value={cliente.rif_clie}>
                  {cliente.tipo_clie === 'Natural' 
                    ? `${cliente.primer_nom_natu || ''} ${cliente.primer_ape_natu || ''}`.trim()
                    : cliente.razon_social_juri || ''
                  } - {cliente.rif_clie}
                </MenuItem>
              ))}
              {tipoParticipante === 'empleado' && empleados.map(empleado => (
                <MenuItem key={empleado.cod_empl} value={empleado.cod_empl}>
                  {empleado.primer_nom_empl} {empleado.primer_ape_empl} - CI: {empleado.ci_empl}
                </MenuItem>
              ))}
              {tipoParticipante === 'miembro' && miembros.map(miembro => (
                <MenuItem key={miembro.rif_miem} value={miembro.rif_miem}>
                  {miembro.razon_social_miem} - {miembro.rif_miem}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <TextField
            fullWidth
            required
            label="Cantidad de Entradas"
            name="cantidad_entradas"
            type="number"
            value={formData.cantidad_entradas}
            onChange={handleInputChange}
            inputProps={{ min: 1, max: evento.cant_entradas_evento }}
            sx={{ mb: 2 }}
          />
          {evento.precio_entrada_even && evento.precio_entrada_even > 0 && (
            <Box sx={{ background: '#e3f2fd', p: 2, borderRadius: 2, mb: 2 }}>
              <Typography variant="subtitle2">Resumen del Costo</Typography>
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>Precio por entrada:</span>
                <span>${evento.precio_entrada_even}</span>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>Cantidad:</span>
                <span>{formData.cantidad_entradas}</span>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', fontWeight: 600, mt: 1 }}>
                <span>Total:</span>
                <span>${(evento.precio_entrada_even * formData.cantidad_entradas).toFixed(2)}</span>
              </Box>
              <Typography variant="caption" color="primary" sx={{ mt: 1 }}>* Los pagos se manejan por separado en el módulo de ventas</Typography>
            </Box>
          )}
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} color="secondary">Cancelar</Button>
        <Button type="submit" variant="contained" onClick={handleSubmit} disabled={loading}>
          {loading ? <CircularProgress size={24} /> : 'Registrar Entrada'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default CompraEntradas; 