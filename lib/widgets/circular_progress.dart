import 'package:flutter/material.dart';

class CircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? label;
  final bool showPercentage;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.color,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final clr = color ?? Theme.of(context).colorScheme.primary;
    final pct = (progress * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow shadow behind the circle
          Container(
            width: size * 0.96,
            height: size * 0.96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: clr.withValues(alpha: 0.22),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Background track (neutral grey full circle)
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
          ),
          // Progress arc (primary color)
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(clr),
            strokeCap: StrokeCap.round,
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPercentage)
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.bold,
                    color: clr,
                  ),
                ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.06,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
