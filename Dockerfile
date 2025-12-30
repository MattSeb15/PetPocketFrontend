# Build stage
FROM node:22-alpine AS build

WORKDIR /app

# Install deps (reproducible)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source
COPY . .

# Build Angular (production)
RUN npm run build -- --configuration production

# Normalize build output to /out (handles Angular "application" builder output layouts)
RUN mkdir -p /out \
    && if [ -f dist/PetPocketFrontend/browser/index.html ]; then \
    cp -R dist/PetPocketFrontend/browser/* /out/; \
    elif [ -f dist/PetPocketFrontend/index.html ]; then \
    cp -R dist/PetPocketFrontend/* /out/; \
    else \
    echo "ERROR: No se encontró index.html en dist/. Revisa el output de build."; \
    find dist -maxdepth 4 -type f -name index.html -print || true; \
    exit 1; \
    fi


# Runtime stage
FROM nginx:1.27-alpine

# SPA routing for Angular
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
  listen 80;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }
}
EOF

COPY --from=build /out/ /usr/share/nginx/html/

EXPOSE 80
