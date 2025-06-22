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
  const { users, loading, error, refreshUsers, updateUser, deleteUser } = useUsers()
  const { privileges, loading: loadingPrivileges } = useRoles()
  
  const [roles, setRoles] = useState<Rol[]>([])
  const [privilegeModalOpen, setPrivilegeModalOpen] = useState(false)
  const [editModalOpen, setEditModalOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<Usuario | null>(null)
  const [userPrivileges, setUserPrivileges] = useState<Record<string, boolean>>({})
  const [editedUsername, setEditedUsername] = useState("")

  // Lógica mejorada para agrupar privilegios por tabla y acción CRUD
  const getGroupedPrivileges = (): Record<string, GroupedPrivilegeActions> => {
    const grouped: Record<string, GroupedPrivilegeActions> = {};
    const validActions = new Set(['create', 'read', 'update', 'delete']);

    privileges.forEach(priv => {
      const parts = priv.nombre_priv.split('_');
      const action = parts.pop(); // La acción es la última parte
      
      if (action && validActions.has(action)) {
        const tableName = parts.join('_'); // La tabla es todo lo demás
        if (!grouped[tableName]) {
          grouped[tableName] = {};
        }
        grouped[tableName][action as keyof GroupedPrivilegeActions] = priv;
      }
    });
    return grouped;
  }

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
  
  const employeeUsers = users.filter(user => user.rol && !user.rol.nombre_rol.includes("Cliente"))

  const handleRoleChange = async (userId: number, event: SelectChangeEvent<number>) => {
    const newRoleId = event.target.value as number
    await updateUser(userId, { fk_rol: newRoleId })
  }

  const handleOpenPrivilegeModal = (user: Usuario) => {
    setSelectedUser(user)
    const initialPrivileges: Record<string, boolean> = {}
    console.log("Privilegios del usuario seleccionado:", user.rol?.privileges)
    privileges.forEach((priv: Privilegio) => {
      initialPrivileges[priv.nombre_priv] = user.rol?.privileges?.some((p: Privilegio) => p.nombre_priv === priv.nombre_priv) ?? false
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

  // Log para depuración antes del return
  if (!loadingPrivileges) {
    console.log("Privilegios a mostrar en el modal:", privileges)
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
          {loadingPrivileges ? (
            <CircularProgress />
          ) : (
            <Grid container spacing={3} sx={{ pt: 1 }}>
              {Object.entries(getGroupedPrivileges()).map(([tableName, actions]) => (
                <Grid size={{xs:12, sm:6, md:4}} key={tableName}>
                    
                  <Typography variant="h6" sx={{ textTransform: 'capitalize', mb: 1 }}>
                    {tableName.replace(/_/g, ' ')}
                  </Typography>
                  <FormGroup>
                    {(['create', 'read', 'update', 'delete'] as const).map(action => {
                      const priv = actions[action];
                      return (
                        <FormControlLabel
                          key={action}
                          disabled={!priv}
                          control={
                            <Checkbox
                              checked={priv ? userPrivileges[priv.nombre_priv] ?? false : false}
                              onChange={handlePrivilegeChange}
                              name={priv?.nombre_priv || ''}
                            />
                          }
                          label={action}
                        />
                      );
                    })}
                  </FormGroup>
                </Grid>
              ))}
            </Grid>
          )}
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
