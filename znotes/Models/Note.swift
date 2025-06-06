//
//  Note.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var tags: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    static var sampleData: [Note] {
        [
            Note(
                title: "SwiftUI Tips",
                content: "SwiftUI makes it easy to build beautiful user interfaces across all Apple platforms.",
                tags: ["SwiftUI", "iOS", "Development"],
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date().addingTimeInterval(-86400)
            ),
            Note(
                title: "Meeting Notes",
                content: "Discussed project timeline and resource allocation for Q3.",
                tags: ["Meeting", "Project"],
                createdAt: Date().addingTimeInterval(-86400 * 3),
                updatedAt: Date().addingTimeInterval(-86400 * 2)
            ),
            Note(
                title: "Ideas for New Features",
                content: "1. Cloud synchronization\n2. Dark mode support\n3. Export to PDF",
                tags: ["Features", "Development", "Planning"],
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date()
            )
        ]
    }
}