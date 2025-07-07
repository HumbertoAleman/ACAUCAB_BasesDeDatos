import React, { useState, useEffect } from 'react';
import { getTiposEvento, getLugares, createEvento, getJueces, createJuez, createTipoEvento, updateTipoEvento, addJuecesEvento } from '../../services/api';
import type { Evento, TipoEvento, Juez } from '../../interfaces/eventos';
import type { Lugar } from '../../interfaces/common';
import {
  Dialog, DialogTitle, DialogContent, DialogActions,
  TextField, Select, MenuItem, FormControl, InputLabel,
  Button, Box, Typography, Stack, IconButton, Checkbox, CircularProgress, FormControlLabel, List, ListItem, ListItemText, ListSubheader
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

// Componente para mostrar la jerarquía de tipos de evento
const TipoEventoTree: React.FC<{ tipos: TipoEvento[], rootId?: number | null }> = ({ tipos, rootId }) => {
  const buildTree = (parentId: number | null) => {
    return tipos
      .filter(tipo => (tipo.fk_tipo_even ?? null) === parentId)
      .map(tipo => (
        <li key={tipo.cod_tipo_even}>
          {tipo.nombre_tipo_even}
          <ul>{buildTree(tipo.cod_tipo_even)}</ul>
        </li>
      ));
  };
  if (rootId) {
    const root = tipos.find(t => t.cod_tipo_even === rootId);
    if (!root) return null;
    return <ul><li>{root.nombre_tipo_even}<ul>{buildTree(root.cod_tipo_even)}</ul></li></ul>;
  }
  return null;
};

// Función para obtener todos los descendientes de un tipo de evento
function getDescendants(tipos: TipoEvento[], parentId: number): number[] {
  const directChildren = tipos.filter(t => t.fk_tipo_even === parentId).map(t => t.cod_tipo_even);
  return directChildren.reduce((acc, childId) => (
    acc.concat(childId, getDescendants(tipos, childId))
  ), [] as number[]);
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
  const [openJuezModal, setOpenJuezModal] = useState(false);
  const [nuevoJuez, setNuevoJuez] = useState({
    primar_nom_juez: '',
    segundo_nom_juez: '',
    primar_ape_juez: '',
    segundo_ape_juez: '',
    ci_juez: ''
  });
  const [juezLoading, setJuezLoading] = useState(false);
  const [openTipoEventoModal, setOpenTipoEventoModal] = useState(false);
  const [nuevoTipoEvento, setNuevoTipoEvento] = useState({ nombre_tipo_even: '', fk_tipo_even: null });
  const [tipoEventoLoading, setTipoEventoLoading] = useState(false);
  const [selectedTipoPadre, setSelectedTipoPadre] = useState<number | null>(null);
  const [selectedHijos, setSelectedHijos] = useState<number[]>([]);
  const [gestionandoTipos, setGestionandoTipos] = useState(false);
  const [mostrarJerarquia, setMostrarJerarquia] = useState(false);
  const [mostrarJueces, setMostrarJueces] = useState(false);

  useEffect(() => {
    if (isOpen) {
      loadData();
    }
  }, [isOpen]);

  useEffect(() => {
    if (gestionandoTipos && selectedTipoPadre) {
      setSelectedHijos(
        tiposEvento.filter(tipo => tipo.fk_tipo_even === selectedTipoPadre).map(tipo => tipo.cod_tipo_even)
      );
    }
    if (!gestionandoTipos) {
      setSelectedHijos([]);
    }
  }, [gestionandoTipos, selectedTipoPadre, tiposEvento]);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Cargar tipos de evento
      const tipos = await getTiposEvento();
      setTiposEvento(tipos);

      // Cargar lugares (parroquias)
      const lugares = await getLugares();
      setLugares(lugares);

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
    if (["fk_tipo_even", "fk_luga"].includes(name)) {
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

  const handleNuevoTipoEventoInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setNuevoTipoEvento(prev => ({ ...prev, [name]: value }));
  };

  const handleNuevoTipoEventoSelectChange = (e: SelectChangeEvent<string>) => {
    const name = e.target.name as string;
    const value = e.target.value;
    setNuevoTipoEvento(prev => ({ ...prev, [name]: value === '' ? null : Number(value) }));
  };

  const handleCrearTipoEvento = async (e: React.FormEvent) => {
    e.preventDefault();
    setTipoEventoLoading(true);
    try {
      const res = await createTipoEvento(nuevoTipoEvento);
      if (res && res.data && res.data[0]) {
        await loadData();
        setOpenTipoEventoModal(false);
        setNuevoTipoEvento({ nombre_tipo_even: '', fk_tipo_even: null });
      } else {
        alert('Error al crear tipo de evento');
      }
    } catch (error) {
      alert('Error al crear tipo de evento');
    } finally {
      setTipoEventoLoading(false);
    }
  };

  const handleGestionarTipos = () => setGestionandoTipos(true);
  const handleCerrarGestion = () => {
    setGestionandoTipos(false);
    setSelectedTipoPadre(null);
    setSelectedHijos([]);
  };
  const handleSeleccionarPadre = (e: SelectChangeEvent<string>) => {
    setSelectedTipoPadre(e.target.value === '' ? null : Number(e.target.value));
  };
  const handleSeleccionarHijo = (id: number) => {
    setSelectedHijos(prev => prev.includes(id) ? prev.filter(h => h !== id) : [...prev, id]);
  };
  const handleGuardarJerarquia = async () => {
    if (!selectedTipoPadre) return;
    // Para cada tipo de evento (excepto el padre), ver si debe asignarse o desasignarse
    for (const tipo of tiposEvento) {
      if (tipo.cod_tipo_even === selectedTipoPadre) continue;
      const debeSerHijo = selectedHijos.includes(tipo.cod_tipo_even);
      const esHijo = tipo.fk_tipo_even === selectedTipoPadre;
      if (debeSerHijo && !esHijo) {
        // Asignar padre
        await updateTipoEvento(tipo.cod_tipo_even, { fk_tipo_even: selectedTipoPadre });
      } else if (!debeSerHijo && esHijo) {
        // Desasignar padre
        await updateTipoEvento(tipo.cod_tipo_even, { fk_tipo_even: null });
      }
    }
    await loadData();
    handleCerrarGestion();
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
      const eventoResponse = await createEvento(formData);
      if (eventoResponse && eventoResponse.length > 0) {
        const nuevoEvento = eventoResponse[0];
        if (selectedJueces.length > 0) {
          await addJuecesEvento(nuevoEvento.cod_even, selectedJueces, formData.fecha_hora_ini_even);
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
    onClose();
  };

  if (!isOpen) return null;

  // Calcular tipos de evento que son padres (tienen hijos)
  const tiposPadre = tiposEvento.filter(padre => tiposEvento.some(hijo => hijo.fk_tipo_even === padre.cod_tipo_even)).map(t => t.cod_tipo_even);

  // En el selector de tipo de evento, mostrar solo el tipo seleccionado y sus descendientes
  const tipoEventoOptions = formData.fk_tipo_even
    ? [
        tiposEvento.find(t => t.cod_tipo_even === formData.fk_tipo_even),
        ...getDescendants(tiposEvento, formData.fk_tipo_even).map(id => tiposEvento.find(t => t.cod_tipo_even === id))
      ].filter(Boolean)
    : tiposEvento.filter(t => !t.fk_tipo_even); // Si no hay seleccionado, mostrar raíces

  return (
    <Dialog open={isOpen} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography variant="h6" component="span">Registrar Nuevo Evento</Typography>
        <IconButton onClick={handleClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <DialogContent dividers>
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1 }}>
          <Stack spacing={2}>
            <TextField fullWidth required label="Nombre del Evento" name="nombre_even" value={formData.nombre_even} onChange={handleInputChange} />
            <TextField fullWidth required label="Dirección" name="direccion_even" value={formData.direccion_even} onChange={handleInputChange} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField fullWidth required label="Fecha y Hora de Inicio" name="fecha_hora_ini_even" type="datetime-local" value={formData.fecha_hora_ini_even} onChange={handleInputChange} InputLabelProps={{ shrink: true }} />
              <TextField fullWidth required label="Fecha y Hora de Fin" name="fecha_hora_fin_even" type="datetime-local" value={formData.fecha_hora_fin_even} onChange={handleInputChange} InputLabelProps={{ shrink: true }} />
            </Stack>
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <TextField fullWidth required label="Capacidad" name="capacidad_even" type="number" value={formData.capacidad_even} onChange={handleInputChange} inputProps={{ min: 1 }} />
              <TextField fullWidth required label="Cantidad de Entradas" name="cant_entradas_evento" type="number" value={formData.cant_entradas_evento} onChange={handleInputChange} inputProps={{ min: 1 }} />
              <TextField fullWidth label="Precio de Entrada (USD)" name="precio_entrada_even" type="number" value={formData.precio_entrada_even} onChange={handleInputChange} inputProps={{ min: 0, step: 0.01 }} />
            </Stack>
            <TextField fullWidth required label="Descripción" name="descripcion_even" value={formData.descripcion_even} onChange={handleInputChange} multiline rows={3} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
              <FormControl fullWidth required sx={{ mb: 2 }}>
                <InputLabel>Lugar (Parroquia)</InputLabel>
                <Select name="fk_luga" value={String(formData.fk_luga || '')} onChange={handleInputChange} label="Lugar (Parroquia)">
                  <MenuItem value="">Seleccione un lugar</MenuItem>
                  {lugares.map(lugar => (
                    <MenuItem key={lugar.cod_luga} value={String(lugar.cod_luga)}>{lugar.nombre_luga}</MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl fullWidth required sx={{ mb: 2 }}>
                <InputLabel>Tipo de Evento</InputLabel>
                <Select name="fk_tipo_even" value={String(formData.fk_tipo_even || '')} onChange={handleInputChange} label="Tipo de Evento">
                  <MenuItem value="">Seleccione un tipo</MenuItem>
                  {tipoEventoOptions.map(tipo => (
                    <MenuItem key={tipo.cod_tipo_even} value={String(tipo.cod_tipo_even)}>{tipo.nombre_tipo_even}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Stack>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
              <Box sx={{ flex: 1, pr: 1 }}>
                <Button fullWidth variant="outlined" size="small" onClick={() => setOpenTipoEventoModal(true)}>
                  Agregar Tipo de Evento
                </Button>
              </Box>
              <Box sx={{ flex: 1, pl: 1 }}>
                <Button fullWidth variant="outlined" size="small" onClick={handleGestionarTipos}>
                  Gestionar Jerarquía de Tipos de Evento
                </Button>
              </Box>
            </Box>
            <Box sx={{ mb: 2 }}>
              <Button fullWidth variant="text" size="small" onClick={() => setMostrarJerarquia(v => !v)}>
                {mostrarJerarquia ? 'Ocultar Jerarquía de Tipos de Evento' : 'Mostrar Jerarquía de Tipos de Evento'}
              </Button>
              {mostrarJerarquia && (
                <Box sx={{ mt: 1 }}>
                  <Typography variant="subtitle2">Jerarquía de Tipos de Evento:</Typography>
                  {formData.fk_tipo_even ? (
                    <TipoEventoTree tipos={tiposEvento} rootId={formData.fk_tipo_even} />
                  ) : (
                    <Typography variant="body2">Seleccione un tipo de evento para ver su jerarquía.</Typography>
                  )}
                </Box>
              )}
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
              <Box sx={{ flex: 1 }}>
                <Typography variant="subtitle1">Jueces del Evento (Opcional)</Typography>
              </Box>
              <Box sx={{ flex: 1, display: 'flex', justifyContent: 'flex-end' }}>
                <Button variant="outlined" size="small" onClick={() => setOpenJuezModal(true)}>
                  Agregar Juez
                </Button>
              </Box>
            </Box>
            <Box sx={{ mb: 2 }}>
              <Button fullWidth variant="text" size="small" onClick={() => setMostrarJueces(v => !v)}>
                {mostrarJueces ? 'Ocultar Jueces' : 'Mostrar Jueces'}
              </Button>
              {mostrarJueces && (
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mt: 1 }}>
                  {jueces.map(juez => (
                    <FormControlLabel
                      key={juez.cod_juez}
                      control={<Checkbox checked={selectedJueces.includes(juez.cod_juez)} onChange={() => handleJuezSelection(juez.cod_juez)} />}
                      label={`${juez.primar_nom_juez} ${juez.primar_ape_juez} (CI: ${juez.ci_juez})`}
                    />
                  ))}
                </Box>
              )}
            </Box>
          </Stack>
        </Box>
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
        <Dialog open={openTipoEventoModal} onClose={() => setOpenTipoEventoModal(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Registrar Tipo de Evento</DialogTitle>
          <DialogContent dividers>
            <Box component="form" onSubmit={handleCrearTipoEvento} sx={{ mt: 1 }}>
              <Stack spacing={2}>
                <TextField fullWidth required label="Nombre del Tipo de Evento" name="nombre_tipo_even" value={nuevoTipoEvento.nombre_tipo_even} onChange={handleNuevoTipoEventoInputChange} />
                <FormControl fullWidth>
                  <InputLabel>Tipo de Evento Padre (opcional)</InputLabel>
                  <Select name="fk_tipo_even" value={nuevoTipoEvento.fk_tipo_even ? String(nuevoTipoEvento.fk_tipo_even) : ''} onChange={(e, _) => handleNuevoTipoEventoSelectChange(e as SelectChangeEvent<string>)} label="Tipo de Evento Padre (opcional)">
                    <MenuItem value="">Ninguno</MenuItem>
                    {tiposEvento.map(tipo => (
                      <MenuItem key={tipo.cod_tipo_even} value={String(tipo.cod_tipo_even)}>{tipo.nombre_tipo_even}</MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Stack>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenTipoEventoModal(false)} color="secondary">Cancelar</Button>
            <Button type="submit" variant="contained" onClick={handleCrearTipoEvento} disabled={tipoEventoLoading}>
              {tipoEventoLoading ? <CircularProgress size={24} /> : 'Registrar Tipo de Evento'}
            </Button>
          </DialogActions>
        </Dialog>
        <Dialog open={gestionandoTipos} onClose={handleCerrarGestion} maxWidth="sm" fullWidth>
          <DialogTitle>Gestionar Jerarquía de Tipos de Evento</DialogTitle>
          <DialogContent dividers>
            <Stack spacing={2}>
              <FormControl fullWidth>
                <InputLabel>Selecciona el Tipo de Evento Padre</InputLabel>
                <Select value={selectedTipoPadre ? String(selectedTipoPadre) : ''} onChange={handleSeleccionarPadre} label="Selecciona el Tipo de Evento Padre">
                  <MenuItem value="">Ninguno</MenuItem>
                  {tiposEvento.map(tipo => (
                    <MenuItem key={tipo.cod_tipo_even} value={String(tipo.cod_tipo_even)}>{tipo.nombre_tipo_even}</MenuItem>
                  ))}
                </Select>
              </FormControl>
              <Typography variant="subtitle1">Selecciona los Tipos de Evento Hijos</Typography>
              <List>
                {tiposEvento.filter(tipo => tipo.cod_tipo_even !== selectedTipoPadre && !tiposPadre.includes(tipo.cod_tipo_even)).map(tipo => (
                  <ListItem key={tipo.cod_tipo_even} onClick={() => handleSeleccionarHijo(tipo.cod_tipo_even)} selected={selectedHijos.includes(tipo.cod_tipo_even)}>
                    <Checkbox checked={selectedHijos.includes(tipo.cod_tipo_even)} />
                    <ListItemText primary={tipo.nombre_tipo_even} />
                  </ListItem>
                ))}
              </List>
            </Stack>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCerrarGestion} color="secondary">Cancelar</Button>
            <Button onClick={handleGuardarJerarquia} variant="contained" disabled={!selectedTipoPadre}>Guardar Cambios</Button>
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