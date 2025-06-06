import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { NotesService } from './notes.service';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('notes')
@Controller('notes')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotesController {
  constructor(private readonly notesService: NotesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new note' })
  @ApiResponse({
    status: 201,
    description: 'Note created successfully',
  })
  create(@Body() createNoteDto: CreateNoteDto, @GetUser() user: User) {
    return this.notesService.create(createNoteDto, user);
  }

  @Get()
  @ApiOperation({ summary: 'Get all user notes' })
  @ApiResponse({
    status: 200,
    description: 'List of user notes',
  })
  findAll(@GetUser() user: User) {
    return this.notesService.findAll(user);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search notes by title or content' })
  @ApiQuery({ name: 'q', description: 'Search query' })
  @ApiResponse({
    status: 200,
    description: 'Search results',
  })
  search(@Query('q') query: string, @GetUser() user: User) {
    return this.notesService.search(query, user);
  }

  @Get('by-tags')
  @ApiOperation({ summary: 'Filter notes by tags' })
  @ApiQuery({ name: 'tags', description: 'Comma-separated tags' })
  @ApiResponse({
    status: 200,
    description: 'Notes filtered by tags',
  })
  findByTags(@Query('tags') tagsQuery: string, @GetUser() user: User) {
    const tags = tagsQuery.split(',').map(tag => tag.trim());
    return this.notesService.findByTags(tags, user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get note by ID' })
  @ApiResponse({
    status: 200,
    description: 'Note details',
  })
  @ApiResponse({
    status: 404,
    description: 'Note not found',
  })
  findOne(@Param('id') id: string, @GetUser() user: User) {
    return this.notesService.findOne(id, user);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update note' })
  @ApiResponse({
    status: 200,
    description: 'Note updated successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Note not found',
  })
  update(@Param('id') id: string, @Body() updateNoteDto: UpdateNoteDto, @GetUser() user: User) {
    return this.notesService.update(id, updateNoteDto, user);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete note (move to trash)' })
  @ApiResponse({
    status: 200,
    description: 'Note deleted successfully',
  })
  @ApiResponse({
    status: 404,
    description: 'Note not found',
  })
  remove(@Param('id') id: string, @GetUser() user: User) {
    return this.notesService.remove(id, user);
  }
}