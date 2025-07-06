import React, { useState, useEffect } from 'react';
import RegistroEvento from './RegistroEvento';
import CompraEntradas from './CompraEntradas';
import { getEventos, getTiposEvento, getLugares } from '../../services/api';
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
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';

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
              {eventosFiltrados.map(evento => (
                <TableRow key={evento.cod_even} hover>
                  <TableCell>
                    <Typography fontWeight={600}>{evento.nombre_even}</Typography>
                    <Typography variant="body2" color="text.secondary" sx={{ maxWidth: 220, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {evento.descripcion_even}
                    </Typography>
                  </TableCell>
                  <TableCell>{getTipoEventoNombre(evento.fk_tipo_even)}</TableCell>
                  <TableCell>{new Date(evento.fecha_hora_ini_even).toLocaleString()}</TableCell>
                  <TableCell>{getLugarNombre(evento.fk_luga)}</TableCell>
                  <TableCell>{evento.precio_entrada_even != null ? `$${evento.precio_entrada_even}` : 'Gratis'}</TableCell>
                  <TableCell>{evento.cant_entradas_evento}</TableCell>
                  <TableCell>
                    <Button size="small" variant="outlined" onClick={() => openCompraModal(evento)}>
                      Comprar
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </Paper>
      {showRegistroModal && (
        <RegistroEvento
          isOpen={showRegistroModal}
          onClose={() => setShowRegistroModal(false)}
          onSuccess={handleRegistroSuccess}
        />
      )}
    </Box>
  );
};

export default GestionEventos; 