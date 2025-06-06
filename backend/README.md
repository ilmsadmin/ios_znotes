# iOS ZNotes API

A NestJS API backend for the iOS ZNotes application with authentication, group management, and CRUD operations.

## Features

### 🔐 Authentication & Authorization
- User registration with email verification
- JWT-based authentication
- Email domain-based automatic grouping
- Group admin permissions
- Role-based access control

### 👥 Group Management
- Automatic group creation based on email domains
- First user of a domain becomes group admin
- Group admin can manage user roles
- Group-scoped data access

### 📝 API Endpoints
- **Notes**: Personal note management
- **Tasks**: Task management with assignments
- **Issues**: Issue tracking with comments
- **Assignments**: Work assignment management
- **Users**: User management
- **Groups**: Group management

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment:
```bash
cp .env.example .env
# Edit .env with your database and JWT configuration
```

4. Setup database:
```bash
# Create MySQL database named 'znotes'
# Tables will be auto-created when the app starts
```

5. Start the development server:
```bash
npm run start:dev
```

The API will be available at:
- **API**: http://localhost:3000/api/v1
- **Documentation**: http://localhost:3000/api/docs

## API Documentation

Visit http://localhost:3000/api/docs for interactive Swagger documentation.

### Key API Endpoints

#### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `GET /api/v1/auth/verify-email?token=` - Verify email
- `GET /api/v1/auth/profile` - Get current user profile

#### Groups & Users
- `GET /api/v1/groups` - Get all groups
- `GET /api/v1/groups/:id/members` - Get group members
- `PATCH /api/v1/groups/:groupId/users/:userId/role` - Update user role (admin only)

#### Notes
- `GET /api/v1/notes` - Get user notes
- `POST /api/v1/notes` - Create note
- `GET /api/v1/notes/:id` - Get note by ID
- `PATCH /api/v1/notes/:id` - Update note
- `DELETE /api/v1/notes/:id` - Delete note

#### Tasks
- `GET /api/v1/tasks` - Get group tasks
- `POST /api/v1/tasks` - Create task
- `GET /api/v1/tasks/:id` - Get task by ID
- `PATCH /api/v1/tasks/:id` - Update task
- `DELETE /api/v1/tasks/:id` - Delete task

## Architecture

### Database Schema
- **Users**: User accounts with authentication and group membership
- **Groups**: Email domain-based groups with admin management
- **Notes**: Personal notes (user-scoped)
- **Tasks**: Group tasks with assignments and priorities
- **Issues**: Group issues with comments and tracking
- **Assignments**: Task/issue assignments to users

### Security Features
- Password hashing with bcryptjs
- JWT token authentication
- Email verification requirement
- Group-based data isolation
- Role-based permissions

### Email Domain Grouping Logic
1. User registers with email (e.g., john@company.com)
2. System extracts domain (company.com)
3. If group for domain doesn't exist:
   - Create new group named after domain
   - Make user the group admin
4. If group exists:
   - Add user as regular member
   - Existing admin maintains permissions

## Development

### Available Scripts
- `npm run start:dev` - Development server with hot reload
- `npm run build` - Build for production
- `npm run start:prod` - Start production server
- `npm run test` - Run tests
- `npm run lint` - Lint code

### Database Management
The application uses TypeORM with MySQL. Database schema is automatically synchronized in development mode.

### Testing
Run the test suite:
```bash
npm run test
```

## Deployment

1. Build the application:
```bash
npm run build
```

2. Set production environment variables
3. Start the production server:
```bash
npm run start:prod
```

## License

MIT License - see LICENSE file for details.