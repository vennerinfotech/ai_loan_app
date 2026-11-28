import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../screens/login_with_mobile_screen.dart';
import '../screens/forgot_mpin_screen.dart';
import '../screens/main_nav_screen.dart';
import '../widgets/mpin_verification_dialog.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../models/auth_response_model.dart';

/// GetX controller for Login with MPIN flow.
/// Includes ticker provider for continuous cosmic orbit animation in top card.
class MpinLoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final String? initialPhone;

  MpinLoginController({this.initialPhone});

  final mpin = ''.obs;
  final userName = 'Aarav Mehta'.obs;
  final userPhone = ''.obs;
  final userInitials = 'AM'.obs;
  final isSubmitting = false.obs;
  final isBiometricAvailable = false.obs;
  final authResponse = Rxn<AuthResponseModel>();

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  @override
  void onInit() {
    super.onInit();
    if (initialPhone != null && initialPhone!.trim().isNotEmpty) {
      userPhone.value = initialPhone!.trim();
    }
    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    orbitAnimation = CurvedAnimation(
      parent: orbitController,
      curve: Curves.linear,
    );
    _initSessionAndBiometric();
  }

  Future<void> _initSessionAndBiometric() async {
    await _loadUserSession();
    await _checkBiometricOnLaunch();
  }

  Future<void> _checkBiometricOnLaunch() async {
    final phone = userPhone.value.isNotEmpty
        ? userPhone.value
        : await SessionManager.getUserPhone();
    final isReady = await BiometricService.instance.isBiometricReady(phone: phone);
    isBiometricAvailable.value = isReady;
    if (isReady) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!isClosed && !isSubmitting.value) {
          triggerBiometric();
        }
      });
    }
  }

  Future<void> _loadUserSession() async {
    final savedName = await SessionManager.getUserName();
    final savedPhone = await SessionManager.getUserPhone();
    if (savedName.isNotEmpty) {
      userName.value = savedName;
      userInitials.value = _computeInitials(savedName);
    }
    // Only load from SessionManager if userPhone was not already explicitly set
    if (userPhone.value.isEmpty && savedPhone.isNotEmpty) {
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
    if (isSubmitting.value) return;
    if (mpin.value.length < 6) {
      mpin.value += digit;
      if (mpin.value.length == 6) {
        submitLogin();
      }
    }
  }

  void deleteDigit() {
    if (isSubmitting.value) return;
    if (mpin.value.isNotEmpty) {
      mpin.value = mpin.value.substring(0, mpin.value.length - 1);
    }
  }

  /// Displays a non-dismissible loader dialog during MPIN verification
  void _showVerifyingDialog() {
    Get.dialog(
      const MpinVerificationDialog(),
      barrierDismissible: false,
    );
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

    // Show loader dialog
    _showVerifyingDialog();

    try {
      isSubmitting.value = true;
      final stopwatch = Stopwatch()..start();

      final response = await ApiService.login(phone: phone, mpin: enteredMpin);

      // Ensure minimum display time for smooth user experience (~3.0s)
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed));
      }

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

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
          userId: model.data?.user?.id,
        );

        // Keep Keystore MPIN updated with verified MPIN
        await BiometricService.instance.saveStoredMpin(enteredMpin, phone: loggedPhone);

        // Safely close loader dialog
        if (Get.isDialogOpen == true) {
          Get.back();
        }

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
        // Safely close loader dialog
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        mpin.value = '';
        final errorMsg = ApiService.getErrorMessage(response);
        debugPrint('Login Error: $errorMsg');

        // If MPIN was changed on another device or invalid, clean up out-of-sync Keystore MPIN
        if (response['status_code'] == 401 ||
            errorMsg.toLowerCase().contains('invalid mpin')) {
          await BiometricService.instance.deleteStoredMpin(phone: phone);
          isBiometricAvailable.value = false;
        }

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
      // Safely close loader dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
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
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Triggers biometric authentication (fingerprint) and performs auto-login.
  /// Always available when device supports biometrics + stored MPIN exists.
  Future<void> triggerBiometric() async {
    if (isSubmitting.value) return;

    // Check if device supports biometrics
    final available = await BiometricService.instance.isBiometricAvailable();
    if (!available) {
      Get.snackbar(
        'Biometrics Unavailable',
        'Biometric hardware is not available or no fingerprint is enrolled on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check if stored MPIN exists (user must have logged in with MPIN at least once)
    final phone = userPhone.value.isNotEmpty
        ? userPhone.value
        : await SessionManager.getUserPhone();
    final storedMpin = await BiometricService.instance.getStoredMpin(phone: phone);
    if (storedMpin == null || storedMpin.trim().length != 6) {
      Get.snackbar(
        'Login with MPIN First',
        'Log in with your 6-digit MPIN once to enable fingerprint login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check internet connectivity
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) ||
          connectivityResult.isEmpty) {
        Get.snackbar(
          'No Internet Connection',
          'Please check your internet connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    } catch (_) {}

    // Authenticate with biometrics
    final authenticated = await BiometricService.instance.authenticate(
      localizedReason: 'Scan your fingerprint to log in to Finsphere',
    );

    if (!authenticated) {
      return;
    }

    mpin.value = storedMpin.trim();
    await submitLogin();
  }

  void useMobileNumber() {
    if (isSubmitting.value) return;
    mpin.value = '';
    userPhone.value = '';
    Get.to(() => const LoginWithMobileScreen());
  }

  void forgotMpin() {
    if (isSubmitting.value) return;
    Get.to(() => const ForgotMpinScreen());
  }
}
