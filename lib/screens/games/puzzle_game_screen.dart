import 'package:flutter/material.dart';

import '../../data/game_content.dart';
import '../../models/world.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'game_finish.dart';

/// Quebra-Cabeça funcional. MVP: 9 peças (3x3) no estilo deslizante. A figura
/// é formada por um ícone temático dividido em 9 partes.
class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key, required this.world});

  final World world;

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  static const int n = 3; // 3x3
  static const double board = 300;
  double get tile => board / n;

  late Subject _subject;
  late List<int> _tiles; // posição -> id da peça (8 = espaço vazio)
  bool _usedHint = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    final List<Subject> subjects = subjectsForWorld(widget.world.id);
    _subject = subjects.isNotEmpty
        ? subjects[DateTime.now().millisecond % subjects.length]
        : const Subject(
            name: 'Figura', icon: Icons.image_rounded, color: Colors.grey);
    _shuffle();
  }

  void _shuffle() {
    _tiles = List<int>.generate(n * n, (int i) => i);
    // Embaralha fazendo movimentos válidos a partir do estado resolvido,
    // garantindo solubilidade.
    int blank = n * n - 1;
    int seed = DateTime.now().microsecondsSinceEpoch;
    for (int s = 0; s < 80; s++) {
      final List<int> neighbors = _neighborsOf(blank);
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      final int pick = neighbors[seed % neighbors.length];
      _tiles[blank] = _tiles[pick];
      _tiles[pick] = n * n - 1;
      blank = pick;
    }
    _usedHint = false;
    _showPreview = false;
    setState(() {});
  }

  List<int> _neighborsOf(int pos) {
    final int r = pos ~/ n;
    final int c = pos % n;
    final List<int> out = <int>[];
    if (r > 0) out.add(pos - n);
    if (r < n - 1) out.add(pos + n);
    if (c > 0) out.add(pos - 1);
    if (c < n - 1) out.add(pos + 1);
    return out;
  }

  int get _blankPos => _tiles.indexOf(n * n - 1);

  void _tap(int pos) {
    final int blank = _blankPos;
    if (_neighborsOf(pos).contains(blank)) {
      setState(() {
        _tiles[blank] = _tiles[pos];
        _tiles[pos] = n * n - 1;
      });
      if (_solved()) _onWin();
    }
  }

  bool _solved() {
    for (int i = 0; i < _tiles.length; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  void _onWin() {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      finishActivity(
        context,
        world: widget.world,
        game: GameId.puzzle,
        perfect: !_usedHint,
        playAgain: (_) => PuzzleGameScreen(world: widget.world),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Text('Quebra-Cabeça: ${_subject.name}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Embaralhar',
                      onPressed: _shuffle,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: board,
                        height: board,
                        child: Stack(
                          children: <Widget>[
                            for (int pos = 0; pos < n * n; pos++)
                              if (_tiles[pos] != n * n - 1)
                                _buildTile(pos),
                            if (_showPreview)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Icon(_subject.icon,
                                        size: board * 0.7,
                                        color: _subject.color),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kidsYellow,
                              foregroundColor: Colors.black87,
                            ),
                            onPressed: () {
                              setState(() {
                                _usedHint = true;
                                _showPreview = true;
                              });
                              Future<void>.delayed(
                                  const Duration(milliseconds: 1200), () {
                                if (mounted) {
                                  setState(() => _showPreview = false);
                                }
                              });
                            },
                            icon: const Icon(Icons.lightbulb_rounded),
                            label: const Text('Dica'),
                          ),
                          const SizedBox(height: 12),
                          Text('Monte a figura\ndeslizando as peças!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ],
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

  Widget _buildTile(int pos) {
    final int id = _tiles[pos];
    final int correctRow = id ~/ n;
    final int correctCol = id % n;
    final int r = pos ~/ n;
    final int c = pos % n;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      left: c * tile,
      top: r * tile,
      width: tile,
      height: tile,
      child: GestureDetector(
        onTap: () => _tap(pos),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipRect(
            child: OverflowBox(
              minWidth: 0,
              minHeight: 0,
              maxWidth: board,
              maxHeight: board,
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(-correctCol * tile, -correctRow * tile),
                child: Container(
                  width: board,
                  height: board,
                  color: Color.lerp(_subject.color, Colors.white, 0.85),
                  child: Center(
                    child: Icon(_subject.icon,
                        size: board * 0.7, color: _subject.color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
