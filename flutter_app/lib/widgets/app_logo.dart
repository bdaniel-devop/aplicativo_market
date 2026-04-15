import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 100.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(
          color: color ?? AppTheme.primaryGreen,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / 100.0;
    final double scaleY = size.height / 100.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0 * scaleX
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Path 1: Traçado da folha principal esquerda
    final path1 = Path()
      ..moveTo(50 * scaleX, 85 * scaleY)
      ..cubicTo(
          50 * scaleX, 85 * scaleY, 32 * scaleX, 78 * scaleY, 20 * scaleX, 60 * scaleY)
      ..cubicTo(
          8 * scaleX, 42 * scaleY, 10 * scaleX, 25 * scaleY, 10 * scaleX, 25 * scaleY)
      ..cubicTo(
          10 * scaleX, 25 * scaleY, 28 * scaleX, 22 * scaleY, 42 * scaleX, 35 * scaleY)
      ..cubicTo(
          56 * scaleX, 48 * scaleY, 60 * scaleX, 65 * scaleY, 60 * scaleX, 65 * scaleY);

    // Path 2: Curva superior direita
    final path2 = Path()
      ..moveTo(48 * scaleX, 28 * scaleY)
      ..cubicTo(
          48 * scaleX, 28 * scaleY, 65 * scaleX, 15 * scaleY, 85 * scaleX, 18 * scaleY)
      ..cubicTo(
          105 * scaleX, 21 * scaleY, 95 * scaleX, 45 * scaleY, 95 * scaleX, 45 * scaleY);

    // Path 3: Curva inferior direita
    final path3 = Path()
      ..moveTo(68 * scaleX, 45 * scaleY)
      ..cubicTo(
          68 * scaleX, 45 * scaleY, 78 * scaleX, 35 * scaleY, 88 * scaleX, 38 * scaleY)
      ..cubicTo(
          98 * scaleX, 41 * scaleY, 90 * scaleX, 60 * scaleY, 90 * scaleX, 60 * scaleY)
      ..cubicTo(
          90 * scaleX, 60 * scaleY, 75 * scaleX, 75 * scaleY, 55 * scaleX, 85 * scaleY);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
