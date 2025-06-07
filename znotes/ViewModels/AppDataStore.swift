//
//  AppDataStore.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Date Extension for API
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

@MainActor
class AppDataStore: ObservableObject {
    // MARK: - Published Properties
    @Published var notes: [Note] = []
    @Published var tasks: [TaskItem] = []
    @Published var issues: [Issue] = []
    @Published var assignments: [Assignment] = []
    @Published var people: [Person] = []
    
    // Trash bin storage
    @Published var trashedNotes: [Note] = []
    @Published var trashedTasks: [TaskItem] = []
    @Published var trashedIssues: [Issue] = []
    @Published var showTrashBin = false
    
    @Published var searchText: String = ""
    
    // Loading states
    @Published var isLoadingNotes = false
    @Published var isLoadingTasks = false
    @Published var isLoadingIssues = false
    @Published var isLoadingAssignments = false
    @Published var isLoadingPeople = false
    
    // Error handling
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    // Date formatter for API calls
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    init(loadSampleData: Bool = true) {
        if loadSampleData {
            loadSample()
        } else {
            // Load data from API when user is authenticated
            Task {
                await loadAllData()
            }
        }
    }
    
    // MARK: - API Data Loading
    func loadAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadNotes() }
            group.addTask { await self.loadTasks() }
            group.addTask { await self.loadIssues() }
            group.addTask { await self.loadAssignments() }
            group.addTask { await self.loadPeople() }
        }
    }
    
    func loadNotes() async {
        isLoadingNotes = true
        errorMessage = nil
        
        do {
            let fetchedNotes = try await apiService.fetchNotes()
            notes = fetchedNotes
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
        }
        
        isLoadingNotes = false
    }
    
    func loadTasks() async {
        isLoadingTasks = true
        errorMessage = nil
        
        do {
            let fetchedTasks = try await apiService.fetchTasks()
            tasks = fetchedTasks
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        
        isLoadingTasks = false
    }
    
    func loadIssues() async {
        isLoadingIssues = true
        errorMessage = nil
        
        do {
            let fetchedIssues = try await apiService.fetchIssues()
            issues = fetchedIssues
        } catch {
            errorMessage = "Failed to load issues: \(error.localizedDescription)"
        }
        
        isLoadingIssues = false
    }
    
    func loadAssignments() async {
        isLoadingAssignments = true
        errorMessage = nil
        
        do {
            let fetchedAssignments = try await apiService.fetchAssignments()
            assignments = fetchedAssignments
        } catch {
            errorMessage = "Failed to load assignments: \(error.localizedDescription)"
        }
        
        isLoadingAssignments = false
    }
    
    func loadPeople() async {
        isLoadingPeople = true
        errorMessage = nil
        
        do {
            let fetchedPeople = try await apiService.fetchUsers()
            people = fetchedPeople
        } catch {
            errorMessage = "Failed to load people: \(error.localizedDescription)"
        }
        
        isLoadingPeople = false
    }
    
    private func loadSample() {
        people = Person.sampleData
        notes = Note.sampleData
        tasks = TaskItem.sampleData
        issues = Issue.sampleData
        assignments = Assignment.sampleData
    }
    
    // MARK: - Note Management
    func addNote(_ note: Note) {
        notes.append(note)
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        }
    }
    
    func deleteNote(at indexSet: IndexSet) {
        notes.remove(atOffsets: indexSet)
    }
    
    func deleteNote(with id: String) {
        notes.removeAll { $0.id == id }
    }
    
    // MARK: - Task Management
    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }
    
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
    }
    
    func deleteTask(with id: String) {
        tasks.removeAll { $0.id == id }
    }
    
    // MARK: - Issue Management
    func addIssue(_ issue: Issue) {
        issues.append(issue)
    }
    
    func updateIssue(_ issue: Issue) {
        if let index = issues.firstIndex(where: { $0.id == issue.id }) {
            issues[index] = issue
        }
    }
    
    func deleteIssue(at indexSet: IndexSet) {
        issues.remove(atOffsets: indexSet)
    }
    
    func deleteIssue(with id: String) {
        issues.removeAll { $0.id == id }
    }
    
    func addComment(to issueID: String, comment: Comment) {
        if let index = issues.firstIndex(where: { $0.id == issueID }) {
            issues[index].comments.append(comment)
            issues[index].updatedAt = Date()
        }
    }
    
    // MARK: - Assignment Management
    func addAssignment(_ assignment: Assignment) {
        assignments.append(assignment)
    }
    
    func updateAssignment(_ assignment: Assignment) {
        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index] = assignment
        }
    }
    
    func deleteAssignment(at indexSet: IndexSet) {
        assignments.remove(atOffsets: indexSet)
    }
    
    func deleteAssignment(with id: String) {
        assignments.removeAll { $0.id == id }
    }
    
    // MARK: - Person Management
    func addPerson(_ person: Person) {
        people.append(person)
    }
    
    func updatePerson(_ person: Person) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = person
        }
    }
    
    func deletePerson(at indexSet: IndexSet) {
        people.remove(atOffsets: indexSet)
    }
    
    func deletePerson(with id: String) {
        people.removeAll { $0.id == id }
    }
    
    // MARK: - Helpers
    func getPerson(with id: String) -> Person? {
        return people.first(where: { $0.id == id })
    }
    
    func getTask(with id: String) -> TaskItem? {
        return tasks.first(where: { $0.id == id })
    }
    
    func getIssue(with id: String) -> Issue? {
        return issues.first(where: { $0.id == id })
    }
    
    func getAssignment(with id: String) -> Assignment? {
        return assignments.first(where: { $0.id == id })
    }
    
    // MARK: - Search Filtered Results
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            note.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            task.description.localizedCaseInsensitiveContains(searchText) ||
            task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            task.priority.rawValue.localizedCaseInsensitiveContains(searchText) ||
            task.status.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredIssues: [Issue] {
        if searchText.isEmpty {
            return issues
        }
        return issues.filter { issue in
            issue.title.localizedCaseInsensitiveContains(searchText) ||
            issue.description.localizedCaseInsensitiveContains(searchText) ||
            issue.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            issue.priority.rawValue.localizedCaseInsensitiveContains(searchText) ||
            issue.status.rawValue.localizedCaseInsensitiveContains(searchText) ||
            issue.comments.contains { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Trash Management
    // Helper properties for trash status
    var hasTrashItems: Bool {
        return !trashedNotes.isEmpty || !trashedTasks.isEmpty || !trashedIssues.isEmpty
    }
    
    var totalTrashCount: Int {
        return trashedNotes.count + trashedTasks.count + trashedIssues.count
    }
    
    func emptyTrash() {
        trashedNotes.removeAll()
        trashedTasks.removeAll()
        trashedIssues.removeAll()
    }
    
    // Note trash operations
    func moveNoteToTrash(_ note: Note) {
        var trashedNote = note
        trashedNote.trashedDate = Date()
        trashedNotes.append(trashedNote)
    }
    
    func restoreNoteFromTrash(_ note: Note) {
        if let index = trashedNotes.firstIndex(where: { $0.id == note.id }) {
            var restoredNote = trashedNotes[index]
            restoredNote.trashedDate = nil
            notes.append(restoredNote)
            trashedNotes.remove(at: index)
        }
    }
    
    func permanentlyDeleteNote(_ note: Note) {
        trashedNotes.removeAll { $0.id == note.id }
    }
    
    // Task trash operations
    func moveTaskToTrash(_ task: TaskItem) {
        var trashedTask = task
        trashedTask.trashedDate = Date()
        trashedTasks.append(trashedTask)
    }
    
    func restoreTaskFromTrash(_ task: TaskItem) {
        if let index = trashedTasks.firstIndex(where: { $0.id == task.id }) {
            var restoredTask = trashedTasks[index]
            restoredTask.trashedDate = nil
            tasks.append(restoredTask)
            trashedTasks.remove(at: index)
        }
    }
    
    func permanentlyDeleteTask(_ task: TaskItem) {
        trashedTasks.removeAll { $0.id == task.id }
    }
    
    // Issue trash operations
    func moveIssueToTrash(_ issue: Issue) {
        var trashedIssue = issue
        trashedIssue.trashedDate = Date()
        trashedIssues.append(trashedIssue)
    }
    
    func restoreIssueFromTrash(_ issue: Issue) {
        if let index = trashedIssues.firstIndex(where: { $0.id == issue.id }) {
            var restoredIssue = trashedIssues[index]
            restoredIssue.trashedDate = nil
            issues.append(restoredIssue)
            trashedIssues.remove(at: index)
        }
    }
    
    func permanentlyDeleteIssue(_ issue: Issue) {
        trashedIssues.removeAll { $0.id == issue.id }
    }
    
    // MARK: - Filtered Trash Results
    var filteredTrashedNotes: [Note] {
        if searchText.isEmpty {
            return trashedNotes
        } else {
            return trashedNotes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    var filteredTrashedTasks: [TaskItem] {
        if searchText.isEmpty {
            return trashedTasks
        } else {
            return trashedTasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    var filteredTrashedIssues: [Issue] {
        if searchText.isEmpty {
            return trashedIssues
        } else {
            return trashedIssues.filter { issue in
                issue.title.localizedCaseInsensitiveContains(searchText) ||
                issue.description.localizedCaseInsensitiveContains(searchText) ||
                issue.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    // MARK: - Note Management (API-backed)
    func addNote(_ note: Note) async {
        do {
            let request = CreateNoteRequest(
                title: note.title,
                content: note.content,
                categoryId: nil // TODO: Add category support
            )
            let createdNote = try await apiService.createNote(request)
            notes.append(createdNote)
        } catch {
            errorMessage = "Failed to create note: \(error.localizedDescription)"
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            let request = UpdateNoteRequest(
                title: note.title,
                content: note.content,
                categoryId: nil
            )
            let updatedNote = try await apiService.updateNote(request, id: note.id)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = updatedNote
            }
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
    
    func deleteNote(with id: String) async {
        do {
            try await apiService.deleteNote(id: id)
            notes.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Task Management (API-backed)
    func addTask(_ task: TaskItem) async {
        do {
            let request = CreateTaskRequest(
                title: task.title,
                description: task.description,
                priority: task.priority.rawValue,
                status: task.status.rawValue,
                tags: task.tags,
                dueDate: task.dueDate?.iso8601String,
                assigneeId: task.assigneeId
            )
            let createdTask = try await apiService.createTask(request)
            tasks.append(createdTask)
        } catch {
            errorMessage = "Failed to create task: \(error.localizedDescription)"
        }
    }
    
    func updateTask(_ task: TaskItem) async {
        do {
            let request = UpdateTaskRequest(
                title: task.title,
                description: task.description,
                priority: task.priority.rawValue,
                status: task.status.rawValue,
                tags: task.tags,
                dueDate: task.dueDate?.iso8601String,
                assigneeId: task.assigneeId
            )
            let updatedTask = try await apiService.updateTask(request, id: task.id)
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = updatedTask
            }
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }
    
    func deleteTask(with id: String) async {
        do {
            try await apiService.deleteTask(id: id)
            tasks.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Issue Management (API-backed)
    func addIssue(_ issue: Issue) async {
        do {
            let request = CreateIssueRequest(
                title: issue.title,
                description: issue.description,
                priority: issue.priority.rawValue,
                status: issue.status.rawValue,
                tags: issue.tags,
                reporterId: issue.reporterId,
                assigneeId: issue.assigneeId
            )
            let createdIssue = try await apiService.createIssue(request)
            issues.append(createdIssue)
        } catch {
            errorMessage = "Failed to create issue: \(error.localizedDescription)"
        }
    }
    
    func updateIssue(_ issue: Issue) async {
        do {
            let request = UpdateIssueRequest(
                title: issue.title,
                description: issue.description,
                priority: issue.priority.rawValue,
                status: issue.status.rawValue,
                tags: issue.tags,
                assigneeId: issue.assigneeId
            )
            let updatedIssue = try await apiService.updateIssue(request, id: issue.id)
            if let index = issues.firstIndex(where: { $0.id == issue.id }) {
                issues[index] = updatedIssue
            }
        } catch {
            errorMessage = "Failed to update issue: \(error.localizedDescription)"
        }
    }
    
    func deleteIssue(with id: String) async {
        do {
            try await apiService.deleteIssue(id: id)
            issues.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete issue: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Assignment Management (API-backed)
    func addAssignment(_ assignment: Assignment) async {
        do {
            let request = CreateAssignmentRequest(
                type: assignment.type.rawValue,
                itemId: assignment.itemId,
                personId: assignment.personId,
                description: assignment.notes
            )
            let createdAssignment = try await apiService.createAssignment(request)
            assignments.append(createdAssignment)
        } catch {
            errorMessage = "Failed to create assignment: \(error.localizedDescription)"
        }
    }
    
    func updateAssignment(_ assignment: Assignment) async {
        do {
            let request = UpdateAssignmentRequest(
                type: assignment.type.rawValue,
                itemId: assignment.itemId,
                personId: assignment.personId,
                description: assignment.notes
            )
            let updatedAssignment = try await apiService.updateAssignment(request, id: assignment.id)
            if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
                assignments[index] = updatedAssignment
            }
        } catch {
            errorMessage = "Failed to update assignment: \(error.localizedDescription)"
        }
    }
    
    func deleteAssignment(with id: String) async {
        do {
            try await apiService.deleteAssignment(id: id)
            assignments.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete assignment: \(error.localizedDescription)"
        }
    }
}
