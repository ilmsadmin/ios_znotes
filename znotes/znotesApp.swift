//
//  znotesApp.swift
//  znotes
//
//  Created by toan on 6/6/25.
//

import SwiftUI

@main
struct znotesApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appDataStore = AppDataStore(loadSampleData: true)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDataStore)
                .environmentObject(authManager)
        }
    }
}
