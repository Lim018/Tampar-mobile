import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/budget.dart';

class BudgetBreakdown extends StatelessWidget {
  final Budget budget;
  const BudgetBreakdown({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budget Breakdown', style: AppTypography.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'On Track',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF15803D),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    fixedPercent: budget.fixedPercent,
                    debtPercent: budget.debtPercent,
                    freePercent: budget.freePercent,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                        Text(
                          '5jt',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _LegendItem(
                      color: const Color(0xFFA5B4FC),
                      label: 'Fixed',
                      value: '${budget.fixedPercent.round()}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.secondary,
                      label: 'Debt',
                      value: '${budget.debtPercent.round()}%',
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.primary,
                      label: 'Free',
                      value: '${budget.freePercent.round()}%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double fixedPercent;
  final double debtPercent;
  final double freePercent;

  _DonutChartPainter({
    required this.fixedPercent,
    required this.debtPercent,
    required this.freePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.28;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final total = fixedPercent + debtPercent + freePercent;
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final gap = 0.04; // small gap between segments

    // Free (primary)
    _drawArc(
      canvas,
      rect,
      startAngle,
      freePercent / 100,
      strokeWidth,
      AppColors.primary,
    );
    startAngle += (freePercent / 100) * 2 * math.pi + gap;

    // Fixed (indigo light)
    _drawArc(
      canvas,
      rect,
      startAngle,
      fixedPercent / 100,
      strokeWidth,
      const Color(0xFFA5B4FC),
    );
    startAngle += (fixedPercent / 100) * 2 * math.pi + gap;

    // Debt (secondary)
    _drawArc(
      canvas,
      rect,
      startAngle,
      debtPercent / 100,
      strokeWidth,
      AppColors.secondary,
    );
  }

  void _drawArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double fraction,
    double strokeWidth,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, fraction * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
