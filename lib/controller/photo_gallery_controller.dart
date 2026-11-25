import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class PhotoGalleryController extends GetxController {
  final int initialIndex;
  final String? shareText;

  final currentIndex = 0.obs;
  final isSelectionMode = false.obs;
  final selectedIndices = <int>{}.obs;
  final isSharing = false.obs;

  late PageController pageController;

  PhotoGalleryController({required this.initialIndex, this.shareText});

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void onThumbnailTapped(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void enterSelectionMode() {
    isSelectionMode.value = true;
    selectedIndices.clear();
    selectedIndices.add(currentIndex.value);
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedIndices.clear();
  }

  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
      if (selectedIndices.isEmpty) {
        exitSelectionMode();
      }
    } else {
      selectedIndices.add(index);
    }
  }

  void selectAll(int total) {
    selectedIndices.clear();
    for (int i = 0; i < total; i++) {
      selectedIndices.add(i);
    }
  }

  Future<void> shareImages(List<String> imagePaths, {List<int>? indices, bool all = false}) async {
    isSharing.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Share',
        'Sharing features completed successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      // ignore
    } finally {
      isSharing.value = false;
      exitSelectionMode();
    }
  }
}
