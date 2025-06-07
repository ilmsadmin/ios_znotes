# iOS ZNotes - Complete Solution

This repository contains both the iOS application and the NestJS backend API for the ZNotes project.

## Project Structure

```
├── znotes/                     # iOS SwiftUI Application
│   ├── Models/                 # Swift data models
│   ├── Views/                  # SwiftUI views
│   ├── ViewModels/             # State management
│   └── Assets.xcassets/        # App assets
├── backend/                    # NestJS API Backend
│   ├── src/                    # TypeScript source code
│   │   ├── auth/              # Authentication module
│   │   ├── groups/            # Group management
│   │   ├── users/             # User management
│   │   ├── notes/             # Notes CRUD
│   │   ├── tasks/             # Tasks CRUD
│   │   ├── issues/            # Issues CRUD
│   │   └── assignments/       # Assignments CRUD
│   ├── test/                  # E2E tests
│   └── package.json           # Node.js dependencies
├── docs/                      # Documentation
└── README.md                  # Project overview
```

## iOS Application Features

### 📝 Notes Management
- Create, edit, and delete personal notes
- Tag-based organization
- Search and filter functionality
- Modern SwiftUI interface

### ✅ Task Management
- Priority-based task organization (Low, Medium, High, Critical)
- Status tracking (To Do, In Progress, In Review, Done, Cancelled)
- Assignment to team members
- Deadline management
- Tag categorization

### 🚨 Issue Tracking
- Bug and problem reporting
- Priority and status management
- Comment system for collaboration
- Assignment tracking
- Tag-based categorization

### 👥 Assignment Management
- Task and issue assignment to team members
- Deadline tracking
- Assignment history
- Team workload monitoring

## Backend API Features

### 🔐 Authentication & Security
- **User Registration**: Email-based registration with verification
- **JWT Authentication**: Secure token-based authentication
- **Password Security**: Bcrypt hashing with salt rounds
- **Email Verification**: Required before account activation
- **Password Reset**: Token-based password recovery (planned)

### 👥 Group Management
- **Email Domain Grouping**: Automatic grouping by email domain
  - Users with `@company.com` email automatically join "company.com" group
  - First user becomes group administrator
  - Subsequent users become regular members
- **Role-Based Access**: Group admins can manage user roles
- **Data Isolation**: Group-scoped access to tasks and issues

### 📊 Data Management
- **Personal Notes**: User-scoped note management
- **Group Tasks**: Shared task management within groups
- **Issue Tracking**: Group-wide issue reporting and tracking
- **Assignments**: Task and issue assignment system
- **Soft Deletes**: Data preserved with trash dates
- **Search & Filtering**: Full-text search and tag-based filtering

### 🏗️ Technical Architecture
- **Framework**: NestJS with TypeScript
- **Database**: MySQL with TypeORM
- **Documentation**: Swagger/OpenAPI integration
- **Validation**: Class-validator with DTOs
- **Testing**: Jest with E2E test support
- **Security**: CORS, input validation, SQL injection protection

## Getting Started

### iOS Application
1. Open `znotes.xcodeproj` in Xcode
2. Build and run on iOS simulator or device
3. Explore notes, tasks, issues, and assignments features

### Backend API
1. Navigate to `backend/` directory
2. Install dependencies: `npm install`
3. Configure database in `.env` file
4. Start development server: `npm run start:dev`
5. Visit `http://localhost:3000/api/docs` for API documentation

## Key Implementation Highlights

### Email Domain-Based Grouping
```typescript
// Extract email domain
const emailDomain = email.split('@')[1];

// Find or create group
let group = await this.groupsRepository.findOne({
  where: { domain: emailDomain }
});

if (!group) {
  // Create new group, user becomes admin
  group = await this.groupsRepository.save({
    name: emailDomain,
    domain: emailDomain,
    admin: savedUser
  });
  userRole = UserRole.GROUP_ADMIN;
}
```

### Group-Scoped Data Access
```typescript
// Tasks visible to group members only
return this.tasksRepository
  .createQueryBuilder('task')
  .leftJoin('task.createdBy', 'createdBy')
  .leftJoin('createdBy.group', 'group')
  .where('group.id = :groupId', { groupId: user.groupId })
  .getMany();
```

### Role-Based Permissions
```typescript
// Only group admins can update user roles
if (currentUser.userRole !== UserRole.GROUP_ADMIN || 
    currentUser.groupId !== groupId) {
  throw new ForbiddenException('Only group admins can update user roles');
}
```

## API Integration Examples

### User Registration & Group Creation
```bash
# First user in domain becomes group admin
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@company.com",
    "password": "password123"
  }'

# Response: User becomes group_admin for company.com group
```

### Task Management
```bash
# Create task (requires authentication)
curl -X POST http://localhost:3000/api/v1/tasks \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Implement authentication",
    "description": "Add JWT-based authentication",
    "priority": "High",
    "assigneeId": "user-uuid"
  }'
```

### Group Administration
```bash
# Update user role (group admin only)
curl -X PATCH http://localhost:3000/api/v1/groups/{groupId}/users/{userId}/role \
  -H "Authorization: Bearer <admin_token>" \
  -H "Content-Type: application/json" \
  -d '{"role": "Senior Developer"}'
```

## Security Features

### Authentication Flow
1. User registers with email/password
2. Email verification token sent
3. User verifies email via token
4. User can login to receive JWT token
5. JWT token required for all protected endpoints

### Data Protection
- Passwords hashed with bcryptjs (12 salt rounds)
- Email verification required before account activation
- JWT tokens with configurable expiration
- Input validation on all endpoints
- SQL injection protection via TypeORM
- CORS configuration for cross-origin requests

### Access Control
- Personal notes: Only creator can access
- Group tasks/issues: All group members can access
- User role management: Only group admins
- Group administration: Domain-based isolation

## Future Enhancements

### Backend API
- [ ] Email notification system
- [ ] File upload and attachment support
- [ ] Real-time notifications with WebSockets
- [ ] Advanced search with Elasticsearch
- [ ] Audit logging for all operations
- [ ] Rate limiting and API throttling
- [ ] OAuth integration (Google, GitHub)
- [ ] Multi-language support

### iOS Application
- [ ] Backend API integration
- [ ] Real-time synchronization
- [ ] Offline support with Core Data
- [ ] Push notifications
- [ ] File attachments
- [ ] Calendar integration
- [ ] Dark mode support
- [ ] iPad optimization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is available under the MIT license.

---

**Built with modern technologies for scalable team collaboration and productivity management.**