import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/data/mindfulness_audio_resources.dart';
import '../../../../shared/models/mindfulness_session.dart';
import '../../../../shared/models/mindfulness_summary.dart';
import '../../application/mindfulness_providers.dart';
import '../../../../core/services/notification_service.dart';

class MindfulnessPage extends ConsumerWidget {
  const MindfulnessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(mindfulnessSessionsProvider);
    final summaryAsync = ref.watch(mindfulnessSummaryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mindfulness'),
        actions: [
          IconButton(
            tooltip: 'Programar práctica',
            onPressed: () => _showNotificationSettings(context),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor, // Ensure opaque background behind gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.softBackground,
          color: theme.scaffoldBackgroundColor, // Fallback color
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(mindfulnessSummaryProvider)
                ..invalidate(mindfulnessSessionsProvider);
              await Future.wait([
                ref.read(mindfulnessSummaryProvider.future),
                ref.read(mindfulnessSessionsProvider.future),
              ]);
            },
            child: summaryAsync.when(
              data: (summary) => sessionsAsync.when(
                data: (sessions) => _MindfulnessContent(
                  theme: theme,
                  sessions: sessions,
                  summary: summary,
                ),
                loading: () => const _MindfulnessLoading(),
                error: (error, __) => _MindfulnessError(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(mindfulnessSessionsProvider),
                ),
              ),
              loading: () => const _MindfulnessLoading(),
              error: (error, __) => _MindfulnessError(
                message: error.toString(),
                onRetry: () => ref.invalidate(mindfulnessSummaryProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MindfulnessContent extends StatelessWidget {
  const _MindfulnessContent({
    required this.theme,
    required this.sessions,
    required this.summary,
  });

  final ThemeData theme;
  final List<MindfulnessSession> sessions;
  final MindfulnessSummary summary;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        children: [
          const _MindfulnessHeader(),
          const SizedBox(height: 32),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aún no hay sesiones disponibles',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sincroniza nuevamente más tarde para descubrir nuevas prácticas recomendadas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _MindfulnessHeader(summary: summary),
        const SizedBox(height: 24),
        _MindfulnessAudioSection(
          onOpenResource: (url) => _launchExternal(context, url),
        ),
        const SizedBox(height: 24),
        for (final session in sessions)
          _SessionCard(
            session: session,
            onLaunchMedia: (url) => _launchExternal(context, url),
            onOpenResource: (url) => _launchExternal(context, url),
          ),
      ],
    );
  }
}

class _MindfulnessLoading extends StatelessWidget {
  const _MindfulnessLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: const [
        _MindfulnessHeader(),
        SizedBox(height: 24),
        _SkeletonCard(),
        SizedBox(height: 16),
        _SkeletonCard(),
        SizedBox(height: 16),
        _SkeletonCard(),
      ],
    );
  }
}

class _MindfulnessError extends StatelessWidget {
  const _MindfulnessError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        Icon(
          Icons.report_problem_rounded,
          size: 52,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 18),
        Text(
          'No pudimos cargar las sesiones',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(message, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class _MindfulnessHeader extends StatelessWidget {
  const _MindfulnessHeader({this.summary});

  final MindfulnessSummary? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes = summary?.totalMinutes ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final hasPractice = totalMinutes > 0;

    final durationLabel = hasPractice
        ? (hours > 0
              ? '$hours h ${minutes.toString().padLeft(2, '0')} min'
              : '$minutes min')
        : 'Sin minutos registrados';

    MapEntry<String, int>? topEntry;
    if (summary != null && summary!.byType.isNotEmpty) {
      topEntry = summary!.byType.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
    }

    final focusLabel = topEntry?.key ?? 'Explora una práctica';
    final focusSubtitle = topEntry != null
        ? '${topEntry.value} min'
        : 'Agrega tu primera sesión';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2E9FF), Color(0xFFE8F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  size: 36,
                  color: Color(0xFF7E6BC4),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Respira y recarga energías',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasPractice
                          ? 'Has acumulado $durationLabel de práctica consciente.'
                          : 'Comienza tu primera sesión guiada cuando quieras.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SummaryPill(
                icon: Icons.timer_rounded,
                label: 'Minutos totales',
                value: totalMinutes.toString(),
                subtitle: hasPractice ? durationLabel : 'Meta diaria: 10 min',
              ),
              _SummaryPill(
                icon: Icons.category_rounded,
                label: 'Tipos practicados',
                value: (summary?.byType.length ?? 0).toString(),
                subtitle: summary != null && summary!.byType.isNotEmpty
                    ? 'Varía tus prácticas'
                    : 'Explora nuevas técnicas',
              ),
              _SummaryPill(
                icon: Icons.self_improvement_outlined,
                label: 'Categoría líder',
                value: focusLabel,
                subtitle: focusSubtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MindfulnessAudioSection extends StatelessWidget {
  const _MindfulnessAudioSection({required this.onOpenResource});

  final Future<void> Function(String url) onOpenResource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audios guiados verificados',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final resource in mindfulnessAudioResources)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AudioResourceCard(
              resource: resource,
              onOpenResource: onOpenResource,
            ),
          ),
      ],
    );
  }
}

class _AudioResourceCard extends StatefulWidget {
  const _AudioResourceCard({required this.resource, required this.onOpenResource});

  final MindfulnessAudioResource resource;
  final Future<void> Function(String url) onOpenResource;

  @override
  State<_AudioResourceCard> createState() => _AudioResourceCardState();
}

class _AudioResourceCardState extends State<_AudioResourceCard> {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    await _player.play(AssetSource(widget.resource.assetPath));
    if (mounted) setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: _togglePlay,
            icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.resource.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.resource.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.resource.duration,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.resource.credits,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => widget.onOpenResource(widget.resource.sourceUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(widget.resource.sourceLabel),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle ?? label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 180, height: 18),
          SizedBox(height: 12),
          _SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 8),
          _SkeletonBox(width: double.infinity, height: 12),
          SizedBox(height: 12),
          _SkeletonBox(width: 120, height: 12),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    this.onLaunchMedia,
    this.onOpenResource,
  });

  final MindfulnessSession session;
  final Future<void> Function(String url)? onLaunchMedia;
  final Future<void> Function(String url)? onOpenResource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E9FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(session.duration),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(session.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.spa_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(session.focus, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(session.source, style: theme.textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: session.mediaUrl == null
                    ? null
                    : () => onLaunchMedia?.call(session.mediaUrl!),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar sesión'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: session.resourceUrl == null
                    ? null
                    : () => onOpenResource?.call(session.resourceUrl!),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Visitar recurso'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _launchExternal(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Enlace no válido')));
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
  }
}

Future<void> _showNotificationSettings(BuildContext context) async {
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 20, minute: 0),
    helpText: 'Programar práctica diaria',
  );

  if (time != null && context.mounted) {
    await NotificationService().scheduleDailyNotification(
      id: 3, // Unique ID for mindfulness
      title: 'Momento de calma',
      body: 'Tómate unos minutos para respirar y reconectar contigo.',
      time: time,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recordatorio programado para las ${time.format(context)}')),
    );
  }
}
