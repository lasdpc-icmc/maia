package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// Use PORT environment variable, or default to 8080
	port := "8080"
	if fromEnv := os.Getenv("PORT"); fromEnv != "" {
		port = fromEnv
	}

	// Register the appropriate handler functions for endpoints
	server := http.NewServeMux()
	server.HandleFunc("/call", call)
	server.HandleFunc("/", errorHandler) // Handle all other endpoints with an error

	// Start the web server on the specified port and accept requests
	log.Printf("Server listening on port %s", port)
	err := http.ListenAndServe(":"+port, server)
	log.Fatal(err)
}

// call responds to the "/call" endpoint with a plain-text message.
func call(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)
	host, _ := os.Hostname()
	fmt.Fprintf(w, "Hello, I'm USP app V1\n")
	fmt.Fprintf(w, "Version: 1.0.0\n")
	fmt.Fprintf(w, "Hostname: %s\n", host)
}

// errorHandler responds with a HTTP 500 error for all other endpoints and logs the error.
func errorHandler(w http.ResponseWriter, r *http.Request) {
	log.Printf("Error: Endpoint not found - %s", r.URL.Path)
	http.Error(w, "Internal Server Error", http.StatusInternalServerError)
}
