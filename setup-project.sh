#!/bin/bash

# NT Project - Complete Setup Script
# This script sets up the entire NT Project from scratch

set -e

echo "🚀 Setting up NT Project - Full Stack Application..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[SETUP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Node.js
if command_exists node; then
    node_version=$(node --version)
    print_success "Node.js is installed: $node_version"
else
    print_error "Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check npm
if command_exists npm; then
    npm_version=$(npm --version)
    print_success "npm is installed: $npm_version"
else
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

# Check Docker
if command_exists docker; then
    docker_version=$(docker --version)
    print_success "Docker is installed: $docker_version"
else
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if command_exists docker-compose; then
    compose_version=$(docker-compose --version)
    print_success "Docker Compose is installed: $compose_version"
else
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check Git
if command_exists git; then
    git_version=$(git --version)
    print_success "Git is installed: $git_version"
else
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

echo ""
print_status "All prerequisites are satisfied! ✅"
echo ""

# Install backend dependencies
print_status "Installing backend dependencies..."
cd backend
if [ -f "package.json" ]; then
    npm install
    print_success "Backend dependencies installed"
else
    print_error "Backend package.json not found"
    exit 1
fi
cd ..

# Install frontend dependencies
print_status "Installing frontend dependencies..."
cd frontend
if [ -f "package.json" ]; then
    npm install
    print_success "Frontend dependencies installed"
else
    print_error "Frontend package.json not found"
    exit 1
fi
cd ..

# Make scripts executable
print_status "Making scripts executable..."
chmod +x *.sh
chmod +x backend/*.sh 2>/dev/null || true
chmod +x frontend/*.sh 2>/dev/null || true

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    print_status "Creating .env file..."
    cat > .env << EOF
# Docker Configuration
DOCKER_USERNAME=nt-project

# Database Configuration
MONGODB_URI=mongodb://mongo:27017/nt_project
DB_NAME=nt_project

# Server Configuration
NODE_ENV=development
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

# Initialize Git repository if not already initialized
if [ ! -d ".git" ]; then
    print_status "Initializing Git repository..."
    git init
    print_success "Git repository initialized"
else
    print_warning "Git repository already initialized"
fi

# Add .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    print_warning ".gitignore not found, but it should be created"
fi

# Test Docker setup
print_status "Testing Docker setup..."
if docker info > /dev/null 2>&1; then
    print_success "Docker is running"
else
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Build Docker images
print_status "Building Docker images..."
docker-compose build

# Start services
print_status "Starting services..."
docker-compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 20

# Health check
print_status "Performing health checks..."

# Check MongoDB
if docker-compose exec -T mongo mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    print_success "MongoDB is healthy"
else
    print_error "MongoDB health check failed"
fi

# Check Backend
max_attempts=30
attempt=0
backend_healthy=false
while [ $attempt -lt $max_attempts ]; do
    if curl -s -f http://localhost:3000/health > /dev/null 2>&1; then
        print_success "Backend API is healthy"
        backend_healthy=true
        break
    fi
    attempt=$((attempt + 1))
    print_status "Waiting for backend... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ "$backend_healthy" = false ]; then
    print_error "Backend health check failed"
fi

# Check Frontend
max_attempts=30
attempt=0
frontend_healthy=false
while [ $attempt -lt $max_attempts ]; do
    if curl -s -f http://localhost:3001/health > /dev/null 2>&1; then
        print_success "Frontend is healthy"
        frontend_healthy=true
        break
    fi
    attempt=$((attempt + 1))
    print_status "Waiting for frontend... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ "$frontend_healthy" = false ]; then
    print_error "Frontend health check failed"
fi

# Show container status
print_status "Container status:"
docker-compose ps

echo ""
print_success "🎉 NT Project setup completed!"
echo ""
echo "📱 Access URLs:"
echo "   Frontend: http://localhost:3001"
echo "   Backend API: http://localhost:3000"
echo "   API Health: http://localhost:3000/health"
echo "   API Info: http://localhost:3000/api"
echo ""
echo "🔧 Management Commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo "   Run tests: ./test-app.sh"
echo "   Deploy to Git: ./deploy-git.sh"
echo ""
echo "📚 Documentation:"
echo "   README: README-NEW.md"
echo "   Deployment Guide: DEPLOYMENT-GUIDE.md"
echo ""

# Ask if user wants to run tests
read -p "Do you want to run tests now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Running tests..."
    ./test-app.sh
fi

# Ask if user wants to view logs
read -p "Do you want to view logs? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Showing logs (Press Ctrl+C to exit)..."
    docker-compose logs -f
fi

print_success "Setup completed successfully! 🚀"
