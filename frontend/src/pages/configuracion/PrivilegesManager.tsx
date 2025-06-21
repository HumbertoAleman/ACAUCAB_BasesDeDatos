"use client"

import type React from "react"
import { Box, Typography, Paper, Alert } from "@mui/material"
import { Link as RouterLink } from "react-router-dom"

export const PrivilegesManager: React.FC = () => {
  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Gestión de Privilegios
      </Typography>
      <Paper sx={{ p: 2 }}>
        <Alert severity="info">
          La gestión de roles y privilegios de los usuarios ha sido movida a la página de{" "}
          <RouterLink to="/usuarios">
            <strong>Gestión de Usuarios</strong>
          </RouterLink>
          .
        </Alert>
        <Typography variant="body1" sx={{ mt: 2 }}>
          Desde allí, el administrador puede asignar roles y configurar los permisos CRUD específicos para cada módulo del sistema.
        </Typography>
      </Paper>
    </Box>
  )
} 