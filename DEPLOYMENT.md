# 🚀 Zomato Restaurant Predictor - Deployment Guide

This guide covers the complete deployment setup including Docker, Jenkins, and email notifications.

## 📋 Prerequisites

### Required Secrets in GitHub Repository

Add these secrets in your GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

#### DockerHub Credentials
- `DOCKERHUB_USERNAME` - Your DockerHub username
- `DOCKERHUB_TOKEN` - Your DockerHub access token

#### Jenkins Integration
- `JENKINS_URL` - Your Jenkins server URL (e.g., `https://jenkins.example.com`)
- `JENKINS_USER` - Jenkins username
- `JENKINS_TOKEN` - Jenkins API token

#### Email Configuration
- `SMTP_SERVER` - SMTP server address (e.g., `smtp.gmail.com`)
- `SMTP_PORT` - SMTP port (e.g., `587`)
- `SMTP_USERNAME` - Email username
- `SMTP_PASSWORD` - Email password/app password
- `SMTP_FROM` - From email address
- `NOTIFICATION_EMAILS` - Comma-separated list of email addresses

## 🐳 Docker Setup

### Build and Run Locally

```bash
# Build the Docker image
docker build -t zomato-restaurant-predictor .

# Run the container
docker run -p 5000:5000 zomato-restaurant-predictor

# Or use docker-compose
docker-compose up -d
```

### Access the Application

- **Local:** http://localhost:5000
- **With Nginx:** http://localhost:80

## 🔄 CI/CD Pipeline

### Workflow Triggers

1. **Push to `master` branch** → Triggers Docker build and deployment
2. **Manual trigger** → Available via GitHub Actions UI

### Pipeline Steps

1. **Docker Build** → Builds multi-architecture image (AMD64, ARM64)
2. **Push to DockerHub** → Pushes image with tags
3. **Notify Jenkins** → Triggers Jenkins deployment job
4. **Send Email** → Notifies users of deployment status

## 🏗️ Jenkins Setup

### 1. Create Jenkins Job

1. Go to Jenkins dashboard
2. Click "New Item"
3. Choose "Pipeline"
4. Name it `zomato-deploy`

### 2. Configure Pipeline

1. In the job configuration:
   - **Pipeline script from SCM** → Git
   - **Repository URL** → Your GitHub repository
   - **Script Path** → `Jenkinsfile`

### 3. Add Credentials

In Jenkins (`Manage Jenkins` → `Manage Credentials`):

- **dockerhub-credentials** → DockerHub username/password
- **dockerhub-username** → DockerHub username (string)
- **dockerhub-token** → DockerHub token (secret)

### 4. Configure Email

1. Install "Email Extension" plugin
2. Configure SMTP settings in Jenkins system configuration
3. Set `NOTIFICATION_EMAILS` environment variable

## 📧 Email Notifications

### Success Email Includes:
- ✅ Deployment status
- 📊 Build details (commit, branch, timestamp)
- 🔗 Links to GitHub Actions, Docker Hub, and commit
- 📋 Next steps

### Failure Email Includes:
- ❌ Failure status
- 📊 Build details
- 🔗 Links to logs and console output
- 🔧 Troubleshooting steps

## 🚀 Deployment Commands

### Manual Deployment

```bash
# Deploy with specific tag
./deploy.sh v1.0.0

# Deploy latest
./deploy.sh latest
```

### Docker Commands

```bash
# Build image
docker build -t zomato-restaurant-predictor .

# Run container
docker run -d -p 5000:5000 --name zomato-app zomato-restaurant-predictor

# View logs
docker logs zomato-app

# Stop container
docker stop zomato-app

# Remove container
docker rm zomato-app
```

## 🔍 Monitoring and Health Checks

### Health Check Endpoints

- **Application:** http://localhost:5000/
- **Nginx Health:** http://localhost:80/health

### Logs

```bash
# View application logs
docker logs zomato-app

# Follow logs in real-time
docker logs -f zomato-app

# View last 100 lines
docker logs --tail 100 zomato-app
```

## 🛠️ Troubleshooting

### Common Issues

1. **Docker build fails**
   - Check Dockerfile syntax
   - Verify all files are present
   - Check Docker daemon is running

2. **Jenkins notification fails**
   - Verify Jenkins URL and credentials
   - Check Jenkins job exists
   - Verify webhook permissions

3. **Email sending fails**
   - Check SMTP credentials
   - Verify email server settings
   - Check firewall/network restrictions

4. **Application not starting**
   - Check container logs
   - Verify port availability
   - Check environment variables

### Debug Commands

```bash
# Check container status
docker ps -a

# Check container logs
docker logs <container_name>

# Check image details
docker inspect <image_name>

# Check network connectivity
docker network ls
docker network inspect bridge
```

## 📊 Monitoring

### Application Metrics

- **Response Time:** Monitor via health checks
- **Memory Usage:** `docker stats zomato-app`
- **CPU Usage:** `docker stats zomato-app`

### Log Monitoring

- **Application Logs:** Available via `docker logs`
- **Access Logs:** Available via Nginx (if used)
- **Error Logs:** Check application and container logs

## 🔐 Security Considerations

1. **Secrets Management**
   - Use GitHub Secrets for sensitive data
   - Rotate credentials regularly
   - Use least privilege access

2. **Container Security**
   - Use non-root user in container
   - Keep base images updated
   - Scan images for vulnerabilities

3. **Network Security**
   - Use HTTPS in production
   - Configure proper firewall rules
   - Use reverse proxy for SSL termination

## 📈 Scaling

### Horizontal Scaling

```bash
# Scale with docker-compose
docker-compose up -d --scale zomato-app=3

# Use load balancer
# Configure Nginx upstream with multiple instances
```

### Production Considerations

1. **Use orchestration** (Kubernetes, Docker Swarm)
2. **Implement proper logging** (ELK stack, Fluentd)
3. **Add monitoring** (Prometheus, Grafana)
4. **Use secrets management** (HashiCorp Vault, AWS Secrets Manager)
5. **Implement backup strategies**
6. **Use CDN for static assets**

---

## 🎯 Quick Start

1. **Set up secrets** in GitHub repository
2. **Configure Jenkins** job and credentials
3. **Push to master** branch to trigger deployment
4. **Monitor** via email notifications and logs
5. **Access** application at configured URL

For questions or issues, check the logs and refer to the troubleshooting section above.
