//
//  File.swift
//  
//
//  Created by Michael on 30.01.2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import Combine
import SwiftUI
import SocketIO
import Yelm_Server


public class Core: ObservableObject, Identifiable {
    public var id: Int = 0
    
    var manager : SocketManager?
    var socket : SocketIOClient!
    
    @Published public var socket_state : Bool = false
    
    public func get(){
        
        
        
        AF.request("https://chat.yelm.io/api/message/all?platform=\(YelmChat.settings.platform)&room_id=\(YelmChat.settings.chat.room_id)", method: .get).responseJSON { (response) in
            
            YelmChat.objectWillChange.send()
            YelmChat.chat.messages.removeAll()
            YelmChat.chat.messages.append(chat_message(id: 0))
            
            if (response.value != nil && response.response?.statusCode == 200) {
                
                let json = JSON(response.value!)
                
                if (YelmChat.settings.debug){
                    print(json)
                }
                
                
                if (json.count > 0){
                    for i in 0...json.count-1{
                        let message_json = json[i]
                        
                        if (message_json["type"].string! == "message"){
                            
                            var username : String = "shop"
                            if (YelmChat.settings.chat.client == message_json["from_whom"].int!){
                                username = YelmChat.settings.user
                            }

                            YelmChat.objectWillChange.send()
                            YelmChat.chat.messages.append(chat_message(id: message_json["id"].int!,
                                                                       user: chat_user(id: 0, name: username),
                                                                       text: message_json["message"].string!,
                                                                       time: self.get_time(date_time: message_json["created_at"].string!).1,
                                                                       date: self.get_time(date_time: message_json["created_at"].string!).0,
                                                                       attachments: [:]))
                            
                            
                        }
                        
                        
                        if (message_json["type"].string! == "order"){
                            
                            var username : String = "shop"
                            if (YelmChat.settings.chat.client == message_json["from_whom"].int!){
                                username = YelmChat.settings.user
                            }

                            
                            let id_order = message_json["order_id"].int!
                            
                            
                            
                            YelmChat.objectWillChange.send()
                            YelmChat.chat.messages.append(chat_message(id: message_json["id"].int!,
                                                                       user: chat_user(id: 0, name: username),
                                                                       text: message_json["message"].string!,
                                                                       time: self.get_time(date_time: message_json["created_at"].string!).1,
                                                                       date: self.get_time(date_time: message_json["created_at"].string!).0,
                                                                       attachments: ["order": "true", "id" : "\(id_order)"]))
                            
                        }
                        
                        
                        if (message_json["type"].string! == "items"){
                            
                            var username : String = "shop"
                            if (YelmChat.settings.chat.client == message_json["from_whom"].int!){
                                username = YelmChat.settings.user
                            }
                            
                            let item_AF = message_json["items"]
                            
                            let price_AF = Float(item_AF["discount"].int!) / 100
                            let discount_AF = item_AF["price"].float! * price_AF
                            let discount_final = item_AF["price"].float! - discount_AF
                            let final = discount_final
                            
                            let parameter_AF = item_AF["specification"]
                            var parameters : [parameters_structure] = []
                            
                            if (parameter_AF.count > 0){
                                for k in 0...parameter_AF.count - 1 {
                                    let parameter_single = parameter_AF[k]
                                    let name = parameter_single["name"].string!
                                    let value = parameter_single["value"].string!
                                    parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                                }
                            }
                            
                            var images : [String] = []
                            for k in 0...item_AF["images"].count-1{
                                images.append(item_AF["images"][k].string!)
                            }
                            
                            let structure_ready = items_structure(id: item_AF["id"].int!,
                                                                  title: item_AF["name"].string!,
                                                                  price: String(format:"%.2f", item_AF["price"].float!),
                                                                  text: item_AF["description"].string!,
                                                                  thubnail: item_AF["preview_image"].string!,
                                                                  price_float: item_AF["price"].float!,
                                                                  all_images: images,
                                                                  parameters: parameters,
                                                                  type: item_AF["type"].string!,
                                                                  quanity: "\(item_AF["unit_type"].int!)",
                                                                  discount: String(format:"%.2f", final),
                                                                  discount_value: item_AF["discount"].int!,
                                                                  discount_present: "-\(item_AF["discount"].int!)%",
                                                                  rating: item_AF["rating"].int!,
                                                                  amount: item_AF["quantity"].int!)
                            
                        
                            YelmChat.objectWillChange.send()
                            
                            YelmChat.chat.messages.append(chat_message(id: message_json["id"].int!,
                                                                       user: chat_user(id: 0, name: username),
                                                                       text: "",
                                                                       time: self.get_time(date_time: message_json["created_at"].string!).1,
                                                                       date: self.get_time(date_time: message_json["created_at"].string!).0,
                                                                       attachments: ["item" : "true"],
                                                                       item: structure_ready))
                            
                            
                            
                        }
                        
                        if (message_json["type"].string! == "images"){
                            
                            var username : String = "shop"
                            if (YelmChat.settings.chat.client == message_json["from_whom"].int!){
                                username = YelmChat.settings.user
                            }
                            
                            let json_image = message_json["images"][0].string!
                            
                            
                            YelmChat.objectWillChange.send()
                            YelmChat.chat.messages.append(chat_message(id: message_json["id"].int!,
                                                                       user: chat_user(id: 0, name: username),
                                                                       text: "",
                                                                       time: self.get_time(date_time: message_json["created_at"].string!).1,
                                                                       date: self.get_time(date_time: message_json["created_at"].string!).0,
                                                                       attachments: ["image" : json_image]))
                        }
                        
                    }
                }
                
                
            }else{
                if (YelmChat.settings.debug && YelmChat.settings.internet()){
                    print(response.value!)
                }
            }
        }

    }
    
    func get_time(date_time: String, divider : Character = Character(":")) -> (String, String){
        
        
        let time : String = date_time
        let time_split = time.split(separator: " ")
        let date = String(time_split[0])
        var real_time : String = String(time_split[1])
        real_time = real_time.split(separator: divider)[0] + ":" + real_time.split(separator: divider)[1]
        
        
        return (date, real_time)
        
    }
    
    public func server(host: String){
        
        
        self.get()
        
        manager = SocketManager(socketURL: URL(string: host)!,
                                config: [.log(false),
                                         .forceNew(true),
                                         .connectParams(["token" : YelmChat.settings.chat.api_token, "room_id" : YelmChat.settings.chat.room_id]),
                                         .reconnectWait(1)
                                ])
        self.socket = self.manager!.defaultSocket
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("connected")
            DispatchQueue.main.async {
                YelmChat.objectWillChange.send()
                self.socket_state = true
            }
        }
        
        
        self.socket.on("room.\(YelmChat.settings.chat.room_id)") { [self] (data, emitter) in
            
            let json = JSON(data)
          
            
            if (json[0]["type"].string! == "connected"){
                return
            }
          
            if (json[0]["type"].string! == "message"){
                
                
                var username : String = "shop"
                if (YelmChat.settings.chat.client == json[0]["from_whom"].int!){
                    username = YelmChat.settings.user
                }
                
               
                
                    YelmChat.objectWillChange.send()
                    YelmChat.chat.messages.append(chat_message(id: json[0]["id"].int!,
                                                               user: chat_user(id: 0, name: username),
                                                               text: json[0]["message"].string!,
                                                               time: self.get_time(date_time: json[0]["created_at"].string!).1,
                                                               date: self.get_time(date_time: json[0]["created_at"].string!).0,
                                                               attachments: [:]))
                
              
                
            }
            
            if (json[0]["type"].string! == "images"){
                
                var username : String = "shop"
                if (YelmChat.settings.chat.client == json[0]["from_whom"].int!){
                    username = YelmChat.settings.user
                }
                
                let json_image = json[0]["images"][0].string!
                
                
                YelmChat.objectWillChange.send()
                YelmChat.chat.messages.append(chat_message(id: json[0]["id"].int!,
                                                           user: chat_user(id: 0, name: username),
                                                           text: "",
                                                           time: self.get_time(date_time: json[0]["created_at"].string!).1,
                                                           date: self.get_time(date_time: json[0]["created_at"].string!).0,
                                                           attachments: ["image" : json_image]))
            }
            
            
            if (json[0]["type"].string! == "items"){
                
                var username : String = "shop"
                if (YelmChat.settings.chat.client == json[0]["from_whom"].int!){
                    username = YelmChat.settings.user
                }
                
                let item_AF = json[0]["items"]
                
                let price_AF = Float(item_AF["discount"].int!) / 100
                let discount_AF = item_AF["price"].float! * price_AF
                let discount_final = item_AF["price"].float! - discount_AF
                let final = discount_final
                
                let parameter_AF = item_AF["specification"]
                var parameters : [parameters_structure] = []
                
                if (parameter_AF.count > 0){
                    for k in 0...parameter_AF.count - 1 {
                        let parameter_single = parameter_AF[k]
                        let name = parameter_single["name"].string!
                        let value = parameter_single["value"].string!
                        parameters.append(parameters_structure(id: item_AF["id"].int!, name: name, value: value))
                    }
                }
                
                var images : [String] = []
                for k in 0...item_AF["images"].count-1{
                    images.append(item_AF["images"][k].string!)
                }
                
                let structure_ready = items_structure(id: item_AF["id"].int!,
                                                      title: item_AF["name"].string!,
                                                      price: String(format:"%.2f", item_AF["price"].float!),
                                                      text: item_AF["description"].string!,
                                                      thubnail: item_AF["preview_image"].string!,
                                                      price_float: item_AF["price"].float!,
                                                      all_images: images,
                                                      parameters: parameters,
                                                      type: item_AF["type"].string!,
                                                      quanity: "\(item_AF["unit_type"].int!)",
                                                      discount: String(format:"%.2f", final),
                                                      discount_value: item_AF["discount"].int!,
                                                      discount_present: "-\(item_AF["discount"].int!)%",
                                                      rating: item_AF["rating"].int!,
                                                      amount: item_AF["quantity"].int!)
                
                
                YelmChat.objectWillChange.send()
                YelmChat.chat.messages.append(chat_message(id: json[0]["id"].int!,
                                                           user: chat_user(id: 0, name: username),
                                                           text: "",
                                                           time: self.get_time(date_time: json[0]["created_at"].string!).1,
                                                           date: self.get_time(date_time: json[0]["created_at"].string!).0,
                                                           attachments: ["item" : "true"],
                                                           item: structure_ready))
                
                
                
            }
            
            
        }
        
        self.socket.on(clientEvent: .reconnect) { (data, ack) in
            DispatchQueue.main.async {
                YelmChat.objectWillChange.send()
                self.socket_state = true
            }
        }
        
        self.socket.on(clientEvent: .error) { (data, ack) in
            print("error_socket")
            
            DispatchQueue.main.async {
                YelmChat.objectWillChange.send()
                self.socket_state = false
            }
            
            
        }
        
        self.socket.on(clientEvent: .statusChange) { (data, emit) in
            
            if (self.socket.status == .connected){
                DispatchQueue.main.async {
                    YelmChat.objectWillChange.send()
                    self.socket_state = true
                }
                
            }
            
            if (self.socket.status == .disconnected){
                DispatchQueue.main.async {
                    YelmChat.objectWillChange.send()
                    self.socket_state = false
                }
            }
            
            if (self.socket.status == .notConnected){
                DispatchQueue.main.async {
                    YelmChat.objectWillChange.send()
                    self.socket_state = false
                }
            }
            
            if (self.socket.status == .connecting){
                DispatchQueue.main.async {
                    YelmChat.objectWillChange.send()
                    self.socket_state = false
                }
                
            }
            
            
        }
        
        self.socket.on(clientEvent: .disconnect) { (data, ack) in
            print("dis_connected")
        }
        
        self.socket.connect()
        
    }
    
    public func send(message: String, type: String){
        var json : [String : Any] = [:]
        
        switch type {
        case "images":
            
            var json_images : JSON = []
            let json_image : JSON = [
                "image" : message
            ]
            json_images.arrayObject?.append(json_image)
            
            
            json = [
                "room_id" : YelmChat.settings.chat.room_id,
                "message" : "",
                "type" : type,
                "platform" : YelmChat.settings.platform,
                "from_whom" : YelmChat.settings.chat.client,
                "to_whom" : YelmChat.settings.chat.shop,
                "images" : json_images.rawString(),
                "items" : "{}"
                
            ]
            
            self.socket.emit("room.\(YelmChat.settings.chat.room_id)", json)
            break
        case "text":
            json = [
                "room_id" : YelmChat.settings.chat.room_id,
                "message" : message,
                "type" : "message",
                "platform" : YelmChat.settings.platform,
                "from_whom" : YelmChat.settings.chat.client,
                "to_whom" : YelmChat.settings.chat.shop,
                "items" : "{}",
                "images" : "[]"
            ]
            
            self.socket.emit("room.\(YelmChat.settings.chat.room_id)", json)
            
            break
        case "basket":
            json = [
                "room_id" : YelmChat.settings.chat.room_id,
                "message" : message,
                "type" : "basket",
                "platform" : YelmChat.settings.platform,
                "from_whom" : YelmChat.settings.chat.client,
                "to_whom" : YelmChat.settings.chat.shop,
                "items" : "{}",
                "images" : "[]"
            ]
            
            self.socket.emit("room.\(YelmChat.settings.chat.room_id)", json)
            
            break
        default: break
            
        }
    }
    
    public func register(completionHandlerRegister: @escaping (_ success:Bool) -> Void){
        
        
        AF.request(YelmChat.settings.url(method: "chat", dev: true), method: .post).responseJSON { (response) in
            
            if (response.value != nil && response.response?.statusCode == 200) {
                
                let json = JSON(response.value!)
                
                if (YelmChat.settings.debug){
                    print(json)
                }
                
                YelmChat.settings.chat.api_token = json["api_token"].string!
                YelmChat.settings.chat.room_id = json["room_id"].int!
                YelmChat.settings.chat.shop = json["shop"].int!
                YelmChat.settings.chat.client = json["client"].int!
                
                
                
                DispatchQueue.main.async {
                    completionHandlerRegister(true)
                }
                
            }else{
                if (YelmChat.settings.debug && YelmChat.settings.internet()){
                    print(response.value!)
                }
            }
        }
        
    }
    
}
