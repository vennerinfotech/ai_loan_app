import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'loan_flow/choose_loan_type_screen.dart';

/// Screen displaying the retrieved CIBIL / CRIF score matching Reference Image 2
class CibilScoreScreen extends StatelessWidget {
  final double score;

  const CibilScoreScreen({
    super.key,
    this.score = 762,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Royal Blue Hero Card with Gauge
                    _buildHeroScoreCard(context),

                    const SizedBox(height: 22),

                    // 2. Section Heading: "What shapes your score"
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'What shapes your score',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 3. 2x2 Factor Cards Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFactorCard(
                                  title: 'Payment history',
                                  value: '100%',
                                  badgeText: 'Excellent',
                                  badgeBg: AppColors.successGreenBg,
                                  badgeTextColor: AppColors.successGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFactorCard(
                                  title: 'Credit utilisation',
                                  value: '28%',
                                  badgeText: 'Good',
                                  badgeBg: AppColors.successGreenBg,
                                  badgeTextColor: AppColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFactorCard(
                                  title: 'Credit age',
                                  value: '4.2 yrs',
                                  badgeText: 'Fair',
                                  badgeBg: AppColors.warningAmberBg,
                                  badgeTextColor: AppColors.warningAmber,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFactorCard(
                                  title: 'Recent enquiries',
                                  value: '2',
                                  badgeText: 'Good',
                                  badgeBg: AppColors.successGreenBg,
                                  badgeTextColor: AppColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Bottom Action: "See loans you qualify for ->"
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  /// Top Hero Card with Speedometer Semicircular Gauge
  Widget _buildHeroScoreCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Row: Back button, Title, Refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Title
              const Text(
                'Credit score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),

              // Refresh Button
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Score Updated',
                    'Your credit score is up to date as of today.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.navy,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Speedometer Semicircular Gauge (using syncfusion_flutter_gauges package with fully responsive layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final gaugeHeight = width * 0.58;
              final strokeWidth = (width * 0.046).clamp(13.0, 18.0);
              final markerSize = (width * 0.065).clamp(18.0, 24.0);
              final centerTop = gaugeHeight * 0.34;
              final scoreFontSize = (width * 0.155).clamp(44.0, 56.0);
              final labelsTop = gaugeHeight * 0.86;
              final labelsInset = width * 0.142;

              return SizedBox(
                width: width,
                height: gaugeHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Large Gauge Arc powered by syncfusion_flutter_gauges package
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 300,
                          maximum: 900,
                          startAngle: 180,
                          endAngle: 0,
                          showLabels: false,
                          showTicks: false,
                          canScaleToFit: true,
                          radiusFactor: 1.0,
                          axisLineStyle: AxisLineStyle(
                            thickness: strokeWidth,
                            cornerStyle: CornerStyle.bothCurve,
                            color: AppColors.indigo,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: score,
                              width: strokeWidth,
                              color: AppColors.amber,
                              cornerStyle: CornerStyle.bothCurve,
                              enableAnimation: true,
                              animationDuration: 1300,
                              animationType: AnimationType.easeOutBack,
                            ),
                            MarkerPointer(
                              value: score,
                              markerType: MarkerType.circle,
                              markerHeight: markerSize,
                              markerWidth: markerSize,
                              color: AppColors.navy,
                              borderWidth: strokeWidth * 0.24,
                              borderColor: AppColors.amber,
                              enableAnimation: true,
                              animationDuration: 1300,
                              animationType: AnimationType.easeOutBack,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 2. Score & Rating Chip strictly centered inside the arch (responsive)
                    Positioned(
                      top: centerTop,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${score.toInt()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: scoreFontSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: width * 0.024),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amber,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Good · +14 this month',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Scale Range Numbers: "300" on left, "900" on right (responsive to any screen width)
                    Positioned(
                      left: labelsInset,
                      top: labelsTop,
                      child: const Text(
                        '300',
                        style: TextStyle(
                          color: AppColors.indigoTint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      right: labelsInset,
                      top: labelsTop,
                      child: const Text(
                        '900',
                        style: TextStyle(
                          color: AppColors.indigoTint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Footer info text
          const Text(
            'Powered by CIBIL · Updated 12 Nov 2026',
            style: TextStyle(
              color: AppColors.indigoTint,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  /// Individual Factor Card (e.g. Payment history, Credit utilisation, etc.)
  Widget _buildFactorCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
  }) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Title
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Metric Value
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom CTA Button: "See loans you qualify for ->"
  Widget _buildBottomCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const ChooseLoanTypeScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'See loans you qualify for',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
