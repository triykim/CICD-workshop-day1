#!/bin/bash

# Jenkins Configuration
JENKINS_URL="http://localhost:8081"
ADMIN_PASSWORD="8e6b171e8fd147bf99bdd3507d7bf861"
JOB_NAME="cicd-workshop-pipeline"
GIT_REPO="https://github.com/epam-msdp/CICD-workshop-day1.git"

echo "=== Jenkins Pipeline Job Setup ==="
echo ""

# Wait for Jenkins to be fully ready
echo "1. Checking Jenkins availability..."
for i in {1..10}; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$JENKINS_URL")
    if [ "$STATUS" = "403" ] || [ "$STATUS" = "200" ]; then
        echo "✅ Jenkins is ready"
        break
    fi
    echo "   Waiting... ($i/10)"
    sleep 5
done

# Create job configuration XML
echo ""
echo "2. Creating Pipeline job configuration..."
cat > /tmp/jenkins-job.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job">
  <description>CI/CD Workshop Pipeline - Automated Testing</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers/>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps">
    <scm class="hudson.plugins.git.GitSCM" plugin="git">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/epam-msdp/CICD-workshop-day1.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="empty-list"/>
      <extensions/>
    </scm>
    <scriptPath>jenkins/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

echo "✅ Configuration created"

echo ""
echo "3. Creating Jenkins job via API..."
curl -X POST "$JENKINS_URL/createItem?name=$JOB_NAME" \
  --user "admin:$ADMIN_PASSWORD" \
  --header "Content-Type: application/xml" \
  --data-binary @/tmp/jenkins-job.xml \
  -o /dev/null -w "HTTP Status: %{http_code}\n"

echo ""
echo "4. Triggering first build..."
sleep 2
curl -X POST "$JENKINS_URL/job/$JOB_NAME/build" \
  --user "admin:$ADMIN_PASSWORD" \
  -o /dev/null -w "HTTP Status: %{http_code}\n"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "📊 Jenkins Dashboard: $JENKINS_URL"
echo "🔧 Job URL: $JENKINS_URL/job/$JOB_NAME"
echo "👤 Username: admin"
echo "🔑 Password: $ADMIN_PASSWORD"
echo ""
echo "Monitor build progress:"
echo "  docker logs -f jenkins-cicd-test"
echo ""
echo "Or open: $JENKINS_URL/job/$JOB_NAME"
