import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../controller/document_wallet_controller.dart';
import '../models/document_detail_model.dart';
import 'photo_gallery_screen.dart';

/// Screen displaying a single document in clean light mode.
/// Pure presentation: renders directly from the document model passed from the wallet.
/// Completely offline-capable with zero extra API calls.
class DocumentViewScreen extends StatefulWidget {
  final DocumentDetailModel? detail;
  final WalletDocumentModel? document;

  const DocumentViewScreen({
    super.key,
    this.detail,
    this.document,
  });

  @override
  State<DocumentViewScreen> createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  int _selectedImageIndex = 0;
  bool _isNumberHidden = true;
  bool _isDownloading = false;
  bool _isSharing = false;

  late DocumentDetailModel documentDetail;
  late String docType;

  @override
  void initState() {
    super.initState();
    if (widget.detail != null) {
      documentDetail = widget.detail!;
      docType = widget.detail!.type?.toLowerCase() ?? 'document';
    } else if (widget.document != null) {
      final d = widget.document!;
      final List<DocumentDetailImageItem> images = [];
      if (d.frontImageUrl != null && d.frontImageUrl!.isNotEmpty) {
        final isPdf = d.frontImageUrl!.toLowerCase().contains('.pdf');
        images.add(DocumentDetailImageItem(
          side: 'front',
          url: d.frontImageUrl,
          isImage: !isPdf,
        ));
      }
      if (d.backImageUrl != null && d.backImageUrl!.isNotEmpty) {
        final isPdf = d.backImageUrl!.toLowerCase().contains('.pdf');
        images.add(DocumentDetailImageItem(
          side: 'back',
          url: d.backImageUrl,
          isImage: !isPdf,
        ));
      }
      documentDetail = DocumentDetailModel(
        type: d.id,
        title: d.title,
        status: d.status,
        imageUrls: images,
        createdAt: d.uploadedDate,
      );
      docType = d.id.toLowerCase();
    } else {
      documentDetail = DocumentDetailModel(
        title: 'Document',
        status: 'Uploaded',
      );
      docType = 'document';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  String _maskNumber(String? number) {
    if (number == null || number.isEmpty) return '—';
    if (docType.contains('aadhaar') && number.length >= 4) {
      final last4 = number.substring(number.length - 4);
      return 'XXXX  XXXX  $last4';
    }
    if (docType.contains('pan') && number.length >= 4) {
      final first2 = number.substring(0, 2);
      final last2 = number.substring(number.length - 2);
      return '${first2}XXXXXX$last2';
    }
    if (number.length > 4) {
      return '****${number.substring(number.length - 4)}';
    }
    return number;
  }

  String _getSideTitle(DocumentDetailImageItem item, int index) {
    final side = item.side?.toLowerCase();
    if (side == 'front') return 'Front Side';
    if (side == 'back') return 'Back Side';
    if (side == 'single') return 'Single Side';
    if (side == 'combined') return 'Combined';
    return item.side?.capitalizeFirst ?? 'Page ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final title = documentDetail.title ??
        (docType.contains('aadhaar')
            ? 'Aadhaar Card'
            : docType.contains('pan')
                ? 'PAN Card'
                : docType.capitalizeFirst ?? 'Document');

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, title),

            // Main Document Content (rendered instantly from model)
            Expanded(
              child: _buildDocumentContent(),
            ),

            // Bottom Actions (Download, Share, Replace)
            _buildBottomActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button and title
  Widget _buildTopBar(BuildContext context, String title) {
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

          // Title (wrapped in Expanded with ellipsis to prevent overflow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Right Spacer to balance the back button
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Main document content: toggle (if multiple), zoomable preview, and metadata from model
  Widget _buildDocumentContent() {
    final images = documentDetail.imageUrls;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Side Toggle Pills (only if more than 1 image)
          if (images.length > 1) ...[
            _buildSideToggle(images),
            const SizedBox(height: 16),
          ],

          // Document Preview Card
          _buildPreviewCard(images),

          const SizedBox(height: 20),

          // Document Details Section
          _buildDetailsCard(documentDetail),
        ],
      ),
    );
  }

  /// Side toggle pills dynamically created from model image list
  Widget _buildSideToggle(List<DocumentDetailImageItem> images) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(images.length, (index) {
              final isSelected = _selectedImageIndex == index;
              final label = _getSideTitle(images[index], index);

              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
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
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Whether the given item represents a PDF (not a raster image)
  bool _isPdfItem(DocumentDetailImageItem? item) {
    if (item == null) return false;
    if (!item.isImage) return true;
    final ext = item.extension?.toLowerCase() ?? '';
    if (ext == 'pdf') return true;
    final name = item.name?.toLowerCase() ?? '';
    if (name.endsWith('.pdf')) return true;
    final url = item.url?.toLowerCase() ?? '';
    if (url.contains('.pdf')) return true;
    return false;
  }

  /// Document image preview card - tapping opens full photo gallery view
  Widget _buildPreviewCard(List<DocumentDetailImageItem> images) {
    DocumentDetailImageItem? currentItem;
    if (images.isNotEmpty && _selectedImageIndex < images.length) {
      currentItem = images[_selectedImageIndex];
    }

    final imageUrl = currentItem?.url;
    final isPdf = _isPdfItem(currentItem);

    final allImageUrls = images
        .map((e) => e.url ?? '')
        .where((u) => u.isNotEmpty)
        .toList();

    if (allImageUrls.isEmpty && imageUrl != null && imageUrl.isNotEmpty) {
      allImageUrls.add(imageUrl);
    }

    // Determine top right chip label (FRONT, BACK, VIEW, PDF, etc.)
    final String chipLabel;
    if (isPdf) {
      chipLabel = 'PDF';
    } else if (currentItem?.side != null && currentItem!.side!.isNotEmpty) {
      final s = currentItem.side!.toUpperCase();
      chipLabel = s == 'SINGLE' ? 'VIEW' : s;
    } else if (images.length > 1) {
      chipLabel = _selectedImageIndex == 0 ? 'FRONT' : 'BACK';
    } else {
      chipLabel = 'VIEW';
    }

    const double cardRadius = 18.0;

    return GestureDetector(
      onTap: () {
        // Don't open photo gallery for PDFs
        if (!isPdf && allImageUrls.isNotEmpty) {
          final galleryUrls = <String>[];
          int adjustedIndex = 0;
          for (int i = 0; i < images.length; i++) {
            if (!_isPdfItem(images[i]) &&
                images[i].url != null &&
                images[i].url!.isNotEmpty) {
              if (i == _selectedImageIndex) adjustedIndex = galleryUrls.length;
              galleryUrls.add(images[i].url!);
            }
          }
          if (galleryUrls.isNotEmpty) {
            Get.to(() => PhotoGalleryScreen(
                  imagePaths: galleryUrls,
                  initialIndex: adjustedIndex,
                ));
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: AppColors.line, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cardRadius - 1.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // PDF Placeholder
              if (isPdf)
                Container(
                  color: AppColors.canvas,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 32,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentItem?.name ?? 'PDF Document',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PDF document uploaded',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              // Document Image (Cached)
              else if (imageUrl != null && imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Container(
                      color: AppColors.canvas,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: AppColors.navy,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      color: AppColors.canvas,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 40,
                              color: AppColors.muted,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Unable to load document image',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: AppColors.canvas,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 44,
                        color: AppColors.muted,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No document preview available',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Top Right Corner Label Chip
              if (imageUrl != null && imageUrl.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.fullscreen_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chipLabel,
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
          ),
        ),
      ),
    );
  }

  /// Dynamic document details card directly rendered from model
  Widget _buildDetailsCard(DocumentDetailModel detail) {
    final number = detail.number;
    final status = detail.status ?? 'Uploaded';
    final createdAt = _formatDate(detail.createdAt);
    final updatedAt = _formatDate(detail.updatedAt);

    // Pick badge color based on status
    final lowerStatus = status.toLowerCase();
    final Color statusBg;
    final Color statusTextColor;
    if (lowerStatus == 'accepted' || lowerStatus == 'verified') {
      statusBg = AppColors.successGreenBg;
      statusTextColor = AppColors.successGreen;
    } else if (lowerStatus == 'rejected') {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    } else {
      statusBg = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    }

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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Information',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),

          // Document Number Row
          if (number != null && number.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Document Number',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _isNumberHidden ? _maskNumber(number) : number,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isNumberHidden = !_isNumberHidden),
                        child: Icon(
                          _isNumberHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: number));
                          Get.snackbar(
                            'Copied',
                            'Document number copied to clipboard',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.navy,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.canvas),
            const SizedBox(height: 12),
          ],

          // Status Row
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.capitalizeFirst ?? status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.canvas),
          const SizedBox(height: 12),

          // Uploaded Date Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Uploaded Date',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                createdAt,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (updatedAt != '—' && updatedAt != createdAt) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.canvas),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Updated',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  updatedAt,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Bottom Actions: Download & Share
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
                label: _isDownloading ? 'Saving...' : 'Download',
                isLoading: _isDownloading,
                onTap: _isDownloading ? () {} : _handleDownload,
              ),
            ),
            const SizedBox(width: 12),

            // Share Button
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_outlined,
                label: _isSharing ? 'Sharing...' : 'Share',
                isLoading: _isSharing,
                onTap: _isSharing ? () {} : _handleShare,
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
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
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
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.amber,
                ),
              )
            else
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

  Future<void> _handleDownload() async {
    final title = documentDetail.title ?? docType.toUpperCase();
    final images = documentDetail.imageUrls;
    DocumentDetailImageItem? currentItem;
    if (images.isNotEmpty && _selectedImageIndex < images.length) {
      currentItem = images[_selectedImageIndex];
    }
    final currentUrl = currentItem?.url;

    if (currentUrl == null || currentUrl.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No downloadable file found for $title.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final response = await http.get(Uri.parse(currentUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      final isPdf = _isPdfItem(currentItem) || contentType.contains('application/pdf');

      String ext;
      if (isPdf) {
        ext = 'pdf';
      } else if (currentItem?.extension != null &&
          currentItem!.extension!.isNotEmpty) {
        ext = currentItem.extension!.toLowerCase().replaceAll('.', '');
      } else if (contentType.contains('png')) {
        ext = 'png';
      } else if (contentType.contains('webp')) {
        ext = 'webp';
      } else {
        ext = 'jpg';
      }

      final safeDocType = docType.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final sidePart = (currentItem?.side ?? 'doc').replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final fileName =
          '${safeDocType}_${sidePart}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      File? savedFile;
      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final candidate = File('${downloadDir.path}/$fileName');
            await candidate.writeAsBytes(response.bodyBytes, flush: true);
            savedFile = candidate;
          }
        } catch (_) {
          // Fallback to app documents directory if public Download is restricted
        }
      }

      if (savedFile == null) {
        final appDir = await getApplicationDocumentsDirectory();
        savedFile = File('${appDir.path}/$fileName');
        await savedFile.writeAsBytes(response.bodyBytes, flush: true);
      }

      if (!mounted) return;

      if (isPdf) {
        final openResult = await OpenFilex.open(
          savedFile.path,
          type: 'application/pdf',
        );
        if (openResult.type != ResultType.done) {
          Get.snackbar(
            'PDF Downloaded',
            'Saved to ${savedFile.path}. Could not auto-open (${openResult.message}).',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } else {
        Get.snackbar(
          'Image Downloaded',
          '$title saved to ${savedFile.path}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Download Failed',
        'Unable to download $title: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _handleShare() async {
    final title = documentDetail.title ?? docType.toUpperCase();
    final images = documentDetail.imageUrls;
    DocumentDetailImageItem? currentItem;
    if (images.isNotEmpty && _selectedImageIndex < images.length) {
      currentItem = images[_selectedImageIndex];
    }
    final currentUrl = currentItem?.url;

    if (currentUrl == null || currentUrl.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No file available to share for $title.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isSharing = true);

    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 100, 100);

    try {
      final response = await http.get(Uri.parse(currentUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      final isPdf = _isPdfItem(currentItem) || contentType.contains('application/pdf');

      String ext;
      if (isPdf) {
        ext = 'pdf';
      } else if (currentItem?.extension != null &&
          currentItem!.extension!.isNotEmpty) {
        ext = currentItem.extension!.toLowerCase().replaceAll('.', '');
      } else if (contentType.contains('png')) {
        ext = 'png';
      } else if (contentType.contains('webp')) {
        ext = 'webp';
      } else {
        ext = 'jpg';
      }

      final safeDocType = docType.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final sidePart = (currentItem?.side ?? 'doc').replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${safeDocType}_$sidePart.$ext');
      await tempFile.writeAsBytes(response.bodyBytes, flush: true);

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          text: title,
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Share Failed',
        'Unable to share $title: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
