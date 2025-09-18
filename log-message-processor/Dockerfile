# log-message-processor/Dockerfile
FROM python:3.6-alpine

WORKDIR /app

# Instalar herramientas de compilación necesarias
RUN apk add --no-cache gcc musl-dev

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias
RUN pip install -r requirements.txt

# Copiar código fuente
COPY . .

# Variables de entorno
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV REDIS_CHANNEL=log_channel
ENV PYTHONUNBUFFERED=1

# Comando para ejecutar
CMD ["python3", "main.py"]
