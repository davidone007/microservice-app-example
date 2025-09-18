# users-api/Dockerfile
FROM openjdk:8-jdk-alpine

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de Maven (para cache de dependencias)
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Hacer el script mvnw ejecutable
RUN chmod +x mvnw

# Descargar dependencias (para optimizar cache de Docker)
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente
COPY src src

# Compilar la aplicación
RUN ./mvnw clean package 

# Exponer puerto
EXPOSE 8083

# Variables de entorno
ENV SERVER_PORT=8083

# Comando para ejecutar la aplicación
CMD ["java", "-jar", "target/users-api-0.0.1-SNAPSHOT.jar"]