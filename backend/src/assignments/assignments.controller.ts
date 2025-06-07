import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AssignmentsService } from './assignments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { UpdateAssignmentDto } from './dto/update-assignment.dto';

@ApiTags('assignments')
@Controller('assignments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AssignmentsController {
  constructor(private readonly assignmentsService: AssignmentsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new assignment' })
  @ApiResponse({ status: 201, description: 'Assignment created successfully' })
  create(@Body() createAssignmentDto: CreateAssignmentDto, @Request() req) {
    return this.assignmentsService.create(createAssignmentDto, req.user);
  }

  @Get()
  @ApiOperation({ summary: 'Get all assignments for user group' })
  @ApiResponse({ status: 200, description: 'Assignments retrieved successfully' })
  findAll(@Request() req, @Query('includeDeleted') includeDeleted?: boolean) {
    return this.assignmentsService.findAll(req.user, includeDeleted === true);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get assignment by ID' })
  @ApiResponse({ status: 200, description: 'Assignment retrieved successfully' })
  findOne(@Param('id') id: string, @Request() req) {
    return this.assignmentsService.findOne(id, req.user);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update assignment' })
  @ApiResponse({ status: 200, description: 'Assignment updated successfully' })
  update(@Param('id') id: string, @Body() updateAssignmentDto: UpdateAssignmentDto, @Request() req) {
    return this.assignmentsService.update(id, updateAssignmentDto, req.user);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete assignment' })
  @ApiResponse({ status: 200, description: 'Assignment deleted successfully' })
  remove(@Param('id') id: string, @Request() req) {
    return this.assignmentsService.remove(id, req.user);
  }
}