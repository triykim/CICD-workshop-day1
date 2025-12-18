#!/bin/bash

# Build script for Go application
# This can be used outside of Jenkins for local development

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "================================"
echo "Building Go Web Application"
echo "================================"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed!"
    echo "Please install Go from: https://go.dev/dl/"
    exit 1
fi

echo "Go version:"
go version
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf bin artifacts
mkdir -p bin artifacts

# Run tests
echo "Running tests..."
go test -v -cover ./...
echo ""

# Build the application
echo "Building application..."
go build -o bin/app ./cmd/webapp
echo "✅ Build successful!"
echo ""

# Show binary info
echo "Binary information:"
ls -lh bin/app
file bin/app
echo ""

# Create package
echo "Creating deployment package..."
cp bin/app artifacts/
echo "Build: local" > artifacts/version.txt
echo "Date: $(date)" >> artifacts/version.txt

cat > artifacts/run.sh << 'EOF'
#!/bin/bash
export PORT=8090
echo "Starting Go Web Application on port $PORT..."
./app
EOF
chmod +x artifacts/run.sh

echo "✅ Package created in artifacts/"
echo ""
echo "To run the application:"
echo "  ./bin/app"
echo ""
echo "Or from the artifacts directory:"
echo "  cd artifacts && ./run.sh"
echo ""
echo "Then visit: http://localhost:8090"
echo "================================"
