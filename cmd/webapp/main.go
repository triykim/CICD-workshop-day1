package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

const version = "1.0.0"

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8090"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/version", versionHandler)

	fmt.Printf("🚀 Go Web Server starting on port %s...\n", port)
	fmt.Printf("📍 Access the app at: http://localhost:%s\n", port)

	// Create server with proper timeouts (security best practice)
	server := &http.Server{
		Addr:              ":" + port,
		Handler:           nil,
		ReadTimeout:       15 * time.Second,
		ReadHeaderTimeout: 15 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	log.Fatal(server.ListenAndServe())
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	html := `
<!DOCTYPE html>
<html>
<head>
    <title>CI/CD Workshop - Go App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { margin-top: 0; }
        .info { background: rgba(0,0,0,0.2); padding: 15px; border-radius: 5px; margin: 10px 0; }
        .code { background: #2d3748; padding: 10px; border-radius: 5px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 CI/CD Workshop - Go Application</h1>
        <div class="info">
            <p><strong>Version:</strong> ` + version + `</p>
            <p><strong>Build Time:</strong> ` + time.Now().Format("2006-01-02 15:04:05") + `</p>
            <p><strong>Status:</strong> ✅ Running Successfully!</p>
        </div>
        <h2>Available Endpoints:</h2>
        <div class="code">
            <p>GET / - This page</p>
            <p>GET /health - Health check</p>
            <p>GET /version - Application version</p>
        </div>
        <p style="margin-top: 20px;">This app was built and deployed using Jenkins CI/CD pipeline! 🚀</p>
    </div>
</body>
</html>
`
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	fmt.Fprint(w, html)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"status":"healthy","version":"%s","timestamp":"%s"}`, version, time.Now().Format(time.RFC3339))
}

func versionHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"version":"%s"}`, version)
}
