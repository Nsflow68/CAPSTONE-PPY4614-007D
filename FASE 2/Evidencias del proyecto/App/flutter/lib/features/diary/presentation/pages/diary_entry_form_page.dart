import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/diary_provider.dart';
import '../../data/models/diary_entry_model.dart';

class DiaryEntryFormPage extends ConsumerStatefulWidget {
  const DiaryEntryFormPage({super.key});

  @override
  ConsumerState<DiaryEntryFormPage> createState() => _DiaryEntryFormPageState();
}

class _DiaryEntryFormPageState extends ConsumerState<DiaryEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _customEmotionController = TextEditingController();
  final _customTagController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'Calma';
  double _score = 6;
  bool _isSaving = false;

  final List<String> _selectedEmotions = [];
  final List<String> _selectedTags = [];

  final List<String> _moodOptions = const [
    'Calma',
    'Agradecido',
    'Contento',
    'Ansioso',
    'Triste',
    'En paz',
    'Motivado',
  ];

  final List<String> _emotionSuggestions = const [
    'Gratitud',
    'Esperanza',
    'Confianza',
    'Estrés',
    'Alegría',
    'Fatiga',
    'Entusiasmo',
    'Nostalgia',
  ];

  final List<String> _tagSuggestions = const [
    'rutina',
    'familia',
    'estudios',
    'trabajo',
    'salud',
    'autocuidado',
    'logros',
    'relaciones',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _customEmotionController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: 'Selecciona la fecha de tu registro',
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleEmotion(String emotion) {
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else {
        if (_selectedEmotions.length < 10) {
          _selectedEmotions.add(emotion);
        }
      }
    });
  }

  void _addCustomEmotion() {
    final value = _customEmotionController.text.trim();
    if (value.isEmpty) return;
    if (_selectedEmotions.contains(value)) {
      _customEmotionController.clear();
      return;
    }
    if (_selectedEmotions.length >= 10) {
      _showSnack('Puedes registrar hasta 10 emociones por entrada.');
      return;
    }
    setState(() {
      _selectedEmotions.add(value);
    });
    _customEmotionController.clear();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length < 10) {
          _selectedTags.add(tag);
        }
      }
    });
  }

  void _addCustomTag() {
    final value = _customTagController.text.trim().toLowerCase();
    if (value.isEmpty) return;
    if (_selectedTags.contains(value)) {
      _customTagController.clear();
      return;
    }
    if (_selectedTags.length >= 10) {
      _showSnack('Puedes registrar hasta 10 etiquetas por entrada.');
      return;
    }
    setState(() {
      _selectedTags.add(value);
    });
    _customTagController.clear();
  }

  void _removeTag(String tag) {
    setState(() => _selectedTags.remove(tag));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      FocusScope.of(context).unfocus();
      final request = DiaryEntryCreateRequest(
        date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mood: _selectedMood,
        emotions: List<String>.from(_selectedEmotions),
        tags: List<String>.from(_selectedTags),
        score: _score.round(),
        attachments: const [],
      );

      await ref.read(diaryProvider.notifier).createEntry(request);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada guardada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('No se pudo guardar la entrada: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancel() {
    if (_isSaving) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE d MMM yyyy', 'es').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva entrada'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparte lo que sentiste hoy. Usa este espacio para registrar tus emociones, pensamientos y logros personales.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Detalles principales'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    hintText: 'Ejemplo: Momento de calma en la tarde',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un titulo';
                    }
                    if (value.trim().length < 4) {
                      return 'Usa al menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Describe tu experiencia',
                    alignLabelWithHint: true,
                    hintText: 'Cuenta lo que ocurrio, como reaccionaste y que te ayudo a sentirte mejor.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cuéntanos un poco mas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Fecha y estado'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_rounded),
                        label: Text(dateLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intensidad emocional',
                            style: theme.textTheme.labelLarge,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _score,
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  label: _score.round().toString(),
                                  onChanged: (value) => setState(() => _score = value),
                                ),
                              ),
                              SizedBox(
                                width: 42,
                                child: Text(
                                  '${_score.round()}/10',
                                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Estado principal',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _moodOptions
                      .map(
                        (mood) => ChoiceChip(
                          label: Text(mood),
                          selected: _selectedMood == mood,
                          onSelected: (_) => setState(() => _selectedMood = mood),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),
                _SectionTitle(title: 'Emociones presentes'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _emotionSuggestions
                      .map(
                        (emotion) => FilterChip(
                          label: Text(emotion),
                          selected: _selectedEmotions.contains(emotion),
                          onSelected: (_) => _toggleEmotion(emotion),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customEmotionController,
                        decoration: const InputDecoration(
                          labelText: 'Añadir emocion personalizada',
                          hintText: 'Ejemplo: alivio, serenidad',
                        ),
                        onSubmitted: (_) => _addCustomEmotion(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _addCustomEmotion,
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_selectedEmotions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedEmotions
                        .map(
                          (emotion) => InputChip(
                            label: Text(emotion),
                            selected: true,
                            onDeleted: () => _toggleEmotion(emotion),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 28),
                _SectionTitle(title: 'Etiquetas y contexto'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _tagSuggestions
                      .map(
                        (tag) => FilterChip(
                          label: Text('#$tag'),
                          selected: _selectedTags.contains(tag),
                          onSelected: (_) => _toggleTag(tag),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customTagController,
                        decoration: const InputDecoration(
                          labelText: 'Añadir etiqueta',
                          hintText: 'Ejemplo: resiliencia',
                        ),
                        onSubmitted: (_) => _addCustomTag(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _addCustomTag,
                      child: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedTags
                        .map(
                          (tag) => InputChip(
                            label: Text('#$tag'),
                            onDeleted: () => _removeTag(tag),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Guardando...' : 'Guardar entrada'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _cancel,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
