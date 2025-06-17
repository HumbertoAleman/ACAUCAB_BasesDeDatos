import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom"
import { ThemeProvider, createTheme } from "@mui/material/styles"
import CssBaseline from "@mui/material/CssBaseline"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { ReactQueryDevtools } from "@tanstack/react-query-devtools"

import { AuthProvider } from "./contexts/AuthContext"
import { ProtectedRoute } from "./components/ProtectedRoute"
import { Layout } from "./components/layout/Layout"
import { LoginForm } from "./components/auth/LoginForm"
import { Dashboard } from "./pages/Dashboard"
import { PuntoVenta } from "./pages/ventas/PuntoVenta"
import { GestionInventario } from "./pages/inventario/GestionInventario"
import { GestionUsuarios } from "./pages/usuarios/GestionUsuarios"
import { Reportes } from "./pages/reportes/Reportes"

// Crear cliente de React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
})

// Tema personalizado para ACAUCAB
const theme = createTheme({
  palette: {
    primary: {
      main: "#2E7D32",
      light: "#4CAF50",
      dark: "#1B5E20",
    },
    secondary: {
      main: "#FF8F00",
      light: "#FFB74D",
      dark: "#E65100",
    },
    background: {
      default: "#f8f9fa",
      paper: "#ffffff",
    },
    success: {
      main: "#4CAF50",
    },
    warning: {
      main: "#FF9800",
    },
    error: {
      main: "#f44336",
    },
  },
  typography: {
    fontFamily: "Roboto, Arial, sans-serif",
    h4: {
      fontWeight: 600,
    },
    h5: {
      fontWeight: 600,
    },
    h6: {
      fontWeight: 500,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: "none",
          borderRadius: 8,
          fontWeight: 500,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: "0 2px 12px rgba(0,0,0,0.08)",
          border: "1px solid rgba(0,0,0,0.05)",
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
        },
      },
    },
    MuiTextField: {
      styleOverrides: {
        root: {
          "& .MuiOutlinedInput-root": {
            borderRadius: 8,
          },
        },
      },
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AuthProvider>
          <Router>
            <Routes>
              <Route path="/login" element={<LoginForm />} />
              <Route
                path="/*"
                element={
                  <ProtectedRoute>
                    <Layout>
                      <Routes>
                        <Route path="/" element={<Navigate to="/dashboard" replace />} />
                        <Route path="/dashboard" element={<Dashboard />} />
                        <Route path="/ventas" element={<PuntoVenta />} />
                        <Route path="/inventario" element={<GestionInventario />} />
                        <Route path="/usuarios" element={<GestionUsuarios />} />
                        <Route path="/reportes" element={<Reportes />} />
                        <Route path="/configuracion" element={<div>Configuración - En desarrollo</div>} />
                        <Route path="*" element={<Navigate to="/dashboard" replace />} />
                      </Routes>
                    </Layout>
                  </ProtectedRoute>
                }
              />
            </Routes>
          </Router>
        </AuthProvider>
      </ThemeProvider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}

export default App
