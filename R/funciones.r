#Archivo para alojar funciones



convertirAMinutos <- function(input)
{
  ##pasa los valores a minutos en las tablas recibidas para evitar problemas al sacar calculos
  #devuelve vector con datos

    datos <- floor(input) * 60 + round((input - floor(input)) * 100)
    return(datos)
}

formatoHoraMinutos <- function(minutos)
{
  #convierte datos (solo los creados por la funcion de arriba) a formato HH:MM

  minutos_redondeados <- round(minutos)
  horas <- minutos_redondeados %/% 60
  minutos_restantes <- minutos_redondeados %% 60

  return(sprintf("%02d:%02d", horas, minutos_restantes))
}
