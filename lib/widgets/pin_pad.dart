import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Teclado numérico para PIN dos pais. Layout em paisagem: pontos de progresso
/// à esquerda, teclado à direita.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.title,
    this.subtitle,
    this.length = 4,
    required this.onCompleted,
    this.errorText,
  });

  final String title;
  final String? subtitle;
  final int length;
  final ValueChanged<String> onCompleted;
  final String? errorText;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _value = '';

  void _press(String digit) {
    if (_value.length >= widget.length) return;
    setState(() => _value += digit);
    if (_value.length == widget.length) {
      final String done = _value;
      // Pequeno atraso para o usuário ver o último ponto preencher.
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        widget.onCompleted(done);
      });
    }
  }

  void _backspace() {
    if (_value.isEmpty) return;
    setState(() => _value = _value.substring(0, _value.length - 1));
  }

  /// Limpa o valor digitado (usado pela tela quando o PIN está incorreto).
  void reset() => setState(() => _value = '');

  @override
  void didUpdateWidget(covariant PinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText != widget.errorText) {
      _value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.lock_rounded,
                  size: 48, color: AppColors.parentBlue),
              const SizedBox(height: 12),
              Text(widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
              if (widget.subtitle != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(widget.length, (int i) {
                  final bool filled = i < _value.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? AppColors.parentBlue
                          : Colors.transparent,
                      border: Border.all(
                          color: AppColors.parentBlue, width: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              if (widget.errorText != null)
                Text(widget.errorText!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: _Keypad(onDigit: _press, onBackspace: _backspace),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            for (int n = 1; n <= 9; n++) _key('$n'),
            const SizedBox.shrink(),
            _key('0'),
            _KeyButton(
              child: const Icon(Icons.backspace_rounded),
              onTap: onBackspace,
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(String digit) =>
      _KeyButton(child: Text(digit, style: const TextStyle(fontSize: 26)),
          onTap: () => onDigit(digit));
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
