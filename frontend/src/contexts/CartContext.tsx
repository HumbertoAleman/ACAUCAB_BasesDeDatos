import React, { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import type { ItemVenta, ResumenVenta } from '../interfaces/ventas';

interface CartContextType {
  items: ItemVenta[];
  resumen: ResumenVenta | null;
  setResumen: (resumen: ResumenVenta | null) => void;
  addItem: (item: ItemVenta) => void;
  removeItem: (key: string) => void;
  updateItem: (key: string, cantidad: number) => void;
  clearCart: () => void;
  setItems: (items: ItemVenta[]) => void;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

const getCartKey = (userId: string | null) => `carrito_${userId || 'anonimo'}`;

export const CartProvider = ({ children, userId }: { children: ReactNode; userId: string | null }) => {
  const [items, setItems] = useState<ItemVenta[]>([]);
  const [resumen, setResumen] = useState<ResumenVenta | null>(null);

  // Cargar carrito desde localStorage al iniciar
  useEffect(() => {
    const key = getCartKey(userId);
    const stored = localStorage.getItem(key);
    if (stored) {
      try {
        setItems(JSON.parse(stored));
      } catch {
        setItems([]);
      }
    } else {
      setItems([]);
    }
  }, [userId]);

  // Guardar carrito en localStorage al cambiar
  useEffect(() => {
    const key = getCartKey(userId);
    localStorage.setItem(key, JSON.stringify(items));
  }, [items, userId]);

  const addItem = (item: ItemVenta) => {
    setItems((prev) => {
      const idx = prev.findIndex(
        (i) => (i.producto as any)._key === (item.producto as any)._key
      );
      if (idx !== -1) {
        // Si ya existe, suma cantidad
        const updated = [...prev];
        updated[idx].cantidad += item.cantidad;
        updated[idx].subtotal = updated[idx].cantidad * updated[idx].precio_unitario;
        return updated;
      }
      return [...prev, item];
    });
  };

  const removeItem = (key: string) => {
    setItems((prev) => prev.filter((i) => (i.producto as any)._key !== key));
  };

  const updateItem = (key: string, cantidad: number) => {
    setItems((prev) =>
      prev.map((i) =>
        (i.producto as any)._key === key
          ? { ...i, cantidad, subtotal: cantidad * i.precio_unitario }
          : i
      )
    );
  };

  const clearCart = () => setItems([]);

  return (
    <CartContext.Provider value={{ items, resumen, setResumen, addItem, removeItem, updateItem, clearCart, setItems }}>
      {children}
    </CartContext.Provider>
  );
};

export const useCart = () => {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart debe usarse dentro de CartProvider');
  return ctx;
}; 