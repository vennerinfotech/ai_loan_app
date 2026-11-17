import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';

/// Screen 4 of Apply Loan Flow: "Upload documents" (Step 4 of 4)
/// Dynamically adapts to all 4 employment types:
/// - Salaried: Circular progress ring, uploaded files with trash icon, uploading progress card, Employee ID upload, alert notice, "Save draft" + "Submit application →"
/// - Self-employed / Business: Business proof header, horizontal progress bar, 9 proof items with "✓ Added" / "Upload" button, "Back" + "Save & continue →"
/// - Freelancer: Freelancer proof header, horizontal progress bar, 6 proof items, "Back" + "Save & continue →"
/// - Pensioner: Pensioner proof header, horizontal progress bar, 6 proof items, "Back" + "Save & continue →"
class UploadDocumentsScreen extends StatelessWidget {
  const UploadDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar: Back button & "Step 4 of 4"
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF1E2127),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Step 4 of 4',
                    style: TextStyle(
                      color: Color(0xFF5D6578),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Dynamic Scrollable Documents Content
            Expanded(
              child: Obx(() {
                final empType = controller.selectedEmploymentType.value.toLowerCase();
                final isSalaried = empType.contains('salaried') && !empType.contains('self');

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section (Circular for Salaried, Icon + Title for others)
                      if (isSalaried)
                        _buildSalariedHeader(controller)
                      else
                        _buildOtherEmploymentHeader(controller),

                      const SizedBox(height: 16),

                      // Document List (Unified for all employment types with live progress & delete icon)
                      _buildDocList(controller, controller.activeDocs, context),

                      const SizedBox(height: 14),

                      // Warning Alert Note (Displayed for Salaried as per reference design)
                      if (isSalaried) ...[
                        _buildAlertNotice(),
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                );
              }),
            ),

            // 3. Bottom Action Buttons
            _buildBottomButtons(context, controller),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Header Implementations
  // ==========================================

  /// Salaried Header with Circular Progress ring + Title + Subtitle
  Widget _buildSalariedHeader(ApplyLoanController controller) {
    return Obx(() {
      final addedCount = controller.activeAddedCount;
      final totalCount = controller.salariedDocs.length;
      final progress = totalCount > 0 ? (addedCount / totalCount).clamp(0.0, 1.0) : 0.0;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Indicator Ring with "2/4"
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5.5,
                    backgroundColor: const Color(0xFFE2E6F5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4340BE)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '$addedCount/$totalCount',
                  style: const TextStyle(
                    color: Color(0xFF1E2127),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Title & Subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salaried documents',
                  style: TextStyle(
                    color: Color(0xFF1E2127),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'PDF, JPG or PNG · up to 5 MB each',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Self-employed / Freelancer / Pensioner Header
  Widget _buildOtherEmploymentHeader(ApplyLoanController controller) {
    final type = controller.selectedEmploymentType.value.toLowerCase();
    String title = 'Business proof';
    String subtitle = 'Self-employed / business owner';
    IconData icon = Icons.storefront_rounded;

    if (type.contains('freelancer')) {
      title = 'Freelancer proof';
      subtitle = 'Project-based work for multiple clients';
      icon = Icons.laptop_mac_rounded;
    } else if (type.contains('pension')) {
      title = 'Pensioner proof';
      subtitle = 'Receiving retirement or pension benefits';
      icon = Icons.north_rounded;
    }

    return Obx(() {
      final addedCount = controller.activeAddedCount;
      final totalCount = controller.activeDocs.length;
      final progress = totalCount > 0 ? addedCount / totalCount : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Navy icon container + Title & Subtitle
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF212074),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: const Color(0xFFFDB022),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1E2127),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E6F5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4340BE)),
            ),
          ),
          const SizedBox(height: 8),

          // Counts & File info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$addedCount of $totalCount added',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'PDF, JPG, PNG · max 5 MB',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ==========================================
  // Document Card Lists
  // ==========================================

  /// Unified Document Cards List for all employment types (Salaried, Self-employed, Freelancer, Pensioner)
  /// Features:
  /// - Pending state: Document icon, title, subtitle, and solid navy "Upload" button
  /// - Uploading state: Royal purple border, live upload progress bar inside card with percentage & cancel '✕'
  /// - Added state: Green checkmark icon, file name & size, and trash can delete icon to remove document
  Widget _buildDocList(ApplyLoanController controller, List<LoanDocItem> docs, BuildContext context) {
    return Column(
      children: docs.map((doc) {
        return Obx(() {
          final isAdded = doc.isAdded.value;
          final isUploading = doc.isUploading.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUploading
                    ? const Color(0xFF4340BE)
                    : const Color(0xFFEEF2F6),
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
                      // Leading Icon
                      _buildDocLeadingIcon(doc),
                      const SizedBox(width: 14),

                      // Text: Title + Subtitle/filename/progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              style: const TextStyle(
                                color: Color(0xFF1E2127),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (isUploading)
                              const Text(
                                'Uploading...',
                                style: TextStyle(
                                  color: Color(0xFF4340BE),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else if (isAdded)
                              Text(
                                '${doc.fileName.value} · ${doc.fileSize.value}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            else
                              Text(
                                doc.subtitle.isNotEmpty
                                    ? doc.subtitle
                                    : 'Upload document',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Trailing Action: Trash icon if added, '✕' if uploading, 'Upload' button if pending
                      if (isAdded)
                        GestureDetector(
                          onTap: () => controller.removeDocument(doc),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        )
                      else if (isUploading)
                        GestureDetector(
                          onTap: () => controller.removeDocument(doc),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => controller.pickAndUploadDocument(doc, context: context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF212074),
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
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Color(0xFFE2E6F5),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4340BE)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildDocLeadingIcon(LoanDocItem doc) {
    final isAdded = doc.isAdded.value;
    final isUploading = doc.isUploading.value;

    if (isAdded) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F7D8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.check_rounded,
            color: Color(0xFF15803D),
            size: 20,
          ),
        ),
      );
    } else if (isUploading) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.upload_rounded,
            color: Color(0xFF4340BE),
            size: 20,
          ),
        ),
      );
    } else {
      IconData icon = Icons.description_outlined;
      final title = doc.title.toLowerCase();
      if (title.contains('id')) {
        icon = Icons.badge_outlined;
      } else if (title.contains('statement')) {
        icon = Icons.account_balance_outlined;
      } else if (title.contains('licence') || title.contains('license') || title.contains('certificate')) {
        icon = Icons.verified_outlined;
      } else if (title.contains('invoice') || title.contains('slip') || title.contains('payment') || title.contains('order')) {
        icon = Icons.receipt_long_outlined;
      }

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF4340BE),
            size: 20,
          ),
        ),
      );
    }
  }

  /// Warning Alert Box: "Make sure all four corners are visible..."
  Widget _buildAlertNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE0B8), width: 1.0),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFC25D00),
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Make sure all four corners are visible and text is readable — blurry photos slow down approval.',
              style: TextStyle(
                color: Color(0xFF8A3C00),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Bottom Action Buttons
  // ==========================================

  Widget _buildBottomButtons(BuildContext context, ApplyLoanController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: Obx(() {
        final empType = controller.selectedEmploymentType.value.toLowerCase();
        final isSalaried = empType.contains('salaried') && !empType.contains('self');

        final leftLabel = isSalaried ? 'Save draft' : 'Back';
        final rightLabel = isSalaried ? 'Submit application' : 'Save & continue';

        return Row(
          children: [
            // Left Button: "Save draft" or "Back"
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSalaried) {
                      Get.snackbar(
                        'Draft Saved',
                        'Your uploaded documents have been saved as draft.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF212074),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F6FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFDDE3F0), width: 1.2),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    leftLabel,
                    style: const TextStyle(
                      color: Color(0xFF1E2127),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Right Button: "Submit application →" or "Save & continue →"
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showSubmissionSuccessDialog(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212074),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rightLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFFDB022),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showSubmissionSuccessDialog(BuildContext context, ApplyLoanController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F7D8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF15803D),
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  color: Color(0xFF1E2127),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ${controller.selectedLoanType.value} application for ${controller.formatIndianCurrency(controller.loanAmount.value)} has been submitted successfully.\n\nAI eligibility review in under 3 minutes.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.until((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212074),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
