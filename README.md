# Proyecto final — Probabilidad y Estadística (UTEC 2026)

Uso de estacionamientos en las calles de San José: análisis estadístico de
10.000 registros de 4 semanas de lunes a viernes.

## Cómo correrlo

1. Abrir `pye2026Lab.Rproj` en RStudio (así el directorio de trabajo queda en
   la raíz del proyecto).
2. Ejecutar **`R/main.r`** completo.

O desde la consola del sistema, parado en la raíz del proyecto:

```
Rscript R/main.r
```

Eso genera, de una sola corrida:

| Archivo | Qué es |
|---|---|
| `datos/datos.csv` | el archivo de 10.000 registros (se crea si no existe) |
| `RESULTADOS.txt` | toda la salida de las 7 consignas y las 7 preguntas |
| `figuras/` | gráficos de normalidad de la pregunta 5 |
| `informe/Informe_Proyecto_Final.md` y `.docx` | el informe de la entrega |

Todo usa **solo R base**: no hace falta instalar ningún paquete.

## Cómo está organizado

```
R/
  parametros.r      supuestos propios: semilla, tarifa, corte de turno, nivel de confianza
  funciones.r       funciones reutilizables (horas, intervalos de confianza, resúmenes)
  data.r            genera o lee datos/datos.csv y prepara el data.frame MA
  01_descriptivos.R consignas 1 a 5 de la letra
  02_inferencia.R   consignas 6 y 7: muestreo sistemático e intervalos de confianza
  03_decisiones.R   las 7 preguntas de decisión
  04_informe.R      arma el informe a partir de los resultados calculados
  main.r            punto de entrada: lee todo en orden y corre el proyecto
datos/datos.csv     archivo de datos (9 columnas)
figuras/            gráficos generados
informe/            informe en Markdown y Word + la plantilla de estilo
```

## Decisiones de diseño

**Los supuestos están en un solo lugar.** La letra no fija la tarifa por unidad
de 30 minutos ni dónde termina la mañana. Esos valores están en
`R/parametros.r`: cambiando una línea se recalcula todo, incluido el informe.

**No hay números escritos a mano.** Todos los resultados salen de los datos y
el informe se genera desde las mismas variables que se calculan en el análisis.
Si se corre dos veces, `RESULTADOS.txt` sale idéntico (salvo la fecha de
ejecución) porque `R/data.r` fija `set.seed(2026)`.

**El archivo de datos se puede reemplazar.** Si la cátedra entrega el archivo,
alcanza con ponerlo en `datos/datos.csv` y correr `R/main.r`: si no trae las
columnas `semana` y `dia_semana`, `prepararDatos()` las deriva de `dia` y valida
la coherencia del contenido.

**La hora se pasa a minutos antes de promediar.** `hora_inicio` está codificada
como HH.MM (9.35 = 9:35), así que su parte decimal son minutos y no centésimas
de hora. Promediar los valores tal cual da 12,798, que no es una hora válida;
`convertirAMinutos()` y `formatoHoraMinutos()` resuelven el ida y vuelta.

## Requisitos

* R 4.x (probado con R 4.6.1).
* Opcional: [pandoc](https://pandoc.org/) para convertir el informe a Word. Si
  no está instalado, el informe queda igual en `informe/Informe_Proyecto_Final.md`
  y se puede convertir después con:
  `pandoc informe/Informe_Proyecto_Final.md -o informe/Informe_Proyecto_Final.docx`
