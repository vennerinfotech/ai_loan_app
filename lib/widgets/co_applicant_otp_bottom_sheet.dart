import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controller/applicant_details_controller.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// Modal Bottom Sheet for Co-Applicant OTP verification:
/// Step 0: Enter/Confirm Mobile Number -> Send OTP
/// Step 1: Enter 6-digit OTP using Pinput -> Verify OTP
class CoApplicantOtpBottomSheet extends StatefulWidget {
  final ApplicantDetailsController? controller;
  final dynamic coApplicantId;
  final String coApplicantName;
  final String? initialPhone;
  final VoidCallback? onVerified;

  const CoApplicantOtpBottomSheet({
    super.key,
    this.controller,
    required this.coApplicantId,
    required this.coApplicantName,
    this.initialPhone,
    this.onVerified,
  });

  /// Static helper to display this bottom sheet anywhere
  static Future<void> show({
    required BuildContext context,
    ApplicantDetailsController? controller,
    required dynamic coApplicantId,
    required String coApplicantName,
    String? initialPhone,
    VoidCallback? onVerified,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoApplicantOtpBottomSheet(
        controller: controller,
        coApplicantId: coApplicantId,
        coApplicantName: coApplicantName,
        initialPhone: initialPhone,
        onVerified: onVerified,
      ),
    );
  }

  @override
  State<CoApplicantOtpBottomSheet> createState() =>
      _CoApplicantOtpBottomSheetState();
}

class _CoApplicantOtpBottomSheetState extends State<CoApplicantOtpBottomSheet> {
  int _currentStep = 0; // 0 = Phone input, 1 = OTP input
  late final TextEditingController _phoneController;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  String _maskedPhone = '';
  dynamic _devOtp;
  int _resendSeconds = 30;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicantDetailsController get _effectiveController =>
      widget.controller ??
      (Get.isRegistered<ApplicantDetailsController>()
          ? Get.find<ApplicantDetailsController>()
          : Get.put(ApplicantDetailsController()));

  @override
  void initState() {
    super.initState();
    // Clean initial phone (extract 10 digits)
    String cleanPhone = (widget.initialPhone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length > 10) {
      cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
    }
    _phoneController = TextEditingController(text: cleanPhone);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _resendSeconds = seconds;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _resendSeconds = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendSeconds--;
          });
        }
      }
    });
  }

  /// Send OTP to co-applicant phone
  Future<void> _handleSendOtp() async {
    final phoneText = _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneText.length != 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _effectiveController.sendCoApplicantOtp(
        coApplicantId: widget.coApplicantId,
        phone: phoneText,
      );

      final isSuccess = res['success'] == true || res['status_code'] == 200;
      if (isSuccess) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        final returnedPhone = data['phone']?.toString();
        final rawOtp = data['otp'];
        final resendAfter = data['resend_after_seconds'] is int
            ? data['resend_after_seconds'] as int
            : 30;

        setState(() {
          _maskedPhone = (returnedPhone != null && returnedPhone.isNotEmpty)
              ? returnedPhone
              : '******${phoneText.substring(phoneText.length - 4)}';
          _devOtp = rawOtp;
          _currentStep = 1;
          _errorMessage = null;
        });

        _startCountdown(resendAfter);

        // Auto-request focus for OTP input
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _otpFocusNode.requestFocus();
        });

        Get.snackbar(
          'OTP Sent',
          res['message']?.toString() ?? 'OTP sent to co-applicant successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          _errorMessage = ApiService.getErrorMessage(res);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Resend OTP API: POST /co-applicants/{id}/documents/resend-otp
  Future<void> _handleResendOtp() async {
    final phoneText = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _effectiveController.resendCoApplicantOtp(
        coApplicantId: widget.coApplicantId,
        phone: phoneText.isNotEmpty ? phoneText : null,
      );

      final isSuccess = res['success'] == true || res['status_code'] == 200;
      if (isSuccess) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        final rawOtp = data['otp'];
        final resendAfter = data['resend_after_seconds'] is int
            ? data['resend_after_seconds'] as int
            : 30;

        setState(() {
          _devOtp = rawOtp;
          _errorMessage = null;
        });

        _startCountdown(resendAfter);

        Get.snackbar(
          'OTP Resent',
          res['message']?.toString() ?? 'OTP resent to co-applicant successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          _errorMessage = ApiService.getErrorMessage(res);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Verify entered OTP
  Future<void> _handleVerifyOtp() async {
    final pin = _otpController.text.trim();
    if (pin.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _effectiveController.verifyCoApplicantOtp(
        coApplicantId: widget.coApplicantId,
        otp: pin,
      );

      final isSuccess = res['success'] == true || res['status_code'] == 200;
      if (isSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
        }

        widget.onVerified?.call();

        Get.snackbar(
          'Verified Successfully',
          res['message']?.toString() ??
              'Co-Applicant verified successfully. Documents are now unlocked.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        setState(() {
          _errorMessage = ApiService.getErrorMessage(res);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify OTP: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.indigoTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.shield_outlined,
                                color: AppColors.navy,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentStep == 0
                                    ? 'Verify Co-Applicant'
                                    : 'Enter OTP Code',
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                widget.coApplicantName,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.muted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Step 0: Phone Input | Step 1: OTP Input
                  if (_currentStep == 0)
                    _buildPhoneInputStep()
                  else
                    _buildOtpInputStep(),

                  // Error Message Banner
                  if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.errorRedBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.errorRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.errorRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 0
                              ? _handleSendOtp
                              : _handleVerifyOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == 0 ? 'Send OTP' : 'Verify OTP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.amber,
                                  size: 16,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 0 UI: Mobile Number Input
  Widget _buildPhoneInputStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'To access co-applicant documents, a one-time verification code will be sent to their mobile number.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Mobile Number *',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: '',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '+91',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 20,
                    color: AppColors.line,
                  ),
                ],
              ),
            ),
            hintText: 'Enter 10-digit mobile number',
            hintStyle: const TextStyle(
              color: AppColors.muted,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.indigo, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// Step 1 UI: Pinput 6-digit OTP Input
  Widget _buildOtpInputStep() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.indigoTint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.navy.withValues(alpha: 0.5), width: 1.5),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Code sent to $_maskedPhone',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = 0;
                  _otpController.clear();
                  _errorMessage = null;
                });
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: AppColors.indigo,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Quick test OTP chip if provided by API (dev convenience)
        if (_devOtp != null) ...[
          GestureDetector(
            onTap: () {
              final otpStr = _devOtp.toString();
              _otpController.text = otpStr;
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.key_rounded,
                      size: 13, color: AppColors.textDark),
                  const SizedBox(width: 5),
                  Text(
                    'Dev OTP: $_devOtp (Tap to fill)',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 6-digit Pinput
        Center(
          child: Pinput(
            length: 6,
            controller: _otpController,
            focusNode: _otpFocusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            followingPinTheme: defaultPinTheme,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            showCursor: true,
            onCompleted: (_) => _handleVerifyOtp(),
          ),
        ),
        const SizedBox(height: 16),

        // Resend Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 5),
                Text(
                  _resendSeconds > 0
                      ? 'Resend in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                      : 'Didn\'t receive code?',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_resendSeconds == 0)
              GestureDetector(
                onTap: _isLoading ? null : _handleResendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
