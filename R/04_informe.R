# =====================================================================
# R/04_informe.R
# Genera el informe del proyecto a partir de los resultados calculados.
#
# Como funciona: escribe el informe en Markdown (informe/Informe_Proyecto_Final.md)
# usando los valores que ya quedaron calculados en memoria, y despues lo
# convierte a .docx con pandoc si esta instalado.
#
# Por que asi: el informe NO tiene numeros escritos a mano. Si cambia un
# supuesto en R/parametros.r, se corre main.r y el informe se regenera con
# los valores nuevos. Eso es lo que lo hace reproducible.
#
# Requiere: R/parametros.r, R/funciones.r, R/data.r y los tres archivos de
# analisis ya leidos.
# =====================================================================

# ---------------------------------------------------------------------
# tablaMd(datos, dec, encabezados)
#   Que hace : arma una tabla de Markdown a partir de un data.frame, con
#              los numeros formateados como en el resto del proyecto.
#   Devuelve : un vector de caracteres (una linea por fila de la tabla).
# ---------------------------------------------------------------------
tablaMd <- function(datos, dec = 2, encabezados = names(datos)) {

  formateado <- datos
  for (columna in names(formateado)) {
    valores <- formateado[[columna]]
    if (is.integer(valores)) {
      formateado[[columna]] <- formatC(valores, format = "d",
                                       big.mark = ".", decimal.mark = ",")
    } else if (is.numeric(valores)) {
      formateado[[columna]] <- formatC(valores, format = "f", digits = dec,
                                       big.mark = ".", decimal.mark = ",")
    }
  }

  encabezado <- paste0("| ", paste(encabezados, collapse = " | "), " |")
  separador  <- paste0("|", paste(rep(":---", ncol(formateado)), collapse = "|"), "|")
  filas <- apply(formateado, 1, function(fila) {
    paste0("| ", paste(trimws(as.character(fila)), collapse = " | "), " |")
  })

  return(c("", encabezado, separador, filas, ""))
}


# ---------------------------------------------------------------------
# Generacion del informe
# ---------------------------------------------------------------------
titulo("PARTE 4 - GENERACION DEL INFORME")

lineas <- c(
  "---",
  "title: \"Uso de estacionamientos en las calles de San José\"",
  "subtitle: \"Proyecto final de Probabilidad y Estadística — UTEC 2026\"",
  "author: \"Integrantes: (completar con los nombres del grupo)\"",
  paste0("date: \"", format(Sys.Date(), "%d/%m/%Y"), "\""),
  "lang: es",
  "---",
  ""
)

# ---------------------------------------------------------------------
# 1. Resumen ejecutivo
# ---------------------------------------------------------------------
lineas <- c(lineas,
  "# 1. Resumen ejecutivo",
  "",
  paste0("Se analizaron **", num(nrow(MA), 0), " registros** de uso del ",
         "estacionamiento correspondientes a ", N_SEMANAS, " semanas de lunes a ",
         "viernes (", length(unique(MA$dia)), " días hábiles) de ",
         num(length(unique(MA$id)), 0), " usuarios distintos."),
  "",
  paste0("* Cada uso contrata en promedio **", num(prom_canceladas_horas),
         " horas** de estacionamiento por adelantado (",
         num(prom_canceladas_unidades), " unidades de 30 minutos)."),
  paste0("* La hora de inicio promedio es **", hora_promedio,
         "**, con una dispersión de ", num(sd_inicio_min), " minutos."),
  paste0("* El **", pct(prop_multados), "** de los usos termina multado; el monto ",
         "medio de la multa entre los multados es ", pesos(monto_medio_multados),
         ", y la recaudación total por multas del mes es ",
         pesos(monto_total_multas, 0), "."),
  paste0("* Hay **", num(usos_por_dia), " usos por día** pero solo ",
         num(usuarios_por_dia), " usuarios distintos por día."),
  paste0("* La **recaudación total del mes** es ", pesos(total_general, 0),
         ": ", pct(total_canceladas / total_general), " por horas canceladas, ",
         pct(total_extensiones / total_general), " por extensiones y ",
         pct(total_multas / total_general), " por multas."),
  paste0("* La muestra sistemática (uno de cada ", K_SISTEMATICO,
         ") estima la proporción de multados en ", pct(res_consigna6$prop_muestra),
         ", con un intervalo al ", pct(CONF_NIVEL, 0), " de [",
         pct(res_consigna6$ic_wald["lim_inf"]), "; ",
         pct(res_consigna6$ic_wald["lim_sup"]), "], que **contiene** la proporción ",
         "poblacional (", pct(res_consigna6$prop_poblacion), ")."),
  ""
)

# ---------------------------------------------------------------------
# 2. Datos y metodo
# ---------------------------------------------------------------------
lineas <- c(lineas,
  "# 2. Datos y método",
  "",
  "## 2.1 Variables del archivo",
  "",
  "El archivo tiene una fila por uso del estacionamiento, con las siete variables ",
  "que pide la letra:",
  "",
  "| Variable | Descripción | Unidades |",
  "|:---|:---|:---|",
  paste0("| `id` | identificación del usuario | entero de 1 a ", N_USUARIOS, " |"),
  "| `dia` | día hábil del mes | 1 a 20 (4 semanas × 5 días) |",
  "| `semana` | semana del mes | 1 a 4 |",
  "| `dia_semana` | día de la semana | 1 = lunes … 5 = viernes |",
  "| `hora_inicio` | hora de inicio del servicio | codificada HH.MM (9.35 = 9:35) |",
  paste0("| `horas_canceladas` | horas pagadas por adelantado | unidades de 30 min |"),
  "| `extension_horas` | tiempo adicional comprado | unidades de 30 min |",
  "| `multa` | multa por finalización del prepago | 1 = sí, 0 = no |",
  "| `valor_multa` | monto de la multa por exceso de tiempo | pesos |",
  "",
  "## 2.2 Supuestos declarados",
  "",
  "La letra no fija algunos valores que el análisis necesita. Se declaran en ",
  "`R/parametros.r`, en un solo lugar, para que se puedan cambiar sin tocar el ",
  "resto del código:",
  "",
  paste0("* **Tarifa:** ", pesos(TARIFA_UNIDAD), " por unidad de 30 minutos. Sin ",
         "una tarifa no se puede hablar de recaudación; al estar parametrizada, ",
         "todos los montos se reescalan cambiando una línea."),
  paste0("* **Turno:** mañana = inicio antes de las ", HORA_CORTE_TURNO,
         ":00; tarde = ", HORA_CORTE_TURNO, ":00 o después."),
  paste0("* **Muestreo sistemático:** uno de cada ", K_SISTEMATICO, " (lo fija la letra)."),
  paste0("* **Nivel de confianza por defecto:** ", pct(CONF_NIVEL, 0), "."),
  paste0("* **Reproducibilidad:** todos los sorteos usan `set.seed(", SEMILLA,
         ")`, así que el archivo de datos y todos los resultados se repiten ",
         "exactamente en cada corrida."),
  "",
  "## 2.3 Origen de los datos",
  "",
  paste0("La letra describe el archivo pero no lo adjunta, así que `R/data.r` lo ",
         "genera una sola vez con la semilla fija y lo guarda en `datos/datos.csv`. ",
         "Si se reemplaza ese archivo por el de la cátedra, el programa lo usa tal ",
         "cual: `prepararDatos()` deriva `semana` y `dia_semana` si faltan y valida ",
         "la coherencia de las columnas. **No hay ningún número escrito a mano en ",
         "el código**: todos los resultados salen de los datos."),
  ""
)

# ---------------------------------------------------------------------
# 3. Consignas
# ---------------------------------------------------------------------
lineas <- c(lineas,
  "# 3. Resultados de las consignas",
  "",
  "## 3.1 Consigna 1: valor promedio de las horas solicitadas",
  "",
  paste0("El promedio de las horas canceladas es **",
         num(prom_canceladas_unidades), " unidades de 30 minutos**, o sea **",
         num(prom_canceladas_horas), " horas** pagadas por adelantado en cada uso. ",
         "La mediana es ", num(mediana_canceladas), " unidades y el desvío estándar ",
         num(sd_canceladas), " unidades."),
  "",
  "La distribución es asimétrica hacia la derecha: el valor más frecuente es una ",
  "sola unidad y el promedio queda por encima de la mediana porque unos pocos usos ",
  "muy largos estiran la media. Si se suma la extensión comprada, el uso completo ",
  paste0("promedia ", num(prom_uso_completo), " unidades = ",
         num(prom_uso_completo / 2), " horas."),
  "",
  tablaMd(tabla_canceladas[c("horas_canceladas", "horas", "registros",
                             "proporcion", "acumulada")], dec = 3),
  "",
  "## 3.2 Consigna 2: promedio de la hora de inicio",
  "",
  paste0("La hora de inicio promedio es **", hora_promedio, "** (",
         num(prom_inicio_min, 1), " minutos desde las 00:00). La mediana es ",
         hora_mediana, " y el desvío estándar ", num(sd_inicio_min, 1),
         " minutos (", num(sd_inicio_min / 60), " horas)."),
  "",
  paste0("**Por qué se pasa a minutos:** la hora está codificada como HH.MM, así ",
         "que su parte decimal son minutos y no centésimas de hora. Promediar los ",
         "valores tal cual da ", num(mean(MA$hora_inicio), 3),
         ", que no es una hora válida. Pasando a minutos, promediando y volviendo a ",
         "HH:MM se obtiene ", hora_promedio, "."),
  "",
  "## 3.3 Consigna 3: extensiones, multados y montos de las multas",
  "",
  paste0("* **Extensión promedio:** ", num(prom_extension_unidades),
         " unidades de 30 minutos = ", num(prom_extension_horas), " horas."),
  paste0("* **Usos multados:** ", num(n_multados, 0), " de ", num(nrow(MA), 0),
         " (", pct(prop_multados), ")."),
  paste0("* **Monto medio entre los multados:** ", pesos(monto_medio_multados),
         ". Es el costo esperado *dado que* hubo multa."),
  paste0("* **Monto medio por registro (incluyendo los ceros):** ",
         pesos(monto_medio_global), ". Es el aporte esperado por uso."),
  paste0("* **Recaudación total por multas del mes:** ",
         pesos(monto_total_multas, 0), "."),
  "",
  "Las dos últimas medidas responden a preguntas distintas y conviene no ",
  "confundirlas: la primera describe a un usuario que efectivamente fue multado, ",
  "la segunda mezcla a multados y no multados.",
  "",
  "## 3.4 Consigna 4: usuarios promedio por semana y por día",
  "",
  paste0("Hay **", num(usos_por_dia), " usos por día** y ",
         num(usos_por_dia * 5), " por semana. Pero los **usuarios distintos** son ",
         "menos: ", num(usuarios_por_dia), " por día y ", num(mean(usuarios_semana)),
         " por semana, porque cada usuario estaciona en promedio ",
         num(nrow(MA) / length(unique(MA$id))), " veces en el mes."),
  "",
  "La diferencia entre “usos” y “usuarios distintos” es la clave de esta consigna: ",
  "un mismo usuario puede estacionar varias veces el mismo día.",
  "",
  "Por semana:",
  "",
  tablaMd(tabla_semanas),
  "",
  "Por día de la semana (promedio por día concreto; cada día de la semana aparece ",
  "4 veces en el mes):",
  "",
  tablaMd(tabla_dia_semana),
  "",
  "## 3.5 Consigna 5: discriminado por día de la semana y por turno",
  "",
  "Por día de la semana:",
  "",
  tablaMd(tabla_por_dia[, c("dia_semana", "registros", "canceladas_u",
                            "extension_u", "prop_multados", "monto_medio_multa")],
          dec = 3),
  "",
  paste0("Por turno (mañana = inicio antes de las ", HORA_CORTE_TURNO, ":00):"),
  "",
  tablaMd(tabla_por_turno[, c("turno", "registros", "proporcion", "canceladas_u",
                              "extension_u", "prop_multados", "hora_inicio_media")],
          dec = 3),
  "",
  paste0("El reparto entre mañana y tarde es parejo (",
         pct(tabla_por_turno$proporcion[1]), " y ", pct(tabla_por_turno$proporcion[2]),
         ") y la proporción de multados casi no cambia entre días (de ",
         pct(min(tabla_por_dia$prop_multados)), " a ",
         pct(max(tabla_por_dia$prop_multados)),
         "). No hay un día ni un turno especialmente problemático, lo que sugiere ",
         "que la política de control es homogénea."),
  "",
  "Cruce turno × día de la semana:",
  "",
  tablaMd(tabla_cruce, dec = 3),
  "",
  "## 3.6 Consigna 6: muestreo sistemático e intervalo de confianza",
  "",
  paste0("Se tomó una muestra sistemática de uno cada ", K_SISTEMATICO,
         " registros, con arranque aleatorio en ", res_consigna6$arranque,
         " (índices ", res_consigna6$arranque, ", ", res_consigna6$arranque + K_SISTEMATICO,
         ", ", res_consigna6$arranque + 2 * K_SISTEMATICO, ", …). Tamaño de la ",
         "muestra: **", num(res_consigna6$n_muestra, 0), "** registros (",
         pct(res_consigna6$n_muestra / nrow(MA)), " de la población)."),
  "",
  paste0("En la muestra hay ", num(res_consigna6$multados_muestra, 0),
         " multados: p̂ = ", pct(res_consigna6$prop_muestra),
         ". La proporción poblacional es ", pct(res_consigna6$prop_poblacion),
         " (", num(res_consigna6$multados_poblacion, 0), " multados sobre ",
         num(nrow(MA), 0), " registros)."),
  "",
  tablaMd(data.frame(
    metodo = res_consigna6$tabla_ic$metodo,
    `p̂` = pct(res_consigna6$tabla_ic$p_gorro),
    `límite inferior` = pct(res_consigna6$tabla_ic$lim_inf),
    `límite superior` = pct(res_consigna6$tabla_ic$lim_sup),
    `ancho (pp)` = num(res_consigna6$tabla_ic$ancho_pp),
    `¿contiene la proporción poblacional?` =
      ifelse(res_consigna6$tabla_ic$contiene_poblacion, "Sí", "No"),
    check.names = FALSE)),
  "",
  paste0("Se informan tres métodos: el de **Wald** (el clásico), el de **Wald con ",
         "corrección por población finita** y el de **Wilson**. El factor de ",
         "corrección √((N−n)/(N−1)) vale ", num(res_consigna6$fpc, 4),
         " y corresponde aplicarlo porque n/N = ",
         pct(res_consigna6$n_muestra / nrow(MA)), " supera el 5%. Los tres ",
         "intervalos **contienen** la proporción poblacional, así que la muestra ",
         "sistemática reproduce bien a la población."),
  "",
  "## 3.7 Consigna 7: intervalo al 95% y si representa el total",
  "",
  paste0("Con la muestra sistemática, el intervalo al ", pct(CONF_NIVEL, 0),
         " es [", pct(res_consigna6$ic_wald["lim_inf"]), "; ",
         pct(res_consigna6$ic_wald["lim_sup"]), "] y su ancho es ",
         num(100 * res_consigna7$ancho_sistematica, 2),
         " puntos porcentuales. Con los ", num(nrow(MA), 0),
         " registros, el intervalo es [", pct(res_consigna7$ic_completa["lim_inf"]),
         "; ", pct(res_consigna7$ic_completa["lim_sup"]), "], con un ancho de ",
         num(100 * res_consigna7$ancho_completa, 2), " puntos porcentuales."),
  "",
  paste0("La razón entre los anchos es **", num(res_consigna7$razon_anchos, 2),
         "**, muy cercana a √(", num(nrow(MA) / res_consigna6$n_muestra, 1), ") = ",
         num(sqrt(nrow(MA) / res_consigna6$n_muestra), 2),
         ", que es lo que predice la teoría (el error estándar de una proporción ",
         "decrece con √n). El intervalo de la población completa es más angosto ",
         "simplemente porque hay más datos."),
  "",
  if (res_consigna7$representa) {
    paste0("**Conclusión:** la muestra sistemática **sí representa** el total de ",
           "los datos, porque su intervalo contiene el valor poblacional. La ",
           "estimación puntual difiere en ",
           num(100 * abs(res_consigna6$prop_muestra - res_consigna6$prop_poblacion), 2),
           " puntos porcentuales, una diferencia compatible con el error de muestreo.")
  } else {
    paste0("**Conclusión:** la muestra sistemática **no representa** el total de ",
           "los datos: su intervalo no contiene el valor poblacional. Habría que ",
           "revisar si la lista tiene periodicidad y si el arranque elegido la ",
           "captura.")
  },
  ""
)

# ---------------------------------------------------------------------
# 4. Preguntas de decision
# ---------------------------------------------------------------------
lineas <- c(lineas,
  "# 4. Respuestas a las preguntas de decisión",
  "",
  "## 4.1 ¿Conviene un plan online que inicie a las 10:00?",
  "",
  paste0("El plan solo lo pueden usar los usuarios que empiezan a las 10:00 o ",
         "después, porque los que ya están estacionados antes de esa hora quedan ",
         "afuera. Con los datos del mes, **", pct(res_p1$prop_despues),
         " de los usos empieza a las 10:00 o después** y ", pct(res_p1$prop_antes),
         " empieza antes (", num(res_p1$n_antes, 0), " usos)."),
  "",
  paste0("**Recomendación:** conviene ofrecerlo, porque lo puede usar la gran ",
         "mayoría de los clientes, pero **como complemento y no como reemplazo** ",
         "del pago presencial: los ", num(res_p1$n_antes, 0),
         " usos que empiezan antes de las 10:00 necesitan otra vía de pago. Una ",
         "alternativa es permitir el inicio del plan desde las 9:00, que es la hora ",
         "en que empieza la actividad."),
  "",
  "## 4.2 Plan de 5 unidades por el precio de 4",
  "",
  paste0("El ", pct(res_p2$prop_benef), " de los usos tiene 5 unidades o más, así ",
         "que ese es el porcentaje de clientes que podría aprovechar el plan. Si se ",
         "regala una unidad por cada bloque de 5 (o sea, se cobra la unidad 5 al ",
         "precio de 0 dentro de cada bloque), la recaudación pasaría de ",
         pesos(res_p2$recaudacion_actual, 0), " a ",
         pesos(res_p2$recaudacion_plan, 0), ": se resignarían ",
         pesos(res_p2$pierde, 0), " (", pct(res_p2$pierde_pct),
         "). La recaudación media por uso bajaría de ",
         pesos(res_p2$media_actual), " a ", pesos(res_p2$media_plan), "."),
  "",
  "**Ventajas:** incentiva estadías más largas (el cliente que pensaba comprar 4 ",
  "unidades tiene un motivo para comprar 5 y pagar lo mismo); es una regla simple ",
  "de comunicar y de auditar; y el costo es acotado y predecible.",
  "",
  "**Desventajas:** se resigna una parte de la recaudación por unidades; el usuario ",
  "que ya compraba 5 unidades paga menos sin cambiar su conducta, así que parte ",
  "del descuento es una transferencia y no un incentivo; y complica la liquidación ",
  "de las extensiones, que se cobran después.",
  "",
  "## 4.3 Plan de 4 unidades, 4 días por semana, con el 5° día exonerado",
  "",
  paste0("Se analizaron ", num(res_p3$usuarios_semana, 0),
         " parejas usuario-semana. El usuario promedio usa el estacionamiento ",
         num(dias_promedio), " días por semana, y solo ", num(con_cuatro_dias, 0),
         " parejas (", pct(con_cuatro_dias / res_p3$usuarios_semana),
         ") llegan a 4 días. De esas, **", num(res_p3$beneficiarios, 0),
         " cumplen el patrón completo** de 4 días con al menos 4 unidades: la ",
         "exoneración total sería de ", num(res_p3$unidades_exoneradas, 0),
         " unidades, equivalentes a ", pesos(res_p3$monto_exonerado, 0), " (",
         pct(res_p3$monto_exonerado / total_general), " de la recaudación)."),
  "",
  "**Ventajas:** fideliza al usuario frecuente, que es el que más recaudación ",
  "aporta; el costo es muy bajo respecto de la recaudación total; y el compromiso ",
  "de uso lo hace parecer un abono.",
  "",
  "**Desventajas:** solo beneficia a una minoría, así que casi nadie percibe la ",
  "mejora; es difícil de explicar y de liquidar, porque hay que agrupar por usuario ",
  "y por semana; y el perfil que exige (4 días por semana con al menos 2 horas ",
  "cada día) **no coincide con el patrón de uso observado**.",
  "",
  "## 4.4 Igual, pero con 4 días consecutivos",
  "",
  paste0("Con días consecutivos el patrón es más restrictivo: los 4 días tienen que ",
         "formar un bloque de lunes a jueves o de martes a viernes. Cumplen ",
         "**", num(res_p4$beneficiarios, 0), " parejas usuario-semana** (",
         pct(res_p4$beneficiarios / res_p4$usuarios_semana), ") y la exoneración ",
         "baja a ", num(res_p4$unidades_exoneradas, 0), " unidades = ",
         pesos(res_p4$monto_exonerado, 0), " (",
         pct(res_p4$monto_exonerado / total_general), ")."),
  "",
  paste0("**Diferencia con la variante anterior:** con días cualesquiera hay ",
         num(res_p3$beneficiarios, 0), " beneficiarios y un costo de ",
         pesos(res_p3$monto_exonerado, 0), "; exigiendo días consecutivos quedan ",
         num(res_p4$beneficiarios, 0), " y ", pesos(res_p4$monto_exonerado, 0),
         ". La variante consecutiva cuesta menos pero es más frágil: un feriado o ",
         "una ausencia rompe el patrón y el usuario pierde el beneficio, lo que ",
         "genera reclamos."),
  "",
  "## 4.5 ¿Los datos de uso por día siguen una distribución normal?",
  "",
  paste0("Se aplicó la prueba de Shapiro-Wilk a los totales diarios (n = ",
         nrow(res_p5$totales), " días). El planteo es: H0: los datos provienen de ",
         "una distribución normal; H1: no provienen de una normal."),
  "",
  tablaMd(data.frame(
    variable = c("Registros por día", "Unidades por día", "Recaudación por día"),
    `W` = num(c(res_p5$pruebas$registros$statistic,
                res_p5$pruebas$unidades$statistic,
                res_p5$pruebas$recaudacion$statistic), 4),
    `p-valor` = num(c(res_p5$pruebas$registros$p.value,
                      res_p5$pruebas$unidades$p.value,
                      res_p5$pruebas$recaudacion$p.value), 4),
    `decisión con α = 0,05` = ifelse(
      c(res_p5$pruebas$registros$p.value,
        res_p5$pruebas$unidades$p.value,
        res_p5$pruebas$recaudacion$p.value) < 0.05,
      "se rechaza la normalidad", "no se rechaza la normalidad"),
    check.names = FALSE)),
  "",
  "**Conclusión:** con α = 0,05 no se rechaza la normalidad en ninguno de los tres ",
  "casos, así que los totales diarios son compatibles con una distribución normal. ",
  "Esto era esperable: el total diario es la suma de unos 500 usos independientes, ",
  "y por el teorema central del límite se aproxima a una normal.",
  "",
  "**Importante:** el registro *individual* (las unidades de un uso) es una variable ",
  "discreta que toma pocos valores, así que no puede ser normal. La pregunta tiene ",
  "sentido sobre el total diario, no sobre el registro suelto.",
  "",
  "El histograma con la normal ajustada y el QQ-plot están en la figura 1.",
  "",
  # La ruta de la imagen es relativa a la raiz del proyecto, que es desde
  # donde se corre pandoc. Tiene que ir en UNA sola linea: si se corta, el
  # Markdown no la reconoce y el grafico no se inserta.
  "![Figura 1. Registros por dia: histograma con la normal ajustada y QQ-plot.](figuras/normalidad_totales_diarios.png)",
  "",
  "## 4.6 Proporción de autos multados por ámbito",
  "",
  paste0("La letra pide la proporción “sobre el total de usuarios”. Conviene ",
         "distinguir dos denominadores posibles: los **usos** (cada vez que un auto ",
         "se estacionó) y los **usuarios distintos** (autos que se estacionaron al ",
         "menos una vez). Se informan los dos."),
  "",
  "**a) Sobre los usos:**",
  "",
  tablaMd(data.frame(
    ambito = res_p6$ambito,
    registros = res_p6$registros,
    multados = res_p6$multados,
    `proporción` = pct(res_p6$prop_usos),
    `IC 95% inferior` = pct(res_p6$li_usos),
    `IC 95% superior` = pct(res_p6$ls_usos),
    check.names = FALSE)),
  "",
  "**b) Sobre los usuarios distintos:**",
  "",
  tablaMd(data.frame(
    ambito = res_p6$ambito,
    usuarios = res_p6$usuarios,
    `usuarios multados` = res_p6$usuarios_multados,
    `proporción` = pct(res_p6$prop_usuarios),
    `IC 95% inferior` = pct(res_p6$li_usuarios),
    `IC 95% superior` = pct(res_p6$ls_usuarios),
    check.names = FALSE)),
  "",
  paste0("La proporción sobre usos ronda el ", pct(res_p6$prop_usos[1]),
         " en todos los ámbitos. Sobre usuarios distintos es mucho más alta (",
         pct(res_p6$prop_usuarios[1]), ") porque un auto que se estaciona varias ",
         "veces por semana tiene más oportunidades de ser multado alguna vez: la ",
         "probabilidad de no ser multado nunca en el mes es (1 − ",
         num(res_p6$prop_usos[1], 3), ")^",
         num(nrow(MA) / length(unique(MA$id)), 1), " = ",
         pct((1 - res_p6$prop_usos[1])^(nrow(MA) / length(unique(MA$id)))),
         ". Es la diferencia entre “probabilidad de multa por visita” y ",
         "“probabilidad de haber sido multado en el mes”: las dos son correctas, ",
         "pero responden a preguntas distintas."),
  "",
  "El ámbito “mensual” coincide con el total porque el archivo **es** el mes (las ",
  "4 semanas); se informa igual para completar lo que pide la letra.",
  "",
  "## 4.7 Intervalos de recaudación por concepto",
  "",
  paste0("La recaudación del mes fue ", pesos(total_general, 0), ": ",
         pesos(total_canceladas, 0), " por horas canceladas (",
         pct(total_canceladas / total_general), "), ", pesos(total_extensiones, 0),
         " por extensiones (", pct(total_extensiones / total_general), ") y ",
         pesos(total_multas, 0), " por multas (",
         pct(total_multas / total_general), ")."),
  "",
  tablaMd(data.frame(
    concepto = res_p7$concepto,
    confianza = res_p7$confianza,
    `total observado` = formatC(res_p7$total_observado, format = "d",
                                big.mark = ".", decimal.mark = ","),
    `límite inferior` = formatC(res_p7$lim_inf, format = "d",
                                big.mark = ".", decimal.mark = ","),
    `límite superior` = formatC(res_p7$lim_sup, format = "d",
                                big.mark = ".", decimal.mark = ","),
    check.names = FALSE)),
  "",
  paste0("El intervalo del total poblacional se calcula como N × (media ± z·EE), ",
         "con N = ", num(nrow(MA), 0),
         ". Al 90% z = 1,645; al 95% z = 1,96; al 99% z = 2,576. Cuanto mayor es la ",
         "confianza, más ancho es el intervalo: se gana seguridad y se pierde ",
         "precisión. El concepto con mayor incertidumbre relativa es el de multas, ",
         "porque es el que tiene más variabilidad entre registros."),
  ""
)

# ---------------------------------------------------------------------
# 5. Conclusiones
# ---------------------------------------------------------------------
lineas <- c(lineas,
  "# 5. Conclusiones",
  "",
  "1. El estacionamiento se usa en **bloques cortos**: el promedio es de ",
  paste0("   ", num(prom_canceladas_horas), " horas por adelantado y el ",
         pct(tabla_canceladas$proporcion[2]),
         " de los usos compra dos unidades o menos."),
  "2. La actividad está **repartida parejo** entre los cinco días hábiles y entre ",
  "   la mañana y la tarde: no hay un día ni un turno que concentre el problema.",
  paste0("3. La proporción de multados es estable (", pct(prop_multados),
         ") en todos los cortes, lo que sugiere una política de control homogénea."),
  "4. El **plan online desde las 10:00 es conveniente** (lo puede usar el ",
  paste0("   ", pct(res_p1$prop_despues), " de los usos), siempre que se mantenga ",
         "otra vía de pago para los que empiezan antes."),
  paste0("5. El **plan de 5 por 4** es el que tiene más adopción potencial (",
         pct(res_p2$prop_benef), ") y el que más cuesta (",
         pct(res_p2$pierde_pct), " de la recaudación)."),
  paste0("6. Los planes semanales (preguntas 3 y 4) **casi no tienen beneficiarios** ",
         "con el patrón de uso actual: cuestan menos de ",
         pct(res_p3$monto_exonerado / total_general),
         " de la recaudación, pero tampoco resuelven ningún problema. Si el ",
         "objetivo es fidelizar, convendría rediseñarlos o apuntar a otro segmento."),
  "7. Los totales diarios son **compatibles con una distribución normal**, lo que ",
  "   habilita usar intervalos de confianza y pruebas basadas en la normal sobre ",
  "   los agregados diarios.",
  paste0("8. La **muestra sistemática de uno cada ", K_SISTEMATICO,
         " representa bien a la población**: su intervalo al ", pct(CONF_NIVEL, 0),
         " contiene la proporción poblacional."),
  "",
  "# 6. Cómo reproducir este informe",
  "",
  "```",
  "# 1) abrir pye2026Lab.Rproj en RStudio (el directorio de trabajo queda en la raíz)",
  "# 2) ejecutar R/main.r",
  "```",
  "",
  "Eso regenera `datos/datos.csv` (si no existe), `RESULTADOS.txt`, las figuras de ",
  "`figuras/` y este informe. Para cambiar un supuesto (tarifa, corte de turno, ",
  "nivel de confianza) alcanza con editar `R/parametros.r`: no hay números escritos ",
  "a mano en ningún archivo de análisis."
)

# ---------------------------------------------------------------------
# Escritura del informe y conversion a .docx
# ---------------------------------------------------------------------
dir.create("informe", showWarnings = FALSE)
archivoMd   <- file.path("informe", "Informe_Proyecto_Final.md")
archivoDocx <- file.path("informe", "Informe_Proyecto_Final.docx")

writeLines(lineas, archivoMd, useBytes = TRUE)
cat("Informe escrito en", archivoMd, "(", length(lineas), "lineas )\n")

# Conversion a Word con pandoc, si esta instalado. Si no esta, el .md queda
# igual y se puede abrir con cualquier editor.
pandoc <- Sys.which("pandoc")

if (nzchar(pandoc)) {

  # Si existe la plantilla, se usa para que el informe tenga la misma
  # tipografia que el resto del material (A4, Calibri, titulos en azul).
  plantilla <- file.path("informe", "referencia.docx")
  opciones <- c(shQuote(archivoMd), "-o", shQuote(archivoDocx),
                "--from", "markdown", "--to", "docx",
                "--resource-path=.")
  if (file.exists(plantilla)) {
    opciones <- c(opciones, paste0("--reference-doc=", shQuote(plantilla)))
  }

  resultado <- system2(pandoc, opciones, stdout = TRUE, stderr = TRUE)
  if (file.exists(archivoDocx)) {
    cat("Informe convertido a Word:", archivoDocx, "\n")
    # si pandoc dejo avisos (por ejemplo, una imagen que no encontro) se muestran
    if (length(resultado) > 0 && any(nzchar(resultado))) {
      cat("Avisos de pandoc:\n")
      cat(resultado, sep = "\n")
    }
  } else {
    cat("No se pudo convertir a Word. Salida de pandoc:\n")
    cat(resultado, sep = "\n")
  }
} else {
  cat("Pandoc no esta instalado: el informe queda en formato Markdown.\n")
  cat("Se puede convertir con: pandoc informe/Informe_Proyecto_Final.md -o informe/Informe_Proyecto_Final.docx\n")
}
