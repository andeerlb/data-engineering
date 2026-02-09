#!/bin/bash

set -e

echo "Setting up Apache Airflow - Dynamic DAGs"
echo "=============================================="
echo ""

# Output colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Docker
echo "Checking Docker..."
if ! command_exists docker; then
    echo -e "${RED}✗ Docker not found. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

# Check Docker Compose
echo "Checking Docker Compose..."
if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    echo -e "${GREEN}✓ Docker Compose V2 (plugin) found${NC}"
elif command_exists docker-compose; then
    COMPOSE_CMD="docker-compose"
    echo -e "${YELLOW}⚠ Using Docker Compose V1 (standalone)${NC}"
else
    echo -e "${RED}✗ Docker Compose not found${NC}"
    exit 1
fi

# Check if sudo is required
if docker ps >/dev/null 2>&1; then
    DOCKER_SUDO=""
    echo -e "${GREEN}✓ Docker accessible without sudo${NC}"
else
    DOCKER_SUDO="sudo"
    echo -e "${YELLOW}⚠ Docker requires sudo${NC}"
fi

# Check ports
echo "Checking ports..."
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${YELLOW}⚠ Port $port is already in use${NC}"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Port $port available${NC}"
    fi
}

check_port 8080
check_port 5432

# Create directory structure
echo "Creating directory structure..."
mkdir -p dags/configs logs plugins config
echo -e "${GREEN}✓ Directories created${NC}"

# Create .env file if it does not exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat > .env << EOF
AIRFLOW_UID=$(id -u)
_AIRFLOW_WWW_USER_USERNAME=admin
_AIRFLOW_WWW_USER_PASSWORD=admin123
EOF
    echo -e "${GREEN}✓ .env file created${NC}"
else
    echo -e "${YELLOW}⚠ .env file already exists, keeping current settings${NC}"
fi

# Initialize Airflow
echo ""
echo "Initializing Airflow..."
echo ""

# Build image
echo "Building Docker image..."
$DOCKER_SUDO $COMPOSE_CMD build
echo -e "${GREEN}✓ Image built${NC}"

# Initialize database
echo "Initializing database..."
$DOCKER_SUDO $COMPOSE_CMD up airflow-init
echo -e "${GREEN}✓ Database initialized${NC}"

# Start services
echo "Starting services..."
$DOCKER_SUDO $COMPOSE_CMD up
echo -e "${GREEN}✓ Services started${NC}"

# Wait for services to be ready
echo ""
echo "Waiting for services to be ready..."
sleep 10

# Check status
echo ""
echo "Service status:"
$DOCKER_SUDO $COMPOSE_CMD ps

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Access Airflow at: http://localhost:8080"
echo "Username: admin"
echo "Password: admin123 (or as defined in .env)"
echo ""
echo "Useful commands:"
echo "  - View logs: $COMPOSE_CMD logs -f"
echo "  - Stop services: $COMPOSE_CMD down"
echo "  - Restart scheduler: $COMPOSE_CMD restart airflow-scheduler"
echo ""