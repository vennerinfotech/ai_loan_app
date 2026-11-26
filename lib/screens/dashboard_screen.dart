import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../models/dashboard_response_model.dart';
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
        child: Obx(() {
          final isLoading = controller.isLoading.value &&
              controller.dashboardData.value == null;

          if (isLoading) {
            return _buildGreySkeletonLoader();
          }

          return Column(
            children: [
              // 1. Sticky Header (Fixed at top, not scrollable, search icon removed)
              _buildStickyTopHeader(controller),

              // 2. Scrollable Dashboard Body (Compressive / compact layout with pull-to-refresh)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchDashboardData,
                  color: AppColors.primaryPurple,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CIBIL Score Card (Compact)
                        _buildCibilScoreCard(controller),
                        const SizedBox(height: 12),

                        // Complete your KYC Card (Compact)
                        _buildKycStatusCard(controller),
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
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Pure neutral grey Skeletonizer loader matching dashboard layout (no colorful cards)
  Widget _buildGreySkeletonLoader() {
    const greyBone = Color(0xFFE5E7EB);
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE5E7EB),
        highlightColor: Color(0xFFF3F4F6),
      ),
      child: Column(
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                const Bone.circle(size: 38),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(words: 2, fontSize: 11),
                      SizedBox(height: 5),
                      Bone.text(words: 2, fontSize: 16),
                    ],
                  ),
                ),
                const Bone.circle(size: 38),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CIBIL Card grey skeleton
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: greyBone),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Bone.text(words: 2, fontSize: 12),
                                  SizedBox(height: 8),
                                  Bone.text(words: 1, fontSize: 28),
                                  SizedBox(height: 8),
                                  Bone.text(words: 3, fontSize: 11),
                                ],
                              ),
                            ),
                            Bone.circle(size: 54),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Bone.button(
                                height: 38,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Bone.button(
                                height: 38,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // KYC Status Card grey skeleton
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: greyBone),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Bone.circle(size: 36),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Bone.text(words: 2, fontSize: 14),
                                  SizedBox(height: 6),
                                  Bone.text(words: 3, fontSize: 11),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Bone.text(words: 4, fontSize: 11),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2x2 Feature Grid grey skeleton
                  for (int row = 0; row < 2; row++) ...[
                    Row(
                      children: [
                        for (int col = 0; col < 2; col++) ...[
                          if (col > 0) const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 114,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: greyBone),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Bone.circle(size: 32),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Bone.text(words: 2, fontSize: 13),
                                      SizedBox(height: 5),
                                      Bone.text(words: 3, fontSize: 10),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (row == 0) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),

                  // Active Application grey skeleton
                  const Bone.text(words: 2, fontSize: 14),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: greyBone),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone.text(words: 3, fontSize: 14),
                        SizedBox(height: 8),
                        Bone.text(words: 4, fontSize: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky top user bar: Avatar, Greeting, User Name, Notification icon
  Widget _buildStickyTopHeader(DashboardController controller,
      {bool isLoading = false}) {
    return Container(
      color: AppColors.lightBackground,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Avatar (Dynamic)
          Obx(() {
            final photoUrl = controller.dashboardData.value?.user?.profilePhotoUrl;
            final initials = controller.userInitials.value;
            return Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.mpinAvatarBackground,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initials.isNotEmpty ? initials : '',
                          style: const TextStyle(
                            color: AppColors.mpinAvatarText,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: initials.isNotEmpty
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: AppColors.mpinAvatarText,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: AppColors.mpinAvatarText,
                              size: 20,
                            ),
                    ),
            );
          }),
          const SizedBox(width: 10),

          // Greeting & Name (Dynamic, zero static text)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final g = controller.greeting.value;
                  if (g.isEmpty && !isLoading) return const SizedBox.shrink();
                  return Text(
                    g.isNotEmpty ? g.toLowerCase() : 'good morning',
                    style: const TextStyle(
                      color: AppColors.textDarkSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
                Obx(
                  () => Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : (isLoading ? 'Loading User' : ''),
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
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.3),
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
                              color: AppColors.indigoTint,
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
                                  controller.cibilScore.value > 0
                                      ? '${controller.cibilScore.value}'
                                      : '--',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Obx(() {
                                final status = controller.cibilStatus.value;
                                if (status.isEmpty) return const SizedBox.shrink();
                                final cs = controller.dashboardData.value?.creditScore;
                                Color tagColor = AppColors.cibilGoodTagText;
                                Color tagBg = AppColors.cibilGoodTagBg;
                                if (cs?.bandColor != null) {
                                  final parsed = _parseHexColor(cs!.bandColor);
                                  tagColor = parsed;
                                  tagBg = parsed.withValues(alpha: 0.15);
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: tagBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: tagColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Obx(() {
                            final isEst = controller.dashboardData.value?.creditScore?.isEstimated == true;
                            return Text(
                              isEst ? 'Estimated score · updated live' : 'Credit score · free refresh',
                              style: const TextStyle(
                                color: AppColors.indigoTint,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // CIBIL Gauge Ring (Reduced size 54x54)
                    Obx(() {
                      final cs = controller.dashboardData.value?.creditScore;
                      double progress = 0.0;
                      if (cs != null) {
                        if (cs.gaugePercent != null) {
                          progress = cs.gaugePercent! / 100.0;
                        } else if (cs.score != null && cs.maxScore != null && cs.maxScore! > 0) {
                          progress = cs.score! / cs.maxScore!;
                        }
                      }
                      return SizedBox(
                        width: 54,
                        height: 54,
                        child: CustomPaint(
                          painter: _CibilRingPainter(progress: progress.clamp(0.0, 1.0)),
                        ),
                      );
                    }),
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
                                      color: AppColors.navy,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.navy,
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
                    color: AppColors.kycNotLinkedCircleBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.warningAmber,
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
                backgroundColor: AppColors.indigo,
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

            // Card 2: AI eligibility (Golden Amber - navigation removed per request)
            Expanded(
              child: _buildGridCard(
                backgroundColor: AppColors.accentGold,
                iconBg: AppColors.navy.withValues(alpha: 0.12),
                icon: Icons.auto_awesome_rounded,
                iconColor: AppColors.navy,
                title: 'AI eligibility',
                titleColor: AppColors.navy,
                subtitle: 'Check before you apply',
                subtitleColor: AppColors.navy.withValues(alpha: 0.8),
                onTap: () {},
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
                iconBg: AppColors.successGreenBg,
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.successGreen,
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
                iconBg: AppColors.kycNotLinkedCircleBg,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.warningAmber,
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

  /// Active Application Section: Strictly dynamic, zero static fallback data.
  /// Hidden when there is no active loan application (shows skeleton bone while loading).
  Widget _buildActiveApplicationSection(DashboardController controller,
      {bool isLoading = false}) {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active application',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dashboardCardBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan application status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Loading application progress details...',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Obx(() {
      final activeApps = controller.dashboardData.value?.activeLoanApplications;
      final appStatus = controller.dashboardData.value?.applicationStatus;
      final latestLead = appStatus?.latestLead;
      final isSubmitted = appStatus?.isSubmitted == true;

      final items = activeApps?.items ?? [];

      // If user hasn't applied for any loan or there are no active applications, hide section
      if (items.isEmpty && latestLead == null && !isSubmitted) {
        return const SizedBox.shrink();
      }

      // Display up to 2 active applications as requested
      final List<DashboardActiveLoanItem> displayItems = items.isNotEmpty
          ? items.take(2).toList()
          : [
              if (latestLead != null)
                DashboardActiveLoanItem(
                  id: latestLead.id,
                  loanType: latestLead.loanType,
                  loanAmount: latestLead.loanAmount,
                  employmentType: latestLead.employmentType,
                  status: latestLead.status,
                  statusLabel: latestLead.status != null
                      ? '${latestLead.status![0].toUpperCase()}${latestLead.status!.substring(1)}'
                      : 'Lead',
                  createdAt: latestLead.createdAt,
                ),
            ];

      final sectionTitle = activeApps?.title ??
          (displayItems.length > 1 ? 'Active applications' : 'Active application');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () => controller.onDashboardOptionSelected('All Applications'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          for (int i = 0; i < displayItems.length; i++)
            _buildActiveAppItemCard(
              controller: controller,
              item: displayItems[i],
              appStatus: appStatus,
            ),
        ],
      );
    });
  }

  /// Single Active Application Item Card
  Widget _buildActiveAppItemCard({
    required DashboardController controller,
    required DashboardActiveLoanItem item,
    required DashboardApplicationStatus? appStatus,
  }) {
    final loanTitle = item.loanType ?? 'Loan application';
    final amountFormatted = item.loanAmount != null
        ? NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(item.loanAmount)
        : '';
    final loanSubtitle = [
      if (amountFormatted.isNotEmpty) amountFormatted,
      if (item.employmentType?.isNotEmpty == true) item.employmentType!,
      if (item.bankName?.isNotEmpty == true) item.bankName!,
    ].join(' • ');

    final statusText = item.statusLabel ??
        item.status ??
        (appStatus?.isSubmitted == true ? 'Submitted' : 'In review');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => controller.onDashboardOptionSelected('All Applications'),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.indigoTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        _getLoanTypeIcon(item.loanType),
                        color: _getLoanTypeColor(item.loanType),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loanTitle,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (loanSubtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            loanSubtitle,
                            style: const TextStyle(
                              color: AppColors.textDarkSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(statusText),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: _getStatusTextColor(statusText),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              if (item.createdAt != null || item.id != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.createdAt != null)
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            _formatShortDate(item.createdAt!),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    if (item.id != null)
                      Text(
                        'Ref: #${item.id}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Icon mapping for loan types
  IconData _getLoanTypeIcon(String? loanType) {
    final type = loanType?.toLowerCase() ?? '';
    if (type.contains('home')) return Icons.home_outlined;
    if (type.contains('business')) return Icons.business_center_outlined;
    if (type.contains('education')) return Icons.school_outlined;
    if (type.contains('vehicle') || type.contains('car') || type.contains('auto')) {
      return Icons.directions_car_outlined;
    }
    if (type.contains('personal')) return Icons.person_outline;
    if (type.contains('lap') || type.contains('property')) return Icons.apartment_outlined;
    return Icons.account_balance_outlined;
  }

  Color _getLoanTypeColor(String? loanType) {
    final type = loanType?.toLowerCase() ?? '';
    if (type.contains('home')) return AppColors.primaryPurple;
    if (type.contains('business')) return AppColors.navy;
    if (type.contains('education')) return AppColors.indigo;
    return AppColors.primaryPurple;
  }

  Color _getStatusBgColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('approved') || s.contains('disbursed') || s.contains('completed')) {
      return AppColors.successGreenBg;
    }
    if (s.contains('reject')) {
      return AppColors.errorRedBg;
    }
    return AppColors.reviewPillBg;
  }

  Color _getStatusTextColor(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('approved') || s.contains('disbursed') || s.contains('completed')) {
      return AppColors.successGreen;
    }
    if (s.contains('reject')) {
      return AppColors.errorRed;
    }
    return AppColors.reviewPillText;
  }

  String _formatShortDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return rawDate;
    }
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
      ..color = AppColors.cardOrbitLine.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    // 1. Concentric guide rings centered on the gauge (outer 155 ring removed per request)
    canvas.drawCircle(anchor, 58, orbitPaint);
    canvas.drawCircle(anchor, 105, orbitPaint);

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
      orbitPaint..color = AppColors.cardOrbitLine.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper to parse hex color strings like "#059669" or "ef4444"
Color _parseHexColor(String? hexString, {Color fallback = const Color(0xFF10B981)}) {
  if (hexString == null || hexString.trim().isEmpty) return fallback;
  final cleanHex = hexString.replaceAll('#', '').trim();
  final buffer = StringBuffer();
  if (cleanHex.length == 6) {
    buffer.write('ff');
  }
  buffer.write(cleanHex);
  final val = int.tryParse(buffer.toString(), radix: 16);
  return val != null ? Color(val) : fallback;
}
