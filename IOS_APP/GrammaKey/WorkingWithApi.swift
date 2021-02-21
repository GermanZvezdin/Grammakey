//
//  WorkingWithApi.swift
//  GrammaKey
//
//  Created by German Zvezdin on 20.02.2021.
//

import UniformTypeIdentifiers

class GrammaKeyApi: ObservableObject {
    
    @Published var GetStatus = false
    @Published var PostStatus = false
    @Published var SID:Int = -1
    @Published var text: String = ""


    struct SPost: Encodable, Decodable {
        var text: String
    }
    struct ApiRes: Decodable{
        var answer: String
    }
    struct PostRes: Decodable {
        var id: Int
    }
    
    
    func GrammaKeyApiPostData(text: String, _ completion:@escaping (_ id: Int)->Void) {
        
        let Data = SPost(text: text)
        
        guard let encoded = try? JSONEncoder().encode(Data) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "http://192.168.1.238:8080/")!
        var request = URLRequest(url: url)
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        let body = encoded
        request.httpMethod = "POST"
        request.httpBody = body
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
                            
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                //в случае успеха сервер сообщает нам уникальный SID по которому мы находим результат
                //декодируем данные от сервера
                if let decodedOrder = try? JSONDecoder().decode(PostRes.self, from: data) {
                    //т.к запросы выполняются в отдельном потоке вызываем внешний декоратор который замыкает функцию(т.е вызывается в случае ее завершения)
                    //внутрь замыкания передается SID для дальнейшего использования
                    completion(decodedOrder.id)
                
                } else {}
            } else {
                print("ERROR2")
            }
        }
        task.resume()
        
        
    }
    
    func GrammaKeyApiGetData(sid: Int,  _ completion:@escaping (_ isSuccess:String, _ status: Bool)->Void) {
            
            let url = URL(string: "http://192.168.1.238:8080/\(sid)")!
            
            var request = URLRequest(url: url)
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            
            request.httpMethod = "GET"
            
            
            
            let session = URLSession.shared
            
           
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    completion("", false)
                } else if let data = data {
                    if let decodedOrder = try? JSONDecoder().decode(ApiRes.self, from: data) {
                        print(decodedOrder.answer)
                        if decodedOrder.answer == "In work" || decodedOrder.answer == "" {
                            completion("", false)
                        } else {
                            completion(decodedOrder.answer, true)
                        }
                        
                    } else {
                        completion("", false)
                    }
                } else {
                    print("ERROR2")
                    completion("", false)
                }
            }
            
            task.resume()
            
        }
    
    
    public func Send(text: String){
            //Вызов API
        self.GrammaKeyApiPostData(text: text) {
                (res) in
                    DispatchQueue.main.async {
                        self.SID = res
                        print("POST: \(res)\n")
                    }
        }
    }
    public func GetRes(_ completion:@escaping (_ isSuccess:String)->Void){
            DispatchQueue.main.async {
                self.GetStatus = true
            }
            let interval = 0.75
            var count = 0
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: interval,repeats: true) { t in
                    self.GrammaKeyApiGetData(sid: self.SID) {
                        (res, flag) in
                        if flag {
                            DispatchQueue.main.async {
                                self.text = res
                                completion(self.text)
                            }
                            t.invalidate()
                        }
                    }
                    count+=1
                    if count >= 100 {
                        t.invalidate()
                        DispatchQueue.main.async {
                            self.GetStatus = false
                            completion("Server timeout")
                        }
                    }
                    
                }
            }
        }
    
}



