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
} from "@mui/material"
import { Security, Refresh, Edit, Delete } from "@mui/icons-material"
import { useUsers } from "../../hooks/useUsers"
import { 
  privilegeService, 
  roleService, 
  updateUser
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

  useEffect(() => {
    const fetchRoles = async () => {
      const response = await roleService.getRoles()
      if (Array.isArray(response)) {
        setRoles(response)
      } else {
        console.error("Error al cargar los roles:", (response as any).error)
      }
    }
    fetchRoles()
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

  if (loading || roles.length === 0) return <CircularProgress />

  return (
    <Box sx={{ p: 3 }}>
      <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
        <Typography variant="h4" gutterBottom>Gestión de Usuarios</Typography>
        <Button variant="outlined" startIcon={<Refresh />} onClick={refreshUsers}>
          Actualizar
        </Button>
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
    </Box>
  )
}
