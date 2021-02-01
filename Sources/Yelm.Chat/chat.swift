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
    
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboard_show),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    @objc func keyboard_show(_ notification: Notification) {
        if let frame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            keyboard = rect.height
        }
    }
    
}
