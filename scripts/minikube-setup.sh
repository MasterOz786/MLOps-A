#!/bin/bash

# Minikube Setup Script for Zomato Flask App
# This script sets up Minikube and deploys the Zomato Flask application

set -e

echo "🚀 Starting Minikube setup for Zomato Flask App..."

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

# Check if Minikube is installed
check_minikube() {
    print_status "Checking Minikube installation..."
    if ! command -v minikube &> /dev/null; then
        print_error "Minikube is not installed. Please install Minikube first."
        echo "Installation guide: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
    fi
    print_success "Minikube is installed"
}

# Check if kubectl is installed
check_kubectl() {
    print_status "Checking kubectl installation..."
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        echo "Installation guide: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    print_success "kubectl is installed"
}

# Start Minikube
start_minikube() {
    print_status "Starting Minikube..."
    
    # Check if Minikube is already running
    if minikube status &> /dev/null; then
        print_warning "Minikube is already running"
        return 0
    fi
    
    # Start Minikube with specific configuration
    minikube start \
        --driver=docker \
        --memory=4096 \
        --cpus=2 \
        --disk-size=20g \
        --addons=ingress \
        --addons=metrics-server
    
    print_success "Minikube started successfully"
}

# Enable required addons
enable_addons() {
    print_status "Enabling required addons..."
    
    # Enable ingress addon
    minikube addons enable ingress
    print_success "Ingress addon enabled"
    
    # Enable metrics-server
    minikube addons enable metrics-server
    print_success "Metrics-server addon enabled"
    
    # Enable dashboard (optional)
    minikube addons enable dashboard
    print_success "Dashboard addon enabled"
}

# Build and load Docker image
build_and_load_image() {
    print_status "Building and loading Docker image..."
    
    # Build the Docker image
    docker build -t masteroz/zomato-flask-app:latest .
    
    # Load image into Minikube
    minikube image load masteroz/zomato-flask-app:latest
    
    print_success "Docker image built and loaded into Minikube"
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_status "Deploying to Kubernetes..."
    
    # Create namespace
    kubectl apply -f k8s/namespace.yaml
    print_success "Namespace created"
    
    # Create secrets
    kubectl apply -f k8s/secret.yaml
    print_success "Secrets created"
    
    # Deploy application
    kubectl apply -f k8s/deployment.yaml
    print_success "Deployment created"
    
    # Create services
    kubectl apply -f k8s/service.yaml
    print_success "Services created"
    
    # Create ingress
    kubectl apply -f k8s/ingress.yaml
    print_success "Ingress created"
}

# Wait for deployment to be ready
wait_for_deployment() {
    print_status "Waiting for deployment to be ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/zomato-flask-app -n zomato-app
    
    print_success "Deployment is ready"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    echo "📊 Pods:"
    kubectl get pods -n zomato-app
    echo ""
    
    echo "🌐 Services:"
    kubectl get services -n zomato-app
    echo ""
    
    echo "🚪 Ingress:"
    kubectl get ingress -n zomato-app
    echo ""
    
    echo "📈 Deployment:"
    kubectl get deployment -n zomato-app
    echo ""
}

# Show access information
show_access_info() {
    print_status "Access Information:"
    echo ""
    
    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip)
    echo "🖥️  Minikube IP: $MINIKUBE_IP"
    
    # Get NodePort
    NODEPORT=$(kubectl get service zomato-flask-nodeport -n zomato-app -o jsonpath='{.spec.ports[0].nodePort}')
    echo "🔗 NodePort Access: http://$MINIKUBE_IP:$NODEPORT"
    
    # Get Ingress IP (if available)
    INGRESS_IP=$(kubectl get ingress zomato-flask-ingress -n zomato-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending")
    if [ "$INGRESS_IP" != "Pending" ] && [ "$INGRESS_IP" != "" ]; then
        echo "🌐 Ingress Access: http://$INGRESS_IP"
        echo "🌐 Local Domain: http://zomato.local (add to /etc/hosts: $INGRESS_IP zomato.local)"
    else
        echo "🌐 Ingress IP: Pending (check with 'kubectl get ingress -n zomato-app')"
    fi
    
    echo ""
    echo "📋 Useful Commands:"
    echo "  View logs: kubectl logs -f deployment/zomato-flask-app -n zomato-app"
    echo "  Scale deployment: kubectl scale deployment zomato-flask-app --replicas=5 -n zomato-app"
    echo "  Port forward: kubectl port-forward service/zomato-flask-service 8080:80 -n zomato-app"
    echo "  Minikube dashboard: minikube dashboard"
    echo "  Delete deployment: kubectl delete namespace zomato-app"
    echo ""
}

# Main execution
main() {
    echo "🎯 Zomato Flask App - Minikube Deployment"
    echo "=========================================="
    echo ""
    
    check_minikube
    check_kubectl
    start_minikube
    enable_addons
    build_and_load_image
    deploy_to_k8s
    wait_for_deployment
    show_status
    show_access_info
    
    print_success "🎉 Zomato Flask App deployed successfully on Minikube!"
    echo ""
    echo "🚀 Your application is now running on Kubernetes!"
}

# Run main function
main "$@"
