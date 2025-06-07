# iOS ZNotes API Documentation

## Overview

The iOS ZNotes API provides a complete backend solution for the iOS notes application with authentication, group management, and CRUD operations for notes, tasks, issues, and assignments.

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication

All endpoints except registration, login, and email verification require Bearer token authentication.

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## API Endpoints

### Authentication

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@company.com",
  "password": "password123"
}
```

**Response (201):**
```json
{
  "message": "User registered successfully. Please verify your email.",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@company.com",
    "userRole": "group_admin",
    "emailDomain": "company.com",
    "isEmailVerified": false
  },
  "emailVerificationRequired": true
}
```

#### Login User
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@company.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "access_token": "jwt.token.here",
  "user": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@company.com",
    "userRole": "group_admin",
    "group": {
      "id": "uuid",
      "name": "company.com",
      "domain": "company.com"
    }
  }
}
```

#### Verify Email
```http
GET /auth/verify-email?token=verification_token
```

#### Get Profile
```http
GET /auth/profile
Authorization: Bearer <token>
```

### Groups

#### Get All Groups
```http
GET /groups
Authorization: Bearer <token>
```

#### Get Group Members
```http
GET /groups/{groupId}/members
Authorization: Bearer <token>
```

#### Update User Role (Group Admin only)
```http
PATCH /groups/{groupId}/users/{userId}/role
Authorization: Bearer <token>
Content-Type: application/json

{
  "role": "Developer"
}
```

### Notes

#### Get User Notes
```http
GET /notes
Authorization: Bearer <token>
```

#### Create Note
```http
POST /notes
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Meeting Notes",
  "content": "Discussed project timeline...",
  "tags": ["meeting", "project"]
}
```

#### Get Note by ID
```http
GET /notes/{noteId}
Authorization: Bearer <token>
```

#### Update Note
```http
PATCH /notes/{noteId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Meeting Notes",
  "content": "Updated content...",
  "tags": ["meeting", "project", "updated"]
}
```

#### Delete Note
```http
DELETE /notes/{noteId}
Authorization: Bearer <token>
```

#### Search Notes
```http
GET /notes/search?q=meeting
Authorization: Bearer <token>
```

#### Filter Notes by Tags
```http
GET /notes/by-tags?tags=meeting,project
Authorization: Bearer <token>
```

### Tasks

#### Get Group Tasks
```http
GET /tasks
Authorization: Bearer <token>
```

#### Create Task
```http
POST /tasks
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Implement user authentication",
  "description": "Add login and registration functionality",
  "priority": "High",
  "status": "To Do",
  "tags": ["authentication", "security"],
  "dueDate": "2024-12-31T23:59:59Z",
  "assigneeId": "user-uuid"
}
```

#### Get Task by ID
```http
GET /tasks/{taskId}
Authorization: Bearer <token>
```

#### Update Task
```http
PATCH /tasks/{taskId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "In Progress",
  "priority": "Critical"
}
```

#### Delete Task
```http
DELETE /tasks/{taskId}
Authorization: Bearer <token>
```

### Users

#### Get All Users
```http
GET /users
Authorization: Bearer <token>
```

#### Get User by ID
```http
GET /users/{userId}
Authorization: Bearer <token>
```

#### Get Users by Group
```http
GET /users/group/{groupId}
Authorization: Bearer <token>
```

## Data Models

### User Roles
- `user` - Regular group member
- `group_admin` - Group administrator
- `system_admin` - System administrator

### Priority Levels
- `Low` - Minor improvements
- `Medium` - Standard priority  
- `High` - Important items
- `Critical` - Urgent items

### Task/Issue Status
- `To Do` - Not started
- `In Progress` - Currently being worked on
- `In Review` - Awaiting review
- `Done` - Completed
- `Cancelled` - No longer needed

### Assignment Types
- `Task` - Task assignment
- `Issue` - Issue assignment

## Error Handling

### Common Error Responses

#### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

#### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

#### 403 Forbidden
```json
{
  "statusCode": 403,
  "message": "Only group admins can update user roles",
  "error": "Forbidden"
}
```

#### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Note not found",
  "error": "Not Found"
}
```

#### 409 Conflict
```json
{
  "statusCode": 409,
  "message": "User with this email already exists",
  "error": "Conflict"
}
```

## Group Management Logic

1. **User Registration**: When a user registers with an email (e.g., `john@company.com`):
   - Extract domain (`company.com`)
   - Check if group for domain exists
   - If no group exists:
     - Create new group named after domain
     - Make user the group admin (`group_admin` role)
   - If group exists:
     - Add user as regular member (`user` role)

2. **Group Admin Permissions**:
   - Can update user roles within their group
   - Can view all group members
   - Have full access to group tasks and issues

3. **Data Scoping**:
   - **Notes**: User-scoped (only creator can access)
   - **Tasks**: Group-scoped (all group members can access)
   - **Issues**: Group-scoped (all group members can access)
   - **Assignments**: Group-scoped (all group members can access)

## Interactive Documentation

For interactive API documentation with the ability to test endpoints directly, visit:

```
http://localhost:3000/api/docs
```

This provides a complete Swagger UI interface with all endpoints, request/response schemas, and authentication capabilities.