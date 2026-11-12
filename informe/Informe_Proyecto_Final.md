---
title: "Uso de estacionamientos en las calles de San José"
subtitle: "Proyecto final de Probabilidad y Estadística — UTEC 2026"
author: "Integrantes: (completar con los nombres del grupo)"
date: "09/11/2026"
lang: es
---

# 1. Resumen ejecutivo

Se analizaron **10.000 registros** de uso del estacionamiento correspondientes a 4 semanas de lunes a viernes (20 días hábiles) de 1.200 usuarios distintos.

* Cada uso contrata en promedio **1,40 horas** de estacionamiento por adelantado (2,81 unidades de 30 minutos).
* La hora de inicio promedio es **13:00**, con una dispersión de 137,80 minutos.
* El **35,62%** de los usos termina multado; el monto medio de la multa entre los multados es $ 159,63, y la recaudación total por multas del mes es $ 568.600.
* Hay **500,00 usos por día** pero solo 408,90 usuarios distintos por día.
* La **recaudación total del mes** es $ 1.690.125: 41,53% por horas canceladas, 24,83% por extensiones y 33,64% por multas.
* La muestra sistemática (uno de cada 10) estima la proporción de multados en 36,50%, con un intervalo al 95% de [33,52%; 39,48%], que **contiene** la proporción poblacional (35,62%).

# 2. Datos y método

## 2.1 Variables del archivo

El archivo tiene una fila por uso del estacionamiento, con las siete variables 
que pide la letra:

| Variable | Descripción | Unidades |
|:---|:---|:---|
| `id` | identificación del usuario | entero de 1 a 1200 |
| `dia` | día hábil del mes | 1 a 20 (4 semanas × 5 días) |
| `semana` | semana del mes | 1 a 4 |
| `dia_semana` | día de la semana | 1 = lunes … 5 = viernes |
| `hora_inicio` | hora de inicio del servicio | codificada HH.MM (9.35 = 9:35) |
| `horas_canceladas` | horas pagadas por adelantado | unidades de 30 min |
| `extension_horas` | tiempo adicional comprado | unidades de 30 min |
| `multa` | multa por finalización del prepago | 1 = sí, 0 = no |
| `valor_multa` | monto de la multa por exceso de tiempo | pesos |

## 2.2 Supuestos declarados

La letra no fija algunos valores que el análisis necesita. Se declaran en 
`R/parametros.r`, en un solo lugar, para que se puedan cambiar sin tocar el 
resto del código:

* **Tarifa:** $ 25,00 por unidad de 30 minutos. Sin una tarifa no se puede hablar de recaudación; al estar parametrizada, todos los montos se reescalan cambiando una línea.
* **Turno:** mañana = inicio antes de las 13:00; tarde = 13:00 o después.
* **Muestreo sistemático:** uno de cada 10 (lo fija la letra).
* **Nivel de confianza por defecto:** 95%.
* **Reproducibilidad:** todos los sorteos usan `set.seed(2026)`, así que el archivo de datos y todos los resultados se repiten exactamente en cada corrida.

## 2.3 Origen de los datos

La letra describe el archivo pero no lo adjunta, así que `R/data.r` lo genera una sola vez con la semilla fija y lo guarda en `datos/datos.csv`. Si se reemplaza ese archivo por el de la cátedra, el programa lo usa tal cual: `prepararDatos()` deriva `semana` y `dia_semana` si faltan y valida la coherencia de las columnas. **No hay ningún número escrito a mano en el código**: todos los resultados salen de los datos.

# 3. Resultados de las consignas

## 3.1 Consigna 1: valor promedio de las horas solicitadas

El promedio de las horas canceladas es **2,81 unidades de 30 minutos**, o sea **1,40 horas** pagadas por adelantado en cada uso. La mediana es 2,00 unidades y el desvío estándar 1,68 unidades.

La distribución es asimétrica hacia la derecha: el valor más frecuente es una 
sola unidad y el promedio queda por encima de la mediana porque unos pocos usos 
muy largos estiran la media. Si se suma la extensión comprada, el uso completo 
promedia 4,49 unidades = 2,24 horas.


| horas_canceladas | horas | registros | proporcion | acumulada |
|:---|:---|:---|:---|:---|
| 1 | 0,500 | 2.729 | 0,273 | 0,273 |
| 2 | 1,000 | 2.434 | 0,243 | 0,516 |
| 3 | 1,500 | 1.783 | 0,178 | 0,695 |
| 4 | 2,000 | 1.319 | 0,132 | 0,827 |
| 5 | 2,500 | 938 | 0,094 | 0,920 |
| 6 | 3,000 | 507 | 0,051 | 0,971 |
| 7 | 3,500 | 196 | 0,020 | 0,991 |
| 8 | 4,000 | 94 | 0,009 | 1,000 |


## 3.2 Consigna 2: promedio de la hora de inicio

La hora de inicio promedio es **13:00** (779,6 minutos desde las 00:00). La mediana es 13:00 y el desvío estándar 137,8 minutos (2,30 horas).

**Por qué se pasa a minutos:** la hora está codificada como HH.MM, así que su parte decimal son minutos y no centésimas de hora. Promediar los valores tal cual da 12,798, que no es una hora válida. Pasando a minutos, promediando y volviendo a HH:MM se obtiene 13:00.

## 3.3 Consigna 3: extensiones, multados y montos de las multas

* **Extensión promedio:** 1,68 unidades de 30 minutos = 0,84 horas.
* **Usos multados:** 3.562 de 10.000 (35,62%).
* **Monto medio entre los multados:** $ 159,63. Es el costo esperado *dado que* hubo multa.
* **Monto medio por registro (incluyendo los ceros):** $ 56,86. Es el aporte esperado por uso.
* **Recaudación total por multas del mes:** $ 568.600.

Las dos últimas medidas responden a preguntas distintas y conviene no 
confundirlas: la primera describe a un usuario que efectivamente fue multado, 
la segunda mezcla a multados y no multados.

## 3.4 Consigna 4: usuarios promedio por semana y por día

Hay **500,00 usos por día** y 2.500,00 por semana. Pero los **usuarios distintos** son menos: 408,90 por día y 1.048,75 por semana, porque cada usuario estaciona en promedio 8,33 veces en el mes.

La diferencia entre “usos” y “usuarios distintos” es la clave de esta consigna: 
un mismo usuario puede estacionar varias veces el mismo día.

Por semana:


| semana | registros | usuarios_distintos | usos_por_dia | usuarios_por_dia |
|:---|:---|:---|:---|:---|
| 1 | 2.462 | 1.050 | 492,40 | 403,80 |
| 2 | 2.573 | 1.062 | 514,60 | 418,20 |
| 3 | 2.493 | 1.040 | 498,60 | 407,20 |
| 4 | 2.472 | 1.043 | 494,40 | 406,40 |


Por día de la semana (promedio por día concreto; cada día de la semana aparece 
4 veces en el mes):


| dia_semana | dias | registros | usos_por_dia | usuarios_por_dia |
|:---|:---|:---|:---|:---|
| Lunes | 4 | 1.991 | 497,75 | 401,50 |
| Martes | 4 | 2.063 | 515,75 | 418,75 |
| Miercoles | 4 | 1.995 | 498,75 | 411,50 |
| Jueves | 4 | 1.987 | 496,75 | 409,50 |
| Viernes | 4 | 1.964 | 491,00 | 403,25 |


## 3.5 Consigna 5: discriminado por día de la semana y por turno

Por día de la semana:


| dia_semana | registros | canceladas_u | extension_u | prop_multados | monto_medio_multa |
|:---|:---|:---|:---|:---|:---|
| Lunes | 1.991 | 2,849 | 1,678 | 0,372 | 58,262 |
| Martes | 2.063 | 2,837 | 1,696 | 0,351 | 57,247 |
| Miercoles | 1.995 | 2,753 | 1,678 | 0,352 | 56,742 |
| Jueves | 1.987 | 2,832 | 1,699 | 0,353 | 55,662 |
| Viernes | 1.964 | 2,766 | 1,640 | 0,353 | 56,365 |


Por turno (mañana = inicio antes de las 13:00):


| turno | registros | proporcion | canceladas_u | extension_u | prop_multados | hora_inicio_media |
|:---|:---|:---|:---|:---|:---|:---|
| Manana | 4.984 | 0,498 | 2,810 | 1,696 | 0,359 | 11:00 |
| Tarde | 5.016 | 0,502 | 2,806 | 1,660 | 0,353 | 14:58 |


El reparto entre mañana y tarde es parejo (49,84% y 50,16%) y la proporción de multados casi no cambia entre días (de 35,14% a 37,17%). No hay un día ni un turno especialmente problemático, lo que sugiere que la política de control es homogénea.

Cruce turno × día de la semana:


| turno | dia_semana | registros | canceladas_u | extension_u | prop_multados |
|:---|:---|:---|:---|:---|:---|
| Manana | Lunes | 1.012 | 2,843 | 1,688 | 0,373 |
| Manana | Martes | 1.028 | 2,843 | 1,709 | 0,352 |
| Manana | Miercoles | 1.009 | 2,715 | 1,683 | 0,366 |
| Manana | Jueves | 956 | 2,863 | 1,717 | 0,361 |
| Manana | Viernes | 979 | 2,788 | 1,685 | 0,345 |
| Tarde | Lunes | 979 | 2,856 | 1,668 | 0,371 |
| Tarde | Martes | 1.035 | 2,830 | 1,683 | 0,351 |
| Tarde | Miercoles | 986 | 2,793 | 1,672 | 0,339 |
| Tarde | Jueves | 1.031 | 2,803 | 1,682 | 0,345 |
| Tarde | Viernes | 985 | 2,745 | 1,595 | 0,360 |


## 3.6 Consigna 6: muestreo sistemático e intervalo de confianza

Se tomó una muestra sistemática de uno cada 10 registros, con arranque aleatorio en 9 (índices 9, 19, 29, …). Tamaño de la muestra: **1.000** registros (10,00% de la población).

En la muestra hay 365 multados: p̂ = 36,50%. La proporción poblacional es 35,62% (3.562 multados sobre 10.000 registros).


| metodo | p̂ | límite inferior | límite superior | ancho (pp) | ¿contiene la proporción poblacional? |
|:---|:---|:---|:---|:---|:---|
| Wald | 36,50% | 33,52% | 39,48% | 5,97 | Sí |
| Wald con correccion por poblacion finita | 36,50% | 33,67% | 39,33% | 5,66 | Sí |
| Wilson | 36,50% | 33,57% | 39,53% | 5,96 | Sí |


Se informan tres métodos: el de **Wald** (el clásico), el de **Wald con corrección por población finita** y el de **Wilson**. El factor de corrección √((N−n)/(N−1)) vale 0,9487 y corresponde aplicarlo porque n/N = 10,00% supera el 5%. Los tres intervalos **contienen** la proporción poblacional, así que la muestra sistemática reproduce bien a la población.

## 3.7 Consigna 7: intervalo al 95% y si representa el total

Con la muestra sistemática, el intervalo al 95% es [33,52%; 39,48%] y su ancho es 5,97 puntos porcentuales. Con los 10.000 registros, el intervalo es [34,68%; 36,56%], con un ancho de 1,88 puntos porcentuales.

La razón entre los anchos es **3,18**, muy cercana a √(10,0) = 3,16, que es lo que predice la teoría (el error estándar de una proporción decrece con √n). El intervalo de la población completa es más angosto simplemente porque hay más datos.

**Conclusión:** la muestra sistemática **sí representa** el total de los datos, porque su intervalo contiene el valor poblacional. La estimación puntual difiere en 0,88 puntos porcentuales, una diferencia compatible con el error de muestreo.

# 4. Respuestas a las preguntas de decisión

## 4.1 ¿Conviene un plan online que inicie a las 10:00?

El plan solo lo pueden usar los usuarios que empiezan a las 10:00 o después, porque los que ya están estacionados antes de esa hora quedan afuera. Con los datos del mes, **87,71% de los usos empieza a las 10:00 o después** y 12,29% empieza antes (1.229 usos).

**Recomendación:** conviene ofrecerlo, porque lo puede usar la gran mayoría de los clientes, pero **como complemento y no como reemplazo** del pago presencial: los 1.229 usos que empiezan antes de las 10:00 necesitan otra vía de pago. Una alternativa es permitir el inicio del plan desde las 9:00, que es la hora en que empieza la actividad.

## 4.2 Plan de 5 unidades por el precio de 4

El 44,60% de los usos tiene 5 unidades o más, así que ese es el porcentaje de clientes que podría aprovechar el plan. Si se regala una unidad por cada bloque de 5 (o sea, se cobra la unidad 5 al precio de 0 dentro de cada bloque), la recaudación pasaría de $ 1.690.125 a $ 1.575.975: se resignarían $ 114.150 (6,75%). La recaudación media por uso bajaría de $ 112,15 a $ 100,74.

**Ventajas:** incentiva estadías más largas (el cliente que pensaba comprar 4 
unidades tiene un motivo para comprar 5 y pagar lo mismo); es una regla simple 
de comunicar y de auditar; y el costo es acotado y predecible.

**Desventajas:** se resigna una parte de la recaudación por unidades; el usuario 
que ya compraba 5 unidades paga menos sin cambiar su conducta, así que parte 
del descuento es una transferencia y no un incentivo; y complica la liquidación 
de las extensiones, que se cobran después.

## 4.3 Plan de 4 unidades, 4 días por semana, con el 5° día exonerado

Se analizaron 4.195 parejas usuario-semana. El usuario promedio usa el estacionamiento 1,95 días por semana, y solo 228 parejas (5,44%) llegan a 4 días. De esas, **14 cumplen el patrón completo** de 4 días con al menos 4 unidades: la exoneración total sería de 44 unidades, equivalentes a $ 1.100 (0,07% de la recaudación).

**Ventajas:** fideliza al usuario frecuente, que es el que más recaudación 
aporta; el costo es muy bajo respecto de la recaudación total; y el compromiso 
de uso lo hace parecer un abono.

**Desventajas:** solo beneficia a una minoría, así que casi nadie percibe la 
mejora; es difícil de explicar y de liquidar, porque hay que agrupar por usuario 
y por semana; y el perfil que exige (4 días por semana con al menos 2 horas 
cada día) **no coincide con el patrón de uso observado**.

## 4.4 Igual, pero con 4 días consecutivos

Con días consecutivos el patrón es más restrictivo: los 4 días tienen que formar un bloque de lunes a jueves o de martes a viernes. Cumplen **6 parejas usuario-semana** (0,14%) y la exoneración baja a 22 unidades = $ 550 (0,03%).

**Diferencia con la variante anterior:** con días cualesquiera hay 14 beneficiarios y un costo de $ 1.100; exigiendo días consecutivos quedan 6 y $ 550. La variante consecutiva cuesta menos pero es más frágil: un feriado o una ausencia rompe el patrón y el usuario pierde el beneficio, lo que genera reclamos.

## 4.5 ¿Los datos de uso por día siguen una distribución normal?

Se aplicó la prueba de Shapiro-Wilk a los totales diarios (n = 20 días). El planteo es: H0: los datos provienen de una distribución normal; H1: no provienen de una normal.


| variable | W | p-valor | decisión con α = 0,05 |
|:---|:---|:---|:---|
| Registros por día | 0,9425 | 0,2670 | no se rechaza la normalidad |
| Unidades por día | 0,9728 | 0,8121 | no se rechaza la normalidad |
| Recaudación por día | 0,9391 | 0,2305 | no se rechaza la normalidad |


**Conclusión:** con α = 0,05 no se rechaza la normalidad en ninguno de los tres 
casos, así que los totales diarios son compatibles con una distribución normal. 
Esto era esperable: el total diario es la suma de unos 500 usos independientes, 
y por el teorema central del límite se aproxima a una normal.

**Importante:** el registro *individual* (las unidades de un uso) es una variable 
discreta que toma pocos valores, así que no puede ser normal. La pregunta tiene 
sentido sobre el total diario, no sobre el registro suelto.

El histograma con la normal ajustada y el QQ-plot están en la figura 1.

![Figura 1. Registros por dia: histograma con la normal ajustada y QQ-plot.](figuras/normalidad_totales_diarios.png)

## 4.6 Proporción de autos multados por ámbito

La letra pide la proporción “sobre el total de usuarios”. Conviene distinguir dos denominadores posibles: los **usos** (cada vez que un auto se estacionó) y los **usuarios distintos** (autos que se estacionaron al menos una vez). Se informan los dos.

**a) Sobre los usos:**


| ambito | registros | multados | proporción | IC 95% inferior | IC 95% superior |
|:---|:---|:---|:---|:---|:---|
| Total del archivo | 10.000 | 3.562 | 35,62% | 34,68% | 36,56% |
| Mensual (4 semanas) | 10.000 | 3.562 | 35,62% | 34,68% | 36,56% |
| Semana 1 | 2.462 | 892 | 36,23% | 34,33% | 38,13% |
| Semana 2 | 2.573 | 919 | 35,72% | 33,87% | 37,57% |
| Semana 3 | 2.493 | 891 | 35,74% | 33,86% | 37,62% |
| Semana 4 | 2.472 | 860 | 34,79% | 32,91% | 36,67% |
| Lunes | 1.991 | 740 | 37,17% | 35,04% | 39,29% |
| Martes | 2.063 | 725 | 35,14% | 33,08% | 37,20% |
| Miercoles | 1.995 | 703 | 35,24% | 33,14% | 37,33% |
| Jueves | 1.987 | 701 | 35,28% | 33,18% | 37,38% |
| Viernes | 1.964 | 693 | 35,29% | 33,17% | 37,40% |


**b) Sobre los usuarios distintos:**


| ambito | usuarios | usuarios multados | proporción | IC 95% inferior | IC 95% superior |
|:---|:---|:---|:---|:---|:---|
| Total del archivo | 1.200 | 1.142 | 95,17% | 93,95% | 96,38% |
| Mensual (4 semanas) | 1.200 | 1.142 | 95,17% | 93,95% | 96,38% |
| Semana 1 | 1.050 | 631 | 60,10% | 57,13% | 63,06% |
| Semana 2 | 1.062 | 651 | 61,30% | 58,37% | 64,23% |
| Semana 3 | 1.040 | 632 | 60,77% | 57,80% | 63,74% |
| Semana 4 | 1.043 | 611 | 58,58% | 55,59% | 61,57% |
| Lunes | 971 | 549 | 56,54% | 53,42% | 59,66% |
| Martes | 998 | 561 | 56,21% | 53,13% | 59,29% |
| Miercoles | 961 | 530 | 55,15% | 52,01% | 58,30% |
| Jueves | 997 | 544 | 54,56% | 51,47% | 57,65% |
| Viernes | 972 | 527 | 54,22% | 51,09% | 57,35% |


La proporción sobre usos ronda el 35,62% en todos los ámbitos. Sobre usuarios distintos es mucho más alta (95,17%) porque un auto que se estaciona varias veces por semana tiene más oportunidades de ser multado alguna vez: la probabilidad de no ser multado nunca en el mes es (1 − 0,356)^8,3 = 2,55%. Es la diferencia entre “probabilidad de multa por visita” y “probabilidad de haber sido multado en el mes”: las dos son correctas, pero responden a preguntas distintas.

El ámbito “mensual” coincide con el total porque el archivo **es** el mes (las 
4 semanas); se informa igual para completar lo que pide la letra.

## 4.7 Intervalos de recaudación por concepto

La recaudación del mes fue $ 1.690.125: $ 701.950 por horas canceladas (41,53%), $ 419.575 por extensiones (24,83%) y $ 568.600 por multas (33,64%).


| concepto | confianza | total observado | límite inferior | límite superior |
|:---|:---|:---|:---|:---|
| Canceladas | 90% | 701.950 | 695.055 | 708.844 |
| Canceladas | 95% | 701.950 | 693.734 | 710.165 |
| Canceladas | 99% | 701.950 | 691.152 | 712.747 |
| Extensiones | 90% | 419.575 | 415.990 | 423.159 |
| Extensiones | 95% | 419.575 | 415.303 | 423.846 |
| Extensiones | 99% | 419.575 | 413.961 | 425.188 |
| Multas | 90% | 568.600 | 554.508 | 582.691 |
| Multas | 95% | 568.600 | 551.808 | 585.391 |
| Multas | 99% | 568.600 | 546.531 | 590.668 |
| Total | 90% | 1.690.125 | 1.674.127 | 1.706.122 |
| Total | 95% | 1.690.125 | 1.671.062 | 1.709.187 |
| Total | 99% | 1.690.125 | 1.665.071 | 1.715.178 |


El intervalo del total poblacional se calcula como N × (media ± z·EE), con N = 10.000. Al 90% z = 1,645; al 95% z = 1,96; al 99% z = 2,576. Cuanto mayor es la confianza, más ancho es el intervalo: se gana seguridad y se pierde precisión. El concepto con mayor incertidumbre relativa es el de multas, porque es el que tiene más variabilidad entre registros.

# 5. Conclusiones

1. El estacionamiento se usa en **bloques cortos**: el promedio es de 
   1,40 horas por adelantado y el 24,34% de los usos compra dos unidades o menos.
2. La actividad está **repartida parejo** entre los cinco días hábiles y entre 
   la mañana y la tarde: no hay un día ni un turno que concentre el problema.
3. La proporción de multados es estable (35,62%) en todos los cortes, lo que sugiere una política de control homogénea.
4. El **plan online desde las 10:00 es conveniente** (lo puede usar el 
   87,71% de los usos), siempre que se mantenga otra vía de pago para los que empiezan antes.
5. El **plan de 5 por 4** es el que tiene más adopción potencial (44,60%) y el que más cuesta (6,75% de la recaudación).
6. Los planes semanales (preguntas 3 y 4) **casi no tienen beneficiarios** con el patrón de uso actual: cuestan menos de 0,07% de la recaudación, pero tampoco resuelven ningún problema. Si el objetivo es fidelizar, convendría rediseñarlos o apuntar a otro segmento.
7. Los totales diarios son **compatibles con una distribución normal**, lo que 
   habilita usar intervalos de confianza y pruebas basadas en la normal sobre 
   los agregados diarios.
8. La **muestra sistemática de uno cada 10 representa bien a la población**: su intervalo al 95% contiene la proporción poblacional.

# 6. Cómo reproducir este informe

```
# 1) abrir pye2026Lab.Rproj en RStudio (el directorio de trabajo queda en la raíz)
# 2) ejecutar R/main.r
```

Eso regenera `datos/datos.csv` (si no existe), `RESULTADOS.txt`, las figuras de 
`figuras/` y este informe. Para cambiar un supuesto (tarifa, corte de turno, 
nivel de confianza) alcanza con editar `R/parametros.r`: no hay números escritos 
a mano en ningún archivo de análisis.
