//
//  TasksView.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI

struct TasksView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showAddSheet = false
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
                
                // Tasks list
                List {
                    ForEach(filteredTasks) { task in
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            TaskRowView(task: task)
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
                .searchable(text: $dataStore.searchText, prompt: "Search tasks")
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                TaskFormView(mode: .add)
            }
        }
    }
    
    var filteredTasks: [TaskItem] {
        var tasks = dataStore.tasks
        
        // Apply status filter if selected
        if let status = selectedStatus {
            tasks = tasks.filter { $0.status == status }
        }
        
        // Apply search filter if text is not empty
        if !dataStore.searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(dataStore.searchText) ||
                task.description.localizedCaseInsensitiveContains(dataStore.searchText) ||
                task.tags.contains(where: { $0.localizedCaseInsensitiveContains(dataStore.searchText) })
            }
        }
        
        // Sort by priority and due date
        return tasks.sorted {
            if $0.priority != $1.priority {
                return $0.priority.priorityValue > $1.priority.priorityValue
            } else if let date0 = $0.dueDate, let date1 = $1.dueDate {
                return date0 < date1
            } else if $0.dueDate != nil {
                return true
            } else {
                return false
            }
        }
    }
    
    func deleteTasks(at offsets: IndexSet) {
        // Move tasks to trash instead of deleting them permanently
        offsets.forEach { index in
            let task = filteredTasks[index]
            if let originalIndex = dataStore.tasks.firstIndex(where: { $0.id == task.id }) {
                let taskToTrash = dataStore.tasks[originalIndex]
                dataStore.moveTaskToTrash(taskToTrash)
                dataStore.tasks.remove(at: originalIndex)
            }
        }
    }
}


struct TaskRowView: View {
    @EnvironmentObject var dataStore: AppDataStore
    let task: TaskItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                
                Spacer()
                
                PriorityBadge(priority: task.priority)
            }
            
            Text(task.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                StatusBadge(status: task.status)
                
                Spacer()
                
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(formatDate(dueDate))
                            .font(.caption)
                    }
                    .foregroundColor(isPastDue(dueDate) ? .red : .secondary)
                }
            }
            
            if let assigneeId = task.assigneeId, let person = dataStore.getPerson(with: assigneeId) {
                HStack {
                    Image(systemName: person.profileImage ?? "person")
                    Text("Assigned to: \(person.name)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            if !task.tags.isEmpty {
                TagsView(tags: task.tags)
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
}

struct TaskDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditSheet = false
    let task: TaskItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(task.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    PriorityBadge(priority: task.priority)
                }
                
                // Status
                HStack {
                    StatusBadge(status: task.status)
                    
                    Spacer()
                    
                    if let dueDate = task.dueDate {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Due: \(formattedDate(dueDate))")
                        }
                        .foregroundColor(isPastDue(dueDate) ? .red : .primary)
                    }
                }
                
                // Assignee
                if let assigneeId = task.assigneeId, let person = dataStore.getPerson(with: assigneeId) {
                    HStack {
                        Image(systemName: person.profileImage ?? "person")
                        Text("Assigned to: \(person.name) (\(person.role))")
                        Spacer()
                        Text(person.email)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Tags
                if !task.tags.isEmpty {
                    TagsView(tags: task.tags)
                }
                
                Divider()
                
                // Description
                Text("Description")
                    .font(.headline)
                
                Text(task.description)
                    .padding(.bottom)
                
                // Dates
                Group {
                    HStack {
                        Text("Created:")
                            .fontWeight(.medium)
                        Text(formattedDate(task.createdAt))
                    }
                    
                    HStack {
                        Text("Updated:")
                            .fontWeight(.medium)
                        Text(formattedDate(task.updatedAt))
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Task Details")
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
            TaskFormView(mode: .edit(task))
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

struct TaskFormView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let mode: FormMode<TaskItem>
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Priority.medium
    @State private var status = TaskStatus.todo
    @State private var tagsText = ""
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var hasDate = false
    @State private var assigneeID: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
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
                
                Section(header: Text("Due Date")) {
                    Toggle("Has Due Date", isOn: $hasDate)
                    
                    if hasDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Assignment")) {
                    Picker("Assigned To", selection: $assigneeID) {
                        Text("Unassigned").tag(nil as String?)
                        ForEach(dataStore.people) { person in
                            Text(person.name).tag(person.id as String?)
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Update" : "Add") {
                        saveTask()
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
        case .edit(let task):
            title = task.title
            description = task.description
            priority = task.priority
            status = task.status
            tagsText = task.tags.joined(separator: ", ")
            if let taskDueDate = task.dueDate {
                dueDate = taskDueDate
                hasDate = true
            } else {
                hasDate = false
            }
            assigneeID = task.assigneeId
        }
    }
    
    private func saveTask() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        switch mode {
        case .add:
            let newTask = TaskItem(
                title: title,
                description: description,
                priority: priority,
                status: status,
                tags: tags,
                dueDate: hasDate ? dueDate : nil,
                assigneeId: assigneeID
            )
            dataStore.addTask(newTask)
            
        case .edit(let task):
            var updatedTask = task
            updatedTask.title = title
            updatedTask.description = description
            updatedTask.priority = priority
            updatedTask.status = status
            updatedTask.tags = tags
            updatedTask.dueDate = hasDate ? dueDate : nil
            updatedTask.assigneeId = assigneeID
            updatedTask.updatedAt = Date()
            dataStore.updateTask(updatedTask)
        }
    }
}
