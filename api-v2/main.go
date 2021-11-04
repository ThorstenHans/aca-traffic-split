package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
)

const defaultPort = 8080

type response struct {
	Version string `json:"version"`
}

func versionHandler(rw http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		rw.WriteHeader(http.StatusNotFound)
		return
	}
	v1 := response{
		Version: "v2.0.0",
	}

	rw.Header().Add("Content-Type", "application/json")
	err := json.NewEncoder(rw).Encode(v1)

	if err != nil {
		rw.WriteHeader(http.StatusInternalServerError)
	}
}

func logger(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(rw http.ResponseWriter, r *http.Request) {
			fmt.Printf("[%s] %s\r\n", r.Method, r.URL)
			next.ServeHTTP(rw, r)
		},
	)
}

func getPort() int {
	port, err := strconv.Atoi(os.Getenv("PORT"))
	if err != nil {
		return defaultPort
	}
	return port

}
func main() {

	r := http.NewServeMux()

	r.HandleFunc("/", versionHandler)

	logRouter := logger(r)

	p := getPort()
	fmt.Printf("Starting server on port: %d\r\n", p)
	http.ListenAndServe(fmt.Sprintf(":%d", p), logRouter)
}
