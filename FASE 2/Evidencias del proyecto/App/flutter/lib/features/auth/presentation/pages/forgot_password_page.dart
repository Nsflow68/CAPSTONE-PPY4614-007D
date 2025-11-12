import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: const Center(
        child: Text(
          'Aquí podrás recuperar tu contraseña.\nContenido pendiente.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
