"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Grid,
  Paper,
  Typography,
  TextField,
  Button,
  Card,
  CardContent,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Chip,
  Divider,
} from "@mui/material"
import { Add, Remove, Delete, Payment, Search, ShoppingCart } from "@mui/icons-material"
import type { Cerveza, Cliente } from "../../interfaces"

// Datos de ejemplo basados en las interfaces
const productosEjemplo: (Cerveza & { precio_unitario: number; cantidad_disponible: number; tipo_cerveza: string })[] = [
  {
    cod_cerv: 1,
    nombre_cerv: "Pale Ale Artesanal",
    fk_tipo_cerv: 1,
    precio_unitario: 8.5,
    cantidad_disponible: 45,
    tipo_cerveza: "Pale Ale",
  },
  {
    cod_cerv: 2,
    nombre_cerv: "IPA Tropical",
    fk_tipo_cerv: 2,
    precio_unitario: 9.0,
    cantidad_disponible: 32,
    tipo_cerveza: "IPA",
  },
  {
    cod_cerv: 3,
    nombre_cerv: "Stout Imperial",
    fk_tipo_cerv: 3,
    precio_unitario: 12.0,
    cantidad_disponible: 18,
    tipo_cerveza: "Stout",
  },
]

const clientesEjemplo: Cliente[] = [
  {
    rif_clie: 12345678,
    tipo_clie: "Natural",
    primer_nom_natu: "Juan",
    primer_ape_natu: "Pérez",
    direccion_fisica_clie: "Caracas",
    direccion_fiscal_clie: "Caracas",
    fk_luga_1: 1,
    fk_luga_2: 1,
  },
  {
    rif_clie: 87654321,
    tipo_clie: "Juridico",
    razon_social_juri: "Restaurante El Parador C.A.",
    direccion_fisica_clie: "Valencia",
    direccion_fiscal_clie: "Valencia",
    fk_luga_1: 2,
    fk_luga_2: 2,
  },
]

interface ItemVenta {
  cod_cerv: number
  nombre_cerv: string
  cantidad: number
  precio_unitario: number
  subtotal: number
}

export const PuntoVenta: React.FC = () => {
  const [busquedaProducto, setBusquedaProducto] = useState("")
  const [clienteSeleccionado, setClienteSeleccionado] = useState<Cliente | null>(null)
  const [itemsVenta, setItemsVenta] = useState<ItemVenta[]>([])
  const [dialogPago, setDialogPago] = useState(false)
  const [metodoPago, setMetodoPago] = useState("")

  const productosFiltered = productosEjemplo.filter((producto) =>
    producto.nombre_cerv.toLowerCase().includes(busquedaProducto.toLowerCase()),
  )

  const agregarProducto = (producto: (typeof productosEjemplo)[0]) => {
    const itemExistente = itemsVenta.find((item) => item.cod_cerv === producto.cod_cerv)

    if (itemExistente) {
      setItemsVenta(
        itemsVenta.map((item) =>
          item.cod_cerv === producto.cod_cerv
            ? {
                ...item,
                cantidad: item.cantidad + 1,
                subtotal: (item.cantidad + 1) * item.precio_unitario,
              }
            : item,
        ),
      )
    } else {
      const nuevoItem: ItemVenta = {
        cod_cerv: producto.cod_cerv,
        nombre_cerv: producto.nombre_cerv,
        cantidad: 1,
        precio_unitario: producto.precio_unitario,
        subtotal: producto.precio_unitario,
      }
      setItemsVenta([...itemsVenta, nuevoItem])
    }
  }

  const modificarCantidad = (cod_cerv: number, nuevaCantidad: number) => {
    if (nuevaCantidad <= 0) {
      setItemsVenta(itemsVenta.filter((item) => item.cod_cerv !== cod_cerv))
    } else {
      setItemsVenta(
        itemsVenta.map((item) =>
          item.cod_cerv === cod_cerv
            ? {
                ...item,
                cantidad: nuevaCantidad,
                subtotal: nuevaCantidad * item.precio_unitario,
              }
            : item,
        ),
      )
    }
  }

  const eliminarItem = (cod_cerv: number) => {
    setItemsVenta(itemsVenta.filter((item) => item.cod_cerv !== cod_cerv))
  }

  const calcularSubtotal = () => {
    return itemsVenta.reduce((total, item) => total + item.subtotal, 0)
  }

  const calcularIVA = () => {
    return calcularSubtotal() * 0.16
  }

  const calcularTotal = () => {
    return calcularSubtotal() + calcularIVA()
  }

  const procesarVenta = () => {
    console.log("Procesando venta:", {
      cliente: clienteSeleccionado,
      items: itemsVenta,
      subtotal: calcularSubtotal(),
      iva: calcularIVA(),
      total: calcularTotal(),
      metodo_pago: metodoPago,
    })

    // Limpiar formulario
    setItemsVenta([])
    setClienteSeleccionado(null)
    setMetodoPago("")
    setDialogPago(false)

    alert("Venta procesada exitosamente")
  }

  const getNombreCliente = (cliente: Cliente) => {
    if (cliente.tipo_clie === "Natural") {
      return `${cliente.primer_nom_natu || ""} ${cliente.primer_ape_natu || ""}`.trim()
    } else {
      return cliente.razon_social_juri || ""
    }
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Punto de Venta
      </Typography>

      <Grid container spacing={3}>
        {/* Panel de Productos */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Paper sx={{ p: 2, mb: 2 }}>
            <TextField
              fullWidth
              placeholder="Buscar productos..."
              value={busquedaProducto}
              onChange={(e) => setBusquedaProducto(e.target.value)}
              InputProps={{
                startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} />,
              }}
            />
          </Paper>

          <Grid container spacing={2}>
            {productosFiltered.map((producto) => (
              <Grid size={{ xs: 12, md: 4, sm: 6 }} key={producto.cod_cerv}>
                <Card
                  sx={{
                    cursor: "pointer",
                    "&:hover": { boxShadow: 4 },
                    opacity: producto.cantidad_disponible === 0 ? 0.5 : 1,
                  }}
                  onClick={() => producto.cantidad_disponible > 0 && agregarProducto(producto)}
                >
                  <CardContent>
                    <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                      <img
                        src="/placeholder.svg?height=50&width=50"
                        alt={producto.nombre_cerv}
                        style={{ width: 50, height: 50, marginRight: 8 }}
                      />
                      <Box>
                        <Typography variant="subtitle2">{producto.nombre_cerv}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          {producto.tipo_cerveza}
                        </Typography>
                      </Box>
                    </Box>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <Typography variant="h6" color="primary">
                        ${producto.precio_unitario.toFixed(2)}
                      </Typography>
                      <Chip
                        label={`Stock: ${producto.cantidad_disponible}`}
                        size="small"
                        color={producto.cantidad_disponible > 10 ? "success" : "warning"}
                      />
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </Grid>

        {/* Panel de Venta */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper sx={{ p: 2, position: "sticky", top: 20 }}>
            <Typography variant="h6" gutterBottom sx={{ display: "flex", alignItems: "center", gap: 1 }}>
              <ShoppingCart />
              Carrito de Venta
            </Typography>

            {/* Selección de Cliente */}
            <FormControl fullWidth sx={{ mb: 2 }}>
              <InputLabel>Cliente (Opcional)</InputLabel>
              <Select
                value={clienteSeleccionado?.rif_clie || ""}
                onChange={(e) => {
                  const cliente = clientesEjemplo.find((c) => c.rif_clie === Number(e.target.value))
                  setClienteSeleccionado(cliente || null)
                }}
                label="Cliente (Opcional)"
              >
                <MenuItem value="">Sin cliente</MenuItem>
                {clientesEjemplo.map((cliente) => (
                  <MenuItem key={cliente.rif_clie} value={cliente.rif_clie}>
                    {getNombreCliente(cliente)}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <Divider sx={{ mb: 2 }} />

            {/* Items de Venta */}
            <Box sx={{ maxHeight: 300, overflowY: "auto", mb: 2 }}>
              {itemsVenta.length === 0 ? (
                <Typography variant="body2" color="text.secondary" sx={{ textAlign: "center", py: 2 }}>
                  No hay productos en el carrito
                </Typography>
              ) : (
                itemsVenta.map((item) => (
                  <Box key={item.cod_cerv} sx={{ mb: 2, p: 1, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                    <Typography variant="subtitle2">{item.nombre_cerv}</Typography>
                    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mt: 1 }}>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <IconButton size="small" onClick={() => modificarCantidad(item.cod_cerv, item.cantidad - 1)}>
                          <Remove />
                        </IconButton>
                        <Typography>{item.cantidad}</Typography>
                        <IconButton size="small" onClick={() => modificarCantidad(item.cod_cerv, item.cantidad + 1)}>
                          <Add />
                        </IconButton>
                      </Box>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <Typography variant="body2">${item.subtotal.toFixed(2)}</Typography>
                        <IconButton size="small" color="error" onClick={() => eliminarItem(item.cod_cerv)}>
                          <Delete />
                        </IconButton>
                      </Box>
                    </Box>
                  </Box>
                ))
              )}
            </Box>

            {/* Totales */}
            {itemsVenta.length > 0 && (
              <>
                <Divider sx={{ mb: 2 }} />
                <Box sx={{ mb: 2 }}>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>Subtotal:</Typography>
                    <Typography>${calcularSubtotal().toFixed(2)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", mb: 1 }}>
                    <Typography>IVA (16%):</Typography>
                    <Typography>${calcularIVA().toFixed(2)}</Typography>
                  </Box>
                  <Box sx={{ display: "flex", justifyContent: "space-between", fontWeight: "bold" }}>
                    <Typography variant="h6">Total:</Typography>
                    <Typography variant="h6" color="primary">
                      ${calcularTotal().toFixed(2)}
                    </Typography>
                  </Box>
                </Box>

                <Button
                  fullWidth
                  variant="contained"
                  size="large"
                  startIcon={<Payment />}
                  onClick={() => setDialogPago(true)}
                  sx={{ backgroundColor: "#2E7D32", "&:hover": { backgroundColor: "#1B5E20" } }}
                >
                  Procesar Venta
                </Button>
              </>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Dialog de Pago */}
      <Dialog open={dialogPago} onClose={() => setDialogPago(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Procesar Pago</DialogTitle>
        <DialogContent>
          <Box sx={{ mb: 2 }}>
            <Typography variant="h6">Total a Pagar: ${calcularTotal().toFixed(2)}</Typography>
          </Box>

          <FormControl fullWidth>
            <InputLabel>Método de Pago</InputLabel>
            <Select value={metodoPago} onChange={(e) => setMetodoPago(e.target.value)} label="Método de Pago">
              <MenuItem value="efectivo">Efectivo</MenuItem>
              <MenuItem value="tarjeta">Tarjeta de Débito/Crédito</MenuItem>
              <MenuItem value="transferencia">Transferencia Bancaria</MenuItem>
              <MenuItem value="pago_movil">Pago Móvil</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogPago(false)}>Cancelar</Button>
          <Button variant="contained" onClick={procesarVenta} disabled={!metodoPago}>
            Confirmar Pago
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
