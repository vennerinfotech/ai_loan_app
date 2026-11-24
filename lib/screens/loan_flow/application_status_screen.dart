import 'dart:math' as math;
import '../../theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';
import '../../controller/application_status_controller.dart';
import '../main_nav_screen.dart';

/// Screen: "Application status" (Matching attached reference design)
/// Features:
/// - Deep royal blue hero card with application ID pill
/// - Dynamic user loan amount, verification status segments, and active status step
/// - Intersecting cosmic orbit curves in the top right corner of the card
/// - "Your progress" vertical stepper dynamically driven by GET /loan/status
/// - Bottom support chat button and "Continue application →" CTA
class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applyController = Get.isRegistered<ApplyLoanController>()
        ? Get.find<ApplyLoanController>()
        : Get.put(ApplyLoanController());
    final statusController = Get.isRegistered<ApplicationStatusController>()
        ? Get.find<ApplicationStatusController>()
        : Get.put(ApplicationStatusController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content (Top Hero Card + Stepper)
            Expanded(
              child: RefreshIndicator(
                onRefresh: statusController.fetchLoanStatus,
                color: AppColors.primaryPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Hero Card (Loan Amount, Details, Segments, Cosmic Orbits)
                      _buildTopHeroCard(applyController, statusController),
                      const SizedBox(height: 22),

                      // "Your progress" Header
                      const Text(
                        'Your progress',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vertical Progress Stepper List
                      Obx(() => _buildVerticalStepper(statusController)),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions: Support Icon + "Continue application →"
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  /// Top Deep Royal Blue Hero Card with cosmic orbits in the top-right corner
  Widget _buildTopHeroCard(
    ApplyLoanController applyController,
    ApplicationStatusController statusController,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Cosmic Orbit Curve Painter (Matching reference image)
          const Positioned.fill(
            child: CustomPaint(
              painter: _ApplicationStatusOrbitPainter(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Back button & Application ID badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final userId = statusController.loanStatus.value?.user?.id;
                      final idText = userId != null ? '#FS-2611-00$userId' : '#FS-2611-0042';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          idText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 18),

                // Loan Type · Name Subtitle
                Obx(() {
                  final name = statusController.userName;
                  final loanType = applyController.selectedLoanType.value.isNotEmpty
                      ? applyController.selectedLoanType.value
                      : 'Home Loan';
                  final subtitle = name.isNotEmpty
                      ? '$loanType · $name'
                      : '$loanType · ${applyController.selectedTenureYears.value} years';

                  return Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                const SizedBox(height: 4),

                // Large Amount Display
                Obx(() {
                  final amount = statusController.loanStatus.value?.user?.loanAmount != null
                      ? statusController.formattedLoanAmount
                      : applyController.formatIndianCurrency(applyController.loanAmount.value);

                  return Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  );
                }),
                const SizedBox(height: 18),

                // 6-Segment Horizontal Progress Bar
                Obx(() {
                  final completed = statusController.completedStepsCount;
                  final total = statusController.dynamicSteps.length;
                  return _buildSegmentedProgressBar(
                    activeSegments: completed,
                    totalSegments: total,
                  );
                }),
                const SizedBox(height: 8),

                // Sub-row: "X of Y complete" & "Now: ..."
                Obx(() {
                  final completed = statusController.completedStepsCount;
                  final total = statusController.dynamicSteps.length;
                  final label = statusController.activeStepLabel;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completed of $total complete',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6-Segment Progress Bar
  Widget _buildSegmentedProgressBar({
    required int activeSegments,
    required int totalSegments,
  }) {
    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index < activeSegments;

        return Expanded(
          child: Container(
            height: 4.5,
            margin: EdgeInsets.only(
              right: index < totalSegments - 1 ? 5.0 : 0.0,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.amber
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  /// Vertical Progress Stepper
  Widget _buildVerticalStepper(ApplicationStatusController controller) {
    final steps = controller.dynamicSteps;
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return _buildStepRow(step, isLast);
      }),
    );
  }

  Widget _buildStepRow(ProgressStepItem step, bool isLast) {
    Color lineColor = AppColors.line;
    if (step.status == ApplicationStepStatus.done) {
      lineColor = AppColors.amber;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Step Icon Indicator + Vertical Connecting Line
          Column(
            children: [
              _buildStepIndicator(step.status),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Right Column: Title, Subtitle, and Trailing Status Badge
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            color: step.status == ApplicationStepStatus.pending
                                ? AppColors.muted
                                : AppColors.textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.subtitle,
                          style: TextStyle(
                            color: step.status == ApplicationStepStatus.pending
                                ? AppColors.muted
                                : AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Pill Tag (Done / In progress / Pending)
                  _buildStatusPillBadge(step.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step Circle Indicator
  Widget _buildStepIndicator(ApplicationStepStatus status) {
    switch (status) {
      case ApplicationStepStatus.done:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.navy,
              size: 16,
            ),
          ),
        );
      case ApplicationStepStatus.inProgress:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.indigo,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case ApplicationStepStatus.pending:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.line,
              width: 1.5,
            ),
          ),
        );
    }
  }

  /// Status Pill Badge
  Widget _buildStatusPillBadge(ApplicationStepStatus status) {
    String text = 'Pending';
    Color bgColor = AppColors.canvas;
    Color textColor = AppColors.muted;

    if (status == ApplicationStepStatus.done) {
      text = 'Done';
      bgColor = AppColors.successGreenBg;
      textColor = AppColors.successGreen;
    } else if (status == ApplicationStepStatus.inProgress) {
      text = 'In progress';
      bgColor = AppColors.indigoTint;
      textColor = AppColors.indigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Bottom Actions: Support Icon + "Continue application →"
  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      child: Row(
        children: [
          // Left: Support Chat Button
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'Finsphere Support',
                'Connecting to your loan advisor...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.navy,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              );
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.line,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.textDark,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Right: "Continue application →" CTA Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => const MainNavScreen());
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
                      'Continue application',
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

/// Custom painter for intersecting cosmic orbit curves in the top right corner
/// of the application status card, matching reference image.
class _ApplicationStatusOrbitPainter extends CustomPainter {
  const _ApplicationStatusOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Anchor aligned with the top-right #FS-2611-0042 badge region
    final anchor = Offset(size.width - 65, 38);

    final orbitPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    final faintPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Concentric circular guide rings
    canvas.drawCircle(anchor, 65, orbitPaint);
    canvas.drawCircle(anchor, 115, orbitPaint);
    canvas.drawCircle(anchor, 175, faintPaint);

    // 2. Wide flat tilted cosmic orbit ellipse
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(-25 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 290,
        height: 78,
      ),
      orbitPaint..color = AppColors.indigo.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
