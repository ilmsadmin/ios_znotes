//
//  Issue.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

// MARK: - Comment Model

struct Comment: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var content: String
    var authorId: String
    var createdAt: Date
    
    init(id: String = UUID().uuidString, content: String, authorId: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.authorId = authorId
        self.createdAt = createdAt
    }
}

struct Issue: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    var tags: [String] = []
    var reporterId: String
    var assigneeId: String?
    var comments: [Comment] = []
    var createdAt: Date
    var updatedAt: Date
    var trashedDate: Date? = nil
    
    init(id: String = UUID().uuidString, title: String, description: String, priority: Priority, status: TaskStatus, tags: [String] = [], reporterId: String, assigneeId: String? = nil, comments: [Comment] = [], createdAt: Date = Date(), updatedAt: Date = Date(), trashedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.tags = tags
        self.reporterId = reporterId
        self.assigneeId = assigneeId
        self.comments = comments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.trashedDate = trashedDate
    }
    
    static var sampleData: [Issue] {
        [
            Issue(
                id: "ISSUE-001",
                title: "App crashes on launch",
                description: "The app crashes when launched on iPhone SE devices running iOS 15",
                priority: .critical,
                status: .inProgress,
                tags: ["Crash", "iOS 15", "iPhone SE"],
                reporterId: "123E4567-E89B-12D3-A456-426614174003",
                assigneeId: "123E4567-E89B-12D3-A456-426614174000",
                comments: [
                    Comment(content: "I can reproduce this on my test device", authorId: "123E4567-E89B-12D3-A456-426614174000"),
                    Comment(content: "Fixed in PR #123", authorId: "123E4567-E89B-12D3-A456-426614174000")
                ]
            ),
            Issue(
                id: "ISSUE-002",
                title: "Login button unresponsive",
                description: "The login button sometimes doesn't respond when tapped",
                priority: .high,
                status: .todo,
                tags: ["UI", "Authentication"],
                reporterId: "123E4567-E89B-12D3-A456-426614174001",
                assigneeId: "123E4567-E89B-12D3-A456-426614174001"
            ),
            Issue(
                id: "ISSUE-003",
                title: "Improve loading performance",
                description: "Initial app loading takes too long, need to optimize",
                priority: .medium,
                status: .inReview,
                tags: ["Performance", "Optimization"],
                reporterId: "123E4567-E89B-12D3-A456-426614174002",
                assigneeId: "123E4567-E89B-12D3-A456-426614174000",
                comments: [
                    Comment(content: "Added caching to improve load times", authorId: "123E4567-E89B-12D3-A456-426614174000")
                ]
            )
        ]
    }
}
