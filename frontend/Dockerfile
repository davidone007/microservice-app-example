# frontend/Dockerfile
FROM node:8-alpine

WORKDIR /app

# Copiar package.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Exponer puerto
EXPOSE 8080

# Variables de entorno
ENV PORT=8080

# Comando para ejecutar
CMD ["npm", "start"]
