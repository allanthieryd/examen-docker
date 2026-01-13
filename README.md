# Quiz App - Configuration Docker

## Architecture de l'application

Cette application Quiz est composée de 3 services Docker orchestrés avec Docker Compose :

- **Frontend** : Application web servie par Nginx (port 8087)
- **Backend** : API Node.js (port 3007)
- **Database** : PostgreSQL 17 (port interne 5432)

## Étapes de création Docker

### 1. Configuration de la base de données (database/)

**Fichier** : [database/Dockerfile](database/Dockerfile)

```dockerfile
FROM postgres:17-alpine
WORKDIR /app
COPY init.sql ./docker-entrypoint-initdb.d/
```

- Utilisation de PostgreSQL 17 Alpine (image légère)
- Copie du script `init.sql` dans le répertoire d'initialisation automatique de PostgreSQL
- Le script SQL sera exécuté automatiquement au premier démarrage

### 2. Configuration du backend (backend/)

**Fichier** : [backend/Dockerfile](backend/Dockerfile)

```dockerfile
FROM node:24-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3007
CMD ["npm", "run", "start"]
```

**Étapes** :
- Image de base Node.js 24 Alpine (légère)
- Installation des dépendances npm
- Copie du code source
- Exposition du port 3007
- Démarrage de l'application avec `npm start`

### 3. Configuration du frontend

**Fichier** : [Dockerfile](Dockerfile) (à la racine)

Build multi-stage pour optimiser la taille de l'image :

**Stage 1 - Build** :
```dockerfile
FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build
```

**Stage 2 - Production** :
```dockerfile
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Avantages** :
- Build multi-stage : image finale légère sans les dépendances de développement
- Nginx pour servir les fichiers statiques en production
- Configuration nginx personnalisée

### 4. Orchestration avec Docker Compose

**Fichier** : [docker-compose.yml](docker-compose.yml)

```yaml
services:
  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5
    volumes:
      - /var/lib/postgresql/data
    restart: unless-stopped

  backend:
    expose:
      - 3007
    variables:
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy

  frontend:
    ports:
      - 8087:80
    depends_on:
      - backend
```

**Caractéristiques importantes** :

- **Healthcheck** : Le backend attend que la DB soit prête avant de démarrer
- **Dépendances** : Frontend → Backend → Database (démarrage séquentiel)
- **Volumes** : Persistance des données PostgreSQL
- **Variables d'environnement** : Configuration via `.env.local`
- **Restart policy** : Redémarrage automatique de la DB en cas de crash

### 5. Configuration des variables d'environnement

**Fichier** : [.env.local](.env.local)

```env
DATABASE_URL=postgres://${quiz_user}:${quiz_password}@db:5432/${quiz_db}
POSTGRES_USER=quiz_user
POSTGRES_PASSWORD=quiz_password
POSTGRES_DB=quiz_db

ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123
JWT_SECRET=123456
```

## Commandes Docker

### Lancer l'application

```bash
docker-compose up -d
```

### Voir les logs

```bash
docker-compose logs -f
```

### Arrêter l'application

```bash
docker-compose down
```

### Rebuild après modification

```bash
docker-compose up -d --build
```

### Supprimer les volumes (réinitialiser la DB)

```bash
docker-compose down -v
```

## Accès à l'application

- **Frontend** : http://localhost:8087
- **Backend API** : http://localhost:3007 (via le frontend)
- **Database** : Accessible uniquement en interne par le backend

## Bonnes pratiques appliquées

1. **Images Alpine** : Images légères pour réduire la taille
2. **Multi-stage build** : Frontend optimisé pour la production
3. **Healthchecks** : Garantit que les services dépendants sont prêts
4. **Variables d'environnement** : Configuration externalisée
5. **Volumes** : Persistance des données
6. **Restart policies** : Haute disponibilité
7. **Exposition sélective des ports** : Seul le frontend est accessible publiquement

## Structure du projet

```
quiz-app/
├── backend/
│   ├── Dockerfile
│   └── (code backend)
├── database/
│   ├── Dockerfile
│   └── init.sql
├── nginx/
│   └── nginx.conf
├── Dockerfile (frontend)
├── docker-compose.yml
├── .env.local
└── (fichiers frontend)
```
