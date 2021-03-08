package main

import (
	"log"
	"net/http"
	"github.com/gorilla/websocket"
	"fmt"
    "encoding/json"
    "time"
    "bytes"
    "strings"
)

var clients = make(map[*websocket.Conn]bool) // connected clients


// Configure the upgrader
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Define our message object
type Message struct {
	Sender   string `json:"sender"`
	Message  string `json:"message"`
}

type msg_ws struct {
	msg Message
	client_ws *websocket.Conn
}

// get response on Post request
type RespponsePostData struct {
  Id int64         `json:"id"`
}

// get response on Get request from specific session 
type RespponseGetData struct {
  Answer string   `json:"answer"`
}

// api_url on which site send Post data
var api_url = "http://grammakey.space:8080/"
var chat_api_url = "http://grammakey.space:8020/"

var broadcast = make(chan msg_ws)           // broadcast channel

func main() {
	// Create a simple file server
	fs := http.FileServer(http.Dir("public"))
	http.Handle("/", fs)

	// Configure websocket route
	http.HandleFunc("/ws", handleConnections)

	// Start listening for incoming chat messages
	go handleMessages()

	// Start the server on localhost port 8000 and log any errors
	log.Println("http server started on :8000")
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func handleConnections(w http.ResponseWriter, r *http.Request) {
	// Upgrade initial GET request to a websocket
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}
	// Make sure we close the connection when the function returns
	defer ws.Close()

	// Register our new client
	clients[ws] = true

	for {
		var msg Message
		// Read in a new message as JSON and map it to a Message object
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("error: %v", err)
			delete(clients, ws)
			break
		}
		// Send the newly received message to the broadcast channel

		res := msg_ws{msg, ws}
		broadcast <- res
	}
}

func post_data(url string, text string) (session_id int64) {
  /* 
  Post data on api_url for future processing on api side
  Input:
  	url - post data on this url
	text - key sentece which is send to url
  Output:
  	session_id - int number which shows session id of processing
	text data
  */
  postBody, _ := json.Marshal(map[string]string{
    "text":text,
  })

  responseBody := bytes.NewBuffer(postBody)

  resp, err :=  http.Post(url, "application/json", responseBody)
  if err != nil {
    fmt.Println("An Error occured %v", err)
  }
  defer resp.Body.Close()

  post_data := RespponsePostData{}
  json.NewDecoder(resp.Body).Decode(&post_data)

  return post_data.Id
}

func get_data_from_session(url string, session int64) (string) {
  /*
  When site get sessing id, site needs to send get request to the
  following url: api_url/<session_id> to get result data
  Input:
  	sessin - int number of session
  Output:
  	chan: channel that transfer data
  */
  url_session := fmt.Sprintf("%s%d", url, session)
  fmt.Println(url_session)


  // it creates lightweight thread, so the function
  // get_data_from_session is actually asynchronous
  // go func() {
  // defer close(r)
  r := ""
  for {
    time.Sleep(time.Second/100)
    resp, err := http.Get(url_session)
    if err != nil {
      panic(err)
    }
    defer resp.Body.Close()
    get_data := RespponseGetData{}
    json.NewDecoder(resp.Body).Decode(&get_data)
    fmt.Println("Answer = ", get_data.Answer)
    if get_data.Answer != "" && get_data.Answer != "In work" {
      r = get_data.Answer
      break
    }
  }
  //}()
  return r
}

func handleMessages() {
	for {
		// Grab the next message from the broadcast channel
		res := <-broadcast
		// Send it out to every client that is currently connected

		// msg sended by user
		res.msg.Sender = "user"
		err := res.client_ws.WriteJSON(res.msg)
		if err != nil {
			log.Printf("error: %v", err)
			res.client_ws.Close()
			delete(clients, res.client_ws)
		}

		session := post_data(api_url, res.msg.Message)
		fmt.Printf("session = %d ", session)
		
		result_txt := get_data_from_session(api_url, session)
		fmt.Println(result_txt)

		if (strings.HasPrefix(result_txt, "Sory, but you have mistake")) {
			res.msg.Message = result_txt
			res.msg.Sender = "server"
			err2 := res.client_ws.WriteJSON(res.msg)
			if err2 != nil {
				log.Printf("error: %v", err2)
				res.client_ws.Close()
				delete(clients, res.client_ws)

			}
			continue
		}

		session_chat := post_data(chat_api_url, result_txt)
		bot_answer := get_data_from_session(chat_api_url, session_chat)

		// answer by server
		res.msg.Message = bot_answer
		res.msg.Sender = "server"
		err2 := res.client_ws.WriteJSON(res.msg)
		if err2 != nil {
			log.Printf("error: %v", err2)
			res.client_ws.Close()
			delete(clients, res.client_ws)
		}

	}
}
