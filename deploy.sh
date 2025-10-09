#!/bin/bash

# Zomato Restaurant Predictor Deployment Script
# This script handles the deployment process

set -e  # Exit on any error

# Configuration
DOCKER_IMAGE="zomato-restaurant-predictor"
DOCKER_TAG="${1:-latest}"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-your-username}"
CONTAINER_NAME="zomato-app"
PORT="5000"

echo "🚀 Starting deployment process..."
echo "📦 Docker Image: ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"

# Function to check if container is running
check_container() {
    if docker ps -q -f name=${CONTAINER_NAME} | grep -q .; then
        return 0
    else
        return 1
    fi
}

# Function to wait for application to be ready
wait_for_app() {
    echo "⏳ Waiting for application to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:${PORT}/ > /dev/null 2>&1; then
            echo "✅ Application is ready!"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts - Application not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ Application failed to start within expected time"
    return 1
}

# Stop and remove existing container if running
if check_container; then
    echo "🛑 Stopping existing container..."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# Pull the latest image
echo "📥 Pulling latest Docker image..."
docker pull ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Run the new container
echo "🏃 Starting new container..."
docker run -d \
    --name ${CONTAINER_NAME} \
    -p ${PORT}:5000 \
    --restart unless-stopped \
    ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Wait for application to be ready
if wait_for_app; then
    echo "🎉 Deployment successful!"
    echo "🌐 Application is available at: http://localhost:${PORT}"
    
    # Show container status
    echo "📊 Container Status:"
    docker ps -f name=${CONTAINER_NAME}
    
    # Show logs
    echo "📋 Recent logs:"
    docker logs --tail 10 ${CONTAINER_NAME}
    
    exit 0
else
    echo "❌ Deployment failed!"
    echo "📋 Container logs:"
    docker logs ${CONTAINER_NAME}
    
    # Clean up failed container
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    
    exit 1
fi
