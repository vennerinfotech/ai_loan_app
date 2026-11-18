import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

/// Reusable Bottom Sheet for selecting document upload source (Camera or Gallery)
/// styled cleanly to match Finsphere AI's theme.
class ImagePickerBottomSheet {
  ImagePickerBottomSheet._();

  /// Opens the bottom sheet and returns the selected [XFile], or null if canceled.
  static Future<XFile?> show({
    BuildContext? context,
    String title = 'Upload document',
    String subtitle = 'Take a clear photo or select from your gallery',
  }) async {
    final ImagePicker picker = ImagePicker();

    Widget buildSheet(BuildContext sheetContext) {
      return Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (Get.isBottomSheetOpen == true) {
                      Get.back();
                    } else {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
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
            const SizedBox(height: 20),

            // Option 1: Take Photo via Camera
            _buildOptionCard(
              icon: Icons.photo_camera_rounded,
              iconColor: AppColors.primaryPurple,
              iconBgColor: AppColors.indigoTint,
              title: 'Take photo',
              subtitle: 'Use camera to scan your document',
              onTap: () {
                if (Get.isBottomSheetOpen == true) {
                  Get.back(result: ImageSource.camera);
                } else {
                  Navigator.of(sheetContext).pop(ImageSource.camera);
                }
              },
            ),
            const SizedBox(height: 12),

            // Option 2: Choose from Gallery
            _buildOptionCard(
              icon: Icons.photo_library_outlined,
              iconColor: AppColors.amber,
              iconBgColor: AppColors.amber.withValues(alpha: 0.15),
              title: 'Choose from gallery',
              subtitle: 'Select existing image or PDF from device',
              onTap: () {
                if (Get.isBottomSheetOpen == true) {
                  Get.back(result: ImageSource.gallery);
                } else {
                  Navigator.of(sheetContext).pop(ImageSource.gallery);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

    // Prefer Get.bottomSheet for native GetX routing across all contexts
    final ImageSource? selectedSource = await Get.bottomSheet<ImageSource>(
      Builder(builder: buildSheet),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (selectedSource == null) return null;

    try {
      return await picker.pickImage(
        source: selectedSource,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Image picker error: $e');
      Get.snackbar(
        'Upload Unavailable',
        'Could not access the selected photo source on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }
  }

  /// Option Tile with squircle icon, text, and chevron
  static Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDarkSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDarkSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
