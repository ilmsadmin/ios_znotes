import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEnum, IsOptional, IsArray, IsDateString, IsUUID } from 'class-validator';
import { Priority, TaskStatus } from '../../common/enums';

export class CreateTaskDto {
  @ApiProperty({ description: 'Task title', example: 'Implement user authentication' })
  @IsNotEmpty()
  @IsString()
  title: string;

  @ApiProperty({ description: 'Task description', example: 'Add login and registration functionality' })
  @IsNotEmpty()
  @IsString()
  description: string;

  @ApiProperty({ enum: Priority, default: Priority.MEDIUM })
  @IsEnum(Priority)
  @IsOptional()
  priority?: Priority;

  @ApiProperty({ enum: TaskStatus, default: TaskStatus.TODO })
  @IsEnum(TaskStatus)
  @IsOptional()
  status?: TaskStatus;

  @ApiProperty({ description: 'Tags', example: ['authentication', 'security'], required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiProperty({ description: 'Due date', required: false })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiProperty({ description: 'Assignee user ID', required: false })
  @IsOptional()
  @IsUUID()
  assigneeId?: string;
}