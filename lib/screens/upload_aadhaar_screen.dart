import 'dart:io';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen: "Upload your Aadhaar card" (Front & Back documents or Single PDF)
class UploadAadhaarScreen extends StatelessWidget {
  const UploadAadhaarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: UploadAadhaarBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Upload your Aadhaar card" (used within sticky-header KYC flow)
class UploadAadhaarBody extends StatelessWidget {
  const UploadAadhaarBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AadhaarKycController>()
        ? Get.find<AadhaarKycController>()
        : Get.put(AadhaarKycController());

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
                  'Upload your Aadhaar card',
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
                  'Upload clear photos or PDF of your Aadhaar card for verification.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // Top Mode Toggle: [Front & Back Images/PDF] vs [Single PDF (Front + Back)]
                _buildUploadModeToggle(controller),
                const SizedBox(height: 20),

                // Dynamic Upload Content (Front & Back row vs Single PDF container)
                Obx(() {
                  if (controller.isSinglePdfMode) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aadhaar Single PDF',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSinglePdfUploadContainer(context, controller),
                      ],
                    );
                  }
                  return _buildUploadCardsRow(context, controller);
                }),
                const SizedBox(height: 24),

                // Dynamic Upload Checklist
                Obx(() => _buildUploadChecklist(controller.isSinglePdfMode)),
              ],
            ),
          ),
        ),

        // Bottom Actions: Security Notice + "Upload & Continue" button
        _buildBottomSection(controller),
      ],
    );
  }

  /// Top Mode Selection Toggle:
  /// Left: "Front & Back\nImages/PDF"
  /// Right: "Single PDF (Front\n+ Back)"
  Widget _buildUploadModeToggle(AadhaarKycController controller) {
    return Obx(() {
      final selectedIndex = controller.uploadModeIndex.value;

      return Row(
        children: [
          // Option 0: Front & Back Images/PDF
          Expanded(
            child: _buildTogglePill(
              title: 'Front & Back\nImages/PDF',
              isSelected: selectedIndex == 0,
              onTap: () => controller.setUploadMode(0),
            ),
          ),
          const SizedBox(width: 14),

          // Option 1: Single PDF (Front + Back)
          Expanded(
            child: _buildTogglePill(
              title: 'Single PDF (Front\n+ Back)',
              isSelected: selectedIndex == 1,
              onTap: () => controller.setUploadMode(1),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTogglePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.navy,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.navy,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  /// Single PDF Upload Container (Shown when "Single PDF (Front + Back)" is selected)
  Widget _buildSinglePdfUploadContainer(
    BuildContext context,
    AadhaarKycController controller,
  ) {
    return Obx(() {
      final isUploaded = controller.singlePdfUploaded.value;
      final isUploading = controller.isUploadingDocuments.value;
      final filePath = controller.singlePdfPath.value;
      final fileBytes = controller.singlePdfBytes.value;
      final filename = controller.singlePdfFilename.value.isNotEmpty
          ? controller.singlePdfFilename.value
          : (filePath.isNotEmpty ? filePath.split('/').last : '');
      final hasFile = fileBytes != null ||
          (filePath.isNotEmpty && File(filePath).existsSync()) ||
          filename.isNotEmpty;

      return GestureDetector(
        onTap: () => controller.pickSinglePdfDocument(context: context),
        child: Container(
          width: double.infinity,
          height: 160,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUploaded ? AppColors.successGreen : AppColors.kycUploadCardBorder,
              width: isUploaded ? 1.8 : 1.2,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isUploaded
                    ? AppColors.successGreen.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: hasFile
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // PDF Document View
                    Container(
                      color: const Color(0xFFF9FAFC),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Color(0xFFE53935),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            filename.isNotEmpty ? filename : 'aadhaar_card.pdf',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'PDF Document (Front + Back)',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Right Action Buttons: "Change" & "Remove (X)"
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => controller.pickSinglePdfDocument(context: context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Change',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: controller.removeSinglePdfDocument,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Status Strip for PDF
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreenBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.successGreen,
                              size: 15,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Selected ✓',
                              style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUploading
                            ? AppColors.indigoTint
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isUploading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.indigo,
                                ),
                              )
                            : const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Color(0xFFE53935),
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload Single PDF (Front + Back)',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUploading
                          ? 'Uploading...'
                          : 'Tap to select PDF containing both sides (PDF only, Max 10MB)',
                      style: const TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  /// Front side & Back side upload cards row
  Widget _buildUploadCardsRow(
    BuildContext context,
    AadhaarKycController controller,
  ) {
    return Row(
      children: [
        // Front Side Card
        Expanded(
          child: Obx(
            () => _buildUploadCard(
              title: 'Front side',
              subtitle: controller.isUploadingDocuments.value
                  ? 'Uploading...'
                  : (controller.frontUploaded.value
                      ? 'Selected ✓'
                      : 'Camera or gallery'),
              isUploaded: controller.frontUploaded.value,
              isUploading: controller.isUploadingDocuments.value,
              imagePath: controller.frontImagePath.value,
              imageBytes: controller.frontImageBytes.value,
              filename: controller.frontUploadedFilename.value,
              onTap: () => controller.pickAadhaarDocument(
                isFront: true,
                context: context,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Back Side Card
        Expanded(
          child: Obx(
            () => _buildUploadCard(
              title: 'Back side',
              subtitle: controller.isUploadingDocuments.value
                  ? 'Uploading...'
                  : (controller.backUploaded.value
                      ? 'Selected ✓'
                      : 'Camera or gallery'),
              isUploaded: controller.backUploaded.value,
              isUploading: controller.isUploadingDocuments.value,
              imagePath: controller.backImagePath.value,
              imageBytes: controller.backImageBytes.value,
              filename: controller.backUploadedFilename.value,
              onTap: () => controller.pickAadhaarDocument(
                isFront: false,
                context: context,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    bool isUploading = false,
    required String imagePath,
    Uint8List? imageBytes,
    String? filename,
    required VoidCallback onTap,
  }) {
    final effectiveFilename = filename != null && filename.isNotEmpty
        ? filename
        : (imagePath.isNotEmpty ? imagePath.split('/').last : '');
    final hasFile = imageBytes != null ||
        (imagePath.isNotEmpty && File(imagePath).existsSync()) ||
        effectiveFilename.isNotEmpty;
    final isPdf = imagePath.toLowerCase().endsWith('.pdf') ||
        effectiveFilename.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 145,
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUploaded
                ? AppColors.successGreen
                : AppColors.kycUploadCardBorder,
            width: isUploaded ? 1.8 : 1.2,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isUploaded
                  ? AppColors.successGreen.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasFile
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Full Card Image or PDF Preview
                  if (isPdf)
                    Container(
                      color: const Color(0xFFF9FAFC),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Color(0xFFE53935),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            effectiveFilename.isNotEmpty
                                ? effectiveFilename
                                : 'document.pdf',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'PDF Document',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (imageBytes != null)
                    Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),

                  // Bottom Gradient dark overlay for readability
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Title & Uploaded Checkmark badge
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.successGreen,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top-Right "Change" Tag
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Change',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isUploading
                          ? AppColors.indigoTint
                          : (isUploaded
                              ? AppColors.successGreenBg
                              : AppColors.kycUploadIconBg),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: isUploading
                          ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.indigo,
                                ),
                              )
                          : Icon(
                              isUploaded
                                  ? Icons.check_circle_rounded
                                  : Icons.photo_camera_back_outlined,
                              color: isUploaded
                                  ? AppColors.successGreen
                                  : AppColors.kycUploadIcon,
                              size: 22,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUploading
                          ? AppColors.indigo
                          : (isUploaded
                              ? AppColors.successGreen
                              : AppColors.textDarkSecondary),
                      fontSize: 10.5,
                      fontWeight: isUploaded || isUploading
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Upload checklist (dynamic based on single PDF vs separate images)
  Widget _buildUploadChecklist(bool isSinglePdf) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Guidelines',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (isSinglePdf) ...const [
            _ChecklistRow(
              text: 'Single PDF file must contain both front and back sides of Aadhaar',
            ),
            SizedBox(height: 8),
            _ChecklistRow(
              text: 'Ensure name, photo, DOB, and 12-digit number are clearly visible',
            ),
            SizedBox(height: 8),
            _ChecklistRow(
              text: 'The file must be in PDF format (.pdf only, up to 10MB)',
            ),
          ] else ...const [
            _ChecklistRow(
              text: 'Both front and back sides of the Aadhaar card are required',
            ),
            SizedBox(height: 8),
            _ChecklistRow(
              text: 'All 4 corners, photo, and 12-digit number should be visible',
            ),
            SizedBox(height: 8),
            _ChecklistRow(
              text: 'Avoid flash reflection, shadows, or blurry camera captures',
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom Section: Security note + "Upload & Continue" button
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: Column(
        children: [
          // Security note
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.successGreen,
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Bank-grade encryption • UIDAI compliant',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Button: "Upload & Continue"
          Obx(
            () {
              final isUploading = controller.isUploadingDocuments.value;
              final isSingle = controller.isSinglePdfMode;
              final canUpload = isSingle
                  ? (controller.singlePdfUploaded.value && !isUploading)
                  : (controller.frontUploaded.value &&
                      controller.backUploaded.value &&
                      !isUploading);

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      canUpload ? controller.uploadBothAadhaarDocuments : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonBackground,
                    disabledBackgroundColor:
                        AppColors.navy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isUploading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload & Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String text;

  const _ChecklistRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: AppColors.successGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textDarkSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
