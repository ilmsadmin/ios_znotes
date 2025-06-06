//
//  DashboardView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var dataStore: AppDataStore
    @State private var searchText: String = ""
    
    // Add state variables for new item sheets
    @State private var showingNewNoteSheet = false
    @State private var showingNewTaskSheet = false
    @State private var showingNewIssueSheet = false
    @State private var showingNewAssignmentSheet = false
    
    // New item state variables
    @State private var newNoteTitle = ""
    @State private var newNoteContent = ""
    
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskPriority = Priority.medium
    @State private var newTaskStatus = TaskStatus.todo
    @State private var newTaskDueDate = Date()
    @State private var newTaskHasDueDate = false
    
    @State private var newIssueTitle = ""
    @State private var newIssueDescription = ""
    @State private var newIssuePriority = Priority.medium
    @State private var newIssueStatus = TaskStatus.todo
    @State private var newIssueReporterID: UUID? // New state variable for reporter ID
    
    @State private var newAssignmentType = AssignmentType.task
    @State private var newAssignmentItemID: UUID?
    @State private var newAssignmentPersonID: UUID?
    @State private var newAssignmentDueDate = Date()
    @State private var newAssignmentHasDueDate = false
    @State private var newAssignmentNotes = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Stats Overview
                    statsOverview
                    
                    // Recent Items Section
                    recentItemsSection
                    
                    // Main Menu Grid
                    menuGrid
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .searchable(text: $searchText, prompt: "Search notes, tasks, issues...")
            .onAppear {
                // Reset search text when view appears
                searchText = ""
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // Action to create new note
                            showingNewNoteSheet.toggle()
                        }) {
                            Label("New Note", systemImage: "note.text.badge.plus")
                        }
                        
                        Button(action: {
                            // Action to create new task
                            showingNewTaskSheet.toggle()
                        }) {
                            Label("New Task", systemImage: "checklist.badge.plus")
                        }
                        
                        Button(action: {
                            // Action to create new issue
                            showingNewIssueSheet.toggle()
                        }) {
                            Label("New Issue", systemImage: "exclamationmark.triangle.badge.plus")
                        }
                        
                        Button(action: {
                            // Action to create new assignment
                            showingNewAssignmentSheet.toggle()
                        }) {
                            Label("New Assignment", systemImage: "person.2.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show profile or settings
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewNoteSheet) {
            NoteFormView(mode: .add)
        }
        .sheet(isPresented: $showingNewTaskSheet) {
            TaskFormView(mode: .add)
        }
        .sheet(isPresented: $showingNewIssueSheet) {
            IssueFormView(mode: .add)
        }
        .sheet(isPresented: $showingNewAssignmentSheet) {
            AssignmentFormView(mode: .add)
        }
    }
    
    // MARK: - Dashboard Components
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Notes",
                    count: dataStore.notes.count,
                    icon: "note.text",
                    color: .blue,
                    destinationView: AnyView(NotesView())
                )
                
                StatCard(
                    title: "Tasks",
                    count: dataStore.tasks.count,
                    icon: "checklist",
                    color: .green,
                    destinationView: AnyView(TasksView())
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Issues",
                    count: dataStore.issues.count,
                    icon: "exclamationmark.triangle",
                    color: .orange,
                    destinationView: AnyView(IssuesView())
                )
                
                StatCard(
                    title: "Assigns",
                    count: dataStore.assignments.count,
                    icon: "person.2",
                    color: .purple,
                    destinationView: AnyView(AssignmentsView())
                )
            }
        }
    }
    
    private var recentItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Items")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Show most recent notes, tasks, and issues
                    ForEach(dataStore.notes.prefix(3)) { note in
                        NavigationLink(destination: NoteDetailView(note: note)) {
                            RecentItemCard(
                                title: note.title,
                                subtitle: "Note",
                                description: note.content,
                                date: note.updatedAt,
                                icon: "note.text",
                                color: .blue
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(dataStore.tasks.prefix(3)) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            RecentItemCard(
                                title: task.title,
                                subtitle: "Task",
                                description: task.description,
                                date: task.updatedAt,
                                icon: "checklist",
                                color: .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(dataStore.issues.prefix(2)) { issue in
                        NavigationLink(destination: IssueDetailView(issue: issue)) {
                            RecentItemCard(
                                title: issue.title,
                                subtitle: "Issue",
                                description: issue.description,
                                date: issue.updatedAt,
                                icon: "exclamationmark.triangle",
                                color: .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var menuGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Menu")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: columns, spacing: 16) {
                NavigationLink(destination: NotesView()) {
                    MenuCard(
                        title: "Notes",
                        icon: "note.text",
                        color: .blue,
                        description: "Personal notes and memos"
                    )
                }
                
                NavigationLink(destination: TasksView()) {
                    MenuCard(
                        title: "Tasks",
                        icon: "checklist",
                        color: .green,
                        description: "Manage your to-do list"
                    )
                }
                
                NavigationLink(destination: IssuesView()) {
                    MenuCard(
                        title: "Issues",
                        icon: "exclamationmark.triangle",
                        color: .orange,
                        description: "Track problems and bugs"
                    )
                }
                
                NavigationLink(destination: AssignmentsView()) {
                    MenuCard(
                        title: "Assignments",
                        icon: "person.2",
                        color: .purple,
                        description: "Delegate work to team"
                    )
                }
                
                Button(action: {
                    dataStore.showTrashBin = true
                }) {
                    MenuCard(
                        title: "Trash",
                        icon: "trash",
                        color: .red,
                        description: "Recover deleted items"
                    )
                }
                
                NavigationLink(destination: Text("Analytics coming soon...")) {
                    MenuCard(
                        title: "Analytics",
                        icon: "chart.bar",
                        color: .gray,
                        description: "Track your productivity"
                    )
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    var destinationView: AnyView? = nil
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("\(count)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentItemCard: View {
    let title: String
    let subtitle: String
    let description: String
    let date: Date
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatDate(date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.headline)
                .lineLimit(1)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 240)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct MenuCard: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(minHeight: 140)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppDataStore(loadSampleData: true))
}
