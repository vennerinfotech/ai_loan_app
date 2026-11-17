import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';
import '../feature_placeholder_screen.dart';

/// Screen 3 of Apply Loan Flow: "Employment type" (Step 3 of 4)
class EmploymentTypeScreen extends StatelessWidget {
  const EmploymentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Back button, Segmented progress bar (3/4 active), and "3/4"
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
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

                  // 4-Segmented Progress Bar (3 active, 1 inactive)
                  _buildSegmentedProgress(activeSegments: 3, totalSegments: 4),

                  // "3/4" text
                  const Text(
                    '3/4',
                    style: TextStyle(
                      color: Color(0xFF5D6578),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading & Subtitle
                    const Text(
                      'How do you earn?',
                      style: TextStyle(
                        color: Color(0xFF1E2127),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This decides which documents we\'ll ask for.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4 Employment Options Cards
                    _buildEmploymentCardsList(controller),
                    const SizedBox(height: 16),

                    // Co-applicant Tip / Hint Card
                    _buildCoApplicantHintCard(),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: "Continue ->"
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  /// 4 horizontal capsule dashes for step 3/4
  Widget _buildSegmentedProgress({
    required int activeSegments,
    required int totalSegments,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSegments, (index) {
        final isActive = index < activeSegments;

        return Container(
          width: 22,
          height: 4.5,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF4A44D1)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildEmploymentCardsList(ApplyLoanController controller) {
    return Column(
      children: controller.employmentTypes.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Obx(() {
            final isSelected = controller.selectedEmploymentType.value == item.title;

            return GestureDetector(
              onTap: () => controller.selectEmploymentType(item.title),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF212074) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF212074)
                        : const Color(0xFFEEF2F6),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF212074).withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.02),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFDB022)
                            : const Color(0xFFEEF1FD),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconForEmployment(item.iconKey),
                          size: 21,
                          color: isSelected
                              ? const Color(0xFF212074)
                              : const Color(0xFF4340BE),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1E2127),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFD3D6F0)
                                  : const Color(0xFF6B7280),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Radio Button Indicator
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFDB022)
                              : const Color(0xFFCBD5E1),
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDB022),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  /// Light purple hint container explaining co-applicant benefits
  Widget _buildCoApplicantHintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E5FB),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: Color(0xFF4A44D1),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Adding a co-applicant with income can improve your eligibility. You can add one on the next step.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Get.to(
              () => const FeaturePlaceholderScreen(
                featureTitle: 'Loan Documents & Co-applicant (Step 4 of 4)',
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF212074),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFFFDB022),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForEmployment(String iconKey) {
    switch (iconKey) {
      case 'briefcase':
        return Icons.work_outline_rounded;
      case 'home_office':
        return Icons.storefront_outlined;
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'pension':
        return Icons.north_rounded;
      default:
        return Icons.person_outline_rounded;
    }
  }
}
