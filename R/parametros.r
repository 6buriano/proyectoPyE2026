# =====================================================================
# R/parametros.r
# Parametros del proyecto. TODO lo que es un supuesto propio esta aca,
# en un solo lugar, para poder cambiarlo sin tocar el resto del codigo.
#
# La letra no fija algunos de estos valores (por ejemplo la tarifa por
# unidad de 30 minutos ni donde termina la manana), asi que se declaran
# explicitamente.
# =====================================================================

# --- Reproducibilidad ------------------------------------------------
# Semilla del generador de numeros aleatorios. Sin esto, cada corrida
# produce datos distintos y ningun numero del informe se puede repetir.
SEMILLA <- 2026

# --- Datos -----------------------------------------------------------
N_REGISTROS <- 10000   # cantidad de registros del archivo (letra)
N_USUARIOS  <- 1200    # cantidad de usuarios distintos del padrón
N_SEMANAS   <- 4       # 4 semanas de lunes a viernes = 20 dias habiles

# --- Supuestos economicos y operativos -------------------------------
TARIFA_UNIDAD   <- 25   # $ por unidad de 30 minutos (la letra no la fija)

# --- Franjas horarias (hay DOS, no confundirlas) ---------------------
# (1) Franja de MUESTREO: la ventana del dia en la que ocurren los
#     servicios. La usa generarDatos() para sortear la hora de inicio.
#     El ultimo servicio empieza un minuto antes de HORA_CIERRE.
HORA_APERTURA <- 9      # 9:00
HORA_CIERRE   <- 17     # se muestrea hasta las 16:59

# (2) Corte MAÑANA/TARDE: parte el dia en dos para la consigna 5.
#     Lo usa prepararDatos() para construir la columna "turno".
HORA_CORTE_TURNO <- 13  # antes de las 13:00 = manana; 13:00 o despues = tarde

# --- Muestreo e inferencia -------------------------------------------
K_SISTEMATICO <- 10     # muestreo sistematico: uno de cada 10 (letra)
CONF_NIVEL    <- 0.95   # nivel de confianza por defecto
