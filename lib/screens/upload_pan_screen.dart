import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';

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

  /// Viewfinder container: Shows full card image with cancel option when uploaded,
  /// or dark indigo container with DottedBorder from package when empty.
  Widget _buildPanCardFrameViewfinder(
    BuildContext context,
    PanKycController controller,
  ) {
    return Obx(() {
      final bytes = controller.panImageBytes.value;
      final imagePath = controller.panImagePath.value;
      final hasImage =
          bytes != null ||
          (imagePath.isNotEmpty && File(imagePath).existsSync());

      if (hasImage) {
        // FULL CARD IMAGE DISPLAY with cancel & change options
        return Container(
          width: double.infinity,
          height: 195,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.successGreen, width: 1.8),
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.successGreen.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Full-cover image
              GestureDetector(
                onTap: () => controller.openImagePickerBottomSheet(context: context),
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

              // Gradient vignette at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Status Badge (top-left)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successGreen, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'PAN Card Front',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Cancel Option Button (top-right)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: controller.clearPanImage,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 1),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // 4. Change photo pill (bottom center)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => controller.openImagePickerBottomSheet(context: context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Change photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Uploading Overlay
              Obx(() {
                if (controller.isUploadingPan.value) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          SizedBox(height: 10),
                          Text(
                            'Uploading PAN card...',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      }

      // EMPTY STATE: DOTTED BORDER using dotted_border package
      return GestureDetector(
        onTap: () => controller.openImagePickerBottomSheet(context: context),
        child: Container(
          width: double.infinity,
          height: 195,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradientDiagonal,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DottedBorder(
            color: AppColors.accentGold,
            strokeWidth: 1.8,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            padding: const EdgeInsets.all(12),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fit the card inside the frame',
                    style: TextStyle(
                      color: AppColors.indigoTint,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to capture or choose from gallery',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
                border: Border.all(color: AppColors.line, width: 1.2),
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
            color: AppColors.successGreenBg,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.successGreen,
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
                color: AppColors.inputFill,
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
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isUploadingPan.value
                      ? null
                      : () => controller.continueToReview(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isUploadingPan.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
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
          ),
        ],
      ),
    );
  }
}
