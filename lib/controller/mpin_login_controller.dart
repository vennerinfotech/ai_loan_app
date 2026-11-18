import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/login_with_mobile_screen.dart';
import '../screens/forgot_mpin_screen.dart';
import '../screens/main_nav_screen.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../models/auth_response_model.dart';

/// GetX controller for Login with MPIN flow.
/// Includes ticker provider for continuous cosmic orbit animation in top card.
class MpinLoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mpin = ''.obs;
  final userName = 'Aarav Mehta'.obs;
  final userPhone = ''.obs;
  final userInitials = 'AM'.obs;
  final isSubmitting = false.obs;
  final authResponse = Rxn<AuthResponseModel>();

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  @override
  void onInit() {
    super.onInit();
    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    orbitAnimation = CurvedAnimation(
      parent: orbitController,
      curve: Curves.linear,
    );
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final savedName = await SessionManager.getUserName();
    final savedPhone = await SessionManager.getUserPhone();
    if (savedName.isNotEmpty) {
      userName.value = savedName;
      userInitials.value = _computeInitials(savedName);
    }
    if (savedPhone.isNotEmpty) {
      userPhone.value = savedPhone;
    }
  }

  void setPhoneNumber(String phone) {
    if (phone.trim().isNotEmpty) {
      userPhone.value = phone.trim();
    }
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return 'AM';
  }

  @override
  void onClose() {
    orbitController.dispose();
    super.onClose();
  }

  void enterDigit(String digit) {
    if (mpin.value.length < 6) {
      mpin.value += digit;
      if (mpin.value.length == 6) {
        submitLogin();
      }
    }
  }

  void deleteDigit() {
    if (mpin.value.isNotEmpty) {
      mpin.value = mpin.value.substring(0, mpin.value.length - 1);
    }
  }

  /// Submit Login with Phone & MPIN: POST /login
  Future<void> submitLogin() async {
    if (isSubmitting.value) return;

    final enteredMpin = mpin.value.trim();
    if (enteredMpin.length < 6) return;

    final phone = userPhone.value.isNotEmpty
        ? userPhone.value
        : await SessionManager.getUserPhone();

    if (phone.isEmpty) {
      Get.snackbar(
        'Missing Phone',
        'Please login with mobile number first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      useMobileNumber();
      return;
    }

    try {
      isSubmitting.value = true;
      final Map<String, dynamic> response = await ApiService.login(
        phone: phone,
        mpin: enteredMpin,
      );
      isSubmitting.value = false;

      final statusCode = response['status_code'];
      final isSuccess =
          response['success'] == true || statusCode == 200 || statusCode == 201;

      if (isSuccess) {
        final model = AuthResponseModel.fromJson(response);
        authResponse.value = model;

        final token = model.data?.token;
        final name = model.data?.user?.name ?? userName.value;
        final loggedPhone = model.data?.user?.phone ?? phone;

        await SessionManager.saveLoginSession(
          phone: loggedPhone,
          name: name,
          token: token,
        );

        Get.snackbar(
          'Success',
          model.message.isNotEmpty ? model.message : 'Login successful.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        Get.offAll(() => const MainNavScreen());
      } else {
        mpin.value = '';
        final errorMsg = response['message']?.toString() ?? 'Invalid MPIN';
        debugPrint('Login Error: $errorMsg');
        Get.snackbar(
          'Login Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      mpin.value = '';
      debugPrint('Login Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to login: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void triggerBiometric() {
    Get.snackbar(
      'Biometric Login',
      'Authenticating via fingerprint...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.indigo,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 900), () async {
      // Save session with setString
      await SessionManager.saveLoginSession(name: userName.value);
      Get.offAll(() => const MainNavScreen());
    });
  }

  void useMobileNumber() {
    Get.to(() => const LoginWithMobileScreen());
  }

  void forgotMpin() {
    Get.to(() => const ForgotMpinScreen());
  }
}
