# 🏗️ Jenkins Pipeline Setup Guide

This guide will help you set up Jenkins to automatically execute the deployment pipeline when there's a new commit on the master branch.

## 📋 Prerequisites

- Jenkins server running (local or cloud)
- Docker installed on Jenkins server
- GitHub repository with the project
- DockerHub account

## 🔧 Jenkins Configuration

### 1. Install Required Plugins

In Jenkins, go to **Manage Jenkins** → **Manage Plugins** and install:

- **GitHub Integration Plugin**
- **Docker Pipeline Plugin**
- **Email Extension Plugin**
- **Build Pipeline Plugin**
- **Parameterized Trigger Plugin**

### 2. Create Jenkins Job

1. Go to **New Item** in Jenkins
2. Enter job name: `zomato-deploy`
3. Select **Pipeline** type
4. Click **OK**

### 3. Configure Pipeline Job

#### General Settings:
- ✅ **GitHub project**: `https://github.com/MasterOz786/MLOps-A`
- ✅ **This project is parameterized**:
  - `DOCKER_IMAGE` (String): `masteroz/zomato-price-prediction`
  - `DOCKER_TAG` (String): `latest`
  - `GITHUB_SHA` (String): ``
  - `GITHUB_REF` (String): ``
  - `BUILD_CAUSE` (String): `GitHub Actions`

#### Pipeline Configuration:
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/MasterOz786/MLOps-A.git`
- **Branch**: `*/master`
- **Script Path**: `Jenkinsfile`

#### Build Triggers:
- ✅ **GitHub hook trigger for GITScm polling**
- ✅ **Trigger builds remotely** (Authentication Token: `your-secure-token`)

### 4. Configure Credentials

Go to **Manage Jenkins** → **Manage Credentials** and add:

#### DockerHub Credentials:
- **Kind**: Username with password
- **ID**: `dockerhub-credentials`
- **Username**: Your DockerHub username
- **Password**: Your DockerHub access token

#### SMTP Credentials (for email notifications):
- **Kind**: Username with password
- **ID**: `smtp-credentials`
- **Username**: Your SMTP username
- **Password**: Your SMTP password

### 5. Configure Email Notifications

Go to **Manage Jenkins** → **Configure System**:

#### SMTP Server:
- **SMTP server**: `smtp.gmail.com` (or your SMTP server)
- **Default user e-mail suffix**: `@yourdomain.com`
- **Use SMTP Authentication**: ✅
- **User Name**: Your email
- **Password**: Your email password
- **Use SSL**: ✅
- **SMTP Port**: `587`

## 🔐 GitHub Secrets Setup

In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions** and add:

```
JENKINS_URL=https://your-jenkins-server.com
JENKINS_USER=your-jenkins-username
JENKINS_TOKEN=your-jenkins-api-token
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-dockerhub-access-token
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-email-password
SMTP_FROM=your-email@gmail.com
NOTIFICATION_EMAILS=recipient1@example.com,recipient2@example.com
```

## 🚀 Testing the Pipeline

### 1. Test Jenkins Webhook

Run the test script:
```bash
./test-jenkins-webhook.sh
```

### 2. Test GitHub Integration

1. Make a small change to any file
2. Commit and push to master:
   ```bash
   git add .
   git commit -m "test: trigger Jenkins pipeline"
   git push origin master
   ```

### 3. Monitor the Pipeline

- **GitHub Actions**: Check the Actions tab in your repository
- **Jenkins**: Check the Jenkins dashboard for the running job
- **Email**: Check for deployment notification emails

## 🔄 Pipeline Flow

1. **Push to master** → Triggers GitHub Actions
2. **GitHub Actions** → Builds Docker image and pushes to DockerHub
3. **GitHub Actions** → Notifies Jenkins via webhook
4. **Jenkins** → Executes deployment pipeline
5. **Jenkins** → Sends email notifications

## 🛠️ Troubleshooting

### Common Issues:

#### 1. Jenkins Webhook Not Triggering
- Check Jenkins URL in GitHub secrets
- Verify Jenkins job has "GitHub hook trigger" enabled
- Check Jenkins logs for webhook errors

#### 2. Docker Build Fails
- Ensure Docker is installed on Jenkins server
- Check DockerHub credentials
- Verify Dockerfile syntax

#### 3. Email Notifications Not Working
- Check SMTP configuration in Jenkins
- Verify email credentials
- Test SMTP connection

#### 4. GitHub Actions Fails
- Check all required secrets are set
- Verify repository permissions
- Check GitHub Actions logs

### Debug Commands:

```bash
# Test Jenkins connectivity
curl -u $JENKINS_USER:$JENKINS_TOKEN $JENKINS_URL/api/json

# Test DockerHub connectivity
docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN

# Test SMTP connectivity
telnet $SMTP_SERVER $SMTP_PORT
```

## 📊 Monitoring

### Jenkins Dashboard:
- View build history
- Monitor build logs
- Check build status

### GitHub Actions:
- View workflow runs
- Check build logs
- Monitor deployment status

### Email Notifications:
- Success/failure notifications
- Build details and links
- Deployment status updates

## 🎯 Success Criteria

The pipeline is working correctly when:

1. ✅ Push to master triggers GitHub Actions
2. ✅ Docker image builds and pushes to DockerHub
3. ✅ Jenkins receives webhook and starts deployment
4. ✅ Jenkins pipeline completes successfully
5. ✅ Email notifications are sent
6. ✅ Application is deployed and accessible

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review Jenkins and GitHub Actions logs
3. Verify all credentials and secrets are correct
4. Test individual components (Docker, SMTP, etc.)

---

**🎉 Once set up, every push to master will automatically trigger the complete deployment pipeline!**
