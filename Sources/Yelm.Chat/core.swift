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

public class Core: ObservableObject, Identifiable {
    public var id: Int = 0
    
    var manager : SocketManager?
    var socket : SocketIOClient!
    
    @Published public var socket_state : Bool = false
    
    public func get(){
        
    }
    
   
    
    public func server(host: String){
       
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
        
      
        self.socket.on("room.\(YelmChat.settings.chat.room_id)") { (data, emitter) in
            print(data)
            print(emitter)
            print("room.\(YelmChat.settings.chat.room_id)")
            
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
                "images" : json_images.rawString()
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
                "to_whom" : YelmChat.settings.chat.shop
                ]
            
            self.socket.emit("room.\(YelmChat.settings.chat.room_id)", json)
            
            break
        default: break
            
        }
    }
    
    public func register(completionHandlerRegister: @escaping (_ success:Bool) -> Void){
        
        print(YelmChat.settings.url(method: "chat", dev: true))
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
