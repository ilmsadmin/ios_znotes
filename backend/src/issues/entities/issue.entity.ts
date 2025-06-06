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
import { User } from '../../users/entities/user.entity';
import { Comment } from './comment.entity';
import { Priority, TaskStatus } from '../../common/enums';

@Entity('issues')
export class Issue {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({
    type: 'enum',
    enum: Priority,
    default: Priority.MEDIUM,
  })
  priority: Priority;

  @Column({
    type: 'enum',
    enum: TaskStatus,
    default: TaskStatus.TODO,
  })
  status: TaskStatus;

  @Column({ type: 'json', nullable: true })
  tags: string[];

  @ManyToOne(() => User, (user) => user.reportedIssues, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'reporterId' })
  reporter: User;

  @Column({ type: 'uuid' })
  @Index()
  reporterId: string;

  @ManyToOne(() => User, (user) => user.assignedIssues, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'assigneeId' })
  assignee: User;

  @Column({ type: 'uuid', nullable: true })
  @Index()
  assigneeId: string;

  @OneToMany(() => Comment, (comment) => comment.issueId)
  comments: Comment[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'datetime', nullable: true })
  trashedDate: Date;
}