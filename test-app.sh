#!/bin/bash

# NT Project - Application Test Script
# This script tests the full-stack application

set -e

echo "🧪 Testing NT Project Application..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Configuration
BACKEND_URL="http://localhost:3000"
FRONTEND_URL="http://localhost:3001"
TIMEOUT=10

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Running: $test_name"
    
    if eval "$test_command"; then
        print_success "$test_name"
        ((TESTS_PASSED++))
    else
        print_error "$test_name"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Function to check if service is running
check_service() {
    local url="$1"
    local service_name="$2"
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        print_success "$service_name is running"
        return 0
    else
        print_error "$service_name is not running"
        return 1
    fi
}

# Function to test API endpoint
test_api_endpoint() {
    local method="$1"
    local endpoint="$2"
    local expected_status="$3"
    local data="$4"
    
    local url="$BACKEND_URL$endpoint"
    local curl_cmd="curl -s -w '%{http_code}' -o /dev/null"
    
    if [ "$method" = "POST" ] || [ "$method" = "PUT" ]; then
        curl_cmd="$curl_cmd -X $method -H 'Content-Type: application/json' -d '$data'"
    else
        curl_cmd="$curl_cmd -X $method"
    fi
    
    curl_cmd="$curl_cmd '$url'"
    
    local status_code=$(eval "$curl_cmd")
    
    if [ "$status_code" = "$expected_status" ]; then
        return 0
    else
        print_error "Expected status $expected_status, got $status_code for $method $endpoint"
        return 1
    fi
}

echo "🔍 Starting application tests..."
echo "=================================="

# Test 1: Check if Docker containers are running
print_status "Checking Docker containers..."
if docker-compose ps | grep -q "Up"; then
    print_success "Docker containers are running"
    docker-compose ps
else
    print_error "Docker containers are not running"
    echo "Please run: docker-compose up -d"
    exit 1
fi
echo ""

# Test 2: Check MongoDB connection
run_test "MongoDB Connection" "docker-compose exec -T mongo mongosh --eval 'db.adminCommand(\"ping\")' > /dev/null 2>&1"

# Test 3: Check Backend Health
run_test "Backend Health Check" "check_service '$BACKEND_URL/health' 'Backend API'"

# Test 4: Check Frontend Health
run_test "Frontend Health Check" "check_service '$FRONTEND_URL/health' 'Frontend'"

# Test 5: Test API Endpoints
print_status "Testing API Endpoints..."

# Test GET /api/products
run_test "GET /api/products" "test_api_endpoint 'GET' '/api/products' '200'"

# Test GET /api/products/categories
run_test "GET /api/products/categories" "test_api_endpoint 'GET' '/api/products/categories' '200'"

# Test POST /api/products
test_product_data='{"name":"Test Product","price":100000,"description":"Test Description","category":"Other"}'
run_test "POST /api/products" "test_api_endpoint 'POST' '/api/products' '201' '$test_product_data'"

# Test 6: Test Frontend Page
run_test "Frontend Page Load" "check_service '$FRONTEND_URL' 'Frontend Page'"

# Test 7: Test Database Operations
print_status "Testing Database Operations..."

# Get a product ID for testing
PRODUCT_ID=$(curl -s "$BACKEND_URL/api/products" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$PRODUCT_ID" ]; then
    # Test GET /api/products/:id
    run_test "GET /api/products/:id" "test_api_endpoint 'GET' '/api/products/$PRODUCT_ID' '200'"
    
    # Test PUT /api/products/:id
    update_data='{"name":"Updated Test Product","price":150000,"description":"Updated Description","category":"Electronics"}'
    run_test "PUT /api/products/:id" "test_api_endpoint 'PUT' '/api/products/$PRODUCT_ID' '200' '$update_data'"
    
    # Test DELETE /api/products/:id
    run_test "DELETE /api/products/:id" "test_api_endpoint 'DELETE' '/api/products/$PRODUCT_ID' '200'"
else
    print_warning "No products found for testing individual product operations"
fi

# Test 8: Test Error Handling
print_status "Testing Error Handling..."

# Test 404 for non-existent product
run_test "404 for non-existent product" "test_api_endpoint 'GET' '/api/products/non-existent-id' '404'"

# Test 400 for invalid data
invalid_data='{"name":"","price":-100,"description":"","category":"InvalidCategory"}'
run_test "400 for invalid data" "test_api_endpoint 'POST' '/api/products' '400' '$invalid_data'"

# Test 9: Performance Test
print_status "Testing Performance..."

# Test response time
response_time=$(curl -s -w '%{time_total}' -o /dev/null "$BACKEND_URL/api/products")
if (( $(echo "$response_time < 1.0" | bc -l) )); then
    print_success "API response time is acceptable: ${response_time}s"
else
    print_warning "API response time is slow: ${response_time}s"
fi

# Test 10: Load Test (simple)
print_status "Running simple load test..."
concurrent_requests=10
successful_requests=0

for i in $(seq 1 $concurrent_requests); do
    if curl -s -f "$BACKEND_URL/api/products" > /dev/null 2>&1; then
        ((successful_requests++))
    fi
done

if [ $successful_requests -eq $concurrent_requests ]; then
    print_success "Load test passed: $successful_requests/$concurrent_requests requests successful"
else
    print_warning "Load test partial: $successful_requests/$concurrent_requests requests successful"
fi

# Test 11: Database Data Integrity
print_status "Testing Database Data Integrity..."

# Check if sample data exists
sample_products=$(curl -s "$BACKEND_URL/api/products" | grep -o '"name":"[^"]*"' | wc -l)
if [ $sample_products -gt 0 ]; then
    print_success "Database contains $sample_products products"
else
    print_warning "Database appears to be empty"
fi

# Test 12: CORS Test
print_status "Testing CORS..."

# Test CORS headers
cors_headers=$(curl -s -I -H "Origin: http://localhost:3001" "$BACKEND_URL/api/products" | grep -i "access-control-allow-origin")
if [ -n "$cors_headers" ]; then
    print_success "CORS headers are present"
else
    print_warning "CORS headers not found"
fi

# Summary
echo "=================================="
echo "📊 Test Summary"
echo "=================================="
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo "📈 Success Rate: $(( TESTS_PASSED * 100 / (TESTS_PASSED + TESTS_FAILED) ))%"

if [ $TESTS_FAILED -eq 0 ]; then
    print_success "🎉 All tests passed! Application is working correctly."
    exit 0
else
    print_error "⚠️  Some tests failed. Please check the issues above."
    exit 1
fi
