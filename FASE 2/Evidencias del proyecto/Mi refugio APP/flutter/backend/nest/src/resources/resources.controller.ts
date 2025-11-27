import { Controller, Get, Query } from '@nestjs/common';
import { ResourcesService } from './resources.service';

@Controller('resources')
export class ResourcesController {
  constructor(private readonly resourcesService: ResourcesService) {}

  @Get()
  list(@Query('q') q?: string, @Query('category') category?: string) {
    return this.resourcesService.list({ q, category });
  }
}
