import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateAdoptionDto } from './dto/create-adoption.dto';
import { UpdateAdoptionDto } from './dto/update-adoption.dto';

@Injectable()
export class AdoptionsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(refugeId?: string, status?: string, petType?: string) {
    const where: any = {};

    if (refugeId) {
      where.refugeId = refugeId;
    }

    if (status) {
      where.status = status;
    }

    if (petType) {
      where.petType = petType;
    }

    return this.prisma.adoption.findMany({
      where,
      include: {
        refuge: {
          select: {
            id: true,
            name: true,
            region: true,
            phone: true,
            email: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const adoption = await this.prisma.adoption.findUnique({
      where: { id },
      include: {
        refuge: true,
      },
    });

    if (!adoption) {
      throw new NotFoundException(`Adopción con ID ${id} no encontrada`);
    }

    return adoption;
  }

  async create(createAdoptionDto: CreateAdoptionDto) {
    return this.prisma.adoption.create({
      data: createAdoptionDto,
      include: {
        refuge: true,
      },
    });
  }

  async update(id: string, updateAdoptionDto: UpdateAdoptionDto) {
    await this.findOne(id); // Verifica que existe

    const data: any = { ...updateAdoptionDto };

    // Si se marca como adoptado, registrar fecha
    if (updateAdoptionDto.status === 'adopted' && !data.adoptedAt) {
      data.adoptedAt = new Date();
    }

    return this.prisma.adoption.update({
      where: { id },
      data,
      include: {
        refuge: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id); // Verifica que existe

    return this.prisma.adoption.delete({
      where: { id },
    });
  }

  async markAsAdopted(id: string, adoptedBy: string) {
    return this.update(id, {
      status: 'adopted',
      adoptedBy,
    });
  }
}
