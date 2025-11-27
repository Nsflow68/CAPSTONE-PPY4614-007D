import 'package:mi_refugio_app/shared/models/resource_item.dart';

const mentalHealthResources = <ResourceItem>[
  ResourceItem(
    id: 'fono-salud',
    title: 'Fono Salud Responde',
    subtitle: 'Línea 24/7 del Ministerio de Salud',
    description:
        'Atención gratuita en crisis, contención emocional inmediata y derivación con profesionales acreditados.',
    category: 'Urgencia',
    asset: 'assets/images/government/gobierno_chile.png',
    contact: '600 360 7777',
    website: 'https://www.gob.cl/saludresponde',
  ),
  ResourceItem(
    id: 'linea-libre',
    title: 'Línea Libre',
    subtitle: 'Fundación para adolescentes y jóvenes',
    description:
        'Chat confidencial con psicólogos especializados para personas entre 12 y 29 años. Disponible vía app y WhatsApp.',
    category: 'Juventud',
    asset: 'assets/images/mental_health/apoyo.png',
    website: 'https://linealibre.cl',
  ),
  ResourceItem(
    id: 'todo-mejora',
    title: 'Fundación Todo Mejora',
    subtitle: 'Apoyo LGBTIQ+ y sus familias',
    description:
        'Contención emocional, acompañamiento y talleres gratuitos para fortalecer redes de apoyo y seguridad emocional.',
    category: 'Comunidad',
    asset: 'assets/images/mascot/pose3.png',
    website: 'https://todomejora.org',
  ),
  ResourceItem(
    id: 'colegio-psicologos',
    title: 'Colegio de Psicólogos de Chile',
    subtitle: 'Directorio profesional acreditado',
    description:
        'Encuentra psicólogos y psicólogas validados, con especialidades en salud mental, trauma y bienestar.',
    category: 'Profesionales',
    asset: 'assets/images/mascot/pose4.png',
    website: 'https://www.colegiodepsicologos.cl',
  ),
  ResourceItem(
    id: 'mindfulness-uc',
    title: 'Mindfulness UC',
    subtitle: 'Programa de la Pontificia Universidad Católica',
    description:
        'Talleres, cápsulas y cursos breves de mindfulness basados en evidencia científica y adaptados a la realidad chilena.',
    category: 'Mindfulness',
    asset: 'assets/images/mental_health/respiracion.png',
    website: 'https://mindfulness.uc.cl/recursos/',
  ),
  ResourceItem(
    id: 'elige-vivir-sano',
    title: 'Elige Vivir Sano - Hidratación',
    subtitle: 'Recomendaciones oficiales de hidratación',
    description:
        'Guías prácticas sobre consumo de agua, infusiones saludables y recordatorios diarios para toda la familia.',
    category: 'Hidratación',
    asset: 'assets/images/government/gobierno_chile.png',
    website: 'https://eligevivirsano.gob.cl/hidratacion',
  ),
  ResourceItem(
    id: 'respira-uchile',
    title: 'Programa Respira UChile',
    subtitle: 'Mindfulness y autocuidado',
    description:
        'Sesiones gratuitas en línea, recursos descargables y cápsulas para regular el estrés desde casa.',
    category: 'Mindfulness',
    asset: 'assets/images/mascot/pose2.png',
    website: 'https://www.saludmental.uchile.cl/respira',
  ),
];
