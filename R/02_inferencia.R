# =====================================================================
# R/02_inferencia.R
# Consignas 6 y 7 de la letra: muestreo sistematico e intervalos de
# confianza para proporciones.
#
#   6. Muestreo sistematico uno de cada 10 datos e intervalo de confianza
#      para la proporcion de autos multados, para compararlo con la
#      proporcion poblacional.
#   7. Intervalo de confianza al 95% para proporciones y determinar si
#      representa el total de los datos.
#
# Requiere: R/parametros.r, R/funciones.r y R/data.r ya leidos (MA).
# =====================================================================

titulo("PARTE 2 - INFERENCIA: MUESTREO SISTEMATICO E INTERVALOS DE CONFIANZA")


# =====================================================================
# CONSIGNA 6: muestreo sistematico uno de cada 10
# =====================================================================
subtitulo("Consigna 6: muestreo sistematico uno de cada 10 y su intervalo de confianza")

# La proporcion poblacional se puede calcular porque tenemos los 10.000
# registros: es el valor "verdadero" contra el que se compara la muestra.
N_POBLACION     <- nrow(MA)
multados_pob    <- sum(MA$multa)
prop_poblacion  <- mean(MA$multa)

cat("Poblacion (los 10.000 registros): ", num(multados_pob, 0), " multados de ",
    num(N_POBLACION, 0), " = ", pct(prop_poblacion), "\n", sep = "")

# --- muestreo sistematico
# El arranque de la muestra se sortea, asi que se fija la semilla justo
# antes para que la muestra (y por lo tanto el intervalo) sea siempre la
# misma en cada corrida.
set.seed(SEMILLA)
sistematica <- muestreoSistematico(MA, k = K_SISTEMATICO)
muestra     <- sistematica$muestra
n_muestra   <- sistematica$tamano

cat("Muestreo sistematico: uno de cada", K_SISTEMATICO,
    "| arranque aleatorio:", sistematica$arranque,
    "| tamano de la muestra:", n_muestra, "\n")
cat("Fraccion de muestreo n/N:", pct(n_muestra / N_POBLACION), "\n")

# --- estimacion en la muestra
multados_muestra <- sum(muestra$multa)
prop_muestra     <- mean(muestra$multa)

cat("En la muestra: ", num(multados_muestra, 0), " multados de ", n_muestra,
    " = ", pct(prop_muestra), "\n", sep = "")

# --- intervalos de confianza al 95%
ic_wald <- icProporcion(multados_muestra, n_muestra, conf = CONF_NIVEL)
ic_fpc  <- icProporcion(multados_muestra, n_muestra, conf = CONF_NIVEL,
                        N = N_POBLACION)
ic_wilson <- icProporcionWilson(multados_muestra, n_muestra, conf = CONF_NIVEL)

tabla_ic_sistematica <- data.frame(
  metodo = c("Wald", "Wald con correccion por poblacion finita", "Wilson"),
  p_gorro = c(ic_wald["p_gorro"], ic_fpc["p_gorro"], ic_wilson["p_gorro"]),
  lim_inf = c(ic_wald["lim_inf"], ic_fpc["lim_inf"], ic_wilson["lim_inf"]),
  lim_sup = c(ic_wald["lim_sup"], ic_fpc["lim_sup"], ic_wilson["lim_sup"])
)
tabla_ic_sistematica$ancho_pp <- 100 * (tabla_ic_sistematica$lim_sup -
                                          tabla_ic_sistematica$lim_inf)
tabla_ic_sistematica$contiene_poblacion <- tabla_ic_sistematica$lim_inf <= prop_poblacion &
  prop_poblacion <= tabla_ic_sistematica$lim_sup

cat("\nIntervalos de confianza al", pct(CONF_NIVEL, 0), "para la proporcion de multados:\n")
mostrar(tabla_ic_sistematica, dec = 4)

cat("\nComparacion con la proporcion poblacional (", pct(prop_poblacion), "):\n", sep = "")
for (i in 1:nrow(tabla_ic_sistematica)) {
  cat(" ", tabla_ic_sistematica$metodo[i], ": ",
      ifelse(tabla_ic_sistematica$contiene_poblacion[i],
             "el intervalo CONTIENE el valor poblacional", 
             "el intervalo NO contiene el valor poblacional"), "\n", sep = "")
}

# Factor de correccion por poblacion finita, para mostrarlo explicitamente
fpc <- sqrt((N_POBLACION - n_muestra) / (N_POBLACION - 1))
cat("\nFactor de correccion por poblacion finita: sqrt((N-n)/(N-1)) =", num(fpc, 4), "\n")
cat("Como n/N =", pct(n_muestra / N_POBLACION),
    "es mayor que el 5%, corresponde aplicarlo: el intervalo se angosta",
    num(100 * (1 - fpc), 1), "%.\n")


# =====================================================================
# CONSIGNA 7: IC al 95% y evaluacion de si representa el total
# =====================================================================
subtitulo("Consigna 7: intervalo de confianza al 95% y si representa el total de los datos")

# --- con la muestra sistematica (la misma de la consigna 6)
cat("a) Con la muestra sistematica (n =", n_muestra, "):\n")
cat("   p_gorro =", pct(prop_muestra),
    "| IC 95%:", pct(ic_wald["lim_inf"]), "a", pct(ic_wald["lim_sup"]),
    "| ancho =", num(100 * (ic_wald["lim_sup"] - ic_wald["lim_inf"]), 2),
    "puntos porcentuales\n")

# --- con todos los datos
ic_completa <- icProporcion(multados_pob, N_POBLACION, conf = CONF_NIVEL)
cat("b) Con los", N_POBLACION, "registros (muestra = poblacion):\n")
cat("   p_gorro =", pct(ic_completa["p_gorro"]),
    "| IC 95%:", pct(ic_completa["lim_inf"]), "a", pct(ic_completa["lim_sup"]),
    "| ancho =", num(100 * (ic_completa["lim_sup"] - ic_completa["lim_inf"]), 2),
    "puntos porcentuales\n")

# --- comparacion de anchos
ancho_sistematica <- ic_wald["lim_sup"] - ic_wald["lim_inf"]
ancho_completa    <- ic_completa["lim_sup"] - ic_completa["lim_inf"]
razon_anchos      <- ancho_sistematica / ancho_completa

cat("\nc) Comparacion:\n")
cat("   El intervalo de la muestra sistematica es", num(razon_anchos, 2),
    "veces mas ancho que el de la poblacion completa.\n")
cat("   La teoria predice sqrt(n_poblacion/n_muestra) = sqrt(",
    N_POBLACION, "/", n_muestra, ") = ", num(sqrt(N_POBLACION / n_muestra), 2),
    ", que coincide.\n", sep = "")

# --- veredicto
representa <- ic_wald["lim_inf"] <= prop_poblacion & prop_poblacion <= ic_wald["lim_sup"]
cat("\nVeredicto: la muestra sistematica ",
    ifelse(representa, "SI", "NO"),
    " representa el total de los datos,\n", sep = "")
cat("porque su intervalo al 95% (", pct(ic_wald["lim_inf"]), " a ",
    pct(ic_wald["lim_sup"]),
    ") contiene la proporcion poblacional (", pct(prop_poblacion), ").\n",
    sep = "")
cat("El intervalo con los 10.000 registros es mas angosto simplemente porque el error",
    "estandar\nde una proporcion decrece con sqrt(n): mas datos, menos incertidumbre.\n")

# Guardamos los resultados para el informe
res_consigna6 <- list(prop_poblacion = prop_poblacion,
                      multados_poblacion = multados_pob,
                      prop_muestra = prop_muestra,
                      multados_muestra = multados_muestra,
                      n_muestra = n_muestra,
                      arranque = sistematica$arranque,
                      ic_wald = ic_wald,
                      ic_fpc = ic_fpc,
                      ic_wilson = ic_wilson,
                      tabla_ic = tabla_ic_sistematica,
                      fpc = fpc)
res_consigna7 <- list(ic_completa = ic_completa,
                      ancho_sistematica = ancho_sistematica,
                      ancho_completa = ancho_completa,
                      razon_anchos = razon_anchos,
                      representa = representa)
