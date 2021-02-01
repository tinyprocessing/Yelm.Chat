// API Chat Yelm Side


import Alamofire
import SwiftyJSON
import Combine
import SwiftUI
import Foundation




public var YelmChat: ChatIO = ChatIO()

public class ChatIO: ObservableObject, Identifiable {
    public var id: Int = 0
    @Published public var settings : Settings =  Settings()
    @Published public var core : Core =  Core()
    @Published public var chat : ChatEngine = ChatEngine()
    
    
    public func start(platform : String, user: String,  completionHandlerStart: @escaping (_ success:Bool) -> Void){

        self.settings.platform = platform
        self.settings.user = user
        
        DispatchQueue.main.async {
            completionHandlerStart(true)
        }
        
        
    }
}
