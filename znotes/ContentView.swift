//
//  ContentView.swift
//  znotes
//
//  Created by toan on 6/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = AppDataStore(loadSampleData: true)
    
    var body: some View {
        TabView {
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            IssuesView()
                .tabItem {
                    Label("Issues", systemImage: "exclamationmark.triangle")
                }
            
            AssignmentsView()
                .tabItem {
                    Label("Assignments", systemImage: "person.2")
                }
        }
        .environmentObject(dataStore)
    }
}

#Preview {
    ContentView()
}
