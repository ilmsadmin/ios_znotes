//
//  Note.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Codable, Hashable, Sendable {
    var id: String = UUID().uuidString
    var title: String
    var content: String
    var tags: [String] = []
    // var author: Person?
    var authorId: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var trashedDate: Date? = nil
    
    // Custom coding keys to handle backend response format
    enum CodingKeys: String, CodingKey {
        case id, title, content, tags
        // case author
        case authorId
        case createdAt, updatedAt
    }
    
    init(id: String = UUID().uuidString, title: String, content: String, tags: [String] = [], authorId: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), trashedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.authorId = authorId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.trashedDate = trashedDate
    }
    
    // Convenience initializer for simple creation
    init(title: String, content: String) {
        self.init(title: title, content: content, tags: [], authorId: nil, createdAt: Date(), updatedAt: Date())
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as string
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        // self.author = try container.decodeIfPresent(Person.self, forKey: .author)
        self.authorId = try container.decodeIfPresent(String.self, forKey: .authorId)
        
        // Handle date parsing
        let dateFormatter = ISO8601DateFormatter()
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            self.createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            self.updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(tags, forKey: .tags)
        // try container.encodeIfPresent(author, forKey: .author)
        try container.encodeIfPresent(authorId, forKey: .authorId)
        
        let dateFormatter = ISO8601DateFormatter()
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
    }
    
    // Manual Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    static var sampleData: [Note] {
        var note1 = Note(title: "SwiftUI Tips", content: "SwiftUI makes it easy to build beautiful user interfaces across all Apple platforms.")
        note1.tags = ["SwiftUI", "iOS", "Development"]
        note1.createdAt = Date().addingTimeInterval(-86400 * 7)
        note1.updatedAt = Date().addingTimeInterval(-86400)
        
        var note2 = Note(title: "Meeting Notes", content: "Discussed project timeline and resource allocation for Q3.")
        note2.tags = ["Meeting", "Project"]
        note2.createdAt = Date().addingTimeInterval(-86400 * 3)
        note2.updatedAt = Date().addingTimeInterval(-86400 * 2)
        
        var note3 = Note(title: "Ideas for New Features", content: "1. Cloud synchronization\n2. Dark mode support\n3. Export to PDF")
        note3.tags = ["Features", "Development", "Planning"]
        note3.createdAt = Date().addingTimeInterval(-86400)
        note3.updatedAt = Date()
        
        return [note1, note2, note3]
    }
}
