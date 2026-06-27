import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/achievements.dart';
import '../data/stickers.dart';
import '../models/child_profile.dart';
import '../models/world.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_view.dart';
import '../widgets/common_widgets.dart';

/// Perfil Infantil: mostra progresso (estrelas, moedas, nível, mundos,
/// adesivos, conquistas) — atende ao critério de aceite de exibir progresso.
class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        color: AppColors.kidsBlue,
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (BuildContext context, AppState app, _) {
              final ChildProfile? p = app.activeProfile;
              if (p == null) return const SizedBox.shrink();
              final int unlockedWorlds = kWorlds
                  .where((World w) => app.isWorldUnlocked(w))
                  .length;
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: const <Widget>[
                        BackCircleButton(),
                        SizedBox(width: 12),
                        Text('Meu Perfil',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              AvatarView(profile: p, size: 150),
                              const SizedBox(height: 12),
                              Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800)),
                              if (p.age != null)
                                Text('${p.age} anos',
                                    style: const TextStyle(
                                        color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    _StatCard(
                                        icon: Icons.star_rounded,
                                        color: AppColors.rewardGold,
                                        value: '${p.stars}',
                                        label: 'Estrelas'),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                        icon: Icons.monetization_on_rounded,
                                        color: AppColors.kidsOrange,
                                        value: '${p.coins}',
                                        label: 'Moedas'),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                        icon: Icons.military_tech_rounded,
                                        color: AppColors.kidsPurple,
                                        value: 'Nível ${p.level}',
                                        label: 'Nível'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Progresso para o próximo nível',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: p.levelProgress,
                                    minHeight: 14,
                                    backgroundColor: Colors.white,
                                    color: AppColors.kidsGreen,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: <Widget>[
                                    _StatCard(
                                        icon: Icons.public_rounded,
                                        color: AppColors.worldOcean,
                                        value:
                                            '$unlockedWorlds / ${kWorlds.length}',
                                        label: 'Mundos'),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                        icon: Icons
                                            .collections_bookmark_rounded,
                                        color: AppColors.kidsGreen,
                                        value:
                                            '${p.stickers.length} / ${kStickers.length}',
                                        label: 'Adesivos'),
                                    const SizedBox(width: 12),
                                    _StatCard(
                                        icon: Icons.emoji_events_rounded,
                                        color: AppColors.kidsOrange,
                                        value:
                                            '${p.achievements.length} / ${kAchievements.length}',
                                        label: 'Conquistas'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
