import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GroupsService } from './groups.service';
import { GroupsController } from './groups.controller';
import { Group } from './entities/group.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Group, User])],
  controllers: [GroupsController],
  providers: [GroupsService],
  exports: [GroupsService],
})
export class GroupsModule {}