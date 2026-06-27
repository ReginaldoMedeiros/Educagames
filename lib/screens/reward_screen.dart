import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/rewards.dart';
import '../data/stickers.dart';
import '../theme/app_colors.dart';
import '../widgets/corujao.dart';

/// Tela de recompensa pós-jogo. Mostra estrelas, moedas, adesivo (se houver)
/// e novas conquistas, com mensagem positiva do Mestre Corujão.
class RewardScreen extends StatelessWidget {
  const RewardScreen({
    super.key,
    required this.result,
    required this.onPlayAgain,
  });

  final ActivityResult result;

  /// Reabre o mesmo jogo (botão "Jogar Novamente").
  final WidgetBuilder onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final StickerDef? sticker =
        result.stickerId == null ? null : stickerById(result.stickerId!);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFFF1C9), AppColors.kidsCream],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CorujaoMessage(
                    message: result.perfect
                        ? 'Incrível! Sem erros! Você encontrou novas estrelas!'
                        : 'Parabéns! Você encontrou novas estrelas para a Biblioteca!',
                    size: 90,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _RewardBadge(
                        icon: Icons.star_rounded,
                        color: AppColors.rewardGold,
                        label: '+${result.stars}',
                        caption: 'Estrelas',
                      ),
                      const SizedBox(width: 24),
                      _RewardBadge(
                        icon: Icons.monetization_on_rounded,
                        color: AppColors.kidsOrange,
                        label: '+${result.coins}',
                        caption: 'Moedas',
                      ),
                      if (sticker != null) ...<Widget>[
                        const SizedBox(width: 24),
                        _RewardBadge(
                          icon: sticker.icon,
                          color: AppColors.kidsGreen,
                          label: '',
                          caption: 'Adesivo: ${sticker.name}',
                        ),
                      ],
                    ],
                  ),
                  if (result.newAchievements.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    _AchievementsUnlocked(ids: result.newAchievements),
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(builder: onPlayAgain),
                        ),
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Jogar Novamente'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsBlue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.grid_view_rounded),
                        label: const Text('Escolher Outra Atividade'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            Navigator.of(context).popUntil((Route<dynamic> r) {
                          return r.settings.name == 'world' || r.isFirst;
                        }),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Voltar ao Mundo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.icon,
    required this.color,
    required this.label,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Icon(icon, size: 48, color: color),
        ),
        const SizedBox(height: 8),
        if (label.isNotEmpty)
          Text(label,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        Text(caption,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}

class _AchievementsUnlocked extends StatelessWidget {
  const _AchievementsUnlocked({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          const Text('Nova conquista!',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          ...ids.map((String id) {
            final Achievement? a = achievementById(id);
            if (a == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(a.icon, color: AppColors.kidsOrange),
                  const SizedBox(width: 8),
                  Text(a.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
