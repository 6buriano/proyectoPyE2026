# =====================================================================
# R/data.r
# Archivo de datos del estacionamiento.
#
# Que hace: busca el archivo datos/datos.csv. Si existe lo usa tal cual
# (asi se puede reemplazar por el archivo de la catedra sin tocar nada);
# si no existe, lo genera una vez con la semilla fija y lo escribe.
#
# Las 7 variables de la letra:
#   1. id                identificacion del usuario
#   2. dia               dia habil del mes (1 a 20 = 4 semanas x 5 dias)
#   3. semana            1 a 4 (se deriva del dia)
#   4. dia_semana        1 = lunes ... 5 = viernes (se deriva del dia)
#   5. hora_inicio       hora de inicio, codificada como HH.MM (9.35 = 9:35)
#   6. horas_canceladas  horas pagadas por adelantado, en unidades de 30 min
#   7. extension_horas   tiempo adicional comprado, en unidades de 30 min
#   8. multa             1 = multado por terminacion del tiempo prepagado
#   9. valor_multa       monto de la multa por exceso de tiempo
#
# Requiere: haber leido R/parametros.r y R/funciones.r (main.r lo hace).
# =====================================================================

if (!exists("TARIFA_UNIDAD")) {
  stop("Leé primero R/parametros.r: main.r lo hace por vos, en ese orden.")
}


# ---------------------------------------------------------------------
# generarDatos(n, nUsuarios)
#   Que hace : simula el archivo de 10.000 registros con la estructura de
#              la letra.
#   Recibe   : n = cantidad de registros, nUsuarios = cantidad de usuarios.
#   Devuelve : data.frame con las 9 columnas.
#   Nota     : la semilla se fija ADENTRO de la funcion, para que generar
#              los datos siempre de el mismo archivo.
# ---------------------------------------------------------------------
generarDatos <- function(n = N_REGISTROS, nUsuarios = N_USUARIOS) {

  set.seed(SEMILLA)

  # Matriz vacia de n filas y 9 columnas: se llena columna por columna.
  A <- matrix(0, nrow = n, ncol = 9)

  # 1. Identificacion del usuario.
  #    Se sortea CON reemplazo entre nUsuarios: asi el mismo usuario aparece
  #    varias veces en el mes, que es lo que permite analizar su
  #    comportamiento (consigna 4).
  A[, 1] <- sample(1:nUsuarios, n, replace = TRUE)

  # 2. Dia habil del mes: 4 semanas x 5 dias = 20 dias.
  #    Se sortea el dia y de ahi se derivan la semana y el dia de la semana,
  #    para que la terna nunca quede incoherente (dia 3 con semana 4, etc.).
  A[, 2] <- sample(1:(5 * N_SEMANAS), n, replace = TRUE)
  A[, 3] <- (A[, 2] - 1) %/% 5 + 1      # %/% division entera -> 1 a 4
  A[, 4] <- (A[, 2] - 1) %% 5 + 1       # %%  resto           -> 1 a 5

  # 3. Hora de inicio del servicio entre las 9:00 y las 16:59.
  #    Se sortea el minuto del dia y despues se reescribe con la
  #    codificacion HH.MM de la catedra: parte entera = hora, parte decimal
  #    = minutos. Como los minutos son enteros de 0 a 59, la hora se
  #    reconstruye exacta con convertirAMinutos().
  minutos_inicio <- 9 * 60 + sample(0:(8 * 60 - 1), n, replace = TRUE)
  A[, 5] <- floor(minutos_inicio / 60) + (minutos_inicio %% 60) / 100

  # 4. Horas canceladas, en unidades de 30 minutos (1 a 8 = 30 min a 4 h).
  #    La mayoria de los usos compra bloques cortos: las probabilidades
  #    decrecen con el tamano.
  A[, 6] <- sample(1:8, n, replace = TRUE,
                   prob = c(.28, .24, .18, .13, .09, .05, .02, .01))

  # 5. Extension de hora, en unidades de 30 minutos (1 a 4).
  #    La extension es el tiempo adicional que se compra cuando se termina
  #    el prepago, asi que casi siempre es corta.
  A[, 7] <- sample(1:4, n, replace = TRUE, prob = c(.55, .28, .12, .05))

  # 6. Multa por finalizacion del tiempo prepagado (S/N).
  #    Bernoulli con 35% de multados.
  A[, 8] <- rbinom(n, size = 1, prob = 0.35)

  # 7. Valor de la multa por exceso de tiempo: 100 pesos mas 0, 1 o 2
  #    recargos del 30%, sorteados por separado -> 100, 200 o 300.
  #    Ojo: rbinom(1, 0.3) sin "size=1" toma size = 0 y devuelve siempre 0;
  #    el recargo tiene que ser una Bernoulli por registro.
  recargos <- rbinom(n, size = 1, prob = 0.3) + rbinom(n, size = 1, prob = 0.3)
  A[, 9] <- 100 * A[, 8] * (1 + recargos)

  # Nombres de las columnas y conversion a data.frame
  colnames(A) <- c("id", "dia", "semana", "dia_semana", "hora_inicio",
                   "horas_canceladas", "extension_horas", "multa", "valor_multa")

  return(data.frame(A))
}


# ---------------------------------------------------------------------
# Carga del archivo
# ---------------------------------------------------------------------
archivoDatos <- file.path("datos", "datos.csv")

if (!file.exists(archivoDatos)) {
  dir.create("datos", showWarnings = FALSE)
  MA <- generarDatos()
  write.csv(MA, archivoDatos, row.names = FALSE)
  cat("No existia el archivo: se genero ", archivoDatos,
      " con set.seed(", SEMILLA, ").\n", sep = "")
} else {
  MA <- read.csv(archivoDatos)
  cat("Se usa el archivo existente: ", archivoDatos, "\n", sep = "")
}

# prepararDatos() deriva semana y dia_semana si el archivo no las trae,
# agrega el turno y valida la coherencia del contenido.
MA <- prepararDatos(MA)

cat("Registros: ", nrow(MA),
    " | usuarios distintos: ", length(unique(MA$id)),
    " | dias habiles: ", length(unique(MA$dia)), "\n", sep = "")
