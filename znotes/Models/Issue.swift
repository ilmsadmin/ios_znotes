//
//  Issue.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI

struct Comment: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var content: String
    var authorID: UUID
    var createdAt: Date = Date()
}

struct Issue: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var priority: Priority
    var status: TaskStatus
    var tags: [String] = []
    var reporterID: UUID
    var assigneeID: UUID?
    var comments: [Comment] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    static var sampleData: [Issue] {
        [
            Issue(
                title: "App crashes on launch",
                description: "The app crashes when launched on iPhone SE devices running iOS 15",
                priority: .critical,
                status: .inProgress,
                tags: ["Crash", "iOS 15", "iPhone SE"],
                reporterID: Person.sampleData[3].id,
                assigneeID: Person.sampleData[0].id,
                comments: [
                    Comment(content: "I can reproduce this on my test device", authorID: Person.sampleData[0].id),
                    Comment(content: "Fixed in PR #123", authorID: Person.sampleData[0].id)
                ]
            ),
            Issue(
                title: "Login button unresponsive",
                description: "The login button sometimes doesn't respond when tapped",
                priority: .high,
                status: .todo,
                tags: ["UI", "Authentication"],
                reporterID: Person.sampleData[1].id,
                assigneeID: nil
            ),
            Issue(
                title: "Improve loading performance",
                description: "Initial app loading takes too long, need to optimize",
                priority: .medium,
                status: .inReview,
                tags: ["Performance", "Optimization"],
                reporterID: Person.sampleData[2].id,
                assigneeID: Person.sampleData[0].id,
                comments: [
                    Comment(content: "Added caching to improve load times", authorID: Person.sampleData[0].id)
                ]
            )
        ]
    }
}