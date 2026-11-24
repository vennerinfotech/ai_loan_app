import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/emi_calculator_controller.dart';
import '../controller/dashboard_controller.dart';

/// Screen for interactive Loan EMI calculation (Reference Image)
class EmiCalculatorScreen extends StatelessWidget {
  final bool showBackButton;

  const EmiCalculatorScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmiCalculatorController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Main Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Monthly EMI Summary Card with Donut Chart
                    _buildEmiSummaryCard(controller),

                    const SizedBox(height: 18),

                    // Sliders Container Card
                    _buildSlidersCard(controller),

                    const SizedBox(height: 16),

                    // Total Payable Strip
                    _buildTotalPayableStrip(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button and centered title
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Squircle Back Button
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<DashboardController>()) {
                  final dash = Get.find<DashboardController>();
                  if (dash.currentNavIndex.value == 1) {
                    dash.currentNavIndex.value = 0; // Return to Home
                    return;
                  }
                }
                Get.back();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),

          // Title
          const Expanded(
            child: Center(
              child: Text(
                'EMI calculator',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Symmetrical spacer
          if (showBackButton) const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Top Banner Card with Donut Chart and EMI breakdown
  Widget _buildEmiSummaryCard(EmiCalculatorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Donut Ring Chart on the left
          Obx(() {
            return SizedBox(
              width: 86,
              height: 86,
              child: CustomPaint(
                painter: _EmiDonutPainter(
                  principalRatio: controller.principalRatio,
                ),
              ),
            );
          }),

          const SizedBox(width: 20),

          // EMI Details Column on the right
          Expanded(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Monthly EMI',
                    style: TextStyle(
                      color: AppColors.line,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.formatCurrency(controller.monthlyEmi.value),
                    style: const TextStyle(
                      color: AppColors.amber,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Principal row
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Principal ${controller.formatCurrency(controller.loanAmount.value)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Interest row
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.indigo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Interest ${controller.formatCurrency(controller.totalInterest.value)}',
                        style: const TextStyle(
                          color: AppColors.indigoTint,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  /// White Container holding the 3 sliders: Loan amount, Interest rate, Tenure
  Widget _buildSlidersCard(EmiCalculatorController controller) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Loan Amount Slider
          Obx(() {
            return _buildSliderItem(
              title: 'Loan amount',
              valueString: controller.formatCurrency(controller.loanAmount.value),
              currentValue: controller.loanAmount.value,
              minValue: controller.minLoanAmount.value,
              maxValue: controller.maxLoanAmount.value,
              minLabel: controller.formatCurrency(controller.minLoanAmount.value),
              maxLabel: controller.formatCurrency(controller.maxLoanAmount.value),
              onChanged: controller.updateLoanAmount,
            );
          }),

          const SizedBox(height: 20),

          // 2. Interest Rate Slider
          Obx(() {
            return _buildSliderItem(
              title: 'Interest rate (p.a.)',
              valueString: '${controller.interestRate.value.toStringAsFixed(1)}%',
              currentValue: controller.interestRate.value,
              minValue: controller.minInterestRate.value,
              maxValue: controller.maxInterestRate.value,
              minLabel: '${controller.minInterestRate.value.toStringAsFixed(0)}%',
              maxLabel: '${controller.maxInterestRate.value.toStringAsFixed(0)}%',
              onChanged: controller.updateInterestRate,
            );
          }),

          const SizedBox(height: 20),

          // 3. Tenure Slider
          Obx(() {
            final yrs = controller.tenureYears.value;
            final tenureStr = yrs < 1
                ? '${(yrs * 12).round()} months'
                : '${yrs.toStringAsFixed(yrs % 1 == 0 ? 0 : 1)} yrs';
            final minLabel = controller.minTenure.value < 1
                ? '${(controller.minTenure.value * 12).round()} mo'
                : '${controller.minTenure.value.toInt()} yr';
            final maxLabel = '${controller.maxTenure.value.toInt()} yrs';

            return _buildSliderItem(
              title: 'Tenure',
              valueString: tenureStr,
              currentValue: controller.tenureYears.value,
              minValue: controller.minTenure.value,
              maxValue: controller.maxTenure.value,
              minLabel: minLabel,
              maxLabel: maxLabel,
              onChanged: controller.updateTenure,
            );
          }),
        ],
      ),
    );
  }

  /// Individual slider component with title, value, custom track & thumb, and min/max labels
  Widget _buildSliderItem({
    required String title,
    required String valueString,
    required double currentValue,
    required double minValue,
    required double maxValue,
    required String minLabel,
    required String maxLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Value Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              valueString,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Custom Slider
        maxValue > minValue
            ? SliderTheme(
                data: SliderThemeData(
                  trackHeight: 5,
                  trackShape: const _EmiSliderTrackShape(),
                  activeTrackColor: AppColors.indigoTint,
                  inactiveTrackColor: AppColors.inputFill,
                  thumbColor: AppColors.navy,
                  thumbShape: const _EmiSliderThumbShape(thumbRadius: 11),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: currentValue.clamp(minValue, maxValue),
                  min: minValue,
                  max: maxValue,
                  onChanged: onChanged,
                ),
              )
            : const SizedBox(
                height: 30,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),

        const SizedBox(height: 4),

        // Min / Max labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minLabel,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              maxLabel,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Total Payable Strip
  Widget _buildTotalPayableStrip(EmiCalculatorController controller) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.indigoTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total payable',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Obx(() {
            return Text(
              controller.formatCurrency(controller.totalPayable.value),
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Custom Donut Chart Painter for Principal vs Interest breakdown
class _EmiDonutPainter extends CustomPainter {
  final double principalRatio;

  const _EmiDonutPainter({required this.principalRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 14.0;

    final baseRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Background interest arc (Lavender / Purple)
    final interestPaint = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 2. Principal arc (Amber / Golden)
    final principalPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background full circle or interest arc
    canvas.drawArc(
      baseRect,
      0,
      2 * math.pi,
      false,
      interestPaint,
    );

    // Draw principal arc starting from top (-pi / 2)
    final sweepAngle = 2 * math.pi * principalRatio;
    canvas.drawArc(
      baseRect,
      -math.pi / 2,
      sweepAngle,
      false,
      principalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmiDonutPainter oldDelegate) =>
      oldDelegate.principalRatio != principalRatio;
}

/// Custom Slider Thumb with navy center and amber border ring
class _EmiSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const _EmiSliderThumbShape({this.thumbRadius = 11.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer amber border ring
    final outerPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, outerPaint);

    // Inner navy circle
    final innerPaint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius - 3.5, innerPaint);
  }
}

/// Custom Slider Track with rounded edges
class _EmiSliderTrackShape extends RoundedRectSliderTrackShape {
  const _EmiSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 5;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
