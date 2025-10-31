# 🚀 Kubernetes Deployment Guide for Zomato Flask App

This guide provides comprehensive instructions for deploying the Zomato Flask application on Kubernetes using Minikube.

## 📋 Prerequisites

### Required Software:
- **Minikube** - Local Kubernetes cluster
- **kubectl** - Kubernetes command-line tool
- **Docker** - Container runtime
- **Git** - Version control

### Installation Links:
- [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl Installation](https://kubernetes.io/docs/tasks/tools/)
- [Docker Installation](https://docs.docker.com/get-docker/)

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress       │    │   Service       │    │   Deployment    │
│   (nginx)       │───▶│   (ClusterIP)   │───▶│   (3 replicas)  │
│   Port 80       │    │   Port 80       │    │   Port 5000     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       ▼
         │                       │              ┌─────────────────┐
         │                       │              │   Pods          │
         │                       │              │   - Flask App   │
         │                       │              │   - Health      │
         │                       │              │     Checks      │
         │                       │              └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   NodePort      │    │   ConfigMap     │
│   Port 30080    │    │   & Secrets     │
└─────────────────┘    └─────────────────┘
```

## 📁 File Structure

```
k8s/
├── deployment.yaml      # Deployment, ConfigMap, and resource limits
├── service.yaml         # ClusterIP and NodePort services
├── ingress.yaml         # Ingress configuration for external access
├── secret.yaml          # Sensitive configuration data
└── namespace.yaml       # Namespace and resource quotas

scripts/
├── minikube-setup.sh    # Complete deployment script
├── minikube-cleanup.sh  # Cleanup script
└── k8s-utils.sh         # Utility functions for management
```

## 🚀 Quick Start

### 1. Deploy the Application

```bash
# Run the complete setup script
./scripts/minikube-setup.sh
```

This script will:
- ✅ Check prerequisites (Minikube, kubectl, Docker)
- ✅ Start Minikube with required addons
- ✅ Build and load Docker image
- ✅ Deploy all Kubernetes resources
- ✅ Wait for deployment to be ready
- ✅ Show access information

### 2. Access the Application

After deployment, you can access the application via:

#### **NodePort Access (Recommended for testing):**
```bash
# Get Minikube IP and NodePort
minikube ip
kubectl get service zomato-flask-nodeport -n zomato-app

# Access via: http://<MINIKUBE_IP>:30080
```

#### **Port Forward (Local development):**
```bash
kubectl port-forward service/zomato-flask-service 8080:80 -n zomato-app
# Access via: http://localhost:8080
```

#### **Ingress (Production-like):**
```bash
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
<INGRESS_IP> zomato.local

# Access via: http://zomato.local
```

## 🔧 Management Commands

### Using the Utility Script:

```bash
# Show deployment status
./scripts/k8s-utils.sh status

# View logs
./scripts/k8s-utils.sh logs

# Scale deployment
./scripts/k8s-utils.sh scale 5

# Port forward
./scripts/k8s-utils.sh port-forward 3000 80

# Restart deployment
./scripts/k8s-utils.sh restart

# Update image
./scripts/k8s-utils.sh update-image v1.2.3

# Show resource usage
./scripts/k8s-utils.sh resources

# Show access information
./scripts/k8s-utils.sh access
```

### Manual kubectl Commands:

```bash
# Check deployment status
kubectl get all -n zomato-app

# View logs
kubectl logs -f deployment/zomato-flask-app -n zomato-app

# Scale deployment
kubectl scale deployment zomato-flask-app --replicas=5 -n zomato-app

# Port forward
kubectl port-forward service/zomato-flask-service 8080:80 -n zomato-app

# Restart deployment
kubectl rollout restart deployment/zomato-flask-app -n zomato-app

# Update image
kubectl set image deployment/zomato-flask-app zomato-flask-app=masteroz/zomato-flask-app:v1.2.3 -n zomato-app

# Check resource usage
kubectl top pods -n zomato-app
kubectl top nodes
```

## 📊 Monitoring and Debugging

### Health Checks:
- **Liveness Probe**: Checks if the app is running (every 10s)
- **Readiness Probe**: Checks if the app is ready to serve traffic (every 5s)

### Resource Limits:
- **CPU**: 250m request, 500m limit per pod
- **Memory**: 256Mi request, 512Mi limit per pod
- **Replicas**: 3 (configurable)

### Logs and Events:
```bash
# View application logs
kubectl logs -f deployment/zomato-flask-app -n zomato-app

# View events
kubectl get events -n zomato-app --sort-by='.lastTimestamp'

# Describe resources for debugging
kubectl describe deployment zomato-flask-app -n zomato-app
kubectl describe pod <pod-name> -n zomato-app
```

## 🔐 Configuration Management

### ConfigMap:
Contains non-sensitive configuration:
- Application properties
- Nginx configuration
- Environment variables

### Secrets:
Contains sensitive data (base64 encoded):
- Flask secret key
- Database URLs
- API keys

### Environment Variables:
- `FLASK_APP=app.py`
- `FLASK_ENV=production`
- `PYTHONUNBUFFERED=1`

## 🧹 Cleanup

### Complete Cleanup:
```bash
# Run the cleanup script
./scripts/minikube-cleanup.sh
```

### Manual Cleanup:
```bash
# Delete namespace (removes all resources)
kubectl delete namespace zomato-app

# Stop Minikube
minikube stop

# Delete Minikube cluster (optional)
minikube delete
```

## 🔄 CI/CD Integration

### Jenkins Pipeline Integration:
The Kubernetes deployment can be integrated with your existing Jenkins pipeline:

```groovy
stage('Deploy to Kubernetes') {
    steps {
        script {
            // Deploy to Minikube or production Kubernetes
            sh 'kubectl apply -f k8s/'
            sh 'kubectl rollout status deployment/zomato-flask-app -n zomato-app'
        }
    }
}
```

### GitHub Actions Integration:
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl apply -f k8s/
    kubectl rollout status deployment/zomato-flask-app -n zomato-app
```

## 🚨 Troubleshooting

### Common Issues:

#### 1. **Pods not starting:**
```bash
kubectl describe pod <pod-name> -n zomato-app
kubectl logs <pod-name> -n zomato-app
```

#### 2. **Image pull errors:**
```bash
# Ensure image is built and loaded
docker build -t masteroz/zomato-flask-app:latest .
minikube image load masteroz/zomato-flask-app:latest
```

#### 3. **Service not accessible:**
```bash
# Check service endpoints
kubectl get endpoints -n zomato-app
kubectl describe service zomato-flask-service -n zomato-app
```

#### 4. **Ingress not working:**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl describe ingress zomato-flask-ingress -n zomato-app
```

### Debug Commands:
```bash
# Get all resources
kubectl get all -n zomato-app

# Check resource usage
kubectl top pods -n zomato-app

# View events
kubectl get events -n zomato-app

# Check Minikube status
minikube status
minikube dashboard
```

## 📈 Scaling and Performance

### Horizontal Scaling:
```bash
# Scale to 5 replicas
kubectl scale deployment zomato-flask-app --replicas=5 -n zomato-app

# Auto-scaling (requires metrics-server)
kubectl autoscale deployment zomato-flask-app --cpu-percent=70 --min=3 --max=10 -n zomato-app
```

### Resource Optimization:
- Adjust CPU/memory limits in `deployment.yaml`
- Monitor resource usage with `kubectl top`
- Use resource quotas in `namespace.yaml`

## 🎯 Production Considerations

### For Production Deployment:
1. **Use a managed Kubernetes service** (EKS, GKE, AKS)
2. **Set up proper monitoring** (Prometheus, Grafana)
3. **Configure persistent storage** for data
4. **Set up proper secrets management**
5. **Configure network policies**
6. **Set up backup and disaster recovery**

### Security Best Practices:
- Use non-root containers
- Implement network policies
- Regular security scanning
- Secrets management
- RBAC configuration

---

## 🎉 Success!

Your Zomato Flask application is now running on Kubernetes! 

**Quick Access:**
- **NodePort**: `http://<minikube-ip>:30080`
- **Port Forward**: `kubectl port-forward service/zomato-flask-service 8080:80 -n zomato-app`
- **Dashboard**: `minikube dashboard`

**Next Steps:**
- Monitor the application with `./scripts/k8s-utils.sh status`
- Scale as needed with `./scripts/k8s-utils.sh scale 5`
- View logs with `./scripts/k8s-utils.sh logs`

Happy deploying! 🚀
