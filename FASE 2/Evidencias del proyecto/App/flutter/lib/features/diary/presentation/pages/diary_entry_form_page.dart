import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/models/diary_entry.dart';

class DiaryEntryFormPage extends StatefulWidget {
  const DiaryEntryFormPage({super.key});

  @override
  State<DiaryEntryFormPage> createState() => _DiaryEntryFormPageState();
}

class _DiaryEntryFormPageState extends State<DiaryEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _mood = 'Calma';

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      mood: _mood,
      body: _body.text.trim(),
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar emoción')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registra lo que estás sintiendo para seguir tu progreso emocional.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: '¿Qué título describe mejor tu entrada?',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Ingresa un título'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _mood,
                  items: const [
                    DropdownMenuItem(value: 'Calma', child: Text('Calma')),
                    DropdownMenuItem(value: 'Alegre', child: Text('Alegre')),
                    DropdownMenuItem(value: 'Triste', child: Text('Triste')),
                    DropdownMenuItem(
                      value: 'Ansioso/a',
                      child: Text('Ansioso/a'),
                    ),
                    DropdownMenuItem(value: 'En paz', child: Text('En paz')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Emoción predominante',
                  ),
                  onChanged: (value) => setState(() => _mood = value ?? _mood),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: _body,
                    maxLines: null,
                    expands: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Describe tu experiencia',
                      alignLabelWithHint: true,
                      hintText:
                          'Escribe con libertad lo que ocurrió, cómo reaccionaste y qué te ayudó.',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Cuéntanos un poco más'
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
