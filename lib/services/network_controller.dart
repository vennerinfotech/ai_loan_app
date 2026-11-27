import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// Global Network & Connectivity Controller
/// Listens to real-time network state changes using the official `connectivity_plus` package.
/// Displays a theme-consistent blocking modal when offline and auto-recovers when back online.
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final isConnected = true.obs;
  final isChecking = false.obs;
  bool _isDialogOpen = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  /// Initial connection check on app launch
  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking initial connection: $e');
    }
  }

  /// Handles connectivity stream events
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final hasNetworkType = results.any((r) => r != ConnectivityResult.none);

    bool reachable = false;
    if (hasNetworkType) {
      reachable = await _checkInternetReachability();
    }

    if (!reachable) {
      isConnected.value = false;
      _showNoInternetDialog();
    } else {
      final wasDisconnected = !isConnected.value;
      isConnected.value = true;
      _closeNoInternetDialog();

      if (wasDisconnected) {
        Get.snackbar(
          'Online',
          'Your internet connection has been restored.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          icon: const Icon(Icons.wifi_rounded, color: Colors.white),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Double checks actual reachability by resolving DNS
  Future<bool> _checkInternetReachability() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Manually retry connection when user clicks "Try Again"
  Future<void> retryConnection() async {
    isChecking.value = true;
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetworkType = results.any((r) => r != ConnectivityResult.none);

      bool reachable = false;
      if (hasNetworkType) {
        reachable = await _checkInternetReachability();
      }

      if (reachable) {
        isConnected.value = true;
        _closeNoInternetDialog();
        Get.snackbar(
          'Online',
          'Internet connection restored successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline_rounded,
              color: Colors.white),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        isConnected.value = false;
        Get.snackbar(
          'Still Offline',
          'Unable to reach the internet. Please check your Wi-Fi or mobile data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isChecking.value = false;
    }
  }

  /// Display theme-matched No Internet dialog
  void _showNoInternetDialog() {
    if (_isDialogOpen) return;

    _isDialogOpen = true;
    Get.dialog(
      PopScope(
        canPop: false, // Prevents Android back button dismissal while offline
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with subtle circular gradient/tint
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.errorRedBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 32,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                const Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                const Text(
                  'Please check your Wi-Fi or mobile data connection and try again to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),

                // Status chip: Offline mode
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Device is currently offline',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Try Again CTA Button
                Obx(() {
                  final loading = isChecking.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : retryConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _isDialogOpen = false;
    });
  }

  /// Closes the dialog automatically when back online
  void _closeNoInternetDialog() {
    if (_isDialogOpen) {
      _isDialogOpen = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }
}
