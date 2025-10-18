import 'package:flutter/material.dart';

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

const onboardingData = [
  OnboardingItem(
    icon: Icons.self_improvement_rounded,
    title: 'Encuentra tu paz interior',
    description:
        'Un espacio seguro para explorar y expresar tus emociones con libertad',
  ),
  OnboardingItem(
    icon: Icons.psychology_rounded,
    title: 'Comprende tus emociones',
    description:
        'Aprende a identificar y gestionar tus estados emocionales de manera saludable',
  ),
  OnboardingItem(
    icon: Icons.volunteer_activism_rounded,
    title: 'Crece y evoluciona',
    description:
        'Desarrolla herramientas y hábitos para tu bienestar emocional',
  ),
];
