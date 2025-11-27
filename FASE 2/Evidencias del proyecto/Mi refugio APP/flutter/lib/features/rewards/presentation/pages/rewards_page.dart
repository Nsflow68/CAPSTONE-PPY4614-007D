import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recompensas')),
      body: const Center(
        child: Text(
          'Aquí aparecerán tus logros y retos emocionales.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
