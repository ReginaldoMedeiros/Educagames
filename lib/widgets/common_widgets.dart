import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botão grande e arredondado, com ícone maior que o texto (UX infantil).
class BigIconButton extends StatelessWidget {
  const BigIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.locked = false,
    this.size = 140,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: Opacity(
          opacity: locked ? 0.5 : 1,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(icon, size: size * 0.42, color: Colors.white),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.lock_rounded, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip mostrando estrelas ou moedas no topo das telas infantis.
class CurrencyChip extends StatelessWidget {
  const CurrencyChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text('$value',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Botão de voltar grande e claro (sempre no canto superior esquerdo).
class BackCircleButton extends StatelessWidget {
  const BackCircleButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          // Botão de voltar amarelo/dourado, como nos mockups aprovados.
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.kidsYellow, AppColors.rewardGold],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded,
            size: 30, color: Color(0xFF6B4A1F)),
      ),
    );
  }
}

/// Fundo com gradiente suave para as telas infantis temáticas.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    required this.color,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(color, Colors.white, 0.35)!,
            Color.lerp(color, Colors.white, 0.75)!,
          ],
        ),
      ),
      child: child,
    );
  }
}
