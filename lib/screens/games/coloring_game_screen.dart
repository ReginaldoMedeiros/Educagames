import 'package:flutter/material.dart';

import '../../data/game_content.dart';
import '../../models/world.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'game_finish.dart';

/// Jogo de Colorir funcional. A área de desenho ocupa ~70% da tela, com uma
/// grade de células que a criança pinta com a cor selecionada. Inclui desfazer,
/// limpar e concluir, conforme o documento mestre.
class ColoringGameScreen extends StatefulWidget {
  const ColoringGameScreen({super.key, required this.world});

  final World world;

  @override
  State<ColoringGameScreen> createState() => _ColoringGameScreenState();
}

class _ColoringGameScreenState extends State<ColoringGameScreen> {
  static const int cols = 14;
  static const int rows = 8;

  late Subject _subject;
  // Máscara do desenho: true = célula faz parte da figura (pintável).
  late List<bool> _mask;
  // Cor atual de cada célula (null = ainda não pintada).
  late List<Color?> _cells;
  final List<int> _history = <int>[];
  Color _selected = AppColors.paintPalette.first;

  @override
  void initState() {
    super.initState();
    final List<Subject> subjects = subjectsForWorld(widget.world.id);
    _subject = subjects.isNotEmpty
        ? subjects[DateTime.now().second % subjects.length]
        : const Subject(
            name: 'Desenho', icon: Icons.image_rounded, color: Colors.grey);
    _buildMask();
  }

  /// Cria uma silhueta simples (losango/centro preenchido) como contorno.
  void _buildMask() {
    _mask = List<bool>.filled(cols * rows, false);
    _cells = List<Color?>.filled(cols * rows, null);
    final double cx = (cols - 1) / 2;
    final double cy = (rows - 1) / 2;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final double dx = (x - cx).abs() / (cols / 2);
        final double dy = (y - cy).abs() / (rows / 2);
        // Forma arredondada central preenchível.
        if (dx + dy <= 1.05) {
          _mask[y * cols + x] = true;
        }
      }
    }
    _history.clear();
  }

  void _paint(int index) {
    if (!_mask[index]) return;
    if (_cells[index] == _selected) return;
    setState(() {
      _history.add(index);
      _cells[index] = _selected;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final int last = _history.removeLast();
      // Reverte para o estado anterior daquela célula (simplificação: limpa).
      _cells[last] = null;
    });
  }

  void _clear() {
    setState(() {
      _cells = List<Color?>.filled(cols * rows, null);
      _history.clear();
    });
  }

  int get _paintableCount => _mask.where((bool m) => m).length;
  int get _paintedCount =>
      _cells.where((Color? c) => c != null).length;

  void _finish() {
    finishActivity(
      context,
      world: widget.world,
      game: GameId.coloring,
      perfect: false,
      playAgain: (_) => ColoringGameScreen(world: widget.world),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canFinish = _paintedCount > 0;
    return Scaffold(
      body: GradientBackground(
        color: widget.world.color,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    const BackCircleButton(),
                    const SizedBox(width: 12),
                    Text('Colorir: ${_subject.name}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('$_paintedCount / $_paintableCount',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    // Botões laterais (desfazer / limpar / concluir).
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _SideButton(
                              icon: Icons.undo_rounded,
                              label: 'Desfazer',
                              onTap: _undo),
                          const SizedBox(height: 12),
                          _SideButton(
                              icon: Icons.delete_outline_rounded,
                              label: 'Limpar',
                              onTap: _clear),
                          const SizedBox(height: 12),
                          _SideButton(
                            icon: Icons.check_circle_rounded,
                            label: 'Concluir',
                            color: AppColors.kidsGreen,
                            onTap: canFinish ? _finish : null,
                          ),
                        ],
                      ),
                    ),
                    // Área de desenho.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return GridView.builder(
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                ),
                                itemCount: cols * rows,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  final bool inFigure = _mask[index];
                                  return GestureDetector(
                                    onTap: () => _paint(index),
                                    child: Container(
                                      margin: const EdgeInsets.all(0.5),
                                      decoration: BoxDecoration(
                                        color: inFigure
                                            ? (_cells[index] ?? Colors.white)
                                            : Colors.transparent,
                                        border: inFigure
                                            ? Border.all(
                                                color: Colors.black12,
                                                width: 0.5)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Paleta de cores.
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (final Color c in AppColors.paintPalette)
                      GestureDetector(
                        onTap: () => setState(() => _selected = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selected == c
                                  ? Colors.black
                                  : Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          foregroundColor: color == null ? Colors.black87 : Colors.white,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
