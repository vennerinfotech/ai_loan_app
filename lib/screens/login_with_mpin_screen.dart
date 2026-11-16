import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/mpin_login_controller.dart';
import '../theme/theme.dart';

/// Screen: Login with MPIN
/// Features top cosmic user hero card with avatar, 4 MPIN indicator dots,
/// and responsive numeric keypad with integrated biometric fingerprint button.
/// Exact pixel-perfect match to Figma reference design.
class LoginWithMpinScreen extends StatelessWidget {
  const LoginWithMpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MpinLoginController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Hero Card (User Avatar + Welcome back + Name + 4 MPIN dots)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildTopUserCard(controller),
            ),

            const Spacer(),

            // Numeric Keypad with Biometrics + Footer Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNumberPad(controller),
                  const SizedBox(height: 20),
                  _buildFooterLinks(controller),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top User Hero Card with avatar, cosmic lines, user name, and 4 MPIN dots
  Widget _buildTopUserCard(MpinLoginController controller) {
    return Container(
      width: double.infinity,
      height: 275,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.heroCardGradientTop,
            AppColors.heroCardGradientBottom,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle cosmic orbit lines
          Positioned.fill(
            child: CustomPaint(
              painter: _TopCardCosmicPainter(),
            ),
          ),

          // Content Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar circle with initials
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.mpinAvatarBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Obx(() => Text(
                      controller.userInitials.value,
                      style: const TextStyle(
                        color: AppColors.mpinAvatarText,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )),
              ),
              const SizedBox(height: 10),

              // "Welcome back" subtitle
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // User Name
              Obx(() => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  )),
              const SizedBox(height: 14),

              // 4 MPIN indicator dots
              Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      final isFilled = index < controller.mpin.value.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? AppColors.mpinDotFilled
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilled
                                ? AppColors.mpinDotFilled
                                : AppColors.mpinDotEmptyBorder,
                            width: 1.6,
                          ),
                        ),
                      );
                    }),
                  )),
              const SizedBox(height: 8),

              // "Enter your 4-digit MPIN"
              const Text(
                'Enter your 4-digit MPIN',
                style: TextStyle(
                  color: AppColors.inputHintIcon,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3x4 Number keypad with biometric fingerprint and backspace
  Widget _buildNumberPad(MpinLoginController controller) {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      'bio', '0', '⌫',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];

        final isBio = key == 'bio';
        final isBackspace = key == '⌫';

        if (isBio) {
          // Biometric Fingerprint Button
          return GestureDetector(
            onTap: controller.triggerBiometric,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.mpinBiometricBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.fingerprint_rounded,
                color: AppColors.mpinBiometricIcon,
                size: 26,
              ),
            ),
          );
        }

        if (isBackspace) {
          // Backspace button
          return GestureDetector(
            onTap: controller.deleteDigit,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.numPadActionKeyBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_outlined,
                color: AppColors.numPadKeyText,
                size: 22,
              ),
            ),
          );
        }

        // Standard numeric key (1-9, 0)
        return GestureDetector(
          onTap: () => controller.enterDigit(key),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.numPadKeyBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.numPadKeyBorder,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: const TextStyle(
                color: AppColors.numPadKeyText,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Footer links: "Use mobile number" & "Forgot MPIN?"
  Widget _buildFooterLinks(MpinLoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: controller.useMobileNumber,
          child: const Text(
            'Use mobile number',
            style: TextStyle(
              color: AppColors.inputText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: controller.forgotMpin,
          child: const Text(
            'Forgot MPIN?',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for background cosmic orbits in the user card
class _TopCardCosmicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.40);

    // Orbit ellipse
    final orbitPaint = Paint()
      ..color = AppColors.heroConcentricRings.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-20 * math.pi / 180);

    final oval = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.88,
      height: size.height * 0.48,
    );
    canvas.drawOval(oval, orbitPaint);

    // Golden accent planet dot on the orbit
    final dotPaint = Paint()..color = AppColors.accentGold;
    canvas.drawCircle(Offset(size.width * 0.38, -size.height * 0.10), 3.5, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
