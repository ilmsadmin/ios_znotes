//
//  Assignment.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation

enum AssignmentType: String, CaseIterable, Codable, Identifiable {
    case task = "Task"
    case issue = "Issue"
    
    var id: String { rawValue }
}

struct Assignment: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var type: AssignmentType
    var itemId: String  // ID of the Task or Issue being assigned
    var personId: String  // ID of the person assigned
    var dueDate: Date?
    var notes: String?
    var createdById: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, type: AssignmentType, itemId: String, personId: String, dueDate: Date? = nil, notes: String? = nil, createdById: String, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.itemId = itemId
        self.personId = personId
        self.dueDate = dueDate
        self.notes = notes
        self.createdById = createdById
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static var sampleData: [Assignment] {
        [
            Assignment(
                id: "ASSIGNMENT-AAA-BBB-CCC-DDD",
                type: .task,
                itemId: "TASK-AAA-BBB-CCC-DDD",
                personId: "123E4567-E89B-12D3-A456-426614174000",
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
                notes: "High priority task for Q1 deliverable",
                createdById: "CREATOR-AAA-BBB-CCC-DDD"
            ),
            Assignment(
                id: "ASSIGNMENT-EEE-FFF-GGG-HHH",
                type: .issue,
                itemId: "ISSUE-EEE-FFF-GGG-HHH",
                personId: "123E4567-E89B-12D3-A456-426614174001",
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                notes: "Critical bug that needs immediate attention",
                createdById: "CREATOR-EEE-FFF-GGG-HHH"
            ),
            Assignment(
                id: "ASSIGNMENT-III-JJJ-KKK-LLL",
                type: .task,
                itemId: "TASK-III-JJJ-KKK-LLL",
                personId: "123E4567-E89B-12D3-A456-426614174002",
                dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
                notes: "Presentation for quarterly review meeting",
                createdById: "CREATOR-III-JJJ-KKK-LLL"
            )
        ]
    }
}