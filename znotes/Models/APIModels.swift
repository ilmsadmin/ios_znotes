//
//  APIModels.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation

// MARK: - Note API Models
struct CreateNoteRequest: Codable {
    let title: String
    let content: String
    let categoryId: String?
}

struct UpdateNoteRequest: Codable {
    let title: String
    let content: String
    let categoryId: String?
}

// MARK: - Task API Models
struct CreateTaskRequest: Codable {
    let title: String
    let description: String
    let priority: String
    let status: String
    let tags: [String]?
    let dueDate: String?
    let assigneeId: String?
}

struct UpdateTaskRequest: Codable {
    let title: String
    let description: String
    let priority: String
    let status: String
    let tags: [String]?
    let dueDate: String?
    let assigneeId: String?
}

// MARK: - Issue API Models
struct CreateIssueRequest: Codable {
    let title: String
    let description: String
    let priority: String
    let status: String
    let tags: [String]?
    let reporterId: String
    let assigneeId: String?
}

struct UpdateIssueRequest: Codable {
    let title: String
    let description: String
    let priority: String
    let status: String
    let tags: [String]?
    let assigneeId: String?
}

// MARK: - Assignment API Models
struct CreateAssignmentRequest: Codable {
    let type: String
    let itemId: String
    let personId: String
    let description: String?
}

struct UpdateAssignmentRequest: Codable {
    let type: String
    let itemId: String
    let personId: String
    let description: String?
}
