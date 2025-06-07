import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Group } from '../../groups/entities/group.entity';
import { Note } from '../../notes/entities/note.entity';
import { Task } from '../../tasks/entities/task.entity';
import { Issue } from '../../issues/entities/issue.entity';
import { Assignment } from '../../assignments/entities/assignment.entity';
import { Comment } from '../../issues/entities/comment.entity';

export enum UserRole {
  USER = 'user',
  GROUP_ADMIN = 'group_admin',
  SYSTEM_ADMIN = 'system_admin',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 255, unique: true })
  email: string;

  @Column({ length: 255 })
  password: string;

  @Column({ length: 50, default: 'user' })
  role: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.USER,
  })
  userRole: UserRole;

  @Column({ length: 255, nullable: true })
  profileImage: string;

  @Column({ default: false })
  isEmailVerified: boolean;

  @Column({ length: 255, nullable: true })
  emailVerificationToken: string;

  @Column({ length: 255, nullable: true })
  resetPasswordToken: string;

  @Column({ type: 'datetime', nullable: true })
  resetPasswordExpiry: Date;

  @Column({ length: 100 })
  @Index()
  emailDomain: string;

  @ManyToOne(() => Group, (group) => group.members, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'groupId' })
  group: Group;

  @Column({ type: 'uuid', nullable: true })
  groupId: string;

  @OneToMany(() => Note, (note) => note.author)
  notes: Note[];

  @OneToMany(() => Task, (task) => task.assignee)
  assignedTasks: Task[];

  @OneToMany(() => Issue, (issue) => issue.reporter)
  reportedIssues: Issue[];

  @OneToMany(() => Issue, (issue) => issue.assignee)
  assignedIssues: Issue[];

  @OneToMany(() => Assignment, (assignment) => assignment.person)
  assignments: Assignment[];

  @OneToMany(() => Comment, (comment) => comment.author)
  comments: Comment[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'datetime', nullable: true })
  trashedDate: Date;
}