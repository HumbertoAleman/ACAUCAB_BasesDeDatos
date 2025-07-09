import React from "react";
import { Box, Typography, Paper } from "@mui/material";

const Dashboard: React.FC = () => {
  return (
    <Box sx={{ p: 4 }}>
      <Paper elevation={3} sx={{ p: 4, textAlign: "center" }}>
        <Typography variant="h4" sx={{ fontWeight: "bold", mb: 2 }}>
          Dashboard de Reportes
        </Typography>
        <Typography variant="body1" color="textSecondary">
          Aquí se mostrarán los indicadores y reportes interactivos.
        </Typography>
      </Paper>
    </Box>
  );
};

export default Dashboard; 