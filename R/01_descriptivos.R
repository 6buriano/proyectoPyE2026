# =====================================================================
# R/01_descriptivos.R
# Consignas 1 a 5 de la letra: estadistica descriptiva.
#
#   1. Valor promedio de las horas solicitadas de uso.
#   2. Promedio de la hora de inicio del uso.
#   3. Promedio de las extensiones, de los multados y de los montos.
#   4. Usuarios promedios por semana y por dia de la semana.
#   5. Todo lo anterior discriminado por dia de la semana y por turno.
#
# Requiere: R/parametros.r, R/funciones.r y R/data.r ya leidos (MA).
# =====================================================================

titulo("PARTE 1 - ESTADISTICA DESCRIPTIVA (consignas 1 a 5)")

# Una unidad de tiempo = 30 minutos. Se usa mucho, conviene tenerlo a mano.
MINUTOS_POR_UNIDAD <- 30
UNIDADES_POR_HORA  <- 60 / MINUTOS_POR_UNIDAD   # 2 unidades por hora


# =====================================================================
# CONSIGNA 1: valor promedio de las horas solicitadas de uso
# =====================================================================
subtitulo("Consigna 1: valor promedio de las horas solicitadas de uso")

# "Horas solicitadas" = lo que el usuario paga por adelantado, o sea la
# columna horas_canceladas. Esta expresada en unidades de 30 minutos, asi
# que se informa en unidades y convertida a horas.
prom_canceladas_unidades <- mean(MA$horas_canceladas)
prom_canceladas_horas    <- prom_canceladas_unidades / UNIDADES_POR_HORA
mediana_canceladas       <- median(MA$horas_canceladas)
sd_canceladas            <- sd(MA$horas_canceladas)

cat("Promedio de horas canceladas .......", num(prom_canceladas_unidades),
    "unidades de 30 min\n")
cat("Equivalente en horas ...............", num(prom_canceladas_horas), "horas\n")
cat("Mediana ............................", num(mediana_canceladas), "unidades\n")
cat("Desvio estandar ....................", num(sd_canceladas), "unidades\n")

# Distribucion de las horas canceladas
tabla_canceladas <- as.data.frame(table(horas_canceladas = MA$horas_canceladas))
tabla_canceladas$proporcion <- tabla_canceladas$Freq / nrow(MA)
tabla_canceladas$acumulada  <- cumsum(tabla_canceladas$proporcion)
tabla_canceladas$horas      <- as.numeric(as.character(tabla_canceladas$horas_canceladas)) /
  UNIDADES_POR_HORA
names(tabla_canceladas)[2] <- "registros"

cat("\nDistribucion de las horas canceladas (1 unidad = 30 minutos):\n")
mostrar(tabla_canceladas[c("horas_canceladas", "horas", "registros",
                           "proporcion", "acumulada")], dec = 3)

cat("\nLectura: cada uso solicita en promedio", num(prom_canceladas_unidades),
    "unidades, o sea", num(prom_canceladas_horas), "horas pagadas por adelantado.\n")
cat("La mediana (", num(mediana_canceladas),
    " unidades) es menor que el promedio: unos pocos usos muy largos\n", sep = "")
cat("estiran la media hacia arriba.\n")

# Dato complementario: el uso completo incluye la extension comprada.
prom_uso_completo <- mean(MA$horas_canceladas + MA$extension_horas)
cat("Si se suma la extension de hora (consigna 3), el uso completo promedia ",
    num(prom_uso_completo), " unidades = ", num(prom_uso_completo / UNIDADES_POR_HORA),
    " horas.\n", sep = "")


# =====================================================================
# CONSIGNA 2: promedio de la hora de inicio
# =====================================================================
subtitulo("Consigna 2: promedio de la hora de inicio del uso")

# No se puede promediar la hora codificada directamente: se pasa a
# minutos, se promedia y se vuelve a HH:MM.
minutos_inicio     <- convertirAMinutos(MA$hora_inicio)
prom_inicio_min    <- mean(minutos_inicio)
mediana_inicio_min <- median(minutos_inicio)
sd_inicio_min      <- sd(minutos_inicio)
hora_promedio      <- formatoHoraMinutos(prom_inicio_min)
hora_mediana       <- formatoHoraMinutos(mediana_inicio_min)

cat("Hora de inicio promedio ............", hora_promedio,
    " (", num(prom_inicio_min, 1), " minutos desde las 00:00)\n", sep = "")
cat("Hora de inicio mediana .............", hora_mediana, "\n")
cat("Desvio estandar ....................", num(sd_inicio_min, 1),
    " minutos (", num(sd_inicio_min / 60), " horas)\n", sep = "")
cat("Primer y ultimo inicio observados ..",
    formatoHoraMinutos(min(minutos_inicio)), "y",
    formatoHoraMinutos(max(minutos_inicio)), "\n")

cat("\nPor que se convierte a minutos:");
cat("\n  el promedio de la hora tal cual seria ", num(mean(MA$hora_inicio), 3),
    ", que no es una hora valida\n", sep = "")
cat("  (la parte decimal serian 80 minutos). En minutos da ",
    num(prom_inicio_min, 1), " -> ", hora_promedio, ".\n", sep = "")

# Distribucion de los inicios por hora entera
hora_entera <- floor(MA$hora_inicio)
tabla_horas <- as.data.frame(table(hora = hora_entera))
tabla_horas$proporcion <- tabla_horas$Freq / nrow(MA)
names(tabla_horas)[2] <- "registros"
cat("\nRegistros por hora de inicio:\n")
mostrar(tabla_horas, dec = 3)


# =====================================================================
# CONSIGNA 3: extensiones, multados y montos de las multas
# =====================================================================
subtitulo("Consigna 3: extensiones, multados y montos de las multas")

prom_extension_unidades <- mean(MA$extension_horas)
prom_extension_horas    <- prom_extension_unidades / UNIDADES_POR_HORA
n_multados              <- sum(MA$multa)
prop_multados           <- mean(MA$multa)
monto_medio_multados    <- mean(MA$valor_multa[MA$multa == 1])
monto_medio_global      <- mean(MA$valor_multa)   # incluye los ceros
monto_total_multas      <- sum(MA$valor_multa)

cat("Extension promedio .................", num(prom_extension_unidades),
    "unidades de 30 min =", num(prom_extension_horas), "horas\n")
cat("Usos multados ......................", n_multados, "de", nrow(MA),
    "(", pct(prop_multados), ")\n")
cat("Monto medio entre los multados .....", pesos(monto_medio_multados), "\n")
cat("Monto medio por registro (global) ..", pesos(monto_medio_global),
    "  <- incluye los ceros\n", sep = "")
cat("Recaudacion total por multas .......", pesos(monto_total_multas, 0), "\n")

# Distribucion de los valores de la multa
tabla_multas <- as.data.frame(table(valor_multa = MA$valor_multa))
names(tabla_multas)[2] <- "registros"
tabla_multas$proporcion <- tabla_multas$registros / nrow(MA)
cat("\nDistribucion del valor de la multa:\n")
mostrar(tabla_multas, dec = 4)

cat("\nLectura: la multa promedio es ", pesos(monto_medio_multados),
    " entre los multados, pero como\n", sep = "")
cat("solo el ", pct(prop_multados),
    " de los usos termina multado, el aporte medio por registro es ",
    pesos(monto_medio_global), ".\n", sep = "")


# =====================================================================
# CONSIGNA 4: usuarios promedio por semana y por dia de la semana
# =====================================================================
subtitulo("Consigna 4: usuarios promedio por semana y por dia de la semana")

# Se arma una tabla con una fila por dia habil (20 filas). Para cada dia:
# registros (usos) y usuarios DISTINTOS. Esa distincion es la clave de la
# consigna: un mismo usuario puede estacionar varias veces el mismo dia.
dias <- data.frame(dia = sort(unique(MA$dia)))
dias$semana     <- (dias$dia - 1) %/% 5 + 1
dias$dia_semana <- (dias$dia - 1) %% 5 + 1
dias$registros  <- as.vector(table(MA$dia))
dias$usuarios   <- sapply(dias$dia, function(d) length(unique(MA$id[MA$dia == d])))

usos_por_dia     <- mean(dias$registros)
usuarios_por_dia <- mean(dias$usuarios)

# Usuarios distintos por semana: se cuentan los usuarios UNICOS de cada
# semana. Ojo: es distinto de sumar los usuarios distintos de cada dia,
# porque el mismo usuario vuelve varios dias de la misma semana.
usuarios_semana <- sapply(1:N_SEMANAS, function(s) {
  length(unique(MA$id[MA$semana == s]))
})

cat("USOS (registros) promedio por dia ...", num(usos_por_dia), "\n")
cat("USOS por semana .....................", num(usos_por_dia * 5), "\n")
cat("USUARIOS distintos promedio por dia .", num(usuarios_por_dia), "\n")
cat("USUARIOS distintos por semana .......", num(mean(usuarios_semana)),
    " (promedio de las 4 semanas)\n")
cat("Usuarios distintos en todo el mes ...", length(unique(MA$id)), "\n")
cat("Usos por usuario en el mes ..........",
    num(nrow(MA) / length(unique(MA$id))), "\n")

# Por semana: totales y promedios por dia
tabla_semanas <- data.frame(
  semana = 1:N_SEMANAS,
  registros = as.vector(tapply(dias$registros, dias$semana, sum)),
  usuarios_distintos = usuarios_semana,
  usos_por_dia = as.vector(tapply(dias$registros, dias$semana, mean)),
  usuarios_por_dia = as.vector(tapply(dias$usuarios, dias$semana, mean))
)
cat("\nPor semana:\n")
mostrar(tabla_semanas)

# Por dia de la semana: promedio por dia concreto (cada dia de la semana
# aparece 4 veces en el mes)
tabla_dia_semana <- data.frame(
  dia_semana = 1:5,
  dias = as.vector(table(dias$dia_semana)),
  registros = as.vector(tapply(dias$registros, dias$dia_semana, sum)),
  usos_por_dia = as.vector(tapply(dias$registros, dias$dia_semana, mean)),
  usuarios_por_dia = as.vector(tapply(dias$usuarios, dias$dia_semana, mean))
)
tabla_dia_semana$dia_semana <- as.character(nombreDiaSemana(tabla_dia_semana$dia_semana))
cat("\nPor dia de la semana (promedio por dia concreto):\n")
mostrar(tabla_dia_semana)

cat("\nLectura: hay", num(usos_por_dia), "usos por dia pero solo",
    num(usuarios_por_dia), "usuarios distintos por dia,\nporque cada usuario",
    "estaciona", num(nrow(MA) / length(unique(MA$id))), "veces en el mes.\n")
cat("En la semana pasan", num(mean(usuarios_semana)), "usuarios distintos, menos que la suma de\n")
cat("los distintos de cada dia (", num(sum(usuarios_por_dia) * 5), "): el mismo usuario vuelve.\n",
    sep = "")


# =====================================================================
# CONSIGNA 5: lo mismo discriminado por dia de la semana y por turno
# =====================================================================
subtitulo("Consigna 5: discriminado por dia de la semana y por turno (manana/tarde)")

# Tabla por dia de la semana con todas las medidas de las consignas 1 a 3
tabla_por_dia <- do.call(rbind, lapply(1:5, function(d) {
  sub <- MA[MA$dia_semana == d, ]
  data.frame(
    dia_semana = DIAS_SEMANA[d],
    registros = nrow(sub),
    canceladas_u = mean(sub$horas_canceladas),
    extension_u = mean(sub$extension_horas),
    prop_multados = mean(sub$multa),
    monto_medio_multa = mean(sub$valor_multa),
    hora_inicio_media = formatoHoraMinutos(mean(convertirAMinutos(sub$hora_inicio)))
  )
}))
names(tabla_por_dia)[3] <- "canceladas_u"

cat("Por dia de la semana:\n")
mostrar(tabla_por_dia, dec = 3)

# Tabla por turno
tabla_por_turno <- do.call(rbind, lapply(levels(MA$turno), function(t) {
  sub <- MA[MA$turno == t, ]
  data.frame(
    turno = t,
    registros = nrow(sub),
    proporcion = nrow(sub) / nrow(MA),
    canceladas_u = mean(sub$horas_canceladas),
    extension_u = mean(sub$extension_horas),
    prop_multados = mean(sub$multa),
    monto_medio_multa = mean(sub$valor_multa),
    hora_inicio_media = formatoHoraMinutos(mean(convertirAMinutos(sub$hora_inicio)))
  )
}))
cat("\nPor turno (manana = inicio antes de las ", HORA_CORTE_TURNO, ":00):\n", sep = "")
mostrar(tabla_por_turno, dec = 3)

# Cruce turno x dia de la semana
tabla_cruce <- do.call(rbind, lapply(levels(MA$turno), function(t) {
  do.call(rbind, lapply(1:5, function(d) {
    sub <- MA[MA$turno == t & MA$dia_semana == d, ]
    data.frame(
      turno = t,
      dia_semana = DIAS_SEMANA[d],
      registros = nrow(sub),
      canceladas_u = mean(sub$horas_canceladas),
      extension_u = mean(sub$extension_horas),
      prop_multados = mean(sub$multa)
    )
  }))
}))
cat("\nCruce turno x dia de la semana:\n")
mostrar(tabla_cruce, dec = 3)

cat("\nLectura: el reparto entre manana y tarde es parejo (",
    pct(tabla_por_turno$proporcion[1]), " y ", pct(tabla_por_turno$proporcion[2]),
    "),\n", sep = "")
cat("y la proporcion de multados casi no cambia entre dias (",
    pct(min(tabla_por_dia$prop_multados)), " a ",
    pct(max(tabla_por_dia$prop_multados)), "): no hay un dia especialmente problematico.\n",
    sep = "")
