FROM public.ecr.aws/docker/library/node:22-slim
RUN npm install -g npm@11 --loglevel=error

# Instalando curl
RUN cd client && npm ci --legacy-peer-deps --no-audit --no-fund --loglevel=error

WORKDIR /usr/src/app

# Copiar package.json raiz primeiro
COPY package*.json ./
RUN npm ci --no-audit --no-fund --loglevel=error

# Copiar package.json do client e instalar dependências (incluindo devDependencies para build)
COPY client/package*.json ./client/
RUN cd client && npm install --legacy-peer-deps --loglevel=error

# Copiar todos os arquivos
COPY . .

# Build do front-end com Vite
RUN cd client && VITE_API_URL=http://localhost:3001 npm run build
RUN cd client && VITE_API_URL="" npm run build

# Limpeza das dependências de desenvolvimento do client para reduzir tamanho
RUN cd client && npm prune --production && rm -rf node_modules/.cache

EXPOSE 8080

CMD [ "npm", "start" ]