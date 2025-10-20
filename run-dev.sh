#!/bin/bash

# NT Project - Development Runner Script
# This script runs the application in development mode

set -e

echo "🚀 Starting NT Project in Development Mode..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[DEV]${NC} $1"
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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Starting development environment..."

# Stop any existing containers
print_status "Stopping existing containers..."
docker-compose down > /dev/null 2>&1 || true

# Build and start containers
print_status "Building and starting containers..."
docker-compose up -d --build

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 15

# Check if services are running
print_status "Checking service health..."

# Check MongoDB
if docker-compose exec -T mongo mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    print_success "MongoDB is running"
else
    print_error "MongoDB failed to start"
    exit 1
fi

# Check Backend
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s -f http://localhost:3000/health > /dev/null 2>&1; then
        print_success "Backend API is running"
        break
    fi
    attempt=$((attempt + 1))
    print_status "Waiting for backend... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "Backend failed to start within timeout"
    exit 1
fi

# Check Frontend
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; then
    if curl -s -f http://localhost:3001/health > /dev/null 2>&1; then
        print_success "Frontend is running"
        break
    fi
    attempt=$((attempt + 1))
    print_status "Waiting for frontend... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "Frontend failed to start within timeout"
    exit 1
fi

# Show running containers
print_status "Container status:"
docker-compose ps

echo ""
print_success "🎉 Development environment is ready!"
echo ""
echo "📱 Access URLs:"
echo "   Frontend: http://localhost:3001"
echo "   Backend API: http://localhost:3000"
echo "   API Health: http://localhost:3000/health"
echo "   API Info: http://localhost:3000/api"
echo ""
echo "🔧 Development Commands:"
echo "   View logs: docker-compose logs -f"
echo "   View backend logs: docker-compose logs -f backend"
echo "   View frontend logs: docker-compose logs -f frontend"
echo "   View database logs: docker-compose logs -f mongo"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo ""
echo "🧪 Testing:"
echo "   Run tests: ./test-app.sh"
echo "   Test API: curl http://localhost:3000/api/products"
echo ""
echo "📊 Monitoring:"
echo "   Container status: docker-compose ps"
echo "   Resource usage: docker stats"
echo ""

# Ask if user wants to view logs
read -p "Do you want to view logs? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Showing logs (Press Ctrl+C to exit)..."
    docker-compose logs -f
fi
