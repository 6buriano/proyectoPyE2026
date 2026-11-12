# =====================================================================
# R/funciones.r
# Funciones reutilizables del proyecto de estacionamientos.
#
# Cada funcion tiene arriba un comentario con: que hace, que recibe y
# que devuelve. Todo el archivo usa solo R base (no hacen falta paquetes).
# =====================================================================


# ---------------------------------------------------------------------
# 1. HORAS
# ---------------------------------------------------------------------

# convertirAMinutos(input)
#   Que hace : pasa una hora codificada como HH.MM a minutos desde las 00:00.
#              La parte entera son las horas y la parte decimal son los
#              minutos (9.35 se lee 9:35, no 9 horas y 35 centesimas).
#   Recibe   : un vector numerico de horas en formato HH.MM.
#   Devuelve : un vector numerico de minutos.
#   Por que  : una hora codificada asi no se puede promediar directamente:
#              el promedio de 9.55 y 10.05 da 9.80, que no es una hora
#              valida. Pasando a minutos da 600, o sea las 10:00.
convertirAMinutos <- function(input) {

  datos <- floor(input) * 60 + round((input - floor(input)) * 100)

  return(datos)
}

# formatoHoraMinutos(minutos)
#   Que hace : convierte minutos desde las 00:00 a texto HH:MM.
#   Recibe   : un vector numerico de minutos (el que devuelve la funcion
#              anterior, o un promedio de esos valores).
#   Devuelve : un vector de caracteres "HH:MM".
#   Por que  : %/% da la division entera (horas) y %% el resto (minutos),
#              sin ambiguedades de redondeo; sprintf rellena con cero.
formatoHoraMinutos <- function(minutos) {

  minutos_redondeados <- round(minutos)
  horas <- minutos_redondeados %/% 60
  minutos_restantes <- minutos_redondeados %% 60

  return(sprintf("%02d:%02d", horas, minutos_restantes))
}

# minutosAHoraDecimal(minutos)
#   Que hace : pasa minutos a horas como numero decimal (780 -> 13.0).
#              Sirve para clasificar por turno o para graficar.
#   Recibe   : un vector de minutos.
#   Devuelve : un vector numerico en horas decimales.
minutosAHoraDecimal <- function(minutos) {

  return(minutos / 60)
}


# ---------------------------------------------------------------------
# 2. DIAS DE LA SEMANA
# ---------------------------------------------------------------------

# Nombres de los dias en el orden en que se codifican: 1 = lunes.
DIAS_SEMANA <- c("Lunes", "Martes", "Miercoles", "Jueves", "Viernes")

# nombreDiaSemana(dia_semana)
#   Que hace : traduce el codigo 1..5 al nombre del dia.
#   Recibe   : vector numerico 1..5.
#   Devuelve : factor con los nombres, en el orden de lunes a viernes.
nombreDiaSemana <- function(dia_semana) {

  return(factor(DIAS_SEMANA[dia_semana], levels = DIAS_SEMANA))
}

# nombreSemana(semana)
#   Que hace : arma la etiqueta "Semana 1", "Semana 2", ...
nombreSemana <- function(semana) {

  return(factor(paste("Semana", semana), levels = paste("Semana", 1:4)))
}


# ---------------------------------------------------------------------
# 3. PREPARACION Y VALIDACION DEL ARCHIVO DE DATOS
# ---------------------------------------------------------------------

# prepararDatos(datos)
#   Que hace : deja el data.frame listo para el analisis. Si el archivo no
#              trae las columnas "semana" y "dia_semana" las deriva de
#              "dia", de modo que tambien funciona con el archivo original
#              de la catedra (que solo tiene las 7 variables de la letra).
#   Recibe   : un data.frame con al menos las columnas id, dia, hora_inicio,
#              horas_canceladas, extension_horas, multa y valor_multa.
#   Devuelve : el mismo data.frame con las columnas semana, dia_semana y turno.
#              Si falta alguna columna obligatoria, corta con un error.
prepararDatos <- function(datos) {

  # --- columnas obligatorias segun la letra
  obligatorias <- c("id", "dia", "hora_inicio", "horas_canceladas",
                    "extension_horas", "multa", "valor_multa")
  faltan <- setdiff(obligatorias, names(datos))
  if (length(faltan) > 0) {
    stop("Faltan columnas en el archivo de datos: ",
         paste(faltan, collapse = ", "))
  }

  # --- el dia 1 es lunes: 5 dias habiles por semana
  if (is.null(datos$dia_semana)) datos$dia_semana <- (datos$dia - 1) %% 5 + 1
  if (is.null(datos$semana)) datos$semana <- (datos$dia - 1) %/% 5 + 1

  # --- controles de coherencia: si algo no cierra, se corta aca y no se
  #     sigue calculando sobre datos mal armados
  stopifnot(
    nrow(datos) > 0,
    all(!is.na(datos)),
    all(datos$multa %in% c(0, 1)),
    all(datos$dia_semana %in% 1:5),
    all(datos$semana >= 1)
  )

  # --- el turno se define por la hora de inicio: manana antes del corte
  datos$turno <- ifelse(
    minutosAHoraDecimal(convertirAMinutos(datos$hora_inicio)) < HORA_CORTE_TURNO,
    "Manana", "Tarde")
  datos$turno <- factor(datos$turno, levels = c("Manana", "Tarde"))

  return(datos)
}


# ---------------------------------------------------------------------
# 4. FORMATO DE NUMEROS (para que la salida quede legible)
# ---------------------------------------------------------------------

# num(x, dec)
#   Que hace : formatea un numero con separador de miles "." y decimal ",".
#   Recibe   : un numero y la cantidad de decimales.
#   Devuelve : un caracter.
num <- function(x, dec = 2) {

  return(formatC(x, format = "f", digits = dec,
                 big.mark = ".", decimal.mark = ","))
}

# pesos(x, dec)
#   Que hace : formatea un monto como "$ 1.234.567".
pesos <- function(x, dec = 2) {

  return(paste0("$ ", num(x, dec)))
}

# pct(x, dec)
#   Que hace : formatea una proporcion como porcentaje ("35,62%").
pct <- function(x, dec = 2) {

  return(paste0(num(100 * x, dec), "%"))
}


# ---------------------------------------------------------------------
# 5. RESUMENES POR GRUPO
# ---------------------------------------------------------------------

# resumenPor(valor, grupo)
#   Que hace : calcula el promedio de "valor" dentro de cada categoria de
#              "grupo" y devuelve una tabla lista para imprimir.
#   Recibe   : valor = vector numerico, grupo = vector que define los grupos.
#   Devuelve : data.frame con grupo, registros, promedio y total.
resumenPor <- function(valor, grupo) {

  promedios <- tapply(valor, grupo, mean)
  cantidades <- tapply(valor, grupo, length)
  totales <- tapply(valor, grupo, sum)

  tabla <- data.frame(
    grupo = names(promedios),
    registros = as.vector(cantidades),
    promedio = as.vector(promedios),
    total = as.vector(totales),
    stringsAsFactors = FALSE
  )

  return(tabla)
}

# usuariosPorGrupo(datos, columna)
#   Que hace : cuenta cuantos registros y cuantos USUARIOS DISTINTOS hay en
#              cada grupo. La distincion es la clave de la consigna 4: un
#              usuario puede estacionar varias veces en el mismo dia.
#   Recibe   : datos y el nombre de la columna que define el grupo.
#   Devuelve : data.frame con grupo, registros, usuarios y usos_por_usuario.
usuariosPorGrupo <- function(datos, columna) {

  grupos <- sort(unique(datos[[columna]]))
  salida <- data.frame(
    grupo = grupos,
    registros = NA_integer_,
    usuarios = NA_integer_,
    usos_por_usuario = NA_real_,
    stringsAsFactors = FALSE
  )

  for (i in seq_along(grupos)) {
    subconjunto <- datos[datos[[columna]] == grupos[i], ]
    salida$registros[i] <- nrow(subconjunto)
    salida$usuarios[i] <- length(unique(subconjunto$id))
  }
  salida$usos_por_usuario <- salida$registros / salida$usuarios

  return(salida)
}


# ---------------------------------------------------------------------
# 6. MUESTREO
# ---------------------------------------------------------------------

# muestreoSistematico(datos, k)
#   Que hace : toma uno de cada k registros, con arranque aleatorio entre 1
#              y k. Es el muestreo que pide la consigna 6 (k = 10).
#   Recibe   : datos y el intervalo k.
#   Devuelve : lista con arranque, indices, muestra y tamano.
#   Ojo      : el arranque se sortea con el generador de R, asi que conviene
#              que la semilla ya este fijada en data.r para que sea
#              reproducible.
muestreoSistematico <- function(datos, k = 10) {

  N <- nrow(datos)
  arranque <- sample(1:k, 1)
  indices <- seq(arranque, N, by = k)

  return(list(arranque = arranque,
              indices = indices,
              muestra = datos[indices, ],
              tamano = length(indices)))
}


# ---------------------------------------------------------------------
# 7. INTERVALOS DE CONFIANZA
# ---------------------------------------------------------------------

# icProporcion(x, n, conf, N)
#   Que hace : intervalo de confianza para una proporcion por el metodo de
#              Wald:  p_gorro +/- z * sqrt(p_gorro*(1-p_gorro)/n).
#   Recibe   : x     = cantidad de exitos en la muestra
#              n     = tamano de la muestra
#              conf  = nivel de confianza (0.95 por defecto)
#              N     = tamano de la poblacion, si se quiere aplicar el
#                      factor de correccion por poblacion finita
#   Devuelve : vector con lim_inf, p_gorro, lim_sup y error_estandar.
icProporcion <- function(x, n, conf = 0.95, N = Inf) {

  p <- x / n
  z <- qnorm(1 - (1 - conf) / 2)
  ee <- sqrt(p * (1 - p) / n)

  # correccion por poblacion finita: corresponde cuando n supera el 5% de N
  if (is.finite(N)) ee <- ee * sqrt((N - n) / (N - 1))

  return(c(lim_inf = p - z * ee,
           p_gorro = p,
           lim_sup = p + z * ee,
           error_estandar = ee))
}

# icProporcionWilson(x, n, conf)
#   Que hace : intervalo de confianza para una proporcion por el metodo de
#              Wilson, que se porta mejor cuando n*p_gorro es chico.
#   Devuelve : vector con lim_inf, p_gorro y lim_sup.
icProporcionWilson <- function(x, n, conf = 0.95) {

  p <- x / n
  z <- qnorm(1 - (1 - conf) / 2)
  centro <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  mitad <- (z / (1 + z^2 / n)) * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))

  return(c(lim_inf = centro - mitad, p_gorro = p, lim_sup = centro + mitad))
}

# icMedia(x, conf, sigma, N)
#   Que hace : intervalo de confianza para la media. Si no se conoce sigma
#              usa la t de Student con n-1 grados de libertad; si se conoce,
#              usa la normal.
#   Recibe   : x = vector de datos, conf = nivel, sigma = desvio poblacional
#              (opcional), N = tamano de la poblacion (opcional, para el fpc).
#   Devuelve : vector con lim_inf, media, lim_sup y error_estandar.
icMedia <- function(x, conf = 0.95, sigma = NULL, N = Inf) {

  n <- length(x)
  media <- mean(x)

  if (is.null(sigma)) {
    ee <- sd(x) / sqrt(n)
    z <- qt(1 - (1 - conf) / 2, df = n - 1)
  } else {
    ee <- sigma / sqrt(n)
    z <- qnorm(1 - (1 - conf) / 2)
  }

  if (is.finite(N)) ee <- ee * sqrt((N - n) / (N - 1))

  return(c(lim_inf = media - z * ee,
           media = media,
           lim_sup = media + z * ee,
           error_estandar = ee))
}

# icTotal(x, conf, N, sigma)
#   Que hace : intervalo de confianza para el TOTAL poblacional.
#              Se obtiene multiplicando el intervalo de la media por N.
#   Recibe   : x = vector de valores por registro, N = cantidad de registros
#              de la poblacion.
#   Devuelve : vector con lim_inf, total, lim_sup.
icTotal <- function(x, conf = 0.95, N, sigma = NULL, fpc = FALSE) {

  # Ojo con el factor de correccion: si la muestra ES la poblacion (N = n),
  # el intervalo se hace de ancho cero y no informa nada. Por eso, para
  # estimar la recaudacion esperada se usa fpc = FALSE por defecto.
  ic <- icMedia(x, conf = conf, sigma = sigma,
                N = if (fpc) N else Inf)

  # unname(): al indexar un vector con nombre y volver a nombrarlo, R
  # arrastraria el nombre viejo (lim_inf.lim_inf) y despues no se encuentra.
  return(c(lim_inf = N * unname(ic["lim_inf"]),
           total = N * unname(ic["media"]),
           lim_sup = N * unname(ic["lim_sup"])))
}


# ---------------------------------------------------------------------
# 8. PRESENTACION DE LA SALIDA
# ---------------------------------------------------------------------

# titulo(texto)
#   Que hace : imprime un encabezado de seccion, para que RESULTADOS.txt
#              se pueda leer.
titulo <- function(texto) {

  cat("\n", strrep("=", 72), "\n", sep = "")
  cat(texto, "\n")
  cat(strrep("=", 72), "\n", sep = "")
}

# subtitulo(texto)
#   Que hace : imprime un encabezado de subseccion.
subtitulo <- function(texto) {

  cat("\n--- ", texto, "\n", sep = "")
}

# mostrar(tabla, dec)
#   Que hace : imprime un data.frame redondeando las columnas numericas.
mostrar <- function(tabla, dec = 2) {

  tabla_impresa <- tabla
  for (columna in names(tabla_impresa)) {
    valores <- tabla_impresa[[columna]]

    if (is.integer(valores)) {
      # los conteos van sin decimales
      tabla_impresa[[columna]] <- formatC(valores, format = "d", big.mark = ".",
                                          decimal.mark = ",")
    } else if (is.numeric(valores)) {
      # los decimales se muestran con coma, como en el texto
      tabla_impresa[[columna]] <- formatC(valores, format = "f", digits = dec,
                                          big.mark = ".", decimal.mark = ",")
    }
  }
  print(tabla_impresa, row.names = FALSE)
  invisible(tabla_impresa)
}
