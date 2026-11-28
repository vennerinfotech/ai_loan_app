import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'loan_flow/choose_loan_type_screen.dart';
import '../controller/cibil_score_controller.dart';

/// Screen displaying the retrieved CIBIL / CRIF score matching updated full-height design
class CibilScoreScreen extends StatelessWidget {
  final double? score;

  const CibilScoreScreen({
    super.key,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CibilScoreController>()
        ? Get.find<CibilScoreController>()
        : Get.put(CibilScoreController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Separate Top Header (Back, Title, Refresh)
            _buildTopHeader(controller),

            const SizedBox(height: 8),

            // 2. Full-height Royal Blue Hero Card till bottom button with centered chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeroScoreCard(context, controller),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Bottom CTA: "View loans you qualify for" & "Download report"
            _buildBottomCta(context, controller),
          ],
        ),
      ),
    );
  }

  /// Separate Top Header Bar outside the card
  Widget _buildTopHeader(CibilScoreController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textDark,
                  size: 16,
                ),
              ),
            ),
          ),

          // Header Title
          const Text(
            'Credit score',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),

          // Refresh Button
          Obx(
            () => GestureDetector(
              onTap: controller.isLoading.value ? null : () => controller.fetchCibilScore(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.navy,
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-Height Hero Card with Speedometer Semicircular Gauge centered
  Widget _buildHeroScoreCard(BuildContext context, CibilScoreController controller) {
    return Obx(() {
      final currentScore = score ?? controller.cibilScore.value.toDouble();
      final rating = controller.getRatingForScore(currentScore.toInt());
      final reportDate = controller.reportDate.value.isNotEmpty
          ? controller.reportDate.value
          : CibilScoreController.formatReportDate(DateTime.now());

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.dashboardCardGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGradientEnd.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 42),

            // Top Title & Subtitle inside Hero Card
            const Text(
              'CIBIL Score',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Official credit health report from bureau',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),

            const Spacer(),

            // Centered Speedometer Semicircular Gauge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final gaugeHeight = width * 0.58;
                  final strokeWidth = (width * 0.046).clamp(14.0, 20.0);
                  final markerSize = (width * 0.065).clamp(20.0, 26.0);
                  final centerTop = gaugeHeight * 0.44;
                  final scoreFontSize = (width * 0.16).clamp(46.0, 58.0);
                  final labelsTop = gaugeHeight * 0.86;
                  final labelsInset = width * 0.142;

                  return SizedBox(
                    width: width,
                    height: gaugeHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Large Gauge Arc powered by syncfusion_flutter_gauges
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
                                  value: currentScore,
                                  width: strokeWidth,
                                  color: AppColors.amber,
                                  cornerStyle: CornerStyle.bothCurve,
                                  enableAnimation: true,
                                  animationDuration: 1300,
                                  animationType: AnimationType.easeOutBack,
                                ),
                                MarkerPointer(
                                  value: currentScore,
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

                        // 2. Score & Rating Chip (Only status text, removed +14 this month)
                        Positioned(
                          top: centerTop,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currentScore.toInt()}',
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
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.amber,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  rating, // ONLY show status
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. Scale Range Numbers: "300" on left, "900" on right
                        Positioned(
                          left: labelsInset,
                          top: labelsTop,
                          child: const Text(
                            '300',
                            style: TextStyle(
                              color: AppColors.indigoTint,
                              fontSize: 12.5,
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // Bottom details card (Report Date & Bureau Source: CIBIL TransUnion)
            _buildReportDetailsCard(reportDate),
          ],
        ),
      );
    });
  }

  /// Bottom details card displaying Report Date (from current DateTime.now) and Bureau Source (CIBIL TransUnion)
  Widget _buildReportDetailsCard(String reportDate) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Date',
                style: TextStyle(
                  color: AppColors.textDarkSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                reportDate,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: AppColors.line,
              height: 1,
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Bureau Source',
                style: TextStyle(
                  color: AppColors.textDarkSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'CIBIL TransUnion',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom CTA Section: "View loans you qualify for" & "Download report"
  Widget _buildBottomCta(BuildContext context, CibilScoreController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Primary Button: "View loans you qualify for"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Get.offAll(() => const ChooseLoanTypeScreen());
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
                    'View loans you qualify for',
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
          const SizedBox(height: 8),

          // 2. Download Report button with "Save As" location dialog
          Obx(
            () => GestureDetector(
              onTap: controller.isDownloadingPdf.value
                  ? null
                  : () => controller.downloadReportPdf(),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: controller.isDownloadingPdf.value
                    ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.indigo,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_rounded,
                            color: AppColors.textDarkSecondary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Download report',
                            style: TextStyle(
                              color: AppColors.textDarkSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
