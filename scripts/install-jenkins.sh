#!/bin/bash

# Jenkins Installation Script for Ubuntu 24.04
# This script installs Jenkins and its prerequisites

set -e

echo "================================"
echo "Jenkins Installation Script"
echo "================================"

# Install Java (Jenkins requires Java 17 or 21)
echo "Installing OpenJDK 17..."
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre

# Verify Java installation
java -version

# Add Jenkins repository
echo "Adding Jenkins repository..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
echo "Installing Jenkins..."
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins service
echo "Starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Display initial admin password
echo "================================"
echo "Jenkins Installation Complete!"
echo "================================"
echo ""
echo "Jenkins is running at: http://localhost:8080"
echo ""
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "Copy this password to unlock Jenkins in your browser"
echo "================================"
