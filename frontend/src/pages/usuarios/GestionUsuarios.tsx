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
  Alert,
  CircularProgress,
} from "@mui/material"
import { Search, Add, Edit, Delete, Security, Refresh } from "@mui/icons-material"
import type { Usuario, Rol, Privilegio } from "../../interfaces"
import { useUsers } from "../../hooks/useUsers"
import { useAuth } from "../../contexts/AuthContext"

export const GestionUsuarios: React.FC = () => {
  const { hasPermission } = useAuth()
  const {
    users,
    roles,
    privileges,
    loading,
    error,
    createUser,
    updateUser,
    deleteUser,
    refreshUsers,
  } = useUsers()

  const [busqueda, setBusqueda] = useState("")
  const [dialogUsuario, setDialogUsuario] = useState(false)
  const [usuarioSeleccionado, setUsuarioSeleccionado] = useState<Usuario | null>(null)
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    fk_rol: "",
  })

  // Verificar permisos
  if (!hasPermission("usuarios")) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          No tiene permisos para acceder a la gestión de usuarios.
        </Alert>
      </Box>
    )
  }

  const usuariosFiltrados = users.filter((usuario) =>
    usuario.username_usua.toLowerCase().includes(busqueda.toLowerCase()),
  )

  const handleNuevoUsuario = () => {
    setUsuarioSeleccionado(null)
    setFormData({
      username: "",
      password: "",
      fk_rol: "",
    })
    setDialogUsuario(true)
  }

  const handleEditarUsuario = (usuario: Usuario) => {
    setUsuarioSeleccionado(usuario)
    setFormData({
      username: usuario.username_usua,
      password: "",
      fk_rol: usuario.fk_rol.toString(),
    })
    setDialogUsuario(true)
  }

  const handleEliminarUsuario = async (usuario: Usuario) => {
    if (window.confirm(`¿Está seguro de eliminar al usuario ${usuario.username_usua}?`)) {
      await deleteUser(usuario.cod_usua)
    }
  }

  const handleGuardarUsuario = async () => {
    const userData = {
      username_usua: formData.username,
      contra_usua: formData.password,
      fk_rol: parseInt(formData.fk_rol),
    }

    let success = false
    if (usuarioSeleccionado) {
      success = await updateUser(usuarioSeleccionado.cod_usua, userData)
    } else {
      success = await createUser(userData)
    }

    if (success) {
      setDialogUsuario(false)
      setFormData({ username: "", password: "", fk_rol: "" })
    }
  }

  const getRolNombre = (fk_rol: number) => {
    const rol = roles.find(r => r.cod_rol === fk_rol)
    return rol ? rol.nombre_rol : "Sin rol"
  }

  if (loading) {
    return (
      <Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", height: "50vh" }}>
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Gestión de Usuarios y Roles
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <Grid container spacing={3}>
        {/* Gestión de Usuarios */}
        <Grid size={{ xs: 12, lg: 8 }}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
              <Typography variant="h6">Usuarios del Sistema</Typography>
              <Box>
                <Button
                  variant="outlined"
                  startIcon={<Refresh />}
                  onClick={refreshUsers}
                  sx={{ mr: 1 }}
                >
                  Actualizar
                </Button>
                <Button variant="contained" startIcon={<Add />} onClick={handleNuevoUsuario}>
                  Nuevo Usuario
                </Button>
              </Box>
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
                    <TableCell>Privilegios</TableCell>
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
                        <Chip label={getRolNombre(usuario.fk_rol)} color="primary" size="small" />
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: "flex", gap: 0.5, flexWrap: "wrap" }}>
                          {usuario.privileges?.slice(0, 3).map((priv) => (
                            <Chip
                              key={priv.cod_priv}
                              label={priv.nombre_priv}
                              color="secondary"
                              size="small"
                              variant="outlined"
                            />
                          ))}
                          {usuario.privileges && usuario.privileges.length > 3 && (
                            <Chip
                              label={`+${usuario.privileges.length - 3}`}
                              size="small"
                              variant="outlined"
                            />
                          )}
                        </Box>
                      </TableCell>
                      <TableCell align="center">
                        <IconButton size="small" color="primary" onClick={() => handleEditarUsuario(usuario)}>
                          <Edit />
                        </IconButton>
                        <IconButton 
                          size="small" 
                          color="error"
                          onClick={() => handleEliminarUsuario(usuario)}
                        >
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
        <Grid size={{ xs: 12, lg: 4 }}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
              <Typography variant="h6">Roles del Sistema</Typography>
              <Button variant="outlined" startIcon={<Security />} size="small">
                Nuevo Rol
              </Button>
            </Box>

            {roles.map((rol) => (
              <Box key={rol.cod_rol} sx={{ mb: 2, p: 2, border: "1px solid #e0e0e0", borderRadius: 1 }}>
                <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 1 }}>
                  <Typography variant="subtitle2">{rol.nombre_rol}</Typography>
                  <IconButton size="small">
                    <Edit />
                  </IconButton>
                </Box>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                  {rol.descripcion_rol}
                </Typography>
                <Box sx={{ display: "flex", gap: 0.5, flexWrap: "wrap" }}>
                  {rol.privileges?.slice(0, 2).map((priv) => (
                    <Chip
                      key={priv.cod_priv}
                      label={priv.nombre_priv}
                      color="secondary"
                      size="small"
                      variant="outlined"
                    />
                  ))}
                  {rol.privileges && rol.privileges.length > 2 && (
                    <Chip
                      label={`+${rol.privileges.length - 2}`}
                      size="small"
                      variant="outlined"
                    />
                  )}
                </Box>
              </Box>
            ))}
          </Paper>
        </Grid>
      </Grid>

      {/* Dialog para crear/editar usuario */}
      <Dialog open={dialogUsuario} onClose={() => setDialogUsuario(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          {usuarioSeleccionado ? "Editar Usuario" : "Nuevo Usuario"}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 1 }}>
            <TextField
              fullWidth
              label="Nombre de usuario"
              value={formData.username}
              onChange={(e) => setFormData({ ...formData, username: e.target.value })}
              sx={{ mb: 2 }}
            />
            <TextField
              fullWidth
              label="Contraseña"
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              sx={{ mb: 2 }}
              helperText={usuarioSeleccionado ? "Dejar vacío para mantener la contraseña actual" : ""}
            />
            <FormControl fullWidth>
              <InputLabel>Rol</InputLabel>
              <Select
                value={formData.fk_rol}
                label="Rol"
                onChange={(e) => setFormData({ ...formData, fk_rol: e.target.value })}
              >
                {roles.map((rol) => (
                  <MenuItem key={rol.cod_rol} value={rol.cod_rol}>
                    {rol.nombre_rol}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogUsuario(false)}>Cancelar</Button>
          <Button onClick={handleGuardarUsuario} variant="contained">
            {usuarioSeleccionado ? "Actualizar" : "Crear"}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
