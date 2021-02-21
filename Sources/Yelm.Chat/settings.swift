//
//  File.swift
//  
//
//  Created by Michael on 30.01.2021.
//

import Foundation
import Alamofire
import SwiftUI
import SwiftyJSON
import SystemConfiguration


let version : String = "3.0"


public class Chat: ObservableObject, Identifiable {
    public var id: Int = 0
    
    public var api_token : String = ""
    public var room_id : Int = 0
    public var client : Int = 0
    public var shop : Int = 0
}

public class Settings: ObservableObject, Identifiable {
    var domain : String = "https://rest.yelm.io/api/mobile/"
    var domain_beta : String = "https://dev.yelm.io/api/mobile/"
    
    
    private var develope : Bool = false

    
    public var id: Int = 0
    public var platform : String = ""
    public var debug : Bool = false
    public var position : String = ""
    public var user : String = ""
    public var chat : Chat =  Chat()
    
    /// Get url to connect rest api
    /// - Parameter method: Method Name - example m-application
    /// - Returns: Ready string
    
    func url(method: String, dev: Bool = false) -> String {
        var url : String = ""
        if (Locale.current.regionCode != nil && Locale.current.languageCode != nil){
            
            if (self.develope == false){
                url = self.domain
            }else{
                url = self.domain_beta
            }
           
            url += method
            url += "?version=\(version)&region_code=\(Locale.current.regionCode!)&language_code=\(Locale.current.languageCode!)&platform=\(self.platform)"
            if (self.position == ""){
                url += "&lat=0&lon=0"
            }else{
                url += ("&"+position)
            }
            
            url += "&login=\(self.user)"
          
            
        }else{

            if (self.develope == false){
                url = self.domain
            }else{
                url = self.domain_beta
            }
            
            url += method
            url += "?version=\(version)&region_code=US&language_code=en&platform=\(self.platform)"
            if (self.position == ""){
                url += "&lat=0&lon=0"
            }else{
                url += ("&"+position)
            }
            
            url += "&login=\(self.user)"
            
        }
        
        if (self.debug){
            print(url)
        }
        return url
    }
    
    
    func internet() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(SCNetworkReachabilityCreateWithName(nil, "https://yelm.io")!, &flags)
        
        let reachable = flags.contains(.reachable)
        let connection = flags.contains(.connectionRequired)
        let automated = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let connection_noninteraction = automated && !flags.contains(.interventionRequired)
        
       return reachable && (!connection || connection_noninteraction)
    }
    
}
