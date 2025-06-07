import { IsString, IsNotEmpty, IsEnum, IsOptional, IsUUID, IsArray } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Priority, TaskStatus } from '../../common/enums';

export class CreateIssueDto {
  @ApiProperty({ description: 'Issue title' })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ description: 'Issue description', required: false })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ enum: Priority, description: 'Issue priority' })
  @IsEnum(Priority)
  priority: Priority;

  @ApiProperty({ enum: TaskStatus, description: 'Issue status' })
  @IsEnum(TaskStatus)
  status: TaskStatus;

  @ApiProperty({ description: 'Reporter user ID', required: false })
  @IsOptional()
  @IsUUID()
  reporterId?: string;

  @ApiProperty({ description: 'Assignee user ID', required: false })
  @IsOptional()
  @IsUUID()
  assigneeId?: string;

  @ApiProperty({ description: 'Tags array', required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}
