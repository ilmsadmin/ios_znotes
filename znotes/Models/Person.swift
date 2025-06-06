//
//  Person.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

struct Person: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var profileImage: String? // Tên của system image
    var role: String
    
    static var sampleData: [Person] {
        [
            Person(name: "John Doe", email: "john@example.com", profileImage: "person.circle.fill", role: "Developer"),
            Person(name: "Jane Smith", email: "jane@example.com", profileImage: "person.circle", role: "Designer"),
            Person(name: "Mike Johnson", email: "mike@example.com", profileImage: "person.fill", role: "Project Manager"),
            Person(name: "Sarah Wilson", email: "sarah@example.com", profileImage: "person", role: "Tester")
        ]
    }
}