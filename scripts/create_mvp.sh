#!/bin/bash
# 🚀 MVP GENERATOR - Crea un MVP funcional en minutos
# Usa templates pre-configurados para diferentes industrias

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración
PROJECT_NAME=""
PROJECT_TYPE=""
INDUSTRY=""
PORT=3000

# Banner
show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         MVP GENERATOR PRO v2.0               ║${NC}"
    echo -e "${CYAN}║     De idea a producción en 60 minutos      ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

# Seleccionar tipo de proyecto
select_project_type() {
    echo -e "${BLUE}📦 SELECCIONA EL TIPO DE MVP:${NC}"
    echo ""
    echo "  1) 🏢 CRM Simple (Gestión de clientes)"
    echo "  2) 📅 Sistema de Reservas/Turnos"
    echo "  3) 📊 Dashboard Analytics"
    echo "  4) 🛒 E-commerce Básico"
    echo "  5) 📝 Sistema de Tickets/Soporte"
    echo "  6) 📚 LMS (Plataforma educativa)"
    echo "  7) 🏥 Historia Clínica Digital"
    echo "  8) 🍕 Delivery/Pedidos Online"
    echo "  9) 📦 Control de Inventario"
    echo " 10) 🤖 Chatbot con IA"
    echo ""
    read -p "Opción (1-10): " choice
    
    case $choice in
        1) PROJECT_TYPE="crm" ;;
        2) PROJECT_TYPE="booking" ;;
        3) PROJECT_TYPE="dashboard" ;;
        4) PROJECT_TYPE="ecommerce" ;;
        5) PROJECT_TYPE="tickets" ;;
        6) PROJECT_TYPE="lms" ;;
        7) PROJECT_TYPE="medical" ;;
        8) PROJECT_TYPE="delivery" ;;
        9) PROJECT_TYPE="inventory" ;;
        10) PROJECT_TYPE="chatbot" ;;
        *) echo "Opción inválida"; exit 1 ;;
    esac
}

# Obtener detalles del proyecto
get_project_details() {
    echo ""
    read -p "📝 Nombre del proyecto: " PROJECT_NAME
    PROJECT_NAME=$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    read -p "🏭 Industria del cliente: " INDUSTRY
    
    read -p "🔌 Puerto para el servidor (default 3000): " custom_port
    if [ ! -z "$custom_port" ]; then
        PORT=$custom_port
    fi
}

# Crear estructura base
create_base_structure() {
    echo ""
    echo -e "${BLUE}🔨 Creando estructura del proyecto...${NC}"
    
    mkdir -p $PROJECT_NAME
    cd $PROJECT_NAME
    
    # Estructura de carpetas
    mkdir -p {src,public,config,scripts,docs,tests}
    mkdir -p src/{components,pages,services,utils,hooks,context}
    mkdir -p src/components/{common,layout,features}
    mkdir -p public/{images,fonts}
    mkdir -p scripts/{deploy,backup}
    
    echo -e "${GREEN}✓ Estructura creada${NC}"
}

# Generar package.json
create_package_json() {
    echo -e "${BLUE}📦 Configurando package.json...${NC}"
    
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "MVP for $INDUSTRY - $PROJECT_TYPE",
  "private": true,
  "scripts": {
    "dev": "next dev -p $PORT",
    "build": "next build",
    "start": "next start -p $PORT",
    "lint": "next lint",
    "test": "jest",
    "docker:build": "docker build -t $PROJECT_NAME .",
    "docker:run": "docker run -p $PORT:$PORT $PROJECT_NAME",
    "deploy": "bash scripts/deploy/deploy.sh"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@prisma/client": "^5.0.0",
    "prisma": "^5.0.0",
    "axios": "^1.6.0",
    "zustand": "^4.4.0",
    "react-hook-form": "^7.48.0",
    "zod": "^3.22.0",
    "@hookform/resolvers": "^3.3.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "nodemailer": "^6.9.0",
    "react-query": "^3.39.0",
    "date-fns": "^3.0.0",
    "recharts": "^2.10.0",
    "react-hot-toast": "^2.4.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.3.0",
    "eslint": "^8.55.0",
    "eslint-config-next": "14.0.0",
    "@testing-library/react": "^14.1.0",
    "@testing-library/jest-dom": "^6.1.0",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0"
  }
}
EOF
    
    echo -e "${GREEN}✓ package.json creado${NC}"
}

# Crear archivo de configuración Next.js
create_next_config() {
    echo -e "${BLUE}⚙️ Configurando Next.js...${NC}"
    
    cat > next.config.js << EOF
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  env: {
    DATABASE_URL: process.env.DATABASE_URL,
    JWT_SECRET: process.env.JWT_SECRET,
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:$PORT'
  },
  images: {
    domains: ['localhost', 'res.cloudinary.com'],
  },
}

module.exports = nextConfig
EOF
    
    echo -e "${GREEN}✓ Next.js configurado${NC}"
}

# Crear configuración de Prisma
create_prisma_config() {
    echo -e "${BLUE}🗄️ Configurando base de datos...${NC}"
    
    mkdir -p prisma
    
    cat > prisma/schema.prisma << EOF
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  name      String?
  role      Role     @default(USER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum Role {
  USER
  ADMIN
  SUPER_ADMIN
}

model Customer {
  id        String   @id @default(cuid())
  name      String
  email     String   @unique
  phone     String?
  company   String?
  notes     String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Product {
  id          String   @id @default(cuid())
  name        String
  description String?
  price       Float
  stock       Int      @default(0)
  category    String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
EOF
    
    echo -e "${GREEN}✓ Prisma configurado${NC}"
}

# Crear Dockerfile
create_docker_config() {
    echo -e "${BLUE}🐳 Configurando Docker...${NC}"
    
    cat > Dockerfile << EOF
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE $PORT
ENV PORT $PORT

CMD ["node", "server.js"]
EOF
    
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build: .
    ports:
      - "$PORT:$PORT"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/$PROJECT_NAME
      - JWT_SECRET=your-secret-key-here
    depends_on:
      - db
    volumes:
      - ./:/app
      - /app/node_modules
    command: npm run dev

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=$PROJECT_NAME
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF
    
    echo -e "${GREEN}✓ Docker configurado${NC}"
}

# Crear archivos de entorno
create_env_files() {
    echo -e "${BLUE}🔐 Creando archivos de entorno...${NC}"
    
    cat > .env.local << EOF
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/$PROJECT_NAME"

# Authentication
JWT_SECRET="$(openssl rand -base64 32)"
NEXTAUTH_URL="http://localhost:$PORT"
NEXTAUTH_SECRET="$(openssl rand -base64 32)"

# Email (opcional)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"

# API Keys (agregar según necesidad)
# OPENAI_API_KEY=""
# STRIPE_SECRET_KEY=""
# CLOUDINARY_URL=""
EOF
    
    cat > .env.example << EOF
# Copy this file to .env.local and fill with your values
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
JWT_SECRET="your-secret-key"
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="your-nextauth-secret"
EOF
    
    echo -e "${GREEN}✓ Variables de entorno configuradas${NC}"
}

# Generar componente principal según tipo
generate_main_component() {
    echo -e "${BLUE}🎨 Generando componentes principales...${NC}"
    
    case $PROJECT_TYPE in
        "crm")
            create_crm_components
            ;;
        "booking")
            create_booking_components
            ;;
        "dashboard")
            create_dashboard_components
            ;;
        *)
            create_generic_components
            ;;
    esac
    
    echo -e "${GREEN}✓ Componentes creados${NC}"
}

# Componentes para CRM
create_crm_components() {
    cat > src/pages/index.tsx << 'EOF'
import { useState } from 'react'
import { useQuery } from 'react-query'

export default function CRMDashboard() {
  const [selectedCustomer, setSelectedCustomer] = useState(null)
  
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <h1 className="text-3xl font-bold text-gray-900">CRM Dashboard</h1>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Stats */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">Total Clientes</h3>
            <p className="mt-2 text-3xl font-semibold text-blue-600">1,234</p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">Ventas del Mes</h3>
            <p className="mt-2 text-3xl font-semibold text-green-600">$45,678</p>
          </div>
          
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">Tareas Pendientes</h3>
            <p className="mt-2 text-3xl font-semibold text-yellow-600">23</p>
          </div>
        </div>
        
        {/* Customer List */}
        <div className="mt-8 bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900">Clientes Recientes</h2>
          </div>
          <div className="divide-y divide-gray-200">
            {/* Customer rows here */}
          </div>
        </div>
      </main>
    </div>
  )
}
EOF
}

# Componentes genéricos
create_generic_components() {
    cat > src/pages/index.tsx << 'EOF'
export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20">
        <div className="text-center">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            MVP Ready to Launch 🚀
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Tu aplicación está lista para personalizar y desplegar
          </p>
          <div className="space-x-4">
            <button className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700">
              Get Started
            </button>
            <button className="bg-white text-gray-900 px-6 py-3 rounded-lg border hover:bg-gray-50">
              Learn More
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF
}

# Crear scripts de deployment
create_deployment_scripts() {
    echo -e "${BLUE}🚀 Creando scripts de deployment...${NC}"
    
    mkdir -p scripts/deploy
    
    cat > scripts/deploy/deploy.sh << 'EOF'
#!/bin/bash
# Deployment script

echo "🚀 Starting deployment..."

# Build
npm run build

# Run tests
npm test

# Docker build and push
docker build -t $PROJECT_NAME:latest .
# docker push your-registry/$PROJECT_NAME:latest

echo "✅ Deployment complete!"
EOF
    
    chmod +x scripts/deploy/deploy.sh
    
    echo -e "${GREEN}✓ Scripts de deployment creados${NC}"
}

# Crear README
create_readme() {
    echo -e "${BLUE}📝 Creando documentación...${NC}"
    
    cat > README.md << EOF
# $PROJECT_NAME

MVP para $INDUSTRY - Tipo: $PROJECT_TYPE

## 🚀 Quick Start

### Desarrollo local
\`\`\`bash
# Instalar dependencias
npm install

# Configurar base de datos
npx prisma migrate dev

# Iniciar servidor de desarrollo
npm run dev
\`\`\`

Abrir [http://localhost:$PORT](http://localhost:$PORT)

### Docker
\`\`\`bash
docker-compose up
\`\`\`

## 📁 Estructura

\`\`\`
$PROJECT_NAME/
├── src/
│   ├── components/
│   ├── pages/
│   ├── services/
│   └── utils/
├── prisma/
│   └── schema.prisma
├── public/
├── scripts/
└── docker-compose.yml
\`\`\`

## 🔧 Configuración

1. Copiar \`.env.example\` a \`.env.local\`
2. Configurar variables de entorno
3. Ejecutar migraciones: \`npx prisma migrate dev\`

## 📦 Deployment

### Vercel
\`\`\`bash
vercel --prod
\`\`\`

### Docker
\`\`\`bash
docker build -t $PROJECT_NAME .
docker run -p $PORT:$PORT $PROJECT_NAME
\`\`\`

### VPS
\`\`\`bash
bash scripts/deploy/deploy.sh
\`\`\`

## 📊 Features

- ✅ Autenticación JWT
- ✅ CRUD completo
- ✅ Dashboard responsive
- ✅ API RESTful
- ✅ Docker ready
- ✅ Tests incluidos

## 🛠️ Tech Stack

- **Frontend**: Next.js 14, React, TailwindCSS
- **Backend**: Next.js API Routes
- **Database**: PostgreSQL + Prisma
- **Auth**: JWT
- **Deploy**: Docker, Vercel

## 📝 License

Private - $INDUSTRY

---
Generated with MVP Generator Pro v2.0
EOF
    
    echo -e "${GREEN}✓ README creado${NC}"
}

# Instalar dependencias
install_dependencies() {
    echo ""
    echo -e "${BLUE}📦 ¿Instalar dependencias ahora? (puede tomar varios minutos)${NC}"
    read -p "Instalar (s/n): " install_deps
    
    if [[ $install_deps =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}Installing dependencies...${NC}"
        npm install
        echo -e "${GREEN}✓ Dependencias instaladas${NC}"
        
        echo -e "${BLUE}🗄️ ¿Configurar base de datos Prisma?${NC}"
        read -p "Configurar (s/n): " setup_db
        
        if [[ $setup_db =~ ^[Ss]$ ]]; then
            npx prisma generate
            echo -e "${GREEN}✓ Prisma configurado${NC}"
        fi
    fi
}

# Función principal
main() {
    show_banner
    select_project_type
    get_project_details
    
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${CYAN}Creando MVP: $PROJECT_NAME${NC}"
    echo -e "${CYAN}Tipo: $PROJECT_TYPE | Industria: $INDUSTRY${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    
    create_base_structure
    create_package_json
    create_next_config
    create_prisma_config
    create_docker_config
    create_env_files
    generate_main_component
    create_deployment_scripts
    create_readme
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ MVP CREADO EXITOSAMENTE!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}📁 Ubicación: $(pwd)${NC}"
    echo -e "${YELLOW}🔌 Puerto: $PORT${NC}"
    echo ""
    
    install_dependencies
    
    echo ""
    echo -e "${CYAN}🎯 PRÓXIMOS PASOS:${NC}"
    echo "  1. cd $PROJECT_NAME"
    echo "  2. Configurar .env.local"
    echo "  3. npm run dev"
    echo "  4. Abrir http://localhost:$PORT"
    echo ""
    echo -e "${GREEN}🚀 Happy coding!${NC}"
}

# Ejecutar
main
