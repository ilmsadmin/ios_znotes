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
        NavigationView {
            DashboardView()
        }
        .environmentObject(dataStore)
        .sheet(isPresented: $dataStore.showTrashBin) {
            TrashBinView()
                .environmentObject(dataStore)
        }
    }
}

#Preview {
    ContentView()
} 
