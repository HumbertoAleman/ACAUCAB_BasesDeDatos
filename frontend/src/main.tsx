import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';

// 1. Define tu tema de Material-UI
const theme = createTheme({
  palette: {
    primary: {
      main: '#556cd6', // Un azul ejemplo
    },
    secondary: {
      main: '#19857b', // Un verde teal ejemplo
    },
    // Puedes personalizar más aquí
  },
  typography: {
    fontFamily: 'Roboto, Arial, sans-serif',
  },
});

// 2. Monta tu aplicación React en el DOM
// Aquí el operador '!' le dice a TypeScript que estamos seguros de que 'root' existirá.
ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline /> {/* Resetea estilos para consistencia Material Design */}
      <App />
    </ThemeProvider>
  </React.StrictMode>,
);
