import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../theme/app_colors.dart';
import '../../controller/applicant_details_controller.dart';
import '../../models/co_applicant_form_options_model.dart';
import '../../models/add_co_applicant_model.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/image_picker_bottom_sheet.dart';

/// Screen for adding a new co-applicant or guarantor (Dynamic API Form with Skeletonizer Loader & Document Uploads)
class AddCoApplicantScreen extends StatefulWidget {
  final String role;

  const AddCoApplicantScreen({
    super.key,
    this.role = 'Co-Applicant',
  });

  @override
  State<AddCoApplicantScreen> createState() => _AddCoApplicantScreenState();
}

class _AddCoApplicantScreenState extends State<AddCoApplicantScreen> {
  late final ApplicantDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ApplicantDetailsController>()
        ? Get.find<ApplicantDetailsController>()
        : Get.put(ApplicantDetailsController());

    // Fetch form options strictly when Add Co-Applicant screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCoApplicantFormOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isGuarantor = widget.role.toLowerCase() == 'guarantor';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Form Body with Skeletonizer
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoadingFormOptions.value &&
                    controller.formOptionsData.value == null;

                return Skeletonizer(
                  enabled: isLoading,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Form(
                      key: controller.addCoAppFormKey,
                      autovalidateMode: AutovalidateMode.disabled,
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

                          // Dynamic Form Fields from GET /co-applicants/form-options
                          if (isLoading && controller.activeAddFormFields.isEmpty)
                            ...List.generate(
                              5,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: _buildSkeletonFieldPlaceholder(),
                              ),
                            )
                          else
                            ...controller.activeAddFormFields.map((field) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: _buildDynamicFormField(
                                  context,
                                  controller,
                                  field,
                                  isGuarantor,
                                ),
                              );
                            }),

                          const SizedBox(height: 8),

                          // Dynamic Document Upload Section
                          _buildDocumentsUploadSection(context, controller),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
                'Add ${widget.role.toLowerCase()}',
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

  /// Dynamic Form Field Builder based on CoApplicantFormField configuration
  Widget _buildDynamicFormField(
    BuildContext context,
    ApplicantDetailsController controller,
    CoApplicantFormField field,
    bool isGuarantor,
  ) {
    final type = field.type?.toLowerCase() ?? 'text';
    final name = field.name ?? '';
    final alias = field.alias ?? '';
    final isReq = field.required == true;

    // 1. Dropdown Select Fields (Without inline auto-validation on change)
    if (type == 'select') {
      if (name == 'co_relationship' || alias == 'relationship') {
        final options = field.options.isNotEmpty
            ? field.options
            : controller.currentRelationshipOptions;
        final label = field.label ?? 'Relationship to Applicant';

        return Obx(
          () => CustomAppDropdown(
            label: label,
            isRequired: isReq,
            hintText: 'Select Relationship',
            value: controller.selectedRelationship.value,
            items: options,
            onChanged: (val) {
              controller.selectRelationship(val);
            },
          ),
        );
      }

      if (name == 'applicant_type') {
        final options = field.options.isNotEmpty
            ? field.options
            : controller.currentApplicantTypeOptions;
        final label = field.label ?? 'Applicant Type';

        return Obx(
          () => CustomAppDropdown(
            label: label,
            isRequired: isReq,
            hintText: 'Select Applicant Type',
            value: controller.selectedApplicantType.value,
            items: options,
            onChanged: (val) {
              controller.selectApplicantType(val);
            },
          ),
        );
      }

      if (name == 'employment_type') {
        final label = field.label ?? 'Employment Type';

        return Obx(() {
          final options = controller.currentEmploymentOptions;

          return CustomAppDropdown(
            label: label,
            isRequired: isReq,
            hintText: 'Select Employment Type',
            value: controller.selectedEmploymentType.value,
            items: options,
            onChanged: (val) {
              controller.selectEmploymentType(val);
            },
          );
        });
      }

      // Generic dropdown if any other select field appears
      final label = field.label ?? name;
      return Obx(
        () => CustomAppDropdown(
          label: label,
          isRequired: isReq,
          hintText: 'Select $label',
          value: '',
          items: field.options,
          onChanged: (_) {},
        ),
      );
    }

    // 2. Phone Input Field
    if (type == 'phone' || name.contains('mobile') || name.contains('phone')) {
      final label = field.label ?? 'Mobile number';
      final patternStr = field.pattern ?? r'^[0-9]{10}$';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(label, isRequired: isReq),
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
              if (isReq && text.isEmpty) {
                return 'Please enter $label';
              }
              if (text.isNotEmpty && !RegExp(patternStr).hasMatch(text)) {
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
        ],
      );
    }

    // 3. Text Input Field (Name or other text)
    final isNameField = name == 'co_applicant_name' || alias == 'name';
    final label = isNameField
        ? (isGuarantor ? 'Guarantor name' : (field.label ?? 'Co-applicant name'))
        : (field.label ?? name);
    final hint = isNameField
        ? (isGuarantor ? 'Enter Guarantor Name' : 'Enter Co-Applicant Name')
        : 'Enter $label';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isReq),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.fullNameController,
          keyboardType: TextInputType.name,
          maxLength: field.max,
          validator: (val) {
            final text = val?.trim() ?? '';
            if (isReq && text.isEmpty) {
              return 'Please enter $label';
            }
            if (isNameField && text.isNotEmpty && text.length < 2) {
              return 'Name must be at least 2 characters';
            }
            if (field.max != null && text.length > field.max!) {
              return 'Must not exceed ${field.max} characters';
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
            hintText: hint,
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
      ],
    );
  }

  /// Dynamic Document Upload Section rendered strictly from API response documents
  Widget _buildDocumentsUploadSection(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    return Obx(() {
      final docItems = controller.coAppDocuments;
      if (docItems.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header OUTSIDE container
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_rounded,
                    color: AppColors.navy,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Upload Documents',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Attach proofs for faster loan evaluation and verification.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Render document upload cards directly from API response items
          ...docItems.map((docItem) => _buildDocUploadCard(context, controller, docItem)),
        ],
      );
    });
  }

  /// Individual Document Upload Card matching Finsphere AI theme
  Widget _buildDocUploadCard(
    BuildContext context,
    ApplicantDetailsController controller,
    CoAppDocumentItem docItem,
  ) {
    final docKey = docItem.key ?? '';
    final docLabel = docItem.label ?? docKey;
    final isMulti = docItem.allowMultiple == true;
    final acceptedFormats = docItem.acceptedFormats.isNotEmpty
        ? docItem.acceptedFormats
        : ['pdf', 'jpg', 'jpeg', 'png'];
    final maxSize = docItem.maxSizeMb ?? 5;

    return Obx(() {
      final files = controller.coAppUploadedFiles[docKey] ?? [];
      final isUploaded = files.isNotEmpty;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.indigo.withValues(alpha: 0.35) : AppColors.line,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Leading Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUploaded ? AppColors.successGreenBg : AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isUploaded ? Icons.check_circle_rounded : _getDocIcon(docKey),
                    color: isUploaded ? AppColors.successGreen : AppColors.navy,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      docLabel,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (isUploaded)
                      Text(
                        files.length == 1
                            ? files.first.name
                            : '${files.length} files attached',
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Formats: ${acceptedFormats.join(', ').toUpperCase()} (Max ${maxSize}MB)',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Buttons
              if (isUploaded) ...[
                // Remove File Button
                GestureDetector(
                  onTap: () => controller.removeCoAppFile(docKey),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorRed,
                      size: 18,
                    ),
                  ),
                ),
                if (isMulti) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePickerBottomSheet.show(
                        context: context,
                        title: 'Upload $docLabel',
                      );
                      if (picked != null) {
                        controller.addCoAppFile(docKey, picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.navy,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ] else
                // Upload Button
                SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePickerBottomSheet.show(
                        context: context,
                        title: 'Upload $docLabel',
                      );
                      if (picked != null) {
                        controller.addCoAppFile(docKey, picked);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    label: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  IconData _getDocIcon(String key) {
    if (key == 'profile_image') return Icons.account_circle_outlined;
    if (key == 'aadhar_card') return Icons.badge_outlined;
    if (key == 'pan_card') return Icons.credit_card_outlined;
    if (key == 'bank_statement') return Icons.account_balance_outlined;
    if (key == 'latest_salary_slips') return Icons.receipt_long_outlined;
    if (key == 'form_16_itr' || key == 'gst_3b') return Icons.assignment_outlined;
    return Icons.description_outlined;
  }

  /// Label with red asterisk if required
  Widget _buildFieldLabel(String title, {bool isRequired = true}) {
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
        if (isRequired)
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

  Widget _buildSkeletonFieldPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
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
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isAddingCoApplicant.value
                      ? null
                      : () => controller.addCoApplicant(role: widget.role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isAddingCoApplicant.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Add ${widget.role}',
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
          ),
        ],
      ),
    );
  }
}
