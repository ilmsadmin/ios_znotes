import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Note } from './entities/note.entity';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class NotesService {
  constructor(
    @InjectRepository(Note)
    private notesRepository: Repository<Note>,
  ) {}

  async create(createNoteDto: CreateNoteDto, user: User): Promise<Note> {
    const note = this.notesRepository.create({
      ...createNoteDto,
      authorId: user.id,
    });

    return this.notesRepository.save(note);
  }

  async findAll(user: User): Promise<Note[]> {
    return this.notesRepository.find({
      where: { authorId: user.id, trashedDate: null },
      relations: ['author'],
      order: { updatedAt: 'DESC' },
    });
  }

  async findOne(id: string, user: User): Promise<Note> {
    const note = await this.notesRepository.findOne({
      where: { id, authorId: user.id, trashedDate: null },
      relations: ['author'],
    });

    if (!note) {
      throw new NotFoundException('Note not found');
    }

    return note;
  }

  async update(id: string, updateNoteDto: UpdateNoteDto, user: User): Promise<Note> {
    const note = await this.findOne(id, user);

    Object.assign(note, updateNoteDto);
    note.updatedAt = new Date();

    return this.notesRepository.save(note);
  }

  async remove(id: string, user: User): Promise<void> {
    const note = await this.findOne(id, user);

    note.trashedDate = new Date();
    await this.notesRepository.save(note);
  }

  async search(query: string, user: User): Promise<Note[]> {
    return this.notesRepository
      .createQueryBuilder('note')
      .where('note.authorId = :userId', { userId: user.id })
      .andWhere('note.trashedDate IS NULL')
      .andWhere('(note.title LIKE :query OR note.content LIKE :query)', {
        query: `%${query}%`,
      })
      .leftJoinAndSelect('note.author', 'author')
      .orderBy('note.updatedAt', 'DESC')
      .getMany();
  }

  async findByTags(tags: string[], user: User): Promise<Note[]> {
    const queryBuilder = this.notesRepository
      .createQueryBuilder('note')
      .where('note.authorId = :userId', { userId: user.id })
      .andWhere('note.trashedDate IS NULL');

    tags.forEach((tag, index) => {
      queryBuilder.andWhere(`JSON_CONTAINS(note.tags, :tag${index})`, {
        [`tag${index}`]: JSON.stringify(tag),
      });
    });

    return queryBuilder
      .leftJoinAndSelect('note.author', 'author')
      .orderBy('note.updatedAt', 'DESC')
      .getMany();
  }
}