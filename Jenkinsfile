pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'zomato-restaurant-predictor'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'docker.io'
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_TOKEN = credentials('dockerhub-token')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out code from ${env.GIT_URL}"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def image = docker.build("${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}")
                    echo "Built Docker image: ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'dockerhub-credentials') {
                        def image = docker.image("${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}")
                        image.push()
                        image.push('latest')
                        echo "Pushed image to DockerHub: ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
        
        stage('Deploy to Production') {
            steps {
                script {
                    // Deploy to your production environment
                    // This could be Kubernetes, Docker Swarm, or any other orchestration
                    echo "Deploying ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG} to production..."
                    
                    // Example: Deploy to Kubernetes
                    // sh "kubectl set image deployment/zomato-app zomato-app=${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    
                    // Example: Deploy with Docker Compose
                    // sh "docker-compose pull && docker-compose up -d"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    // Wait for deployment to be ready
                    sleep(time: 30, unit: 'SECONDS')
                    
                    // Perform health check
                    sh """
                        # Check if the application is responding
                        curl -f http://localhost:5000/ || exit 1
                        echo "Health check passed!"
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images to save space
            sh "docker image prune -f"
        }
        
        success {
            // Send success notification
            emailext (
                subject: "✅ Zomato App Deployment Successful - Build #${env.BUILD_NUMBER}",
                body: """
                <h2>🚀 Deployment Successful!</h2>
                
                <h3>📊 Build Details</h3>
                <ul>
                    <li><strong>Build Number:</strong> ${env.BUILD_NUMBER}</li>
                    <li><strong>Docker Image:</strong> ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}</li>
                    <li><strong>Git Commit:</strong> ${env.GIT_COMMIT}</li>
                    <li><strong>Branch:</strong> ${env.GIT_BRANCH}</li>
                    <li><strong>Build Time:</strong> ${new Date()}</li>
                </ul>
                
                <h3>🔗 Links</h3>
                <ul>
                    <li><a href="${env.BUILD_URL}">Jenkins Build</a></li>
                    <li><a href="https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}">Docker Hub</a></li>
                </ul>
                
                <p><strong>Status:</strong> ✅ Application deployed successfully and is running!</p>
                """,
                mimeType: 'text/html',
                to: "${env.NOTIFICATION_EMAILS}"
            )
        }
        
        failure {
            // Send failure notification
            emailext (
                subject: "❌ Zomato App Deployment Failed - Build #${env.BUILD_NUMBER}",
                body: """
                <h2>❌ Deployment Failed!</h2>
                
                <h3>📊 Build Details</h3>
                <ul>
                    <li><strong>Build Number:</strong> ${env.BUILD_NUMBER}</li>
                    <li><strong>Git Commit:</strong> ${env.GIT_COMMIT}</li>
                    <li><strong>Branch:</strong> ${env.GIT_BRANCH}</li>
                    <li><strong>Build Time:</strong> ${new Date()}</li>
                </ul>
                
                <h3>🔗 Links</h3>
                <ul>
                    <li><a href="${env.BUILD_URL}">Jenkins Build Log</a></li>
                    <li><a href="${env.BUILD_URL}console">Console Output</a></li>
                </ul>
                
                <p><strong>Status:</strong> ❌ Deployment failed. Please check the logs and fix the issues.</p>
                
                <h3>🔧 Next Steps</h3>
                <ol>
                    <li>Check the Jenkins build logs</li>
                    <li>Verify Docker image build</li>
                    <li>Check deployment configuration</li>
                    <li>Retry the deployment after fixing issues</li>
                </ol>
                """,
                mimeType: 'text/html',
                to: "${env.NOTIFICATION_EMAILS}"
            )
        }
    }
}
