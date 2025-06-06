import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { AssignmentType } from '../enums';

@Entity('assignments')
export class Assignment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: AssignmentType,
  })
  type: AssignmentType;

  @Column({ type: 'uuid' })
  @Index()
  itemId: string; // ID của Task hoặc Issue

  @ManyToOne(() => User, (user) => user.assignments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'personId' })
  person: User;

  @Column({ type: 'uuid' })
  @Index()
  personId: string;

  @Column({ type: 'datetime', nullable: true })
  dueDate: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'createdById' })
  createdBy: User;

  @Column({ type: 'uuid' })
  @Index()
  createdById: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}