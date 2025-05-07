import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BudLinearGradientProgressIndicator extends StatelessWidget {
  /// 0.0 ~ 1.0
  final double? value;

  final Color backgroundColor;
  final Color? color;
  final LinearGradient? gradient;
  final double minHeight;
  final BorderRadius? borderRadius;

  const BudLinearGradientProgressIndicator({
    super.key,
    this.value = 0,
    this.backgroundColor = const Color(0x1AFFFFFF),
    this.gradient,
    this.color,
    this.minHeight = 7,
    this.borderRadius,
  });

  static BorderRadius defaultBorderRadius = BorderRadius.circular(4);

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = this.borderRadius ?? defaultBorderRadius;
    Color color = this.color ?? Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        clipBehavior: (borderRadius != BorderRadius.zero && value == null) ? Clip.antiAlias : Clip.none,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        constraints: BoxConstraints(
          minWidth: double.infinity,
          minHeight: minHeight,
        ),
        child: CustomPaint(
          painter: _LinearProgressIndicatorPainter(
            backgroundColor: backgroundColor,
            valueColor: color,
            gradient: gradient,
            value: value,
            indicatorBorderRadius: borderRadius,
          ),
        ),
      );
    });
  }
}

class _LinearProgressIndicatorPainter extends CustomPainter {
  const _LinearProgressIndicatorPainter({
    required this.backgroundColor,
    required this.valueColor,
    this.gradient,
    this.value,
    required this.indicatorBorderRadius,
  });

  final Color backgroundColor;
  final Color valueColor;
  final LinearGradient? gradient;
  final double? value;
  final BorderRadius indicatorBorderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint.color = valueColor;
    }

    void drawBar(double x, double width) {
      if (width <= 0.0) {
        return;
      }

      final Rect rect = Offset(x, 0.0) & Size(width, size.height);
      if (indicatorBorderRadius != BorderRadius.zero) {
        final RRect rrect = indicatorBorderRadius.toRRect(rect);
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }

    if (value != null) {
      drawBar(0.0, clampDouble(value!, 0.0, 1.0) * size.width);
    } else {
      final double x1 = size.width;
      final double width1 = size.width - x1;

      final double x2 = size.width;
      final double width2 = size.width - x2;

      drawBar(x1, width1);
      drawBar(x2, width2);
    }
  }

  @override
  bool shouldRepaint(_LinearProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.indicatorBorderRadius != indicatorBorderRadius;
  }
}
