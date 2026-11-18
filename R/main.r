# =====================================================================
# R/main.r  -  PUNTO DE ENTRADA DEL PROYECTO
#
# Como se corre:
#   1) Abrir pye2026Lab.Rproj en RStudio (asi el directorio de trabajo
#      queda en la raiz del proyecto) y ejecutar este archivo COMPLETO
#      con Ctrl + Shift + Enter (boton "Source").
#   2) O desde la consola del sistema, parado en la raiz del proyecto:
#        Rscript R/main.r
#
# No conviene ejecutarlo linea por linea con Ctrl+Enter: las primeras
# lineas de abajo cargan los supuestos y las funciones, y si se saltea
# alguna aparece "objeto 'SEMILLA' no encontrado".
#
# Que hace: lee los parametros y las funciones, carga (o genera) el
# archivo de datos, resuelve las 7 consignas y las 7 preguntas de la
# letra, deja toda la salida en RESULTADOS.txt y genera el informe.
#
# Orden de lectura de los archivos:
#   parametros.r      -> supuestos propios (tarifa, franjas, semilla)
#   funciones.r       -> funciones reutilizables (horas, IC, graficos)
#   data.r            -> datos/datos.csv y el data.frame MA
#   01_descriptivos.R -> consignas 1 a 5
#   02_inferencia.R   -> consignas 6 y 7
#   03_decisiones.R   -> las 7 preguntas
#   04_informe.R      -> informe/Informe_Proyecto_Final.md (+ .docx)
# =====================================================================


# =====================================================================
# 0. UBICACION Y DEPENDENCIAS
#
# Se cargan ACÁ, fuera de la función, por dos motivos:
#   - si el archivo se ejecuta completo, funciona igual que antes;
#   - si se ejecuta paso a paso desde arriba, los objetos ya existen
#     cuando se llega a las líneas del análisis.
# =====================================================================

# Si se abrió la carpeta R/ en lugar de la raíz del proyecto, se ubica solo
if (!file.exists("R/parametros.r") && file.exists("parametros.r")) {
  setwd("..")
}

if (!file.exists("R/parametros.r")) {
  stop("No encuentro R/parametros.r. ",
       "Abri pye2026Lab.Rproj en RStudio o corre el proyecto desde su raiz.")
}

source("R/parametros.r")
source("R/funciones.r")
source("R/data.r")


# =====================================================================
# 1. EL ANALISIS
# =====================================================================
ejecutarProyecto <- function() {

  # Si se llamó a la función sin haber ejecutado el bloque de arriba,
  # se cargan las dependencias acá (así también funciona sola).
  if (!exists("SEMILLA")) {
    source("R/parametros.r")
    source("R/funciones.r")
    source("R/data.r")
  }

  # Ancho de impresion: con el valor por defecto (80) las tablas de R se
  # cortan en dos bloques y RESULTADOS.txt queda ilegible.
  options(width = 120)

  salida <- file("RESULTADOS.txt", open = "wt", encoding = "UTF-8")
  sink(salida, split = TRUE)          # split = TRUE: se ve en pantalla y en el archivo
  on.exit({ sink(); close(salida) }, add = TRUE)

  cat(strrep("=", 72), "\n", sep = "")
  cat("PROYECTO FINAL DE PROBABILIDAD Y ESTADISTICA - PyE 2026\n")
  cat("Uso de estacionamientos en las calles de San Jose\n")
  cat(strrep("=", 72), "\n", sep = "")
  cat("R ", as.character(getRversion()), " | ", format(Sys.time()), "\n", sep = "")

  # Resumen del archivo de datos. data.r ya lo imprimio al cargarse; aca
  # se repite para que quede registrado dentro de RESULTADOS.txt.
  cat("\nArchivo de datos: datos/datos.csv\n")
  cat("  Registros ..........................", nrow(MA), "\n")
  cat("  Usuarios distintos .................", length(unique(MA$id)), "\n")
  cat("  Dias habiles .......................", length(unique(MA$dia)), "\n")

  cat("\nSupuestos declarados (R/parametros.r):\n")
  cat("  Semilla ..........................", SEMILLA, "\n")
  cat("  Tarifa por unidad de 30 minutos ..", pesos(TARIFA_UNIDAD), "\n")
  cat("  Franja de muestreo ...............",
      paste0(HORA_APERTURA, ":00 a ", HORA_CIERRE, ":00"), "\n")
  cat("  Corte de turno ...................", paste0(HORA_CORTE_TURNO, ":00"),
      "(manana = antes de esa hora)\n")
  cat("  Muestreo sistematico ............. uno de cada", K_SISTEMATICO, "\n")
  cat("  Nivel de confianza ...............", pct(CONF_NIVEL, 0), "\n")

  source("R/01_descriptivos.R")
  source("R/02_inferencia.R")
  source("R/03_decisiones.R")
  source("R/04_informe.R")

  cat("\n", strrep("=", 72), "\n", sep = "")
  cat("FIN. Resultados en RESULTADOS.txt e informe en informe/\n")
  cat(strrep("=", 72), "\n", sep = "")
}

ejecutarProyecto()
