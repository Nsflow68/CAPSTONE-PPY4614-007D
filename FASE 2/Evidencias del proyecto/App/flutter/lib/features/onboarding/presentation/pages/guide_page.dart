import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guía rápida')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Esta guía resume las funciones principales de Mi Refugio. '
            'La implementación detallada se encuentra en la documentación.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
