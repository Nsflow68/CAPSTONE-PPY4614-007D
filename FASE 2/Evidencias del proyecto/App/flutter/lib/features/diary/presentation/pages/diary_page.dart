import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/models/diary_entry.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final List<DiaryEntry> _entries = List.of(_seedEntries);
  String _selectedMood = 'Todos';

  List<String> get _moodFilters => [
    'Todos',
    ...{for (final entry in _entries) entry.mood},
  ];

  List<DiaryEntry> get _visibleEntries => _selectedMood == 'Todos'
      ? _entries
      : _entries
            .where(
              (entry) =>
                  entry.mood.toLowerCase() == _selectedMood.toLowerCase(),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    final visibleEntries = _visibleEntries;
    final moodCount = <String, int>{};
    for (final entry in _entries) {
      moodCount.update(entry.mood, (value) => value + 1, ifAbsent: () => 1);
    }
    final positive = (moodCount['Alegre'] ?? 0) + (moodCount['Feliz'] ?? 0);
    final calm = moodCount['Calma'] ?? 0;
    final supportNeeded =
        (moodCount['Ansioso/a'] ?? 0) + (moodCount['Triste'] ?? 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Diario emocional')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar'),
      ),
      body: SafeArea(
        child: _entries.isEmpty
            ? _DiaryEmptyState(onCreate: _addEntry)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _SummaryCard(
                    positive: positive,
                    calm: calm,
                    supportNeeded: supportNeeded,
                    total: _entries.length,
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _moodFilters
                        .map(
                          (mood) => ChoiceChip(
                            label: Text(mood),
                            selected: _selectedMood == mood,
                            onSelected: (_) =>
                                setState(() => _selectedMood = mood),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  for (final entry in visibleEntries) ...[
                    _DiaryCard(
                      entry: entry,
                      formattedDate: _formatDate(entry.createdAt),
                      color: _moodColor(entry.mood),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
      ),
    );
  }

  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'alegre':
      case 'feliz':
        return AppColors.moodJoy;
      case 'calma':
      case 'equilibrado':
        return AppColors.moodCalm;
      case 'triste':
        return AppColors.moodSad;
      case 'ansioso/a':
      case 'ansioso':
        return AppColors.moodAngry;
      default:
        return AppColors.moodNeutral;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final time = DateFormat.Hm('es').format(date);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateOnly == today) {
      return 'Hoy · $time';
    }
    if (dateOnly == yesterday) {
      return 'Ayer · $time';
    }
    if (date.year == now.year) {
      final formatter = DateFormat('d MMM', 'es');
      return '${formatter.format(date)} · $time';
    }
    final formatter = DateFormat('d MMM y', 'es');
    return '${formatter.format(date)} · $time';
  }

  Future<void> _addEntry() async {
    final entry = await context.push<DiaryEntry>('/diary/entry/new');
    if (entry != null) {
      setState(() => _entries.insert(0, entry));
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.positive,
    required this.calm,
    required this.supportNeeded,
    required this.total,
  });

  final int positive;
  final int calm;
  final int supportNeeded;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14352F44),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen de la semana', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryPill(
                label: 'Emociones positivas',
                value: positive,
                color: AppColors.moodJoy,
              ),
              const SizedBox(width: 8),
              _SummaryPill(
                label: 'Momentos calmados',
                value: calm,
                color: AppColors.moodCalm,
              ),
              const SizedBox(width: 8),
              _SummaryPill(
                label: 'Necesitan apoyo',
                value: supportNeeded,
                color: AppColors.moodAngry,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Has registrado $total emociones. Aumenta tus reflexiones para seguir identificando patrones.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  const _DiaryCard({
    required this.entry,
    required this.formattedDate,
    required this.color,
  });

  final DiaryEntry entry;
  final String formattedDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14352F44),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            entry.mood.isNotEmpty
                ? entry.mood.substring(0, 1).toUpperCase()
                : '?',
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ),
        title: Text(entry.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(entry.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Text(
              '$formattedDate · ${entry.mood}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 68,
              color: AppColors.moodNeutral,
            ),
            const SizedBox(height: 18),
            Text(
              'Registra tu primera emoción',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Anotar cómo te sientes te ayuda a identificar patrones y encontrar herramientas de apoyo.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar emoción'),
            ),
          ],
        ),
      ),
    );
  }
}

final _seedEntries = [
  DiaryEntry(
    id: '1',
    title: 'Agradecimiento matinal',
    mood: 'Alegre',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    body:
        'Hoy me sentí agradecido por el apoyo de mis amigos. Practiqué respiraciones y comencé el día con calma.',
  ),
  DiaryEntry(
    id: '2',
    title: 'Momento desafiante',
    mood: 'Ansioso/a',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    body:
        'Tuve una reunión compleja. Anoté mis sensaciones y me ayudó a ver que fue temporal.',
  ),
];
