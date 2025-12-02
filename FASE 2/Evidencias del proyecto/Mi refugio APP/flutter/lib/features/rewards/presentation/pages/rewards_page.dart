import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mi_refugio_app/features/rewards/application/reward_provider.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class RewardsPage extends ConsumerWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4), // Pastel Yellow Background
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(rewardProvider.notifier).loadRewards();
        },
        child: rewardsAsync.when(
          data: (rewards) => _RewardsContent(
            points: rewards.points,
            streak: rewards.currentStreak,
            unlockedMascots: rewards.unlockedMascots,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(rewardProvider.notifier).loadRewards(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardsContent extends StatelessWidget {
  final int points;
  final int streak;
  final List<String> unlockedMascots;

  const _RewardsContent({
    required this.points,
    required this.streak,
    required this.unlockedMascots,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Points Card
        _StatsCard(
          title: 'Puntos Totales',
          value: points.toString(),
          icon: Icons.stars,
          color: const Color(0xFFFFD54F),
        ),
        const SizedBox(height: 16),

        // Streak Card
        _StatsCard(
          title: 'Racha Actual',
          value: '$streak días',
          icon: Icons.local_fire_department,
          color: const Color(0xFFFF8A65),
        ),
        const SizedBox(height: 24),

        // Mascots Section
        const Text(
          'Mascotas Desbloqueadas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 16),
        _MascotsGrid(unlockedMascots: unlockedMascots),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
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

class _MascotsGrid extends StatelessWidget {
  final List<String> unlockedMascots;

  const _MascotsGrid({required this.unlockedMascots});

  @override
  Widget build(BuildContext context) {
    // All available mascots (poses 1-4)
    final allMascots = ['pose_1', 'pose_2', 'pose_3', 'pose_4'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: allMascots.length,
      itemBuilder: (context, index) {
        final mascotId = allMascots[index];
        final isUnlocked = unlockedMascots.contains(mascotId);

        return _MascotCard(
          mascotId: mascotId,
          isUnlocked: isUnlocked,
        );
      },
    );
  }
}

class _MascotCard extends StatelessWidget {
  final String mascotId;
  final bool isUnlocked;

  const _MascotCard({
    required this.mascotId,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: isUnlocked ? 1.0 : 0.3,
              child: SvgPicture.asset(
                'assets/images/rewards/$mascotId.svg',
                height: 100,
                width: 100,
              ),
            ),
          ),
          if (!isUnlocked)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              _getMascotName(mascotId),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? const Color(0xFF2D3436) : const Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMascotName(String id) {
    switch (id) {
      case 'pose_1':
        return 'Principiante';
      case 'pose_2':
        return 'Motivado';
      case 'pose_3':
        return 'Comprometido';
      case 'pose_4':
        return 'Maestro';
      default:
        return id;
    }
  }
}
