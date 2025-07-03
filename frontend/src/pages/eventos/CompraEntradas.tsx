import React, { useState, useEffect } from 'react';
import { getClientesDetallados, getEmpleados, getMiembros, createRegistroEvento } from '../../services/api';
import type { Evento, RegistroEvento } from '../../interfaces/eventos';
import type { ClienteDetallado } from '../../interfaces/ventas';
import type { Miembro } from '../../interfaces/miembros';

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
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-2xl font-bold text-gray-800">
            Comprar Entradas - {evento.nombre_even}
          </h2>
          <button
            onClick={handleClose}
            className="text-gray-500 hover:text-gray-700 text-2xl"
          >
            ×
          </button>
        </div>

        {/* Información del evento */}
        <div className="bg-gray-50 p-4 rounded-lg mb-6">
          <h3 className="font-semibold text-lg mb-2">Información del Evento</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <span className="font-medium">Fecha:</span> {new Date(evento.fecha_hora_ini_even).toLocaleDateString()}
            </div>
            <div>
              <span className="font-medium">Hora:</span> {new Date(evento.fecha_hora_ini_even).toLocaleTimeString()}
            </div>
            <div>
              <span className="font-medium">Dirección:</span> {evento.direccion_even}
            </div>
            <div>
              <span className="font-medium">Precio:</span> ${evento.precio_entrada_even || 'Gratis'}
            </div>
            <div>
              <span className="font-medium">Entradas disponibles:</span> {evento.cant_entradas_evento}
            </div>
            <div>
              <span className="font-medium">Capacidad:</span> {evento.capacidad_even}
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Tipo de participante */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tipo de Participante *
            </label>
            <div className="flex space-x-4">
              <label className="flex items-center">
                <input
                  type="radio"
                  name="tipoParticipante"
                  value="cliente"
                  checked={tipoParticipante === 'cliente'}
                  onChange={() => handleTipoParticipanteChange('cliente')}
                  className="mr-2"
                />
                Cliente
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  name="tipoParticipante"
                  value="empleado"
                  checked={tipoParticipante === 'empleado'}
                  onChange={() => handleTipoParticipanteChange('empleado')}
                  className="mr-2"
                />
                Empleado/Juez
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  name="tipoParticipante"
                  value="miembro"
                  checked={tipoParticipante === 'miembro'}
                  onChange={() => handleTipoParticipanteChange('miembro')}
                  className="mr-2"
                />
                Miembro
              </label>
            </div>
          </div>

          {/* Selector de participante */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Seleccionar {tipoParticipante === 'cliente' ? 'Cliente' : tipoParticipante === 'empleado' ? 'Empleado/Juez' : 'Miembro'} *
            </label>
            <select
              name={tipoParticipante === 'cliente' ? 'fk_clie' : tipoParticipante === 'empleado' ? 'fk_juez' : 'fk_miem'}
              value={tipoParticipante === 'cliente' ? formData.fk_clie || '' : tipoParticipante === 'empleado' ? formData.fk_juez || '' : formData.fk_miem || ''}
              onChange={handleInputChange}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            >
              <option value="">Seleccione un {tipoParticipante}</option>
              {tipoParticipante === 'cliente' && clientes.map(cliente => (
                <option key={cliente.rif_clie} value={cliente.rif_clie}>
                  {cliente.tipo_clie === 'Natural' 
                    ? `${cliente.primer_nom_natu || ''} ${cliente.primer_ape_natu || ''}`.trim()
                    : cliente.razon_social_juri || ''
                  } - {cliente.rif_clie}
                </option>
              ))}
              {tipoParticipante === 'empleado' && empleados.map(empleado => (
                <option key={empleado.cod_empl} value={empleado.cod_empl}>
                  {empleado.primer_nom_empl} {empleado.primer_ape_empl} - CI: {empleado.ci_empl}
                </option>
              ))}
              {tipoParticipante === 'miembro' && miembros.map(miembro => (
                <option key={miembro.rif_miem} value={miembro.rif_miem}>
                  {miembro.razon_social_miem} - {miembro.rif_miem}
                </option>
              ))}
            </select>
          </div>

          {/* Cantidad de entradas */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cantidad de Entradas *
            </label>
            <input
              type="number"
              name="cantidad_entradas"
              value={formData.cantidad_entradas}
              onChange={handleInputChange}
              min="1"
              max={evento.cant_entradas_evento}
              className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
            <p className="text-sm text-gray-500 mt-1">
              Máximo {evento.cant_entradas_evento} entradas disponibles
            </p>
          </div>

          {/* Resumen del costo */}
          {evento.precio_entrada_even && evento.precio_entrada_even > 0 && (
            <div className="bg-blue-50 p-4 rounded-lg">
              <h4 className="font-semibold text-blue-800 mb-2">Resumen del Costo</h4>
              <div className="flex justify-between text-sm">
                <span>Precio por entrada:</span>
                <span>${evento.precio_entrada_even}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span>Cantidad:</span>
                <span>{formData.cantidad_entradas}</span>
              </div>
              <div className="flex justify-between font-semibold text-blue-800 border-t pt-2 mt-2">
                <span>Total:</span>
                <span>${(evento.precio_entrada_even * formData.cantidad_entradas).toFixed(2)}</span>
              </div>
              <p className="text-xs text-blue-600 mt-2">
                * Los pagos se manejan por separado en el módulo de ventas
              </p>
            </div>
          )}

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
              className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors disabled:opacity-50"
            >
              {loading ? 'Registrando...' : 'Registrar Entrada'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CompraEntradas; 