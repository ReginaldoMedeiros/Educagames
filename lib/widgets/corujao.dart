import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Representação simples (2D, sem assets externos) do Mestre Corujão Explorador:
/// coruja com óculos redondos e chapéu de explorador. Usado em tutoriais,
/// boas-vindas, conquistas e avisos de tempo.
///
/// IMPORTANTE: o Mestre Corujão é o mascote oficial e definitivo. Nenhum outro
/// animal pode substituí-lo como guia principal do app.
class Corujao extends StatelessWidget {
  const Corujao({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      // Arte oficial aprovada; cai para o desenho vetorial se o asset faltar.
      child: Image.asset(
        'assets/branding/mascot/mestre_corujao.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            CustomPaint(painter: _CorujaoPainter()),
      ),
    );
  }
}

class _CorujaoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint body = Paint()..color = const Color(0xFF8D6E63);
    final Paint belly = Paint()..color = const Color(0xFFD7CCC8);
    final Paint hat = Paint()..color = AppColors.kidsOrange;
    final Paint white = Paint()..color = Colors.white;
    final Paint dark = Paint()..color = const Color(0xFF3E2723);
    final Paint scarf = Paint()..color = AppColors.kidsBlue;

    final Offset center = Offset(w / 2, h * 0.55);

    // Corpo
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.7, height: h * 0.7),
      body,
    );
    // Barriga
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + h * 0.05),
          width: w * 0.42,
          height: h * 0.45),
      belly,
    );
    // Lenço azul
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy - h * 0.05),
          width: w * 0.5,
          height: h * 0.2),
      0.2,
      2.7,
      false,
      scarf..strokeWidth = h * 0.06..style = PaintingStyle.stroke,
    );

    // Olhos (óculos redondos)
    final double eyeY = center.dy - h * 0.12;
    final double eyeDx = w * 0.13;
    for (final double sign in <double>[-1, 1]) {
      final Offset eye = Offset(center.dx + sign * eyeDx, eyeY);
      canvas.drawCircle(eye, w * 0.11, white);
      canvas.drawCircle(eye, w * 0.11,
          Paint()..color = dark.color..style = PaintingStyle.stroke..strokeWidth = w * 0.02);
      canvas.drawCircle(eye, w * 0.045, dark);
    }
    // Ponte dos óculos
    canvas.drawLine(
      Offset(center.dx - eyeDx + w * 0.09, eyeY),
      Offset(center.dx + eyeDx - w * 0.09, eyeY),
      Paint()..color = dark.color..strokeWidth = w * 0.02,
    );
    // Bico
    final Path beak = Path()
      ..moveTo(center.dx - w * 0.05, eyeY + h * 0.08)
      ..lineTo(center.dx + w * 0.05, eyeY + h * 0.08)
      ..lineTo(center.dx, eyeY + h * 0.16)
      ..close();
    canvas.drawPath(beak, Paint()..color = AppColors.kidsYellow);

    // Chapéu de explorador
    final double hatY = center.dy - h * 0.34;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, hatY + h * 0.02),
          width: w * 0.62,
          height: h * 0.12),
      hat,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(center.dx, hatY + h * 0.04),
          width: w * 0.4,
          height: h * 0.28),
      3.14,
      3.14,
      false,
      hat,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Balão de fala do Mestre Corujão com uma mensagem positiva.
class CorujaoMessage extends StatelessWidget {
  const CorujaoMessage({
    super.key,
    required this.message,
    this.size = 96,
  });

  final String message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Corujao(size: size),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
