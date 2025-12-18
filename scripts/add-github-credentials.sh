#!/bin/bash

JENKINS_URL="http://localhost:8081"
ADMIN_PASSWORD="8e6b171e8fd147bf99bdd3507d7bf861"

echo "=== Adding GitHub Credentials to Jenkins ==="
echo ""
echo "You need a GitHub Personal Access Token with 'repo' scope"
echo "Create one at: https://github.com/settings/tokens/new"
echo ""
echo "Required scopes:"
echo "  - repo (full control of private repositories)"
echo "  - write:packages (if using GitHub Packages)"
echo ""
read -p "Enter your GitHub token: " GITHUB_TOKEN

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token cannot be empty"
    exit 1
fi

echo ""
echo "Adding credential to Jenkins..."

# Create Groovy script to add credentials
cat > /tmp/add-credentials.groovy << EOF
import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl

def instance = Jenkins.getInstance()
def domain = Domain.global()
def store = instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// Add GitHub token as Secret text
def secret = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "github-token",
    "GitHub Personal Access Token",
    hudson.util.Secret.fromString("${GITHUB_TOKEN}")
)

store.addCredentials(domain, secret)
println("✅ GitHub token added successfully")
EOF

# Execute Groovy script via Jenkins API
curl -X POST "$JENKINS_URL/scriptText" \
  --user "admin:$ADMIN_PASSWORD" \
  --data-urlencode "script@/tmp/add-credentials.groovy" 

echo ""
echo ""
echo "✅ Credential added with ID: github-token"
echo ""
echo "This credential can now be used in Jenkinsfile:"
echo "  withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {"
echo "    // use \$GITHUB_TOKEN here"
echo "  }"

# Cleanup
rm -f /tmp/add-credentials.groovy
