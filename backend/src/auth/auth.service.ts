import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcryptjs from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { User, UserRole } from '../users/entities/user.entity';
import { Group } from '../groups/entities/group.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(Group)
    private groupsRepository: Repository<Group>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { name, email, password } = registerDto;

    // Check if user already exists
    const existingUser = await this.usersRepository.findOne({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Extract email domain
    const emailDomain = email.split('@')[1];
    if (!emailDomain) {
      throw new BadRequestException('Invalid email format');
    }

    // Hash password
    const hashedPassword = await bcryptjs.hash(password, 12);

    // Generate email verification token
    const emailVerificationToken = uuidv4();

    // Find or create group for email domain
    let group = await this.groupsRepository.findOne({
      where: { domain: emailDomain },
      relations: ['admin'],
    });

    let userRole = UserRole.USER;

    if (!group) {
      // Create new group for this domain
      group = this.groupsRepository.create({
        name: emailDomain,
        domain: emailDomain,
        description: `Group for ${emailDomain} domain`,
        isActive: true,
      });
      group = await this.groupsRepository.save(group);
      userRole = UserRole.GROUP_ADMIN; // First user becomes group admin
    }

    // Create user
    const user = this.usersRepository.create({
      name,
      email,
      password: hashedPassword,
      emailDomain,
      userRole,
      emailVerificationToken,
      isEmailVerified: false,
      group,
    });

    const savedUser = await this.usersRepository.save(user);

    // If this is the first user in the group, make them admin
    if (userRole === UserRole.GROUP_ADMIN) {
      group.admin = savedUser;
      group.adminId = savedUser.id;
      await this.groupsRepository.save(group);
    }

    // Return user without sensitive data
    const { password: _, emailVerificationToken: __, ...userResponse } = savedUser;

    return {
      message: 'User registered successfully. Please verify your email.',
      user: userResponse,
      emailVerificationRequired: true,
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user with group information
    const user = await this.usersRepository.findOne({
      where: { email },
      relations: ['group'],
      select: ['id', 'name', 'email', 'password', 'userRole', 'isEmailVerified', 'profileImage', 'role'],
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isEmailVerified) {
      throw new UnauthorizedException('Please verify your email before logging in');
    }

    // Verify password
    const isPasswordValid = await bcryptjs.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate JWT token
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.userRole,
      groupId: user.group?.id,
    };

    const access_token = this.jwtService.sign(payload);

    // Return user without password
    const { password: _, ...userResponse } = user;

    return {
      access_token,
      user: userResponse,
    };
  }

  async verifyEmail(token: string) {
    const user = await this.usersRepository.findOne({
      where: { emailVerificationToken: token },
    });

    if (!user) {
      throw new BadRequestException('Invalid verification token');
    }

    if (user.isEmailVerified) {
      throw new BadRequestException('Email already verified');
    }

    user.isEmailVerified = true;
    user.emailVerificationToken = null;
    await this.usersRepository.save(user);

    return {
      message: 'Email verified successfully. You can now log in.',
    };
  }

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.usersRepository.findOne({
      where: { email },
      select: ['id', 'name', 'email', 'password', 'userRole', 'isEmailVerified'],
    });

    if (user && await bcryptjs.compare(password, user.password)) {
      const { password: _, ...result } = user;
      return result;
    }
    return null;
  }

  async findUserById(id: string) {
    return await this.usersRepository.findOne({
      where: { id },
      relations: ['group'],
    });
  }
}