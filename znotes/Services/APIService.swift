//
//  APIService.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Notes API
    func fetchNotes() async throws -> [Note] {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.notes,
            method: .GET,
            responseType: [Note].self,
            requiresAuth: true
        )
    }
    
    func createNote(_ note: CreateNoteRequest) async throws -> Note {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.notes,
            method: .POST,
            body: note,
            responseType: Note.self,
            requiresAuth: true
        )
    }
    
    func updateNote(_ note: UpdateNoteRequest, id: String) async throws -> Note {
        return try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.notes)/\(id)",
            method: .PUT,
            body: note,
            responseType: Note.self,
            requiresAuth: true
        )
    }
    
    func deleteNote(id: String) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.notes)/\(id)",
            method: .DELETE,
            responseType: EmptyResponse.self,
            requiresAuth: true
        )
    }
    
    // MARK: - Tasks API
    func fetchTasks() async throws -> [TaskItem] {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasks,
            method: .GET,
            responseType: [TaskItem].self,
            requiresAuth: true
        )
    }
    
    func createTask(_ task: CreateTaskRequest) async throws -> TaskItem {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.tasks,
            method: .POST,
            body: task,
            responseType: TaskItem.self,
            requiresAuth: true
        )
    }
    
    func updateTask(_ task: UpdateTaskRequest, id: String) async throws -> TaskItem {
        return try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.tasks)/\(id)",
            method: .PUT,
            body: task,
            responseType: TaskItem.self,
            requiresAuth: true
        )
    }
    
    func deleteTask(id: String) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.tasks)/\(id)",
            method: .DELETE,
            responseType: EmptyResponse.self,
            requiresAuth: true
        )
    }
    
    // MARK: - Issues API
    func fetchIssues() async throws -> [Issue] {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.issues,
            method: .GET,
            responseType: [Issue].self,
            requiresAuth: true
        )
    }
    
    func createIssue(_ issue: CreateIssueRequest) async throws -> Issue {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.issues,
            method: .POST,
            body: issue,
            responseType: Issue.self,
            requiresAuth: true
        )
    }
    
    func updateIssue(_ issue: UpdateIssueRequest, id: String) async throws -> Issue {
        return try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.issues)/\(id)",
            method: .PUT,
            body: issue,
            responseType: Issue.self,
            requiresAuth: true
        )
    }
    
    func deleteIssue(id: String) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.issues)/\(id)",
            method: .DELETE,
            responseType: EmptyResponse.self,
            requiresAuth: true
        )
    }
    
    // MARK: - Assignments API
    func fetchAssignments() async throws -> [Assignment] {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.assignments,
            method: .GET,
            responseType: [Assignment].self,
            requiresAuth: true
        )
    }
    
    func createAssignment(_ assignment: CreateAssignmentRequest) async throws -> Assignment {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.assignments,
            method: .POST,
            body: assignment,
            responseType: Assignment.self,
            requiresAuth: true
        )
    }
    
    func updateAssignment(_ assignment: UpdateAssignmentRequest, id: String) async throws -> Assignment {
        return try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.assignments)/\(id)",
            method: .PATCH,
            body: assignment,
            responseType: Assignment.self,
            requiresAuth: true
        )
    }
    
    func deleteAssignment(id: String) async throws {
        let _: EmptyResponse = try await networkManager.request(
            endpoint: "\(APIConfig.Endpoints.assignments)/\(id)",
            method: .DELETE,
            responseType: EmptyResponse.self,
            requiresAuth: true
        )
    }
    
    // MARK: - Users API
    func fetchUsers() async throws -> [Person] {
        return try await networkManager.request(
            endpoint: APIConfig.Endpoints.users,
            method: .GET,
            responseType: [Person].self,
            requiresAuth: true
        )
    }
}

// MARK: - Request/Response Models

struct EmptyResponse: Codable {}
