n=10000

A=matrix(c(0),nrow=n, ncol=7)

# Definiendo usuarios
x=runif(n,0,0.2*n)
x=floor(x)+1
A[,1]=x

# Definiendo dia de la semana
x=runif(n,0,20)
x=floor(x)+1
A[,2]=x


#Definiendo hora de inicio de servicio

x=runif(n,9,17)
x=0.01*floor(floor(100*(x-floor(x)))/10*6)+floor(x)
A[,3]=x


#Definiendo hora canceladas

x=runif(n,0,4)
x=floor(x)+1
A[,4]=x

#Definiendo hora canceladas

x=floor(runif(n,0,9)/6)
x=floor(x)+1
A[,5]=x

#Definiendo multados



x=rbinom(n,size=1,prob=0.4)
A[,6]=x

#Definiendo multas


x=rbinom(n,size=1,prob=0.3)+rbinom(n,size=1,prob=0.3)
A[,7]=100*A[,6]+100*A[,6]*x

# Asignando nombre a las columnas

colnames(A)=c("id","dia","hora_inicio","horas_canceladas","extension_horas","multa","valor_multa")

# Convirtiendo los datos en data.frame

MA=data.frame(A)

# escribir los datos en el archivo datos.csv
write.csv(MA,"~/datos.csv")



# Para filtar los datos por la columna "dia" se emplea el coamdo, luego se indican
#  las columnas que se guaran en la variable primer_lunes

primer_lunes<-subset(MA, dia == 1,
                     select = c("id","dia","hora_inicio","horas_canceladas",
                                "extension_horas","multa","valor_multa"))
