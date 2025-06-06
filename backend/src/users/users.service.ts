import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find({
      relations: ['group'],
      select: ['id', 'name', 'email', 'role', 'userRole', 'profileImage', 'emailDomain', 'createdAt'],
    });
  }

  async findOne(id: string): Promise<User> {
    return this.usersRepository.findOne({
      where: { id },
      relations: ['group'],
      select: ['id', 'name', 'email', 'role', 'userRole', 'profileImage', 'emailDomain', 'createdAt'],
    });
  }

  async findByGroupId(groupId: string): Promise<User[]> {
    return this.usersRepository.find({
      where: { groupId },
      select: ['id', 'name', 'email', 'role', 'userRole', 'profileImage', 'emailDomain', 'createdAt'],
    });
  }
}