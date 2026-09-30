import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The four flavor scores (0..[maxScore]) on a square radar chart: acidity at
/// the top, then sweetness, body, and bitterness clockwise.
///
/// Names sit outside the plot. Sweetness and bitterness are beside it, so they
/// are not drawn across the shape.
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

  /// The painted plot, without the names around it.
  static const plotKey = Key('flavor-radar-plot');

  final int acidity;
  final int sweetness;
  final int body;
  final int bitterness;
  final int maxScore;

  /// Width and height of the plot. Side names are added outside this square.
  final double size;
  final bool showLabels;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle =
        theme.textTheme.labelSmall ?? const TextStyle(fontSize: 11);
    return Semantics(
      label:
          'Flavor map: acidity $acidity, sweetness $sweetness, '
          'body $body, bitterness $bitterness, out of $maxScore',
      child: showLabels
          ? _LabeledPlot(
              acidity: acidity,
              sweetness: sweetness,
              body: body,
              bitterness: bitterness,
              maxScore: maxScore,
              size: size,
              labelStyle: labelStyle,
              colorScheme: theme.colorScheme,
            )
          : _plot(
              acidity: acidity,
              sweetness: sweetness,
              body: body,
              bitterness: bitterness,
              maxScore: maxScore,
              size: size,
              colorScheme: theme.colorScheme,
            ),
    );
  }
}

class _LabeledPlot extends StatelessWidget {
  const _LabeledPlot({
    required this.acidity,
    required this.sweetness,
    required this.body,
    required this.bitterness,
    required this.maxScore,
    required this.size,
    required this.labelStyle,
    required this.colorScheme,
  });

  final int acidity;
  final int sweetness;
  final int body;
  final int bitterness;
  final int maxScore;
  final double size;
  final TextStyle labelStyle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final bitternessWidth = _textWidth('Bitterness', labelStyle, direction);
    final sweetnessWidth = _textWidth('Sweetness', labelStyle, direction);
    final sideLabels =
        bitternessWidth + sweetnessWidth + FlavorRadarChart._gap * 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final plotSize = maxWidth.isFinite
            ? math.min(size, math.max(48.0, maxWidth - sideLabels))
            : size;
        final plot = _plot(
          acidity: acidity,
          sweetness: sweetness,
          body: body,
          bitterness: bitterness,
          maxScore: maxScore,
          size: plotSize,
          colorScheme: colorScheme,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Acidity', style: labelStyle),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Bitterness', style: labelStyle),
                const SizedBox(width: FlavorRadarChart._gap),
                plot,
                const SizedBox(width: FlavorRadarChart._gap),
                Text('Sweetness', style: labelStyle),
              ],
            ),
            const SizedBox(height: 2),
            Text('Body', style: labelStyle),
          ],
        );
      },
    );
  }
}

Widget _plot({
  required int acidity,
  required int sweetness,
  required int body,
  required int bitterness,
  required int maxScore,
  required double size,
  required ColorScheme colorScheme,
}) {
  return SizedBox.square(
    key: FlavorRadarChart.plotKey,
    dimension: size,
    child: CustomPaint(
      painter: _RadarPainter(
        values: [acidity, sweetness, body, bitterness],
        maxScore: maxScore,
        gridColor: colorScheme.outlineVariant,
        fillColor: colorScheme.primary.withValues(alpha: 0.25),
        strokeColor: colorScheme.primary,
      ),
    ),
  );
}

double _textWidth(String text, TextStyle style, TextDirection direction) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: direction,
    maxLines: 1,
  )..layout();
  return painter.width;
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.maxScore,
    required this.gridColor,
    required this.fillColor,
    required this.strokeColor,
  });

  final List<int> values;
  final int maxScore;
  final Color gridColor;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const inset = 4.0;
    final radius = size.shortestSide / 2 - inset;
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
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.values.toString() != values.toString() ||
      old.gridColor != gridColor ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor;
}
