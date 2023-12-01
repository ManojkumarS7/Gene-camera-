//
//  users.swift
//  Gene
//
//  Created by manoj on 17/11/23.
//

import Foundation

// Define a structure to represent user data
struct UserData: Codable {
    var username: String
    var likesCount: Int
    var userCount: Int
    var comments: [String]
    var imageLink: String  // New property for image link
    
    // Additional properties or methods if needed
    
    // Convert the structure to JSON
    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(self)
            return jsonData
        } catch {
            print("Error encoding user data to JSON: \(error)")
            return nil
        }
    }
}

