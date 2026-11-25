import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../controller/document_wallet_controller.dart';
import '../controller/profile_controller.dart';
import '../models/document_detail_model.dart';
import '../services/api_service.dart';
import '../widgets/image_picker_bottom_sheet.dart';

/// Screen displaying a single document in light mode.
/// Built to directly render document images fetched from an API or device memory,
/// with interactive zoom, front/back toggle, and dynamic detail integration from GET /my-documents/{document_type}.
class DocumentViewScreen extends StatefulWidget {
  final WalletDocumentModel? document;

  const DocumentViewScreen({
    super.key,
    this.document,
  });

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  // 0: Front, 1: Back
  int _selectedSideIndex = 0;

  late WalletDocumentModel doc;
  late final ProfileController profileController;
  DocumentDetailModel? documentDetail;
  bool isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    doc = widget.document ??
        WalletDocumentModel(
          id: 'aadhaar',
          title: 'Aadhaar card',
          subtitle: 'Front + back · 12 Nov',
          category: 'KYC',
          badgeText: 'Verified',
          icon: Icons.badge_outlined,
          isFeatured: true,
        );

    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    _fetchDocumentDetails();
  }

  /// Fetches single document details from GET {{baseUrl}}/my-documents/{type}
  Future<void> _fetchDocumentDetails() async {
    final docId = doc.id.toLowerCase();
    String docType = docId;
    if (docId.contains('aadhaar')) {
      docType = 'aadhaar';
    } else if (docId.contains('pan')) {
      docType = 'pan';
    }

    if (docType != 'aadhaar' && docType != 'pan') return;

    setState(() => isLoadingDetail = true);
    try {
      final res = await ApiService.getDocumentDetails(documentType: docType);
      if (res['success'] == true || res['status_code'] == 200) {
        final model = DocumentDetailModel.fromJson(res);
        if (mounted) {
          setState(() {
            documentDetail = model;
            // Update doc model with fetched image & status
            if (model.image != null && model.image!.isNotEmpty) {
              final fullUrl = model.image!.startsWith('http')
                  ? model.image!
                  : '${ApiService.baseUrl}/storage/${model.image}';

              doc = doc.copyWith(
                title: model.title ?? doc.title,
                badgeText: model.status != null ? model.status!.capitalizeFirst! : doc.badgeText,
                frontImageUrl: fullUrl,
                uploadedDate: _formatDate(model.createdAt ?? model.updatedAt),
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching document detail: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingDetail = false);
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return doc.uploadedDate;
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context),

            // Scrollable Document Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    // Front / Back Toggle Pills
                    _buildSideToggle(),

                    const SizedBox(height: 18),

                    // Main Document Card Preview (Direct Image or Template)
                    _buildDocumentPreviewCard(),

                    const SizedBox(height: 20),

                    // Metadata Card (Status, Uploaded, Used in)
                    _buildMetadataCard(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Actions (Download, Share, Replace)
            _buildBottomActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button, title, and more options menu
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Squircle Back Button
          GestureDetector(
            onTap: () => Get.back(),
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
          ),

          // Title
          Text(
            doc.title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          // More Options Button
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'replace') {
                _handleReplace(context);
              } else if (val == 'download') {
                _handleDownload();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded, size: 18, color: AppColors.muted),
                    SizedBox(width: 10),
                    Text('Download PDF', style: TextStyle(fontSize: 13.5)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'replace',
                child: Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 18, color: AppColors.muted),
                    SizedBox(width: 10),
                    Text('Replace document', style: TextStyle(fontSize: 13.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Front / Back Toggle Pills
  Widget _buildSideToggle() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Front Pill
            GestureDetector(
              onTap: () => setState(() => _selectedSideIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedSideIndex == 0
                      ? AppColors.navy
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedSideIndex == 0
                      ? [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Front',
                  style: TextStyle(
                    color: _selectedSideIndex == 0
                        ? Colors.white
                        : AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Back Pill
            GestureDetector(
              onTap: () => setState(() => _selectedSideIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                decoration: BoxDecoration(
                  color: _selectedSideIndex == 1
                      ? AppColors.navy
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedSideIndex == 1
                      ? [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: _selectedSideIndex == 1
                        ? Colors.white
                        : AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main Document Card Preview in clean light mode.
  /// If a direct document image URL or memory byte array is present (e.g. from backend API),
  /// it renders the direct document image with pinch-to-zoom support.
  /// Otherwise, it falls back to the template layout.
  Widget _buildDocumentPreviewCard() {
    final bool isFront = _selectedSideIndex == 0;
    final Uint8List? imageBytes = isFront ? doc.frontImageBytes : doc.backImageBytes;
    final String? imageUrl = isFront ? doc.frontImageUrl : doc.backImageUrl;
    final bool hasDirectImage =
        imageBytes != null || (imageUrl != null && imageUrl.isNotEmpty);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasDirectImage
          ? _buildDirectDocumentImageView(imageBytes, imageUrl, isFront)
          : Padding(
              padding: const EdgeInsets.all(20),
              child: isFront ? _buildCardFrontContent() : _buildCardBackContent(),
            ),
    );
  }

  /// Directly displays the document image (from API URL or memory bytes)
  Widget _buildDirectDocumentImageView(
    Uint8List? bytes,
    String? url,
    bool isFront,
  ) {
    Widget imageWidget;

    if (bytes != null) {
      imageWidget = Image.memory(
        bytes,
        fit: BoxFit.contain,
        width: double.infinity,
      );
    } else if (url != null && url.startsWith('http')) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 220,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryPurple,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 220,
            color: AppColors.canvas,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.broken_image_rounded,
                    size: 40,
                    color: AppColors.muted,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load document image',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (url != null && url.startsWith('assets/')) {
      imageWidget = Image.asset(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
      );
    } else {
      imageWidget = const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Interactive pinch & zoomable direct document image
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 260),
          color: AppColors.canvas,
          width: double.infinity,
          alignment: Alignment.center,
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            maxScale: 3.5,
            child: imageWidget,
          ),
        ),

        // Side badge overlay (FRONT / BACK with zoom hint)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.zoom_in_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isFront ? 'FRONT' : 'BACK',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Front Side of the Document Card (Template Fallback)
  Widget _buildCardFrontContent() {
    final userName = profileController.fullName.isNotEmpty
        ? profileController.fullName
        : 'Aarav Mehta';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Government of India + Emblem badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.warningAmberBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      '🇮🇳',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Government of India',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),

            // Subtle official chip
            Container(
              width: 28,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // User Photo + Name, DOB, Gender + MASKED Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Container
            Container(
              width: 78,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Obx(() {
                final imageBytes = profileController.profileImageBytes.value;
                if (imageBytes != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: AppColors.muted,
                  ),
                );
              }),
            ),

            const SizedBox(width: 14),

            // User Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'DOB: 15/08/1993',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Male',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // MASKED Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'MASKED',
                style: TextStyle(
                  color: AppColors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Masked Aadhaar Number
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              documentDetail?.number != null && documentDetail!.number!.length >= 4
                  ? 'XXXX  XXXX  ${documentDetail!.number!.substring(documentDetail!.number!.length - 4)}'
                  : 'XXXX  XXXX  1234',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Back Side of the Document Card (Address & QR code Template Fallback)
  Widget _buildCardBackContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          'Unique Identification Authority of India',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address:',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      profileController.address.isNotEmpty
                          ? profileController.address
                          : '123, MG Road, Bengaluru, Karnataka 560001',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // QR Code Placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 52,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Helpline note
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'www.uidai.gov.in  •  Help: 1947',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Metadata Card in light mode (Status, Uploaded, Used in)
  Widget _buildMetadataCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                doc.status,
                style: const TextStyle(
                  color: AppColors.warningAmber,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.canvas),
          const SizedBox(height: 12),

          // Row 2: Uploaded
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Uploaded',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                doc.uploadedDate,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.canvas),
          const SizedBox(height: 12),

          // Row 3: Used in
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Used in',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                doc.usedIn,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom Actions: Download, Share, Replace
  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Download Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.file_download_outlined,
                label: 'Download',
                onTap: _handleDownload,
              ),
            ),
            const SizedBox(width: 10),

            // Share Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: _handleShare,
              ),
            ),
            const SizedBox(width: 10),

            // Replace Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.upload_file_outlined,
                label: 'Replace',
                onTap: () => _handleReplace(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single Action Button matching the app theme
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.amber,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownload() {
    Get.snackbar(
      'Download started',
      'Downloading ${doc.title} PDF to your device...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _handleShare() {
    Get.snackbar(
      'Share document',
      'Preparing secure share link for ${doc.title}...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  Future<void> _handleReplace(BuildContext context) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Replace document',
      subtitle:
          'Upload a clear ${_selectedSideIndex == 0 ? "front" : "back"} copy of ${doc.title}',
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final isFront = _selectedSideIndex == 0;

      setState(() {
        doc = doc.copyWith(
          frontImageBytes: isFront ? bytes : doc.frontImageBytes,
          backImageBytes: !isFront ? bytes : doc.backImageBytes,
        );
      });

      if (Get.isRegistered<DocumentWalletController>()) {
        Get.find<DocumentWalletController>()
            .updateDocumentImage(doc.id, bytes, isFront: isFront);
      }

      Get.snackbar(
        'Document updated',
        '${isFront ? "Front" : "Back"} image for ${doc.title} has been updated.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}
