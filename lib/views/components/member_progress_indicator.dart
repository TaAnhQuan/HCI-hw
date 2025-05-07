import 'package:app/views/ui/bud_linear_gradient_progress_indicator.dart';
import 'package:flutter/material.dart';

class MemberLinearProgressIndicator extends StatelessWidget {
  final double value;

  const MemberLinearProgressIndicator({
    super.key,
    this.value = 0,
  });

  final int count = 4;

  double getConvertProgress(int index) {
    double section = 1 / count;
    double min = section * index;
    double max = section * (index + 1);
    if (value < min) return 0;
    if (value > max) return 1;
    return (value - min) / section;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BudLinearGradientProgressIndicator(
            value: getConvertProgress(0),
            gradient: const LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFC8E5F0),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: BudLinearGradientProgressIndicator(
            value: getConvertProgress(1),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFC0E2EE),
                Color(0xFF92CDE2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: BudLinearGradientProgressIndicator(
            value: getConvertProgress(2),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF74CEDA),
                Color(0xFF4DC4CF),
              ],
              stops: [
                0.0,
                getConvertProgress(2),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: BudLinearGradientProgressIndicator(
            value: getConvertProgress(3),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CC4CF),
                Color(0xFF29BBC6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
