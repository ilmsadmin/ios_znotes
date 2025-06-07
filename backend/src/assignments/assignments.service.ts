import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Assignment } from './entities/assignment.entity';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { UpdateAssignmentDto } from './dto/update-assignment.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AssignmentsService {
  constructor(
    @InjectRepository(Assignment)
    private assignmentsRepository: Repository<Assignment>,
  ) {}

  async create(createAssignmentDto: CreateAssignmentDto, user: User): Promise<Assignment> {
    const assignment = this.assignmentsRepository.create({
      ...createAssignmentDto,
      dueDate: createAssignmentDto.dueDate ? new Date(createAssignmentDto.dueDate) : null,
      createdById: user.id,
    });

    return await this.assignmentsRepository.save(assignment);
  }

  async findAll(user: User, includeDeleted: boolean = false): Promise<Assignment[]> {
    return await this.assignmentsRepository
      .createQueryBuilder('assignment')
      .leftJoinAndSelect('assignment.createdBy', 'createdBy')
      .leftJoinAndSelect('assignment.person', 'person')
      .leftJoin('createdBy.group', 'createdByGroup')
      .where('createdByGroup.id = :groupId', { groupId: user.groupId })
      .orderBy('assignment.createdAt', 'DESC')
      .getMany();
  }

  async findOne(id: string, user: User): Promise<Assignment> {
    const assignment = await this.assignmentsRepository
      .createQueryBuilder('assignment')
      .leftJoinAndSelect('assignment.createdBy', 'createdBy')
      .leftJoinAndSelect('assignment.person', 'person')
      .leftJoin('createdBy.group', 'createdByGroup')
      .where('assignment.id = :id', { id })
      .andWhere('createdByGroup.id = :groupId', { groupId: user.groupId })
      .getOne();

    if (!assignment) {
      throw new NotFoundException('Assignment not found');
    }

    return assignment;
  }

  async update(id: string, updateAssignmentDto: UpdateAssignmentDto, user: User): Promise<Assignment> {
    const assignment = await this.findOne(id, user);
    
    if (updateAssignmentDto.dueDate) {
      updateAssignmentDto.dueDate = new Date(updateAssignmentDto.dueDate) as any;
    }
    
    Object.assign(assignment, updateAssignmentDto);
    
    return await this.assignmentsRepository.save(assignment);
  }

  async remove(id: string, user: User): Promise<void> {
    const assignment = await this.findOne(id, user);
    await this.assignmentsRepository.remove(assignment);
  }
}