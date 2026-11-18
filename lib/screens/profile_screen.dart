import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../services/session_manager.dart';
import '../controller/dashboard_controller.dart';
import '../controller/profile_controller.dart';
import 'loan_flow/applicant_details_screen.dart';
import 'document_wallet_screen.dart';
import 'personal_details_screen.dart';
import 'reset_mpin_screen.dart';
import 'login_with_mpin_screen.dart';
import '../widgets/language_selection_bottom_sheet.dart';

/// Screen displaying user profile, account settings, security, and support (Reference Image 2)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool fingerprintEnabled = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Heading "Profile" + Edit Squircle
              _buildTopBar(context),

              const SizedBox(height: 16),

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
            ],
          ),
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
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.to(() => const PersonalDetailsScreen(initiallyEditing: true));
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF242278), Color(0xFF3835A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF242278).withValues(alpha: 0.22),
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
                  return Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
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
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52,
                          )
                        : Text(
                            profileController.initials,
                            style: const TextStyle(
                              color: Color(0xFF1E2127),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
                          // KYC Done badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Color(0xFF15803D),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'KYC Done',
                                  style: TextStyle(
                                    color: Color(0xFF15803D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            '+91 98765 •••10',
                            style: TextStyle(
                              color: Color(0xFFD6DBED),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text(
                            'Salaried',
                            style: TextStyle(
                              color: Color(0xFFD6DBED),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Obx(
                        () => Text(
                          profileController.email.value,
                          style: const TextStyle(
                            color: Color(0xFF9FA8DA),
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
        color: Color(0xFF64748B),
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  /// ACCOUNT Section Card
  Widget _buildAccountCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.person_outline_rounded,
            iconBg: const Color(0xFFEEF0FD),
            iconColor: const Color(0xFF4340BE),
            title: 'Personal details',
            onTap: () => Get.to(() => const PersonalDetailsScreen()),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildActionRow(
            icon: Icons.people_outline_rounded,
            iconBg: const Color(0xFFEEF0FD),
            iconColor: const Color(0xFF4340BE),
            title: 'Co-applicants',
            trailingText: '1 added',
            onTap: () => Get.to(() => const ApplicantDetailsScreen()),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildActionRow(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFEEF0FD),
            iconColor: const Color(0xFF4340BE),
            title: 'Document wallet',
            trailingText: '4 files',
            onTap: () {
              if (Get.isRegistered<DashboardController>()) {
                Get.find<DashboardController>().currentNavIndex.value = 3;
              } else {
                Get.to(() => const DocumentWalletScreen());
              }
            },
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
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.lock_outline_rounded,
            iconBg: const Color(0xFFE8F8EE),
            iconColor: const Color(0xFF16A34A),
            title: 'Change MPIN',
            onTap: () => Get.to(() => const ResetMpinScreen()),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildToggleRow(
            icon: Icons.fingerprint_rounded,
            iconBg: const Color(0xFFE8F8EE),
            iconColor: const Color(0xFF16A34A),
            title: 'Fingerprint login',
            value: fingerprintEnabled,
            onChanged: (val) {
              setState(() => fingerprintEnabled = val);
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildToggleRow(
            icon: Icons.notifications_none_rounded,
            iconBg: const Color(0xFFE8F8EE),
            iconColor: const Color(0xFF16A34A),
            title: 'Notifications',
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() => notificationsEnabled = val);
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          Obx(() {
            final profileController = Get.isRegistered<ProfileController>()
                ? Get.find<ProfileController>()
                : Get.put(ProfileController());
            return _buildActionRow(
              icon: Icons.translate_rounded,
              iconBg: const Color(0xFFE8F8EE),
              iconColor: const Color(0xFF16A34A),
              title: 'Language',
              trailingText: profileController.selectedLanguage.value,
              onTap: () {
                LanguageSelectionBottomSheet.show(context);
              },
            );
          }),
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
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.chat_bubble_outline_rounded,
            iconBg: const Color(0xFFFFF1E7),
            iconColor: const Color(0xFFEA580C),
            title: 'WhatsApp chat',
            onTap: () {
              Get.snackbar(
                'Support',
                'Connecting to Finsphere WhatsApp support...',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF212074),
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildActionRow(
            icon: Icons.mail_outline_rounded,
            iconBg: const Color(0xFFFFF1E7),
            iconColor: const Color(0xFFEA580C),
            title: 'Email us',
            onTap: () {
              Get.snackbar(
                'Support',
                'Support email: support@finsphere.ai',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF212074),
                colorText: Colors.white,
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
          _buildActionRow(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFFFF1E7),
            iconColor: const Color(0xFFEA580C),
            title: 'Terms & privacy',
            onTap: () {
              Get.snackbar(
                'Terms',
                'Finsphere is RBI-compliant and follows ISO/IEC 27001.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF212074),
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
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
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
            activeTrackColor: const Color(0xFF4340BE),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }

  /// "Log out" pill button
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFFFD5D5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFDC2626),
              size: 17,
            ),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirmation dialog before logging out, styled according to the Finsphere app theme
  void _showLogoutDialog(BuildContext context) {
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
                color: const Color(0xFF212074).withValues(alpha: 0.16),
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
                  color: const Color(0xFFFFF1F1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD5D5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE4E4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFDC2626),
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
                  color: Color(0xFF64748B),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Row: Cancel and Log out
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
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
                        onPressed: () async {
                          Get.back();
                          await SessionManager.clearSession();
                          Get.offAll(() => const LoginWithMpinScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
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
              ),
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
      ..color = const Color(0xFF8B88EF).withValues(alpha: 0.28)
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
      orbitPaint..color = const Color(0xFF8B88EF).withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
