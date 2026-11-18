import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/document_wallet_controller.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import 'document_view_screen.dart';

/// Screen displaying user's saved verification & loan documents (Reference Image 1)
class DocumentWalletScreen extends StatelessWidget {
  final bool showBackButton;

  const DocumentWalletScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocumentWalletController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearchBar(controller),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCategoryPills(controller),
            ),
            const SizedBox(height: 16),

            // 2-Column Grid of Document Cards
            Expanded(
              child: Obx(() {
                final docs = controller.filteredDocuments;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.96,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _buildDocumentCard(context, doc);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back, title, and navy '+' action
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Squircle Back Button
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<DashboardController>()) {
                  final dash = Get.find<DashboardController>();
                  if (dash.currentNavIndex.value == 3) {
                    dash.currentNavIndex.value = 0; // return to Home tab
                    return;
                  }
                }
                Get.back();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textDark,
                ),
              ),
            )
          else
            const SizedBox(width: 40),

          // Title
          const Expanded(
            child: Center(
              child: Text(
                'Document wallet',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Navy '+' Action Button
          GestureDetector(
            onTap: () async {
              final file = await ImagePickerBottomSheet.show(
                title: 'Upload document',
                subtitle: 'Select from camera or documents',
              );
              if (file != null) {
                Get.snackbar(
                  'Document Uploaded',
                  'Your document has been added to your wallet.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.navy,
                  colorText: Colors.white,
                );
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.amber,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Rounded search input pill
  Widget _buildSearchBar(DocumentWalletController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.muted,
            size: 20,
          ),
          hintText: 'Search documents',
          hintStyle: TextStyle(
            color: AppColors.indigo,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// Category filter pills: All, KYC, Income, Loan
  Widget _buildCategoryPills(DocumentWalletController controller) {
    return Obx(() {
      return Row(
        children: controller.categories.map((cat) {
          final isSelected = controller.selectedCategory.value == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navy : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.navy : AppColors.line,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Single document card (Aadhaar has featured dark-navy styling, others are white)
  Widget _buildDocumentCard(BuildContext context, WalletDocumentModel doc) {
    final cardWidget = doc.isFeatured
        ? _buildFeaturedCard(doc)
        : _buildStandardCard(doc);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => DocumentViewScreen(document: doc),
          transition: Transition.noTransition,
          duration: Duration.zero,
        );
      },
      child: cardWidget,
    );
  }

  Widget _buildFeaturedCard(WalletDocumentModel doc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Amber ID Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.amber,
                  size: 20,
                ),
              ),

              // Green "Verified" Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          // Bottom Column: Title + Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                doc.subtitle,
                style: const TextStyle(
                  color: AppColors.indigoTint,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(WalletDocumentModel doc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Lavender squircle icon + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  doc.icon,
                  color: AppColors.indigo,
                  size: 19,
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc.badgeText,
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          // Bottom Column: Title + Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                doc.subtitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
