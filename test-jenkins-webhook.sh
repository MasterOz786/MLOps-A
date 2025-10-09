#!/bin/bash

# Test Jenkins Webhook Script
# This script tests the Jenkins webhook integration

echo "🧪 Testing Jenkins Webhook Integration..."

# Configuration
JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JENKINS_JOB="zomato-deploy"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_TOKEN="${JENKINS_TOKEN:-your-token}"

echo "📋 Configuration:"
echo "  Jenkins URL: $JENKINS_URL"
echo "  Job Name: $JENKINS_JOB"
echo "  User: $JENKINS_USER"
echo ""

# Test 1: Check if Jenkins is accessible
echo "🔍 Test 1: Checking Jenkins accessibility..."
if curl -s -f "$JENKINS_URL/api/json" > /dev/null; then
    echo "✅ Jenkins is accessible"
else
    echo "❌ Jenkins is not accessible at $JENKINS_URL"
    echo "   Please check your Jenkins URL and ensure Jenkins is running"
    exit 1
fi

# Test 2: Check if the job exists
echo ""
echo "🔍 Test 2: Checking if job '$JENKINS_JOB' exists..."
JOB_URL="$JENKINS_URL/job/$JENKINS_JOB"
if curl -s -f -u "$JENKINS_USER:$JENKINS_TOKEN" "$JOB_URL/api/json" > /dev/null; then
    echo "✅ Job '$JENKINS_JOB' exists"
else
    echo "❌ Job '$JENKINS_JOB' not found"
    echo "   Please create the job in Jenkins or update the job name"
    exit 1
fi

# Test 3: Trigger the job
echo ""
echo "🔍 Test 3: Triggering Jenkins job..."
TRIGGER_URL="$JENKINS_URL/job/$JENKINS_JOB/buildWithParameters"
RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -u "$JENKINS_USER:$JENKINS_TOKEN" \
    -d "DOCKER_IMAGE=test-image" \
    -d "DOCKER_TAG=test-tag" \
    -d "GITHUB_SHA=test-sha" \
    -d "GITHUB_REF=refs/heads/master" \
    -d "BUILD_CAUSE=Manual%20Test" \
    "$TRIGGER_URL")

HTTP_CODE="${RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Jenkins job triggered successfully (HTTP $HTTP_CODE)"
else
    echo "❌ Failed to trigger Jenkins job (HTTP $HTTP_CODE)"
    echo "   Response: ${RESPONSE%???}"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Jenkins webhook integration is working correctly."
echo ""
echo "📝 Next steps:"
echo "   1. Set up the required GitHub secrets:"
echo "      - JENKINS_URL"
echo "      - JENKINS_USER"
echo "      - JENKINS_TOKEN"
echo "      - DOCKERHUB_USERNAME"
echo "      - DOCKERHUB_TOKEN"
echo "      - SMTP_SERVER, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD"
echo "      - SMTP_FROM, NOTIFICATION_EMAILS"
echo ""
echo "   2. Push to master branch to trigger the pipeline"
echo "   3. Monitor the deployment in Jenkins and GitHub Actions"
