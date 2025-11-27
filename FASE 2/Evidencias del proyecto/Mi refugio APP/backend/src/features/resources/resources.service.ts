import { Injectable } from '@nestjs/common';

export interface ProfessionalResource {
  id: string;
  title: string;
  subtitle: string;
  category: string;
  description: string;
  contact?: string;
  website?: string;
}

@Injectable()
export class ResourcesService {
  private readonly resources: ProfessionalResource[] = [
    {
      id: 'fono-salud',
      title: 'Fono Salud Responde',
      subtitle: 'Línea 24/7 del Ministerio de Salud',
      category: 'Urgencia',
      description:
        'Atención gratuita en crisis, contención emocional inmediata y derivación con profesionales acreditados.',
      contact: '600 360 7777',
      website: 'https://www.gob.cl/saludresponde',
    },
    {
      id: 'mindfulness-uc',
      title: 'Mindfulness UC',
      subtitle: 'Programa Pontificia Universidad Católica',
      category: 'Mindfulness',
      description:
        'Cursos, cápsulas y talleres respaldados por especialistas para incorporar atención plena a la rutina diaria.',
      website: 'https://mindfulness.uc.cl/recursos/',
    },
    {
      id: 'elige-vivir-sano',
      title: 'Elige Vivir Sano - Hidratación',
      subtitle: 'Gobierno de Chile',
      category: 'Hidratación',
      description:
        'Guía oficial sobre consumo de agua, infusiones saludables y recordatorios diarios para toda la familia.',
      website: 'https://eligevivirsano.gob.cl/hidratacion',
    },
  ];

  findAll(category?: string) {
    if (!category) {
      return this.resources;
    }
    const normalized = category.toLowerCase();
    return this.resources.filter((resource) =>
      resource.category.toLowerCase() === normalized,
    );
  }
}
