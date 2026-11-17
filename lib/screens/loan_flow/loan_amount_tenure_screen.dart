import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';
import 'apply_loan_flow_screen.dart';

/// Screen 2 of Apply Loan Flow: "Loan amount + Tenure" (Step 2 of 4)
class LoanAmountTenureScreen extends StatelessWidget {
  const LoanAmountTenureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApplyLoanFlowScreen(initialStep: 2);
  }
}

/// Content body of "Loan amount + Tenure" (used within sticky-header Loan Flow)
class LoanAmountTenureBody extends StatelessWidget {
  const LoanAmountTenureBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Loan Type Chip Badge
                Obx(
                  () => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getIconForLoanType(
                            controller.selectedLoanType.value,
                          ),
                          size: 15,
                          color: const Color(0xFF4340BE),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.selectedLoanType.value,
                          style: const TextStyle(
                            color: Color(0xFF4340BE),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title
                const Text(
                  'How much do you need?',
                  style: TextStyle(
                    color: Color(0xFF1E2127),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                    const SizedBox(height: 16),

                    // 1. Interactive Loan Amount Card
                    _buildLoanAmountCard(controller),
                    const SizedBox(height: 20),

                    // 2. Tenure Selection
                    const Text(
                      'Tenure',
                      style: TextStyle(
                        color: Color(0xFF1E2127),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTenureSelector(controller),
                    const SizedBox(height: 18),

                    // 3. Estimated EMI Hero Banner Card
                    _buildEmiBannerCard(controller),
                  ],
                ),
              ),
            ),

        // Bottom Actions: "Back" & "Next step ->"
        _buildBottomButtons(context, controller),
      ],
    );
  }

  /// White card containing formatted amount, interactive slider, and quick presets
  Widget _buildLoanAmountCard(ApplyLoanController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEF2F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Loan amount',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // Big Amount Display
          Obx(
            () => Text(
              controller.formatIndianCurrency(controller.loanAmount.value),
              style: const TextStyle(
                color: Color(0xFF1E2127),
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Custom Styled Slider
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: const Color(0xFFFDB022),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: const Color(0xFFFDB022),
                overlayColor: const Color(0xFFFDB022).withValues(alpha: 0.2),
                thumbShape: const _DualColorThumbShape(
                  radius: 12,
                  innerRadius: 6,
                  outerColor: Color(0xFFFDB022),
                  innerColor: Color(0xFF212074),
                ),
              ),
              child: Slider(
                value: controller.loanAmount.value,
                min: 50000.0,
                max: 5000000.0,
                divisions: 99,
                onChanged: (val) => controller.setLoanAmount(val),
              ),
            ),
          ),

          // Min & Max range markers
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹50K',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹50L',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Presets Row: ₹1L, ₹3L, ₹4.5L, ₹10L, ₹25L
          _buildQuickPresets(controller),
        ],
      ),
    );
  }

  Widget _buildQuickPresets(ApplyLoanController controller) {
    final labels = ['₹1L', '₹3L', '₹4.5L', '₹10L', '₹25L'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(controller.quickAmountPresets.length, (index) {
        final amount = controller.quickAmountPresets[index];
        final label = labels[index];

        return Obx(() {
          final isSelected = (controller.loanAmount.value - amount).abs() < 1000;

          return GestureDetector(
            onTap: () => controller.setLoanAmount(amount),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF212074)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  /// 4 side-by-side Tenure cards (5, 10, 15, 20 years)
  Widget _buildTenureSelector(ApplyLoanController controller) {
    return Row(
      children: controller.tenureOptions.map((years) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Obx(() {
              final isSelected = controller.selectedTenureYears.value == years;

              return GestureDetector(
                onTap: () => controller.setTenureYears(years),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A44D1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A44D1)
                          : const Color(0xFFEEF2F6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF4A44D1).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$years',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E2127),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'years',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFC7CAE8)
                              : const Color(0xFF6B7280),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  /// Royal blue banner showing live calculated EMI & Total Interest
  Widget _buildEmiBannerCard(ApplyLoanController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2A8E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2A8E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Cosmic Curve Painter
          const Positioned.fill(
            child: CustomPaint(
              painter: _LoanEmiCosmicPainter(),
            ),
          ),

          // Content Row
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Estimated monthly EMI
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated monthly EMI',
                        style: TextStyle(
                          color: Color(0xFFC7CAE8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.formatIndianCurrency(controller.estimatedMonthlyEmi),
                          style: const TextStyle(
                            color: Color(0xFFFDB022),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Indicative at 9.5% p.a. · final rate after review',
                        style: TextStyle(
                          color: Color(0xFFB1B6DF),
                          fontSize: 10.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Total interest
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total\ninterest',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFFC7CAE8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.formatIndianCurrency(controller.totalInterestPayable),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ApplyLoanController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => controller.handleBack(),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDDE3F0),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF1E2127),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // "Next step ->" Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  controller.goToStep(3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF212074),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next step',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFFDB022),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom thumb shape for the loan amount slider
class _DualColorThumbShape extends SliderComponentShape {
  final double radius;
  final double innerRadius;
  final Color outerColor;
  final Color innerColor;

  const _DualColorThumbShape({
    required this.radius,
    required this.innerRadius,
    required this.outerColor,
    required this.innerColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

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
    final canvas = context.canvas;

    final outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }
}

/// Custom painter for tilted elliptical cosmic orbit loop on Loan EMI Banner,
/// matching the exact design pattern used on the PAN card in Review PAN Details screen.
class _LoanEmiCosmicPainter extends CustomPainter {
  const _LoanEmiCosmicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width - 50, size.height * 0.44);
    canvas.rotate(-23 * math.pi / 180);

    final paint = Paint()
      ..color = const Color(0xFF8B88EF).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 170,
        height: 68,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
