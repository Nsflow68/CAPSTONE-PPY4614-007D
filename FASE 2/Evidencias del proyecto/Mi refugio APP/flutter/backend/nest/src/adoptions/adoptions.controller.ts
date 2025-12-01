import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  Patch,
} from '@nestjs/common';
import { AdoptionsService } from './adoptions.service';
import { CreateAdoptionDto } from './dto/create-adoption.dto';
import { UpdateAdoptionDto } from './dto/update-adoption.dto';

@Controller('adoptions')
export class AdoptionsController {
  constructor(private readonly adoptionsService: AdoptionsService) {}

  @Get()
  findAll(
    @Query('refugeId') refugeId?: string,
    @Query('status') status?: string,
    @Query('petType') petType?: string,
  ) {
    return this.adoptionsService.findAll(refugeId, status, petType);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.adoptionsService.findOne(id);
  }

  @Post()
  create(@Body() createAdoptionDto: CreateAdoptionDto) {
    return this.adoptionsService.create(createAdoptionDto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateAdoptionDto: UpdateAdoptionDto) {
    return this.adoptionsService.update(id, updateAdoptionDto);
  }

  @Patch(':id/adopt')
  markAsAdopted(@Param('id') id: string, @Body('adoptedBy') adoptedBy: string) {
    return this.adoptionsService.markAsAdopted(id, adoptedBy);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.adoptionsService.remove(id);
  }
}
