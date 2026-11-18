import 'dart:math' as math;
import '../../theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/applicant_details_controller.dart';
import 'add_co_applicant_screen.dart';
import 'application_status_screen.dart';

/// Screen displaying primary applicant & co-applicant details (Reference Image Left Screen)
class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplicantDetailsController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segmented Tabs: "Applicant" | "Co-applicant · 1"
                    _buildSegmentedTabs(controller),

                    const SizedBox(height: 16),

                    // Profile Banner Card with cosmic background
                    _buildProfileBanner(controller),

                    const SizedBox(height: 20),

                    // Verification Section
                    _buildSectionHeader('VERIFICATION'),
                    const SizedBox(height: 8),
                    _buildVerificationCard(controller),

                    const SizedBox(height: 20),

                    // Personal & Contact Section
                    _buildSectionHeader('PERSONAL & CONTACT'),
                    const SizedBox(height: 8),
                    _buildPersonalContactCard(controller),

                    const SizedBox(height: 20),

                    // "+ Add another co-applicant" Button
                    _buildAddCoApplicantButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom "Submit application →" Button
            _buildBottomSection(context),
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
          GestureDetector(
            onTap: () => Get.back(),
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
          const Expanded(
            child: Center(
              child: Text(
                'Applicant details',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Segmented pills: "Applicant" and "Co-applicant · 1"
  Widget _buildSegmentedTabs(ApplicantDetailsController controller) {
    return Obx(() {
      final selectedTab = controller.selectedTabIndex.value;
      final coAppCount = controller.coApplicants.length;

      return Container(
        height: 44,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            // Left Pill: Applicant
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedTab == 0 ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    'Applicant',
                    style: TextStyle(
                      color: selectedTab == 0 ? Colors.white : AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Right Pill: Co-applicant · X
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(1),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedTab == 1 ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    'Co-applicant · $coAppCount',
                    style: TextStyle(
                      color: selectedTab == 1 ? Colors.white : AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Profile Banner Card with cosmic orbit curves and avatar
  Widget _buildProfileBanner(ApplicantDetailsController controller) {
    return Obx(() {
      final isPrimary = controller.selectedTabIndex.value == 0;
      final coApp = controller.coApplicants.isNotEmpty
          ? controller.coApplicants.first
          : null;

      final avatarInitials = isPrimary ? 'AM' : (coApp != null ? 'SM' : 'CA');
      final name = isPrimary ? 'Aarav Mehta' : (coApp?.name ?? 'Saanvi Mehta');
      final subtitle = isPrimary
          ? 'Primary applicant · Salaried'
          : 'Co-applicant · ${coApp?.relationship ?? "Spouse"}';

      return Container(
        height: 84,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: AppColors.dashboardCardGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGradientEnd.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background cosmic curve
            Positioned.fill(
              child: CustomPaint(
                painter: const _BannerCosmicPainter(),
              ),
            ),

            // Avatar & Name content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Circular Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatarInitials,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Role Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
    });
  }

  /// Small section heading label
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Verification card container with Aadhaar, PAN, and Mobile rows
  Widget _buildVerificationCard(ApplicantDetailsController controller) {
    return Obx(() {
      final isPrimary = controller.selectedTabIndex.value == 0;
      final coApp = controller.coApplicants.isNotEmpty
          ? controller.coApplicants.first
          : null;

      final aadhaarSub = isPrimary ? 'Identity verified' : 'Link sent to verify';
      final panSub = isPrimary ? 'Tax ID verified' : 'Pending verification';
      final mobileSub = isPrimary ? '+91 98765 •••10' : (coApp?.mobileNumber ?? '+91 98765 43210');
      final badgeText = isPrimary ? 'Verified' : 'Pending';
      final badgeBg = isPrimary ? AppColors.successGreenBg : AppColors.indigoTint;
      final badgeColor = isPrimary ? AppColors.successGreen : AppColors.indigo;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            _buildVerificationRow(
              icon: Icons.shield_outlined,
              title: 'Aadhaar',
              subtitle: aadhaarSub,
              badgeText: badgeText,
              badgeBg: badgeBg,
              badgeColor: badgeColor,
            ),
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildVerificationRow(
              icon: Icons.credit_card_rounded,
              title: 'PAN card',
              subtitle: panSub,
              badgeText: badgeText,
              badgeBg: badgeBg,
              badgeColor: badgeColor,
            ),
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildVerificationRow(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Mobile OTP',
              subtitle: mobileSub,
              badgeText: badgeText,
              badgeBg: badgeBg,
              badgeColor: badgeColor,
            ),
          ],
        ),
      );
    });
  }

  /// Single verification list tile
  Widget _buildVerificationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Green Squircle Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Personal & Contact info card container
  Widget _buildPersonalContactCard(ApplicantDetailsController controller) {
    return Obx(() {
      final isPrimary = controller.selectedTabIndex.value == 0;
      final coApp = controller.coApplicants.isNotEmpty
          ? controller.coApplicants.first
          : null;

      final name = isPrimary ? 'Aarav Mehta' : (coApp?.name ?? 'Saanvi Mehta');
      final dobGender = isPrimary ? '15 Aug 1993 · Male' : '${coApp?.dob ?? "22 Oct 1995"} · Female';
      final email = isPrimary ? 'aarav@example.com' : 'saanvi@example.com';
      final address = isPrimary
          ? '123, MG Road, Bengaluru, Karnataka – 560001'
          : 'Same as primary applicant';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            _buildContactRow(
              icon: Icons.person_outline_rounded,
              label: 'Full name',
              value: name,
            ),
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date of birth · Gender',
              value: dobGender,
            ),
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.mail_outline_rounded,
              label: 'Email',
              value: email,
            ),
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: address,
            ),
          ],
        ),
      );
    });
  }

  /// Single personal & contact list tile
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lavender Squircle Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.indigoTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.indigo,
            ),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "+ Add another co-applicant" outline button
  Widget _buildAddCoApplicantButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const AddCoApplicantScreen()),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.indigoTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.indigoTint,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_rounded,
              color: AppColors.indigo,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              '+ Add another co-applicant',
              style: TextStyle(
                color: AppColors.indigo,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Section: "Submit application →" button
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.lightBackground,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Application Status Screen
            Get.to(() => const ApplicationStatusScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Submit application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.amber,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cosmic orbit line painter for profile banner card
class _BannerCosmicPainter extends CustomPainter {
  const _BannerCosmicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Anchor centered on the right side, matching dashboard CIBIL card
    final anchor = Offset(size.width - 44, size.height * 0.33);

    final orbitPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    // 1. Concentric guide rings (same as dashboard top card)
    canvas.drawCircle(anchor, 58, orbitPaint);
    canvas.drawCircle(anchor, 105, orbitPaint);

    // 2. Wide flat tilted cosmic orbit ellipse
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(-28 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 270,
        height: 75,
      ),
      orbitPaint..color = AppColors.indigo.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
