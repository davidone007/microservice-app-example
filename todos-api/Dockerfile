# todos-api/Dockerfile
FROM node:8-alpine

WORKDIR /app

# Copiar package.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Exponer puerto
EXPOSE 8082

# Variables de entorno
ENV TODO_API_PORT=8082
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV REDIS_CHANNEL=log_channel

# Comando para ejecutar
CMD ["npm", "start"]
