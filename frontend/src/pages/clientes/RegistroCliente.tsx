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
  FormControlLabel,
  Radio,
  RadioGroup,
} from "@mui/material"
import { Add, Delete } from "@mui/icons-material"
import { useForm, useFieldArray } from "react-hook-form"
import type { Cliente, Contacto, Telefono, Correo } from "../../interfaces"

interface ClienteFormData extends Omit<Cliente, "rif_clie"> {
  rif_clie: string // Para el formulario usamos string
  contactos?: Contacto[]
  telefonos?: Telefono[]
  correos?: Correo[]
}

export const RegistroCliente: React.FC = () => {
  const [tipoCliente, setTipoCliente] = useState<"Natural" | "Juridico">("Juridico")

  const {
    control,
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ClienteFormData>({
    defaultValues: {
      tipo_clie: "Juridico",
      contactos: [
        {
          cod_pers: 0,
          primer_nom_pers: "",
          primer_ape_pers: "",
        },
      ],
      telefonos: [
        {
          cod_tele: 0,
          cod_area_tele: 0,
          num_tele: 0,
        },
      ],
      correos: [
        {
          cod_corr: 0,
          prefijo_corr: "",
          dominio_corr: "",
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
    fields: telefonosFields,
    append: appendTelefono,
    remove: removeTelefono,
  } = useFieldArray({
    control,
    name: "telefonos",
  })

  const {
    fields: correosFields,
    append: appendCorreo,
    remove: removeCorreo,
  } = useFieldArray({
    control,
    name: "correos",
  })

  const onSubmit = (data: ClienteFormData) => {
    console.log("Datos del cliente:", data)
    // Aquí iría la lógica para enviar al backend
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Información del Cliente
      </Typography>

      <form onSubmit={handleSubmit(onSubmit)}>
        <Grid container spacing={3}>
          {/* Tipo de Cliente */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                Tipo de Cliente
              </Typography>
              <RadioGroup
                row
                value={tipoCliente}
                onChange={(e) => setTipoCliente(e.target.value as "Natural" | "Juridico")}
              >
                <FormControlLabel value="Juridico" control={<Radio />} label="Persona Jurídica" />
                <FormControlLabel value="Natural" control={<Radio />} label="Persona Natural" />
              </RadioGroup>
            </Paper>
          </Grid>

          {/* Información Principal */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                {tipoCliente === "Juridico" ? "Persona Jurídica" : "Persona Natural"}
              </Typography>

              <Grid container spacing={2}>
                <Grid item xs={12} md={6}>
                  <TextField
                    fullWidth
                    label="RIF"
                    {...register("rif_clie", { required: "RIF es requerido" })}
                    error={!!errors.rif_clie}
                    helperText={errors.rif_clie?.message}
                  />
                </Grid>

                {tipoCliente === "Juridico" ? (
                  <>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Razón Social" {...register("razon_social_juri")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Denominación Comercial" {...register("denom_comercial_juri")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Capital Disponible" type="number" {...register("capital_juri")} />
                    </Grid>
                    <Grid item xs={12}>
                      <TextField fullWidth label="Página Web" {...register("pag_web_juri")} />
                    </Grid>
                  </>
                ) : (
                  <>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Cédula de Identidad" {...register("ci_natu")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Primer Nombre" {...register("primer_nom_natu")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Segundo Nombre" {...register("segundo_nom_natu")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Primer Apellido" {...register("primer_ape_natu")} />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <TextField fullWidth label="Segundo Apellido" {...register("segundo_ape_natu")} />
                    </Grid>
                  </>
                )}

                {/* Direcciones */}
                <Grid item xs={12}>
                  <Divider sx={{ my: 2 }} />
                  <Typography variant="subtitle1" gutterBottom>
                    Direcciones
                  </Typography>
                </Grid>

                <Grid item xs={12} md={6}>
                  <TextField
                    fullWidth
                    label="Dirección Física Principal"
                    multiline
                    rows={2}
                    {...register("direccion_fisica_clie")}
                  />
                </Grid>
                <Grid item xs={12} md={6}>
                  <TextField
                    fullWidth
                    label="Dirección Fiscal"
                    multiline
                    rows={2}
                    {...register("direccion_fiscal_clie")}
                  />
                </Grid>

                <Grid item xs={12} md={3}>
                  <FormControl fullWidth>
                    <InputLabel>Ciudad</InputLabel>
                    <Select label="Ciudad" {...register("fk_luga_1")}>
                      <MenuItem value={1}>Caracas</MenuItem>
                      <MenuItem value={2}>Valencia</MenuItem>
                      <MenuItem value={3}>Maracay</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>
                <Grid item xs={12} md={3}>
                  <FormControl fullWidth>
                    <InputLabel>Estado</InputLabel>
                    <Select label="Estado" {...register("fk_luga_2")}>
                      <MenuItem value={1}>Distrito Capital</MenuItem>
                      <MenuItem value={2}>Carabobo</MenuItem>
                      <MenuItem value={3}>Aragua</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>
              </Grid>
            </Paper>
          </Grid>

          {/* Teléfonos */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                <Typography variant="h6">Teléfonos</Typography>
                <Button
                  startIcon={<Add />}
                  onClick={() =>
                    appendTelefono({
                      cod_tele: 0,
                      cod_area_tele: 0,
                      num_tele: 0,
                    })
                  }
                  variant="outlined"
                  size="small"
                >
                  Agregar Teléfono
                </Button>
              </Box>

              {telefonosFields.map((field, index) => (
                <Card key={field.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                      <Typography variant="subtitle2">Teléfono {index + 1}</Typography>
                      {index > 0 && (
                        <IconButton onClick={() => removeTelefono(index)} color="error">
                          <Delete />
                        </IconButton>
                      )}
                    </Box>

                    <Grid container spacing={2}>
                      <Grid item xs={12} md={4}>
                        <TextField
                          fullWidth
                          label="Código de Área"
                          type="number"
                          {...register(`telefonos.${index}.cod_area_tele`)}
                        />
                      </Grid>
                      <Grid item xs={12} md={8}>
                        <TextField
                          fullWidth
                          label="Número de Teléfono"
                          type="number"
                          {...register(`telefonos.${index}.num_tele`)}
                        />
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              ))}
            </Paper>
          </Grid>

          {/* Correos */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                <Typography variant="h6">Correos Electrónicos</Typography>
                <Button
                  startIcon={<Add />}
                  onClick={() =>
                    appendCorreo({
                      cod_corr: 0,
                      prefijo_corr: "",
                      dominio_corr: "",
                    })
                  }
                  variant="outlined"
                  size="small"
                >
                  Agregar Correo
                </Button>
              </Box>

              {correosFields.map((field, index) => (
                <Card key={field.id} sx={{ mb: 2 }}>
                  <CardContent>
                    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 2 }}>
                      <Typography variant="subtitle2">Correo {index + 1}</Typography>
                      {index > 0 && (
                        <IconButton onClick={() => removeCorreo(index)} color="error">
                          <Delete />
                        </IconButton>
                      )}
                    </Box>

                    <Grid container spacing={2}>
                      <Grid item xs={12} md={6}>
                        <TextField
                          fullWidth
                          label="Usuario (antes del @)"
                          {...register(`correos.${index}.prefijo_corr`)}
                        />
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <TextField
                          fullWidth
                          label="Dominio (después del @)"
                          {...register(`correos.${index}.dominio_corr`)}
                        />
                      </Grid>
                    </Grid>
                  </CardContent>
                </Card>
              ))}
            </Paper>
          </Grid>

          {/* Personas de Contacto */}
          <Grid item xs={12}>
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
                      <Grid item xs={12} md={6}>
                        <TextField
                          fullWidth
                          label="Primer Nombre"
                          {...register(`contactos.${index}.primer_nom_pers`)}
                        />
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <TextField
                          fullWidth
                          label="Segundo Nombre"
                          {...register(`contactos.${index}.segundo_nom_pers`)}
                        />
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <TextField
                          fullWidth
                          label="Primer Apellido"
                          {...register(`contactos.${index}.primer_ape_pers`)}
                        />
                      </Grid>
                      <Grid item xs={12} md={6}>
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

          {/* Botón de Registro */}
          <Grid item xs={12}>
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
                Registrar Cliente
              </Button>
            </Box>
          </Grid>
        </Grid>
      </form>
    </Box>
  )
}
