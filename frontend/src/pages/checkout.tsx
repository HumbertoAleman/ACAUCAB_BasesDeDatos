import React, { useState } from 'react';
import { useCart } from '../contexts/CartContext';
import { Box, Typography, Divider, Button, Alert } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { procesarVenta } from '../services/api';
import { useAuth } from '../contexts/AuthContext';

const CheckoutOnline: React.FC = () => {
  const { items, clearCart } = useCart();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const subtotal = items.reduce((acc, item) => acc + item.subtotal, 0);
  const iva = subtotal * 0.16;
  const total = subtotal + iva;

  const handleProcesar = async () => {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      // Construir el objeto venta para el backend
      const ventaOnline = {
        fecha_vent: new Date().toISOString().split('T')[0],
        iva_vent: iva,
        base_imponible_vent: subtotal,
        total_vent: total,
        online: true,
        fk_clie: user?.username, // O el identificador real del cliente
        fk_tien: 1, // O tienda online
        items: items.map(item => ({
          fk_cerv_pres_1: item.producto.fk_cerv_pres_1,
          fk_cerv_pres_2: item.producto.fk_cerv_pres_2,
          fk_tien: item.producto.fk_tien,
          fk_luga_tien: item.producto.fk_luga_tien,
          cantidad: item.cantidad,
        })),
        pagos: [], // Vacío porque es carrito, no pagado aún
      };
      // Llamar al endpoint del backend para guardar el carrito
      const res = await procesarVenta(ventaOnline as any);
      if (res.success) {
        setSuccess('Carrito guardado correctamente. Puedes continuar tu compra más tarde o proceder al pago cuando desees.');
        clearCart();
        setTimeout(() => navigate('/catalogo'), 2000);
      } else {
        setError(res.message || 'Error al guardar el carrito');
      }
    } catch (e) {
      setError('Error inesperado al guardar el carrito');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{ p: 3, maxWidth: 700, mx: 'auto' }}>
      <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#2E7D32', mb: 2 }}>
        Confirmar Compra Online
      </Typography>
      <Divider sx={{ mb: 2 }} />
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }}>{success}</Alert>}
      <Typography variant="h6">Resumen del Carrito</Typography>
      <ul>
        {items.map((item) => (
          <li key={(item.producto as any)._key}>
            {item.producto.nombre_cerv} - {item.producto.nombre_pres} x {item.cantidad} = ${item.subtotal.toFixed(2)}
          </li>
        ))}
      </ul>
      <Divider sx={{ my: 2 }} />
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
        <Typography>Subtotal:</Typography>
        <Typography>${subtotal.toFixed(2)}</Typography>
      </Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
        <Typography>IVA (16%):</Typography>
        <Typography>${iva.toFixed(2)}</Typography>
      </Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
        <Typography variant="h6">Total:</Typography>
        <Typography variant="h6" color="primary">${total.toFixed(2)}</Typography>
      </Box>
      <Button
        variant="contained"
        color="success"
        fullWidth
        size="large"
        disabled={loading || items.length === 0}
        onClick={handleProcesar}
      >
        Confirmar y Guardar Carrito
      </Button>
    </Box>
  );
};

export default CheckoutOnline; 