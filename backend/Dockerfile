# Utiliser une image de base Node.js légère
FROM node:24-alpine

# Définir le répertoire de travail de l'application
WORKDIR /app

# Copier les fichiers package.json et package-lock.json pour installer les dépendances
COPY package.json ./

# Installer les dépendances
RUN npm install

# Copier les fichiers sources de l'application dans le conteneur
COPY . .

# Exposer le port
EXPOSE 3007

# Démarrer l'application
CMD ["npm", "run", "start"]
