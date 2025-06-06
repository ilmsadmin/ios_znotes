# iOS Notes Application

Ứng dụng quản lý ghi chú và nhiệm vụ toàn diện được xây dựng bằng SwiftUI hiện đại.

## 🚀 Tính năng chính

### 📝 Quản lý ghi chú (Notes)
- Tạo, chỉnh sửa và xóa ghi chú cá nhân
- Thêm tags để tổ chức
- Tìm kiếm và lọc ghi chú
- Giao diện thân thiện với người dùng

### ✅ Quản lý nhiệm vụ (Tasks)
- Tạo nhiệm vụ với các mức độ ưu tiên (Thấp, Trung bình, Cao, Khẩn cấp)
- Theo dõi trạng thái nhiệm vụ (Cần làm, Đang tiến hành, Đang xem xét, Hoàn thành, Hủy bỏ)
- Gán nhiệm vụ cho thành viên nhóm
- Đặt hạn chót và theo dõi tiến độ
- Thêm tags và mô tả chi tiết

### 🚨 Theo dõi vấn đề (Issues)
- Báo cáo và theo dõi các vấn đề với mô tả chi tiết
- Quản lý vấn đề theo mức độ ưu tiên
- Hệ thống bình luận để cộng tác
- Theo dõi phân công và trạng thái
- Phân loại bằng tags

### 👥 Quản lý phân công (Assignments)
- Phân công nhiệm vụ và vấn đề cho thành viên nhóm
- Theo dõi lịch sử phân công
- Đặt hạn chót và ghi chú
- Giám sát khối lượng công việc của nhóm

## 🏗️ Kiến trúc kỹ thuật

### Công nghệ sử dụng
- **SwiftUI**: Giao diện người dùng hiện đại
- **Swift 6.1**: Ngôn ngữ lập trình mới nhất
- **Combine Framework**: Quản lý state reactive
- **Swift Package Manager**: Quản lý dependencies

### Cấu trúc dự án
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

### Mô hình dữ liệu
Tất cả các models đều tuân thủ `Identifiable`, `Codable`, và `Sendable`:

- **Note**: Ghi chú cá nhân với tiêu đề, nội dung và tags
- **Task**: Nhiệm vụ công việc với phân công và ưu tiên
- **Issue**: Vấn đề/bug với bình luận và theo dõi
- **Assignment**: Phân công nhiệm vụ/vấn đề cho người
- **Person**: Thông tin thành viên nhóm

## 📱 Giao diện người dùng

### Thiết kế TabView
Ứng dụng sử dụng `TabView` với 4 tab chính:

1. **Notes** (📝): Quản lý ghi chú cá nhân
2. **Tasks** (✅): Quản lý nhiệm vụ và deadline
3. **Issues** (🚨): Theo dõi và báo cáo vấn đề
4. **Assignments** (👥): Phân công công việc

### Tính năng UI
- Navigation dựa trên tabs
- Tìm kiếm và lọc dữ liệu
- Pull-to-refresh
- Swipe-to-delete
- Modal forms cho thêm/chỉnh sửa
- Responsive design cho các kích thước màn hình khác nhau

## 🛠️ Cài đặt và sử dụng

### Yêu cầu hệ thống
- iOS 15.0+ / macOS 12.0+
- Xcode 13.0+
- Swift 6.1+

### Cài đặt
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

### Sử dụng trong iOS App
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

Dự án bao gồm comprehensive test suite:

```bash
swift test
```

Tests bao gồm:
- CRUD operations cho tất cả models
- State management
- Data validation
- Sample data loading

Kết quả: **14 tests passed** ✅

## 📊 Demo

Chạy demo để xem các tính năng:

```bash
swift run
```

Output hiển thị:
- Tổng quan các tính năng ứng dụng
- Dữ liệu mẫu (3 notes, 3 tasks, 3 issues, 3 assignments, 4 people)
- Hướng dẫn tích hợp vào iOS project

## 📚 Tài liệu

- [Documentation.md](Documentation.md): Tài liệu API chi tiết
- [Design.md](Design.md): Thiết kế kiến trúc và UI/UX

## 🎯 Tính năng nổi bật

### Hệ thống ưu tiên
- **Thấp**: Cải tiến nhỏ hoặc không khẩn cấp
- **Trung bình**: Ưu tiên tiêu chuẩn
- **Cao**: Cần chú ý ngay
- **Khẩn cấp**: Cần xử lý tức thì

### Theo dõi trạng thái
- **Cần làm**: Chưa bắt đầu
- **Đang tiến hành**: Đang được thực hiện
- **Đang xem xét**: Chờ phê duyệt
- **Hoàn thành**: Đã hoàn thành thành công
- **Hủy bỏ**: Không còn cần thiết

### Quản lý state hiện đại
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

## 🚀 Khả năng mở rộng

Thiết kế modular hỗ trợ thêm:
- Tích hợp lịch
- Đính kèm file
- Tính năng cộng tác
- Tìm kiếm nâng cao
- Workflows tùy chỉnh
- Đồng bộ cloud
- Offline support

## 🔒 Bảo mật

- Mã hóa dữ liệu cục bộ
- Lưu trữ keychain an toàn
- Thiết kế ưu tiên privacy

## 📄 License

Dự án này có sẵn dưới giấy phép MIT.

## 💡 Đóng góp

1. Fork repository
2. Tạo feature branch
3. Thực hiện changes
4. Thêm tests nếu cần
5. Submit pull request

## 📞 Hỗ trợ

Để được hỗ trợ hoặc báo cáo vấn đề, vui lòng tạo issue trong repository.

---

✨ **Được xây dựng với SwiftUI và các practices phát triển iOS hiện đại!** ✨
