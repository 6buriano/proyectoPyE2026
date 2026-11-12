# =====================================================================
# R/03_decisiones.R
# Las siete preguntas de la letra ("Se busca contestar").
#
#   1. ¿Conviene ofrecer planes para pagar online que inicien a las 10:00?
#   2. Ventajas y desventajas de un plan de 5 unidades por el precio de 4.
#   3. Ventajas y desventajas de un plan de 4 unidades, 4 dias por semana,
#      con exoneracion de 4 unidades el 5to dia.
#   4. Idem anterior pero con 4 dias consecutivos.
#   5. ¿Los datos de uso por dia siguen una distribucion normal?
#   6. Proporcion de autos multados por total de usuarios: total, mensual,
#      semanal y por dia de la semana.
#   7. Intervalos de recaudacion por concepto, con 90%, 95% y 99%.
#
# Requiere: R/parametros.r, R/funciones.r, R/data.r, R/01_descriptivos.R
# y R/02_inferencia.R ya leidos.
# =====================================================================

titulo("PARTE 3 - PREGUNTAS DE DECISION")

# Base de facturacion de un uso: todas las unidades de 30 minutos que el
# usuario ocupa (las canceladas por adelantado mas las extensiones).
# Las multas se mantienen aparte porque son un concepto distinto.
UNIDADES_POR_REGISTRO <- MA$horas_canceladas + MA$extension_horas
RECAUDACION_UNIDADES  <- UNIDADES_POR_REGISTRO * TARIFA_UNIDAD

# Recaudacion observada del mes, por concepto. Ojo: estas variables son
# vectores, uno por registro; los totales del mes son la SUMA de esos
# vectores y se guardan aparte como escalares, para no confundir nunca un
# valor por registro con un total.
recaudacion_canceladas  <- MA$horas_canceladas * TARIFA_UNIDAD
recaudacion_extensiones <- MA$extension_horas  * TARIFA_UNIDAD
recaudacion_multas      <- MA$valor_multa
recaudacion_total       <- recaudacion_canceladas + recaudacion_extensiones +
  recaudacion_multas

total_canceladas  <- sum(recaudacion_canceladas)
total_extensiones <- sum(recaudacion_extensiones)
total_multas      <- sum(recaudacion_multas)
total_general     <- sum(recaudacion_total)


# =====================================================================
# PREGUNTA 1: ¿conviene un plan online que inicie a las 10:00?
# =====================================================================
subtitulo("Pregunta 1: ¿conviene ofrecer planes online que inicien a las 10:00?")

# El plan solo lo pueden usar los que empiezan a las 10:00 o despues: los
# que ya estan estacionados antes de esa hora quedan afuera.
antes_de_10      <- minutos_inicio < 10 * 60
prop_antes       <- mean(antes_de_10)
ic_antes         <- icProporcion(sum(antes_de_10), nrow(MA), conf = CONF_NIVEL)
prop_despues     <- 1 - prop_antes

cat("Usos que empiezan antes de las 10:00 ...", sum(antes_de_10),
    "(", pct(prop_antes), ")\n")
cat("Usos que empiezan a las 10:00 o despues", sum(!antes_de_10),
    "(", pct(prop_despues), ")\n")
cat("IC 95% para la proporcion que empieza antes de las 10:00:",
    pct(ic_antes["lim_inf"]), "a", pct(ic_antes["lim_sup"]), "\n")
cat("Usos perdidos si el plan fuera EXCLUSIVO para despues de las 10:00:",
    sum(antes_de_10), " (", pct(prop_antes), " de la recaudacion potencial)\n", sep = "")

cat("\nComo el", pct(prop_despues), "de los usos empieza a las 10:00 o despues,\n")
cat("el plan es utilizable por la gran mayoria de los clientes. Conviene ofrecerlo,\n")
cat("pero como complemento del estacionamiento presencial y no como reemplazo:\n")
cat("los", sum(antes_de_10), "usos que empiezan antes de las 10:00 necesitan otra via de pago.\n")

res_p1 <- list(prop_antes = prop_antes, prop_despues = prop_despues,
               ic_antes = ic_antes, n_antes = sum(antes_de_10))


# =====================================================================
# PREGUNTA 2: plan de 5 unidades por el precio de 4
# =====================================================================
subtitulo("Pregunta 2: plan de 5 unidades por el precio de 4")

# Se aplica sobre las unidades de cada uso: cada bloque completo de 5
# unidades paga solo 4. O sea, se regala una unidad por cada 5.
unidades_gratis_5x4 <- floor(UNIDADES_POR_REGISTRO / 5)
recaudacion_con_plan_5x4 <- (UNIDADES_POR_REGISTRO - unidades_gratis_5x4) * TARIFA_UNIDAD +
  recaudacion_multas
pierde_5x4    <- total_general - sum(recaudacion_con_plan_5x4)
prop_benef_5x4 <- mean(UNIDADES_POR_REGISTRO >= 5)

cat("Usos con 5 unidades o mas ............", pct(prop_benef_5x4),
    " (los que aprovechan el plan)\n")
cat("Recaudacion actual (todas las unidades)", pesos(total_general, 0), "\n")
cat("Recaudacion con el plan ..............", pesos(sum(recaudacion_con_plan_5x4), 0), "\n")
cat("Recaudacion que se deja de cobrar ....", pesos(pierde_5x4, 0),
    " (", pct(pierde_5x4 / total_general), ")\n", sep = "")
cat("Unidades regaladas en el mes .........", sum(unidades_gratis_5x4), "\n")
cat("Recaudacion media por uso ............", pesos(mean(RECAUDACION_UNIDADES)),
    "->", pesos(mean((UNIDADES_POR_REGISTRO - unidades_gratis_5x4) * TARIFA_UNIDAD)), "\n")

cat("\nVentajas:\n")
cat("  - Incentiva estadias mas largas: el cliente que iba a comprar 4 unidades\n")
cat("    tiene un motivo para comprar 5 (paga lo mismo).\n")
cat("  - Es un beneficio facil de comunicar y de auditar (una regla simple).\n")
cat("  - El costo es acotado y predecible: una unidad por cada cinco.\n")
cat("Desventajas:\n")
cat("  - Se resigna el ", pct(pierde_5x4 / total_general),
    " de la recaudacion por unidades.\n", sep = "")
cat("  - El usuario que ya compraba 5 unidades paga menos sin cambiar su conducta:\n")
cat("    parte del descuento es una transferencia, no un incentivo.\n")
cat("  - Complica la liquidacion de las extensiones, que se cobran despues.\n")

res_p2 <- list(prop_benef = prop_benef_5x4,
               recaudacion_actual = total_general,
               recaudacion_plan = sum(recaudacion_con_plan_5x4),
               pierde = pierde_5x4,
               pierde_pct = pierde_5x4 / total_general,
               unidades_gratis = sum(unidades_gratis_5x4),
               media_actual = mean(RECAUDACION_UNIDADES),
               media_plan = mean((UNIDADES_POR_REGISTRO - unidades_gratis_5x4) * TARIFA_UNIDAD))


# =====================================================================
# PREGUNTAS 3 y 4: plan de 4 unidades, 4 dias por semana
# =====================================================================
subtitulo("Preguntas 3 y 4: plan de 4 unidades, 4 dias por semana, con el 5to dia exonerado")

# Se agrupa por usuario y semana: para cada usuario en cada semana se mira
# cuantas unidades uso en cada uno de los 5 dias habiles.
unidades_por_dia <- aggregate(
  cbind(unidades = UNIDADES_POR_REGISTRO),
  by = list(id = MA$id, semana = MA$semana, dia_semana = MA$dia_semana),
  FUN = sum)

# exoneracionUsuario(u, consecutivos)
#   Que hace : calcula cuantas unidades se le exoneran a UN usuario en UNA
#              semana, segun el plan: 4 dias con al menos 4 unidades, y el
#              dia que queda afuera se exonera hasta 4 unidades.
#   Recibe   : u = vector de 5 posiciones con las unidades de cada dia
#              (0 si ese dia no uso el estacionamiento).
#              consecutivos = TRUE exige que los 4 dias sean consecutivos.
#   Devuelve : las unidades exoneradas (0 si no califica).
#   Detalle  : se prueban los 5 casos posibles (cual dia queda libre) y se
#              toma el mejor para el usuario, que es el peor caso para la
#              recaudacion. La exoneracion nunca supera 4 unidades.
exoneracionUsuario <- function(u, consecutivos = FALSE,
                               diasRequeridos = 4, minimoPorDia = 4,
                               topeExoneracion = 4) {

  mejor <- 0

  for (diaLibre in 1:5) {

    diasPagos <- setdiff(1:5, diaLibre)

    # si el plan exige dias consecutivos, los 4 dias pagos tienen que serlo
    if (consecutivos && !all(diff(diasPagos) == 1)) next

    # los 4 dias pagos tienen que alcanzar el minimo de unidades
    if (!all(u[diasPagos] >= minimoPorDia)) next

    # el 5to dia se exonera hasta el tope (si no lo uso, no hay nada que exonerar)
    mejor <- max(mejor, min(topeExoneracion, u[diaLibre]))
  }

  return(mejor)
}

# evaluarPlanSemanal(datos, consecutivos)
#   Que hace : aplica el plan a todos los usuario-semana y devuelve el costo.
#   Recibe   : datos = salida del aggregate anterior, consecutivos = TRUE/FALSE.
#   Devuelve : lista con usuarios_semana, beneficiarios, unidades_exoneradas
#              y monto_exonerado.
evaluarPlanSemanal <- function(datos, consecutivos = FALSE) {

  claves <- unique(datos[c("id", "semana")])
  exoneradas <- numeric(nrow(claves))

  for (i in seq_len(nrow(claves))) {
    sub <- datos[datos$id == claves$id[i] & datos$semana == claves$semana[i], ]
    u <- rep(0, 5)
    u[sub$dia_semana] <- sub$unidades
    exoneradas[i] <- exoneracionUsuario(u, consecutivos = consecutivos)
  }

  return(list(usuarios_semana = nrow(claves),
              beneficiarios = sum(exoneradas > 0),
              unidades_exoneradas = sum(exoneradas),
              monto_exonerado = sum(exoneradas) * TARIFA_UNIDAD,
              detalle = data.frame(claves, exoneradas = exoneradas)))
}

# --- Pregunta 3: 4 dias cualesquiera de la semana
plan_libre    <- evaluarPlanSemanal(unidades_por_dia, consecutivos = FALSE)
# --- Pregunta 4: 4 dias consecutivos
plan_consec   <- evaluarPlanSemanal(unidades_por_dia, consecutivos = TRUE)

tabla_planes <- data.frame(
  variante = c("4 dias cualesquiera", "4 dias consecutivos"),
  usuarios_semana = c(plan_libre$usuarios_semana, plan_consec$usuarios_semana),
  beneficiarios = c(plan_libre$beneficiarios, plan_consec$beneficiarios),
  prop_beneficiarios = c(plan_libre$beneficiarios / plan_libre$usuarios_semana,
                         plan_consec$beneficiarios / plan_consec$usuarios_semana),
  unidades_exoneradas = c(plan_libre$unidades_exoneradas, plan_consec$unidades_exoneradas),
  monto_exonerado = c(plan_libre$monto_exonerado, plan_consec$monto_exonerado)
)
tabla_planes$monto_sobre_recaudacion <- tabla_planes$monto_exonerado / total_general

cat("Parejas usuario-semana analizadas:", plan_libre$usuarios_semana, "\n")

# Contexto: el plan exige 4 dias de uso en la semana, asi que conviene
# mostrar cual es el patron real de uso semanal. Sin esto, el numero de
# beneficiarios se lee mal.
dias_por_usuario_semana <- aggregate(dia_semana ~ id + semana,
                                     data = unidades_por_dia, FUN = length)
dias_promedio   <- mean(dias_por_usuario_semana$dia_semana)
con_cuatro_dias <- sum(dias_por_usuario_semana$dia_semana >= 4)

cat("Dias por semana que usa el usuario promedio: ", num(dias_promedio), "\n", sep = "")
cat("Parejas que usan 4 dias o mas en la semana: ", con_cuatro_dias, " (",
    pct(con_cuatro_dias / plan_libre$usuarios_semana), ")\n\n", sep = "")
cat("Resultado comparado de las dos variantes del plan:\n")
mostrar(tabla_planes, dec = 4)

cat("\nPregunta 3 - 4 dias cualesquiera:\n")
cat("  Cumplen el patron ", plan_libre$beneficiarios, " parejas usuario-semana (",
    pct(plan_libre$beneficiarios / plan_libre$usuarios_semana), ").\n", sep = "")
cat("  Se exoneran ", plan_libre$unidades_exoneradas, " unidades = ",
    pesos(plan_libre$monto_exonerado, 0), " (",
    pct(plan_libre$monto_exonerado / total_general), " de la recaudacion).\n", sep = "")

cat("\nPregunta 4 - 4 dias consecutivos:\n")
cat("  Cumplen el patron ", plan_consec$beneficiarios, " parejas usuario-semana (",
    pct(plan_consec$beneficiarios / plan_consec$usuarios_semana), ").\n", sep = "")
cat("  Se exoneran ", plan_consec$unidades_exoneradas, " unidades = ",
    pesos(plan_consec$monto_exonerado, 0), " (",
    pct(plan_consec$monto_exonerado / total_general), " de la recaudacion).\n", sep = "")

cat("\nDiferencia entre las dos variantes:\n")
cat("  La variante de dias consecutivos es MAS restrictiva: exige que los 4 dias\n")
cat("  con al menos 4 unidades sean un bloque de lunes a jueves o de martes a\n")
cat("  viernes, mientras que la otra acepta cualquier combinacion de 4 dias de 5.\n")
cat("  Por eso tiene menos beneficiarios (", plan_consec$beneficiarios, " contra ",
    plan_libre$beneficiarios, ") y cuesta menos (",
    pesos(plan_consec$monto_exonerado), " contra ",
    pesos(plan_libre$monto_exonerado), ").\n", sep = "")

cat("\nVentajas de las dos variantes:\n")
cat("  - Fideliza al usuario frecuente, que es el que mas recaudacion aporta.\n")
cat("  - El costo es muy bajo respecto de la recaudacion total.\n")
cat("  - Exige un compromiso de uso, asi que se parece a un abono.\n")
cat("Desventajas:\n")
cat("  - Solo beneficia a una minoria; el resto de los usuarios no percibe la mejora.\n")
cat("  - Es dificil de explicar y de liquidar (hay que agrupar por usuario y semana).\n")
cat("  - Con la variante de dias consecutivos, un feriado o una ausencia rompe el patron\n")
cat("    y el usuario pierde el beneficio, lo que genera reclamos.\n")

res_p3 <- plan_libre
res_p4 <- plan_consec
res_tabla_planes <- tabla_planes


# =====================================================================
# PREGUNTA 5: ¿los datos de uso por dia siguen una distribucion normal?
# =====================================================================
subtitulo("Pregunta 5: ¿el uso por dia sigue una distribucion normal?")

# Para testear normalidad se necesita una variable continua y varias
# observaciones. La candidata natural es el total diario: 20 dias habiles.
totales_diarios <- data.frame(
  dia = sort(unique(MA$dia)),
  registros = as.vector(tapply(MA$multa, MA$dia, length)),
  unidades = as.vector(tapply(UNIDADES_POR_REGISTRO, MA$dia, sum)),
  recaudacion = as.vector(tapply(recaudacion_total, MA$dia, sum))
)
totales_diarios$dia_semana <- (totales_diarios$dia - 1) %% 5 + 1

prueba_registros   <- shapiro.test(totales_diarios$registros)
prueba_unidades    <- shapiro.test(totales_diarios$unidades)
prueba_recaudacion <- shapiro.test(totales_diarios$recaudacion)

cat("Totales diarios (n =", nrow(totales_diarios), "dias):\n")
mostrar(totales_diarios, dec = 0)

cat("\nPrueba de Shapiro-Wilk (H0: los datos provienen de una distribucion normal)\n")
cat("  Registros por dia ....... W =", num(prueba_registros$statistic, 4),
    " p-valor =", num(prueba_registros$p.value, 4), "\n")
cat("  Unidades por dia ........ W =", num(prueba_unidades$statistic, 4),
    " p-valor =", num(prueba_unidades$p.value, 4), "\n")
cat("  Recaudacion por dia ..... W =", num(prueba_recaudacion$statistic, 4),
    " p-valor =", num(prueba_recaudacion$p.value, 4), "\n")

# Con 20 observaciones se rechaza si p-valor < 0,05
alfa <- 0.05
cat("\nCon alfa =", alfa, ":\n")
for (nombre in c("registros", "unidades", "recaudacion")) {
  pval <- switch(nombre,
                 registros = prueba_registros$p.value,
                 unidades = prueba_unidades$p.value,
                 recaudacion = prueba_recaudacion$p.value)
  cat("  ", nombre, ": ",
      ifelse(pval < alfa,
             "se RECHAZA la normalidad",
             "NO se rechaza la normalidad (es compatible con una normal)"),
      "\n", sep = "")
}

# El registro individual NO puede ser normal: es una variable discreta
# (unidades de 30 minutos) y solo toma pocos valores.
cat("\nOjo con el nivel de analisis: el registro individual (unidades por uso) es una\n")
cat("variable discreta que toma pocos valores, asi que no puede ser normal. Lo que se\n")
cat("testea es el total diario, que se aproxima a una normal por el teorema central\n")
cat("del limite (suma de muchos usos independientes).\n")

# Graficos de normalidad de los totales diarios
dir.create("figuras", showWarnings = FALSE)
png("figuras/normalidad_totales_diarios.png", width = 1000, height = 520, res = 110)
par(mfrow = c(1, 2))
hist(totales_diarios$registros, freq = FALSE, main = "Registros por dia",
     xlab = "Registros", ylab = "Densidad", col = "lightsteelblue")
lines(density(totales_diarios$registros), lwd = 2, col = "darkblue")
curve(dnorm(x, mean(totales_diarios$registros), sd(totales_diarios$registros)),
      add = TRUE, lwd = 2, col = "darkred")
legend("topright", lwd = 2, col = c("darkblue", "darkred"),
       legend = c("densidad observada", "normal ajustada"), bty = "n", cex = 0.8)
qqnorm(totales_diarios$registros, main = "QQ-plot: registros por dia")
qqline(totales_diarios$registros, col = "darkred", lwd = 2)
dev.off()
cat("\nGrafico guardado en figuras/normalidad_totales_diarios.png\n")

res_p5 <- list(totales = totales_diarios,
               pruebas = list(registros = prueba_registros,
                              unidades = prueba_unidades,
                              recaudacion = prueba_recaudacion),
               alfa = alfa)


# =====================================================================
# PREGUNTA 6: proporcion de autos multados por ambito
# =====================================================================
subtitulo("Pregunta 6: proporcion de autos multados sobre el total de usuarios")

# Se calcula la proporcion de multados en cuatro ambitos: total, mensual,
# semanal y por dia de la semana, con su intervalo de confianza al 95%.
# Se informan DOS lecturas del denominador:
#   a) sobre los USOS   (cada vez que un auto se estaciono)
#   b) sobre los USUARIOS DISTINTOS (autos que se estacionaron al menos una vez)
# La letra dice "sobre el total de usuarios", asi que la lectura (b) es la
# literal; la (a) es la que se usa para estimar probabilidades por visita.

proporcionPorAmbito <- function(datos, etiqueta) {

  x <- sum(datos$multa)
  n <- nrow(datos)
  ic <- icProporcion(x, n, conf = CONF_NIVEL)

  # lectura por usuarios: un usuario cuenta como multado si tuvo al menos una multa
  usuarios <- length(unique(datos$id))
  usuarios_multados <- length(unique(datos$id[datos$multa == 1]))
  ic_usuarios <- icProporcion(usuarios_multados, usuarios, conf = CONF_NIVEL)

  return(data.frame(
    ambito = etiqueta,
    registros = n,
    multados = x,
    prop_usos = x / n,
    li_usos = ic["lim_inf"],
    ls_usos = ic["lim_sup"],
    usuarios = usuarios,
    usuarios_multados = usuarios_multados,
    prop_usuarios = usuarios_multados / usuarios,
    li_usuarios = ic_usuarios["lim_inf"],
    ls_usuarios = ic_usuarios["lim_sup"]
  ))
}

ambitos <- rbind(
  proporcionPorAmbito(MA, "Total del archivo"),
  proporcionPorAmbito(MA[MA$semana %in% 1:4, ], "Mensual (4 semanas)"),
  proporcionPorAmbito(MA[MA$semana == 1, ], "Semana 1"),
  proporcionPorAmbito(MA[MA$semana == 2, ], "Semana 2"),
  proporcionPorAmbito(MA[MA$semana == 3, ], "Semana 3"),
  proporcionPorAmbito(MA[MA$semana == 4, ], "Semana 4"),
  proporcionPorAmbito(MA[MA$dia_semana == 1, ], "Lunes"),
  proporcionPorAmbito(MA[MA$dia_semana == 2, ], "Martes"),
  proporcionPorAmbito(MA[MA$dia_semana == 3, ], "Miercoles"),
  proporcionPorAmbito(MA[MA$dia_semana == 4, ], "Jueves"),
  proporcionPorAmbito(MA[MA$dia_semana == 5, ], "Viernes")
)

cat("a) Sobre los USOS (cada vez que un auto se estaciono):\n")
mostrar(ambitos[c("ambito", "registros", "multados", "prop_usos", "li_usos",
                  "ls_usos")], dec = 4)

cat("\nb) Sobre los USUARIOS distintos (autos que se estacionaron al menos una vez):\n")
mostrar(ambitos[c("ambito", "usuarios", "usuarios_multados", "prop_usuarios",
                  "li_usuarios", "ls_usuarios")], dec = 4)

cat("\nNota 1: el ambito 'mensual' coincide con el total porque el archivo ES el mes\n")
cat("(las 4 semanas). Se informa igual para completar lo que pide la letra.\n")
cat("Nota 2: estos intervalos no llevan la correccion por poblacion finita. Si se\n")
cat("aplicara, se angostarian alrededor de un 5% (el factor es ", num(fpc, 4), ").\n", sep = "")

cat("\nLectura: sobre los usos, la proporcion de multados ronda el",
    pct(ambitos$prop_usos[1]), "en todos los ambitos.\n")
cat("Sobre los usuarios distintos es mucho mas alta (",
    pct(ambitos$prop_usuarios[1]), ") porque un auto que se\n", sep = "")
cat("estaciona varias veces por semana tiene mas oportunidades de ser multado: la\n")
cat("probabilidad de no ser multado nunca en el mes es (1 - ",
    num(ambitos$prop_usos[1], 3), ")^",
    num(nrow(MA) / length(unique(MA$id)), 1), " = ",
    pct((1 - ambitos$prop_usos[1])^(nrow(MA) / length(unique(MA$id)))), ".\n", sep = "")

res_p6 <- ambitos


# =====================================================================
# PREGUNTA 7: intervalos de recaudacion por concepto, al 90%, 95% y 99%
# =====================================================================
subtitulo("Pregunta 7: intervalos de recaudacion por concepto (90%, 95% y 99%)")

conceptos <- list(Canceladas  = recaudacion_canceladas,
                  Extensiones = recaudacion_extensiones,
                  Multas      = recaudacion_multas,
                  Total       = recaudacion_total)

niveles <- c(0.90, 0.95, 0.99)

tabla_recaudacion <- do.call(rbind, lapply(names(conceptos), function(nombre) {
  valores <- conceptos[[nombre]]
  do.call(rbind, lapply(niveles, function(nivel) {
    ic <- icTotal(valores, conf = nivel, N = nrow(MA))
    data.frame(
      concepto = nombre,
      confianza = pct(nivel, 0),
      total_observado = sum(valores),
      media_por_registro = mean(valores),
      lim_inf = as.numeric(ic["lim_inf"]),
      lim_sup = as.numeric(ic["lim_sup"]),
      ancho = as.numeric(ic["lim_sup"]) - as.numeric(ic["lim_inf"])
    )
  }))
}))

cat("Recaudacion observada del mes, por concepto:\n")
mostrar(unique(tabla_recaudacion[c("concepto", "media_por_registro", "total_observado")]),
        dec = 2)

cat("\nIntervalos de confianza para el total del mes (pesos):\n")
mostrar(tabla_recaudacion, dec = 0)

cat("\nParticipacion de cada concepto en la recaudacion total:\n")
for (nombre in names(conceptos)[1:3]) {
  cat(" ", nombre, ": ", pesos(sum(conceptos[[nombre]])),
      " (", pct(sum(conceptos[[nombre]]) / total_general), ")\n", sep = "")
}
cat("  Total   : ", pesos(total_general, 0), "\n", sep = "")

cat("\nComo se calcula: el total poblacional se estima como N x (media +/- z * EE),\n")
cat("con N =", nrow(MA), "registros. Al 90% z = 1,645; al 95% z = 1,96; al 99% z = 2,576.\n")
cat("Cuanto mayor es la confianza, mas ancho es el intervalo: se gana seguridad y se\n")
cat("pierde precision.\n")
cat("\nInterpretacion: como el archivo ES la poblacion del mes, el total observado es un\n")
cat("dato, no una estimacion. El intervalo describe la recaudacion esperada si el\n")
cat("proceso que genera los usos se repitiera, con la misma variabilidad.\n")

res_p7 <- tabla_recaudacion

# Resumen final de recaudaciones para el informe
res_recaudacion <- list(canceladas = sum(recaudacion_canceladas),
                        extensiones = sum(recaudacion_extensiones),
                        multas = sum(recaudacion_multas),
                        total = total_general)
