import React, { useState, useEffect } from 'react';
import { getTiposEvento, getLugares, getEventos, createEvento, createEventoRecursivo } from '../../services/api';
import type { Evento, TipoEvento } from '../../interfaces/eventos';
import type { Lugar } from '../../interfaces/common';

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
  const [loading, setLoading] = useState(false);
  const [isRecursive, setIsRecursive] = useState(false);

  useEffect(() => {
    if (isOpen) {
      loadData();
    }
  }, [isOpen]);

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
    } catch (error) {
      console.error('Error cargando datos:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name.includes('precio') || name.includes('capacidad') || name.includes('cant_entradas') || name.includes('fk_') 
        ? Number(value) 
        : value
    }));
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
      
      let response;
      if (isRecursive && formData.fk_even) {
        response = await createEventoRecursivo(formData.fk_even, formData);
      } else {
        response = await createEvento(formData);
      }

      if (response) {
        alert('Evento registrado exitosamente');
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
    setIsRecursive(false);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-2xl font-bold text-gray-800">
            {isRecursive ? 'Registrar Evento Recursivo' : 'Registrar Nuevo Evento'}
          </h2>
          <button
            onClick={handleClose}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Tipo de evento recursivo */}
          <div className="flex items-center space-x-2 mb-4">
            <input
              type="checkbox"
              id="isRecursive"
              checked={isRecursive}
              onChange={(e) => setIsRecursive(e.target.checked)}
              className="rounded"
            />
            <label htmlFor="isRecursive" className="text-sm font-medium text-gray-700">
              Evento recursivo (basado en otro evento)
            </label>
          </div>

          {/* Evento padre para recursividad */}
          {isRecursive && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Evento Padre *
              </label>
              <select
                name="fk_even"
                value={formData.fk_even || ''}
                onChange={handleInputChange}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="">Seleccione un evento</option>
                {eventos.map(evento => (
                  <option key={evento.cod_even} value={evento.cod_even}>
                    {evento.nombre_even}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Nombre del evento */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Nombre del Evento *
            </label>
            <input
              type="text"
              name="nombre_even"
              value={formData.nombre_even}
              onChange={handleInputChange}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          {/* Fechas y horas */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Fecha y Hora de Inicio *
              </label>
              <input
                type="datetime-local"
                name="fecha_hora_ini_even"
                value={formData.fecha_hora_ini_even}
                onChange={handleInputChange}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Fecha y Hora de Fin *
              </label>
              <input
                type="datetime-local"
                name="fecha_hora_fin_even"
                value={formData.fecha_hora_fin_even}
                onChange={handleInputChange}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>
          </div>

          {/* Dirección */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Dirección *
            </label>
            <textarea
              name="direccion_even"
              value={formData.direccion_even}
              onChange={handleInputChange}
              rows={3}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          {/* Capacidad y entradas */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Capacidad *
              </label>
              <input
                type="number"
                name="capacidad_even"
                value={formData.capacidad_even}
                onChange={handleInputChange}
                min="1"
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cantidad de Entradas *
              </label>
              <input
                type="number"
                name="cant_entradas_evento"
                value={formData.cant_entradas_evento}
                onChange={handleInputChange}
                min="1"
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>
          </div>

          {/* Precio de entrada */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Precio de Entrada (USD)
            </label>
            <input
              type="number"
              name="precio_entrada_even"
              value={formData.precio_entrada_even}
              onChange={handleInputChange}
              min="0"
              step="0.01"
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {/* Descripción */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Descripción *
            </label>
            <textarea
              name="descripcion_even"
              value={formData.descripcion_even}
              onChange={handleInputChange}
              rows={4}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          {/* Tipo de evento y lugar */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Evento *
              </label>
              <select
                name="fk_tipo_even"
                value={formData.fk_tipo_even || ''}
                onChange={handleInputChange}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="">Seleccione un tipo</option>
                {tiposEvento.map(tipo => (
                  <option key={tipo.cod_tipo_even} value={tipo.cod_tipo_even}>
                    {tipo.nombre_tipo_even}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Lugar (Parroquia) *
              </label>
              <select
                name="fk_luga"
                value={formData.fk_luga || ''}
                onChange={handleInputChange}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              >
                <option value="">Seleccione un lugar</option>
                {lugares.map(lugar => (
                  <option key={lugar.cod_luga} value={lugar.cod_luga}>
                    {lugar.nombre_luga}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Botones */}
          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={handleClose}
              className="px-4 py-2 text-gray-700 bg-gray-200 rounded-md hover:bg-gray-300 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
              {loading ? 'Registrando...' : 'Registrar Evento'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RegistroEvento; 