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
  Checkbox,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  CircularProgress,
  Alert,
  Grid,
} from "@mui/material"
import { Save, Refresh } from "@mui/icons-material"
import { roleService, privilegeService } from "../../services/api"
import type { Rol, Privilegio, PrivilegiosPayload } from "../../interfaces"

// Interfaz para la estructura de privilegios agrupados por acción
type GroupedPrivilegeActions = {
  create?: Privilegio;
  read?: Privilegio;
  update?: Privilegio;
  delete?: Privilegio;
}

// Interfaz para los privilegios agrupados por tabla/entidad
type GroupedPrivileges = Record<string, GroupedPrivilegeActions>;

export const GestionPrivilegios: React.FC = () => {
  const [roles, setRoles] = useState<Rol[]>([])
  const [allPrivileges, setAllPrivileges] = useState<Privilegio[]>([])
  const [selectedRoleId, setSelectedRoleId] = useState<number | string>("")
  const [rolePrivileges, setRolePrivileges] = useState<Set<number>>(new Set())
  const [lastRolePrivileges, setLastRolePrivileges] = useState<Set<number>>(new Set())
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Carga inicial de roles y privilegios
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true)
      setError(null)
      try {
        const rolesResponse = await roleService.getRoles()
        const privilegesResponse = await privilegeService.getPrivileges()
        
        if (Array.isArray(rolesResponse)) {
          setRoles(rolesResponse)
        } else {
          throw new Error("Respuesta inválida al cargar los roles")
        }
        
        if (Array.isArray(privilegesResponse)) {
          setAllPrivileges(privilegesResponse)
        } else {
          throw new Error("Respuesta inválida al cargar los privilegios")
        }

      } catch (err) {
        setError(err instanceof Error ? err.message : "Error de conexión")
      } finally {
        setLoading(false)
      }
    }
    fetchData()
  }, [])

  // Cargar los privilegios del rol seleccionado
  useEffect(() => {
    if (!selectedRoleId) {
      setRolePrivileges(new Set());
      setLastRolePrivileges(new Set());
      return;
    }
    const fetchRolePrivileges = async () => {
      setError(null)
      try {
        const response = await roleService.getRolePrivileges(Number(selectedRoleId))
        if (Array.isArray(response)) {
          const privilegeIds = new Set(response.map((p) => p.cod_priv))
          setRolePrivileges(privilegeIds)
          setLastRolePrivileges(new Set(privilegeIds))
        } else {
          setError("Error al cargar los privilegios del rol")
        }
      } catch (err) {
        setError("Error de conexión al obtener los privilegios del rol.")
      }
    }
    fetchRolePrivileges()
  }, [selectedRoleId])

  // Agrupar privilegios por entidad y acción
  const groupedPrivileges = allPrivileges.reduce<GroupedPrivileges>((acc, priv) => {
    const parts = priv.nombre_priv.split('_');
    const action = parts.pop() as keyof GroupedPrivilegeActions;
    const tableName = parts.join('_');
    if (!acc[tableName]) {
      acc[tableName] = {};
    }
    acc[tableName][action] = priv;
    return acc;
  }, {});

  const handleRoleChange = (event: SelectChangeEvent<number | string>) => {
    setSelectedRoleId(event.target.value);
  };

  const handlePrivilegeChange = (privilegeId: number, isChecked: boolean) => {
    const newPrivileges = new Set(rolePrivileges);
    if (isChecked) {
      newPrivileges.add(privilegeId);
    } else {
      newPrivileges.delete(privilegeId);
    }
    setRolePrivileges(newPrivileges);
  };
  
  const handleSaveChanges = async () => {
    if (!selectedRoleId) return;
    // Determinar privilegios agregados y eliminados
    const current = rolePrivileges;
    const previous = lastRolePrivileges;
    const priv_agre = Array.from(current);
    const priv_elim = Array.from(previous).filter((id) => !current.has(id));
    const payload: PrivilegiosPayload = {
      cod_rol: Number(selectedRoleId),
      priv_agre,
      priv_elim,
    };
    try {
      const response = await privilegeService.saveRolePrivileges(payload);
      if (response.success) {
        setLastRolePrivileges(new Set(current));
        alert("Privilegios guardados correctamente.");
      } else {
        setError(response.error || "Error al guardar los privilegios");
      }
    } catch (err) {
      setError("Error de conexión al guardar los privilegios.");
    }
  };

  const handleRefresh = () => {
    if (selectedRoleId) {
        const currentId = selectedRoleId;
        setSelectedRoleId(""); // Deselecciona para limpiar la tabla
        setTimeout(() => setSelectedRoleId(currentId), 0); // Vuelve a seleccionar para recargar
    }
  }

  if (loading) return <CircularProgress sx={{ display: 'block', margin: '2rem auto' }} />;

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>Gestión de Privilegios por Rol</Typography>
      
      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <Paper sx={{ p: 2, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid size={{ xs: 12, md: 6 }}>
            <FormControl fullWidth>
              <InputLabel id="role-select-label">Seleccionar Rol</InputLabel>
              <Select
                labelId="role-select-label"
                value={selectedRoleId}
                label="Seleccionar Rol"
                onChange={handleRoleChange}
              >
                <MenuItem value="">
                  <em>-- Ninguno --</em>
                </MenuItem>
                {roles.map((rol) => (
                  <MenuItem key={rol.cod_rol} value={rol.cod_rol}>
                    {rol.nombre_rol}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Grid>
          <Grid size={{ xs: 12, md: 6 }} sx={{ textAlign: { xs: 'left', md: 'right' }, mt: { xs: 2, md: 0 } }}>
            <Button sx={{ mr: 1 }} variant="outlined" startIcon={<Refresh />} onClick={handleRefresh} disabled={!selectedRoleId}>
                Refrescar
            </Button>
            <Button variant="contained" startIcon={<Save />} onClick={handleSaveChanges} disabled={!selectedRoleId}>
              Guardar Cambios
            </Button>
          </Grid>
        </Grid>
      </Paper>
      
      {selectedRoleId && (
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell sx={{ fontWeight: 'bold' }}>Entidad</TableCell>
                <TableCell align="center" sx={{ fontWeight: 'bold' }}>Crear</TableCell>
                <TableCell align="center" sx={{ fontWeight: 'bold' }}>Leer</TableCell>
                <TableCell align="center" sx={{ fontWeight: 'bold' }}>Actualizar</TableCell>
                <TableCell align="center" sx={{ fontWeight: 'bold' }}>Eliminar</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {Object.entries(groupedPrivileges).sort(([a], [b]) => a.localeCompare(b)).map(([tableName, actions]) => (
                <TableRow key={tableName}>
                  <TableCell sx={{ textTransform: 'capitalize' }}>
                    {tableName.replace(/_/g, ' ')}
                  </TableCell>
                  {(['create', 'read', 'update', 'delete'] as const).map(action => {
                    const privilege = actions[action];
                    return (
                      <TableCell key={action} align="center">
                        {privilege ? (
                          <Checkbox
                            checked={rolePrivileges.has(privilege.cod_priv)}
                            onChange={(e) => handlePrivilegeChange(privilege.cod_priv, e.target.checked)}
                          />
                        ) : (
                          <span>-</span>
                        )}
                      </TableCell>
                    );
                  })}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  )
} 