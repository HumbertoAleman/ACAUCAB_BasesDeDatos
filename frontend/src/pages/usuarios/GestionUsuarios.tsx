"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Checkbox,
  FormGroup,
} from "@mui/material"
import { Search, Add, Edit, Delete, Security } from "@mui/icons-material"
import type { Usuario, Rol, Privilegio } from "../../interfaces"

// Datos de ejemplo basados en las interfaces
const usuariosEjemplo: (Usuario & { rol_nombre?: string })[] = [
  {
    cod_usua: 1,
    username_usua: "admin",
    contra_usua: "",
    fk_rol: 1,
    rol_nombre: "Administrador",
  },
  {
    cod_usua: 2,
    username_usua: "vendedor1",
    contra_usua: "",
    fk_rol: 2,
    rol_nombre: "Vendedor",
  },
  {
    cod_usua: 3,
    username_usua: "empleado1",
    contra_usua: "",
    fk_rol: 3,
    rol_nombre: "Empleado",
  },
]

const rolesDisponibles: Rol[] = [
  {
    cod_rol: 1,
    nombre_rol: "Administrador",
    descripcion_rol: "Acceso completo al sistema",
  },
  {
    cod_rol: 2,
    nombre_rol: "Vendedor",
    descripcion_rol: "Acceso a ventas e inventario",
  },
  {
    cod_rol: 3,
    nombre_rol: "Empleado",
    descripcion_rol: "Acceso básico",
  },
]

const privilegiosDisponibles: Privilegio[] = [
  { cod_priv: 1, nombre_priv: "ventas", descripcion_priv: "Gestión de ventas" },
  { cod_priv: 2, nombre_priv: "inventario", descripcion_priv: "Gestión de inventario" },
  { cod_priv: 3, nombre_priv: "reportes", descripcion_priv: "Acceso a reportes" },
  { cod_priv: 4, nombre_priv: "usuarios", descripcion_priv: "Gestión de usuarios" },
]

export const GestionUsuarios: React.FC = () => {
  const [busqueda, setBusqueda] = useState("")
  const [dialogUsuario, setDialogUsuario] = useState(false)
  const [dialogRol, setDialogRol] = useState(false)
  const [usuarioSeleccionado, setUsuarioSeleccionado] = useState<(typeof usuariosEjemplo)[0] | null>(null)
  const [rolSeleccionado, setRolSeleccionado] = useState<Rol | null>(null)
  const [privilegiosSeleccionados, setPrivilegiosSeleccionados] = useState<number[]>([])

  const usuariosFiltrados = usuariosEjemplo.filter((usuario) =>
    usuario.username_usua.toLowerCase().includes(busqueda.toLowerCase()),
  )

  const handleEditarUsuario = (usuario: (typeof usuariosEjemplo)[0]) => {
    setUsuarioSeleccionado(usuario)
    setDialogUsuario(true)
  }

  const handleEditarRol = (rol: Rol) => {
    setRolSeleccionado(rol)
    setPrivilegiosSeleccionados([])
    setDialogRol(true)
  }

  const handlePrivilegioChange = (privilegioId: number, checked: boolean) => {
    if (checked) {
      setPrivilegiosSeleccionados([...privilegiosSeleccionados, privilegioId])
    } else {
      setPrivilegiosSeleccionados(privilegiosSeleccionados.filter((id) => id !== privilegioId))
    }
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Gestión de Usuarios y Roles
      </Typography>

      <Grid container spacing={3}>
        {/* Gestión de Usuarios */}
        <Grid item xs={12} lg={8}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
              <Typography variant="h6">Usuarios del Sistema</Typography>
              <Button variant="contained" startIcon={<Add />} onClick={() => setDialogUsuario(true)}>
                Nuevo Usuario
              </Button>
            </Box>

            <TextField
              fullWidth
              placeholder="Buscar usuarios..."
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              sx={{ mb: 2 }}
              InputProps={{
                startAdornment: <Search sx={{ mr: 1, color: "text.secondary" }} />,
              }}
            />

            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Usuario</TableCell>
                    <TableCell>Rol</TableCell>
                    <TableCell>Estado</TableCell>
                    <TableCell align="center">Acciones</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {usuariosFiltrados.map((usuario) => (
                    <TableRow key={usuario.cod_usua}>
                      <TableCell>
                        <Typography variant="subtitle2">{usuario.username_usua}</Typography>
                      </TableCell>
                      <TableCell>
                        <Chip label={usuario.rol_nombre} color="primary" size="small" />
                      </TableCell>
                      <TableCell>
                        <Chip label="Activo" color="success" size="small" />
                      </TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary" onClick={() => handleEditarUsuario(usuario)}>
                          <Edit />
                        </IconButton>
                        <IconButton size="small" color="error">
                          <Delete />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          </Paper>
        </Grid>

        {/* Gestión de Roles */}
        <Grid item xs={12} lg={4}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
              <Typography variant="h6">Roles y Privilegios</Typography>
              <Button variant="outlined" startIcon={<Security />} size="small">
                Nuevo Rol
              </Button>
            </Box>

            {rolesDisponibles.map((rol) => (
              <Box key={rol.cod_rol} sx={{ mb: 2, p: 2, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 1 }}>
                  <Typography variant="subtitle2">{rol.nombre_rol}</Typography>
                  <IconButton size="small" onClick={() => handleEditarRol(rol)}>
                    <Edit />
                  </IconButton>
                </Box>
                <Typography variant="body2" color="text.secondary">
                  {rol.descripcion_rol}
                </Typography>
              </Box>
            ))}
          </Paper>
        </Grid>
      </Grid>

      {/* Dialog Usuario */}
      <Dialog open={dialogUsuario} onClose={() => setDialogUsuario(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{usuarioSeleccionado ? "Editar Usuario" : "Nuevo Usuario"}</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12}>
              <TextField fullWidth label="Nombre de Usuario" defaultValue={usuarioSeleccionado?.username_usua || ""} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth label="Contraseña" type="password" />
            </Grid>
            <Grid item xs={12}>
              <FormControl fullWidth>
                <InputLabel>Rol</InputLabel>
                <Select defaultValue={usuarioSeleccionado?.fk_rol || ""} label="Rol">
                  {rolesDisponibles.map((rol) => (
                    <MenuItem key={rol.cod_rol} value={rol.cod_rol}>
                      {rol.nombre_rol}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogUsuario(false)}>Cancelar</Button>
          <Button variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      {/* Dialog Rol */}
      <Dialog open={dialogRol} onClose={() => setDialogRol(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Editar Privilegios del Rol</DialogTitle>
        <DialogContent>
          <Typography variant="h6" gutterBottom>
            {rolSeleccionado?.nombre_rol}
          </Typography>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            Seleccione los privilegios para este rol:
          </Typography>

          <FormGroup>
            {privilegiosDisponibles.map((privilegio) => (
              <FormControlLabel
                key={privilegio.cod_priv}
                control={
                  <Checkbox
                    checked={privilegiosSeleccionados.includes(privilegio.cod_priv)}
                    onChange={(e) => handlePrivilegioChange(privilegio.cod_priv, e.target.checked)}
                  />
                }
                label={
                  <Box>
                    <Typography variant="body2">{privilegio.nombre_priv}</Typography>
                    <Typography variant="caption" color="text.secondary">
                      {privilegio.descripcion_priv}
                    </Typography>
                  </Box>
                }
              />
            ))}
          </FormGroup>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogRol(false)}>Cancelar</Button>
          <Button variant="contained">Guardar Privilegios</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
