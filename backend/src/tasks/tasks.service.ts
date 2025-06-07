import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './entities/task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private tasksRepository: Repository<Task>,
  ) {}

  async create(createTaskDto: CreateTaskDto, user: User): Promise<Task> {
    const task = this.tasksRepository.create({
      ...createTaskDto,
      createdById: user.id,
      dueDate: createTaskDto.dueDate ? new Date(createTaskDto.dueDate) : null,
    });

    return this.tasksRepository.save(task);
  }

  async findAll(user: User): Promise<Task[]> {
    // Users can see tasks in their group
    return this.tasksRepository
      .createQueryBuilder('task')
      .leftJoinAndSelect('task.assignee', 'assignee')
      .leftJoinAndSelect('task.createdBy', 'createdBy')
      .leftJoin('createdBy.group', 'createdByGroup')
      .where('createdByGroup.id = :groupId', { groupId: user.groupId })
      .andWhere('task.trashedDate IS NULL')
      .orderBy('task.updatedAt', 'DESC')
      .getMany();
  }

  async findOne(id: string, user: User): Promise<Task> {
    const task = await this.tasksRepository
      .createQueryBuilder('task')
      .leftJoinAndSelect('task.assignee', 'assignee')
      .leftJoinAndSelect('task.createdBy', 'createdBy')
      .leftJoin('createdBy.group', 'createdByGroup')
      .where('task.id = :id', { id })
      .andWhere('createdByGroup.id = :groupId', { groupId: user.groupId })
      .andWhere('task.trashedDate IS NULL')
      .getOne();

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    return task;
  }

  async update(id: string, updateTaskDto: UpdateTaskDto, user: User): Promise<Task> {
    const task = await this.findOne(id, user);

    Object.assign(task, {
      ...updateTaskDto,
      dueDate: updateTaskDto.dueDate ? new Date(updateTaskDto.dueDate) : task.dueDate,
      updatedAt: new Date(),
    });

    return this.tasksRepository.save(task);
  }

  async remove(id: string, user: User): Promise<void> {
    const task = await this.findOne(id, user);
    task.trashedDate = new Date();
    await this.tasksRepository.save(task);
  }
}