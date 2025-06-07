//
//  TrashBinView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI

/// Giao diện hiển thị và quản lý các mục trong thùng rác
struct TrashBinView: View {
    // MARK: - Properties
    @EnvironmentObject private var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingEmptyTrashAlert = false
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector for different trash categories
                categoryPicker
                
                Divider()
                
                // Content based on selected category
                selectedTabContent
            }
            .navigationTitle("Trash Bin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    closeButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    emptyTrashButton
                }
            }
            .alert("Empty Trash", isPresented: $showingEmptyTrashAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Empty", role: .destructive) {
                    withAnimation {
                        dataStore.emptyTrash()
                    }
                }
            } message: {
                Text("Are you sure you want to permanently delete all items in the trash? This action cannot be undone.")
            }
        }
        .onChange(of: searchText) { _, newValue in
            dataStore.searchText = newValue
        }
    }
    
    // MARK: - UI Components
    
    /// Category picker for switching between trash categories
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedTab) {
            Text("Notes (\(dataStore.trashedNotes.count))").tag(0)
            Text("Tasks (\(dataStore.trashedTasks.count))").tag(1)
            Text("Issues (\(dataStore.trashedIssues.count))").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    /// Content view for the selected tab
    @ViewBuilder
    private var selectedTabContent: some View {
        switch selectedTab {
        case 0:
            notesTabContent
        case 1:
            tasksTabContent
        case 2:
            issuesTabContent
        default:
            notesTabContent
        }
    }
    
    /// Content view for the Notes tab
    private var notesTabContent: some View {
        List {
            ForEach(dataStore.trashedNotes) { note in
                TrashedNoteRow(note: note)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search notes in trash")
        .overlay {
            if dataStore.trashedNotes.isEmpty {
                ContentUnavailableView("No Notes in Trash",
                                      systemImage: "trash")
            }
        }
    }
    
    /// Content view for the Tasks tab
    private var tasksTabContent: some View {
        List {
            ForEach(dataStore.trashedTasks) { task in
                TrashedTaskRow(task: task)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search tasks in trash")
        .overlay {
            if dataStore.trashedTasks.isEmpty {
                ContentUnavailableView("No Tasks in Trash",
                                      systemImage: "trash")
            }
        }
    }
    
    /// Content view for the Issues tab
    private var issuesTabContent: some View {
        List {
            ForEach(dataStore.trashedIssues) { issue in
                TrashedIssueRow(issue: issue)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchText, prompt: "Search issues in trash")
        .overlay {
            if dataStore.trashedIssues.isEmpty {
                ContentUnavailableView("No Issues in Trash",
                                      systemImage: "trash")
            }
        }
    }
    
    /// Close button
    private var closeButton: some View {
        Button("Close") {
            dismiss()
        }
    }
    
    /// Empty trash button
    private var emptyTrashButton: some View {
        Button("Empty Trash") {
            showingEmptyTrashAlert = true
        }
        .disabled(!dataStore.hasTrashItems)
        .foregroundColor(.red)
    }
}

// MARK: - Trashed Item Rows

/// Row item for a trashed note
struct TrashedNoteRow: View {
    // MARK: - Properties
    @EnvironmentObject private var dataStore: AppDataStore
    let note: Note
    @State private var showingRestoreAlert = false
    @State private var showingDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
            
            Text(note.content)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(note.tags, id: \.self) { tag in
                            TagView(tag: tag)
                        }
                    }
                }
            }
            
            HStack {
                Text("Trashed: \(formatDate(note.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    showingRestoreAlert = true
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .alert("Restore Note", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                withAnimation {
                    dataStore.restoreNoteFromTrash(note)
                }
            }
        } message: {
            Text("Are you sure you want to restore this note?")
        }
        .alert("Delete Permanently", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    dataStore.permanentlyDeleteNote(note)
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete this note? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Row item for a trashed task
struct TrashedTaskRow: View {
    // MARK: - Properties
    @EnvironmentObject private var dataStore: AppDataStore
    let task: TaskItem
    @State private var showingRestoreAlert = false
    @State private var showingDeleteAlert = false
    
    // MARK: - Body
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
                    .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Trashed: \(formatDate(task.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    showingRestoreAlert = true
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .alert("Restore Task", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                withAnimation {
                    dataStore.restoreTaskFromTrash(task)
                }
            }
        } message: {
            Text("Are you sure you want to restore this task?")
        }
        .alert("Delete Permanently", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    dataStore.permanentlyDeleteTask(task)
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete this task? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

/// Row item for a trashed issue
struct TrashedIssueRow: View {
    // MARK: - Properties
    @EnvironmentObject private var dataStore: AppDataStore
    let issue: Issue
    @State private var showingRestoreAlert = false
    @State private var showingDeleteAlert = false
    
    // MARK: - Body
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
            
            HStack {
                Text("Trashed: \(formatDate(issue.updatedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    showingRestoreAlert = true
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.backward")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 4)
        .alert("Restore Issue", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore") {
                withAnimation {
                    dataStore.restoreIssueFromTrash(issue)
                }
            }
        } message: {
            Text("Are you sure you want to restore this issue?")
        }
        .alert("Delete Permanently", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    dataStore.permanentlyDeleteIssue(issue)
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete this issue? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Previews
#Preview {
    TrashBinView()
        .environmentObject(AppDataStore())
}
