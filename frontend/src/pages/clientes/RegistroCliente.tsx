"use client"

import type React from "react"
import { useState, useEffect } from "react"
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
  Autocomplete,
} from "@mui/material"
import { Add, Delete } from "@mui/icons-material"
import { useForm, useFieldArray } from "react-hook-form"
import type { Cliente, Contacto, Telefono, Correo } from "../../interfaces"
import { getParroquias, registrarClienteNatural, registrarClienteJuridico } from "../../services/api"
import type { Lugar } from "../../interfaces/common"

interface ClienteFormData extends Omit<Cliente, "rif_clie"> {
  rif_clie: string // Para el formulario usamos string
  contactos?: Contacto[]
  telefonos?: Telefono[]
  correos?: Correo[]
}

export const RegistroCliente: React.FC = () => {
  const [tipoCliente, setTipoCliente] = useState<"Natural" | "Juridico">("Juridico")
  const [lugares, setLugares] = useState<Lugar[]>([])
  const [estados, setEstados] = useState<Lugar[]>([])
  const [parroquias, setParroquias] = useState<Lugar[]>([])
  const [selectedParroquiaFisica, setSelectedParroquiaFisica] = useState<number | null>(null)
  const [selectedParroquiaFiscal, setSelectedParroquiaFiscal] = useState<number | null>(null)
  const [loadingLugares, setLoadingLugares] = useState(false)
  const [errorDireccion, setErrorDireccion] = useState<string>("")

  const {
    control,
    register,
    handleSubmit,
    formState: { errors },
    reset,
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

  useEffect(() => {
    setLoadingLugares(true)
    getParroquias().then((data: any) => {
      const parroquiasList = Array.isArray(data) ? data : (data?.data ?? [])
      setParroquias(parroquiasList)
      setEstados(parroquiasList.filter((l: Lugar) => l.tipo_luga === "Estado"))
      setLoadingLugares(false)
    })
  }, [])

  const onSubmit = async (data: any) => {
    setErrorDireccion("")
    if (!selectedParroquiaFisica || !selectedParroquiaFiscal) {
      setErrorDireccion("Debe seleccionar parroquia para ambas direcciones.")
      return
    }
    // Construir objeto para el backend
    const clienteBase = {
      rif_clie: data.rif_clie,
      direccion_fiscal_clie: data.direccion_fiscal_clie,
      direccion_fisica_clie: data.direccion_fisica_clie,
      fk_luga_1: selectedParroquiaFiscal,
      fk_luga_2: selectedParroquiaFisica,
      telefonos: data.telefonos?.map((t: any) => ({ cod_area_tele: t.cod_area_tele, num_tele: t.num_tele })),
      correos: data.correos?.map((c: any) => ({ prefijo_corr: c.prefijo_corr, dominio_corr: c.dominio_corr })),
    }
    let response
    if (tipoCliente === "Natural") {
      response = await registrarClienteNatural({
        ...clienteBase,
        primer_nom_natu: data.primer_nom_natu,
        segundo_nom_natu: data.segundo_nom_natu,
        primer_ape_natu: data.primer_ape_natu,
        segundo_ape_natu: data.segundo_ape_natu,
        ci_natu: data.ci_natu,
      })
    } else {
      response = await registrarClienteJuridico({
        ...clienteBase,
        razon_social_juri: data.razon_social_juri,
        denom_comercial_juri: data.denom_comercial_juri,
        capital_juri: data.capital_juri,
        pag_web_juri: data.pag_web_juri,
      })
    }
    if (response?.success) {
      alert('Cliente registrado exitosamente')
      reset()
    } else {
      alert('Error al registrar cliente: ' + (response?.error || 'Error desconocido'))
    }
  }

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: "bold", color: "#2E7D32" }}>
        Información del Cliente
      </Typography>

      <form onSubmit={handleSubmit(onSubmit)}>
        <Grid container spacing={3}>
          {/* Tipo de Cliente */}
          <Grid size={{ xs: 12 }}>
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
          <Grid size={{ xs: 12 }}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                {tipoCliente === "Juridico" ? "Persona Jurídica" : "Persona Natural"}
              </Typography>

              <Grid container spacing={2}>
                <Grid size={{ xs: 12, md: 6 }}>
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
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Razón Social" {...register("razon_social_juri")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Denominación Comercial" {...register("denom_comercial_juri")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Capital Disponible" type="number" {...register("capital_juri")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Página Web" {...register("pag_web_juri")} />
                    </Grid>
                  </>
                ) : (
                  <>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Cédula de Identidad" {...register("ci_natu")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Primer Nombre" {...register("primer_nom_natu")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Segundo Nombre" {...register("segundo_nom_natu")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Primer Apellido" {...register("primer_ape_natu")} />
                    </Grid>
                    <Grid size={{ xs: 12, md: 6 }}>
                      <TextField fullWidth label="Segundo Apellido" {...register("segundo_ape_natu")} />
                    </Grid>
                  </>
                )}

                {/* Direcciones */}
                <Grid size={{ xs: 12 }}>
                  <Divider sx={{ my: 2 }} />
                  <Typography variant="subtitle1" gutterBottom>
                    Direcciones
                  </Typography>
                  {errorDireccion && (
                    <Typography color="error" variant="body2" sx={{ mt: 1, mb: 1 }}>
                      {errorDireccion}
                    </Typography>
                  )}
                </Grid>

                {/* Dirección Física */}
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField
                    fullWidth
                    label="Dirección Física Principal"
                    multiline
                    rows={2}
                    {...register("direccion_fisica_clie")}
                  />
                  <Autocomplete
                    options={parroquias}
                    getOptionLabel={(option) => option.nombre_luga}
                    value={parroquias.find(p => p.cod_luga === selectedParroquiaFisica) || null}
                    onChange={(_, value) => setSelectedParroquiaFisica(value ? value.cod_luga : null)}
                    isOptionEqualToValue={(option, value) => option.cod_luga === value.cod_luga}
                    renderInput={(params) => (
                      <TextField {...params} label="Parroquia" fullWidth sx={{ mt: 2 }} />
                    )}
                    disabled={loadingLugares}
                  />
                </Grid>

                {/* Dirección Fiscal */}
                <Grid size={{ xs: 12, md: 6 }}>
                  <TextField
                    fullWidth
                    label="Dirección Fiscal"
                    multiline
                    rows={2}
                    {...register("direccion_fiscal_clie")}
                  />
                  <Autocomplete
                    options={parroquias}
                    getOptionLabel={(option) => option.nombre_luga}
                    value={parroquias.find(p => p.cod_luga === selectedParroquiaFiscal) || null}
                    onChange={(_, value) => setSelectedParroquiaFiscal(value ? value.cod_luga : null)}
                    isOptionEqualToValue={(option, value) => option.cod_luga === value.cod_luga}
                    renderInput={(params) => (
                      <TextField {...params} label="Parroquia" fullWidth sx={{ mt: 2 }} />
                    )}
                    disabled={loadingLugares}
                  />
                </Grid>
              </Grid>
            </Paper>
          </Grid>

          {/* Teléfonos */}
          <Grid size={{ xs: 12 }}>
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
                      <Grid size={{ xs: 12, md: 4 }}>
                        <TextField
                          fullWidth
                          label="Código de Área"
                          type="number"
                          {...register(`telefonos.${index}.cod_area_tele`)}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 8 }}>
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
          <Grid size={{ xs: 12 }}>
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
                      <Grid size={{ xs: 12, md: 6 }}>
                        <TextField
                          fullWidth
                          label="Usuario (antes del @)"
                          {...register(`correos.${index}.prefijo_corr`)}
                        />
                      </Grid>
                      <Grid size={{ xs: 12, md: 6 }}>
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
                Registrar Cliente
              </Button>
            </Box>
          </Grid>
        </Grid>
      </form>
    </Box>
  )
}
