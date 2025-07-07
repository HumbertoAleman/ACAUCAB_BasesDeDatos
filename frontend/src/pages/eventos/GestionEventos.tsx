import React, { useState, useEffect } from 'react';
import RegistroEvento from './RegistroEvento';
import CompraEntradas from './CompraEntradas';
import { getEventos, getTiposEvento, getLugares, getJuecesEvento } from '../../services/api';
import type { Evento, TipoEvento } from '../../interfaces/eventos';
import type { Lugar } from '../../interfaces/common';
import {
  Box,
  Paper,
  Typography,
  Button,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  CircularProgress,
  Stack,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import CloseIcon from '@mui/icons-material/Close';

const DetalleEventoModal = ({ open, onClose, evento, tiposEvento, lugares }) => {
  const [jueces, setJueces] = useState([]);

  useEffect(() => {
    if (open && evento) {
      getJuecesEvento(evento.cod_even).then(setJueces);
    }
  }, [open, evento]);

  // Obtener tipo de evento padre e hijos
  const tipoEvento = tiposEvento.find(t => t.cod_tipo_even === evento.fk_tipo_even);
  const tipoPadre = tipoEvento && tipoEvento.fk_tipo_even ? tiposEvento.find(t => t.cod_tipo_even === tipoEvento.fk_tipo_even) : null;
  const hijos = tiposEvento.filter(t => t.fk_tipo_even === evento.fk_tipo_even);
  const lugar = lugares.find(l => l.cod_luga === evento.fk_luga);

  // Formatear fecha y hora
  const formatDate = (dateStr) => {
    const d = new Date(dateStr);
    return d.toLocaleString('es-VE', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        Detalles del Evento
        <IconButton onClick={onClose}><CloseIcon /></IconButton>
      </DialogTitle>
      <DialogContent dividers>
        <Typography variant="h6">{evento.nombre_even}</Typography>
        <Typography variant="body2" color="text.secondary">{evento.descripcion_even}</Typography>
        <Box sx={{ mt: 2 }}>
          <Typography><b>Fecha y Hora:</b> {formatDate(evento.fecha_hora_ini_even)} - {formatDate(evento.fecha_hora_fin_even)}</Typography>
          <Typography><b>Lugar:</b> {lugar ? lugar.nombre_luga : 'N/A'}</Typography>
          <Typography><b>Capacidad:</b> {evento.capacidad_even}</Typography>
          <Typography><b>Cantidad de Entradas:</b> {evento.cant_entradas_evento}</Typography>
          <Typography><b>Precio de Entrada:</b> {evento.precio_entrada_even}</Typography>
        </Box>
        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1"><b>Tipo de Evento:</b> {tipoEvento ? tipoEvento.nombre_tipo_even : 'N/A'}</Typography>
          {tipoPadre && <Typography variant="body2">Padre: {tipoPadre.nombre_tipo_even}</Typography>}
          {hijos.length > 0 && (
            <Box sx={{ mt: 1 }}>
              <Typography variant="body2">Actividades (Tipos de Evento Hijo):</Typography>
              <ul>
                {hijos.map(hijo => <li key={hijo.cod_tipo_even}>{hijo.nombre_tipo_even}</li>)}
              </ul>
            </Box>
          )}
        </Box>
        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1"><b>Jueces:</b></Typography>
          {jueces.length === 0 ? (
            <Typography variant="body2">No hay jueces asociados a este evento.</Typography>
          ) : (
            <ul>
              {jueces.map(juez => (
                <li key={juez.cod_juez}>{juez.primar_nom_juez} {juez.primar_ape_juez} (CI: {juez.ci_juez})</li>
              ))}
            </ul>
          )}
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="secondary">Cerrar</Button>
      </DialogActions>
    </Dialog>
  );
};

const GestionEventos: React.FC = () => {
  const [eventos, setEventos] = useState<Evento[]>([]);
  const [tiposEvento, setTiposEvento] = useState<TipoEvento[]>([]);
  const [lugares, setLugares] = useState<Lugar[]>([]);
  const [loading, setLoading] = useState(true);
  const [showRegistroModal, setShowRegistroModal] = useState(false);
  const [showCompraModal, setShowCompraModal] = useState(false);
  const [eventoSeleccionado, setEventoSeleccionado] = useState<Evento | null>(null);
  const [filtroTipo, setFiltroTipo] = useState<number>(0);
  const [filtroLugar, setFiltroLugar] = useState<number>(0);
  const [error, setError] = useState<string | null>(null);
  const [paginaActual, setPaginaActual] = useState(1);
  const eventosPorPagina = 15;
  const [showDetalleModal, setShowDetalleModal] = useState(false);
  const [eventoDetalle, setEventoDetalle] = useState<Evento | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const eventos = await getEventos();
      const tipos = await getTiposEvento();
      const lugares = await getLugares();
      setEventos(eventos);
      setTiposEvento(tipos);
      setLugares(lugares);
    } catch (err) {
      setError('Error de conexión o al obtener datos de la API. Intenta de nuevo más tarde.');
      setEventos([]);
      setTiposEvento([]);
      setLugares([]);
    } finally {
      setLoading(false);
    }
  };

  const handleRegistroSuccess = () => {
    loadData();
  };

  const handleCompraSuccess = () => {
    loadData();
  };

  const openCompraModal = (evento: Evento) => {
    setEventoSeleccionado(evento);
    setShowCompraModal(true);
  };

  const getTipoEventoNombre = (codTipo: number) => {
    const tipo = tiposEvento.find(t => t.cod_tipo_even === codTipo);
    return tipo ? tipo.nombre_tipo_even : 'N/A';
  };

  const getLugarNombre = (codLugar: number) => {
    const lugar = lugares.find(l => l.cod_luga === codLugar);
    return lugar ? lugar.nombre_luga : 'N/A';
  };

  const eventosFiltrados = eventos.filter(evento => {
    if (filtroTipo && evento.fk_tipo_even !== filtroTipo) return false;
    if (filtroLugar && evento.fk_luga !== filtroLugar) return false;
    return true;
  });

  const totalPaginas = Math.ceil(eventosFiltrados.length / eventosPorPagina);
  const eventosPagina = eventosFiltrados.slice((paginaActual - 1) * eventosPorPagina, paginaActual * eventosPorPagina);

  useEffect(() => {
    setPaginaActual(1); // Reiniciar a la primera página al cambiar filtros o eventos
  }, [filtroTipo, filtroLugar, eventos.length]);

  const handleVerDetalles = (evento: Evento) => {
    setEventoDetalle(evento);
    setShowDetalleModal(true);
  };

  const handleCerrarDetalle = () => {
    setShowDetalleModal(false);
    setEventoDetalle(null);
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '60vh' }}>
        <CircularProgress size={60} color="primary" />
        <Typography variant="h6" color="text.secondary" sx={{ mt: 2 }}>
          Cargando eventos...
        </Typography>
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '60vh' }}>
        <Typography variant="h5" color="error" gutterBottom>
          {error}
        </Typography>
        <Button variant="contained" onClick={loadData} sx={{ mt: 2 }}>
          Reintentar
        </Button>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" gutterBottom>Gestión de Eventos</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => setShowRegistroModal(true)}>
          Registrar Nuevo Evento
        </Button>
      </Box>

      <Paper sx={{ p: 2, mb: 3 }}>
        <Typography variant="h6" gutterBottom>Filtros</Typography>
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
          <Box flex={1}>
            <FormControl fullWidth>
              <InputLabel>Tipo de Evento</InputLabel>
              <Select
                value={filtroTipo}
                label="Tipo de Evento"
                onChange={(e) => setFiltroTipo(Number(e.target.value))}
              >
                <MenuItem value={0}>Todos los tipos</MenuItem>
                {tiposEvento.map(tipo => (
                  <MenuItem key={tipo.cod_tipo_even} value={tipo.cod_tipo_even}>
                    {tipo.nombre_tipo_even}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
          <Box flex={1}>
            <FormControl fullWidth>
              <InputLabel>Lugar</InputLabel>
              <Select
                value={filtroLugar}
                label="Lugar"
                onChange={(e) => setFiltroLugar(Number(e.target.value))}
              >
                <MenuItem value={0}>Todos los lugares</MenuItem>
                {lugares.map(lugar => (
                  <MenuItem key={lugar.cod_luga} value={lugar.cod_luga}>
                    {lugar.nombre_luga}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
          <Box flexShrink={0} minWidth={{ xs: '100%', md: 140 }}>
            <Button fullWidth variant="outlined" color="secondary" onClick={() => { setFiltroTipo(0); setFiltroLugar(0); }}>
              Limpiar Filtros
            </Button>
          </Box>
        </Stack>
      </Paper>

      <Paper sx={{ p: 2 }}>
        <Typography variant="h6" gutterBottom>Eventos ({eventosFiltrados.length})</Typography>
        {eventosFiltrados.length === 0 ? (
          <Box sx={{ p: 4, textAlign: 'center', color: 'text.secondary' }}>
            No se encontraron eventos con los filtros aplicados
          </Box>
        ) : (
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Evento</TableCell>
                <TableCell>Tipo</TableCell>
                <TableCell>Fecha y Hora</TableCell>
                <TableCell>Lugar</TableCell>
                <TableCell>Precio</TableCell>
                <TableCell>Entradas</TableCell>
                <TableCell>Acciones</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {eventosPagina.map(evento => (
                <TableRow key={evento.cod_even} hover>
                  <TableCell>
                    <Typography fontWeight={600}>{evento.nombre_even}</Typography>
                    <Typography variant="body2" color="text.secondary" sx={{ maxWidth: 220, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {evento.descripcion_even}
                    </Typography>
                  </TableCell>
                  <TableCell>{getTipoEventoNombre(evento.fk_tipo_even)}</TableCell>
                  <TableCell>{new Date(evento.fecha_hora_ini_even).toLocaleString()} - {new Date(evento.fecha_hora_fin_even).toLocaleString()}</TableCell>
                  <TableCell>{getLugarNombre(evento.fk_luga)}</TableCell>
                  <TableCell>{evento.precio_entrada_even != null ? `$${evento.precio_entrada_even}` : 'Gratis'}</TableCell>
                  <TableCell>{evento.cant_entradas_evento}</TableCell>
                  <TableCell>
                    <Stack direction="row" spacing={1}>
                      <Button size="small" onClick={() => handleVerDetalles(evento)}><VisibilityIcon /></Button>
                      <Button size="small" variant="outlined" onClick={() => openCompraModal(evento)}>
                        Comprar
                      </Button>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {totalPaginas > 1 && (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', mt: 2 }}>
            <Button
              variant="outlined"
              onClick={() => setPaginaActual(p => Math.max(1, p - 1))}
              disabled={paginaActual === 1}
              sx={{ mr: 1 }}
            >
              Anterior
            </Button>
            <Typography variant="body2" sx={{ mx: 2 }}>
              Página {paginaActual} de {totalPaginas}
            </Typography>
            <Button
              variant="outlined"
              onClick={() => setPaginaActual(p => Math.min(totalPaginas, p + 1))}
              disabled={paginaActual === totalPaginas}
              sx={{ ml: 1 }}
            >
              Siguiente
            </Button>
          </Box>
        )}
      </Paper>
      {showRegistroModal && (
        <RegistroEvento
          isOpen={showRegistroModal}
          onClose={() => setShowRegistroModal(false)}
          onSuccess={handleRegistroSuccess}
        />
      )}
      {showDetalleModal && eventoDetalle && (
        <DetalleEventoModal
          open={showDetalleModal}
          onClose={handleCerrarDetalle}
          evento={eventoDetalle}
          tiposEvento={tiposEvento}
          lugares={lugares}
        />
      )}
      {showCompraModal && eventoSeleccionado && (
        <CompraEntradas
          isOpen={showCompraModal}
          onClose={() => setShowCompraModal(false)}
          evento={eventoSeleccionado}
        />
      )}
    </Box>
  );
};

export default GestionEventos; 