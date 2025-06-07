//
//  IssuesView.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI
import Foundation

// MARK: - Main View

struct IssuesView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var selectedStatus: TaskStatus?
    
    var body: some View {
        NavigationView {
            VStack {
                // Status filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }
                        
                        ForEach(TaskStatus.allCases) { status in
                            FilterButton(title: status.rawValue, isSelected: selectedStatus == status) {
                                selectedStatus = status
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Issues list
                List {
                    ForEach(filteredIssues) { issue in
                        NavigationLink {
                            IssueDetailView(issue: issue)
                        } label: {
                            IssueRowView(issue: issue)
                        }
                    }
                    .onDelete(perform: deleteIssues)
                }
                .searchable(text: $searchText, prompt: "Search issues")
            }
            .navigationTitle("Issues")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Label("Add Issue", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                IssueFormView(mode: .add)
            }
        }
    }
    
    var filteredIssues: [Issue] {
        var issues = dataStore.issues
        
        // Apply status filter if selected
        if let status = selectedStatus {
            issues = issues.filter { $0.status == status }
        }
        
        // Apply search filter if text is not empty
        if !searchText.isEmpty {
            issues = issues.filter { issue in
                issue.title.localizedCaseInsensitiveContains(searchText) ||
                issue.description.localizedCaseInsensitiveContains(searchText) ||
                issue.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // Sort by priority
        return issues.sorted {
            if $0.priority != $1.priority {
                return $0.priority.priorityValue > $1.priority.priorityValue
            } else {
                return $0.updatedAt > $1.updatedAt
            }
        }
    }
    
    func deleteIssues(at offsets: IndexSet) {
        // Move issues to trash instead of deleting them permanently
        offsets.forEach { index in
            let issue = filteredIssues[index]
            if let originalIndex = dataStore.issues.firstIndex(where: { $0.id == issue.id }) {
                let issueToTrash = dataStore.issues[originalIndex]
                dataStore.moveIssueToTrash(issueToTrash)
                dataStore.issues.remove(at: originalIndex)
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IssueRowView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(issue.title)
                    .font(.headline)
                
                Spacer()
                
                PriorityBadge(priority: issue.priority)
            }
            
            Text(issue.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                StatusBadge(status: issue.status)
                
                Spacer()
                
                Text("Updated: \(formattedDate(issue.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Assignee info
            if let assigneeId = issue.assigneeId, let assignee = dataStore.getPerson(with: assigneeId) {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                    Text("Assignee: \(assignee.name)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            if !issue.tags.isEmpty {
                TagsView(tags: issue.tags)
            }
        }
        .padding(.vertical, 4)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct IssueDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditSheet = false
    @State private var newCommentText = ""
    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(issue.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    PriorityBadge(priority: issue.priority)
                }
                
                // Status
                HStack {
                    StatusBadge(status: issue.status)
                    
                    Spacer()
                    
                    Text("Updated: \(formattedDate(issue.updatedAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Reporter and Assignee info
                let reporter = dataStore.getPerson(with: issue.reporterId)
                if let reporter = reporter {
                    HStack {
                        Text("Reporter: \(reporter.name) (\(reporter.role))")
                        Spacer()
                        Text(reporter.email)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let assigneeId = issue.assigneeId, let assignee = dataStore.getPerson(with: assigneeId) {
                    HStack {
                        Text("Assigned to: \(assignee.name) (\(assignee.role))")
                        Spacer()
                        Text(assignee.email)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Tags
                if !issue.tags.isEmpty {
                    TagsView(tags: issue.tags)
                }
                
                Divider()
                
                // Description
                Text("Description")
                    .font(.headline)
                
                Text(issue.description)
                    .padding(.bottom)
                
                Divider()
                
                // Comments section
                Text("Comments (\(issue.comments.count))")
                    .font(.headline)
                
                ForEach(issue.comments) { comment in
                    CommentView(comment: comment)
                }
                
                // Add comment
                VStack(alignment: .leading) {
                    Text("Add Comment")
                        .font(.subheadline)
                    
                    HStack {
                        TextField("Type your comment", text: $newCommentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addComment) {
                            Image(systemName: "paperplane.fill")
                        }
                        .disabled(newCommentText.isEmpty)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Issue Details")
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
            IssueFormView(mode: .edit(issue))
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func addComment() {
        let comment = Comment(
            content: newCommentText,
            authorId: "123E4567-E89B-12D3-A456-426614174000" // Replace with actual user ID
        )
        
        dataStore.addComment(to: issue.id, comment: comment)
        newCommentText = ""
    }
}

struct CommentView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let author = dataStore.getPerson(with: comment.authorId) {
                HStack {
                    Text(author.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(formattedDate(comment.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(comment.content)
                .font(.body)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct IssueFormView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let mode: FormMode<Issue>
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Priority.medium
    @State private var status = TaskStatus.todo
    @State private var tagsText = ""
    @State private var reporterID: String
    @State private var assigneeID: String?
    
    init(mode: FormMode<Issue>) {
        self.mode = mode
        _reporterID = State(initialValue: Person.sampleData.first?.id ?? UUID().uuidString)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Issue Details")) {
                    TextField("Title", text: $title)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Tags (comma separated)", text: $tagsText)
                }
                
                Section(header: Text("People")) {
                    Picker("Reporter", selection: $reporterID) {
                        ForEach(dataStore.people) { person in
                            Text(person.name).tag(person.id)
                        }
                    }
                    
                    Picker("Assigned To", selection: $assigneeID) {
                        Text("Unassigned").tag(nil as String?)
                        ForEach(dataStore.people) { person in
                            Text(person.name).tag(person.id as String?)
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Issue" : "New Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Update" : "Add") {
                        saveIssue()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
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
        case .edit(let issue):
            title = issue.title
            description = issue.description
            priority = issue.priority
            status = issue.status
            tagsText = issue.tags.joined(separator: ", ")
            reporterID = issue.reporterId
            assigneeID = issue.assigneeId
        }
    }
    
    private func saveIssue() {
        let tags = tagsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        switch mode {
        case .add:
            let newIssue = Issue(
                title: title,
                description: description,
                priority: priority,
                status: status,
                tags: tags,
                reporterId: reporterID,
                assigneeId: assigneeID
            )
            dataStore.addIssue(newIssue)
            
        case .edit(let existingIssue):
            var updatedIssue = existingIssue
            updatedIssue.title = title
            updatedIssue.description = description
            updatedIssue.priority = priority
            updatedIssue.status = status
            updatedIssue.tags = tags
            updatedIssue.reporterId = reporterID
            updatedIssue.assigneeId = assigneeID
            updatedIssue.updatedAt = Date()
            
            dataStore.updateIssue(updatedIssue)
        }
    }
}

#Preview {
    IssuesView()
        .environmentObject(AppDataStore(loadSampleData: true))
}
