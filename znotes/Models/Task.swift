//
//  Task.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case inReview = "In Review"
    case done = "Done"
    case cancelled = "Cancelled"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .todo: return .gray
        case .inProgress: return .blue
        case .inReview: return .orange
        case .done: return .green
        case .cancelled: return .red
        }
    }
}

struct Task: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    var tags: [String] = []
    var dueDate: Date?
    var assigneeID: UUID?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    static var sampleData: [Task] {
        [
            Task(
                title: "Implement User Authentication",
                description: "Add login and registration functionality to the app",
                priority: .high,
                status: .inProgress,
                tags: ["Authentication", "Security"],
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                assigneeID: Person.sampleData[0].id
            ),
            Task(
                title: "Design App Icon",
                description: "Create app icon variants for all required sizes",
                priority: .medium,
                status: .todo,
                tags: ["Design", "Assets"],
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                assigneeID: Person.sampleData[1].id
            ),
            Task(
                title: "Update Documentation",
                description: "Update README and API documentation with latest changes",
                priority: .low,
                status: .inReview,
                tags: ["Documentation"],
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                assigneeID: Person.sampleData[2].id
            )
        ]
    }
}