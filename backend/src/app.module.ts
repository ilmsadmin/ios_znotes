import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { GroupsModule } from './groups/groups.module';
import { NotesModule } from './notes/notes.module';
import { TasksModule } from './tasks/tasks.module';
import { IssuesModule } from './issues/issues.module';
import { AssignmentsModule } from './assignments/assignments.module';
import { User } from './users/entities/user.entity';
import { Group } from './groups/entities/group.entity';
import { Note } from './notes/entities/note.entity';
import { Task } from './tasks/entities/task.entity';
import { Issue } from './issues/entities/issue.entity';
import { Assignment } from './assignments/entities/assignment.entity';
import { Comment } from './issues/entities/comment.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'mysql',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get('DB_PORT', 3306),
        username: configService.get('DB_USERNAME', 'root'),
        password: configService.get('DB_PASSWORD', ''),
        database: configService.get('DB_DATABASE', 'znotes'),
        entities: [User, Group, Note, Task, Issue, Assignment, Comment],
        synchronize: configService.get('NODE_ENV') !== 'production',
        logging: configService.get('NODE_ENV') !== 'production',
      }),
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    GroupsModule,
    NotesModule,
    TasksModule,
    IssuesModule,
    AssignmentsModule,
  ],
})
export class AppModule {}