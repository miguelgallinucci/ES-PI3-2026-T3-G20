// Widget responsável por exibir o gráfico decorativo da tela de login.
//
// Isola o desenho visual usado na autenticação, mantendo a LoginPage
// mais limpa e focada no formulário de entrada.
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginDecorativeChart extends StatelessWidget {
  const LoginDecorativeChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.25,
      child: Transform.translate(
        offset: const Offset(0, -27),
        child: CustomPaint(
          painter: _LoginDecorativeChartPainter(),
        ),
      ),
    );
  }
}

/// Painter personalizado que desenha um gráfico decorativo com linhas azuis e gradiente rosa.
/// Usado como elemento visual na seção superior da página de login.
class _LoginDecorativeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Desenha linhas de grade muito sutis como fundo
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    // Linhas horizontais da grade
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Linhas verticais da grade
    for (int i = 1; i <= 5; i++) {
      final x = size.width * (i / 6);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Pontos da primeira linha do gráfico (azul)
    final blueLinePoints = [
      Offset(size.width * 0.00, size.height * 0.62),
      Offset(size.width * 0.18, size.height * 0.38),
      Offset(size.width * 0.34, size.height * 0.56),
      Offset(size.width * 0.52, size.height * 0.30),
      Offset(size.width * 0.78, size.height * 0.46),
      Offset(size.width * 0.96, size.height * 0.12),
    ];

    // Pontos da segunda linha do gráfico (gradiente rosa/primário)
    final pinkLinePoints = [
      Offset(size.width * 0.00, size.height * 0.72),
      Offset(size.width * 0.16, size.height * 0.82),
      Offset(size.width * 0.30, size.height * 0.50),
      Offset(size.width * 0.48, size.height * 0.72),
      Offset(size.width * 0.66, size.height * 0.28),
      Offset(size.width * 0.94, size.height * 0.52),
    ];

    // Helper para construir um caminho a partir de uma lista de pontos
    Path buildLinePath(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      return path;
    }

    // Cria os caminhos para as duas linhas do gráfico
    final bluePath = buildLinePath(blueLinePoints);
    final pinkPath = buildLinePath(pinkLinePoints);

    // Paint para o brilho/glow da linha azul
    final blueGlowPaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.16)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Paint para o brilho/glow da linha rosa
    final pinkGlowPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.14)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Paint para a linha azul sólida
    final blueLinePaint = Paint()
      ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.95)
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint para a linha rosa com gradiente
    final pinkLinePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.primaryLight,
          AppColors.primary,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(bluePath, blueGlowPaint);
    canvas.drawPath(pinkPath, pinkGlowPaint);

    canvas.drawPath(bluePath, blueLinePaint);
    canvas.drawPath(pinkPath, pinkLinePaint);

    final blueDotPaint = Paint()
      ..color = const Color(0xFF3BA7FF)
      ..style = PaintingStyle.fill;

    final pinkDotPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    for (final point in blueLinePoints) {
      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = const Color(0xFF3BA7FF).withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, 4.2, blueDotPaint);
      canvas.drawCircle(
        point,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    for (final point in pinkLinePoints) {
      canvas.drawCircle(
        point,
        7,
        Paint()
          ..color = AppColors.primaryLight.withValues(alpha: 0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, 4.2, pinkDotPaint);
      canvas.drawCircle(
        point,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF071A2B).withValues(alpha: 0.92),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.55,
          size.width,
          size.height * 0.45,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.55,
        size.width,
        size.height * 0.45,
      ),
      fadePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
