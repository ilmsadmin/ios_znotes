import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { IssuesService } from './issues.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateIssueDto } from './dto/create-issue.dto';
import { UpdateIssueDto } from './dto/update-issue.dto';

@ApiTags('issues')
@Controller('issues')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class IssuesController {
  constructor(private readonly issuesService: IssuesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new issue' })
  @ApiResponse({ status: 201, description: 'Issue created successfully' })
  create(@Body() createIssueDto: CreateIssueDto, @Request() req) {
    return this.issuesService.create(createIssueDto, req.user);
  }

  @Get()
  @ApiOperation({ summary: 'Get all issues for user group' })
  @ApiResponse({ status: 200, description: 'Issues retrieved successfully' })
  findAll(@Request() req, @Query('includeDeleted') includeDeleted?: boolean) {
    return this.issuesService.findAll(req.user, includeDeleted === true);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get issue by ID' })
  @ApiResponse({ status: 200, description: 'Issue retrieved successfully' })
  findOne(@Param('id') id: string, @Request() req) {
    return this.issuesService.findOne(id, req.user);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update issue' })
  @ApiResponse({ status: 200, description: 'Issue updated successfully' })
  update(@Param('id') id: string, @Body() updateIssueDto: UpdateIssueDto, @Request() req) {
    return this.issuesService.update(id, updateIssueDto, req.user);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete issue' })
  @ApiResponse({ status: 200, description: 'Issue deleted successfully' })
  remove(@Param('id') id: string, @Request() req) {
    return this.issuesService.remove(id, req.user);
  }

  @Patch(':id/restore')
  @ApiOperation({ summary: 'Restore deleted issue' })
  @ApiResponse({ status: 200, description: 'Issue restored successfully' })
  restore(@Param('id') id: string, @Request() req) {
    return this.issuesService.restore(id, req.user);
  }
}