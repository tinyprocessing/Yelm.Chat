//
//  File.swift
//  
//
//  Created by Michael on 01.02.2021.
//

import Foundation
import SwiftUI
import Combine


public class ChatEngine: ObservableObject, Identifiable{
    public var id: Int = 0
    @Published public var keyboard: CGFloat = 0
    @Published public var messages : [chat_message] = []
    @Published public var animation : Bool = false
    
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboard_will_show),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboard_hide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboard_show),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
    }
    
    @objc func keyboard_will_show(_ notification: Notification) {
        
        if let frame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            keyboard = rect.height
            
        }
    }
    
    @objc func keyboard_show(_ notification: Notification) {
        self.bottom()
    
        
    }
    
    @objc func keyboard_hide(_ notification: Notification) {
        
        
        self.bottom()
      
    }
    
    public func bottom() {
        
        YelmChat.chat.animation = true
        YelmChat.objectWillChange.send()
        YelmChat.chat.messages.insert(chat_message(id: 1), at: 0)
//
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
//            YelmChat.objectWillChange.send()
//            YelmChat.chat.messages.removeFirst()
//        }
        
    }
    
}
