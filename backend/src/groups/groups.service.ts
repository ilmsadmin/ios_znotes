import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Group } from './entities/group.entity';
import { User, UserRole } from '../users/entities/user.entity';

@Injectable()
export class GroupsService {
  constructor(
    @InjectRepository(Group)
    private groupsRepository: Repository<Group>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<Group[]> {
    return this.groupsRepository.find({
      relations: ['admin', 'members'],
    });
  }

  async findOne(id: string): Promise<Group> {
    const group = await this.groupsRepository.findOne({
      where: { id },
      relations: ['admin', 'members'],
    });

    if (!group) {
      throw new NotFoundException('Group not found');
    }

    return group;
  }

  async findByDomain(domain: string): Promise<Group> {
    return this.groupsRepository.findOne({
      where: { domain },
      relations: ['admin', 'members'],
    });
  }

  async updateUserRole(
    groupId: string,
    userId: string,
    newRole: string,
    currentUser: User,
  ): Promise<User> {
    // Check if current user is group admin
    if (currentUser.userRole !== UserRole.GROUP_ADMIN || currentUser.groupId !== groupId) {
      throw new ForbiddenException('Only group admins can update user roles');
    }

    const user = await this.usersRepository.findOne({
      where: { id: userId, groupId },
    });

    if (!user) {
      throw new NotFoundException('User not found in this group');
    }

    user.role = newRole;
    return this.usersRepository.save(user);
  }

  async getGroupMembers(groupId: string): Promise<User[]> {
    return this.usersRepository.find({
      where: { groupId },
      select: ['id', 'name', 'email', 'role', 'userRole', 'profileImage', 'createdAt'],
    });
  }
}