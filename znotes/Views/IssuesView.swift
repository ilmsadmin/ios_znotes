//
//  IssuesView.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI

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
                
                HStack {
                    Image(systemName: "bubble.left")
                    Text("\(issue.comments.count)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                if let reporter = dataStore.getPerson(with: issue.reporterID) {
                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .font(.caption)
                        Text("Reporter: \(reporter.name)")
                            .font(.caption)
                    }
                }
                
                if let assigneeID = issue.assigneeID, let assignee = dataStore.getPerson(with: assigneeID) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                        Text("Assignee: \(assignee.name)")
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.secondary)
            
            if !issue.tags.isEmpty {
                TagsView(tags: issue.tags)
            }
        }
        .padding(.vertical, 4)
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
                
                // Reporter and Assignee
                HStack {
                    VStack(alignment: .leading) {
                        Text("Reporter")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let reporter = dataStore.getPerson(with: issue.reporterID) {
                            HStack {
                                Image(systemName: reporter.profileImage ?? "person")
                                    .foregroundColor(.blue)
                                Text(reporter.name)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Assignee")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let assigneeID = issue.assigneeID, let assignee = dataStore.getPerson(with: assigneeID) {
                            HStack {
                                Text(assignee.name)
                                Image(systemName: assignee.profileImage ?? "person.fill")
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Text("Unassigned")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func addComment() {
        guard !newCommentText.isEmpty, let currentUserID = dataStore.people.first?.id else { return }
        
        let comment = Comment(
            content: newCommentText,
            authorID: currentUserID
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
            HStack {
                if let author = dataStore.getPerson(with: comment.authorID) {
                    Image(systemName: author.profileImage ?? "person")
                        .foregroundColor(.blue)
                    Text(author.name)
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    Text("Unknown User")
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formattedDate(comment.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .padding(.leading, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
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
    @State private var reporterID: UUID
    @State private var assigneeID: UUID?
    
    init(mode: FormMode<Issue>) {
        self.mode = mode
        
        // Ensure we have a default reporter (first person in list)
        _reporterID = State(initialValue: Person.sampleData.first?.id ?? UUID())
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
                        Text("Unassigned").tag(nil as UUID?)
                        ForEach(dataStore.people) { person in
                            Text(person.name).tag(person.id as UUID?)
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
            // Make sure we have a default reporter if not already set
            if dataStore.people.isEmpty == false && !dataStore.people.contains(where: { $0.id == reporterID }) {
                reporterID = dataStore.people[0].id
            }
            
        case .edit(let issue):
            title = issue.title
            description = issue.description
            priority = issue.priority
            status = issue.status
            tagsText = issue.tags.joined(separator: ", ")
            reporterID = issue.reporterID
            assigneeID = issue.assigneeID
        }
    }
    
    private func saveIssue() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        switch mode {
        case .add:
            let newIssue = Issue(
                title: title,
                description: description,
                priority: priority,
                status: status,
                tags: tags,
                reporterID: reporterID,
                assigneeID: assigneeID
            )
            dataStore.addIssue(newIssue)
            
        case .edit(let issue):
            var updatedIssue = issue
            updatedIssue.title = title
            updatedIssue.description = description
            updatedIssue.priority = priority
            updatedIssue.status = status
            updatedIssue.tags = tags
            updatedIssue.reporterID = reporterID
            updatedIssue.assigneeID = assigneeID
            updatedIssue.updatedAt = Date()
            dataStore.updateIssue(updatedIssue)
        }
    }
}
