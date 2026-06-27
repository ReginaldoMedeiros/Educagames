import 'package:flutter/material.dart';

import '../../models/world.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'game_finish.dart';

/// Letras e Números (PT-BR). Mostra uma letra/número grande com ilustração
/// associada e botões grandes de resposta. Sem erros = conclusão perfeita.
class LettersNumbersScreen extends StatefulWidget {
  const LettersNumbersScreen({super.key, required this.world});

  final World world;

  @override
  State<LettersNumbersScreen> createState() => _LettersNumbersScreenState();
}

class _Question {
  _Question({
    required this.prompt,
    required this.bigText,
    required this.icon,
    required this.iconCount,
    required this.options,
    required this.answer,
  });

  final String prompt;
  final String bigText; // letra ou palavra de apoio
  final IconData icon;
  final int iconCount; // quantos ícones mostrar (números); 1 para letras
  final List<String> options;
  final String answer;
}

class _LettersNumbersScreenState extends State<LettersNumbersScreen> {
  late List<_Question> _questions;
  int _index = 0;
  int _errors = 0;
  String? _wrongPick;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions();
  }

  // Associações simples de letras (letra, palavra, ícone).
  static const List<List<dynamic>> _letterData = <List<dynamic>>[
    <dynamic>['A', 'Abelha', Icons.emoji_nature_rounded],
    <dynamic>['B', 'Bola', Icons.sports_soccer_rounded],
    <dynamic>['C', 'Casa', Icons.home_rounded],
    <dynamic>['D', 'Dado', Icons.casino_rounded],
    <dynamic>['E', 'Estrela', Icons.star_rounded],
    <dynamic>['F', 'Flor', Icons.local_florist_rounded],
    <dynamic>['L', 'Lua', Icons.nightlight_round],
    <dynamic>['P', 'Peixe', Icons.set_meal_rounded],
    <dynamic>['S', 'Sol', Icons.wb_sunny_rounded],
  ];

  List<_Question> _buildQuestions() {
    final int seed = DateTime.now().millisecondsSinceEpoch;
    final List<_Question> qs = <_Question>[];

    // 3 perguntas de letras.
    for (int i = 0; i < 3; i++) {
      final List<dynamic> d = _letterData[(seed ~/ (i + 1) + i * 3) % _letterData.length];
      final String letter = d[0] as String;
      final String word = d[1] as String;
      final IconData icon = d[2] as IconData;
      final Set<String> opts = <String>{letter};
      int k = 1;
      while (opts.length < 4) {
        final String alt = String.fromCharCode(
            'A'.codeUnitAt(0) + (letter.codeUnitAt(0) - 65 + k * 3) % 26);
        opts.add(alt);
        k++;
      }
      final List<String> options = opts.toList()..sort();
      qs.add(_Question(
        prompt: 'Com qual letra começa "$word"?',
        bigText: word,
        icon: icon,
        iconCount: 1,
        options: options,
        answer: letter,
      ));
    }

    // 2 perguntas de números (0-20).
    for (int i = 0; i < 2; i++) {
      final int count = 1 + (seed ~/ (i + 5) + i * 7) % 9; // 1..9 ícones
      final Set<String> opts = <String>{'$count'};
      int k = 1;
      while (opts.length < 4) {
        final int alt = (count + k) % 10 + 1;
        opts.add('$alt');
        k++;
      }
      final List<String> options = opts.toList()
        ..sort((String a, String b) => int.parse(a).compareTo(int.parse(b)));
      qs.add(_Question(
        prompt: 'Quantos você vê?',
        bigText: '',
        icon: Icons.star_rounded,
        iconCount: count,
        options: options,
        answer: '$count',
      ));
    }
    return qs;
  }

  void _answer(String pick) {
    final _Question q = _questions[_index];
    if (pick == q.answer) {
      if (_index == _questions.length - 1) {
        finishActivity(
          context,
          world: widget.world,
          game: GameId.letters,
          perfect: _errors == 0,
          playAgain: (_) => LettersNumbersScreen(world: widget.world),
        );
      } else {
        setState(() {
          _index++;
          _wrongPick = null;
        });
      }
    } else {
      setState(() {
        _errors++;
        _wrongPick = pick;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _Question q = _questions[_index];
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
                    const Text('Letras e Números',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('${_index + 1} / ${_questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(q.prompt,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        // Ilustração associada.
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            for (int i = 0; i < q.iconCount; i++)
                              Icon(q.icon,
                                  size: q.iconCount > 1 ? 44 : 90,
                                  color: Colors.white),
                          ],
                        ),
                        if (q.bigText.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(q.bigText,
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ],
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 14,
                          children: <Widget>[
                            for (final String opt in q.options)
                              _OptionButton(
                                label: opt,
                                wrong: _wrongPick == opt,
                                onTap: () => _answer(opt),
                              ),
                          ],
                        ),
                        if (_wrongPick != null) ...<Widget>[
                          const SizedBox(height: 12),
                          const Text('Quase! Tente de novo.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
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

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: wrong ? Colors.red.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: wrong ? Colors.redAccent : AppColors.kidsBlue, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
