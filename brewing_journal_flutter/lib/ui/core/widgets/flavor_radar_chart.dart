import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The four flavor scores (0..[maxScore]) on a square radar chart: acidity at
/// the top, then sweetness, body, and bitterness clockwise.
class FlavorRadarChart extends StatelessWidget {
  const FlavorRadarChart({
    super.key,
    required this.acidity,
    required this.sweetness,
    required this.body,
    required this.bitterness,
    this.maxScore = 5,
    this.size = 220,
    this.showLabels = true,
  });

  final int acidity;
  final int sweetness;
  final int body;
  final int bitterness;
  final int maxScore;
  final double size;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label:
          'Flavor map: acidity $acidity, sweetness $sweetness, '
          'body $body, bitterness $bitterness, out of $maxScore',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RadarPainter(
            values: [acidity, sweetness, body, bitterness],
            labels: showLabels
                ? const ['Acidity', 'Sweetness', 'Body', 'Bitterness']
                : null,
            maxScore: maxScore,
            gridColor: theme.colorScheme.outlineVariant,
            fillColor: theme.colorScheme.primary.withValues(alpha: 0.25),
            strokeColor: theme.colorScheme.primary,
            labelStyle:
                theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.maxScore,
    required this.gridColor,
    required this.fillColor,
    required this.strokeColor,
    required this.labelStyle,
  });

  final List<int> values;
  final List<String>? labels;
  final int maxScore;
  final Color gridColor;
  final Color fillColor;
  final Color strokeColor;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final labelSpace = this.labels == null ? 4.0 : 26.0;
    final radius = size.shortestSide / 2 - labelSpace;
    final axes = values.length;

    Offset point(int axis, double fraction) {
      final angle = -math.pi / 2 + 2 * math.pi * axis / axes;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * radius * fraction;
    }

    final grid = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var ring = 1; ring <= maxScore; ring++) {
      final path = Path();
      for (var axis = 0; axis < axes; axis++) {
        final p = point(axis, ring / maxScore);
        axis == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var axis = 0; axis < axes; axis++) {
      canvas.drawLine(center, point(axis, 1), grid);
    }

    final shape = Path();
    for (var axis = 0; axis < axes; axis++) {
      final value = values[axis].clamp(0, maxScore);
      final p = point(axis, value / maxScore);
      axis == 0 ? shape.moveTo(p.dx, p.dy) : shape.lineTo(p.dx, p.dy);
    }
    shape.close();
    canvas.drawPath(shape, Paint()..color = fillColor);
    canvas.drawPath(
      shape,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    final labels = this.labels;
    if (labels == null) return;
    for (var axis = 0; axis < axes; axis++) {
      final painter = TextPainter(
        text: TextSpan(text: labels[axis], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final anchor =
          point(axis, 1) +
          switch (axis) {
            0 => Offset(-painter.width / 2, -painter.height - 4),
            1 => Offset(-painter.width, 6),
            2 => Offset(-painter.width / 2, 4),
            _ => Offset(0, 6),
          };
      painter.paint(canvas, anchor);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values.toString() != values.toString() ||
      old.gridColor != gridColor ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor ||
      old.labels != labels;
}
