import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/dashboard_controller.dart';
import '../controller/profile_controller.dart';
import 'loan_flow/applicant_details_screen.dart';
import 'document_wallet_screen.dart';
import 'personal_details_screen.dart';
import 'reset_mpin_screen.dart';
import '../services/support_service.dart';

/// Screen displaying user profile, account settings, security, and support (Reference Image 2)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Top Bar: Heading "Profile" + Edit Squircle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _buildTopBar(context),
            ),

            // Scrollable Body
            Expanded(
              child: RefreshIndicator(
                color: AppColors.indigo,
                backgroundColor: Colors.white,
                onRefresh: () =>
                    profileController.fetchApplicantProfile(isRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Banner Bar (Capsule)
                      _buildUserBanner(),

                const SizedBox(height: 22),

                // ACCOUNT Section
                _buildSectionHeader('ACCOUNT'),
                const SizedBox(height: 8),
                _buildAccountCard(context),

                const SizedBox(height: 22),

                // SECURITY Section
                _buildSectionHeader('SECURITY'),
                const SizedBox(height: 8),
                _buildSecurityCard(context),

                const SizedBox(height: 22),

                // HELP & SUPPORT Section
                _buildSectionHeader('HELP & SUPPORT'),
                const SizedBox(height: 8),
                _buildSupportCard(context),

                const SizedBox(height: 24),

                // Log out Button
                _buildLogoutButton(context),

                // App Version at bottom
                Obx(() {
                  final version = profileController.appVersion.value;
                  if (version.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Center(
                      child: Text(
                        version,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with "Profile" heading and edit action squircle
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () async {
            await Get.to(() => const PersonalDetailsScreen(initiallyEditing: true));
            if (Get.isRegistered<ProfileController>()) {
              Get.find<ProfileController>().fetchApplicantProfile(isRefresh: true);
            }
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
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  /// Rich User profile card displaying avatar, name, verified badge, phone, role & email
  Widget _buildUserBanner() {
    final profileController = Get.put(ProfileController());

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.profileCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background cosmic orbit lines
          Positioned.fill(
            child: CustomPaint(
              painter: const _UserCardCosmicPainter(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // AM Golden Avatar Circle with subtle shadow (or picked image)
                Obx(() {
                  final imageBytes = profileController.profileImageBytes.value;
                  final networkPhoto = profileController.photoUrl;

                  Widget avatarContent;
                  if (imageBytes != null) {
                    avatarContent = Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                    );
                  } else if (networkPhoto.isNotEmpty) {
                    avatarContent = Image.network(
                      networkPhoto,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                      errorBuilder: (context, error, stackTrace) => Text(
                        profileController.initials,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  } else {
                    avatarContent = Text(
                      profileController.initials,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  }

                  return Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: avatarContent,
                  );
                }),
                const SizedBox(width: 14),

                // User details: Name, Verified Badge, Phone & Role, Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Obx(
                              () => Text(
                                profileController.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dynamic KYC Status Badge
                          Obx(() {
                            final isDone = profileController.isKycDone.value;
                            final badgeBg = isDone
                                ? AppColors.successGreenBg
                                : AppColors.warningAmberBg;
                            final badgeColor = isDone
                                ? AppColors.successGreen
                                : AppColors.warningAmber;
                            final badgeIcon = isDone
                                ? Icons.check_circle_rounded
                                : Icons.pending_actions_rounded;
                            final badgeText =
                                isDone ? 'KYC Done' : 'KYC Pending';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    badgeIcon,
                                    size: 11,
                                    color: badgeColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Dynamic masked phone and employment role
                      Obx(() {
                        final phone = profileController.maskedPhone;
                        final role = profileController.employmentType;
                        return Row(
                          children: [
                            if (phone.isNotEmpty) ...[
                              Text(
                                phone,
                                style: const TextStyle(
                                  color: AppColors.line,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (phone.isNotEmpty && role.isNotEmpty) ...[
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.indigoTint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                            if (role.isNotEmpty) ...[
                              Text(
                                role,
                                style: const TextStyle(
                                  color: AppColors.line,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 3),
                      Obx(
                        () => Text(
                          profileController.email,
                          style: const TextStyle(
                            color: AppColors.indigoTint,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

  /// Section header text
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

  /// ACCOUNT Section Card
  Widget _buildAccountCard(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.person_outline_rounded,
            iconBg: AppColors.indigoTint,
            iconColor: AppColors.indigo,
            title: 'Personal details',
            onTap: () async {
              await Get.to(() => const PersonalDetailsScreen());
              profileController.fetchApplicantProfile(isRefresh: true);
            },
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          Obx(
            () => _buildActionRow(
              icon: Icons.people_outline_rounded,
              iconBg: AppColors.indigoTint,
              iconColor: AppColors.indigo,
              title: 'Co-applicants',
              trailingText: '${profileController.coApplicantsCount.value} added',
              onTap: () async {
                await Get.to(() => const ApplicantDetailsScreen());
                profileController.fetchApplicantProfile(isRefresh: true);
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          Obx(
            () => _buildActionRow(
              icon: Icons.description_outlined,
              iconBg: AppColors.indigoTint,
              iconColor: AppColors.indigo,
              title: 'Document wallet',
              trailingText: '${profileController.documentsCount.value} files',
              onTap: () {
                if (Get.isRegistered<DashboardController>()) {
                  Get.find<DashboardController>().currentNavIndex.value = 3;
                } else {
                  Get.to(() => const DocumentWalletScreen());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// SECURITY Section Card
  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.lock_outline_rounded,
            iconBg: AppColors.successGreenBg,
            iconColor: AppColors.successGreen,
            title: 'Change MPIN',
            onTap: () => Get.to(() => const ResetMpinScreen()),
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildToggleRow(
            icon: Icons.notifications_none_rounded,
            iconBg: AppColors.successGreenBg,
            iconColor: AppColors.successGreen,
            title: 'Notifications',
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() => notificationsEnabled = val);
            },
          ),
        ],
      ),
    );
  }

  /// HELP & SUPPORT Section Card
  Widget _buildSupportCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.chat_bubble_outline_rounded,
            iconBg: const Color(0xFFE8F7EE),
            iconColor: const Color(0xFF25D366),
            title: 'WhatsApp chat',
            onTap: () => SupportService.openWhatsApp(),
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildActionRow(
            icon: Icons.mail_outline_rounded,
            iconBg: AppColors.indigoTint,
            iconColor: AppColors.navy,
            title: 'Email us',
            onTap: () => SupportService.openEmail(),
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildActionRow(
            icon: Icons.description_outlined,
            iconBg: AppColors.warningAmberBg,
            iconColor: AppColors.warningAmber,
            title: 'Terms & privacy',
            onTap: () {
              Get.snackbar(
                'Terms',
                'Finsphere is RBI-compliant and follows ISO/IEC 27001.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.navy,
                colorText: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Reusable row with icon, title, optional trailing text, and chevron
  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable row with icon, title, and Switch toggle
  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.indigo,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.line,
          ),
        ],
      ),
    );
  }

  /// "Log out" button
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.errorRedBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.errorRed,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirmation dialog before logging out, styled according to the Finsphere app theme
  void _showLogoutDialog(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.16),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge with layered circular styling
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.errorRedBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.errorRedBg,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRedBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.errorRed,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Are you sure you want to log out of Finsphere? You will need your MPIN to sign back in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Row: Cancel and Log out with Loader
              Obx(() {
                final isLoggingOut = profileController.isLoggingOut.value;
                return Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: isLoggingOut ? null : () => Get.back(),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.canvas,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.line),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Log out button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoggingOut
                              ? null
                              : () async {
                                  await profileController.logout();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            disabledBackgroundColor:
                                AppColors.errorRed.withValues(alpha: 0.7),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoggingOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Log out',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

/// Cosmic orbit line painter for the user profile card matching dashboard top card
class _UserCardCosmicPainter extends CustomPainter {
  const _UserCardCosmicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Anchor centered on the right side, matching dashboard CIBIL card
    final anchor = Offset(size.width - 44, size.height * 0.33);

    final orbitPaint = Paint()
      ..color = AppColors.cardOrbitLine.withValues(alpha: 0.28)
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
      orbitPaint..color = AppColors.cardOrbitLine.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
