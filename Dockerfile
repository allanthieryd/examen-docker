# Utiliser une image de base Node.js légère
FROM node:24-alpine AS build

# Définir le répertoire de travail de l'application
WORKDIR /app

# Copier les fichiers de dépendances
COPY package.json package-lock.json ./

# Installer les dépendances
RUN npm install

# Copier les fichiers sources de l'application dans le conteneur
COPY . .

# Construire l'application
RUN npm run build

## STEP 2

# Utiliser une image nginx
FROM nginx:alpine

# Copier les fichiers construits depuis l'étape précédente
COPY --from=build /app/dist /usr/share/nginx/html

# Copier la configuration nginx
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Démarrer nginx
CMD ["nginx", "-g", "daemon off;"]