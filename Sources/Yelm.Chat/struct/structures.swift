//
//  File.swift
//
//
//  Created by Michael on 30.01.2021.


import Foundation
import Photos
import SwiftUI
import UIKit
import Combine
import Yelm_Server

public struct chat_message: Identifiable, Hashable {

    public init(id: Int, user: chat_user = chat_user(id: 0), text: String = "", time: String = "", date: String = "", attachments: [String : String] = [:], asset: PHAsset? = nil, item: items_structure = items_structure()) {
        self.id = id
        self.user = user
        self.text = text
        self.time = time
        self.date = date
        self.attachments = attachments
        self.asset = asset
        self.item = item
    }

    public var id: Int
    public var user: chat_user = chat_user(id: 0)
    public var text: String = ""
    public var time: String = ""
    public var date: String = ""
    public var attachments : [String : String] = [:]
    public var asset : PHAsset? = nil
    public var item : items_structure = items_structure()
}


public struct chat_user: Identifiable, Hashable {

    public init(id: Int, name: String = "") {
        self.id = id
        self.name = name
    }

    public var id: Int
    public var name: String = ""
}
