import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Clean modal dialog shown during MPIN verification.
/// Matches the clean previous dialog layout, using a security lock icon
/// in place of the circular loader.
class MpinVerificationDialog extends StatelessWidget {
  const MpinVerificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container replacing circular loader
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.indigo.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.navy,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifying MPIN...',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Authenticating your credentials, please wait...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
