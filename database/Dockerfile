# Utiliser une image de base Node.js légère
FROM postgres:17-alpine

# Définir le répertoire de travail de l'application
WORKDIR /app

# Copier les fichiers package.json et package-lock.json pour installer les dépendances
COPY init.sql ./docker-entrypoint-initdb.d/

# Installer les dépendances
RUN npm install

# Copier les fichiers sources de l'application dans le conteneur
COPY . .

# Construire l'application (si nécessaire, par exemple pour React/Vite)
RUN npm run build

# Installer serve globalement pour servir les fichiers statiques
RUN npm install -g serve

# Exposer le port
EXPOSE 3000

# Démarrer l'application
CMD ["serve", "-s", "dist"]
