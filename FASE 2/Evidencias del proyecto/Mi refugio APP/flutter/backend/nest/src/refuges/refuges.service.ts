import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateRefugeDto } from './dto/create-refuge.dto';
import { UpdateRefugeDto } from './dto/update-refuge.dto';

@Injectable()
export class RefugesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(region?: string, isActive?: boolean) {
    const where: any = {};
    
    if (region) {
      where.region = region;
    }
    
    if (isActive !== undefined) {
      where.isActive = isActive;
    }

    return this.prisma.refuge.findMany({
      where,
      include: {
        adoptions: {
          where: { status: 'available' },
          take: 5,
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const refuge = await this.prisma.refuge.findUnique({
      where: { id },
      include: {
        adoptions: true,
      },
    });

    if (!refuge) {
      throw new NotFoundException(`Refugio con ID ${id} no encontrado`);
    }

    return refuge;
  }

  async create(createRefugeDto: CreateRefugeDto) {
    return this.prisma.refuge.create({
      data: {
        ...createRefugeDto,
        services: createRefugeDto.services || [],
      },
    });
  }

  async update(id: string, updateRefugeDto: UpdateRefugeDto) {
    await this.findOne(id); // Verifica que existe

    return this.prisma.refuge.update({
      where: { id },
      data: updateRefugeDto,
    });
  }

  async remove(id: string) {
    await this.findOne(id); // Verifica que existe

    return this.prisma.refuge.delete({
      where: { id },
    });
  }

  async getStatistics(id: string) {
    const refuge = await this.findOne(id);
    
    const totalAdoptions = await this.prisma.adoption.count({
      where: { refugeId: id },
    });

    const adoptedCount = await this.prisma.adoption.count({
      where: { refugeId: id, status: 'adopted' },
    });

    const availableCount = await this.prisma.adoption.count({
      where: { refugeId: id, status: 'available' },
    });

    return {
      refuge: {
        id: refuge.id,
        name: refuge.name,
        capacity: refuge.capacity,
        occupied: refuge.occupied,
      },
      adoptions: {
        total: totalAdoptions,
        adopted: adoptedCount,
        available: availableCount,
      },
      occupancyRate: refuge.capacity > 0 ? (refuge.occupied / refuge.capacity) * 100 : 0,
    };
  }
}
