import React, { useState, useEffect } from 'react';
import RegistroEvento from './RegistroEvento';
import CompraEntradas from './CompraEntradas';
import { getEventos, getTiposEvento, getLugares } from '../../services/api';
import type { Evento, TipoEvento } from '../../interfaces/eventos';
import type { Lugar } from '../../interfaces/common';

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

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Cargar eventos
      const eventos = await getEventos();
      setEventos(eventos);

      // Cargar tipos de evento
      const tipos = await getTiposEvento();
      setTiposEvento(tipos);

      // Cargar lugares
      const lugares = await getLugares();
      setLugares(lugares);
    } catch (error) {
      console.error('Error cargando datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleRegistroSuccess = () => {
    loadData();
  };

  const handleCompraSuccess = () => {
    // Recargar eventos para actualizar entradas disponibles
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
      <div className="flex justify-center items-center h-64">
        <div className="text-xl">Cargando eventos...</div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold text-gray-800">Gestión de Eventos</h1>
        <button
          onClick={() => setShowRegistroModal(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
        >
          Registrar Nuevo Evento
        </button>
      </div>

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <h2 className="text-lg font-semibold mb-4">Filtros</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Tipo de Evento
            </label>
            <select
              value={filtroTipo}
              onChange={(e) => setFiltroTipo(Number(e.target.value))}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value={0}>Todos los tipos</option>
              {tiposEvento.map(tipo => (
                <option key={tipo.cod_tipo_even} value={tipo.cod_tipo_even}>
                  {tipo.nombre_tipo_even}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Lugar
            </label>
            <select
              value={filtroLugar}
              onChange={(e) => setFiltroLugar(Number(e.target.value))}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value={0}>Todos los lugares</option>
              {lugares.map(lugar => (
                <option key={lugar.cod_luga} value={lugar.cod_luga}>
                  {lugar.nombre_luga}
                </option>
              ))}
            </select>
          </div>
          <div className="flex items-end">
            <button
              onClick={() => {
                setFiltroTipo(0);
                setFiltroLugar(0);
              }}
              className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
            >
              Limpiar Filtros
            </button>
          </div>
        </div>
      </div>

      {/* Lista de eventos */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-800">
            Eventos ({eventosFiltrados.length})
          </h2>
        </div>
        
        {eventosFiltrados.length === 0 ? (
          <div className="p-6 text-center text-gray-500">
            No se encontraron eventos con los filtros aplicados
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Evento
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tipo
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Fecha y Hora
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Lugar
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Precio
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Entradas
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {eventosFiltrados.map(evento => (
                  <tr key={evento.cod_even} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div>
                        <div className="text-sm font-medium text-gray-900">
                          {evento.nombre_even}
                        </div>
                        <div className="text-sm text-gray-500 max-w-xs truncate">
                          {evento.descripcion_even}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {getTipoEventoNombre(evento.fk_tipo_even)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <div>
                        <div>{new Date(evento.fecha_hora_ini_even).toLocaleDateString()}</div>
                        <div className="text-gray-500">
                          {new Date(evento.fecha_hora_ini_even).toLocaleTimeString()}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {getLugarNombre(evento.fk_luga)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {evento.precio_entrada_even ? `$${evento.precio_entrada_even}` : 'Gratis'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <div className="flex items-center">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          evento.cant_entradas_evento > 0 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {evento.cant_entradas_evento} disponibles
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button
                          onClick={() => openCompraModal(evento)}
                          disabled={evento.cant_entradas_evento <= 0}
                          className="px-3 py-1 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-xs"
                        >
                          Comprar Entrada
                        </button>
                        <button
                          onClick={() => {
                            setEventoSeleccionado(evento);
                            setShowRegistroModal(true);
                          }}
                          className="px-3 py-1 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors text-xs"
                        >
                          Editar
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Modales */}
      <RegistroEvento
        isOpen={showRegistroModal}
        onClose={() => {
          setShowRegistroModal(false);
          setEventoSeleccionado(null);
        }}
        onSuccess={handleRegistroSuccess}
      />

      <CompraEntradas
        isOpen={showCompraModal}
        onClose={() => {
          setShowCompraModal(false);
          setEventoSeleccionado(null);
        }}
        evento={eventoSeleccionado}
      />
    </div>
  );
};

export default GestionEventos; 