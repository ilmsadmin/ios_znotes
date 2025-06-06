# iOS Notes Application

A comprehensive note-taking and task management application built with modern SwiftUI.

## 🚀 Main Features

### 📝 Notes Management
- Create, edit, and delete personal notes
- Add tags for organization
- Search and filter notes
- User-friendly interface

### ✅ Task Management
- Create tasks with priority levels (Low, Medium, High, Critical)
- Track task status (To Do, In Progress, In Review, Done, Cancelled)
- Assign tasks to team members
- Set deadlines and track progress
- Add tags and detailed descriptions

### 🚨 Issue Tracking
- Report and track issues with detailed descriptions
- Manage issues by priority
- Comment system for collaboration
- Track assignments and status
- Categorize with tags

### 👥 Assignment Management
- Assign tasks and issues to team members
- Track assignment history
- Set deadlines and notes
- Monitor team workload

## 🏗️ Technical Architecture

### Technologies Used
- **SwiftUI**: Modern user interface
- **Swift 6.1**: Latest programming language
- **Combine Framework**: Reactive state management
- **Swift Package Manager**: Dependencies management

### Project Structure
```
Sources/
├── iOSNotesCore/           # Core library
│   ├── Models/             # Data models
│   │   ├── Note.swift
│   │   ├── Task.swift
│   │   ├── Issue.swift
│   │   └── Assignment.swift
│   ├── ViewModels/         # State management
│   │   └── AppDataStore.swift
│   └── Views/              # SwiftUI views
│       ├── NotesView.swift
│       ├── TasksView.swift
│       ├── IssuesView.swift
│       └── AssignmentsView.swift
└── iOSNotes/               # Demo executable
    └── main.swift
Tests/                      # Unit tests
└── iOSNotesTests/
    └── iOSNotesTests.swift
```

### Data Models
All models conform to `Identifiable`, `Codable`, and `Sendable`:

- **Note**: Personal notes with title, content and tags
- **Task**: Work tasks with assignments and priorities
- **Issue**: Problems/bugs with comments and tracking
- **Assignment**: Task/issue assignments to people
- **Person**: Team member information

## 📱 User Interface

### TabView Design
The application uses a `TabView` with 4 main tabs:

1. **Notes** (📝): Manage personal notes
2. **Tasks** (✅): Manage tasks and deadlines
3. **Issues** (🚨): Track and report issues
4. **Assignments** (👥): Manage work assignments

### UI Features
- Tab-based navigation
- Search and filter data
- Pull-to-refresh
- Swipe-to-delete
- Modal forms for adding/editing
- Responsive design for different screen sizes

## 🛠️ Installation and Usage

### System Requirements
- iOS 15.0+ / macOS 12.0+
- Xcode 13.0+
- Swift 6.1+

### Installation
```bash
# Clone repository
git clone https://github.com/ilmsadmin/ios_notes.git
cd ios_notes

# Build project
swift build

# Run demo
swift run

# Run tests
swift test
```

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

## 🧪 Testing

The project includes a comprehensive test suite:

```bash
swift test
```

Tests include:
- CRUD operations for all models
- State management
- Data validation
- Sample data loading

Results: **14 tests passed** ✅

## 📊 Demo

Run the demo to see the features:

```bash
swift run
```

The output displays:
- Overview of application features
- Sample data (3 notes, 3 tasks, 3 issues, 3 assignments, 4 people)
- Integration guide for iOS projects

## 📚 Documentation

- [Documentation.md](Documentation.md): Detailed API documentation
- [Design.md](Design.md): Architecture and UI/UX design

## 🎯 Key Features

### Priority System
- **Low**: Minor improvements or non-urgent items
- **Medium**: Standard priority
- **High**: Needs immediate attention
- **Critical**: Requires urgent handling

### Status Tracking
- **To Do**: Not yet started
- **In Progress**: Currently being worked on
- **In Review**: Waiting for approval
- **Done**: Successfully completed
- **Cancelled**: No longer needed

### Modern State Management
```swift
@MainActor
class AppDataStore: ObservableObject {
    @Published var notes: [Note] = []
    @Published var tasks: [Task] = []
    @Published var issues: [Issue] = []
    @Published var assignments: [Assignment] = []
    @Published var people: [Person] = []
}
```

## 🚀 Scalability

The modular design supports adding:
- Calendar integration
- File attachments
- Collaboration features
- Advanced search
- Custom workflows
- Cloud synchronization
- Offline support

## 🔒 Security

- Local data encryption
- Secure keychain storage
- Privacy-first design

## 📄 License

This project is available under the MIT license.

## 💡 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if needed
5. Submit a pull request

## 📞 Support

For support or issue reporting, please create an issue in the repository.

---

✨ **Built with SwiftUI and modern iOS development practices!** ✨
