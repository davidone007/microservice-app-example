# Etapa de construcción (Build Stage)
# Usamos Node 14 que es más compatible con dependencias antiguas como node-sass@4.x
FROM node:14-alpine as build-stage

# Instalamos las dependencias necesarias para compilar node-sass en Alpine Linux
RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Etapa final (Final Stage)
FROM nginx:alpine

# Copia tu archivo de configuración de Nginx como una plantilla.
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copia los archivos estáticos desde la etapa de construcción
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Elimina la configuración por defecto de Nginx
RUN rm -f /etc/nginx/conf.d/default.conf

# CMD que especifica EXACTAMENTE qué variables reemplazar (VERSIÓN CORREGIDA)
# Esta línea ha sido limpiada para evitar caracteres ocultos.
CMD ["/bin/sh", "-c", "envsubst '${AUTH_HOST} ${AUTH_API_PORT} ${TODOS_API_HOST} ${TODO_API_PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]