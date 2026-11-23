import 'dart:math' as math;
import '../../theme/app_colors.dart';
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
class LoanAmountTenureBody extends StatefulWidget {
  const LoanAmountTenureBody({super.key});

  @override
  State<LoanAmountTenureBody> createState() => _LoanAmountTenureBodyState();
}

class _LoanAmountTenureBodyState extends State<LoanAmountTenureBody> {
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  bool _isEditingAmount = false;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ApplyLoanController>();
    if (controller.monthlyEmi.value == 0) {
      controller.calculateEmiApi().then((_) {
        if (mounted) {
          _amountController.text =
              controller.loanAmount.value.toInt().toString();
          setState(() {});
        }
      });
    }
    _amountController = TextEditingController(
      text: controller.loanAmount.value.toInt().toString(),
    );
    _amountFocusNode = FocusNode();
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus && _isEditingAmount) {
        _finishEditing(controller);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _finishEditing(ApplyLoanController controller) {
    final clean = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isNotEmpty) {
      final parsed = double.tryParse(clean);
      if (parsed != null) {
        controller.setLoanAmount(parsed);
      }
    }
    _amountFocusNode.unfocus();
    setState(() {
      _isEditingAmount = false;
      _amountController.text = controller.loanAmount.value.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return GestureDetector(
      onTap: () {
        if (_isEditingAmount) {
          _finishEditing(controller);
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        color: AppColors.indigoTint,
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
                            color: AppColors.indigo,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            controller.selectedLoanType.value,
                            style: const TextStyle(
                              color: AppColors.indigo,
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
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Interactive Loan Amount Card
                  _buildLoanAmountCard(controller),
                  const SizedBox(height: 20),

                  // 2. Estimated EMI Hero Banner Card
                  _buildEmiBannerCard(controller),
                ],
              ),
            ),
          ),

          // Bottom Actions: "Back" & "Next step ->"
          _buildBottomButtons(context, controller),
        ],
      ),
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
        border: Border.all(color: AppColors.line, width: 1.2),
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
              color: AppColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          // Big Amount Display / In-Place Inline Editable Input (No bottom line)
          _isEditingAmount
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '₹',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                          if (clean.isNotEmpty) {
                            final parsed = double.tryParse(clean);
                            if (parsed != null) {
                              controller.setLoanAmount(parsed);
                            }
                          }
                        },
                        onSubmitted: (_) {
                          _finishEditing(controller);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _finishEditing(controller);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.indigo,
                            width: 1.4,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.indigo,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditingAmount = true;
                      _amountController.text = controller.loanAmount.value.toInt().toString();
                      _amountFocusNode.requestFocus();
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          controller.formatIndianCurrency(controller.loanAmount.value),
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 12),

          // Custom Styled Slider (continuous, allows any entered amount)
          Obx(
            () => SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: AppColors.amber,
                inactiveTrackColor: AppColors.line,
                thumbColor: AppColors.amber,
                overlayColor: AppColors.amber.withValues(alpha: 0.2),
                thumbShape: const _DualColorThumbShape(
                  radius: 12,
                  innerRadius: 6,
                  outerColor: AppColors.amber,
                  innerColor: AppColors.navy,
                ),
              ),
              child: controller.maxLoanAmount.value > controller.minLoanAmount.value
                  ? Slider(
                      value: controller.loanAmount.value.clamp(
                        controller.minLoanAmount.value,
                        controller.maxLoanAmount.value,
                      ),
                      min: controller.minLoanAmount.value,
                      max: controller.maxLoanAmount.value,
                      onChanged: (val) {
                        controller.setLoanAmount(val);
                        if (_isEditingAmount) {
                          _amountController.text = val.toInt().toString();
                        }
                      },
                    )
                  : const SizedBox(
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          // Dynamic Min & Max range markers from dashboard API
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.formatIndianCurrency(controller.minLoanAmount.value),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    controller.formatIndianCurrency(controller.maxLoanAmount.value),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
            onTap: () {
              controller.setLoanAmount(amount);
              if (_isEditingAmount) {
                _amountController.text = amount.toInt().toString();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.navy
                    : AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
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

  /// Royal blue banner showing live calculated EMI & Total Interest from API
  Widget _buildEmiBannerCard(ApplyLoanController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.3),
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
                          color: AppColors.secondaryTextColor2,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => controller.isCalculatingEmi.value
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.amber,
                                  ),
                                ),
                              )
                            : Text(
                                controller.formatIndianCurrency(
                                  controller.monthlyEmi.value > 0
                                      ? controller.monthlyEmi.value
                                      : controller.estimatedMonthlyEmi,
                                ),
                                style: const TextStyle(
                                  color: AppColors.amber,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Text(
                          'Indicative at ${controller.apiInterestRate.value > 0 ? controller.apiInterestRate.value : controller.annualInterestRate.value}% p.a. · final rate after review',
                          style: const TextStyle(
                            color: AppColors.secondaryTextColor2,
                            fontSize: 10.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Total interest & Total payable
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total\ninterest',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColors.secondaryTextColor2,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.formatIndianCurrency(
                            controller.totalInterest.value > 0
                                ? controller.totalInterest.value
                                : controller.totalInterestPayable,
                          ),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.totalPayable.value > 0) {
                          return Text(
                            'Payable: ${controller.formatIndianCurrency(controller.totalPayable.value)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: AppColors.secondaryTextColor2,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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
                  color: AppColors.line,
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.textDark,
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
                  backgroundColor: AppColors.navy,
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
                      color: AppColors.amber,
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
      ..color = AppColors.indigo.withValues(alpha: 0.38)
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
