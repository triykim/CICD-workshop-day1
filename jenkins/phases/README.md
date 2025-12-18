# Jenkins Pipeline Phases - Workshop Guide

This directory contains sequential phases of Jenkins pipeline for CI/CD training workshop.

## 📚 Workshop Structure

### Phase 1: Basic Git Checkout
**File:** `phase1-basic-checkout.jenkinsfile`

**Goal:** Learn how to connect a Git repository to Jenkins

**What's added:**
- Basic pipeline structure
- Stage: Checkout (connecting Git repository)
- Display information about current branch and commit

**Commands for practice:**
```bash
# Check project structure
ls -la

# View current branch
git branch --show-current

# View last commit
git log -1
```

---

### Phase 2: Add Go Environment and Triggers
**File:** `phase2-add-go-environment.jenkinsfile`

**Goal:** Set up Go environment for building and configure automated triggers

**What's added:**
- Triggers section (pollSCM - check for changes every minute)
- GitHub webhook trigger option (commented)
- Environment variables (GO_VERSION, GOPATH, PATH)
- Stage: Setup Go Environment
- Automatic Go installation
- System architecture detection (amd64/arm64)

**Key concepts:**
- Automated triggers (CI/CD automation)
- SCM polling vs webhooks
- Environment variables in Jenkins
- Conditional tool installation
- System architecture detection

---

### Phase 3: Add Build and Workspace Cleanup
**File:** `phase3-add-build.jenkinsfile`

**Goal:** Clean workspace and compile Go application

**What's added:**
- Stage: Cleanup Workspace (deleteDir() before build)
- Stage: Install Dependencies
- Stage: Build
- Version, commit, and build time injection into binary
- Creating binary file in bin/

**Key concepts:**
- Workspace cleanup best practices
- Go modules (go mod download/verify)
- Build flags and ldflags
- Version injection

**Result:**
```bash
bin/GoWebApp  # Compiled binary with version info
```

---

### Phase 4: Add Tests
**File:** `phase4-add-tests.jenkinsfile`

**Goal:** Run unit tests and generate reports

**What's added:**
- Stage: Test
- go-junit-report for JUnit reports
- Coverage reports (HTML and XML)
- Jenkins JUnit integration

**Key concepts:**
- Unit testing in Go
- Code coverage
- Test reporting in Jenkins UI
- JUnit XML format

**Result:**
```
test-reports/junit.xml  # JUnit test report
coverage.out            # Coverage data
coverage.html           # HTML coverage report
```

---

### Phase 5: Add Static Analysis
**File:** `phase5-add-static-analysis.jenkinsfile`

**Goal:** Check code quality using linters

**What's added:**
- Stage: Static Code Analysis
- golangci-lint (20+ linters)
- go vet (static analysis)
- gofmt (formatting check)

**Key concepts:**
- Code quality checks
- Linting
- Static analysis
- Code formatting standards

**Linters:**
- gosec (security)
- errcheck (error handling)
- staticcheck
- govet
- and many others

---

### Phase 6: Add Artifacts
**File:** `phase6-add-artifacts.jenkinsfile`

**Goal:** Create and archive build artifacts

**What's added:**
- Stage: Cleanup Workspace
- Stage: Create Artifacts
- Stage: Archive Artifacts
- Creating tarball with all artifacts
- build-info.json with metadata
- run.sh script for execution

**Key concepts:**
- Build artifacts
- Artifact archiving
- Build metadata
- Tarball packaging

**Result:**
```
artifacts/
├── GoWebApp                        # Binary
├── run.sh                         # Run script
├── build-info.json                # Build metadata
├── coverage.out                   # Coverage data
├── coverage.html                  # Coverage report
└── GoWebApp-1.0.X-abc123.tar.gz  # Complete package
```

---

## 🎯 Workshop Execution Order

### Step 1: Preparation

#### Option 1: Vagrant VM (Recommended)
```bash
# Clone repository
git clone git@github.com:epam-msdp/CICD-workshop-day1.git
cd CICD-workshop-day1

# Start Vagrant VM
vagrant up

# This will:
# - Create Ubuntu 24.04 VM
# - Install Jenkins automatically
# - Configure port forwarding (Jenkins on 8080)

# Wait for VM to start (3-5 minutes)
# Access Jenkins: http://localhost:8080
# Initial password: 8e6b171e8fd147bf99bdd3507d7bf861
```

#### Option 2: Docker (Alternative)
```bash
# Clone repository
git clone git@github.com:epam-msdp/CICD-workshop-day1.git
cd CICD-workshop-day1

# Start Jenkins in Docker
cd docker
docker-compose up -d

# Access Jenkins: http://localhost:8081
# Get initial password:
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Step 2: Initial Jenkins Setup
1. Open Jenkins in browser (port 8080 for Vagrant or 8081 for Docker)
2. Enter initial admin password
3. Install suggested plugins
4. Create first admin user
5. Keep default Jenkins URL

### Step 3: Create Jenkins Job
1. Click "New Item"
2. Enter name: "workshop-demo"
3. Select "Pipeline"
4. Click "OK"
5. In Configuration:
   - **Pipeline Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/epam-msdp/CICD-workshop-day1.git`
   - **Credentials**: None (public repo)
   - **Branch**: `*/main`
   - **Script Path**: `jenkins/phases/phase1-basic-checkout.jenkinsfile`
6. Click "Save"

### Step 4: Progress Through Phases

#### Phase 1: Basic Checkout
```bash
# In Jenkins Job configuration
Script Path: jenkins/phases/phase1-basic-checkout.jenkinsfile
```
- Run Build Now
- Check Console Output
- Review project structure

#### Phase 2: Go Environment and Triggers
```bash
Script Path: jenkins/phases/phase2-add-go-environment.jenkinsfile
```
- Run Build
- Verify Go installation
- Review environment variables
- Make a commit and push to repository
- Wait 1 minute - pipeline should start automatically

#### Phase 3: Build and Cleanup
```bash
Script Path: jenkins/phases/phase3-add-build.jenkinsfile
```
- Run Build
- Observe workspace cleanup (deleteDir())
- Find compiled binary
- Verify version injection

#### Phase 4: Tests
```bash
Script Path: jenkins/phases/phase4-add-tests.jenkinsfile
```
- Run Build
- View Test Results in Jenkins UI
- Open Coverage Report

#### Phase 5: Static Analysis
```bash
Script Path: jenkins/phases/phase5-add-static-analysis.jenkinsfile
```
- Run Build
- Check linting results
- Fix errors if any

#### Phase 6: Artifacts
```bash
Script Path: jenkins/phases/phase6-add-artifacts.jenkinsfile
```
- Run Build
- Download artifacts from Jenkins
- Extract and run the application

---

## 📝 Practical Exercises

### Exercise 1: Add a new test
1. Add a new test in `cmd/webapp/main_test.go`
2. Push changes
3. Verify that pipeline started automatically
4. Review results in Test Results

### Exercise 2: Fix a linting error
1. Introduce an error in code (e.g., wrong formatting)
2. Run pipeline
3. Review errors in Static Analysis
4. Fix and rerun

### Exercise 3: Configure webhook (Advanced)
1. In phase2-add-go-environment.jenkinsfile, uncomment githubPush() and comment pollSCM
2. Configure webhook in GitHub repository settings
3. Test automatic trigger on push

---

## 🔧 Troubleshooting

### Go installation fails
```bash
# Check architecture
uname -m

# Check Go availability
curl -I https://go.dev/dl/go1.21.5.linux-arm64.tar.gz
```

### Tests fail
```bash
# Run tests locally
go test -v ./...

# Check coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Artifacts not created
```bash
# Check permissions
ls -la artifacts/

# Check binary presence
ls -la bin/
```

---

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Go Testing](https://golang.org/pkg/testing/)
- [golangci-lint](https://golangci-lint.run/)
- [GitHub Webhooks](https://docs.github.com/en/webhooks)

---

## ✅ Workshop Checklist

- [ ] Phase 1: Basic Checkout works
- [ ] Phase 2: Go environment installed and automated triggers configured
- [ ] Phase 3: Workspace cleanup added and binary builds successfully
- [ ] Phase 4: Tests pass, coverage report available
- [ ] Phase 5: Static analysis passes without errors
- [ ] Phase 6: Complete pipeline with artifacts (production-ready)
- [ ] Practical exercises completed
- [ ] Webhook configured (optional)

---

**Good luck with your learning! 🚀**
