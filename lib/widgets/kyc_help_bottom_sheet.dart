import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Clean & balanced KYC Verification Help Bottom Sheet.
class KycHelpBottomSheet extends StatelessWidget {
  const KycHelpBottomSheet({super.key});

  /// Show the help bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => const KycHelpBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Icon + Title & Subtitle + Close Button
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC Verification Help',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Follow these simple steps for quick approval',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textDarkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textDarkSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 1. Aadhaar Help
          _buildItem(
            icon: Icons.fingerprint_rounded,
            title: 'Aadhaar e-KYC',
            desc:
                'OTP is sent to your Aadhaar-linked mobile number. If your mobile is not linked, you can upload clear photos of your card.',
          ),
          const SizedBox(height: 14),

          // 2. PAN Card Help
          _buildItem(
            icon: Icons.credit_card_rounded,
            title: 'PAN Card Verification',
            desc:
                'Enter your 10-digit PAN number. Your Name and Date of Birth must match official tax records and Aadhaar.',
          ),
          const SizedBox(height: 14),

          // 3. Document Photo Guidelines
          _buildItem(
            icon: Icons.document_scanner_outlined,
            title: 'Document Photo Quality',
            desc:
                'Ensure all 4 corners are visible with no blur, shadows, or flash glare. Text and photo must be clearly readable.',
          ),
          const SizedBox(height: 14),

          // 4. Security & Privacy
          _buildItem(
            icon: Icons.lock_outline_rounded,
            title: '100% Safe & Encrypted',
            desc:
                'Bank-grade 256-bit encryption. Verified via UIDAI & NSDL. Your personal data is never shared with third parties.',
          ),
          const SizedBox(height: 16),

          // Support info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 18,
                  color: AppColors.primaryPurple,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Need assistance? Our support team is available 24/7.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textDarkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bottom Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Got it, continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDarkSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
