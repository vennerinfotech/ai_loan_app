import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';
import 'apply_loan_flow_screen.dart';

/// Screen 3 of Apply Loan Flow: "Employment type" (Step 3 of 4)
class EmploymentTypeScreen extends StatelessWidget {
  const EmploymentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApplyLoanFlowScreen(initialStep: 3);
  }
}

/// Content body of "Employment type" (used within sticky-header Loan Flow)
class EmploymentTypeBody extends StatelessWidget {
  const EmploymentTypeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();

    return Column(
      children: [
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

        // Bottom CTA Buttons: Back & Continue
        _buildBottomButtons(context, controller),
      ],
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

  Widget _buildBottomButtons(BuildContext context, ApplyLoanController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => controller.handleBack(),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDDE3F0),
                  width: 1.2,
                ),
              ),
              child: const Center(
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF1E2127),
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
              child: ElevatedButton(
                onPressed: () {
                  controller.goToStep(4);
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
          ),
        ],
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
