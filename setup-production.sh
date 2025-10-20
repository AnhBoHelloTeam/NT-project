#!/bin/bash

# NT Project - Production Setup Script
# This script prepares the project for production deployment

set -e

echo "🔧 Setting up NT Project for production..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_status "Creating .env file..."
    cat > .env << EOF
# Docker Configuration
DOCKER_USERNAME=nt-project

# Database Configuration
MONGODB_URI=mongodb://mongo:27017/nt_project
DB_NAME=nt_project

# Server Configuration
NODE_ENV=production
PORT=3000

# Frontend Configuration
FRONTEND_URL=http://localhost:3001

# JWT Configuration
JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF
    print_success ".env file created"
else
    print_warning ".env file already exists, skipping creation"
fi

# Create production docker-compose override
print_status "Creating production docker-compose override..."
cat > docker-compose.prod.yml << EOF
version: '3.8'

services:
  backend:
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/nt_project
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  frontend:
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  mongo:
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# Create nginx reverse proxy configuration
print_status "Creating nginx reverse proxy configuration..."
mkdir -p nginx
cat > nginx/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3000;
    }

    upstream frontend {
        server frontend:80;
    }

    server {
        listen 80;
        server_name localhost;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }

        # Health checks
        location /health {
            proxy_pass http://backend/health;
        }
    }
}
EOF

# Create production docker-compose with nginx
print_status "Creating production docker-compose with nginx..."
cat > docker-compose.nginx.yml << EOF
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    container_name: nt-project-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend
      - frontend
    networks:
      - app-network
    restart: always

  # Include all services from main docker-compose.yml
  mongo:
    image: mongo:7.0
    container_name: nt-project-mongo
    environment:
      - MONGO_INITDB_DATABASE=nt_project
    volumes:
      - mongo_data:/data/db
      - ./database/init:/docker-entrypoint-initdb.d
    networks:
      - app-network
    restart: always

  backend:
    build: 
      context: ./backend
      dockerfile: Dockerfile
    image: \${DOCKER_USERNAME:-nt-project}/backend:latest
    container_name: nt-project-backend
    environment:
      - NODE_ENV=production
      - PORT=3000
      - MONGODB_URI=mongodb://mongo:27017/nt_project
      - FRONTEND_URL=http://localhost
    depends_on:
      mongo:
        condition: service_healthy
    networks:
      - app-network
    restart: always

  frontend:
    build: 
      context: ./frontend
      dockerfile: Dockerfile
    image: \${DOCKER_USERNAME:-nt-project}/frontend:latest
    container_name: nt-project-frontend
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - app-network
    restart: always

volumes:
  mongo_data:

networks:
  app-network:
    driver: bridge
EOF

# Create monitoring script
print_status "Creating monitoring script..."
cat > monitor.sh << 'EOF'
#!/bin/bash

echo "📊 NT Project Monitoring Dashboard"
echo "=================================="

echo ""
echo "🐳 Container Status:"
docker-compose ps

echo ""
echo "💾 Resource Usage:"
docker stats --no-stream

echo ""
echo "🔍 Service Health:"
echo "Backend API: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health || echo "DOWN")"
echo "Frontend: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health || echo "DOWN")"

echo ""
echo "📈 Logs (last 10 lines):"
echo "Backend:"
docker-compose logs --tail=10 backend

echo ""
echo "Frontend:"
docker-compose logs --tail=10 frontend

echo ""
echo "Database:"
docker-compose logs --tail=10 mongo
EOF
chmod +x monitor.sh

# Create backup script
print_status "Creating backup script..."
cat > backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "💾 Creating backup..."

# Backup database
docker-compose exec -T mongo mongodump --db nt_project --archive | gzip > $BACKUP_DIR/mongodb_backup_$DATE.gz

# Backup application files
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz --exclude=node_modules --exclude=.git .

echo "✅ Backup completed: $BACKUP_DIR/app_backup_$DATE.tar.gz"
echo "✅ Database backup: $BACKUP_DIR/mongodb_backup_$DATE.gz"
EOF
chmod +x backup.sh

# Create restore script
print_status "Creating restore script..."
cat > restore.sh << 'EOF'
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 backups/app_backup_20231201_120000.tar.gz"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "🔄 Restoring from backup: $BACKUP_FILE"

# Stop services
docker-compose down

# Restore application files
tar -xzf $BACKUP_FILE

# Start services
docker-compose up -d

echo "✅ Restore completed!"
EOF
chmod +x restore.sh

# Create README for production
print_status "Creating production README..."
cat > README-PRODUCTION.md << 'EOF'
# NT Project - Production Deployment

## Quick Start

1. **Setup for production:**
   ```bash
   ./setup-production.sh
   ```

2. **Deploy with nginx reverse proxy:**
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.nginx.yml up -d
   ```

3. **Deploy without nginx (direct access):**
   ```bash
   docker-compose up -d
   ```

## Management Commands

- **View logs:** `docker-compose logs -f`
- **Monitor services:** `./monitor.sh`
- **Backup data:** `./backup.sh`
- **Restore data:** `./restore.sh <backup_file>`
- **Update application:** `docker-compose pull && docker-compose up -d`

## Access URLs

- **With nginx:** http://localhost (port 80)
- **Direct access:**
  - Frontend: http://localhost:3001
  - Backend API: http://localhost:3000

## Environment Variables

Create a `.env` file with the following variables:

```env
DOCKER_USERNAME=your-docker-username
MONGODB_URI=mongodb://mongo:27017/nt_project
NODE_ENV=production
JWT_SECRET=your-secret-key
```

## Security Notes

- Change default JWT secret in production
- Use HTTPS in production
- Configure firewall properly
- Regular backups recommended
- Monitor logs for security issues

## Troubleshooting

1. **Check container status:** `docker-compose ps`
2. **View logs:** `docker-compose logs <service_name>`
3. **Restart services:** `docker-compose restart`
4. **Health checks:** `curl http://localhost:3000/health`
EOF

print_success "Production setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Review and update .env file with your configuration"
echo "2. Run: docker-compose up -d (for direct access)"
echo "3. Or run: docker-compose -f docker-compose.yml -f docker-compose.nginx.yml up -d (with nginx)"
echo "4. Use ./monitor.sh to check service status"
echo ""
print_success "Setup completed successfully! 🎉"
