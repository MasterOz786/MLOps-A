#!/bin/bash

# Kubernetes Utilities Script for Zomato Flask App
# This script provides utility functions for managing the Kubernetes deployment

set -e

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

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    echo "📊 Pods:"
    kubectl get pods -n zomato-app -o wide
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
    
    echo "💾 ConfigMaps:"
    kubectl get configmaps -n zomato-app
    echo ""
    
    echo "🔐 Secrets:"
    kubectl get secrets -n zomato-app
    echo ""
}

# Show logs
show_logs() {
    local pod_name=${1:-""}
    
    if [ -z "$pod_name" ]; then
        print_status "Showing logs for all pods..."
        kubectl logs -f deployment/zomato-flask-app -n zomato-app
    else
        print_status "Showing logs for pod: $pod_name"
        kubectl logs -f "$pod_name" -n zomato-app
    fi
}

# Scale deployment
scale_deployment() {
    local replicas=${1:-3}
    
    print_status "Scaling deployment to $replicas replicas..."
    kubectl scale deployment zomato-flask-app --replicas="$replicas" -n zomato-app
    
    print_success "Deployment scaled to $replicas replicas"
    
    # Wait for scaling to complete
    kubectl rollout status deployment/zomato-flask-app -n zomato-app
}

# Port forward to service
port_forward() {
    local local_port=${1:-8080}
    local service_port=${2:-80}
    
    print_status "Port forwarding from localhost:$local_port to service:$service_port..."
    print_warning "Press Ctrl+C to stop port forwarding"
    
    kubectl port-forward service/zomato-flask-service "$local_port:$service_port" -n zomato-app
}

# Restart deployment
restart_deployment() {
    print_status "Restarting deployment..."
    kubectl rollout restart deployment/zomato-flask-app -n zomato-app
    
    print_success "Deployment restart initiated"
    
    # Wait for rollout to complete
    kubectl rollout status deployment/zomato-flask-app -n zomato-app
}

# Update image
update_image() {
    local image_tag=${1:-latest}
    
    print_status "Updating image to: masteroz/zomato-flask-app:$image_tag..."
    kubectl set image deployment/zomato-flask-app zomato-flask-app=masteroz/zomato-flask-app:"$image_tag" -n zomato-app
    
    print_success "Image update initiated"
    
    # Wait for rollout to complete
    kubectl rollout status deployment/zomato-flask-app -n zomato-app
}

# Show resource usage
show_resources() {
    print_status "Resource Usage:"
    echo ""
    
    echo "📊 Pod Resource Usage:"
    kubectl top pods -n zomato-app
    echo ""
    
    echo "📈 Node Resource Usage:"
    kubectl top nodes
    echo ""
}

# Show events
show_events() {
    print_status "Recent Events:"
    echo ""
    
    kubectl get events -n zomato-app --sort-by='.lastTimestamp' | tail -20
    echo ""
}

# Access application
access_app() {
    print_status "Application Access Information:"
    echo ""
    
    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "Minikube not running")
    echo "🖥️  Minikube IP: $MINIKUBE_IP"
    
    # Get NodePort
    NODEPORT=$(kubectl get service zomato-flask-nodeport -n zomato-app -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "Service not found")
    if [ "$NODEPORT" != "Service not found" ]; then
        echo "🔗 NodePort Access: http://$MINIKUBE_IP:$NODEPORT"
    fi
    
    # Get Ingress IP
    INGRESS_IP=$(kubectl get ingress zomato-flask-ingress -n zomato-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending")
    if [ "$INGRESS_IP" != "Pending" ] && [ "$INGRESS_IP" != "" ]; then
        echo "🌐 Ingress Access: http://$INGRESS_IP"
        echo "🌐 Local Domain: http://zomato.local"
    else
        echo "🌐 Ingress IP: Pending"
    fi
    
    echo ""
    echo "💡 Port Forward: kubectl port-forward service/zomato-flask-service 8080:80 -n zomato-app"
    echo "   Then access: http://localhost:8080"
    echo ""
}

# Show help
show_help() {
    echo "🔧 Kubernetes Utilities for Zomato Flask App"
    echo "============================================="
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  status                    Show deployment status"
    echo "  logs [pod-name]          Show logs (default: all pods)"
    echo "  scale <replicas>         Scale deployment (default: 3)"
    echo "  port-forward [local] [service]  Port forward (default: 8080:80)"
    echo "  restart                  Restart deployment"
    echo "  update-image [tag]       Update image tag (default: latest)"
    echo "  resources                Show resource usage"
    echo "  events                   Show recent events"
    echo "  access                   Show access information"
    echo "  help                     Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 logs"
    echo "  $0 scale 5"
    echo "  $0 port-forward 3000 80"
    echo "  $0 update-image v1.2.3"
    echo ""
}

# Main execution
main() {
    local command=${1:-"help"}
    
    case $command in
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "scale")
            scale_deployment "$2"
            ;;
        "port-forward")
            port_forward "$2" "$3"
            ;;
        "restart")
            restart_deployment
            ;;
        "update-image")
            update_image "$2"
            ;;
        "resources")
            show_resources
            ;;
        "events")
            show_events
            ;;
        "access")
            access_app
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"
