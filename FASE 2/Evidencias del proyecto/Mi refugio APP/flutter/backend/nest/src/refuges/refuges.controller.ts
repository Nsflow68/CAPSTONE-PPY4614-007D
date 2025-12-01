import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  ParseBoolPipe,
} from '@nestjs/common';
import { RefugesService } from './refuges.service';
import { CreateRefugeDto } from './dto/create-refuge.dto';
import { UpdateRefugeDto } from './dto/update-refuge.dto';

@Controller('refuges')
export class RefugesController {
  constructor(private readonly refugesService: RefugesService) {}

  @Get()
  findAll(
    @Query('region') region?: string,
    @Query('isActive', new ParseBoolPipe({ optional: true })) isActive?: boolean,
  ) {
    return this.refugesService.findAll(region, isActive);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.refugesService.findOne(id);
  }

  @Get(':id/statistics')
  getStatistics(@Param('id') id: string) {
    return this.refugesService.getStatistics(id);
  }

  @Post()
  create(@Body() createRefugeDto: CreateRefugeDto) {
    return this.refugesService.create(createRefugeDto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateRefugeDto: UpdateRefugeDto) {
    return this.refugesService.update(id, updateRefugeDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.refugesService.remove(id);
  }
}
