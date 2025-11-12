import 'package:flutter/material.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot Refu')),
      body: const Center(
        child: Text(
          'El chatbot se conectará al backend Nest/Ollama próximamente.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
