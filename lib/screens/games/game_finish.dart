import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/game_content.dart';
import '../../data/rewards.dart';
import '../../models/world.dart';
import '../../state/app_state.dart';
import '../reward_screen.dart';

/// Conclui uma atividade: concede recompensas (estrelas, moedas, adesivo
/// temático e conquistas) e abre a tela de recompensa, substituindo o jogo.
Future<void> finishActivity(
  BuildContext context, {
  required World world,
  required GameId game,
  required bool perfect,
  required WidgetBuilder playAgain,
}) async {
  final AppState app = context.read<AppState>();
  final Set<String> collected =
      app.activeProfile?.stickers ?? <String>{};

  // Jogos temáticos (colorir, memória, quebra-cabeça) podem conceder adesivo.
  // Letras e Números não concede adesivo de mundo.
  final String? stickerId = game == GameId.letters
      ? null
      : nextStickerForWorld(world.id, collected);

  final ActivityResult result = await app.completeActivity(
    world: world.id,
    game: game,
    perfect: perfect,
    stickerId: stickerId,
  );

  if (!context.mounted) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => RewardScreen(result: result, onPlayAgain: playAgain),
    ),
  );
}
