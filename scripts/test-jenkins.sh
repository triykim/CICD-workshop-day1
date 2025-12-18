#!/bin/bash

# Jenkins Testing Script
# This script helps test the Jenkinsfile locally

set -e

JENKINS_URL="http://localhost:8080"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Jenkins Pipeline Testing Script"
echo "=========================================="
echo ""

# Function to check if Jenkins is running
check_jenkins() {
    if curl -s "${JENKINS_URL}" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for Jenkins to be ready
wait_for_jenkins() {
    echo "⏳ Waiting for Jenkins to start..."
    local attempts=0
    local max_attempts=60
    
    while [ $attempts -lt $max_attempts ]; do
        if check_jenkins; then
            echo "✅ Jenkins is ready!"
            return 0
        fi
        echo "   Attempt $((attempts+1))/$max_attempts..."
        sleep 5
        attempts=$((attempts+1))
    done
    
    echo "❌ Jenkins failed to start within $((max_attempts * 5)) seconds"
    return 1
}

# Function to get initial admin password
get_admin_password() {
    if [ -f "${PROJECT_ROOT}/jenkins_home/secrets/initialAdminPassword" ]; then
        cat "${PROJECT_ROOT}/jenkins_home/secrets/initialAdminPassword"
    elif docker ps | grep -q jenkins-cicd-test; then
        docker exec jenkins-cicd-test cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null
    else
        echo "Password not found"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "Choose an option:"
    echo "1) Start Jenkins (Docker)"
    echo "2) Stop Jenkins"
    echo "3) View Jenkins logs"
    echo "4) Get Admin Password"
    echo "5) Open Jenkins in Browser"
    echo "6) Validate Jenkinsfile Syntax"
    echo "7) Test Pipeline Stages Locally"
    echo "8) Clean up (remove containers and volumes)"
    echo "9) Exit"
    echo ""
    read -p "Enter your choice [1-9]: " choice
    
    case $choice in
        1) start_jenkins ;;
        2) stop_jenkins ;;
        3) view_logs ;;
        4) show_password ;;
        5) open_browser ;;
        6) validate_jenkinsfile ;;
        7) test_stages_locally ;;
        8) cleanup ;;
        9) exit 0 ;;
        *) echo "Invalid option"; show_menu ;;
    esac
}

start_jenkins() {
    echo ""
    echo "🚀 Starting Jenkins..."
    cd "$PROJECT_ROOT"
    
    if docker ps | grep -q jenkins-cicd-test; then
        echo "✅ Jenkins is already running"
    else
        docker-compose up -d
        wait_for_jenkins
        
        echo ""
        echo "=========================================="
        echo "✅ Jenkins started successfully!"
        echo "=========================================="
        echo ""
        echo "📍 URL: ${JENKINS_URL}"
        echo "🔑 Admin Password:"
        sleep 5
        get_admin_password
        echo ""
        echo "📖 Next steps:"
        echo "   1. Open ${JENKINS_URL} in your browser"
        echo "   2. Use the password above to unlock Jenkins"
        echo "   3. Install suggested plugins"
        echo "   4. Create admin user"
        echo "   5. Create a new Pipeline job"
        echo "   6. Configure it to use jenkins/Jenkinsfile from SCM"
        echo ""
    fi
    
    show_menu
}

stop_jenkins() {
    echo ""
    echo "🛑 Stopping Jenkins..."
    cd "$PROJECT_ROOT"
    docker-compose stop
    echo "✅ Jenkins stopped"
    show_menu
}

view_logs() {
    echo ""
    echo "📋 Jenkins logs (Ctrl+C to exit):"
    echo ""
    docker-compose logs -f jenkins
}

show_password() {
    echo ""
    echo "🔑 Admin Password:"
    get_admin_password
    echo ""
    show_menu
}

open_browser() {
    echo ""
    echo "🌐 Opening Jenkins in browser..."
    if command -v open &> /dev/null; then
        open "${JENKINS_URL}"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "${JENKINS_URL}"
    else
        echo "Please open manually: ${JENKINS_URL}"
    fi
    show_menu
}

validate_jenkinsfile() {
    echo ""
    echo "🔍 Validating Jenkinsfile syntax..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker not found. Please install Docker."
        show_menu
        return
    fi
    
    # Use Jenkins CLI to validate
    if check_jenkins; then
        echo "Using Jenkins API to validate..."
        # This would require Jenkins CLI setup
        echo "⚠️  Manual validation recommended via Jenkins UI"
        echo "   Pipeline Syntax → Declarative Directive Generator"
    else
        echo "⚠️  Jenkins not running. Starting basic syntax check..."
        # Basic syntax check with groovy
        if command -v groovy &> /dev/null; then
            groovy -e "evaluate(new File('${PROJECT_ROOT}/jenkins/Jenkinsfile'))"
            echo "✅ Basic syntax check passed"
        else
            echo "ℹ️  Install groovy for local validation or use Jenkins UI"
        fi
    fi
    
    show_menu
}

test_stages_locally() {
    echo ""
    echo "🧪 Testing Pipeline Stages Locally"
    echo "=========================================="
    echo ""
    
    cd "$PROJECT_ROOT"
    
    # Test Go setup
    echo "1️⃣  Testing Go Setup..."
    if command -v go &> /dev/null; then
        go version
        echo "✅ Go is installed"
    else
        echo "❌ Go not found"
    fi
    echo ""
    
    # Test dependencies
    echo "2️⃣  Testing Dependencies..."
    if [ -f "go.mod" ]; then
        go mod download
        go mod verify
        echo "✅ Dependencies verified"
    else
        echo "❌ go.mod not found"
    fi
    echo ""
    
    # Test static analysis
    echo "3️⃣  Testing Static Analysis..."
    if command -v go &> /dev/null; then
        echo "Running go vet..."
        go vet ./cmd/webapp || true
        
        echo "Checking formatting..."
        UNFORMATTED=$(gofmt -l cmd/webapp)
        if [ -z "$UNFORMATTED" ]; then
            echo "✅ Code is properly formatted"
        else
            echo "⚠️  Unformatted files:"
            echo "$UNFORMATTED"
        fi
    fi
    echo ""
    
    # Test build
    echo "4️⃣  Testing Build..."
    if [ -x "./scripts/build.sh" ]; then
        ./scripts/build.sh
        echo "✅ Build completed"
    else
        echo "❌ build.sh not found or not executable"
    fi
    echo ""
    
    # Test running
    echo "5️⃣  Testing Tests..."
    go test -v ./cmd/webapp
    echo ""
    
    echo "=========================================="
    echo "✅ Local testing completed!"
    echo "=========================================="
    
    show_menu
}

cleanup() {
    echo ""
    read -p "⚠️  This will remove all Jenkins data. Continue? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "🧹 Cleaning up..."
        cd "$PROJECT_ROOT"
        docker-compose down -v
        echo "✅ Cleanup complete"
    else
        echo "Cancelled"
    fi
    show_menu
}

# Start
clear
echo "🔧 Jenkins Pipeline Test Environment"
echo ""

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed!"
    echo "Please install docker-compose"
    exit 1
fi

show_menu
