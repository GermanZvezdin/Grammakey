# GrammaKey API and swift app

## API structure

In the core of API is used neural network model, what was trained to generate text by using keywords.
github that corresponds to training data: https://github.com/take2make/key2text

API was constructed by using GO language.
For predict result text is used python.
To speed up transfer between GO and Python are used sockets, so we do need to wait model initializing.

On API users just need to send the following json: {"text", "your key words"}). As a result users recieve session id, to wait the result text on the api_url/<session_id>. 

Following picture shows simple structure of transfer between back and API.
![alt tag](https://github.com/GermanZvezdin/Grammakey/blob/main/API/api2.png)

## Run

Firstly run socket in API

> main.py

it initilizes model and socket to transfer data into go from python.

Second run API

> main.go

Now api url is running, and you can send request to api url.

## Swift app

### Build with
- SwiftUI
- UIKit
- Combine
- Foundation

### Inside the application

#### Users can select language 
![Запись экрана 2021-02-21 в 11 07 16](https://user-images.githubusercontent.com/71877725/108619343-37038b80-7435-11eb-9d9b-b94407e38034.gif)

#### Users can edit result text 
![Запись экрана 2021-02-21 в 11 17 33](https://user-images.githubusercontent.com/71877725/108619554-aded5400-7436-11eb-8322-8ae2ad4db363.gif)



