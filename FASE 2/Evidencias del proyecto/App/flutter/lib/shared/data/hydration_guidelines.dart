class HydrationTip {
  const HydrationTip({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final String icon;
}

const hydrationRecommendations = <HydrationTip>[
  HydrationTip(
    title: 'Meta diaria sugerida',
    detail:
        '2 litros de agua al día según recomendaciones del Ministerio de Salud de Chile (Elige Vivir Sano).',
    icon: '🥤',
  ),
  HydrationTip(
    title: 'Recuerda fraccionar',
    detail:
        'Distribuye 8 vasos durante el día: 2 en la mañana, 3 a mediodía y 3 en la tarde.',
    icon: '⏱️',
  ),
  HydrationTip(
    title: 'Infusiones e hidratación',
    detail:
        'Incluye infusiones sin azúcar, aguas saborizadas con frutas o hierbas locales.',
    icon: '🍵',
  ),
  HydrationTip(
    title: 'Alertas de deshidratación',
    detail:
        'Labios secos, cansancio o dolor de cabeza pueden indicar que necesitas beber agua.',
    icon: '⚠️',
  ),
];
