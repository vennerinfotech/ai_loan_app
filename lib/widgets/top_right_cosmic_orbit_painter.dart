import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../theme/theme.dart';

/// Cosmic orbit rings & animated light beam tailored for the top-right corner,
/// aligning with the step count number (3/3).
/// Styled in brand primary color (#524FBA) for crisp visibility on light backgrounds.
class TopRightCosmicOrbitPainter extends CustomPainter {
  final Animation<double> animation;

  TopRightCosmicOrbitPainter({required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Anchor aligned with the 3/3 step counter region in the top right
    final anchor = Offset(size.width - 32, 54);
    final progress = animation.value;

    // Faint circular outer guide arcs in primary color
    final ringPaint = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(anchor, 115, ringPaint);
    canvas.drawCircle(anchor, 165, ringPaint);

    // Flatter and wider elliptical animated orbit matching reference design
    const ovalWidth = 340.0;
    const ovalHeight = 78.0;
    const baseAngle = -25 * math.pi / 180;

    final ovalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ovalWidth,
          height: ovalHeight,
        ),
      );

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(baseAngle);

    // Base orbit track in primary color
    final basePaint = Paint()
      ..color = AppColors.primaryPurple.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(ovalPath, basePaint);

    // Luminous beam sweeping along the orbit in warm Golden Amber (accentGold)
    final beamPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;

    Offset? headPos;
    for (final metric in ovalPath.computeMetrics()) {
      final total = metric.length;
      final trailLen = total * 0.25;
      final head = progress * total;
      final tail = head - trailLen;

      if (tail >= 0) {
        canvas.drawPath(metric.extractPath(tail, head), beamPaint);
      } else {
        canvas.drawPath(metric.extractPath(tail + total, total), beamPaint);
        canvas.drawPath(metric.extractPath(0, head), beamPaint);
      }

      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        headPos = tangent.position;
      }
    }

    if (headPos != null) {
      canvas.drawCircle(
        headPos,
        4.5,
        Paint()
          ..color = AppColors.accentGold.withValues(alpha: 0.40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(headPos, 2.4, Paint()..color = AppColors.accentGold);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TopRightCosmicOrbitPainter oldDelegate) => false;
}
