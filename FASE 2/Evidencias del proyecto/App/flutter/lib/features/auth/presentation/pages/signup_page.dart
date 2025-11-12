import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: const Center(
        child: Text(
          'Pantalla de registro en construcción',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
