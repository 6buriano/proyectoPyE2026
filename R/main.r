source("R/data.r")
source("R/funciones.r")

#Proyecto de final de curso PyE 2026



#Con el archivo que contiene 10.000 registros correspondientes a 4 semanas de lunes a viernes,

#calcular:

#1. Valor promedio de las horas solicitadas de uso de estacioniento
#2. Promedio de hora de inicio del uso del estacionamiento.

  datosHoras <- convertirAMinutos(MA$hora_inicio)

  promedio <- mean(datosHoras)

  datosFormateados <- formatoHoraMinutos(promedio)

  cat("1-2) Hora inicio promedio del uso del estacionamiento:", datosFormateados, "\n")


#3. Promedio de las extensiones de hora, los multados por finalizacion de tiempo y los montos de las multas.
#4. Usuarios promedios por semana y por dia de la semana.
#5. Luego realice los calculo discriminando dias de la semana, horario(manana/tarde)
#6. Realizar un muestreo sistemático uno de cada 10 datos, y hacer un intervalo de confianza para proporciones, para compararlo con la proporción poblacional de autos multados.
#7. Hacer un intervalo de confianza al 95 % para proporciones y determinar si representa el total de los datos.


#Se busca contestar:

#1. Es conveniente ofrecer planes para pagar online y que inicie a las 10:00 am.
#2. Ventajas y desventajas de ofrecer planes de 5 unidades por el precio de 4.
#3. Ventajas y desventajas de ofrecer planes de por 4 unidades 4 dias a las semana, te exoneran 4 unidades el 5to dia.
#4. Ventajas y desventajas de ofrecer planes de por 4 unidades 4 dias consecutivos, te exoneran 4 unidades el 5to dia/ otro dia cualquiera.
#5. Los datos de uso por dia siguen una distribucion normal?
#6. Proporcion de autos multados por total de usuarios, mensual, semanal y por dia de la semana.
#7. Estimar intervalos de recaudación por cada de los conceptos, con una confianza del 90 %, 95 % y 99 %.


