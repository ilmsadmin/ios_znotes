import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  OneToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('groups')
@Index(['domain'], { unique: true })
export class Group {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ length: 100, unique: true })
  @Index()
  domain: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @OneToOne(() => User, { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'adminId' })
  admin: User;

  @Column({ type: 'uuid', nullable: true })
  adminId: string;

  @OneToMany(() => User, (user) => user.group)
  members: User[];

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}