import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/world_scenes.dart';
import '../models/world.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'games/coloring_game_screen.dart';
import 'games/letters_numbers_screen.dart';
import 'games/memory_game_screen.dart';
import 'games/puzzle_game_screen.dart';
import 'time_up_screen.dart';

/// Tela interna de um mundo. Quando há arte de cenário, usa-a como fundo cheio
/// e posiciona os 3 botões de atividade sobre os medalhões do cenário; senão,
/// cai num layout com gradiente.
class WorldScreen extends StatelessWidget {
  const WorldScreen({super.key, required this.world});

  final World world;

  void _launch(BuildContext context, GameId game) {
    final AppState app = context.read<AppState>();
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
    final WorldScene scene = sceneFor(world.id);
    if (scene.asset == null) {
      return _GradientLayout(world: world, onLaunch: _launch);
    }
    return _SceneLayout(world: world, scene: scene, onLaunch: _launch);
  }
}

/// Layout com cenário de fundo + botões sobre os medalhões.
class _SceneLayout extends StatelessWidget {
  const _SceneLayout({
    required this.world,
    required this.scene,
    required this.onLaunch,
  });

  final World world;
  final WorldScene scene;
  final void Function(BuildContext, GameId) onLaunch;

  // Os 3 medalhões correspondem a estas atividades (na ordem dos slots).
  static const List<GameId> _slotGames = <GameId>[
    GameId.coloring,
    GameId.puzzle,
    GameId.memory,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = c.maxWidth;
          final double h = c.maxHeight;
          final double d = w * 0.16; // diâmetro do botão
          return Stack(
            children: <Widget>[
              // Cenário (ancorado embaixo p/ manter os medalhões visíveis).
              Positioned.fill(
                child: Image.asset(
                  scene.asset!,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration: BoxDecoration(color: world.color),
                  ),
                ),
              ),
              // Botões de atividade sobre os medalhões.
              for (int i = 0; i < _slotGames.length; i++)
                Positioned(
                  left: scene.slots[i].dx * w - d / 2,
                  top: scene.slots[i].dy * h - d / 2,
                  width: d,
                  height: d,
                  child: _SceneButton(
                    game: _slotGames[i],
                    color: world.color,
                    onTap: () => onLaunch(context, _slotGames[i]),
                  ),
                ),
              // Barra superior: voltar + nome + Letras e Números.
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      const BackCircleButton(),
                      const SizedBox(width: 12),
                      _TitlePill(text: world.name),
                      const Spacer(),
                      _LettersButton(
                          onTap: () => onLaunch(context, GameId.letters)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Botão redondo de atividade (fica sobre o medalhão do cenário).
class _SceneButton extends StatelessWidget {
  const _SceneButton({
    required this.game,
    required this.color,
    required this.onTap,
  });

  final GameId game;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(game.icon, color: color, size: 30),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                game.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitlePill extends StatelessWidget {
  const _TitlePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    );
  }
}

class _LettersButton extends StatelessWidget {
  const _LettersButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      icon: const Icon(Icons.abc_rounded),
      label: const Text('Letras e Números'),
    );
  }
}

/// Layout antigo (gradiente) para mundos ainda sem cenário.
class _GradientLayout extends StatelessWidget {
  const _GradientLayout({required this.world, required this.onLaunch});

  final World world;
  final void Function(BuildContext, GameId) onLaunch;

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
                            onTap: () => onLaunch(context, g),
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
