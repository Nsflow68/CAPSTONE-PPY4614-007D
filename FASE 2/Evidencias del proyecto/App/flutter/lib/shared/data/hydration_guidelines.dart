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
        'Apunta a 2 litros de agua al dia siguiendo las recomendaciones del Ministerio de Salud de Chile.',
    icon: 'H2O',
  ),
  HydrationTip(
    title: 'Recuerda fraccionar',
    detail:
        'Distribuye 8 vasos durante la jornada: 2 en la manana, 3 al mediodia y 3 en la tarde.',
    icon: '8x',
  ),
  HydrationTip(
    title: 'Infusiones e hidratacion',
    detail:
        'Alterna con infusiones sin azucar o aguas saborizadas con frutas y hierbas locales.',
    icon: 'Tea',
  ),
  HydrationTip(
    title: 'Alertas de deshidratacion',
    detail:
        'Labios secos, cansancio o dolor de cabeza pueden indicar que necesitas beber agua.',
    icon: '!',
  ),
];
