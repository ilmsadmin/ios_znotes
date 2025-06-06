# iOS Notes Application

## Overview

iOS Notes is a comprehensive note-taking and task management application built with SwiftUI and modern iOS development practices. The application provides functionality for managing notes, tasks, issues, and assignments with a clean, intuitive interface.

## Features

### 📝 Notes Management
- Create, edit, and delete personal notes
- Add tags for organization
- Rich text content support
- Search and filter capabilities

### ✅ Task Management
- Create tasks with priority levels (Low, Medium, High, Critical)
- Track task status (To Do, In Progress, In Review, Done, Cancelled)
- Assign tasks to team members
- Set due dates and track progress
- Add tags and descriptions

### 🚨 Issue Tracking
- Report and track issues with detailed descriptions
- Priority-based issue management
- Comment system for collaboration
- Assignment and status tracking
- Tag-based categorization

### 👥 Assignment Management
- Assign tasks and issues to team members
- Track assignment history
- Set due dates and notes
- Monitor team workload

## Technical Architecture

### Data Models

The application uses four main data models:

- **Note**: Personal notes with title, content, and tags
- **Task**: Work items with priority, status, and assignments
- **Issue**: Problems or bugs with comments and tracking
- **Assignment**: Links between people and tasks/issues
- **Person**: Team members who can be assigned work

### SwiftUI Views

The UI is built using SwiftUI with the following main views:

- **ContentView**: Main tab-based navigation
- **NotesListView**: Display and manage notes
- **TasksListView**: Task management interface
- **IssuesListView**: Issue tracking interface
- **AssignmentsListView**: Assignment management

### Data Management

- **AppDataStore**: ObservableObject for state management
- **@Published** properties for reactive UI updates
- Codable models for data persistence
- Sample data for development and testing

## Project Structure

```
Sources/
├── iOSNotesCore/
│   ├── Models/
│   │   ├── Note.swift
│   │   ├── Task.swift
│   │   ├── Issue.swift
│   │   └── Assignment.swift
│   ├── ViewModels/
│   │   └── AppDataStore.swift
│   └── Views/
│       ├── NotesView.swift
│       ├── TasksView.swift
│       ├── IssuesView.swift
│       └── AssignmentsView.swift
└── iOSNotes/
    └── main.swift
```

## Getting Started

### Prerequisites

- iOS 15.0+ / macOS 12.0+
- Xcode 13.0+
- Swift 6.1+

### Installation

1. Clone the repository
2. Open in Xcode or import as a Swift Package
3. Build and run

### Usage in iOS App

```swift
import SwiftUI
import iOSNotesCore

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Features in Detail

### Priority System

Tasks and issues use a four-level priority system:
- **Low**: Minor improvements or non-urgent items
- **Medium**: Standard priority items
- **High**: Important items that need attention
- **Critical**: Urgent items requiring immediate action

### Status Tracking

Both tasks and issues use a comprehensive status system:
- **To Do**: Not started
- **In Progress**: Currently being worked on
- **In Review**: Awaiting review or approval
- **Done**: Completed successfully
- **Cancelled**: No longer needed

### User Interface

The application provides:
- Tab-based navigation for main features
- Search and filter functionality
- Pull-to-refresh data updates
- Swipe-to-delete actions
- Modal forms for adding/editing items
- Responsive design for different screen sizes

## Development

### Building

```bash
swift build
```

### Running

```bash
swift run
```

### Testing

The package includes sample data for development and testing purposes.

## API Reference

### AppDataStore

Main data store class that manages all application data:

```swift
class AppDataStore: ObservableObject {
    @Published var notes: [Note]
    @Published var tasks: [Task]
    @Published var issues: [Issue]
    @Published var assignments: [Assignment]
    @Published var people: [Person]
    
    // CRUD operations for all entities
}
```

### Models

All models conform to `Identifiable`, `Codable`, and `Sendable`:

- `Note`: Personal notes with tags
- `Task`: Work items with assignments
- `Issue`: Problems with comments
- `Assignment`: Task/issue assignments
- `Person`: Team member information

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is available under the MIT license.

## Support

For questions or issues, please create an issue in the repository.