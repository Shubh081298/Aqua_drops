import 'package:flutter/material.dart';

class TankLevelPainter extends CustomPainter {
  TankLevelPainter({
    required this.levelPercent,
    required this.isValid,
    this.animValue = 1.0,
  });

  final int    levelPercent;
  final bool   isValid;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = 16.0;

    // Tank outline
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(r),
    );

    // Background
    final bgPaint = Paint()..color = const Color(0xFFE3EAF2);
    canvas.drawRRect(tankRect, bgPaint);

    // Water fill
    final fillLevel = isValid ? (levelPercent / 100.0) * animValue : 0.0;
    final waterHeight = h * fillLevel;
    final waterTop = h - waterHeight;

    final waterColor = _colorForLevel(levelPercent);
    final waterPaint = Paint()..color = waterColor.withValues(alpha: 0.85);

    final waterRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, waterTop, w, waterHeight),
      bottomLeft:  Radius.circular(r),
      bottomRight: Radius.circular(r),
      topLeft:     waterHeight >= h ? Radius.circular(r) : Radius.zero,
      topRight:    waterHeight >= h ? Radius.circular(r) : Radius.zero,
    );
    canvas.drawRRect(waterRect, waterPaint);

    // Wave effect at water surface
    if (waterHeight > 8 && isValid) {
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final wavePath = Path();
      wavePath.moveTo(0, waterTop);
      for (double x = 0; x <= w; x += w / 4) {
        wavePath.quadraticBezierTo(
          x + w / 8, waterTop - 6,
          x + w / 4, waterTop,
        );
      }
      wavePath.lineTo(w, waterTop);
      wavePath.lineTo(w, waterTop + 10);
      wavePath.lineTo(0, waterTop + 10);
      wavePath.close();
      canvas.drawPath(wavePath, wavePaint);
    }

    // Level markers (lines at 25/50/75%)
    final markerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (final pct in [25, 50, 75]) {
      final y = h - (h * pct / 100);
      canvas.drawLine(Offset(w * 0.6, y), Offset(w * 0.95, y), markerPaint);
    }

    // Tank border
    final borderPaint = Paint()
      ..color = const Color(0xFF1769AA).withValues(alpha: 0.3)
      ..style  = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(tankRect, borderPaint);
  }

  Color _colorForLevel(int pct) {
    if (pct <= 0)   return const Color(0xFFB0BAC9);
    if (pct <= 25)  return const Color(0xFFDC4545);
    if (pct <= 50)  return const Color(0xFFF2A900);
    if (pct <= 75)  return const Color(0xFF29B6F6);
    return const Color(0xFF1769AA);
  }

  @override
  bool shouldRepaint(TankLevelPainter old) =>
      old.levelPercent != levelPercent ||
      old.animValue != animValue ||
      old.isValid != isValid;
}
