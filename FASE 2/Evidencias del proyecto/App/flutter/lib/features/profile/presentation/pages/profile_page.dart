import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../rewards/application/reward_provider.dart';
import '../../../rewards/application/reward_state.dart';

const _profileNameKey = StorageKeys.profileName;
const _profileEmailKey = StorageKeys.profileEmail;
const _profilePhoneKey = StorageKeys.profilePhone;
const _profileAvatarKey = StorageKeys.profileAvatar;
const _profileNotificationsKey = StorageKeys.profileNotifications;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedAvatar = 'assets/images/mascot/pose1.png';
  bool _notifications = true;
  bool _loading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final authState = ref.read(authProvider);

      authState.whenOrNull(
        authenticated: (user) {
          _nameController.text = user.name;
          _emailController.text = user.email;
        },
      );

      final storedName = await _storage.read(key: _profileNameKey);
      final storedEmail = await _storage.read(key: _profileEmailKey);
      final storedPhone = await _storage.read(key: _profilePhoneKey);
      final storedAvatar = await _storage.read(key: _profileAvatarKey);
      final storedNotifications =
          await _storage.read(key: _profileNotificationsKey);

      if (!mounted) return;
      setState(() {
        if ((storedName ?? '').isNotEmpty) {
          _nameController.text = storedName!;
        }
        if ((storedEmail ?? '').isNotEmpty) {
          _emailController.text = storedEmail!;
        }
        if ((storedPhone ?? '').isNotEmpty) {
          _phoneController.text = storedPhone!;
        }
        if ((storedAvatar ?? '').isNotEmpty) {
          _selectedAvatar = storedAvatar!;
        }
        if (storedNotifications != null) {
          final v = storedNotifications.toLowerCase().trim();
          _notifications = v == 'true' || v == '1' || v == 'yes';
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final avatars = [
          'assets/images/mascot/pose1.png',
          'assets/images/mascot/pose2.png',
          'assets/images/mascot/pose2_b.png',
          'assets/images/mascot/pose3.png',
          'assets/images/mascot/pose4.png',
        ];

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Elige tu avatar',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: avatars.map((avatar) {
                  final isSelected = avatar == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = avatar);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppGradients.primaryBubble
                            : null,
                        color: isSelected ? null : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(avatar, fit: BoxFit.contain),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);

    try {
      await _storage.write(key: _profileNameKey, value: _nameController.text);
      await _storage.write(key: _profileEmailKey, value: _emailController.text);
      await _storage.write(key: _profilePhoneKey, value: _phoneController.text);
      await _storage.write(key: _profileAvatarKey, value: _selectedAvatar);
      await _storage.write(
        key: _profileNotificationsKey,
        value: _notifications.toString(),
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado exitosamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final rewardState = ref.watch(rewardProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final createdDateText = authState.maybeWhen(
      authenticated: (user) => user.createdAt != null
          ? _formatDate(user.createdAt!)
          : 'Fecha desconocida',
      orElse: () => '',
    );

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.softBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          centerTitle: true,
          leading: const SizedBox.shrink(),
          actions: [
            if (_isEditing)
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text('Cancelar'),
              )
            else
              IconButton(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_rounded),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.primaryBubble,
                        boxShadow: AppShadows.elevated,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          _selectedAvatar,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.soft,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información personal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ProfileField(
                    label: 'Nombre',
                    controller: _nameController,
                    icon: Icons.person_rounded,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _ProfileField(
                    label: 'Teléfono',
                    controller: _phoneController,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isEditing) ...[
              FilledButton.icon(
                onPressed: _loading ? null : _saveProfile,
                icon: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 20),
            ],

            if (authState.maybeWhen(
              authenticated: (_) => true,
              orElse: () => false,
            )) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Cuenta creada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdDateText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            _RewardsSnapshot(state: rewardState),
            if (rewardState is! RewardInitial) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: rewardState is RewardLoading
                          ? null
                          : _refreshRewards,
                      icon: const Icon(Icons.sync_rounded),
                      label: const Text('Sincronizar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: rewardState is RewardLoading
                          ? null
                          : _resetRewards,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Restablecer'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Future<void> _refreshRewards() async {
    final notifier = ref.read(rewardProvider.notifier);
    await notifier.loadRewards();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actualizamos tus recompensas.')),
    );
  }

  Future<void> _resetRewards() async {
    final notifier = ref.read(rewardProvider.notifier);
    await notifier.resetRewards();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reestablecimos tus recompensas.')),
    );
  }
}

class _RewardsSnapshot extends StatelessWidget {
  const _RewardsSnapshot({required this.state});

  final RewardState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (message) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger),
            const SizedBox(width: 12),
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
      ),
      loaded: (summary) {
        if (summary.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final unlocked = summary.items.where((r) => r.active).length;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis insignias',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlocked / ${summary.items.length} desbloqueadas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Chip(
                    avatar: const Icon(Icons.token_rounded, size: 18),
                    label: Text('${summary.balance} pts'),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: summary.items
                    .map((reward) => _BadgeChip(reward: reward))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.reward});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = reward.active;
    final color =
        unlocked ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.5);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: unlocked ? 1 : 0.5,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: unlocked
              ? const LinearGradient(
                  colors: [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: unlocked ? null : Colors.white,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              unlocked ? Icons.emoji_events_rounded : Icons.star_border_rounded,
              color: unlocked ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              reward.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: unlocked ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${reward.points} pts',
              style: theme.textTheme.labelMedium?.copyWith(
                color: unlocked ? Colors.white.withValues(alpha: 0.9) : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: enabled
            ? Colors.transparent
            : AppColors.textSecondary.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
