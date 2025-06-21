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
import { privilegeService, roleService } from "../../services/api"
import type { Rol, Usuario } from "../../interfaces"

// Genera dinámicamente los módulos a partir de las interfaces de negocio
const businessInterfaces = ["cervezas", "eventos", "miembros", "personal", "tiendas", "ventas", "usuarios"]
const systemModules = businessInterfaces.map(name => ({
    key: name,
    label: name.charAt(0).toUpperCase() + name.slice(1) // Capitaliza el nombre para el UI
}))

const crudActions = ["create", "read", "update", "delete"]

export const GestionUsuarios: React.FC = () => {
  const { users, loading, error, refreshUsers, updateUser, deleteUser } = useUsers()
  
  const [roles, setRoles] = useState<Rol[]>([])
  const [privilegeModalOpen, setPrivilegeModalOpen] = useState(false)
  const [editModalOpen, setEditModalOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<Usuario | null>(null)
  const [userPrivileges, setUserPrivileges] = useState<Record<string, boolean>>({})
  const [editedUsername, setEditedUsername] = useState("")

  useEffect(() => {
    const fetchRoles = async () => {
      const response = await roleService.getRoles()
      // La API puede devolver un array directamente en caso de éxito.
      if (Array.isArray(response)) {
        setRoles(response)
      } else {
        console.error("Error al cargar los roles:", (response as any).error)
      }
    }
    fetchRoles()
  }, [])
  
  const employeeUsers = users.filter(user => user.rol && !user.rol.nombre_rol.includes("Cliente"))

  const handleRoleChange = async (userId: number, event: SelectChangeEvent<number>) => {
    const newRoleId = event.target.value as number
    await updateUser(userId, { fk_rol: newRoleId })
  }

  const handleOpenPrivilegeModal = (user: Usuario) => {
    setSelectedUser(user)
    const initialPrivileges: Record<string, boolean> = {}
    systemModules.forEach(module => {
      crudActions.forEach(action => {
        const privilegeName = `${module.key}_${action}`
        initialPrivileges[privilegeName] = user.rol.privileges?.some(p => p.nombre_priv === privilegeName) ?? false
      })
    })
    setUserPrivileges(initialPrivileges)
    setPrivilegeModalOpen(true)
  }

  const handlePrivilegeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setUserPrivileges({
      ...userPrivileges,
      [event.target.name]: event.target.checked,
    })
  }

  const handleSavePrivileges = async () => {
    if (!selectedUser) return

    const updatedPrivileges = Object.keys(userPrivileges).filter(key => userPrivileges[key])
    
    console.log("Enviando al backend para el usuario", selectedUser.cod_usua, ":", { privileges: updatedPrivileges })
    
    await privilegeService.updateUserPrivileges(selectedUser.cod_usua, updatedPrivileges)
    
    setPrivilegeModalOpen(false)
    setSelectedUser(null)
    refreshUsers()
  }

  const handleOpenEditModal = (user: Usuario) => {
    setSelectedUser(user)
    setEditedUsername(user.username_usua)
    setEditModalOpen(true)
  }

  const handleSaveUsername = async () => {
    if (!selectedUser) return
    await updateUser(selectedUser.cod_usua, { username_usua: editedUsername })
    setEditModalOpen(false)
    setSelectedUser(null)
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
              {employeeUsers.map((user) => (
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
                      <Tooltip title="Editar Usuario">
                        <IconButton size="small" onClick={() => handleOpenEditModal(user)}><Edit /></IconButton>
                      </Tooltip>
                      <Tooltip title="Gestionar Privilegios">
                        <IconButton size="small" onClick={() => handleOpenPrivilegeModal(user)}><Security /></IconButton>
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

      {/* Modal de Privilegios */}
      <Dialog open={privilegeModalOpen} onClose={() => setPrivilegeModalOpen(false)} maxWidth="md">
        <DialogTitle>Gestionar Privilegios para {selectedUser?.username_usua}</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ pt: 1 }}>
            {systemModules.map((module) => (
              <Grid size={{ xs: 12, sm: 6, md: 3 }} key={module.key}>
                <Typography variant="h6">{module.label}</Typography>
                <FormGroup>
                  {crudActions.map((action) => {
                    const privilegeName = `${module.key}_${action}`
                    return (
                      <FormControlLabel
                        key={privilegeName}
                        control={
                          <Checkbox
                            checked={userPrivileges[privilegeName] ?? false}
                            onChange={handlePrivilegeChange}
                            name={privilegeName}
                          />
                        }
                        label={action.charAt(0).toUpperCase() + action.slice(1)}
                      />
                    )
                  })}
                </FormGroup>
              </Grid>
            ))}
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setPrivilegeModalOpen(false)}>Cancelar</Button>
          <Button onClick={handleSavePrivileges} variant="contained">Guardar Cambios</Button>
        </DialogActions>
      </Dialog>
      
      {/* Modal de Edición de Usuario */}
      <Dialog open={editModalOpen} onClose={() => setEditModalOpen(false)}>
        <DialogTitle>Editar Usuario</DialogTitle>
        <DialogContent sx={{ pt: '20px !important' }}>
          <TextField
            label="Nombre de Usuario"
            fullWidth
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
