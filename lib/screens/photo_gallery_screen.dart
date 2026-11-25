import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/photo_gallery_controller.dart';
import '../theme/app_colors.dart';
import '../utils/media_utility.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final List<String> imagePaths;
  final List<bool>? needsFlip;
  final int initialIndex;
  final String? shareText;

  const PhotoGalleryScreen({
    super.key,
    required this.imagePaths,
    this.needsFlip,
    this.initialIndex = 0,
    this.shareText,
  });

  Widget _buildNetworkImage(
    String url, {
    required BoxFit fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white70,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ??
          const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white30,
              size: 40,
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tag = 'photo-gallery-${imagePaths.hashCode}-$initialIndex';
    final controller = Get.put(
      PhotoGalleryController(initialIndex: initialIndex, shareText: shareText),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Obx(() {
          if (controller.isSelectionMode.value) {
            final count = controller.selectedIndices.length;
            return Text(
              '$count Selected',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            );
          }
          return Text(
            'Photo ${controller.currentIndex.value + 1} of ${imagePaths.length}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          );
        }),
        leading: Obx(() {
          if (controller.isSelectionMode.value) {
            return IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: controller.exitSelectionMode,
            );
          }
          return IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isSelectionMode.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected = controller.selectedIndices.contains(index);
                      return GestureDetector(
                        onTap: () => controller.toggleSelection(index),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: () {
                                final normalized = MediaUtility.normalizeUrl(imagePaths[index]);
                                if (normalized.startsWith('http')) {
                                  return _buildNetworkImage(
                                    normalized,
                                    fit: BoxFit.cover,
                                    placeholder: Container(
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: Container(
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white30,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                } else if (normalized.startsWith('assets/')) {
                                  return Image.asset(
                                    normalized,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.file(
                                    File(normalized),
                                    fit: BoxFit.cover,
                                  );
                                }
                              }(),
                            ),
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.indigo.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: AppColors.indigo,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.indigo
                                      : Colors.black45,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                );
              }

              return PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: () {
                        final normalized = MediaUtility.normalizeUrl(imagePaths[index]);
                        if (normalized.startsWith('http')) {
                          return _buildNetworkImage(
                            normalized,
                            fit: BoxFit.contain,
                          );
                        } else if (normalized.startsWith('assets/')) {
                          return Image.asset(
                            normalized,
                            fit: BoxFit.contain,
                          );
                        } else {
                          return Image.file(
                            File(normalized),
                            fit: BoxFit.contain,
                          );
                        }
                      }(),
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (controller.isSelectionMode.value) return const SizedBox.shrink();
            if (imagePaths.length <= 1) return const SizedBox.shrink();

            return Container(
              height: 100,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected = index == controller.currentIndex.value;
                    return GestureDetector(
                      onTap: () => controller.onThumbnailTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 76,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: () {
                                final normalized = MediaUtility.normalizeUrl(imagePaths[index]);
                                if (normalized.startsWith('http')) {
                                  return _buildNetworkImage(
                                    normalized,
                                    fit: BoxFit.cover,
                                    placeholder: Container(
                                      color: Colors.grey[900],
                                    ),
                                    errorWidget: Container(
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white24,
                                        size: 16,
                                      ),
                                    ),
                                  );
                                } else if (normalized.startsWith('assets/')) {
                                  return Image.asset(
                                    normalized,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.file(
                                    File(normalized),
                                    fit: BoxFit.cover,
                                  );
                                }
                              }(),
                            ),
                            if (isSelected)
                              const SizedBox.shrink()
                            else
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
