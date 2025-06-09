
import { Box, Typography, Button } from '@mui/material';

function App() {
  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: '#e0f7fa', // Color de fondo claro
        textAlign: 'center',
        p: 3, // Padding
      }}
    >
      <Typography variant="h3" component="h1" gutterBottom>
        ¡Bienvenido a ACAUCAB!
      </Typography>
      <Typography variant="h6" color="text.secondary" paragraph>
        Esta es la página de inicio de tu aplicación frontend.
      </Typography>
      <Typography variant="body1" sx={{ mb: 4 }}>
        Estamos listos para construir.
      </Typography>
      <Button variant="contained" color="primary" size="large">
        Comenzar
      </Button>
    </Box>
  );
}

export default App;