//
//  SharedEnums.swift
//  znotes
//
//  Created on 6/7/25.
//

import Foundation
import SwiftUI

enum Priority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case inReview = "In Review"
    case done = "Done"
    case cancelled = "Cancelled"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .todo: return .gray
        case .inProgress: return .blue
        case .inReview: return .orange
        case .done: return .green
        case .cancelled: return .red
        }
    }
}

// Extension to help sort by priority level
extension Priority {
    var priorityValue: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .critical: return 3
        }
    }
}

// Form mode for add/edit operations
enum FormMode<T> {
    case add
    case edit(T)
}
