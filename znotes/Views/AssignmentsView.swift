//
//  AssignmentsView.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI

struct AssignmentsView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var selectedType: AssignmentType?
    @State private var selectedPersonID: UUID?
    
    var body: some View {
        NavigationView {
            VStack {
                // Type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }
                        
                        ForEach(AssignmentType.allCases) { type in
                            FilterButton(title: type.rawValue, isSelected: selectedType == type) {
                                selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)
                
                // Person filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All People", isSelected: selectedPersonID == nil) {
                            selectedPersonID = nil
                        }
                        
                        ForEach(dataStore.people) { person in
                            FilterButton(title: person.name, isSelected: selectedPersonID == person.id) {
                                selectedPersonID = person.id
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)
                
                // Assignments list
                List {
                    ForEach(filteredAssignments) { assignment in
                        NavigationLink {
                            AssignmentDetailView(assignment: assignment)
                        } label: {
                            AssignmentRowView(assignment: assignment)
                        }
                    }
                    .onDelete(perform: deleteAssignments)
                }
                .searchable(text: $searchText, prompt: "Search assignments")
            }
            .navigationTitle("Assignments")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Label("Add Assignment", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AssignmentFormView(mode: .add)
            }
        }
    }
    
    var filteredAssignments: [Assignment] {
        var assignments = dataStore.assignments
        
        // Apply type filter
        if let type = selectedType {
            assignments = assignments.filter { $0.type == type }
        }
        
        // Apply person filter
        if let personID = selectedPersonID {
            assignments = assignments.filter { $0.personID == personID }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            assignments = assignments.filter { assignment in
                if let notes = assignment.notes, notes.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                
                // Search in related task/issue
                switch assignment.type {
                case .task:
                    if let task = dataStore.getTask(with: assignment.itemID) {
                        return task.title.localizedCaseInsensitiveContains(searchText) ||
                               task.description.localizedCaseInsensitiveContains(searchText)
                    }
                case .issue:
                    if let issue = dataStore.getIssue(with: assignment.itemID) {
                        return issue.title.localizedCaseInsensitiveContains(searchText) ||
                               issue.description.localizedCaseInsensitiveContains(searchText)
                    }
                }
                
                // Search in person name
                if let person = dataStore.getPerson(with: assignment.personID) {
                    return person.name.localizedCaseInsensitiveContains(searchText)
                }
                
                return false
            }
        }
        
        // Sort by due date (most urgent first)
        return assignments.sorted { a1, a2 in
            if let date1 = a1.dueDate, let date2 = a2.dueDate {
                return date1 < date2
            } else if a1.dueDate != nil {
                return true
            } else if a2.dueDate != nil {
                return false
            } else {
                return a1.createdAt > a2.createdAt
            }
        }
    }
    
    func deleteAssignments(at offsets: IndexSet) {
        dataStore.deleteAssignment(at: offsets)
    }
}

struct AssignmentRowView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TypeBadge(type: assignment.type)
                
                Spacer()
                
                if let dueDate = assignment.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(formatDate(dueDate))
                            .font(.caption)
                    }
                    .foregroundColor(isPastDue(dueDate) ? .red : .secondary)
                }
            }
            
            // Item details
            if let itemTitle = getItemTitle(), let status = getItemStatus(), let priority = getItemPriority() {
                HStack {
                    Text(itemTitle)
                        .font(.headline)
                    
                    Spacer()
                    
                    PriorityBadge(priority: priority)
                }
                
                StatusBadge(status: status)
            }
            
            // Person info
            if let person = dataStore.getPerson(with: assignment.personID) {
                HStack {
                    Image(systemName: person.profileImage ?? "person")
                    Text("Assigned to: \(person.name)")
                    
                    Spacer()
                    
                    Text(person.role)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Notes (if any)
            if let notes = assignment.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func isPastDue(_ date: Date) -> Bool {
        return date < Date()
    }
    
    private func getItemTitle() -> String? {
        switch assignment.type {
        case .task:
            return dataStore.getTask(with: assignment.itemID)?.title
        case .issue:
            return dataStore.getIssue(with: assignment.itemID)?.title
        }
    }
    
    private func getItemStatus() -> TaskStatus? {
        switch assignment.type {
        case .task:
            return dataStore.getTask(with: assignment.itemID)?.status
        case .issue:
            return dataStore.getIssue(with: assignment.itemID)?.status
        }
    }
    
    private func getItemPriority() -> Priority? {
        switch assignment.type {
        case .task:
            return dataStore.getTask(with: assignment.itemID)?.priority
        case .issue:
            return dataStore.getIssue(with: assignment.itemID)?.priority
        }
    }
}

struct AssignmentDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditSheet = false
    let assignment: Assignment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    TypeBadge(type: assignment.type)
                    
                    Spacer()
                    
                    if let dueDate = assignment.dueDate {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Due: \(formattedDate(dueDate))")
                        }
                        .foregroundColor(isPastDue(dueDate) ? .red : .primary)
                    }
                }
                
                // Person details
                if let person = dataStore.getPerson(with: assignment.personID) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assigned To")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: person.profileImage ?? "person.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(person.name)
                                    .font(.title3)
                                
                                Text(person.role)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(person.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Task/Issue details
                VStack(alignment: .leading, spacing: 8) {
                    switch assignment.type {
                    case .task:
                        if let task = dataStore.getTask(with: assignment.itemID) {
                            TaskDetailSection(task: task)
                        } else {
                            Text("Task not found")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    case .issue:
                        if let issue = dataStore.getIssue(with: assignment.itemID) {
                            IssueDetailSection(issue: issue)
                        } else {
                            Text("Issue not found")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Notes
                if let notes = assignment.notes {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                    }
                }
                
                Divider()
                
                // Dates
                Group {
                    HStack {
                        Text("Created:")
                            .fontWeight(.medium)
                        Text(formattedDate(assignment.createdAt))
                    }
                    
                    HStack {
                        Text("Updated:")
                            .fontWeight(.medium)
                        Text(formattedDate(assignment.updatedAt))
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Assignment Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditSheet = true
                }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AssignmentFormView(mode: .edit(assignment))
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func isPastDue(_ date: Date) -> Bool {
        return date < Date()
    }
}

struct TaskDetailSection: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Task: \(task.title)")
                    .font(.headline)
                
                Spacer()
                
                PriorityBadge(priority: task.priority)
            }
            
            StatusBadge(status: task.status)
            
            Text(task.description)
                .font(.body)
                .padding(.vertical, 4)
            
            if !task.tags.isEmpty {
                TagsView(tags: task.tags)
            }
        }
    }
}

struct IssueDetailSection: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Issue: \(issue.title)")
                    .font(.headline)
                
                Spacer()
                
                PriorityBadge(priority: issue.priority)
            }
            
            StatusBadge(status: issue.status)
            
            Text(issue.description)
                .font(.body)
                .padding(.vertical, 4)
            
            if !issue.tags.isEmpty {
                TagsView(tags: issue.tags)
            }
            
            HStack {
                Image(systemName: "bubble.left")
                Text("\(issue.comments.count) comments")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

struct AssignmentFormView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let mode: FormMode<Assignment>
    
    @State private var type = AssignmentType.task
    @State private var itemID: UUID?
    @State private var personID: UUID?
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var hasDate = false
    @State private var notes = ""
    
    // Task and issue lists for selection
    private var tasks: [Task] { dataStore.tasks }
    private var issues: [Issue] { dataStore.issues }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Type")) {
                    Picker("Type", selection: $type) {
                        ForEach(AssignmentType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Item")) {
                    switch type {
                    case .task:
                        Picker("Select Task", selection: $itemID) {
                            Text("Select a task").tag(nil as UUID?)
                            ForEach(tasks) { task in
                                Text(task.title).tag(task.id as UUID?)
                            }
                        }
                    case .issue:
                        Picker("Select Issue", selection: $itemID) {
                            Text("Select an issue").tag(nil as UUID?)
                            ForEach(issues) { issue in
                                Text(issue.title).tag(issue.id as UUID?)
                            }
                        }
                    }
                }
                
                Section(header: Text("Assignee")) {
                    Picker("Assigned To", selection: $personID) {
                        Text("Select a person").tag(nil as UUID?)
                        ForEach(dataStore.people) { person in
                            Text(person.name).tag(person.id as UUID?)
                        }
                    }
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Has Due Date", isOn: $hasDate)
                    
                    if hasDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit Assignment" : "New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Update" : "Add") {
                        saveAssignment()
                        dismiss()
                    }
                    .disabled(itemID == nil || personID == nil)
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    private var isEditMode: Bool {
        switch mode {
        case .add:
            return false
        case .edit:
            return true
        }
    }
    
    private func setupInitialValues() {
        switch mode {
        case .add:
            break
        case .edit(let assignment):
            type = assignment.type
            itemID = assignment.itemID
            personID = assignment.personID
            if let assignmentDueDate = assignment.dueDate {
                dueDate = assignmentDueDate
                hasDate = true
            } else {
                hasDate = false
            }
            if let assignmentNotes = assignment.notes {
                notes = assignmentNotes
            }
        }
    }
    
    private func saveAssignment() {
        guard let item = itemID, let person = personID else { return }
        
        switch mode {
        case .add:
            let newAssignment = Assignment(
                type: type,
                itemID: item,
                personID: person,
                dueDate: hasDate ? dueDate : nil,
                notes: notes.isEmpty ? nil : notes
            )
            dataStore.addAssignment(newAssignment)
            
        case .edit(let assignment):
            var updatedAssignment = assignment
            updatedAssignment.type = type
            updatedAssignment.itemID = item
            updatedAssignment.personID = person
            updatedAssignment.dueDate = hasDate ? dueDate : nil
            updatedAssignment.notes = notes.isEmpty ? nil : notes
            updatedAssignment.updatedAt = Date()
            dataStore.updateAssignment(updatedAssignment)
        }
    }
}