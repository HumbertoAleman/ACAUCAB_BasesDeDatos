"use client"

import type React from "react"
import { useState } from "react"
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
  Card,
  CardContent,
  IconButton,
  Chip,
  OutlinedInput,
  type SelectChangeEvent,
} from "@mui/material"
import { Add, Delete, Upload, LocalBar } from "@mui/icons-material"
import { useForm, useFieldArray } from "react-hook-form"
import type { Miembro, Contacto, Cerveza } from "../../interfaces"

const ingredientesDisponibles = [
  "Malta de Cebada",
  "Lúpulo",
  "Levadura",
  "Agua",
  "Malta de Trigo",
  "Malta Caramelo",
  "Malta Chocolate",
  "Avena",
  "Centeno",
  "Miel",
]

const tiposCerveza = [
  "Pale Ale",
  "IPA",
  "Stout",
  "Porter",
  "Lager",
  "Pilsner",
  "Wheat Beer",
  "Belgian Ale",
  "Amber Ale",
  "Brown Ale",
]

interface MiembroFormData extends Miembro {
  contactos?: Contacto[]
  productos?: Cerveza[]
}

export const RegistroMiembro: React.FC = () => {
  const [selectedIngredientes, setSelectedIngredientes] = useState<string[]>([])

  const {
    control,
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<MiembroFormData>({
    defaultValues: {
      contactos: [
        {
          cod_pers: 0,
          primer_nom_pers: "",
          primer_ape_pers: "",
        },
      ],
      productos: [
        {
          cod_cerv: 0,
          nombre_cerv: "",
          fk_tipo_cerv: 0,
        },
      ],
    },
  })

  const {
    fields: contactosFields,
    append: appendContacto,
    remove: removeContacto,
  } = useFieldArray({
    control,
    name: "contactos",
  })

  const {
    fields: productosFields,
    append: appendProducto,
    remove: removeProducto,
  } = useFieldArray({
    control,
    name: "productos",
  })

  const handleIngredientesChange = (event: SelectChangeEvent<typeof selectedIngredientes>) => {
    const value = event.target.value
    setSelectedIngredientes(typeof value === "string" ? value.split(",") : value)
  }

  const onSubmit = async (data: any) => {
    // Aquí iría la lógica para enviar los datos al backend
    alert('Miembro registrado exitosamente (simulado)');
    reset();
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Información del Miembro Proveedor ACAUCAB
      </Typography>

      <form onSubmit={handleSubmit(onSubmit)}>
        <Grid container spacing={3}>
          {/* Información del Proveedor */}
          <Grid size={{ xs: 12 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                Información del Proveedor
              </Typography>

              <Grid container spacing={2}>
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField
                    fullWidth
                    label="RIF"
                    {...register("rif_miem", { required: "RIF es requerido" })}
                    error={!!errors.rif_miem}
                    helperText={errors.rif_miem?.message}
                  />
                </Grid>
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField fullWidth label="Razón Social" {...register("razon_social_miem")} />
                </Grid>
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField fullWidth label="Denominación Comercial" {...register("denom_comercial_miem")} />
                </Grid>
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField fullWidth label="Página Web" {...register("pag_web_miem")} />
                </Grid>

                {/* Direcciones */}
                <Grid size={{ xs: 12 }}>
                  <Divider sx={{ my: 2 }} />
                  <Typography variant="subtitle1" gutterBottom>
                    Direcciones
                  </Typography>
                </Grid>

                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField
                    fullWidth
                    label="Dirección Física Principal"
                    multiline
                    rows={2}
                    {...register("direccion_fisica_miem")}
                  />
                </Grid>
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField
                    fullWidth
                    label="Dirección Fiscal"
                    multiline
                    rows={2}
                    {...register("direccion_fiscal_miem")}
                  />
                </Grid>

                <Grid size={{ xs: 12, md: 4 }}>
                  <FormControl fullWidth>
                    <InputLabel>Ciudad</InputLabel>
                    <Select label="Ciudad" {...register("fk_luga_1")}>
                      <MenuItem value={1}>Caracas</MenuItem>
                      <MenuItem value={2}>Valencia</MenuItem>
                      <MenuItem value={3}>Maracay</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <FormControl fullWidth>
                    <InputLabel>Estado</InputLabel>
                    <Select label="Estado" {...register("fk_luga_2")}>
                      <MenuItem value={1}>Distrito Capital</MenuItem>
                      <MenuItem value={2}>Carabobo</MenuItem>
                      <MenuItem value={3}>Aragua</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>
                <Grid size={{ xs: 12, md: 4 }}>
                  <FormControl fullWidth>
                    <InputLabel>País</InputLabel>
                    <Select label="País" defaultValue="venezuela">
                      <MenuItem value="venezuela">Venezuela</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>
              </Grid>
            </Paper>
          </Grid>

          {/* Personas de Contacto */}
          <Grid size={{ xs: 12 }}>
            <Paper sx={{ p: 3 }}>
              <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                <Typography variant="h6">Persona(s) de Contacto</Typography>
                <Button
                  startIcon={<Add />}
                  onClick={() =>
                    appendContacto({
                      cod_pers: 0,
                      primer_nom_pers: "",
                      primer_ape_pers: "",
                    })
                  }
                  variant="outlined"
                  size="small"
                >
                  Agregar otra Persona
                </Button>
              </Box>

              {contactosFields.map((field, index) => (
                <Card key={field.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                      <Typography variant="subtitle2">Contacto {index + 1}</Typography>
                      {index > 0 && (
                        <IconButton onClick={() => removeContacto(index)} color="error">
                          <Delete />
                        </IconButton>
                      )}
                    </Box>

                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Primer Nombre"
                          {...register(`contactos.${index}.primer_nom_pers`)}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Segundo Nombre"
                          {...register(`contactos.${index}.segundo_nom_pers`)}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Primer Apellido"
                          {...register(`contactos.${index}.primer_ape_pers`)}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Segundo Apellido"
                          {...register(`contactos.${index}.segundo_ape_pers`)}
                        />
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              ))}
            </Paper>
          </Grid>

          {/* Información del Producto */}
          <Grid size={{ xs: 12 }}>
            <Paper sx={{ p: 3 }}>
              <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                <Typography variant="h6">Información del Producto</Typography>
                <Button
                  startIcon={<Add />}
                  onClick={() =>
                    appendProducto({
                      cod_cerv: 0,
                      nombre_cerv: "",
                      fk_tipo_cerv: 0,
                    })
                  }
                  variant="outlined"
                  size="small"
                >
                  Agregar otro Producto
                </Button>
              </Box>

              {productosFields.map((field, index) => (
                <Card key={field.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                      <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                        <LocalBar />
                        <Typography variant="subtitle2">Producto {index + 1}</Typography>
                      </Box>
                      {index > 0 && (
                        <IconButton onClick={() => removeProducto(index)} color="error">
                          <Delete />
                        </IconButton>
                      )}
                    </Box>

                    <Grid container spacing={2}>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField fullWidth label="Nombre" {...register(`productos.${index}.nombre_cerv`)} />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
                        <FormControl fullWidth>
                          <InputLabel>Tipo de Cerveza</InputLabel>
                          <Select label="Tipo de Cerveza" {...register(`productos.${index}.fk_tipo_cerv`)}>
                            {tiposCerveza.map((tipo, idx) => (
                              <MenuItem key={tipo} value={idx + 1}>
                                {tipo}
                              </MenuItem>
                            ))}
                          </Select>
                        </FormControl>
                      </Grid>

                      <Grid size={{ xs: 12 }}>
                        <FormControl fullWidth>
                          <InputLabel>Ingredientes (Selección Múltiple)</InputLabel>
                          <Select
                            multiple
                            value={selectedIngredientes}
                            onChange={handleIngredientesChange}
                            input={<OutlinedInput label="Ingredientes (Selección Múltiple)" />}
                            renderValue={(selected) => (
                              <Box sx={{ display: "flex", flexWrap: "wrap", gap: 0.5 }}>
                                {selected.map((value) => (
                                  <Chip key={value} label={value} size="small" />
                                ))}
                              </Box>
                            )}
                          >
                            {ingredientesDisponibles.map((ingrediente) => (
                              <MenuItem key={ingrediente} value={ingrediente}>
                                {ingrediente}
                              </MenuItem>
                            ))}
                          </Select>
                        </FormControl>
                      </Grid>

                      <Grid size={{ xs: 12 }}>
                        <Box
                          sx={{
                            border: "2px dashed #ccc",
                            borderRadius: 2,
                            p: 3,
                            textAlign: "center",
                            cursor: "pointer",
                            "&:hover": { borderColor: "#2E7D32" },
                          }}
                        >
                          <Upload sx={{ fontSize: 48, color: "#ccc", mb: 1 }} />
                          <Typography variant="body2" color="textSecondary">
                            Foto del producto
                          </Typography>
                          <Button variant="outlined" size="small" sx={{ mt: 1 }}>
                            Seleccione un Archivo
                          </Button>
                        </Box>
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              ))}
            </Paper>
          </Grid>

          {/* Botón de Registro */}
          <Grid size={{ xs: 12 }}>
            <Box sx={{ display: "flex", justifyContent: "center", mt: 3 }}>
              <Button
                type="submit"
                variant="contained"
                size="large"
                sx={{
                  backgroundColor: "#2E7D32",
                  "&:hover": { backgroundColor: "#1B5E20" },
                  px: 6,
                  py: 1.5,
                }}
              >
                Registrar Miembro
              </Button>
            </Box>
          </Grid>
        </Grid>
      </form>
    </Box>
  )
}
