import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/forgot_mpin_controller.dart';
import '../theme/theme.dart';

/// Screen: Forgot MPIN
/// Allows users to recover/reset their MPIN via registered mobile number OTP.
/// Features top back button, cosmic key badge with animated golden orbit,
/// security notice card, "Send OTP →" CTA button, and "Back to login" link.
/// Pixel-perfect match to Figma reference design.
class ForgotMpinScreen extends StatelessWidget {
  const ForgotMpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotMpinController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Back Button Squircle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GestureDetector(
                onTap: controller.backToLogin,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.backButtonBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.backButtonBorder,
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.backButtonIcon,
                    size: 22,
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Cosmic Golden Key Badge (with animated celestial orbit)
                    _buildCosmicKeyBadge(controller),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Forgot your MPIN?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'No worries. Enter your registered mobile number and we\'ll send a code to reset it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Registered Mobile Number Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered mobile number',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // +91 | 98765 43210 Input Container
                        _buildMobileInputField(controller),
                        const SizedBox(height: 16),

                        // Security notice card
                        _buildSecurityNotice(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Actions: "Send OTP →" + "Back to login"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSendOtpButton(controller),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.backToLogin,
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                        color: AppColors.linkText,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Center badge with deep navy squircle, golden key, and animated golden orbit
  Widget _buildCosmicKeyBadge(ForgotMpinController controller) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFF24227E),
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated cosmic golden orbit ring
          Positioned.fill(
            child: CustomPaint(
              painter: _KeyCosmicOrbitPainter(
                animation: controller.orbitAnimation,
              ),
            ),
          ),

          // Tilted Golden Key icon matching reference
          Transform.rotate(
            angle: -38 * math.pi / 180,
            child: const Icon(
              Icons.key_rounded,
              color: AppColors.accentGold,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Number input field using native TextFormField directly (no wrapped container)
  Widget _buildMobileInputField(ForgotMpinController controller) {
    return TextFormField(
      controller: controller.mobileController,
      focusNode: controller.focusNode,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: '98765 43210',
        hintStyle: const TextStyle(
          color: AppColors.inputLabel,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            const Text(
              '+91',
              style: TextStyle(
                color: AppColors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              height: 24,
              width: 1.2,
              color: AppColors.inputBorder,
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.fieldFocusedBorder,
            width: 1.8,
          ),
        ),
      ),
    );
  }

  /// Security notice box
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.securityBoxBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(
              Icons.shield_outlined,
              color: AppColors.primaryPurple,
              size: 19,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your loan applications and documents stay safe — only the MPIN changes.',
              style: TextStyle(
                color: AppColors.securityText,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Send OTP →" Primary Action Button
  Widget _buildSendOtpButton(ForgotMpinController controller) {
    return Obx(() {
      final canSubmit = controller.canSubmit;

      return InkWell(
        onTap: canSubmit ? controller.sendOtp : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: canSubmit
                ? AppColors.primaryButtonBackground
                : AppColors.primaryButtonBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Send OTP',
                style: TextStyle(
                  color: canSubmit
                      ? AppColors.primaryButtonText
                      : AppColors.primaryButtonText.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.accentGold,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Custom painter for the animated golden orbit ring around the key in the badge
class _KeyCosmicOrbitPainter extends CustomPainter {
  final Animation<double> animation;

  _KeyCosmicOrbitPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final progress = animation.value;

    final ovalWidth = size.width * 0.82;
    const ovalHeight = 44.0;
    const baseAngle = -28 * math.pi / 180;

    final ovalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ovalWidth,
          height: ovalHeight,
        ),
      );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(baseAngle);

    // Faint base orbit track
    final basePaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(ovalPath, basePaint);

    // Luminous moving golden satellite dot with soft glow
    Offset? headPos;
    for (final metric in ovalPath.computeMetrics()) {
      final total = metric.length;
      final head = progress * total;
      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        headPos = tangent.position;
      }

      final trailLen = total * 0.18;
      final tail = head - trailLen;
      final trailPaint = Paint()
        ..color = AppColors.accentGold.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.8;

      if (tail >= 0) {
        canvas.drawPath(metric.extractPath(tail, head), trailPaint);
      } else {
        canvas.drawPath(metric.extractPath(tail + total, total), trailPaint);
        canvas.drawPath(metric.extractPath(0, head), trailPaint);
      }
    }

    if (headPos != null) {
      canvas.drawCircle(
        headPos,
        4.0,
        Paint()
          ..color = AppColors.accentGold.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
      canvas.drawCircle(headPos, 2.2, Paint()..color = AppColors.accentGold);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KeyCosmicOrbitPainter oldDelegate) => false;
}
