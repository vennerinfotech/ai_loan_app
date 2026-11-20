import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../widgets/kyc_stepper.dart';
import 'main_nav_screen.dart';
import 'fetching_report_screen.dart';

/// Screen 3 of KYC Flow: "Credit check" (CIBIL / CRIF Consent - Reference Image)
class CreditCheckScreen extends StatelessWidget {
  const CreditCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(
              activeStep: 3,
              title: 'Credit check',
              showHelp: false,
            ),
            SizedBox(height: 8),
            Expanded(child: CreditCheckBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Credit check" (used within step flow)
class CreditCheckBody extends StatefulWidget {
  const CreditCheckBody({super.key});

  @override
  State<CreditCheckBody> createState() => _CreditCheckBodyState();
}

class _CreditCheckBodyState extends State<CreditCheckBody> {
  // GetX / state observables
  final isBureauAuthorized = true.obs;
  final isWhatsAppOptIn = false.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Blue Banner Card ("Fetch your credit report")
                _buildHeroBannerCard(),
                const SizedBox(height: 14),

                // 2. Dual Feature Cards: Bureau data & Private
                _buildDualCardsRow(),
                const SizedBox(height: 14),

                // 3. Consent Checkboxes Card
                _buildConsentCard(),
              ],
            ),
          ),
        ),

        // Bottom Actions: "Later" & "I agree, fetch report ->"
        _buildBottomSection(context),
      ],
    );
  }

  /// Dark navy card with yellow squircle bar chart icon and cosmic orbit pattern
  Widget _buildHeroBannerCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientDiagonal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background cosmic orbit design pattern at top right
          const Positioned.fill(
            child: CustomPaint(
              painter: _CreditHeroOrbitPainter(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yellow squircle with bar chart icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.leaderboard_rounded,
                      color: AppColors.navy,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Heading
                const Text(
                  'Fetch your credit report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'We\'ll pull your report from CIBIL / CRIF to find loans you qualify for.',
                  style: TextStyle(
                    color: AppColors.indigoTint,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Two side-by-side feature cards: "Bureau data" & "Private"
  Widget _buildDualCardsRow() {
    return Row(
      children: [
        // Card 1: Bureau data
        Expanded(
          child: Container(
            height: 126,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: AppColors.successGreen,
                      size: 21,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bureau data',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Straight from CIBIL & CRIF',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Card 2: Private
        Expanded(
          child: Container(
            height: 126,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Private',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Shared only with lenders you pick',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 11,
                        height: 1.25,
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

  /// White consent card with two checkboxes
  Widget _buildConsentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Checkbox 1: CIBIL / CRIF authorization
          Obx(
            () => GestureDetector(
              onTap: () => isBureauAuthorized.value = !isBureauAuthorized.value,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isBureauAuthorized.value
                            ? AppColors.primaryButtonBackground
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isBureauAuthorized.value
                              ? AppColors.primaryButtonBackground
                              : AppColors.line,
                          width: 1.5,
                        ),
                      ),
                      child: isBureauAuthorized.value
                          ? const Center(
                              child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I authorise Finsphere AI to fetch my credit report from CIBIL / CRIF for this loan application.',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Checkbox 2: WhatsApp updates (optional)
          Obx(
            () => GestureDetector(
              onTap: () => isWhatsAppOptIn.value = !isWhatsAppOptIn.value,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isWhatsAppOptIn.value
                            ? AppColors.primaryButtonBackground
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isWhatsAppOptIn.value
                              ? AppColors.primaryButtonBackground
                              : AppColors.line,
                          width: 1.5,
                        ),
                      ),
                      child: isWhatsAppOptIn.value
                          ? const Center(
                              child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Send me a monthly score update on WhatsApp (optional).',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
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

  /// Bottom Section: "Later" & "I agree, fetch report ->"
  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Row(
        children: [
          // Later button
          GestureDetector(
            onTap: () => Get.offAll(() => const MainNavScreen()),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line, width: 1.2),
              ),
              child: const Center(
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // "I agree, fetch report ->" button
          Expanded(
            child: Obx(
              () => SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isBureauAuthorized.value
                      ? () {
                          Get.to(() => const FetchingReportScreen());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonBackground,
                    disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'I agree, fetch report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.accentGold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cosmic orbit ellipse painter for the Credit Check Hero Card
class _CreditHeroOrbitPainter extends CustomPainter {
  const _CreditHeroOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final orbitPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    // Outer large sweeping arc passing from top down towards bottom-right
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.28),
        width: size.width * 0.86,
        height: size.height * 1.35,
      ),
      orbitPaint,
    );

    // Inner secondary sweeping arc
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.90, size.height * 0.20),
        width: size.width * 0.50,
        height: size.height * 0.82,
      ),
      orbitPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
