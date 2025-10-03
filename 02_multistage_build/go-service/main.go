package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "time"
)

type Response struct {
    Message   string    `json:"message"`
    Timestamp time.Time `json:"timestamp"`
    Version   string    `json:"version"`
}

type HealthResponse struct {
    Status string `json:"status"`
    Uptime string `json:"uptime"`
}

var startTime = time.Now()

func main() {
    http.HandleFunc("/", handleRoot)
    http.HandleFunc("/health", handleHealth)
    http.HandleFunc("/api/data", handleData)

    port := os.Getenv("API_PORT")
    if port == "" {
        port = "8080"
    }

    fmt.Printf("Go API сервис запущен на порту %s\n", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
    response := Response{
        Message:   "Go API сервис работает!",
        Timestamp: time.Now(),
        Version:   "1.0.0",
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
    uptime := time.Since(startTime).String()
    
    health := HealthResponse{
        Status: "healthy",
        Uptime: uptime,
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(health)
}

func handleData(w http.ResponseWriter, r *http.Request) {
    data := map[string]interface{}{
        "users":    []string{"Alice", "Bob", "Charlie"},
        "count":    3,
        "generated": time.Now(),
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(data)
}
