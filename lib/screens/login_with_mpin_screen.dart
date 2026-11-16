import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/mpin_login_controller.dart';
import '../theme/theme.dart';

/// Screen: Login with MPIN
/// Features proportionally sized top cosmic user hero card with avatar,
/// intersecting animated cosmic orbit rings with moving golden satellite,
/// 4 MPIN indicator dots, and responsive numeric keypad with biometric button.
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
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
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
                  const SizedBox(height: 14),
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
      height: 335,
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
          // Background intersecting cosmic orbit lines with animation
          Positioned.fill(
            child: CustomPaint(
              painter: _TopCardCosmicPainter(
                animation: controller.orbitAnimation,
              ),
            ),
          ),

          // Content Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Avatar circle with initials
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.mpinAvatarBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Obx(() => Text(
                      controller.userInitials.value,
                      style: const TextStyle(
                        color: AppColors.mpinAvatarText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )),
              ),
              const SizedBox(height: 12),

              // "Welcome back" subtitle
              const Text(
                'Welcome back',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),

              // User Name
              Obx(() => Text(
                    controller.userName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  )),
              const SizedBox(height: 16),

              // 4 MPIN indicator dots
              Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      final isFilled = index < controller.mpin.value.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? AppColors.mpinDotFilled
                              : Colors.transparent,
                          border: Border.all(
                            color: isFilled
                                ? AppColors.mpinDotFilled
                                : AppColors.mpinDotEmptyBorder,
                            width: 1.8,
                          ),
                        ),
                      );
                    }),
                  )),
              const SizedBox(height: 10),

              // "Enter your 4-digit MPIN"
              const Text(
                'Enter your 4-digit MPIN',
                style: TextStyle(
                  color: AppColors.inputHintIcon,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
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
          // Backspace Button
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

        // Standard Numeric Key (1-9, 0)
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

  /// Footer Links: "Use mobile number" and "Forgot MPIN?"
  Widget _buildFooterLinks(MpinLoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: controller.useMobileNumber,
          child: const Text(
            'Use mobile number',
            style: TextStyle(
              color: AppColors.numPadKeyText,
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

/// Custom painter for background cosmic orbits and animated celestial satellite in the user card
class _TopCardCosmicPainter extends CustomPainter {
  final Animation<double> animation;

  _TopCardCosmicPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Aligned with the center of the user avatar in the top card
    final center = Offset(size.width * 0.5, size.height * 0.31);
    final progress = animation.value;

    final ringPaint = Paint()
      ..color = AppColors.heroConcentricRings.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final ovalWidth = size.width * 0.88;
    const ovalHeight = 84.0;

    final ovalRect = Rect.fromCenter(
      center: Offset.zero,
      width: ovalWidth,
      height: ovalHeight,
    );

    final path1 = Path()..addOval(ovalRect);
    final path2 = Path()..addOval(ovalRect);

    // Orbit 1: Tilted -18 degrees
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-18 * math.pi / 180);
    canvas.drawPath(path1, ringPaint);

    // Animated Golden satellite dot along Orbit 1
    Offset? headPos;
    for (final metric in path1.computeMetrics()) {
      final total = metric.length;
      final head = progress * total;
      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        headPos = tangent.position;
      }

      // Gentle golden light trail behind the satellite
      final trailLen = total * 0.15;
      final tail = head - trailLen;
      final trailPaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;

      if (tail >= 0) {
        canvas.drawPath(metric.extractPath(tail, head), trailPaint);
      } else {
        canvas.drawPath(metric.extractPath(tail + total, total), trailPaint);
        canvas.drawPath(metric.extractPath(0, head), trailPaint);
      }
    }

    if (headPos != null) {
      // Golden outer glow
      canvas.drawCircle(
        headPos,
        5.0,
        Paint()
          ..color = AppColors.accentGold.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Golden satellite core dot
      canvas.drawCircle(
        headPos,
        3.2,
        Paint()..color = AppColors.accentGold,
      );
    }
    canvas.restore();

    // Orbit 2: Intersecting Orbit tilted +18 degrees (matches Figma 3D celestial sphere)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(18 * math.pi / 180);
    canvas.drawPath(path2, ringPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TopCardCosmicPainter oldDelegate) => false;
}
