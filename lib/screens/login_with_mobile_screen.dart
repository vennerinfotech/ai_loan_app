import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/login_with_mobile_controller.dart';
import '../theme/theme.dart';

/// Screen: Login with Mobile Number
/// Features top hero card with Saturn logo, "Welcome back.", cosmic orbit,
/// mobile number input, "Get OTP →" button, "Sign in with MPIN", and registration link.
/// Pixel-perfect match to Figma reference design.
class LoginWithMobileScreen extends StatelessWidget {
  const LoginWithMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginWithMobileController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                      child: _buildHeroCard(controller),
                    ),
                    const SizedBox(height: 24),

                    // Mobile Number Input Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mobile number',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // +91 | 98765 43210 Input Container
                          _buildMobileInputField(controller),
                          const SizedBox(height: 18),

                          // "Get OTP →" Primary Button
                          _buildGetOtpButton(controller),
                          const SizedBox(height: 24),

                          // "OR" Divider
                          _buildOrDivider(),
                          const SizedBox(height: 20),

                          // "Sign in with MPIN" Secondary Card Button
                          _buildSignInWithMpinButton(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Footer Link: "New to Finsphere? Create an account"
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: _buildBottomFooter(controller),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Hero Card with Saturn branding, Welcome back text, and cosmic orbit
  Widget _buildHeroCard(LoginWithMobileController controller) {
    return Container(
      width: double.infinity,
      height: 245,
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
        children: [
          // Background celestial globe, concentric ripple rings, and animated golden orbit
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginHeroOrbitPainter(
                animation: controller.orbitAnimation,
              ),
            ),
          ),

          // Content Layer
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header: Saturn Logo + "Finsphere AI"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSaturnIcon(),
                    const SizedBox(width: 8),
                    const Text(
                      'Finsphere AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Heading: "Welcome\nback."
                const Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '.',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Sign in to continue your application.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small Saturn Logo icon
  Widget _buildSaturnIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: -30 * math.pi / 180,
            child: Container(
              width: 17,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.elliptical(8.5, 3.5)),
                border: Border.all(
                  color: AppColors.saturnRingColor,
                  width: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Number input field using native TextFormField directly (no wrapped container)
  Widget _buildMobileInputField(LoginWithMobileController controller) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  /// "Get OTP →" Primary Action Button
  Widget _buildGetOtpButton(LoginWithMobileController controller) {
    return Obx(() {
      final canSubmit = controller.canSubmit;

      return InkWell(
        onTap: canSubmit ? controller.getOtp : null,
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
                'Get OTP',
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

  /// "OR" Divider
  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(
          child: Divider(
            color: AppColors.numPadKeyBorder,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.inputLabel,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.numPadKeyBorder,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  /// "Sign in with MPIN" Card Button
  Widget _buildSignInWithMpinButton(LoginWithMobileController controller) {
    return InkWell(
      onTap: controller.signInWithMpin,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryPurple,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Sign in with MPIN',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Footer Link: "New to Finsphere? Create an account"
  Widget _buildBottomFooter(LoginWithMobileController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New to Finsphere? ',
          style: TextStyle(
            color: AppColors.textDarkSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: controller.createAccount,
          child: const Text(
            'Create an account',
            style: TextStyle(
              color: AppColors.linkText,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the right celestial globe, concentric ripple rings, and animated golden orbit
class _LoginHeroOrbitPainter extends CustomPainter {
  final Animation<double> animation;

  _LoginHeroOrbitPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Globe center in the top right region matching reference image
    final globeCenter = Offset(size.width * 0.75, size.height * 0.42);
    final progress = animation.value;

    // 1. Concentric circular guide rings
    final ringPaint = Paint()
      ..color = AppColors.heroConcentricRings.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawCircle(globeCenter, 98, ringPaint);
    canvas.drawCircle(globeCenter, 142, ringPaint);

    // 2. Solid Planetary Globe / Circle
    final globePaint = Paint()
      ..color = AppColors.globeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(globeCenter, 62, globePaint);

    // 3. Golden Cosmic Orbit Ellipse
    final ovalWidth = size.width * 0.95;
    const ovalHeight = 92.0;
    const baseAngle = -24 * math.pi / 180;

    final ovalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ovalWidth,
          height: ovalHeight,
        ),
      );

    canvas.save();
    canvas.translate(globeCenter.dx, globeCenter.dy);
    canvas.rotate(baseAngle);

    // Base golden orbit track
    final basePaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(ovalPath, basePaint);

    // Animated luminous golden beam
    final beamPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;

    Offset? headPos;
    for (final metric in ovalPath.computeMetrics()) {
      final total = metric.length;
      final trailLen = total * 0.22;
      final head = progress * total;
      final tail = head - trailLen;

      if (tail >= 0) {
        canvas.drawPath(metric.extractPath(tail, head), beamPaint);
      } else {
        canvas.drawPath(metric.extractPath(tail + total, total), beamPaint);
        canvas.drawPath(metric.extractPath(0, head), beamPaint);
      }

      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        headPos = tangent.position;
      }
    }

    if (headPos != null) {
      canvas.drawCircle(
        headPos,
        5.0,
        Paint()
          ..color = AppColors.accentGold.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(headPos, 2.6, Paint()..color = AppColors.accentGold);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LoginHeroOrbitPainter oldDelegate) => false;
}
