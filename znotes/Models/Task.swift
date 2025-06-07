//
//  Task.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

// MARK: - Task Model
struct TaskItem: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    var tags: [String] = []
    var dueDate: Date?
    var assigneeId: String?
    var createdAt: Date
    var updatedAt: Date
    var trashedDate: Date? = nil
    
    init(id: String = UUID().uuidString, title: String, description: String, priority: Priority, status: TaskStatus, tags: [String] = [], dueDate: Date? = nil, assigneeId: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), trashedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.tags = tags
        self.dueDate = dueDate
        self.assigneeId = assigneeId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.trashedDate = trashedDate
    }
    
    static var sampleData: [TaskItem] {
        [
            TaskItem(
                id: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                title: "Implement User Authentication",
                description: "Add login and registration functionality to the app",
                priority: .high,
                status: .inProgress,
                tags: ["Authentication", "Security"],
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                assigneeId: "123E4567-E89B-12D3-A456-426614174000"
            ),
            TaskItem(
                id: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                title: "Design App Icon",
                description: "Create app icon variants for all required sizes",
                priority: .medium,
                status: .todo,
                tags: ["Design", "Assets"],
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                assigneeId: "123E4567-E89B-12D3-A456-426614174001"
            ),
            TaskItem(
                id: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC",
                title: "Update Documentation",
                description: "Update README and API documentation with latest changes",
                priority: .low,
                status: .inReview,
                tags: ["Documentation"],
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                assigneeId: "123E4567-E89B-12D3-A456-426614174002"
            )
        ]
    }
}
