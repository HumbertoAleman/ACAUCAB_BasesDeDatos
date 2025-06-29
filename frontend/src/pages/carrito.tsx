import React from 'react';
import { useCart } from '../contexts/CartContext';
import { Box, Typography, Button, IconButton, Divider, List, ListItem, ListItemText, ListItemSecondaryAction, TextField } from '@mui/material';
import { Delete, Add, Remove } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';

const CarritoOnline: React.FC = () => {
  const { items, updateItem, removeItem, clearCart } = useCart();
  const navigate = useNavigate();

  const handleCantidad = (key: string, cantidad: number) => {
    if (cantidad <= 0) removeItem(key);
    else updateItem(key, cantidad);
  };

  const total = items.reduce((acc, item) => acc + item.subtotal, 0);

  return (
    <Box sx={{ p: 3, maxWidth: 700, mx: 'auto' }}>
      <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#2E7D32', mb: 2 }}>
        Carrito de Compras Online
      </Typography>
      <Divider sx={{ mb: 2 }} />
      {items.length === 0 ? (
        <Typography variant="body1" color="text.secondary" sx={{ textAlign: 'center', mt: 4 }}>
          Tu carrito está vacío.
        </Typography>
      ) : (
        <>
          <List>
            {items.map((item) => (
              <ListItem key={(item.producto as any)._key}>
                <ListItemText
                  primary={item.producto.nombre_cerv + ' - ' + item.producto.nombre_pres}
                  secondary={`Precio: $${item.precio_unitario.toFixed(2)} | Subtotal: $${item.subtotal.toFixed(2)}`}
                />
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <IconButton onClick={() => handleCantidad((item.producto as any)._key, item.cantidad - 1)}>
                    <Remove />
                  </IconButton>
                  <TextField
                    value={item.cantidad}
                    onChange={e => {
                      const val = parseInt(e.target.value, 10);
                      if (!isNaN(val)) handleCantidad((item.producto as any)._key, val);
                    }}
                    type="number"
                    size="small"
                    inputProps={{ min: 1, style: { width: 40, textAlign: 'center' } }}
                  />
                  <IconButton onClick={() => handleCantidad((item.producto as any)._key, item.cantidad + 1)}>
                    <Add />
                  </IconButton>
                </Box>
                <ListItemSecondaryAction>
                  <IconButton edge="end" onClick={() => removeItem((item.producto as any)._key)}>
                    <Delete />
                  </IconButton>
                </ListItemSecondaryAction>
              </ListItem>
            ))}
          </List>
          <Divider sx={{ my: 2 }} />
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Typography variant="h6">Total:</Typography>
            <Typography variant="h6" color="primary">${total.toFixed(2)}</Typography>
          </Box>
          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button variant="outlined" color="error" onClick={clearCart}>Vaciar Carrito</Button>
            <Button variant="contained" color="success" onClick={() => navigate('/checkout')}>Procesar Compra</Button>
          </Box>
        </>
      )}
    </Box>
  );
};

export default CarritoOnline; 