import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mi_refugio_app/features/chatbot/application/chatbot_provider.dart';
import 'package:mi_refugio_app/features/chatbot/application/chatbot_state.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_gradients.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});

  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  ProviderSubscription<ChatSessionState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<ChatSessionState>(
      chatSessionProvider,
      (previous, next) {
        if (previous == null ||
            previous.messages.length != next.messages.length ||
            previous.isLoading != next.isLoading) {
          Future.microtask(_scrollToBottom);
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _inputController.text;
    ref.read(chatSessionProvider.notifier).sendMessage(text);
    if (preset == null) {
      _inputController.clear();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatSessionProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refu • Acompañamiento'),
        actions: [
          IconButton(
            tooltip: 'Reiniciar sesión',
            onPressed: ref.read(chatSessionProvider.notifier).resetSession,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.softBackground),
        child: Column(
          children: [
            _ChatHero(state: state),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ErrorBanner(message: state.errorMessage!),
              ),
            if (state.quickPrompts.isNotEmpty)
              _QuickPromptList(
                prompts: state.quickPrompts,
                onSelected: _send,
              ),
            if (state.practice != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PracticeCard(text: state.practice!),
              ),
            Expanded(
              child: _MessagesList(
                controller: _scrollController,
                state: state,
              ),
            ),
            _ComposerBar(
              controller: _inputController,
              onSend: _send,
              isLoading: state.isLoading,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ChatHero extends StatelessWidget {
  const _ChatHero({required this.state});

  final ChatSessionState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calmPercent = (state.calmScore * 100).clamp(0, 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5F5CFE), Color(0xFF8DE0D1)],
          begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refu está contigo',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Respira, escribe o conversa; la sesión se adapta a lo que necesitas.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  title: 'Índice de calma',
                  value: '$calmPercent%',
                  icon: Icons.favorite_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatChip(
                    title: 'Foco sugerido',
                    value: state.focus,
                    icon: Icons.self_improvement_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickPromptList extends StatelessWidget {
  const _QuickPromptList({
    required this.prompts,
    required this.onSelected,
  });

  final List<String> prompts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(prompts[index]),
            onPressed: () => onSelected(prompts[index]),
            backgroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.self_improvement_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Práctica recomendada',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.controller,
    required this.state,
  });

  final ScrollController controller;
  final ChatSessionState state;

  @override
  Widget build(BuildContext context) {
    final messages = state.messages;
    final totalItems = state.isLoading ? messages.length + 1 : messages.length;
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return const _TypingBubble();
        }
        final message = messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: _MessageBubble(message: message),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final colors = isUser
        ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)]
        : [Colors.white, Colors.white];
    final textColor = isUser ? Colors.white : AppColors.textPrimary;
    final timeLabel = DateFormat('HH:mm').format(message.timestamp);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 24),
          ),
          boxShadow: isUser ? AppShadows.soft : null,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timeLabel,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Dot(),
            SizedBox(width: 4),
            _Dot(delay: 120),
            SizedBox(width: 4),
            _Dot(delay: 240),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});

  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.2, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            widget.delay / 300,
            1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: const CircleAvatar(
        radius: 4,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Escribe cómo te sientes...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(null),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: isLoading ? null : () => onSend(null),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: const CircleBorder(),
            ),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
