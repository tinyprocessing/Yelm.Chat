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
                                    config: [.log(true),
                                             .forceNew(true),
                                             .connectParams(["token" : YelmChat.settings.chat.api_token, "room_id" : YelmChat.settings.chat.room_id]),
                                             .reconnectWait(1)
                                             ])
        self.socket = self.manager!.defaultSocket
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("connected")
        }
        
      
        self.socket.on("room.\(YelmChat.settings.chat.room_id)") { (data, emitter) in
            print(data)
            print(emitter)
            print("room.\(YelmChat.settings.chat.room_id)")
            
        }
        
        self.socket.on(clientEvent: .reconnect) { (data, ack) in
            YelmChat.objectWillChange.send()
            self.socket_state = true
        }
        
        self.socket.on(clientEvent: .error) { (data, ack) in
            print("error_socket")
            
            YelmChat.objectWillChange.send()
            self.socket_state = false
            
            
        }
        
        self.socket.on(clientEvent: .statusChange) { (data, emit) in
            
            if (self.socket.status == .connected){
                YelmChat.objectWillChange.send()
                self.socket_state = true
                
            }

            if (self.socket.status == .disconnected){
                YelmChat.objectWillChange.send()
                self.socket_state = false
                
            }

            if (self.socket.status == .notConnected){
                YelmChat.objectWillChange.send()
                self.socket_state = false
                
            }

            if (self.socket.status == .connecting){
                YelmChat.objectWillChange.send()
                self.socket_state = false
                
            }
            
            
        }
        
        self.socket.on(clientEvent: .disconnect) { (data, ack) in
            print("dis_connected")
        }
        
        self.socket.connect()

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
                YelmChat.settings.chat.from_whom = json["from_whom"].int!
                YelmChat.settings.chat.to_whom = json["to_whom"].int!
    
    
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
