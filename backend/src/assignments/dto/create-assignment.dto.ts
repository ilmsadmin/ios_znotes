import { IsString, IsNotEmpty, IsEnum, IsOptional, IsUUID, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { AssignmentType } from '../enums';

export class CreateAssignmentDto {
  @ApiProperty({ enum: AssignmentType, description: 'Type of assignment (Task or Issue)' })
  @IsEnum(AssignmentType)
  type: AssignmentType;

  @ApiProperty({ description: 'ID of the task or issue being assigned' })
  @IsUUID()
  @IsNotEmpty()
  itemId: string;

  @ApiProperty({ description: 'ID of the person being assigned to' })
  @IsUUID()
  @IsNotEmpty()
  personId: string;

  @ApiProperty({ description: 'Due date for the assignment', required: false })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiProperty({ description: 'Additional notes for the assignment', required: false })
  @IsOptional()
  @IsString()
  notes?: string;
}
