// API Chat Yelm Side


import Alamofire
import SwiftyJSON
import Combine
import SwiftUI
import Foundation




public let YelmChat: ChatIO = ChatIO()

open class ChatIO: ObservableObject, Identifiable {
    public var id: Int = 0
    public var settings : Settings =  Settings()
    public var core : Core =  Core()
    
    
    
    public func start(platform : String, user: String,  completionHandlerStart: @escaping (_ success:Bool) -> Void){

        self.settings.platform = platform
        self.settings.user = user
        
        DispatchQueue.main.async {
            completionHandlerStart(true)
        }
        
        
    }
}
