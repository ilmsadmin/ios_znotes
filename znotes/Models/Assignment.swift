//
//  Assignment.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

enum AssignmentType: String, Codable, CaseIterable, Identifiable {
    case task = "Task"
    case issue = "Issue"
    
    var id: String { self.rawValue }
}

struct Assignment: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var type: AssignmentType
    var itemID: UUID // ID của Task hoặc Issue
    var personID: UUID
    var dueDate: Date?
    var notes: String?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    static var sampleData: [Assignment] {
        [
            Assignment(
                type: .task,
                itemID: Task.sampleData[0].id,
                personID: Person.sampleData[0].id,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                notes: "High priority task for the release"
            ),
            Assignment(
                type: .task,
                itemID: Task.sampleData[1].id,
                personID: Person.sampleData[1].id,
                dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                notes: "Required for App Store submission"
            ),
            Assignment(
                type: .issue,
                itemID: Issue.sampleData[0].id,
                personID: Person.sampleData[0].id,
                dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                notes: "Critical issue affecting production"
            )
        ]
    }
}