import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull, Not } from 'typeorm';
import { Issue } from './entities/issue.entity';
import { CreateIssueDto } from './dto/create-issue.dto';
import { UpdateIssueDto } from './dto/update-issue.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class IssuesService {
  constructor(
    @InjectRepository(Issue)
    private issuesRepository: Repository<Issue>,
  ) {}

  async create(createIssueDto: CreateIssueDto, user: User): Promise<Issue> {
    const issue = this.issuesRepository.create({
      ...createIssueDto,
      reporterId: createIssueDto.reporterId || user.id,
    });

    return await this.issuesRepository.save(issue);
  }

  async findAll(user: User, includeDeleted: boolean = false): Promise<Issue[]> {
    const queryBuilder = this.issuesRepository
      .createQueryBuilder('issue')
      .leftJoinAndSelect('issue.reporter', 'reporter')
      .leftJoinAndSelect('issue.assignee', 'assignee')
      .leftJoin('reporter.group', 'reporterGroup')
      .where('reporterGroup.id = :groupId', { groupId: user.groupId })
      .orderBy('issue.createdAt', 'DESC');

    if (!includeDeleted) {
      queryBuilder.andWhere('issue.trashedDate IS NULL');
    }

    return await queryBuilder.getMany();
  }

  async findOne(id: string, user: User): Promise<Issue> {
    const issue = await this.issuesRepository
      .createQueryBuilder('issue')
      .leftJoinAndSelect('issue.reporter', 'reporter')
      .leftJoinAndSelect('issue.assignee', 'assignee')
      .leftJoinAndSelect('issue.comments', 'comments')
      .leftJoin('reporter.group', 'reporterGroup')
      .where('issue.id = :id', { id })
      .andWhere('reporterGroup.id = :groupId', { groupId: user.groupId })
      .getOne();

    if (!issue) {
      throw new NotFoundException('Issue not found');
    }

    return issue;
  }

  async update(id: string, updateIssueDto: UpdateIssueDto, user: User): Promise<Issue> {
    const issue = await this.findOne(id, user);
    
    Object.assign(issue, updateIssueDto);
    
    return await this.issuesRepository.save(issue);
  }

  async remove(id: string, user: User): Promise<Issue> {
    const issue = await this.findOne(id, user);
    
    issue.trashedDate = new Date();
    
    return await this.issuesRepository.save(issue);
  }

  async restore(id: string, user: User): Promise<Issue> {
    const issue = await this.issuesRepository
      .createQueryBuilder('issue')
      .leftJoinAndSelect('issue.reporter', 'reporter')
      .leftJoin('reporter.group', 'reporterGroup')
      .where('issue.id = :id', { id })
      .andWhere('reporterGroup.id = :groupId', { groupId: user.groupId })
      .andWhere('issue.trashedDate IS NOT NULL')
      .getOne();

    if (!issue) {
      throw new NotFoundException('Deleted issue not found');
    }
    
    issue.trashedDate = null;
    
    return await this.issuesRepository.save(issue);
  }
}