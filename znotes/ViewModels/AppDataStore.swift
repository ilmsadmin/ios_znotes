//
//  AppDataStore.swift
//  znotes
//
//  Created on 6/6/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppDataStore: ObservableObject {
    @Published var notes: [Note] = []
    @Published var tasks: [Task] = []
    @Published var issues: [Issue] = []
    @Published var assignments: [Assignment] = []
    @Published var people: [Person] = []
    
    @Published var searchText: String = ""
    
    init(loadSampleData: Bool = true) {
        if loadSampleData {
            loadSample()
        }
    }
    
    private func loadSample() {
        people = Person.sampleData
        notes = Note.sampleData
        tasks = Task.sampleData
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
    
    func deleteNote(with id: UUID) {
        notes.removeAll { $0.id == id }
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
    }
    
    func deleteTask(with id: UUID) {
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
    
    func deleteIssue(with id: UUID) {
        issues.removeAll { $0.id == id }
    }
    
    func addComment(to issueID: UUID, comment: Comment) {
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
    
    func deleteAssignment(with id: UUID) {
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
    
    func deletePerson(with id: UUID) {
        people.removeAll { $0.id == id }
    }
    
    // MARK: - Helpers
    func getPerson(with id: UUID) -> Person? {
        return people.first(where: { $0.id == id })
    }
    
    func getTask(with id: UUID) -> Task? {
        return tasks.first(where: { $0.id == id })
    }
    
    func getIssue(with id: UUID) -> Issue? {
        return issues.first(where: { $0.id == id })
    }
    
    func getAssignment(with id: UUID) -> Assignment? {
        return assignments.first(where: { $0.id == id })
    }
    
    // MARK: - Filtered Results
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    var filteredIssues: [Issue] {
        if searchText.isEmpty {
            return issues
        } else {
            return issues.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
}