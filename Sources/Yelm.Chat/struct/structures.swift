//
//  File.swift
//  
//
//  Created by Michael on 30.01.2021.
//

import Foundation



public struct messages_structure: Identifiable, Hashable {
    public var id: Int
    /// message
    public var message: String = ""
    /// images
    public var images: String = ""

}
