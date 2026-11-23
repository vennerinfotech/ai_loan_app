import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../controller/apply_loan_controller.dart';
import '../../models/employment_type_model.dart';
import 'applicant_details_screen.dart';
import 'apply_loan_flow_screen.dart';

/// Screen 4 of Apply Loan Flow: "Upload documents / Employment & Proof" (Step 4 of 4)
/// Matches the web proof layout (media_1795169562743_35dfbd91.png):
/// 1. Card 1: 💼 Employment Details (text inputs: company, designation, salary, etc.)
/// 2. Card 2: 📄 Required Document Proofs (checkbox, dotted upload container, cloud icon)
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title matching web mockup (e.g. "Salaried Business Proof")
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
                  const SizedBox(height: 12),

                  // ==========================================
                  // Card 1: 💼 Employment Details (Strictly dynamic from detail_fields)
                  // ==========================================
                  _buildEmploymentDetailsCard(controller),
                  const SizedBox(height: 16),

                  // ==========================================
                  // Card 2: 📄 Required Document Proofs
                  // ==========================================
                  _buildRequiredDocumentProofsCard(controller, context),
                  const SizedBox(height: 16),
                ],
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
  // Card 1: Employment Details Card (Strictly dynamic per API response)
  // ==========================================
  Widget _buildEmploymentDetailsCard(ApplyLoanController controller) {
    final fields = controller.activeDetailFields;
    final salaryModes = controller.activeSalaryModes;

    // If API returned no detail fields for this employment type (e.g. Freelancer/Pensioner), hide card
    if (fields.isEmpty && salaryModes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
          // Header: Blue briefcase icon + "Employment Details"
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.business_center_rounded,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Employment Details',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                  () => _buildDropdownField(
                    label: label,
                    isRequired: isReq,
                    value: dropVal.value,
                    options: field.options,
                    onChanged: (val) {
                      if (val != null) dropVal.value = val;
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

          // Dynamic Salary Modes from API (e.g. Bank Salary, Cash Salary, Bank + Cash Salary)
          if (salaryModes.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildSalaryModesField(controller, salaryModes),
          ],
        ],
      ),
    );
  }

  Widget _buildSalaryModesField(ApplyLoanController controller, List<SalaryModeItem> salaryModes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Salary Mode',
          style: TextStyle(
            color: Color(0xFF334155),
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
                    color: isSel ? const Color(0xFF1E1B4B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? const Color(0xFF1E1B4B) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ==========================================
  // Card 2: Required Document Proofs Card (Filtered per API)
  // ==========================================
  Widget _buildRequiredDocumentProofsCard(ApplyLoanController controller, BuildContext context) {
    // Filter documents from POST /loan/employment-type:
    // Exclude property documents & already uploaded KYC documents
    final dynamicDocs = controller.dynamicDocuments.where((doc) {
      final cat = doc.category?.toLowerCase() ?? '';
      final key = doc.key?.toLowerCase() ?? '';
      if (cat == 'property') return false;
      if (key == 'aadhar_card_front' || key == 'pan_card_image') return false;
      return true;
    }).toList();

    final hasDynamic = dynamicDocs.isNotEmpty;

    return Container(
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
          // Header: Blue document icon + "Required Document Proofs"
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_rounded,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Required Document Proofs',
                style: TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (hasDynamic)
            ...dynamicDocs.map((doc) => _buildDynamicDocProofItem(controller, doc, context))
          else
            ...controller.activeDocs.map((doc) => _buildStaticDocProofItem(controller, doc, context)),
        ],
      ),
    );
  }

  /// Document Proof Item matching web design (Dotted border container with cloud icon)
  Widget _buildDynamicDocProofItem(
    ApplyLoanController controller,
    LoanDocumentItem doc,
    BuildContext context,
  ) {
    final key = doc.key ?? '';
    final label = doc.label ?? key;

    return Obx(() {
      final isChecked = controller.selectedDocCheckboxes[key] ?? true;
      final fileName = controller.uploadedDocFileNames[key];
      final isUploaded = doc.uploaded == true || (fileName != null && fileName.isNotEmpty);
      final isUploading = controller.uploadingDocKeys[key] == true;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? const Color(0xFF4F46E5) : AppColors.line,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox + Document Label
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.selectedDocCheckboxes[key] = !isChecked;
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isChecked ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isChecked ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Center(
                            child: Icon(Icons.check, size: 14, color: Colors.white),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isUploaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Text(
                      'Uploaded ✓',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Dashed / Dotted Upload Container with Cloud Icon
            GestureDetector(
              onTap: () => controller.pickAndUploadDynamicDoc(doc, context: context),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: isUploaded ? const Color(0xFF818CF8) : const Color(0xFFCBD5E1),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isUploading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Color(0xFF4F46E5),
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        )
                      : isUploaded
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName ?? '$label uploaded',
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Tap to change file',
                                        style: TextStyle(
                                          color: Color(0xFF6366F1),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => controller.removeDynamicDoc(doc),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF64748B),
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to upload $label',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PDF, JPG or PNG (up to ${doc.maxSizeMb ?? 5} MB)',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
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
    });
  }

  /// Fallback static document proof item
  Widget _buildStaticDocProofItem(
    ApplyLoanController controller,
    LoanDocItem doc,
    BuildContext context,
  ) {
    return Obx(() {
      final isAdded = doc.isAdded.value;
      final isUploading = doc.isUploading.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAdded ? const Color(0xFF4F46E5) : AppColors.line,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isAdded ? const Color(0xFF4F46E5) : const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    doc.title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isAdded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Text(
                      'Uploaded ✓',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => controller.pickAndUploadDocument(doc, context: context),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: isAdded ? const Color(0xFF818CF8) : const Color(0xFFCBD5E1),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isUploading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Color(0xFF4F46E5),
                                strokeWidth: 2.2,
                              ),
                            ),
                          ),
                        )
                      : isAdded
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    doc.fileName.value.isNotEmpty
                                        ? doc.fileName.value
                                        : '${doc.title} uploaded',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => controller.removeDocument(doc),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF64748B),
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap to upload ${doc.title}',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'PDF, JPG or PNG (up to 5 MB)',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
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
    });
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    final validValue = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: options.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
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
        child: ElevatedButton(
          onPressed: () {
            // Save details & advance to Applicant Details
            Get.to(() => const ApplicantDetailsScreen());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Save & Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter to draw a clean dashed/dotted border matching web UI
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({
    this.color = const Color(0xFFCBD5E1),
  });

  static const double strokeWidth = 1.2;
  static const double gap = 4.0;
  static const double dash = 6.0;
  static const double radius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final currentLength = (distance + dash < metric.length) ? dash : metric.length - distance;
        final extract = metric.extractPath(distance, distance + currentLength);
        canvas.drawPath(extract, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
