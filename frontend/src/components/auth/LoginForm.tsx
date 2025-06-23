"use client"

import type React from "react"
import { useState } from "react"
import { Box, Card, CardContent, TextField, Button, Typography, Alert, Container, Avatar } from "@mui/material"
import { LocalBar } from "@mui/icons-material"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { useAuth } from "../../contexts/AuthContext"
import { useLocation, Navigate, useNavigate } from "react-router-dom"

const loginSchema = z.object({
  username: z.string().min(1, "El usuario es requerido"),
  password: z.string().min(1, "La contraseña es requerida"),
})

type LoginFormData = z.infer<typeof loginSchema>

export const LoginForm: React.FC = () => {
  const { user, login, isLoading } = useAuth()
  const [error, setError] = useState<string>("")
  const location = useLocation()
  const navigate = useNavigate()

  // Si ya está autenticado, redirigir al dashboard o a la página original
  if (user) {
    const from = (location.state as any)?.from?.pathname || "/dashboard"
    return <Navigate to={from} replace />
  }

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginFormData) => {
    try {
      setError("")
      await login(data)
      // La redirección se maneja automáticamente en el AuthContext
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "Error de conexión. Verifique su conexión a internet."
      setError(errorMessage)
    }
  }

  return (
    <Container component="main" maxWidth="sm">
      <Box
        sx={{
          marginTop: 8,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <Card sx={{ width: "100%", maxWidth: 400 }}>
          <CardContent sx={{ p: 4 }}>
            <Box sx={{ display: "flex", flexDirection: "column", alignItems: "center", mb: 3 }}>
              <Avatar sx={{ m: 1, bgcolor: "#2E7D32", width: 56, height: 56 }}>
                <LocalBar />
              </Avatar>
              <Typography component="h1" variant="h4" sx={{ color: "#2E7D32", fontWeight: "bold" }}>
                ACAUCAB
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Sistema de Gestión
              </Typography>
            </Box>

            {error && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {error}
              </Alert>
            )}

            <Box component="form" onSubmit={handleSubmit(onSubmit)} sx={{ mt: 1 }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="username"
                label="Usuario"
                autoComplete="username"
                autoFocus
                {...register("username")}
                error={!!errors.username}
                helperText={errors.username?.message}
              />
              <TextField
                margin="normal"
                required
                fullWidth
                label="Contraseña"
                type="password"
                id="password"
                autoComplete="current-password"
                {...register("password")}
                error={!!errors.password}
                helperText={errors.password?.message}
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                sx={{
                  mt: 3,
                  mb: 2,
                  backgroundColor: "#2E7D32",
                  "&:hover": {
                    backgroundColor: "#1B5E20",
                  },
                }}
                disabled={isLoading}
              >
                {isLoading ? "Iniciando sesión..." : "Iniciar Sesión"}
              </Button>
              <Button
                fullWidth
                variant="outlined"
                sx={{ mb: 2 }}
                onClick={() => navigate("/registro-cliente")}
              >
                Registrarse
              </Button>
            </Box>

            <Box sx={{ mt: 2, p: 2, backgroundColor: "#f5f5f5", borderRadius: 1 }}>
              <Typography variant="caption" color="text.secondary">
                <strong>Nota:</strong> Ingrese sus credenciales del sistema ACAUCAB.
                <br />
                Si tiene problemas para acceder, contacte al administrador.
              </Typography>
            </Box>
          </CardContent>
        </Card>
      </Box>
    </Container>
  )
}
