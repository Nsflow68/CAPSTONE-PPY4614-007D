export class ResourceItemDto {
  id!: string;
  name!: string;
  category!: string;
  description!: string;
  coverage?: string;
  contactPhone?: string;
  contactEmail?: string;
  website?: string;
  region?: string;
  tags?: string[];
}
