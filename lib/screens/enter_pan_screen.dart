import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 1 of PAN KYC Flow: "Enter your PAN" (Reference Image 1)
class EnterPanScreen extends StatelessWidget {
  const EnterPanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 2),
            SizedBox(height: 12),
            Expanded(child: EnterPanBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Enter your PAN" (used within sticky-header KYC flow)
class EnterPanBody extends StatefulWidget {
  const EnterPanBody({super.key});

  @override
  State<EnterPanBody> createState() => _EnterPanBodyState();
}

class _EnterPanBodyState extends State<EnterPanBody> {
  late final PanKycController controller;
  late final FocusNode _panFocusNode;
  TextInputType _currentKeyboardType = TextInputType.text;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PanKycController>()
        ? Get.find<PanKycController>()
        : Get.put(PanKycController(), permanent: true);
    _panFocusNode = FocusNode();
    _currentKeyboardType = _getKeyboardTypeForLength(controller.panController.text.length);
    controller.panController.addListener(_onPanTextChanged);
  }

  @override
  void dispose() {
    controller.panController.removeListener(_onPanTextChanged);
    _panFocusNode.dispose();
    super.dispose();
  }

  TextInputType _getKeyboardTypeForLength(int length) {
    if (length < 5) {
      // First 5 characters (index 0-4): alphabetic
      return TextInputType.text;
    } else if (length < 9) {
      // Next 4 characters (index 5-8): numeric
      return TextInputType.number;
    } else {
      // Last character (index 9): alphabetic
      return TextInputType.text;
    }
  }

  void _onPanTextChanged() {
    final length = controller.panController.text.length;
    final newKeyboardType = _getKeyboardTypeForLength(length);

    if (newKeyboardType != _currentKeyboardType) {
      setState(() {
        _currentKeyboardType = newKeyboardType;
      });
      // Trigger keyboard refresh by unfocusing and refocusing
      if (_panFocusNode.hasFocus) {
        _panFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _panFocusNode.requestFocus();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Heading
                const Text(
                  'Enter your PAN',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Needed to check your credit profile and tax records.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),

                // Label
                const Text(
                  'PAN number',
                  style: TextStyle(
                    color: AppColors.inputLabel,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // PAN Text Field
                _buildPanInputField(controller),
                const SizedBox(height: 5),

                // Help caption
                const Text(
                  '10 characters • 5 letters, 4 numbers, 1 letter',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),

                // "Upload PAN card instead" Button
                _buildUploadInsteadButton(controller),
              ],
            ),
          ),
        ),

        // Bottom Action: Verify PAN Button
        _buildBottomSection(controller),
      ],
    );
  }

  /// PAN input text field
  Widget _buildPanInputField(PanKycController controller) {
    return TextFormField(
      controller: controller.panController,
      focusNode: _panFocusNode,
      keyboardType: _currentKeyboardType,
      onChanged: controller.onPanChanged,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        _UpperCaseTextFormatter(),
      ],
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'ABCDE1234F',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldFocusedBorder, width: 1.8),
        ),
        suffixIcon: Obx(() {
          if (controller.isPanFormatValid) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.successGreen,
                      size: 13,
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  /// "Upload PAN card instead" Button
  Widget _buildUploadInsteadButton(PanKycController controller) {
    return GestureDetector(
      onTap: controller.uploadPanCardInstead,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.line,
            width: 1.1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.badge_outlined,
              color: AppColors.primaryPurple,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Upload PAN card instead',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Verify PAN Button
  Widget _buildBottomSection(PanKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.verifyPan,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButtonBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify PAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
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
    );
  }
}

/// Automatically capitalizes all typed letters for PAN format
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
