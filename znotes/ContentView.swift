//
//  ContentView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            TasksView()
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Tasks")
                }
                .tag(1)
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
                .tag(2)
            
            IssuesView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Issues")
                }
                .tag(3)
            
            AssignmentsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Assignments")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
} 
