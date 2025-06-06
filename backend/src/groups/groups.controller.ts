import { Controller, Get, Param, Patch, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { GroupsService } from './groups.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('groups')
@Controller('groups')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all groups' })
  @ApiResponse({
    status: 200,
    description: 'List of all groups',
  })
  findAll() {
    return this.groupsService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get group by ID' })
  @ApiResponse({
    status: 200,
    description: 'Group details with members',
  })
  @ApiResponse({
    status: 404,
    description: 'Group not found',
  })
  findOne(@Param('id') id: string) {
    return this.groupsService.findOne(id);
  }

  @Get(':id/members')
  @ApiOperation({ summary: 'Get group members' })
  @ApiResponse({
    status: 200,
    description: 'List of group members',
  })
  getMembers(@Param('id') id: string) {
    return this.groupsService.getGroupMembers(id);
  }

  @Patch(':groupId/users/:userId/role')
  @ApiOperation({ summary: 'Update user role (Group Admin only)' })
  @ApiResponse({
    status: 200,
    description: 'User role updated successfully',
  })
  @ApiResponse({
    status: 403,
    description: 'Only group admins can update user roles',
  })
  @ApiResponse({
    status: 404,
    description: 'User not found in this group',
  })
  updateUserRole(
    @Param('groupId') groupId: string,
    @Param('userId') userId: string,
    @Body('role') role: string,
    @GetUser() currentUser: User,
  ) {
    return this.groupsService.updateUserRole(groupId, userId, role, currentUser);
  }
}