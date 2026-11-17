import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/dashboard_controller.dart';

/// Compact, compressed Dashboard screen with sticky non-scrollable header.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Sticky Header (Fixed at top, not scrollable, search icon removed)
            _buildStickyTopHeader(controller),

            // 2. Scrollable Dashboard Body (Compressive / compact layout)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CIBIL Score Card (Compact)
                    _buildCibilScoreCard(controller),
                    const SizedBox(height: 12),

                    // Complete your KYC Card (Compact)
                    Obx(() => _buildKycStatusCard(controller)),
                    const SizedBox(height: 12),

                    // 2x2 Feature Grid (Compact)
                    _buildFeatureGrid(controller),
                    const SizedBox(height: 14),

                    // Active Application Section (Compact)
                    _buildActiveApplicationSection(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sticky top user bar: Avatar, "good morning Aarav", Notification icon (Search bar removed)
  Widget _buildStickyTopHeader(DashboardController controller) {
    return Container(
      color: AppColors.lightBackground,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Avatar AM (Reduced size 38x38)
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.mpinAvatarBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Obx(
                () => Text(
                  controller.userInitials.value,
                  style: const TextStyle(
                    color: AppColors.mpinAvatarText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Greeting & Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'good morning',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification Action Button with Badge (Search bar removed)
          GestureDetector(
            onTap: () => controller.onDashboardOptionSelected('Notifications'),
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textDark,
                      size: 19,
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact CIBIL score card with reduced radius and tighter padding
  Widget _buildCibilScoreCard(DashboardController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3835A8),
            Color(0xFF24227E),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24227E).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _CibilCosmicOrbitPainter(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your CIBIL score',
                            style: TextStyle(
                              color: Color(0xFFC7CAE8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Obx(
                                () => Text(
                                  '${controller.cibilScore.value}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cibilGoodTagBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Obx(
                                  () => Text(
                                    controller.cibilStatus.value,
                                    style: const TextStyle(
                                      color: AppColors.cibilGoodTagText,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Updated 12 Nov • Free monthly refresh',
                            style: TextStyle(
                              color: Color(0xFF9EA3D1),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CIBIL Gauge Ring (Reduced size 54x54)
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CustomPaint(
                        painter: _CibilRingPainter(progress: 762 / 900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom button row inside card (Reduced height 38, radius 10)
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: GestureDetector(
                        onTap: () => controller.onDashboardOptionSelected('Apply for loan'),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Apply for a loan',
                                    style: TextStyle(
                                      color: Color(0xFF212074),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF212074),
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () => controller.onDashboardOptionSelected('CIBIL Report'),
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact Complete your KYC Card with reduced radius & padding
  Widget _buildKycStatusCard(DashboardController controller) {
    final isAadhaarDone = controller.isAadhaarCompleted;
    final isPanDone = controller.isPanCompleted;

    String stepsText = '1 of 3 steps done • ~3 min left';
    if (isAadhaarDone && isPanDone) {
      stepsText = '3 of 3 steps done • All verified ✓';
    } else if (isAadhaarDone) {
      stepsText = '2 of 3 steps done • ~1 min left';
    }

    return GestureDetector(
      onTap: () => controller.onDashboardOptionSelected('Complete your KYC'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Soft orange icon box (Reduced size 36x36)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFF97316),
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete your KYC',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        stepsText,
                        style: const TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDarkSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 3-step progress bar row
            Row(
              children: [
                // Step 1: Mobile
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Mobile ✓',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Step 2: Aadhaar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: isAadhaarDone ? AppColors.primaryPurple : AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAadhaarDone ? 'Aadhaar ✓' : 'Aadhaar',
                        style: TextStyle(
                          color: isAadhaarDone ? AppColors.primaryPurple : AppColors.textDarkSecondary,
                          fontSize: 10.5,
                          fontWeight: isAadhaarDone ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Step 3: PAN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: isPanDone ? AppColors.primaryPurple : AppColors.indicatorInactive,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPanDone ? 'PAN ✓' : 'PAN',
                        style: TextStyle(
                          color: isPanDone ? AppColors.primaryPurple : AppColors.textDarkSecondary,
                          fontSize: 10.5,
                          fontWeight: isPanDone ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact 2x2 Feature Grid: Reduced height to 112, radius to 14
  Widget _buildFeatureGrid(DashboardController controller) {
    return Column(
      children: [
        Row(
          children: [
            // Card 1: Apply for loan (Indigo)
            Expanded(
              child: _buildGridCard(
                backgroundColor: const Color(0xFF524FBA),
                iconBg: Colors.white.withValues(alpha: 0.18),
                icon: Icons.add_rounded,
                iconColor: Colors.white,
                title: 'Apply for loan',
                titleColor: Colors.white,
                subtitle: 'Home, business, personal...',
                subtitleColor: Colors.white.withValues(alpha: 0.8),
                onTap: () => controller.onDashboardOptionSelected('Apply for loan'),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: AI eligibility (Golden Amber)
            Expanded(
              child: _buildGridCard(
                backgroundColor: AppColors.accentGold,
                iconBg: const Color(0xFF212074).withValues(alpha: 0.12),
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF212074),
                title: 'AI eligibility',
                titleColor: const Color(0xFF212074),
                subtitle: 'Check before you apply',
                subtitleColor: const Color(0xFF212074).withValues(alpha: 0.8),
                onTap: () => controller.onDashboardOptionSelected('AI eligibility'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 3: Loan updates (White with green icon)
            Expanded(
              child: _buildGridCard(
                backgroundColor: Colors.white,
                iconBg: const Color(0xFFE8F7ED),
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF16A34A),
                title: 'Loan updates',
                titleColor: AppColors.textDark,
                subtitle: 'Track your application',
                subtitleColor: AppColors.textDarkSecondary,
                hasBorder: true,
                onTap: () => controller.onDashboardOptionSelected('Loan updates'),
              ),
            ),
            const SizedBox(width: 10),

            // Card 4: Other loans (White with peach icon)
            Expanded(
              child: _buildGridCard(
                backgroundColor: Colors.white,
                iconBg: const Color(0xFFFFF2E6),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFF97316),
                title: 'Other loans',
                titleColor: AppColors.textDark,
                subtitle: 'Track existing EMIs',
                subtitleColor: AppColors.textDarkSecondary,
                hasBorder: true,
                onTap: () => controller.onDashboardOptionSelected('Other loans'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required Color backgroundColor,
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 114,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: hasBorder ? Border.all(color: AppColors.dashboardCardBorder, width: 1.2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 17),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Active Application Section: Radius 14, padding 12
  Widget _buildActiveApplicationSection(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active application',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => controller.onDashboardOptionSelected('All Applications'),
              child: const Text(
                'View all',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => controller.onDashboardOptionSelected('Home loan Application'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Home icon box (Reduced size 36x36)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF1FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_outlined,
                          color: AppColors.primaryPurple,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home loan',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            '₹14,50,000 • 15 years',
                            style: TextStyle(
                              color: AppColors.textDarkSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "In review" status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.reviewPillBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'In review',
                        style: TextStyle(
                          color: AppColors.reviewPillText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Linear Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.48,
                    backgroundColor: Color(0xFFEAEFF8),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 6),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step 3 of 6 • Credit report',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    Text(
                      '48%',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular gauge painter for CIBIL score (Compact)
class _CibilRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _CibilRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill arc in yellow
    final arcPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CibilRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Cosmic orbit line painter for CIBIL card background matching reference design
class _CibilCosmicOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Anchor centered directly on the CIBIL score gauge
    final anchor = Offset(size.width - 44, size.height * 0.33);

    final orbitPaint = Paint()
      ..color = const Color(0xFF8B88EF).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    final faintPaint = Paint()
      ..color = const Color(0xFF8B88EF).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Concentric guide rings centered on the gauge
    canvas.drawCircle(anchor, 58, orbitPaint);
    canvas.drawCircle(anchor, 105, orbitPaint);
    canvas.drawCircle(anchor, 155, faintPaint);

    // 2. Wide flat tilted cosmic orbit ellipse passing through the gauge
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(-28 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 270,
        height: 75,
      ),
      orbitPaint..color = const Color(0xFF8B88EF).withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
