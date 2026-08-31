import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppleHealthRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final double gapRadius; // angle gap at end in radians

  const AppleHealthRing({
    super.key,
    required this.progress,
    this.size = 300,
    this.strokeWidth = 18,
    this.progressColor = const Color(0xFF30D158), // Apple green
    this.trackColor = const Color(0xFF3A3A3C), // Apple dark track
    this.gapRadius = 0.02,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTrackColor = isDark
        ? trackColor
        : const Color(0xFFE5E5EA); // Apple light track
    final effectiveProgressColor = progressColor;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          trackColor: effectiveTrackColor,
          progressColor: effectiveProgressColor,
          gapRadius: gapRadius,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final double gapRadius;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
    required this.gapRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Track paint - very thin and subtle
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth * 0.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Progress paint - thick and vibrant
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Start at 12 o'clock (-pi/2)
    const startAngle = -math.pi / 2;
    const fullCircle = 2 * math.pi;
    final sweepAngle = fullCircle * progress - gapRadius;

    // Draw full track circle (very subtle)
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc if there's progress
    if (progress > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}