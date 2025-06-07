//
//  Person.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

struct Person: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var name: String
    var email: String
    var profileImage: String? // System image name
    var role: String
    var groupId: String?
    
    // Custom coding keys to handle backend response format
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, groupId
        case profileImage
    }
    
    init(id: String = UUID().uuidString, name: String, email: String, profileImage: String? = nil, role: String, groupId: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.role = role
        self.groupId = groupId
    }
    
    static var sampleData: [Person] {
        [
            Person(id: "123E4567-E89B-12D3-A456-426614174000", name: "John Doe", email: "john@example.com", profileImage: "person.circle.fill", role: "Developer"),
            Person(id: "123E4567-E89B-12D3-A456-426614174001", name: "Jane Smith", email: "jane@example.com", profileImage: "person.circle", role: "Designer"),
            Person(id: "123E4567-E89B-12D3-A456-426614174002", name: "Mike Johnson", email: "mike@example.com", profileImage: "person.fill", role: "Project Manager"),
            Person(id: "123E4567-E89B-12D3-A456-426614174003", name: "Sarah Wilson", email: "sarah@example.com", profileImage: "person", role: "Tester")
        ]
    }
}