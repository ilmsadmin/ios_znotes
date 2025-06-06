//
//  NotesView.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showAddSheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults) { note in
                    NavigationLink {
                        NoteDetailView(note: note)
                    } label: {
                        NoteRowView(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .searchable(text: $searchText, prompt: "Search notes")
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                NoteFormView(mode: .add)
            }
        }
    }
    
    var searchResults: [Note] {
        if searchText.isEmpty {
            return dataStore.notes
        } else {
            return dataStore.notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText) ||
                note.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
    
    func deleteNotes(at offsets: IndexSet) {
        dataStore.deleteNote(at: offsets)
    }
}

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading) {
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
            
            Text("Updated: \(formattedDate(note.updatedAt))")
                .font(.caption)
                .foregroundColor(.secondary)
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

struct NoteDetailView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @State private var showEditSheet = false
    let note: Note
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if !note.tags.isEmpty {
                    TagsView(tags: note.tags)
                }
                
                Divider()
                
                Text(note.content)
                    .font(.body)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Created:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedDate(note.createdAt))
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Updated:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedDate(note.updatedAt))
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Note Details")
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
            NoteFormView(mode: .edit(note))
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum FormMode<T> {
    case add
    case edit(T)
}

struct NoteFormView: View {
    @EnvironmentObject var dataStore: AppDataStore
    @Environment(\.dismiss) private var dismiss
    
    let mode: FormMode<Note>
    
    @State private var title = ""
    @State private var content = ""
    @State private var tagsText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                    TextField("Tags (comma separated)", text: $tagsText)
                }
            }
            .navigationTitle(isEditMode ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Update" : "Add") {
                        saveNote()
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
        case .edit(let note):
            title = note.title
            content = note.content
            tagsText = note.tags.joined(separator: ", ")
        }
    }
    
    private func saveNote() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        switch mode {
        case .add:
            let newNote = Note(
                title: title,
                content: content,
                tags: tags,
                createdAt: Date(),
                updatedAt: Date()
            )
            dataStore.addNote(newNote)
            
        case .edit(let note):
            var updatedNote = note
            updatedNote.title = title
            updatedNote.content = content
            updatedNote.tags = tags
            updatedNote.updatedAt = Date()
            dataStore.updateNote(updatedNote)
        }
    }
}