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
    
    
    public func server(host: String){
        
        let e : Echo = Echo(options: ["host": host, "auth": ["headers": ["Authorization": "Bearer " + YelmChat.settings.chat.api_token]]])

        e.connected(){ data, ack in
           
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
                YelmChat.settings.chat.from_whom = json["from_whom"].int!
                YelmChat.settings.chat.to_whom = json["to_whom"].int!
    
    
                DispatchQueue.main.async {
                    completionHandlerRegister(true)
                }

            }else{
                if (YelmChat.settings.debug){
                    print(response.value)
                }
            }
        }
        
    }
    
}
