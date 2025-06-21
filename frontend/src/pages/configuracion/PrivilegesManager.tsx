import React, { useState, useEffect } from 'react';
import type { SelectChangeEvent } from '@mui/material';
import {
  Box, Typography, Select, MenuItem, FormControl, InputLabel,
  Table, TableBody, TableCell, TableContainer, TableHead, TableRow,
  Checkbox, Button, Paper, CircularProgress, Alert
} from '@mui/material';
import { userService, privilegeService } from '../../services/api';

// Define modules and permissions available in the system
const MODULES = [
  'usuario', 'rol', 'privilegio', 'cliente', 'empleado',
  'venta', 'inventario', 'compra', 'presentacion', 'evento'
];
const PERMISSIONS = ['create', 'read', 'update', 'delete'];

// Interfaces for the data
interface User {
  cod_usua: number;
  username_usua: string;
  rol: {
    nombre_rol: string;
    privileges: { nombre_priv: string }[];
  };
}

const PrivilegesManager: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [userPrivileges, setUserPrivileges] = useState<Record<string, string[]>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUsers = async () => {
      setIsLoading(true);
      const response = await userService.getUsersWithRoles();
      if (response.success && response.data) {
        // We only want to manage privileges for employees
        const employeeUsers = response.data.filter((u: any) => u.rol.nombre_rol !== 'Cliente Natural' && u.rol.nombre_rol !== 'Miembro');
        setUsers(employeeUsers);
      } else {
        setError('No se pudieron cargar los usuarios.');
      }
      setIsLoading(false);
    };

    fetchUsers();
  }, []);

  const handleUserChange = (event: SelectChangeEvent<number>) => {
    const userId = event.target.value as number;
    const user = users.find(u => u.cod_usua === userId) || null;
    setSelectedUser(user);

    if (user) {
      const privilegesMap: Record<string, string[]> = {};
      user.rol.privileges.forEach(priv => {
        const [module, permission] = priv.nombre_priv.split('_');
        if (!privilegesMap[module]) {
          privilegesMap[module] = [];
        }
        privilegesMap[module].push(permission);
      });
      setUserPrivileges(privilegesMap);
    } else {
      setUserPrivileges({});
    }
  };

  const handlePrivilegeChange = (module: string, permission: string, checked: boolean) => {
    setUserPrivileges(prev => {
      const newPrivileges = { ...prev };
      if (!newPrivileges[module]) {
        newPrivileges[module] = [];
      }

      if (checked) {
        newPrivileges[module] = [...newPrivileges[module], permission];
      } else {
        newPrivileges[module] = newPrivileges[module].filter(p => p !== permission);
      }
      return newPrivileges;
    });
  };

  const handleSaveChanges = async () => {
    if (!selectedUser) return;

    setIsSaving(true);
    const privilegesList: string[] = [];
    for (const module in userPrivileges) {
      for (const permission of userPrivileges[module]) {
        privilegesList.push(`${module}_${permission}`);
      }
    }

    const response = await privilegeService.updateUserPrivileges(selectedUser.cod_usua, privilegesList);
    if (!response.success) {
      setError('Error al guardar los privilegios. El backend podría no estar listo.');
    }
    setIsSaving(false);
    alert('Cambios guardados (simulado). El backend necesita implementar el endpoint.');
  };

  if (isLoading) {
    return <CircularProgress />;
  }

  return (
    <Box sx={{ p: 3, maxWidth: 1000, margin: 'auto' }}>
      <Typography variant="h4" gutterBottom>
        Gestión de Privilegios
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

      <FormControl fullWidth sx={{ mb: 3 }}>
        <InputLabel id="user-select-label">Seleccionar Empleado</InputLabel>
        <Select
          labelId="user-select-label"
          value={selectedUser?.cod_usua || ''}
          label="Seleccionar Empleado"
          onChange={handleUserChange}
        >
          {users.map(user => (
            <MenuItem key={user.cod_usua} value={user.cod_usua}>
              {user.username_usua} - ({user.rol.nombre_rol})
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {selectedUser && (
        <Paper>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Módulo</TableCell>
                  {PERMISSIONS.map(p => <TableCell key={p} align="center">{p.toUpperCase()}</TableCell>)}
                </TableRow>
              </TableHead>
              <TableBody>
                {MODULES.map(module => (
                  <TableRow key={module}>
                    <TableCell component="th" scope="row">{module}</TableCell>
                    {PERMISSIONS.map(permission => (
                      <TableCell key={permission} align="center">
                        <Checkbox
                          checked={userPrivileges[module]?.includes(permission) || false}
                          onChange={(e) => handlePrivilegeChange(module, permission, e.target.checked)}
                        />
                      </TableCell>
                    ))}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <Box sx={{ p: 2, display: 'flex', justifyContent: 'flex-end' }}>
            <Button
              variant="contained"
              onClick={handleSaveChanges}
              disabled={isSaving}
            >
              {isSaving ? <CircularProgress size={24} /> : 'Guardar Cambios'}
            </Button>
          </Box>
        </Paper>
      )}
    </Box>
  );
};

export default PrivilegesManager; 