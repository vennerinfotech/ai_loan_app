import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../controller/apply_loan_controller.dart';
import '../../models/employment_type_model.dart';
import '../../widgets/custom_dropdown.dart';
import 'apply_loan_flow_screen.dart';

/// Screen 4 of Apply Loan Flow: "Upload documents / Employment & Proof" (Step 4 of 4)
/// 1. Section 1: Employment Details (Header outside container, dynamic input fields card inside)
/// 2. Section 2: Required Document Proofs (Header outside, cards styled like demo UI with leading icon, title, subtitle & solid upload button)
/// 3. Bottom: Save & Continue button
class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApplyLoanFlowScreen(initialStep: 4);
  }
}

/// Content body of "Upload documents" (used within sticky-header Loan Flow)
class UploadDocumentsBody extends StatelessWidget {
  const UploadDocumentsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return Column(
      children: [
        // Dynamic Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() {
              final empType = controller.selectedEmploymentType.value;

              return Form(
                key: controller.uploadDocsFormKey,
                autovalidateMode: controller.autoValidateUploadDocs.value
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title matching flow (e.g. "Salaried Business Proof" or "Employment Proof")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$empType Business Proof',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.handleBack(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.muted,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ==========================================
                    // Section 1: Employment Details (Header outside container)
                    // ==========================================
                    _buildEmploymentDetailsSection(controller),

                    // ==========================================
                    // Section 2: Required Document Proofs (Header outside, cards matching demo UI)
                    // ==========================================
                    _buildRequiredDocumentProofsSection(controller, context),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
          ),
        ),

        // Bottom CTA Buttons (Save & Continue)
        _buildBottomButtons(context, controller),
      ],
    );
  }

  // ==========================================
  // Section 1: Employment Details (Header OUTSIDE container)
  // ==========================================
  Widget _buildEmploymentDetailsSection(ApplyLoanController controller) {
    final fields = controller.activeDetailFields;
    final salaryModes = controller.activeSalaryModes;

    // If API returned no detail fields for this employment type, hide section
    if (fields.isEmpty && salaryModes.isEmpty) {
      return const SizedBox.shrink();
    }

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
                  Icons.business_center_rounded,
                  color: AppColors.navy,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Employment Details',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Container holding all detail fields
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
            children: [
              // Render ONLY the fields returned in detail_fields for the selected employment type
              ...fields.map((field) {
                final name = field.name ?? '';
                final label = field.label ?? name;
                final isReq = field.required == true;
                final type = field.type?.toLowerCase() ?? 'text';

                if (type == 'select' && field.options.isNotEmpty) {
                  final dropVal = controller.getDropdownValueForField(name, field.options.first);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Obx(
                      () => CustomAppDropdown(
                        label: label,
                        isRequired: isReq,
                        value: dropVal.value,
                        items: field.options,
                        validator: isReq
                            ? (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please select $label';
                                }
                                return null;
                              }
                            : null,
                        onChanged: (val) {
                          dropVal.value = val;
                        },
                      ),
                    ),
                  );
                }

                final textCtrl = controller.getControllerForField(name);
                final isNum = type == 'number';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTextField(
                    label: label,
                    isRequired: isReq,
                    hintText: 'Enter $label',
                    controller: textCtrl,
                    keyboardType: isNum ? TextInputType.number : TextInputType.text,
                  ),
                );
              }),

              // Dynamic Salary Modes from API
              if (salaryModes.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildSalaryModesField(controller, salaryModes),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildSalaryModesField(ApplyLoanController controller, List<SalaryModeItem> salaryModes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salary Mode',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final currentMode = controller.selectedSalaryMode.value.isNotEmpty
              ? controller.selectedSalaryMode.value
              : (salaryModes.first.key ?? '');

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: salaryModes.map((mode) {
              final key = mode.key ?? '';
              final label = mode.label ?? key;
              final isSel = currentMode == key;

              return GestureDetector(
                onTap: () => controller.selectedSalaryMode.value = key,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.navy : AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? AppColors.navy : AppColors.line,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSel ? Colors.white : AppColors.textDark,
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),

        // If current selected salary mode requires extra fields (e.g. cash_salary_amount, bank_salary_amount)
        Obx(() {
          final currentModeKey = controller.selectedSalaryMode.value.isNotEmpty
              ? controller.selectedSalaryMode.value
              : (salaryModes.first.key ?? '');
          final currentMode = salaryModes.firstWhereOrNull((m) => m.key == currentModeKey);
          if (currentMode != null && currentMode.requires.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                ...currentMode.requires.map((req) {
                  final label = req == 'cash_salary_amount'
                      ? 'Cash Salary Amount'
                      : (req == 'bank_salary_amount'
                          ? 'Bank Salary Amount'
                          : req.replaceAll('_', ' ').capitalizeFirst ?? req);
                  final textCtrl = controller.getControllerForField(req);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTextField(
                      label: label,
                      isRequired: true,
                      hintText: 'Enter $label',
                      controller: textCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // ==========================================
  // Section 2: Required Document Proofs (Strictly from POST /loan/store-amount)
  // ==========================================
  Widget _buildRequiredDocumentProofsSection(ApplyLoanController controller, BuildContext context) {
    // Documents loaded dynamically directly from POST /loan/store-amount API without static filtering
    final dynamicDocs = controller.dynamicDocuments;

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
              'Required Document Proofs',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Only render documents from POST /loan/store-amount API
        if (dynamicDocs.isNotEmpty)
          ...dynamicDocs.map((doc) => _buildDemoStyleDynamicDocCard(controller, doc, context))
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: const Center(
              child: Text(
                'No additional document proofs required for this loan selection.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Individual Document Card matching the demo UI:
  /// Leading icon (40x40 squircle), title, subtitle/filename, and compact solid "Upload" button / delete icon
  Widget _buildDemoStyleDynamicDocCard(
    ApplyLoanController controller,
    LoanDocumentItem doc,
    BuildContext context,
  ) {
    final key = doc.key ?? '';
    final label = doc.label ?? key;

    return Obx(() {
      final fileName = controller.uploadedDocFileNames[key];
      final fileSize = controller.uploadedDocFileSizes[key];
      final isUploaded = doc.uploaded == true || (fileName != null && fileName.isNotEmpty);
      final isUploading = controller.uploadingDocKeys[key] == true;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploading
                ? AppColors.indigo
                : (isUploaded ? AppColors.indigo.withValues(alpha: 0.35) : AppColors.line),
            width: isUploading ? 1.4 : 1.2,
          ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Leading Icon (soft purple squircle, or green checkmark when uploaded)
                  _buildDocLeadingIcon(label, isUploaded, isUploading),
                  const SizedBox(width: 14),

                  // Text: Title + Subtitle / File info / Uploading
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (isUploading)
                          const Text(
                            'Uploading...',
                            style: TextStyle(
                              color: AppColors.indigo,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (isUploaded)
                          Text(
                            fileName != null && fileName.isNotEmpty
                                ? '$fileName${fileSize != null ? ' · $fileSize' : ''}'
                                : 'Uploaded ✓',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            doc.acceptedFormats.isNotEmpty
                                ? '${doc.acceptedFormats.join(', ')} · max ${doc.maxSizeMb ?? 5} MB'
                                : 'PDF, JPG or PNG · max ${doc.maxSizeMb ?? 5} MB',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Trailing Action: Solid "Upload" button or delete icon
                  if (isUploaded)
                    GestureDetector(
                      onTap: () => controller.removeDynamicDoc(doc),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.muted,
                          size: 19,
                        ),
                      ),
                    )
                  else if (isUploading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.indigo,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => controller.pickAndUploadDynamicDoc(doc, context: context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Smooth linear progress bar widget inside the card during upload
            if (isUploading)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppColors.indigoTint,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// 40x40 Leading Icon container for document cards
  Widget _buildDocLeadingIcon(String label, bool isUploaded, bool isUploading) {
    if (isUploaded) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.successGreenBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            color: AppColors.successGreen,
            size: 20,
          ),
        ),
      );
    } else if (isUploading) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.indigoTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.upload_rounded,
            color: AppColors.indigo,
            size: 20,
          ),
        ),
      );
    } else {
      IconData icon = Icons.description_outlined;
      final lower = label.toLowerCase();
      if (lower.contains('id') || lower.contains('card')) {
        icon = Icons.badge_outlined;
      } else if (lower.contains('statement') || lower.contains('bank')) {
        icon = Icons.account_balance_outlined;
      } else if (lower.contains('slip') || lower.contains('salary')) {
        icon = Icons.receipt_long_outlined;
      } else if (lower.contains('tax') || lower.contains('itr') || lower.contains('form')) {
        icon = Icons.request_quote_outlined;
      } else if (lower.contains('gst') ||
          lower.contains('licence') ||
          lower.contains('license') ||
          lower.contains('registration') ||
          lower.contains('certificate') ||
          lower.contains('udyam') ||
          lower.contains('moa')) {
        icon = Icons.verified_outlined;
      }

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.indigoTint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppColors.indigo,
            size: 20,
          ),
        ),
      );
    }
  }

  // ==========================================
  // Form Field Helper Widgets
  // ==========================================
  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ??
              (val) {
                final text = val?.trim() ?? '';
                if (isRequired && text.isEmpty) {
                  return 'Please enter $label';
                }
                if (keyboardType == TextInputType.number && text.isNotEmpty) {
                  final numVal = num.tryParse(text);
                  if (numVal == null || numVal <= 0) {
                    return 'Please enter a valid amount';
                  }
                }
                if (keyboardType == TextInputType.phone && text.isNotEmpty) {
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
                    return '$label must be 10 digits';
                  }
                }
                return null;
              },
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.line, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
            ),
            errorStyle: const TextStyle(
              color: AppColors.errorRed,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }


  // ==========================================
  // Bottom Action Buttons
  // ==========================================
  Widget _buildBottomButtons(BuildContext context, ApplyLoanController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.isSubmittingLead.value
                ? null
                : () => controller.submitLoanApplication(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: controller.isSubmittingLead.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save & Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.amber,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
