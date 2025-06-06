//
//  BadgeViews.swift
//  znotes
//
//  Created on 6/6/25.
//

import SwiftUI

struct PriorityBadge: View {
    let priority: Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(priority.color)
            .clipShape(Capsule())
    }
}

struct StatusBadge: View {
    let status: TaskStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(status.color)
            .clipShape(Capsule())
    }
}

struct TypeBadge: View {
    let type: AssignmentType
    
    var body: some View {
        Text(type.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(type == .task ? Color.blue : Color.orange)
            .clipShape(Capsule())
    }
}

struct TagView: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.gray.opacity(0.2))
            .clipShape(Capsule())
    }
}

struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    TagView(tag: tag)
                }
            }
        }
    }
}

struct BadgeViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            PriorityBadge(priority: .high)
            StatusBadge(status: .inProgress)
            TypeBadge(type: .task)
            TagView(tag: "SwiftUI")
            TagsView(tags: ["SwiftUI", "iOS", "Development"])
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}