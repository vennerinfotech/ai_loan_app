import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 3: "Upload your PAN card" (Reference Image 3)
class UploadPanScreen extends StatelessWidget {
  const UploadPanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 2),
            SizedBox(height: 12),
            Expanded(child: UploadPanBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Upload your PAN card" (used within sticky-header KYC flow)
class UploadPanBody extends StatelessWidget {
  const UploadPanBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PanKycController>();

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Heading
                const Text(
                  'Upload your PAN card',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'A clear photo of the front side is enough.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Card frame viewfinder container (Deep Blue / Indigo)
                _buildPanCardFrameViewfinder(context, controller),
                const SizedBox(height: 16),

                // Dual buttons: "Take photo" & "Gallery"
                _buildCameraGalleryButtonsRow(controller),
                const SizedBox(height: 20),

                // 3-point upload checklist
                _buildUploadChecklist(),
              ],
            ),
          ),
        ),

        // Bottom Actions: "Cancel" & "Continue ->"
        _buildBottomSection(controller),
      ],
    );
  }

  /// Dark indigo container with dashed golden frame viewfinder
  Widget _buildPanCardFrameViewfinder(
    BuildContext context,
    PanKycController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.openImagePickerBottomSheet(context: context),
      child: Container(
        width: double.infinity,
        height: 185,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF333099),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF333099).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: _DashedRectPainter(
            color: AppColors.accentGold,
            strokeWidth: 2.0,
            dashWidth: 6,
            dashSpace: 4,
            radius: 16,
          ),
          child: Center(
            child: Obx(() {
              final bytes = controller.panImageBytes.value;
              final imagePath = controller.panImagePath.value;
              final hasImage =
                  bytes != null ||
                  (imagePath.isNotEmpty && File(imagePath).existsSync());

              if (hasImage) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: bytes != null
                          ? Image.memory(
                              bytes,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(imagePath),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF22C55E),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        controller.isCardUploaded.value
                            ? Icons.check_circle_rounded
                            : Icons.badge_outlined,
                        color: controller.isCardUploaded.value
                            ? const Color(0xFF22C55E)
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.isCardUploaded.value
                        ? 'PAN card captured via ${controller.uploadSource.value} ✓'
                        : 'Fit the card inside the frame',
                    style: TextStyle(
                      color: controller.isCardUploaded.value
                          ? AppColors.accentGold
                          : const Color(0xFFC7CAE8),
                      fontSize: 12.5,
                      fontWeight: controller.isCardUploaded.value
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Dual buttons: "Take photo" (Purple) & "Gallery" (White)
  Widget _buildCameraGalleryButtonsRow(PanKycController controller) {
    return Row(
      children: [
        // "Take photo" Button
        Expanded(
          child: GestureDetector(
            onTap: controller.takePhoto,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Take photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // "Gallery" Button
        Expanded(
          child: GestureDetector(
            onTap: controller.pickFromGallery,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE3F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.textDark,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13.5,
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
  }

  /// Checklist with green badges
  Widget _buildUploadChecklist() {
    return Column(
      children: [
        _buildChecklistItem('All four corners visible'),
        const SizedBox(height: 10),
        _buildChecklistItem('Good light, no glare or shadow'),
        const SizedBox(height: 10),
        _buildChecklistItem('JPG, PNG or PDF · up to 5 MB'),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF16A34A),
              size: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Bottom Actions: Cancel & Continue
  Widget _buildBottomSection(PanKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Row(
        children: [
          // Cancel Button
          GestureDetector(
            onTap: controller.cancelUpload,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Continue Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.continueToReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}

/// Custom painter for dashed rounded rectangle viewfinder
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + len),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
