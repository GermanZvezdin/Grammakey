package main

import (
  "fmt"
  "net/http"
  "html/template"
  "encoding/json"
  "time"
  "bytes"

)

// site data
type FormData struct {
  Loaded bool
  Result string
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


// Display the named template
func display(w http.ResponseWriter, page string, is_load bool, result string) {
  /*
  Display specific template, which is differnt, because it has some time
  to get Result text.
  Input:
  	page - displate this page
	is_load - bool var which shows loaded data or not
	result - if is_load equals true then result contains the result text from api_url
  */
  t, err := template.ParseFiles("templates/index.html")

  if err != nil {
    fmt.Println(w, err.Error())
  }

  Data := FormData{is_load, result}
  t.Execute(w, Data)
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

func get_data_from_session(session int64) (string) {
  /*
  When site get sessing id, site needs to send get request to the
  following url: api_url/<session_id> to get result data
  Input:
  	sessin - int number of session
  Output:
  	chan: channel that transfer data
  */
  url_session := fmt.Sprintf("%s%d", api_url, session)
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

func upload_text(w http.ResponseWriter, r *http.Request) {
  /*
  Upload text to site and then send to api_url
  */
  key_sentence := r.FormValue("key_sentence")

  fmt.Println("key sentence = ", key_sentence)
  
  session := post_data(api_url, key_sentence)
  fmt.Printf("session = %d ", session)
  
  result_txt := get_data_from_session(session)
  fmt.Println(result_txt)

  display(w, "index", true, result_txt)
}

func view_handler(w http.ResponseWriter, r *http.Request) {
  /* 
  Handler to view GET or POST data on site
  */
  switch r.Method {
  	case "GET":
  		display(w, "index", false, "")
  	case "POST":
  		upload_text(w, r)
	}
}

func main() {
	http.HandleFunc("/", view_handler)
        http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static/"))))
	http.ListenAndServe(":8000", nil)
}
