import 'dart:io';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 1 of Aadhaar KYC Flow: "Verify your Aadhaar" (Reference Image 2)
class AadhaarVerificationScreen extends StatelessWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: AadhaarVerificationBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Verify your Aadhaar" (used within sticky-header KYC flow)
class AadhaarVerificationBody extends StatelessWidget {
  const AadhaarVerificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AadhaarKycController());

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
                  'Verify your Aadhaar',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'We\'ll send an OTP to the mobile number linked with your Aadhaar.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Aadhaar Number Input Label
                const Text(
                  'Aadhaar number',
                  style: TextStyle(
                    color: AppColors.inputLabel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Aadhaar Number TextFormField
                _buildAadhaarInputField(controller),
                const SizedBox(height: 24),

                // "OR UPLOAD CARD" Divider
                _buildOrUploadDivider(),
                const SizedBox(height: 20),

                // Front side & Back side upload cards
                _buildUploadCardsRow(context, controller),
                const SizedBox(height: 24),

                // Test toggle for linking simulation (Linked vs Unlinked branch)
                _buildBranchingTestToggle(controller),
              ],
            ),
          ),
        ),

        // Bottom Actions & Security Notice
        _buildBottomSection(controller),
      ],
    );
  }

  /// Aadhaar number input field with green checkmark when 12 digits are valid
  Widget _buildAadhaarInputField(AadhaarKycController controller) {
    return TextFormField(
      controller: controller.aadhaarController,
      onChanged: controller.onAadhaarChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: '4821 7730 1234',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.fieldFocusedBorder, width: 2.0),
        ),
        suffixIcon: Obx(() {
          if (controller.isAadhaarValid) {
            return Container(
              margin: const EdgeInsets.only(right: 12),
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.successGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.successGreen,
                size: 18,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  /// "OR UPLOAD CARD" horizontal line divider
  Widget _buildOrUploadDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.line, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR UPLOAD CARD',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.line, thickness: 1),
        ),
      ],
    );
  }

  /// Front side & Back side upload cards
  Widget _buildUploadCardsRow(BuildContext context, AadhaarKycController controller) {
    return Row(
      children: [
        // Front Side Card
        Expanded(
          child: Obx(
            () => _buildUploadCard(
              title: 'Front side',
              subtitle: controller.frontUploaded.value ? 'Uploaded ✓' : 'Camera or gallery',
              isUploaded: controller.frontUploaded.value,
              imagePath: controller.frontImagePath.value,
              imageBytes: controller.frontImageBytes.value,
              onTap: () => controller.pickAadhaarDocument(isFront: true, context: context),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Back Side Card
        Expanded(
          child: Obx(
            () => _buildUploadCard(
              title: 'Back side',
              subtitle: controller.backUploaded.value ? 'Uploaded ✓' : 'Camera or gallery',
              isUploaded: controller.backUploaded.value,
              imagePath: controller.backImagePath.value,
              imageBytes: controller.backImageBytes.value,
              onTap: () => controller.pickAadhaarDocument(isFront: false, context: context),
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
    required String imagePath,
    Uint8List? imageBytes,
    required VoidCallback onTap,
  }) {
    final hasImage = imageBytes != null || (imagePath.isNotEmpty && File(imagePath).existsSync());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // Full Card Image Preview
                  if (imageBytes != null)
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded, color: Colors.white, size: 11),
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isUploaded ? AppColors.successGreenBg : AppColors.kycUploadIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        isUploaded ? Icons.check_circle_rounded : Icons.photo_camera_back_outlined,
                        color: isUploaded ? AppColors.successGreen : AppColors.kycUploadIcon,
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
                      color: isUploaded ? AppColors.successGreen : AppColors.textDarkSecondary,
                      fontSize: 10.5,
                      fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Helpful simulation bar allowing user to test both branches (Mobile Linked vs Not Linked)
  Widget _buildBranchingTestToggle(AadhaarKycController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.indigoTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings_suggest_rounded, color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation: Mobile Linked to Aadhaar?',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Toggle to test both success & unlinked flows',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.isMobileLinked.value,
              activeThumbColor: AppColors.primaryPurple,
              activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.3),
              onChanged: (val) => controller.isMobileLinked.value = val,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom section: Security notice + "Send OTP ->" button
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: Column(
        children: [
          // Security note
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.successGreen, size: 15),
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

          // Send OTP Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isAadhaarValid ? controller.sendOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonBackground,
                  disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send OTP',
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
            ),
          ),
        ],
      ),
    );
  }
}
