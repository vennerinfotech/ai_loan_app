import 'package:material_ui/material_ui.dart';
import '../../theme/app_colors.dart';
import 'package:get/get.dart';
import '../../controller/applicant_details_controller.dart';

/// Screen for adding a new co-applicant (Reference Image Right Screen)
class AddCoApplicantScreen extends StatelessWidget {
  const AddCoApplicantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ApplicantDetailsController>()
        ? Get.find<ApplicantDetailsController>()
        : Get.put(ApplicantDetailsController());

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    const Text(
                      'Who is applying with you?',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A co-applicant with steady income can raise your loan eligibility.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Relationship label & chips
                    const Text(
                      'Relationship',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRelationshipChips(controller),

                    const SizedBox(height: 20),

                    // Full Name
                    const Text(
                      'Full name',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFullNameField(controller),

                    const SizedBox(height: 18),

                    // Mobile Number
                    const Text(
                      'Mobile number',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMobileField(controller),

                    const SizedBox(height: 18),

                    // Date of birth & Monthly Income
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date of birth',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPillInput(
                                controller: controller.dobController,
                                hintText: 'DD / MM / YYYY',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly income',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildPillInput(
                                controller: controller.incomeController,
                                hintText: '₹ 0',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Info banner
                    _buildInfoBanner(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
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
          const Expanded(
            child: Center(
              child: Text(
                'Add co-applicant',
                style: TextStyle(
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

  /// Relationship selection chips
  Widget _buildRelationshipChips(ApplicantDetailsController controller) {
    return Obx(() {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: controller.relationshipOptions.map((rel) {
          final isSelected = controller.selectedRelationship.value == rel;
          return GestureDetector(
            onTap: () => controller.selectRelationship(rel),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.line,
                  width: 1.2,
                ),
              ),
              child: Text(
                rel,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Full name input field with dynamic focus styling
  Widget _buildFullNameField(ApplicantDetailsController controller) {
    return _CoAppFocusableField(
      controller: controller.fullNameController,
      hintText: 'Saanvi Mehta',
    );
  }

  /// Mobile number input field with country code prefix
  Widget _buildMobileField(ApplicantDetailsController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '+91',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 22,
            color: AppColors.line,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.mobileNumberController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: AppColors.indigo,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  color: AppColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable input pill box for DOB and Monthly Income
  Widget _buildPillInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppColors.indigo,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
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

  /// Bottom action button row: Cancel and Add co-applicant
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

          // Add co-applicant Button
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: controller.addCoApplicant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Add co-applicant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
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

/// Dynamic focusable input field for Co-Applicant
class _CoAppFocusableField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const _CoAppFocusableField({
    required this.controller,
    required this.hintText,
  });

  @override
  State<_CoAppFocusableField> createState() => _CoAppFocusableFieldState();
}

class _CoAppFocusableFieldState extends State<_CoAppFocusableField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 50,
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? AppColors.indigo : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
