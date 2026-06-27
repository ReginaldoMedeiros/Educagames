import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/world.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'games/coloring_game_screen.dart';
import 'games/letters_numbers_screen.dart';
import 'games/memory_game_screen.dart';
import 'games/puzzle_game_screen.dart';
import 'time_up_screen.dart';

/// Tela interna de um mundo: cenário temático + os minijogos do MVP.
class WorldScreen extends StatelessWidget {
  const WorldScreen({super.key, required this.world});

  final World world;

  void _launch(BuildContext context, GameId game) {
    final AppState app = context.read<AppState>();
    // Revalida tempo a cada tentativa de iniciar um jogo.
    if (!app.canPlayGames) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TimeUpScreen()),
      );
      return;
    }
    final Widget screen;
    switch (game) {
      case GameId.coloring:
        screen = ColoringGameScreen(world: world);
        break;
      case GameId.puzzle:
        screen = PuzzleGameScreen(world: world);
        break;
      case GameId.memory:
        screen = MemoryGameScreen(world: world);
        break;
      case GameId.letters:
        screen = LettersNumbersScreen(world: world);
        break;
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        color: world.color,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const BackCircleButton(),
                    const SizedBox(width: 16),
                    Text(world.name,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(world.icon,
                      size: 140, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (final GameId g in GameId.values)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: BigIconButton(
                            icon: g.icon,
                            label: g.label,
                            color: world.color,
                            onTap: () => _launch(context, g),
                            size: 130,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
