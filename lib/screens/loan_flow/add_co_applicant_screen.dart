import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'package:get/get.dart';
import '../../controller/applicant_details_controller.dart';
import '../../widgets/custom_dropdown.dart';

/// Screen for adding a new co-applicant or guarantor (Full Mobile Page Flow with Form Validation)
class AddCoApplicantScreen extends StatelessWidget {
  final String role;

  const AddCoApplicantScreen({
    super.key,
    this.role = 'Co-Applicant',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ApplicantDetailsController>()
        ? Get.find<ApplicantDetailsController>()
        : Get.put(ApplicantDetailsController());

    final isGuarantor = role.toLowerCase() == 'guarantor';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: controller.addCoAppFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading & Subtitle
                      Text(
                        isGuarantor
                            ? 'Who is guaranteeing your loan?'
                            : 'Who is applying with you?',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isGuarantor
                            ? 'A guarantor provides assurance to lenders and helps in loan approval.'
                            : 'A co-applicant with steady income can raise your loan eligibility.',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 1. Full Name
                      _buildFieldLabel(isGuarantor ? 'Guarantor name' : 'Co-applicant name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.fullNameController,
                        keyboardType: TextInputType.name,
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) {
                            return isGuarantor
                                ? 'Please enter guarantor name'
                                : 'Please enter co-applicant name';
                          }
                          if (text.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: isGuarantor
                              ? 'Enter Guarantor Name'
                              : 'Enter Co-Applicant Name',
                          hintStyle: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 2. Mobile Number
                      _buildFieldLabel('Mobile number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.mobileNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Please enter mobile number';
                          }
                          if (text.length != 10) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '+91',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 1,
                                  height: 22,
                                  color: AppColors.line,
                                ),
                              ],
                            ),
                          ),
                          hintText: 'Enter 10-Digit Mobile Number',
                          hintStyle: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3. Relationship to Applicant Dropdown
                      Obx(
                        () => CustomAppDropdown(
                          label: 'Relationship to applicant',
                          isRequired: true,
                          hintText: 'Select Relationship',
                          value: controller.selectedRelationship.value,
                          items: controller.relationshipOptions,
                          onChanged: (val) => controller.selectRelationship(val),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please select relationship';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4. Applicant Type Dropdown (Financial / Non-Financial)
                      Obx(
                        () => CustomAppDropdown(
                          label: 'Applicant type',
                          isRequired: true,
                          hintText: 'Select Applicant Type',
                          value: controller.selectedApplicantType.value,
                          items: controller.applicantTypeOptions,
                          onChanged: (val) => controller.selectApplicantType(val),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please select applicant type';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 5. Dynamic Employment Type Dropdown
                      Obx(
                        () => CustomAppDropdown(
                          label: 'Employment type',
                          isRequired: true,
                          hintText: 'Select Employment Type',
                          value: controller.selectedEmploymentType.value,
                          items: controller.currentEmploymentOptions,
                          onChanged: (val) => controller.selectEmploymentType(val),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please select employment type';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Info banner
                      _buildInfoBanner(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons (Cancel & Add)
            _buildBottomButtons(context, controller),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back and centered title
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Squircle Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Add ${role.toLowerCase()}',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          // Spacer for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Label with red asterisk
  Widget _buildFieldLabel(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: AppColors.errorRed,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Informational notice card
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.indigoTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.shield_outlined,
            color: AppColors.indigo,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'We\'ll send them a link to verify their own Aadhaar and PAN — you don\'t need their documents.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom action button row: Cancel and Add co-applicant / guarantor
  Widget _buildBottomButtons(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.lightBackground,
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.line,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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

          // Add Button
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => controller.addCoApplicant(role: role),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add $role',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.amber,
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
