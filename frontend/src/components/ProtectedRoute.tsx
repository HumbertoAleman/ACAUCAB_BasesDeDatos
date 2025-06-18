"use client"

import type React from "react"
import { Navigate, useLocation } from "react-router-dom"
import { useAuth } from "../contexts/AuthContext"
import { Box, CircularProgress, Typography } from "@mui/material"
import { checkRouteAccess, getFirstAccessibleRoute } from "../config/routes"

interface ProtectedRouteProps {
  children: React.ReactNode
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { user, isLoading, hasPermission } = useAuth()
  const location = useLocation()

  if (isLoading) {
    return (
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          alignItems: "center",
          height: "100vh",
          gap: 2,
        }}
      >
        <CircularProgress size={60} sx={{ color: "#2E7D32" }} />
        <Typography variant="h6" color="text.secondary">
          Cargando sistema...
        </Typography>
      </Box>
    )
  }

  if (!user) {
    // Guardar la ubicación actual para redirigir después del login
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  // Verificar si el usuario tiene acceso a la ruta actual
  const currentPath = location.pathname
  const hasAccess = checkRouteAccess(currentPath, hasPermission)
  
  if (!hasAccess) {
    // Redirigir a la primera página a la que tiene acceso
    const accessibleRoute = getFirstAccessibleRoute(hasPermission)
    return <Navigate to={accessibleRoute} replace />
  }

  return <>{children}</>
}
