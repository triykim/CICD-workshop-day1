#!/bin/bash

JENKINS_URL="http://localhost:8081"
ADMIN_PASSWORD="8e6b171e8fd147bf99bdd3507d7bf861"

echo "=== Completing Jenkins Initial Setup ==="
echo ""
echo "Initial Admin Password: $ADMIN_PASSWORD"
echo ""
echo "📋 Manual steps required:"
echo ""
echo "1. Open: $JENKINS_URL"
echo "2. Paste password: $ADMIN_PASSWORD"
echo "3. Click 'Install suggested plugins'"
echo "4. Wait for plugins to install (~2-3 minutes)"
echo "5. Create first admin user OR click 'Skip and continue as admin'"
echo "6. Keep Jenkins URL as: $JENKINS_URL"
echo "7. Click 'Start using Jenkins'"
echo ""
echo "After setup is complete, press ENTER to create the pipeline job..."
read -p ""

echo ""
echo "Creating pipeline job..."
./scripts/setup-jenkins-job.sh

echo ""
echo "✅ Setup complete! Check build status at:"
echo "   $JENKINS_URL/job/cicd-workshop-pipeline"
