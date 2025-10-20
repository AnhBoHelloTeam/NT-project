#!/bin/bash

# NT Project - Ubuntu VM Deployment Script
# This script sets up the NT Project on Ubuntu VM

set -e

echo "🚀 Starting NT Project deployment on Ubuntu VM..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/opt/nt-project"
DOCKER_USERNAME="${DOCKER_USERNAME:-nt-project}"
DOMAIN="${DOMAIN:-localhost}"

# Function to print colored output
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    print_success "Docker installed successfully"
else
    print_success "Docker is already installed"
fi

# Install Docker Compose
print_status "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose installed successfully"
else
    print_success "Docker Compose is already installed"
fi

# Create project directory
print_status "Creating project directory..."
sudo mkdir -p $PROJECT_DIR
sudo chown $USER:$USER $PROJECT_DIR

# Copy project files
print_status "Copying project files..."
cp -r . $PROJECT_DIR/
cd $PROJECT_DIR

# Create environment file
print_status "Creating environment configuration..."
cat > .env << EOF
# Docker Configuration
DOCKER_USERNAME=$DOCKER_USERNAME

# Database Configuration
MONGODB_URI=mongodb://mongo:27017/nt_project
DB_NAME=nt_project

# Server Configuration
NODE_ENV=production
PORT=3000

# Frontend Configuration
FRONTEND_URL=http://$DOMAIN:3001

# JWT Configuration
JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=7d
EOF

# Set up firewall
print_status "Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 3000/tcp # Backend API
sudo ufw allow 3001/tcp # Frontend
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw --force enable

# Create systemd service for auto-start
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/nt-project.service > /dev/null << EOF
[Unit]
Description=NT Project Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable nt-project.service

# Pull and start containers
print_status "Pulling Docker images..."
docker-compose pull

print_status "Starting application containers..."
docker-compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Health check
print_status "Performing health checks..."

# Check MongoDB
if docker-compose exec -T mongo mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    print_success "MongoDB is healthy"
else
    print_error "MongoDB health check failed"
    exit 1
fi

# Check Backend
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    print_success "Backend API is healthy"
else
    print_error "Backend API health check failed"
    exit 1
fi

# Check Frontend
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    print_success "Frontend is healthy"
else
    print_error "Frontend health check failed"
    exit 1
fi

# Show running containers
print_status "Application containers status:"
docker-compose ps

# Show access information
print_success "🎉 NT Project deployed successfully!"
echo ""
echo "📱 Access URLs:"
echo "   Frontend: http://$DOMAIN:3001"
echo "   Backend API: http://$DOMAIN:3000"
echo "   API Health: http://$DOMAIN:3000/health"
echo ""
echo "🔧 Management Commands:"
echo "   View logs: cd $PROJECT_DIR && docker-compose logs -f"
echo "   Restart: cd $PROJECT_DIR && docker-compose restart"
echo "   Stop: cd $PROJECT_DIR && docker-compose down"
echo "   Update: cd $PROJECT_DIR && docker-compose pull && docker-compose up -d"
echo ""
echo "📊 Monitoring:"
echo "   Container status: docker-compose ps"
echo "   Resource usage: docker stats"
echo "   System service: sudo systemctl status nt-project"
echo ""

# Create update script
print_status "Creating update script..."
cat > update.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating NT Project..."
cd /opt/nt-project
docker-compose pull
docker-compose down
docker-compose up -d
docker image prune -f
echo "✅ Update completed!"
EOF
chmod +x update.sh

print_success "Update script created at $PROJECT_DIR/update.sh"
print_success "Deployment completed successfully! 🎉"
