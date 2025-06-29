"use client"

import type React from "react"
import { useState, useEffect } from "react"
import type { SelectChangeEvent } from "@mui/material"
import {
  Box,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Grid,
  FormControl,
  Select,
  MenuItem,
  Checkbox,
  FormGroup,
  FormControlLabel,
  Alert,
  CircularProgress,
  Tooltip,
  TextField,
  Stack,
  Autocomplete,
  InputLabel,
} from "@mui/material"
import { Security, Refresh, Edit, Delete, Add } from "@mui/icons-material"
import { useUsers } from "../../hooks/useUsers"
import { 
  privilegeService, 
  roleService, 
  updateUser,
  getClientesDetallados,
  createUsuarioCliente
} from "../../services/api"
import { useRoles } from "../../hooks/useRoles"
import type { Rol, Usuario, Privilegio } from "../../interfaces"

// Interfaz para la nueva estructura de privilegios agrupados
type GroupedPrivilegeActions = {
  create?: Privilegio;
  read?: Privilegio;
  update?: Privilegio;
  delete?: Privilegio;
}

export const GestionUsuarios: React.FC = () => {
  const { users, loading, error, refreshUsers, deleteUser } = useUsers()
  
  const [roles, setRoles] = useState<Rol[]>([])
  const [editModalOpen, setEditModalOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<Usuario | null>(null)
  const [editedUsername, setEditedUsername] = useState("")
  const [createModalOpen, setCreateModalOpen] = useState(false)
  const [newUsername, setNewUsername] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [newTipoUsuario, setNewTipoUsuario] = useState<string>("")
  const [newRelacionado, setNewRelacionado] = useState<any>(null)
  const [clientes, setClientes] = useState<any[]>([])
  
  // Estados para crear roles
  const [createRoleModalOpen, setCreateRoleModalOpen] = useState(false)
  const [newRoleName, setNewRoleName] = useState("")
  const [newRoleDescription, setNewRoleDescription] = useState("")
  
  // Simulación de listas para cada tipo (luego se reemplaza por fetch real)
  const listaEmpleados = [ { id: 1, nombre: "Empleado 1" }, { id: 2, nombre: "Empleado 2" } ]
  const listaMiembros = [ { id: 1, nombre: "Miembro 1" }, { id: 2, nombre: "Miembro 2" } ]
  const listaJuridicos = [ { id: 1, nombre: "Juridico 1" }, { id: 2, nombre: "Juridico 2" } ]
  const listaNaturales = [ { id: 1, nombre: "Natural 1" }, { id: 2, nombre: "Natural 2" } ]

  const fetchRoles = async () => {
    const response = await roleService.getRoles()
    if (Array.isArray(response)) {
      setRoles(response)
    } else {
      console.error("Error al cargar los roles:", (response as any).error)
    }
  }

  useEffect(() => {
    fetchRoles()
  }, [])
  
  useEffect(() => {
    getClientesDetallados().then((data) => {
      // Si la respuesta es un array de arrays, aplanar
      const clientesFlat = Array.isArray(data[0]) ? data.flat() : data;
      setClientes(clientesFlat || [])
    })
  }, [])
  
  const handleRoleChange = async (userId: number, event: SelectChangeEvent<number>) => {
    const newRoleId = event.target.value as number
    await updateUser({ cod_usua: userId, fk_rol: newRoleId })
    refreshUsers();
  }

  const handleOpenEditModal = (user: Usuario) => {
    setSelectedUser(user)
    setEditedUsername(user.username_usua)
    setEditModalOpen(true)
  }

  const handleSaveUsername = async () => {
    if (!selectedUser) return
    await updateUser({ 
      cod_usua: selectedUser.cod_usua,
      username_usua: editedUsername,
    })
    setEditModalOpen(false)
    setSelectedUser(null)
    refreshUsers();
  }

  const handleDeleteUser = async (userId: number) => {
    if (window.confirm("¿Está seguro de que desea eliminar este usuario? Esta acción es irreversible.")) {
      await deleteUser(userId)
    }
  }

  const handleCreateUsuario = async () => {
    if (!newUsername || !newPassword || !newRelacionado) return;
    const payload = {
      username_usua: newUsername,
      contra_usua: newPassword,
      fk_clie: newRelacionado.rif_clie,
      tipo_clie: newRelacionado.tipo_clie,
    };
    console.log("Payload enviado a /api/clientes:", payload);
    const res = await createUsuarioCliente(payload);
    if (res.success) {
      setCreateModalOpen(false);
      setNewUsername("");
      setNewPassword("");
      setNewTipoUsuario("");
      setNewRelacionado(null);
      refreshUsers();
      alert("Usuario creado exitosamente");
    } else {
      alert("Error al crear usuario: " + (res.error || "Error desconocido"));
    }
  }

  const handleCreateRole = async () => {
    if (!newRoleName.trim() || !newRoleDescription.trim()) {
      alert("Por favor complete todos los campos");
      return;
    }

    try {
      const response = await roleService.createRole({
        nombre_rol: newRoleName.trim(),
        descripcion_rol: newRoleDescription.trim()
      });

      if (response.success) {
        setCreateRoleModalOpen(false);
        setNewRoleName("");
        setNewRoleDescription("");
        await fetchRoles(); // Recargar la lista de roles
        alert("Rol creado exitosamente");
      } else {
        alert("Error al crear rol: " + (response.error || "Error desconocido"));
      }
    } catch (error) {
      console.error("Error al crear rol:", error);
      alert("Error de conexión al crear rol");
    }
  }

  if (loading || roles.length === 0) return <CircularProgress />

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
        <Typography variant="h4" gutterBottom>Gestión de Usuarios</Typography>
        <Box sx={{ display: "flex", gap: 2 }}>
          <Button variant="outlined" startIcon={<Refresh />} onClick={refreshUsers}>
            Actualizar
          </Button>
          <Button variant="outlined" startIcon={<Add />} onClick={() => setCreateRoleModalOpen(true)}>
            Crear Rol
          </Button>
          <Button variant="contained" color="primary" onClick={() => setCreateModalOpen(true)}>
            Crear Usuario
          </Button>
        </Box>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <Paper>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Usuario</TableCell>
                <TableCell>Rol Asignado</TableCell>
                <TableCell align="center">Acciones</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {users.map((user) => (
                <TableRow key={user.cod_usua}>
                  <TableCell>{user.username_usua}</TableCell>
                  <TableCell>
                    <FormControl size="small" sx={{ minWidth: 200 }}>
                      <Select
                        value={user.fk_rol}
                        onChange={(e) => handleRoleChange(user.cod_usua, e)}
                      >
                        {roles.map((rol) => (
                          <MenuItem key={rol.cod_rol} value={rol.cod_rol}>
                            {rol.nombre_rol}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  </TableCell>
                  <TableCell align="center">
                    <Stack direction="row" spacing={1} justifyContent="center">
                      <Tooltip title="Editar Nombre">
                        <IconButton size="small" onClick={() => handleOpenEditModal(user)}><Edit /></IconButton>
                      </Tooltip>
                      <Tooltip title="Eliminar Usuario">
                        <IconButton size="small" color="error" onClick={() => handleDeleteUser(user.cod_usua)}><Delete /></IconButton>
                      </Tooltip>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Modal de Edición de Usuario */}
      <Dialog open={editModalOpen} onClose={() => setEditModalOpen(false)}>
        <DialogTitle>Editar Nombre de Usuario</DialogTitle>
        <DialogContent sx={{ pt: '20px !important' }}>
          <TextField
            autoFocus
            margin="dense"
            id="username"
            label="Nombre de Usuario"
            type="text"
            fullWidth
            variant="outlined"
            value={editedUsername}
            onChange={(e) => setEditedUsername(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditModalOpen(false)}>Cancelar</Button>
          <Button onClick={handleSaveUsername} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      {/* Modal de Creación de Usuario */}
      <Dialog open={createModalOpen} onClose={() => setCreateModalOpen(false)}>
        <DialogTitle>Crear Usuario</DialogTitle>
        <DialogContent sx={{ pt: '20px !important', minWidth: 400 }}>
          <TextField
            autoFocus
            margin="dense"
            label="Nombre de Usuario"
            type="text"
            fullWidth
            variant="outlined"
            value={newUsername}
            onChange={e => setNewUsername(e.target.value)}
            sx={{ mb: 2 }}
          />
          <TextField
            margin="dense"
            label="Contraseña"
            type="password"
            fullWidth
            variant="outlined"
            value={newPassword}
            onChange={e => setNewPassword(e.target.value)}
            sx={{ mb: 2 }}
          />
          <FormControl fullWidth sx={{ mb: 2 }}>
            <InputLabel>Tipo de Usuario</InputLabel>
            <Select
              value={newTipoUsuario}
              label="Tipo de Usuario"
              onChange={e => {
                setNewTipoUsuario(e.target.value)
                setNewRelacionado(null)
              }}
            >
              <MenuItem value="juridico">Cliente Jurídico</MenuItem>
              <MenuItem value="natural">Cliente Natural</MenuItem>
            </Select>
          </FormControl>
          {newTipoUsuario && (
            <Autocomplete
              options={clientes.filter(c => (newTipoUsuario === "juridico" ? c.tipo_clie === "Juridico" : c.tipo_clie === "Natural"))}
              getOptionLabel={option => option.razon_social_juri || option.primer_nom_natu + ' ' + option.primer_ape_natu || option.rif_clie}
              value={newRelacionado}
              onChange={(_, value) => setNewRelacionado(value)}
              renderInput={params => <TextField {...params} label={`Seleccionar Cliente`} fullWidth />}
            />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateModalOpen(false)}>Cancelar</Button>
          <Button variant="contained" onClick={handleCreateUsuario} disabled={!newUsername || !newPassword || !newRelacionado}>Crear</Button>
        </DialogActions>
      </Dialog>

      {/* Modal de Creación de Rol */}
      <Dialog open={createRoleModalOpen} onClose={() => setCreateRoleModalOpen(false)}>
        <DialogTitle>Crear Rol</DialogTitle>
        <DialogContent sx={{ pt: '20px !important', minWidth: 400 }}>
          <TextField
            autoFocus
            margin="dense"
            label="Nombre del Rol"
            type="text"
            fullWidth
            variant="outlined"
            value={newRoleName}
            onChange={e => setNewRoleName(e.target.value)}
            sx={{ mb: 2 }}
          />
          <TextField
            margin="dense"
            label="Descripción del Rol"
            type="text"
            fullWidth
            variant="outlined"
            value={newRoleDescription}
            onChange={e => setNewRoleDescription(e.target.value)}
            sx={{ mb: 2 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateRoleModalOpen(false)}>Cancelar</Button>
          <Button variant="contained" onClick={handleCreateRole}>Crear</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}
