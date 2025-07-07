import React, { useState, useEffect } from 'react';
import { getTiposEvento, getLugares, getEventos, createEvento, createEventoRecursivo, getJueces, createRegistroEvento, createJuez } from '../../services/api';
import type { Evento, TipoEvento, Juez } from '../../interfaces/eventos';
import type { Lugar } from '../../interfaces/common';
import {
  Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, Select, MenuItem, FormControl, InputLabel,
  Button, Box, Typography, Stack, IconButton, Checkbox, CircularProgress, FormControlLabel
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import type { SelectChangeEvent } from '@mui/material/Select';

interface RegistroEventoProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface FormData {
  nombre_even: string;
  fecha_hora_ini_even: string;
  fecha_hora_fin_even: string;
  direccion_even: string;
  capacidad_even: number;
  descripcion_even: string;
  precio_entrada_even: number;
  cant_entradas_evento: number;
  fk_tipo_even: number;
  fk_luga: number;
  fk_even?: number; // Para eventos recursivos
}

interface RegistroEventoData {
  fk_even: number;
  fk_juez?: number;
  fk_clie?: string;
  fk_miem?: string;
  fecha_hora_regi_even: string;
}

// Utilidad para formatear fecha a yyyy-MM-ddTHH:mm para input type="datetime-local"
function toDatetimeLocal(dateString: string) {
  if (!dateString) return '';
  const date = new Date(dateString);
  const offset = date.getTimezoneOffset();
  const localDate = new Date(date.getTime() - offset * 60 * 1000);
  return localDate.toISOString().slice(0, 16); // yyyy-MM-ddTHH:mm
}

const RegistroEvento: React.FC<RegistroEventoProps> = ({ isOpen, onClose, onSuccess }) => {
  const [formData, setFormData] = useState<FormData>({
    nombre_even: '',
    fecha_hora_ini_even: '',
    fecha_hora_fin_even: '',
    direccion_even: '',
    capacidad_even: 0,
    descripcion_even: '',
    precio_entrada_even: 0,
    cant_entradas_evento: 0,
    fk_tipo_even: 0,
    fk_luga: 0
  });

  const [tiposEvento, setTiposEvento] = useState<TipoEvento[]>([]);
  const [lugares, setLugares] = useState<Lugar[]>([]);
  const [eventos, setEventos] = useState<Evento[]>([]);
  const [jueces, setJueces] = useState<Juez[]>([]);
  const [selectedJueces, setSelectedJueces] = useState<number[]>([]);
  const [loading, setLoading] = useState(false);
  const [isRecursive, setIsRecursive] = useState(false);
  const [openJuezModal, setOpenJuezModal] = useState(false);
  const [nuevoJuez, setNuevoJuez] = useState({
    primar_nom_juez: '',
    segundo_nom_juez: '',
    primar_ape_juez: '',
    segundo_ape_juez: '',
    ci_juez: ''
  });
  const [juezLoading, setJuezLoading] = useState(false);

  useEffect(() => {
    if (isOpen) {
      loadData();
    }
  }, [isOpen]);

  useEffect(() => {
    if (isRecursive && formData.fk_even) {
      const padre = eventos.find(e => e.cod_even === formData.fk_even);
      if (padre) {
        setFormData(prev => ({
          ...prev,
          direccion_even: padre.direccion_even || '',
          fecha_hora_ini_even: toDatetimeLocal(padre.fecha_hora_ini_even),
          fecha_hora_fin_even: toDatetimeLocal(padre.fecha_hora_fin_even),
          capacidad_even: padre.capacidad_even ?? 0,
          descripcion_even: padre.descripcion_even || '',
          precio_entrada_even: padre.precio_entrada_even ?? 0,
          cant_entradas_evento: padre.cant_entradas_evento ?? 0,
          fk_tipo_even: padre.fk_tipo_even ?? 0,
          fk_luga: padre.fk_luga ?? 0
        }));
      }
    }
    if (!isRecursive) {
      setFormData(prev => ({
        ...prev,
        fk_even: undefined,
        direccion_even: '',
        fecha_hora_ini_even: '',
        fecha_hora_fin_even: '',
        capacidad_even: 0,
        descripcion_even: '',
        precio_entrada_even: 0,
        cant_entradas_evento: 0,
        fk_tipo_even: 0,
        fk_luga: 0
      }));
    }
  // eslint-disable-next-line
  }, [isRecursive, formData.fk_even]);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Cargar tipos de evento
      const tipos = await getTiposEvento();
      setTiposEvento(tipos);

      // Cargar lugares (parroquias)
      const lugares = await getLugares();
      setLugares(lugares);

      // Cargar eventos existentes para recursividad
      const eventos = await getEventos();
      setEventos(eventos);

      // Cargar jueces disponibles
      const jueces = await getJueces();
      setJueces(jueces);
    } catch (error) {
      console.error('Error cargando datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    if (["fk_even", "fk_tipo_even", "fk_luga"].includes(name)) {
      setFormData(prev => ({
        ...prev,
        [name]: value === '' ? 0 : Number(value)
      }));
    } else {
      setFormData(prev => ({
        ...prev,
        [name]: name.includes('precio') || name.includes('capacidad') || name.includes('cant_entradas')
          ? Number(value)
          : value
      }));
    }
  };

  const handleSelectChange = (e: SelectChangeEvent<string>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value === '' ? 0 : Number(value)
    }));
  };

  const handleJuezSelection = (juezId: number) => {
    setSelectedJueces(prev => {
      if (prev.includes(juezId)) {
        return prev.filter(id => id !== juezId);
      } else {
        return [...prev, juezId];
      }
    });
  };

  const handleNuevoJuezChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setNuevoJuez(prev => ({ ...prev, [name]: value }));
  };

  const handleCrearJuez = async (e: React.FormEvent) => {
    e.preventDefault();
    setJuezLoading(true);
    const juezData = {
      primar_nom_juez: nuevoJuez.primar_nom_juez,
      segundo_nom_juez: nuevoJuez.segundo_nom_juez || null,
      primar_ape_juez: nuevoJuez.primar_ape_juez,
      segundo_ape_juez: nuevoJuez.segundo_ape_juez || null,
      ci_juez: Number(nuevoJuez.ci_juez)
    };
    const res = await createJuez(juezData);
    setJuezLoading(false);
    if (res && res[0]) {
      await loadData();
      setSelectedJueces(prev => [...prev, res[0].cod_juez]);
      setOpenJuezModal(false);
      setNuevoJuez({ primar_nom_juez: '', segundo_nom_juez: '', primar_ape_juez: '', segundo_ape_juez: '', ci_juez: '' });
    } else {
      alert('Error al crear juez');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.nombre_even || !formData.fecha_hora_ini_even || !formData.fecha_hora_fin_even) {
      alert('Por favor complete todos los campos obligatorios');
      return;
    }

    if (new Date(formData.fecha_hora_ini_even) >= new Date(formData.fecha_hora_fin_even)) {
      alert('La fecha de inicio debe ser anterior a la fecha de fin');
      return;
    }

    try {
      setLoading(true);
      
      let eventoResponse;
      if (isRecursive && formData.fk_even) {
        eventoResponse = await createEventoRecursivo(formData.fk_even, formData);
      } else {
        eventoResponse = await createEvento(formData);
      }

      if (eventoResponse && eventoResponse.length > 0) {
        const nuevoEvento = eventoResponse[0];
        
        // Registrar jueces para el evento
        if (selectedJueces.length > 0) {
          for (const juezId of selectedJueces) {
            const registroData: RegistroEventoData = {
              fk_even: nuevoEvento.cod_even,
              fk_juez: juezId,
              fecha_hora_regi_even: formData.fecha_hora_ini_even
            };
            
            await createRegistroEvento(registroData);
          }
        }

        alert('Evento registrado exitosamente con los jueces seleccionados');
        onSuccess();
        handleClose();
      } else {
        alert('Error al registrar el evento');
      }
    } catch (error) {
      console.error('Error registrando evento:', error);
      alert('Error al registrar el evento');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setFormData({
      nombre_even: '',
      fecha_hora_ini_even: '',
      fecha_hora_fin_even: '',
      direccion_even: '',
      capacidad_even: 0,
      descripcion_even: '',
      precio_entrada_even: 0,
      cant_entradas_evento: 0,
      fk_tipo_even: 0,
      fk_luga: 0
    });
    setSelectedJueces([]);
    setIsRecursive(false);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <Dialog open={isOpen} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography variant="h6" component="span">{isRecursive ? 'Registrar Evento Recursivo' : 'Registrar Nuevo Evento'}</Typography>
        <IconButton onClick={handleClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <DialogContent dividers>
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1 }}>
          <Stack spacing={2}>
            <FormControlLabel
              control={<Checkbox checked={isRecursive} onChange={e => setIsRecursive(e.target.checked)} />}
              label="Evento recursivo (basado en otro evento)"
            />
            {isRecursive && (
              <FormControl fullWidth required>
                <InputLabel>Evento Padre</InputLabel>
                <Select name="fk_even" value={String(formData.fk_even || '')} onChange={handleSelectChange} label="Evento Padre">
                  <MenuItem value="">Seleccione un evento</MenuItem>
                  {eventos.map(evento => (
                    <MenuItem key={evento.cod_even} value={String(evento.cod_even)}>{evento.nombre_even}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            )}
            <TextField fullWidth required label="Nombre del Evento" name="nombre_even" value={formData.nombre_even} onChange={handleInputChange} />
            <TextField fullWidth required label="Dirección" name="direccion_even" value={formData.direccion_even} onChange={handleInputChange} disabled={isRecursive} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField fullWidth required label="Fecha y Hora de Inicio" name="fecha_hora_ini_even" type="datetime-local" value={formData.fecha_hora_ini_even} onChange={handleInputChange} InputLabelProps={{ shrink: true }} disabled={isRecursive} />
              <TextField fullWidth required label="Fecha y Hora de Fin" name="fecha_hora_fin_even" type="datetime-local" value={formData.fecha_hora_fin_even} onChange={handleInputChange} InputLabelProps={{ shrink: true }} disabled={isRecursive} />
            </Stack>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField fullWidth required label="Capacidad" name="capacidad_even" type="number" value={formData.capacidad_even} onChange={handleInputChange} inputProps={{ min: 1 }} disabled={isRecursive} />
              <TextField fullWidth required label="Cantidad de Entradas" name="cant_entradas_evento" type="number" value={formData.cant_entradas_evento} onChange={handleInputChange} inputProps={{ min: 1 }} disabled={isRecursive} />
              <TextField fullWidth label="Precio de Entrada (USD)" name="precio_entrada_even" type="number" value={formData.precio_entrada_even} onChange={handleInputChange} inputProps={{ min: 0, step: 0.01 }} disabled={isRecursive} />
            </Stack>
            <TextField fullWidth required label="Descripción" name="descripcion_even" value={formData.descripcion_even} onChange={handleInputChange} multiline rows={3} disabled={isRecursive} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <FormControl fullWidth required disabled={isRecursive}>
                <InputLabel>Tipo de Evento</InputLabel>
                <Select name="fk_tipo_even" value={String(formData.fk_tipo_even || '')} onChange={handleSelectChange} label="Tipo de Evento">
                  <MenuItem value="">Seleccione un tipo</MenuItem>
                  {tiposEvento.map(tipo => (
                    <MenuItem key={tipo.cod_tipo_even} value={String(tipo.cod_tipo_even)}>{tipo.nombre_tipo_even}</MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth required disabled={isRecursive}>
                <InputLabel>Lugar (Parroquia)</InputLabel>
                <Select name="fk_luga" value={String(formData.fk_luga || '')} onChange={handleSelectChange} label="Lugar (Parroquia)">
                  <MenuItem value="">Seleccione un lugar</MenuItem>
                  {lugares.map(lugar => (
                    <MenuItem key={lugar.cod_luga} value={String(lugar.cod_luga)}>{lugar.nombre_luga}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Stack>
            {/* Selección de jueces */}
            <Box>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                <Typography variant="subtitle1" sx={{ flexGrow: 1 }}>Jueces del Evento (Opcional)</Typography>
                <Button variant="outlined" size="small" onClick={() => setOpenJuezModal(true)}>Agregar Juez</Button>
              </Box>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                {jueces.map(juez => (
                  <FormControlLabel
                    key={juez.cod_juez}
                    control={<Checkbox checked={selectedJueces.includes(juez.cod_juez)} onChange={() => handleJuezSelection(juez.cod_juez)} />}
                    label={`${juez.primar_nom_juez} ${juez.primar_ape_juez} (CI: ${juez.ci_juez})`}
                  />
                ))}
              </Box>
            </Box>
          </Stack>
        </Box>
        {/* Submodal para crear juez */}
        <Dialog open={openJuezModal} onClose={() => setOpenJuezModal(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Registrar Juez</DialogTitle>
          <DialogContent dividers>
            <Box component="form" onSubmit={handleCrearJuez} sx={{ mt: 1 }}>
              <Stack spacing={2}>
                <TextField fullWidth required label="Primer Nombre" name="primar_nom_juez" value={nuevoJuez.primar_nom_juez} onChange={handleNuevoJuezChange} />
                <TextField fullWidth label="Segundo Nombre" name="segundo_nom_juez" value={nuevoJuez.segundo_nom_juez} onChange={handleNuevoJuezChange} />
                <TextField fullWidth required label="Primer Apellido" name="primar_ape_juez" value={nuevoJuez.primar_ape_juez} onChange={handleNuevoJuezChange} />
                <TextField fullWidth label="Segundo Apellido" name="segundo_ape_juez" value={nuevoJuez.segundo_ape_juez} onChange={handleNuevoJuezChange} />
                <TextField fullWidth required label="Cédula" name="ci_juez" value={nuevoJuez.ci_juez} onChange={handleNuevoJuezChange} type="number" inputProps={{ min: 1 }} />
              </Stack>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenJuezModal(false)} color="secondary">Cancelar</Button>
            <Button type="submit" variant="contained" onClick={handleCrearJuez} disabled={juezLoading}>
              {juezLoading ? <CircularProgress size={24} /> : 'Registrar Juez'}
            </Button>
          </DialogActions>
        </Dialog>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} color="secondary">Cancelar</Button>
        <Button type="submit" variant="contained" onClick={handleSubmit} disabled={loading}>
          {loading ? <CircularProgress size={24} /> : 'Registrar Evento'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default RegistroEvento; 