#!/bin/bash

# Minikube Cleanup Script for Zomato Flask App
# This script cleans up the Minikube deployment

set -e

echo "🧹 Starting Minikube cleanup for Zomato Flask App..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Clean up Kubernetes resources
cleanup_k8s() {
    print_status "Cleaning up Kubernetes resources..."
    
    # Delete namespace (this will delete all resources in the namespace)
    kubectl delete namespace zomato-app --ignore-not-found=true
    print_success "Namespace and all resources deleted"
}

# Clean up Minikube
cleanup_minikube() {
    print_status "Cleaning up Minikube..."
    
    # Stop Minikube
    minikube stop
    print_success "Minikube stopped"
    
    # Delete Minikube cluster (optional - uncomment if you want to completely remove Minikube)
    # minikube delete
    # print_success "Minikube cluster deleted"
}

# Clean up Docker images
cleanup_docker() {
    print_status "Cleaning up Docker images..."
    
    # Remove the application image
    docker rmi masteroz/zomato-flask-app:latest --force 2>/dev/null || true
    print_success "Docker images cleaned up"
}

# Show cleanup status
show_cleanup_status() {
    print_status "Cleanup Status:"
    echo ""
    
    echo "📊 Checking remaining resources..."
    
    # Check if namespace still exists
    if kubectl get namespace zomato-app &> /dev/null; then
        print_warning "Namespace 'zomato-app' still exists"
    else
        print_success "Namespace 'zomato-app' deleted"
    fi
    
    # Check Minikube status
    if minikube status &> /dev/null; then
        print_warning "Minikube is still running"
    else
        print_success "Minikube is stopped"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "🧹 Zomato Flask App - Minikube Cleanup"
    echo "======================================"
    echo ""
    
    # Ask for confirmation
    read -p "Are you sure you want to clean up the Zomato Flask App deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    cleanup_k8s
    cleanup_minikube
    cleanup_docker
    show_cleanup_status
    
    print_success "🎉 Cleanup completed successfully!"
    echo ""
    echo "💡 To redeploy, run: ./scripts/minikube-setup.sh"
}

# Run main function
main "$@"
