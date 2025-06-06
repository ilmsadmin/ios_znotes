//
//  ContentView.swift
//  znotes
//
//  Created on 6/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = AppDataStore(loadSampleData: true)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView {
                NavigationView {
                    DashboardView()
                }
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                
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
            
            // Trash bin button
            if dataStore.hasTrashItems {
                Button(action: {
                    dataStore.showTrashBin = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)
                            .shadow(radius: 3)
                        
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                        
                        // Badge with count
                        if dataStore.totalTrashCount > 0 {
                            Text("\(dataStore.totalTrashCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 18, y: -18)
                        }
                    }
                }
                .padding([.trailing, .bottom], 16)
            }
        }
        .sheet(isPresented: $dataStore.showTrashBin) {
            TrashBinView()
                .environmentObject(dataStore)
        }
    }
}

#Preview {
    ContentView()
}
