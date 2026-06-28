import 'package:flutter/material.dart';

import '../../models/world.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'game_finish.dart';

/// Quantidade de páginas de colorir disponíveis (assets/games/coloring/).
const int kColoringPages = 25;

/// Jogo de Colorir funcional usando line-art real.
///
/// A criança pinta uma camada de células ao fundo; o contorno preto (PNG com
/// fundo transparente) fica por cima, então as cores aparecem "dentro" do
/// desenho. Inclui pintar arrastando, desfazer, limpar e concluir.
class ColoringGameScreen extends StatefulWidget {
  const ColoringGameScreen({super.key, required this.world});

  final World world;

  @override
  State<ColoringGameScreen> createState() => _ColoringGameScreenState();
}

class _ColoringGameScreenState extends State<ColoringGameScreen> {
  static const int grid = 24; // resolução da pintura (grid x grid)

  late final String _asset;
  late List<Color?> _cells;
  final List<int> _history = <int>[]; // índices pintados, em ordem
  final Map<int, Color?> _prev = <int, Color?>{}; // cor anterior p/ desfazer
  Color _selected = AppColors.paintPalette.first;

  @override
  void initState() {
    super.initState();
    final int n = 1 + DateTime.now().microsecondsSinceEpoch % kColoringPages;
    _asset = 'assets/games/coloring/coloring_${n.toString().padLeft(2, '0')}.png';
    _cells = List<Color?>.filled(grid * grid, null);
  }

  void _paintAt(Offset local, double side) {
    final double cell = side / grid;
    final int c = (local.dx / cell).floor();
    final int r = (local.dy / cell).floor();
    if (c < 0 || c >= grid || r < 0 || r >= grid) return;
    final int i = r * grid + c;
    if (_cells[i] == _selected) return;
    setState(() {
      _prev[i] = _cells[i];
      _history.add(i);
      _cells[i] = _selected;
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final int i = _history.removeLast();
      _cells[i] = _prev[i];
    });
  }

  void _clear() {
    setState(() {
      _cells = List<Color?>.filled(grid * grid, null);
      _history.clear();
      _prev.clear();
    });
  }

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
    final bool canFinish = _history.isNotEmpty;
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
                    const Text('Colorir',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    // Botões laterais.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _SideButton(
                              icon: Icons.undo_rounded,
                              label: 'Desfazer',
                              onTap: _history.isEmpty ? null : _undo),
                          const SizedBox(height: 12),
                          _SideButton(
                              icon: Icons.delete_outline_rounded,
                              label: 'Limpar',
                              onTap: _history.isEmpty ? null : _clear),
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
                    // Área de desenho (quadrada).
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 3)),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                final double side = constraints.maxWidth;
                                return GestureDetector(
                                  onTapDown: (TapDownDetails d) =>
                                      _paintAt(d.localPosition, side),
                                  onPanStart: (DragStartDetails d) =>
                                      _paintAt(d.localPosition, side),
                                  onPanUpdate: (DragUpdateDetails d) =>
                                      _paintAt(d.localPosition, side),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      // Camada de pintura.
                                      CustomPaint(
                                        painter: _PaintLayer(
                                            cells: _cells, grid: grid),
                                      ),
                                      // Contorno por cima.
                                      IgnorePointer(
                                        child: Image.asset(
                                          _asset,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
                              color:
                                  _selected == c ? Colors.black : Colors.white,
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

/// Desenha as células pintadas (camada de baixo).
class _PaintLayer extends CustomPainter {
  _PaintLayer({required this.cells, required this.grid});

  final List<Color?> cells;
  final int grid;

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / grid;
    final Paint p = Paint();
    for (int i = 0; i < cells.length; i++) {
      final Color? c = cells[i];
      if (c == null) continue;
      final int col = i % grid;
      final int row = i ~/ grid;
      p.color = c;
      canvas.drawRect(
        Rect.fromLTWH(col * cell, row * cell, cell + 0.5, cell + 0.5),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaintLayer old) => true;
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
