package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	//"io/ioutil"
	"log"
	"net"
	"net/http"
	"strconv"
)



var usercounter int = 0

var activeusers map[int]string

const (
	connHost = "127.0.0.1"
	connPort = "8000"
	connType = "tcp"
)
type rec struct {
	Text string
}

func MlSender(text string, id int) {
	c, err := net.Dial(connType, connHost + ":" + connPort)
	if err != nil {
		fmt.Println(err)
	}
	send := fmt.Sprintf(`{"text": "%s", "id": %d}`, text, id)
	c.Write([]byte(send))
	buffer := make([]byte, 16384)
	for {
		n, err := c.Read(buffer)
		if err != nil {
			fmt.Println(err)
		}
		activeusers[id] = string(buffer[0:n])
		break
	}


}

func get(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "get called"}`))
}

func ResHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	id, _ := strconv.Atoi(mux.Vars(r)["id"])

	res := fmt.Sprintf(`{"answer": "%s"}`, activeusers[id])
	fmt.Println(activeusers)
	w.Write([]byte(res))
}

func post(w http.ResponseWriter, r *http.Request) {
	var data = rec{}
	err := json.NewDecoder(r.Body).Decode(&data)

	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(data)
	usercounter += 1
	id := usercounter
	defans := fmt.Sprintf(`{"id": %d}`, usercounter)
	activeusers[usercounter] = "In work"

	w.Write([]byte(defans) )
	MlSender(data.Text, id)

}

func notFound(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"message": "not found"}`))
}

func main() {
	activeusers = make(map[int]string)
	r := mux.NewRouter()
	r.HandleFunc("/", get).Methods(http.MethodGet)
	r.HandleFunc("/", post).Methods(http.MethodPost)
	r.HandleFunc("/", notFound)
	r.HandleFunc("/{id:[0-9]+}", ResHandler).Methods(http.MethodGet)
	log.Fatal(http.ListenAndServe(":8080", r))
}
