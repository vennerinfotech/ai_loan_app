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
  final bool isEdit;
  final dynamic coApplicantId;

  const AddCoApplicantScreen({
    super.key,
    this.role = 'Co-Applicant',
    this.isEdit = false,
    this.coApplicantId,
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

    // Fetch form options strictly when Add/Edit Co-Applicant screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchCoApplicantFormOptions();
      if (widget.isEdit && widget.coApplicantId != null) {
        await controller.fetchAndPopulateCoApplicantForEdit(widget.coApplicantId);
      }
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
                widget.isEdit
                    ? 'Edit ${widget.role.toLowerCase()}'
                    : 'Add ${widget.role.toLowerCase()}',
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
            validator: isReq
                ? (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null
                : null,
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
            validator: isReq
                ? (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null
                : null,
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
            validator: isReq
                ? (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null
                : null,
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
          validator: isReq
              ? (v) => (v == null || v.trim().isEmpty) ? 'Please select $label' : null
              : null,
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
    final docLabel = docItem.label?.isNotEmpty == true
        ? docItem.label!
        : _formatDocKey(docKey);
    final isMulti = docItem.allowMultiple == true;
    final acceptedFormats = docItem.acceptedFormats.isNotEmpty
        ? docItem.acceptedFormats
        : ['pdf', 'jpg', 'jpeg', 'png'];
    final maxSize = docItem.maxSizeMb ?? 5;

    return Obx(() {
      final localFiles = controller.coAppUploadedFiles[docKey] ?? [];
      final existingFiles = controller.coAppExistingFiles[docKey] ?? [];
      final hasLocal = localFiles.isNotEmpty;
      final hasExisting = existingFiles.isNotEmpty;
      final isUploaded = hasLocal || hasExisting;
      final docError = controller.coAppDocumentErrors[docKey];
      final hasError = docError != null && docError.isNotEmpty;

      // Subtitle text
      final String subtitleText;
      final Color subtitleColor;
      if (hasError) {
        subtitleText = docError;
        subtitleColor = AppColors.errorRed;
      } else if (hasLocal) {
        subtitleText = localFiles.length == 1
            ? '${localFiles.first.name} (New)'
            : '${localFiles.length} new files selected';
        subtitleColor = AppColors.indigo;
      } else if (hasExisting) {
        subtitleText = existingFiles.length == 1
            ? (existingFiles.first['name']?.toString() ?? 'Uploaded ✓')
            : '${existingFiles.length} files attached';
        subtitleColor = AppColors.successGreen;
      } else {
        subtitleText = 'Formats: ${acceptedFormats.join(', ').toUpperCase()} (Max ${maxSize}MB)';
        subtitleColor = AppColors.muted;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError
                ? AppColors.errorRed
                : isUploaded
                    ? AppColors.indigo.withValues(alpha: 0.35)
                    : AppColors.line,
            width: hasError ? 1.5 : 1.2,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Leading Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: hasError
                          ? AppColors.errorRedBg
                          : isUploaded
                              ? AppColors.successGreenBg
                              : AppColors.indigoTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        hasError
                            ? Icons.error_outline_rounded
                            : isUploaded
                                ? Icons.check_circle_rounded
                                : _getDocIcon(docKey),
                        color: hasError
                            ? AppColors.errorRed
                            : isUploaded
                                ? AppColors.successGreen
                                : AppColors.navy,
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
                        Text(
                          subtitleText,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11.5,
                            fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Action Buttons
                  if (controller.uploadingDocKeys.contains(docKey)) ...[
                    // Loading indicator while uploading single doc
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ] else if (isUploaded) ...[
                    // Remove File Button
                    GestureDetector(
                      onTap: () {
                        _showDeleteDocConfirmationDialog(
                          context: context,
                          controller: controller,
                          docLabel: docLabel,
                          docKey: docKey,
                          file: existingFiles.length == 1 ? existingFiles.first : null,
                          coApplicantId: widget.coApplicantId,
                        );
                      },
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
                    const SizedBox(width: 6),
                    // Re-upload / Replace / Add Button
                    GestureDetector(
                      onTap: () => _handleUploadOrReupload(context, controller, docKey, docLabel),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isMulti ? Icons.add_rounded : Icons.replay_rounded,
                          color: AppColors.navy,
                          size: 18,
                        ),
                      ),
                    ),
                  ] else
                    // Upload Button
                    SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleUploadOrReupload(context, controller, docKey, docLabel),
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
              if (hasError) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.errorRedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          docError,
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // List attached individual files if multi-file or multiple files attached
              if (existingFiles.length > 1 || localFiles.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...existingFiles.map((f) => _buildAttachedFileItem(
                      context,
                      controller,
                      docKey: docKey,
                      docLabel: docLabel,
                      fileName: f['name']?.toString() ?? 'Document File',
                      isServerFile: true,
                      fileData: f,
                    )),
                ...localFiles.asMap().entries.map((entry) => _buildAttachedFileItem(
                      context,
                      controller,
                      docKey: docKey,
                      docLabel: docLabel,
                      fileName: entry.value.name,
                      isServerFile: false,
                      localIndex: entry.key,
                    )),
              ],
            ],
          ),
        ),
      );
    });
  }

  /// Individual attached file item row with file name and delete button
  Widget _buildAttachedFileItem(
    BuildContext context,
    ApplicantDetailsController controller, {
    required String docKey,
    required String docLabel,
    required String fileName,
    required bool isServerFile,
    Map<String, dynamic>? fileData,
    int? localIndex,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 16,
            color: AppColors.navy,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          // Re-upload / Replace icon button for single attached file
          GestureDetector(
            onTap: () => _handleUploadOrReupload(context, controller, docKey, docLabel),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.replay_rounded,
                color: AppColors.navy,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Delete icon button
          GestureDetector(
            onTap: () {
              _showDeleteDocConfirmationDialog(
                context: context,
                controller: controller,
                docLabel: docLabel,
                docKey: docKey,
                file: fileData,
                localIndex: localIndex,
                coApplicantId: widget.coApplicantId,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorRed,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle document pick and immediate server upload (in edit mode) or local staging
  Future<void> _handleUploadOrReupload(
    BuildContext context,
    ApplicantDetailsController controller,
    String docKey,
    String docLabel,
  ) async {
    final picked = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload $docLabel',
    );
    if (picked != null) {
      if (widget.isEdit && widget.coApplicantId != null) {
        await controller.uploadSingleDocOnServer(
          coApplicantId: widget.coApplicantId,
          docKey: docKey,
          file: picked,
        );
      } else {
        controller.addCoAppFile(docKey, picked);
      }
    }
  }

  /// Show delete confirmation dialog before deleting document from API or draft
  void _showDeleteDocConfirmationDialog({
    required BuildContext context,
    required ApplicantDetailsController controller,
    required String docLabel,
    required String docKey,
    Map<String, dynamic>? file,
    int? localIndex,
    dynamic coApplicantId,
  }) {
    final fileName = file?['name']?.toString() ?? docLabel;
    final isServerDoc = coApplicantId != null &&
        (controller.coAppExistingFiles[docKey]?.isNotEmpty == true ||
            (file != null && file['doc_key'] != null));

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red warning icon in circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Delete Document',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Are you sure you want to delete "$fileName"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // Action buttons (Cancel & Delete)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isDeletingCoAppDoc.value
                              ? null
                              : () async {
                                  if (isServerDoc) {
                                    final targetDocKey = file?['doc_key']?.toString() ?? docKey;
                                    final targetIndex = file?['index'];
                                    final success = await controller.deleteCoAppDocumentOnServer(
                                      coApplicantId: coApplicantId,
                                      docKey: targetDocKey,
                                      index: targetIndex,
                                    );
                                    if (success) {
                                      if (Get.isDialogOpen == true) {
                                        Get.back();
                                      }
                                    }
                                  } else {
                                    // Local file removal
                                    controller.removeCoAppFile(docKey, localIndex);
                                    if (Get.isDialogOpen == true) {
                                      Get.back();
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isDeletingCoAppDoc.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  IconData _getDocIcon(String key) {
    if (key == 'profile_image') return Icons.account_circle_outlined;
    if (key.contains('aadhar') || key.contains('aadhaar')) return Icons.badge_outlined;
    if (key.contains('pan')) return Icons.credit_card_outlined;
    if (key == 'bank_statement') return Icons.account_balance_outlined;
    if (key == 'latest_salary_slips') return Icons.receipt_long_outlined;
    if (key == 'form_16_itr' || key == 'gst_3b') return Icons.assignment_outlined;
    return Icons.description_outlined;
  }

  String _formatDocKey(String key) {
    if (key == 'aadhar_card_front') return 'Aadhaar Card (Front)';
    if (key == 'aadhar_card_back') return 'Aadhaar Card (Back)';
    if (key == 'aadhar_card_combined_pdf') return 'Aadhaar Card (Single PDF)';
    if (key == 'aadhar_card' || key == 'aadhaar_card') return 'Aadhaar Card';
    if (key == 'pan_card_image' || key == 'pan_card') return 'PAN Card';
    if (key == 'profile_image') return 'Co-Applicant Photo';
    if (key == 'latest_salary_slips') return 'Salary Slip';
    if (key == 'bank_statement') return 'Bank Statement';
    if (key == 'form_16_itr') return 'Form 16 / ITR';
    if (key == 'salary_letterpad') return 'Company Letterpad';
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
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
                      : () async {
                          bool success = false;
                          final editId = widget.coApplicantId ?? controller.currentDraftCoAppId.value;
                          if (editId != null) {
                            success = await controller.updateCoApplicant(
                              coApplicantId: editId,
                              role: widget.role,
                            );
                          } else {
                            success = await controller.addCoApplicant(role: widget.role);
                          }
                          if (success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
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
                              widget.isEdit
                                  ? 'Update ${widget.role}'
                                  : 'Add ${widget.role}',
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
