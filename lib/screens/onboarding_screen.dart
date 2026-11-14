import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';
import '../theme/theme.dart';

/// Clean, responsive, and stateless Onboarding Screen for Finsphere AI using GetX.
/// Seamlessly proportioned without blank space, with swipeable top card & text,
/// and stationary 3-dot indicator & fixed bottom buttons.
/// All colors are sourced directly from AppColors for centralized theming.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject GetX OnboardingController (zero setState)
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            // Fixed bottom buttons area: 56 (btn1) + 10 (gap) + 52 (btn2) + 12 (pad) = 130
            const buttonsAreaHeight = 130.0;
            final pageViewHeight = availableHeight - buttonsAreaHeight;

            // Proportional hero card height (~55% on spacious screens, ~50% on compact screens)
            final heroFactor = availableHeight <= 620 ? 0.50 : 0.55;
            final heroCardHeight =
                (availableHeight * heroFactor).clamp(280.0, 485.0);

            // Responsive vertical spacing below hero card:
            // Remaining space inside the page view area
            const textContentHeight = 124.0; // indicator (6) + title (68) + subtitle (50)
            final remainingSpace =
                math.max(0.0, pageViewHeight - heroCardHeight - textContentHeight);

            final gapAboveIndicator = (remainingSpace * 0.28).clamp(8.0, 32.0);
            final gapAboveTitle = (remainingSpace * 0.20).clamp(6.0, 22.0);
            final gapBelowSubtitle = (remainingSpace * 0.52).clamp(8.0, 64.0);

            return Column(
              children: [
                // 1. SWIPEABLE CONTENT: PageView covers top card & text section;
                // Indicator is kept stationary in the Stack overlay.
                Expanded(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: controller.pages.length,
                        itemBuilder: (context, index) {
                          final data = controller.pages[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),

                                // Top hero container (swipes with page)
                                SizedBox(
                                  height: heroCardHeight,
                                  child: _OnboardingHeroCard(
                                    heroHeight: heroCardHeight,
                                    screenWidth: screenWidth,
                                  ),
                                ),

                                // Exact vertical placeholder for the stationary indicator
                                SizedBox(
                                  height: gapAboveIndicator + 5.5 + gapAboveTitle,
                                ),

                                // Heading (swipes with page)
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: data.titlePrefix,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 29,
                                          fontWeight: FontWeight.w800,
                                          height: 1.15,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      TextSpan(
                                        text: data.titleHighlight,
                                        style: const TextStyle(
                                          color: AppColors.headingHighlight,
                                          fontSize: 29,
                                          fontWeight: FontWeight.w800,
                                          height: 1.15,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Description subtitle (swipes with page)
                                Text(
                                  data.description,
                                  style: const TextStyle(
                                    color: AppColors.textDarkSecondary,
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                SizedBox(height: gapBelowSubtitle),
                              ],
                            ),
                          );
                        },
                      ),

                      // Fixed 3-dot indicator: Remains stationary while cards & texts swipe
                      Positioned(
                        top: 4.0 + heroCardHeight + gapAboveIndicator,
                        left: 16.0,
                        child: _buildPageIndicator(controller),
                      ),
                    ],
                  ),
                ),

                // 2. FIXED BOTTOM BUTTONS: "Create free account" & "I already have an account"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPrimaryButton(
                        title: 'Create free account',
                        onTap: controller.createAccount,
                      ),
                      const SizedBox(height: 10),
                      _buildSecondaryButton(
                        title: 'I already have an account',
                        onTap: controller.alreadyHaveAccount,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// GetX reactive Page Indicator: Stationary in position, animates active pill on page change
  Widget _buildPageIndicator(OnboardingController controller) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(controller.pages.length, (index) {
          final isActive = index == controller.currentPage.value;
          return GestureDetector(
            onTap: () => controller.goToPage(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: isActive ? 24 : 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.indicatorActive
                    : AppColors.indicatorInactive,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Primary button: Deep royal blue container with golden amber circular arrow pill
  Widget _buildPrimaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryButtonBackground,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primaryButtonText,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryButtonArrowCircle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryButtonArrowIcon,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Secondary button: Light container with subtle border
  Widget _buildSecondaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.lightButtonBackground,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.lightButtonBorder,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.secondaryButtonText,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// The Top Hero Container without shadows matching reference image
class _OnboardingHeroCard extends StatelessWidget {
  final double heroHeight;
  final double screenWidth;

  const _OnboardingHeroCard({
    required this.heroHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Proportional globe diameter (~36% of heroHeight, clamped between 110 and 155)
    final globeSize = (heroHeight * 0.36).clamp(112.0, 160.0);

    return Container(
      width: double.infinity,
      height: heroHeight,
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
          // Background concentric circles & cosmic orbit ring
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroBackgroundPainter(),
            ),
          ),

          // Central planetary globe (clean solid, zero shadow)
          Align(
            alignment: const Alignment(0, -0.04),
            child: Container(
              width: globeSize,
              height: globeSize,
              decoration: const BoxDecoration(
                color: AppColors.globeColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Top Header: Small Saturn icon + "Finsphere AI"
          Positioned(
            top: 18,
            left: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniSaturnLogo(),
                const SizedBox(width: 8),
                const Text(
                  'Finsphere AI',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          // Floating Card 1 (Top-Left): "Loan approved" (White card, -4.0° tilt, zero shadow)
          Positioned(
            top: (heroHeight * 0.17).clamp(48.0, 80.0),
            left: 16,
            child: _buildLoanApprovedCard(screenWidth),
          ),

          // Floating Card 2 (Bottom-Right): "CIBIL score" (Golden amber card, +4.0° tilt, zero shadow)
          Positioned(
            bottom: (heroHeight * 0.15).clamp(48.0, 78.0),
            right: 16,
            child: _buildCibilScoreCard(screenWidth),
          ),

          // Bottom Feature Badges (3 capsules)
          Positioned(
            bottom: 14,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _FeaturePill(title: 'Instant approval'),
                _FeaturePill(title: '100% secure'),
                _FeaturePill(title: 'Best rates'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small Saturn logo in top header
  Widget _buildMiniSaturnLogo() {
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
              color: AppColors.saturnPlanetColor,
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

  /// White Floating Card: "Loan approved - ₹2,00,000" (-4.0° tilt matching Figma, zero shadow)
  Widget _buildLoanApprovedCard(double screenWidth) {
    final cardWidth = (screenWidth * 0.60).clamp(210.0, 245.0);

    return Transform.rotate(
      angle: -4.0 * math.pi / 180, // Counter-clockwise tilt (-4.0°) matching Figma!
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.loanApprovedCardBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.checkmarkBox,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: AppColors.checkmarkIcon,
                  ),
                ),
                const SizedBox(width: 7),
                const Flexible(
                  child: Text(
                    'Loan approved',
                    style: TextStyle(
                      color: AppColors.cardTextDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '₹2,00,000',
              style: TextStyle(
                color: AppColors.cardAmountText,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Personal loan · sample',
              style: TextStyle(
                color: AppColors.cardSubtitleText,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Golden Amber Floating Card: "CIBIL score - 762 / 900" (+4.0° clockwise tilt matching Figma!)
  Widget _buildCibilScoreCard(double screenWidth) {
    final cardWidth = (screenWidth * 0.50).clamp(180.0, 215.0);

    return Transform.rotate(
      angle: 4.0 * math.pi / 180, // Clockwise tilt (+4.0°) matching Figma!
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cibilCardBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CIBIL score',
              style: TextStyle(
                color: AppColors.cibilCardText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '762 ',
                    style: TextStyle(
                      color: AppColors.cibilCardText,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: '/ 900',
                    style: TextStyle(
                      color: AppColors.cibilCardText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: cardWidth * 0.78,
                height: 4,
                child: LinearProgressIndicator(
                  value: 0.80,
                  backgroundColor: AppColors.cibilProgressTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.cibilProgressFill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small capsule badge at the bottom of the hero card
class _FeaturePill extends StatelessWidget {
  final String title;

  const _FeaturePill({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.featurePillBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.featurePillBorder,
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.featurePillText,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Painter for the subtle concentric circles and orbital line inside the dark hero card
class _HeroBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.46);

    // Faint circular guide rings
    final ringPaint = Paint()
      ..color = AppColors.heroConcentricRings.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, size.height * 0.20, ringPaint);
    canvas.drawCircle(center, size.height * 0.35, ringPaint);
    canvas.drawCircle(center, size.height * 0.50, ringPaint);

    // Smooth tilted elliptical orbit loop
    final orbitPaint = Paint()
      ..color = AppColors.orbitViolet.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-24 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.98,
        height: size.height * 0.44,
      ),
      orbitPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
