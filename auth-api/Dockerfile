# auth-api/Dockerfile
FROM golang:1.18-alpine AS builder

WORKDIR /app

# Copiar archivos Go
COPY . .

# Inicializar módulos y construir
RUN go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
RUN go mod tidy
RUN go build -o auth-api

# Imagen final
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copiar el binario
COPY --from=builder /app/auth-api .

# Exponer puerto
EXPOSE 8000

# Variables de entorno
ENV AUTH_API_PORT=8000

# Comando para ejecutar
CMD ["./auth-api"]
