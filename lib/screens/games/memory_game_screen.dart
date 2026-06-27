import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/game_content.dart';
import '../../models/world.dart';
import '../../widgets/common_widgets.dart';
import 'game_finish.dart';

/// Jogo da Memória funcional. Grade 4x3 (6 pares) com tema do mundo atual.
class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key, required this.world});

  final World world;

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  static const int pairs = 6;

  late List<int> _cards; // índice do assunto para cada carta
  final Set<int> _faceUp = <int>{};
  final Set<int> _matched = <int>{};
  int _moves = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final List<Subject> subjects = subjectsForWorld(widget.world.id);
    final int count = subjects.length < pairs ? subjects.length : pairs;
    final List<int> deck = <int>[];
    for (int i = 0; i < count; i++) {
      deck..add(i)..add(i);
    }
    // Embaralhamento determinístico-suave baseado no relógio (sem dependências).
    final int seed = DateTime.now().microsecondsSinceEpoch;
    for (int i = deck.length - 1; i > 0; i--) {
      final int j = (seed ~/ (i + 1) + i * 7) % (i + 1);
      final int tmp = deck[i];
      deck[i] = deck[j];
      deck[j] = tmp;
    }
    _cards = deck;
    _faceUp.clear();
    _matched.clear();
    _moves = 0;
    _busy = false;
  }

  void _onTap(int index) {
    if (_busy) return;
    if (_matched.contains(index) || _faceUp.contains(index)) return;

    setState(() => _faceUp.add(index));

    if (_faceUp.length == 2) {
      _moves++;
      final List<int> open = _faceUp.toList();
      if (_cards[open[0]] == _cards[open[1]]) {
        // Par encontrado.
        setState(() {
          _matched.addAll(open);
          _faceUp.clear();
        });
        if (_matched.length == _cards.length) {
          _onWin();
        }
      } else {
        // Desvira após um instante.
        _busy = true;
        Timer(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            _faceUp.clear();
            _busy = false;
          });
        });
      }
    }
  }

  void _onWin() {
    final bool perfect = _moves <= pairs + 2;
    Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      finishActivity(
        context,
        world: widget.world,
        game: GameId.memory,
        perfect: perfect,
        playAgain: (_) => MemoryGameScreen(world: widget.world),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Subject> subjects = subjectsForWorld(widget.world.id);
    final double progress =
        _cards.isEmpty ? 0 : _matched.length / _cards.length;

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
                    const Text('Memória',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    _Counter(
                        icon: Icons.touch_app_rounded, label: 'Jogadas: $_moves'),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Reiniciar',
                      onPressed: () => setState(_setup),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white54,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (BuildContext context, int i) {
                      final bool shown =
                          _faceUp.contains(i) || _matched.contains(i);
                      final Subject s = subjects[_cards[i]];
                      return _MemoryCard(
                        shown: shown,
                        matched: _matched.contains(i),
                        subject: s,
                        onTap: () => _onTap(i),
                      );
                    },
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

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.shown,
    required this.matched,
    required this.subject,
    required this.onTap,
  });

  final bool shown;
  final bool matched;
  final Subject subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: shown ? Colors.white : Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: matched
              ? Border.all(color: subject.color, width: 3)
              : Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Center(
          child: shown
              ? Icon(subject.icon, size: 48, color: subject.color)
              : const Icon(Icons.help_outline_rounded,
                  size: 40, color: Colors.white),
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
