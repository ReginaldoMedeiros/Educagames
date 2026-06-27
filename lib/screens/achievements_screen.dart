import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/achievements.dart';
import '../models/child_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Conquistas: cards grandes com ícone, nome e estado (conquistada ou não).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        color: AppColors.kidsOrange,
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (BuildContext context, AppState app, _) {
              final ChildProfile? p = app.activeProfile;
              if (p == null) return const SizedBox.shrink();
              final int done = p.achievements.length;
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        const BackCircleButton(),
                        const SizedBox(width: 12),
                        const Text('Conquistas',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text('$done / ${kAchievements.length}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.6,
                      ),
                      itemCount: kAchievements.length,
                      itemBuilder: (BuildContext context, int i) {
                        final Achievement a = kAchievements[i];
                        final bool unlocked = p.achievements.contains(a.id);
                        return _AchievementCard(
                            achievement: a, unlocked: unlocked);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.unlocked});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: unlocked ? 1 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? AppColors.rewardGold : Colors.black12,
          width: unlocked ? 3 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.rewardGold.withValues(alpha: 0.2)
                  : Colors.black12,
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? achievement.icon : Icons.lock_rounded,
              color: unlocked ? AppColors.kidsOrange : Colors.black38,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(achievement.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(achievement.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
