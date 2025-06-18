"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Grid,
  Card,
  CardContent,
  CardMedia,
  Typography,
  Button,
  TextField,
  InputAdornment,
  IconButton,
  Badge,
  Paper,
  FormControlLabel,
  Radio,
  RadioGroup,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from "@mui/material"
import { Search, ShoppingCart, Add, Remove, Visibility, LocalOffer, Close } from "@mui/icons-material"
import { useNavigate } from "react-router-dom"
import type { Cerveza } from "../../interfaces"

// Datos de ejemplo basados en las interfaces
const productosEjemplo: (Cerveza & { precio_detal: number; precio_mayor: number; stock: number })[] = [
  {
    cod_cerv: 1,
    nombre_cerv: "Pale Ale Artesanal",
    fk_tipo_cerv: 1,
    precio_detal: 35.99,
    precio_mayor: 32.99,
    stock: 1250,
  },
  {
    cod_cerv: 2,
    nombre_cerv: "IPA Tropical",
    fk_tipo_cerv: 2,
    precio_detal: 38.5,
    precio_mayor: 35.0,
    stock: 850,
  },
  {
    cod_cerv: 3,
    nombre_cerv: "Stout Imperial",
    fk_tipo_cerv: 3,
    precio_detal: 42.0,
    precio_mayor: 38.5,
    stock: 450,
  },
]

interface ItemCarrito {
  producto: (typeof productosEjemplo)[0]
  cantidad: number
  tipo_precio: "detal" | "mayor"
  precio_unitario: number
  subtotal: number
}

export const CatalogoProductos: React.FC = () => {
  const navigate = useNavigate()
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedProduct, setSelectedProduct] = useState<(typeof productosEjemplo)[0] | null>(null)
  const [detailsOpen, setDetailsOpen] = useState(false)
  const [discountOpen, setDiscountOpen] = useState(false)
  const [carrito, setCarrito] = useState<ItemCarrito[]>([])
  const [cantidades, setCantidades] = useState<{ [key: number]: number }>({})
  const [tiposPrecios, setTiposPrecios] = useState<{ [key: number]: "detal" | "mayor" }>({})

  const handleAddToCart = (producto: (typeof productosEjemplo)[0]) => {
    const cantidad = cantidades[producto.cod_cerv] || 1
    const tipoPrecio = tiposPrecios[producto.cod_cerv] || "detal"
    const precioUnitario = tipoPrecio === "detal" ? producto.precio_detal : producto.precio_mayor

    const nuevoItem: ItemCarrito = {
      producto,
      cantidad,
      tipo_precio: tipoPrecio,
      precio_unitario: precioUnitario,
      subtotal: precioUnitario * cantidad,
    }

    setCarrito((prev) => [...prev, nuevoItem])
  }

  const handleQuantityChange = (productId: number, delta: number) => {
    setCantidades((prev) => ({
      ...prev,
      [productId]: Math.max(1, (prev[productId] || 1) + delta),
    }))
  }

  const handlePriceTypeChange = (productId: number, tipo: "detal" | "mayor") => {
    setTiposPrecios((prev) => ({
      ...prev,
      [productId]: tipo,
    }))
  }

  const handleViewDetails = (producto: (typeof productosEjemplo)[0]) => {
    setSelectedProduct(producto)
    setDetailsOpen(true)
  }

  const ProductCard: React.FC<{ producto: (typeof productosEjemplo)[0] }> = ({ producto }) => {
    const cantidad = cantidades[producto.cod_cerv] || 1
    const tipoPrecio = tiposPrecios[producto.cod_cerv] || "detal"
    const precio = tipoPrecio === "detal" ? producto.precio_detal : producto.precio_mayor
    const ahorro = producto.precio_detal - producto.precio_mayor

    return (
      <Card sx={{ height: "100%", display: "flex", flexDirection: "column" }}>
        <CardMedia
          component="img"
          height="200"
          image="/placeholder.svg?height=200&width=200"
          alt={producto.nombre_cerv}
          sx={{ backgroundColor: "#f5f5f5" }}
        />
        <CardContent sx={{ flexGrow: 1 }}>
          <Typography variant="h6" gutterBottom>
            {producto.nombre_cerv}
          </Typography>

          <Box sx={{ mb: 2 }}>
            <Typography variant="body2">Cantidad Disponible: {producto.stock}</Typography>
            <Typography variant="body2">Precio Unitario al detal: ${producto.precio_detal.toFixed(2)}</Typography>
            <Typography variant="body2">Precio Unitario al Mayor: ${producto.precio_mayor.toFixed(2)}</Typography>
            {ahorro > 0 && (
              <Typography variant="body2" color="success.main">
                Ahorro: ${ahorro.toFixed(2)}
              </Typography>
            )}
          </Box>

          <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 2 }}>
            <IconButton size="small" onClick={() => handleQuantityChange(producto.cod_cerv, -1)}>
              <Remove />
            </IconButton>
            <Typography variant="body1" sx={{ minWidth: 30, textAlign: "center" }}>
              {cantidad}
            </Typography>
            <IconButton size="small" onClick={() => handleQuantityChange(producto.cod_cerv, 1)}>
              <Add />
            </IconButton>
          </Box>

          <RadioGroup
            row
            value={tipoPrecio}
            onChange={(e) => handlePriceTypeChange(producto.cod_cerv, e.target.value as "detal" | "mayor")}
            sx={{ mb: 2 }}
          >
            <FormControlLabel value="mayor" control={<Radio size="small" />} label="Al mayor" />
            <FormControlLabel value="detal" control={<Radio size="small" />} label="Al detal" />
          </RadioGroup>

          <Box sx={{ display: "flex", gap: 1 }}>
            <Button
              variant="outlined"
              size="small"
              startIcon={<Visibility />}
              onClick={() => handleViewDetails(producto)}
              sx={{ flex: 1 }}
            >
              Ver en Detalle
            </Button>
            <Button
              variant="contained"
              size="small"
              startIcon={<ShoppingCart />}
              onClick={() => handleAddToCart(producto)}
              sx={{
                flex: 1,
                backgroundColor: "#2E7D32",
                "&:hover": { backgroundColor: "#1B5E20" },
              }}
            >
              Añadir al Carrito
            </Button>
          </Box>
        </CardContent>
      </Card>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 3 }}>
        <Typography variant="h4" sx={{ fontWeight: "bold", color: "#2E7D32" }}>
          Catálogo de Productos ACAUCAB
        </Typography>

        <Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
          <Button variant="outlined" onClick={() => navigate("/ordenes")}>
            Mis Órdenes
          </Button>
          <IconButton color="primary" onClick={() => navigate("/carrito")}>
            <Badge badgeContent={carrito.length} color="error">
              <ShoppingCart />
            </Badge>
          </IconButton>
        </Box>
      </Box>

      {/* Barra de búsqueda */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <TextField
          fullWidth
          placeholder="Buscar productos..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <Search />
              </InputAdornment>
            ),
          }}
        />
        <Typography variant="body2" sx={{ mt: 1, color: "text.secondary" }}>
          Todos nuestros productos ya incluyen IVA o IGTF si es en $
        </Typography>
      </Paper>

      {/* Grid de productos */}
      <Grid container spacing={3}>
        {productosEjemplo
          .filter((producto) => producto.nombre_cerv.toLowerCase().includes(searchTerm.toLowerCase()))
          .map((producto) => (
            <Grid size={{ xs: 12, md: 4, sm: 6, lg: 3 }} key={producto.cod_cerv}>
              <ProductCard producto={producto} />
            </Grid>
          ))}
      </Grid>

      {/* Dialog de detalles del producto */}
      <Dialog open={detailsOpen} onClose={() => setDetailsOpen(false)} maxWidth="md" fullWidth>
        <DialogTitle sx={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          Detalles del Producto
          <IconButton onClick={() => setDetailsOpen(false)}>
            <Close />
          </IconButton>
        </DialogTitle>
        <DialogContent>
          {selectedProduct && (
            <Box>
              <Grid container spacing={3}>
                <Grid size={{ xs: 12, md: 6 }}>
                  <img
                    src="/placeholder.svg?height=300&width=300"
                    alt={selectedProduct.nombre_cerv}
                    style={{ width: "100%", maxHeight: 300, objectFit: "cover" }}
                  />
                </Grid>
                <Grid size={{ xs: 12, md: 6 }}>
                  <Typography variant="h5" gutterBottom>
                    {selectedProduct.nombre_cerv}
                  </Typography>

                  <Box sx={{ mb: 2 }}>
                    <Typography variant="subtitle2">Especificaciones:</Typography>
                    <Typography variant="body2">Código: {selectedProduct.cod_cerv}</Typography>
                    <Typography variant="body2">Tipo: {selectedProduct.fk_tipo_cerv}</Typography>
                    <Typography variant="body2">Stock: {selectedProduct.stock}</Typography>
                  </Box>

                  <Button
                    variant="outlined"
                    startIcon={<LocalOffer />}
                    onClick={() => setDiscountOpen(true)}
                    sx={{ mt: 2 }}
                  >
                    Aplicar Descuento
                  </Button>
                </Grid>
              </Grid>
            </Box>
          )}
        </DialogContent>
      </Dialog>

      {/* Dialog de descuentos */}
      <Dialog open={discountOpen} onClose={() => setDiscountOpen(false)}>
        <DialogTitle>Aplicar Descuento</DialogTitle>
        <DialogContent>
          <FormControl fullWidth sx={{ mb: 2 }}>
            <InputLabel>Seleccione Descuento</InputLabel>
            <Select label="Seleccione Descuento">
              <MenuItem value="descuento1">Descuento Navideño - 15%</MenuItem>
              <MenuItem value="descuento2">Descuento por Volumen - 10%</MenuItem>
            </Select>
          </FormControl>
          <TextField fullWidth label="Fecha límite" type="date" InputLabelProps={{ shrink: true }} />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDiscountOpen(false)}>Cancelar</Button>
          <Button variant="contained" onClick={() => setDiscountOpen(false)}>
            Aplicar
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
