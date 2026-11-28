import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../controller/document_wallet_controller.dart';
import '../controller/dashboard_controller.dart';
import '../models/my_documents_response_model.dart';
import '../models/document_detail_model.dart';
import 'cibil_score_screen.dart';
import 'document_view_screen.dart';
import '../widgets/co_applicant_otp_bottom_sheet.dart';
import '../services/api_service.dart';

/// Screen displaying user's saved verification & loan documents in 3 dedicated sections
/// maintaining the mobile app theme and 2-column GridView card UI:
/// 1. Applicant Documents (Aadhaar, PAN, CIBIL Report)
/// 2. Co-Applicant Documents (grouped by Co-Applicant with avatar, name, relationship, date)
/// 3. Loan Application Documents (grouped by Lead with type, ID, amount, date)
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: _buildSearchBar(controller),
            ),

            // Top Side Filter Chips for 3 Sections
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _buildSectionFilterChips(controller),
            ),

            // Main Content Area with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchMyDocuments,
                color: AppColors.navy,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.navy,
                      ),
                    );
                  }

                  final data = controller.myDocumentsData.value;
                  if (data == null) {
                    return _buildEmptyState(context);
                  }

                  final query = controller.searchQuery.value.trim().toLowerCase();
                  final selected = controller.selectedSection.value;
                  final isFilterApplied = selected != 'All';

                  if (selected == 'All' && controller.isEmptyWallet) {
                    return _buildEmptyState(context);
                  }

                  final showApplicant = (selected == 'All' || selected == 'Applicant') &&
                      controller.hasApplicantDocuments;
                  final showCoApplicant = (selected == 'All' || selected == 'Co-Applicant') &&
                      controller.coApplicantsWithDocuments.isNotEmpty;
                  final showLoanApp = (selected == 'All' || selected == 'Loan Application') &&
                      controller.leadsWithDocuments.isNotEmpty;

                  if (!showApplicant && !showCoApplicant && !showLoanApp) {
                    return _buildEmptySectionState(context, selected);
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // Section 1: Applicant Documents
                      if (showApplicant) ...[
                        _buildApplicantDocumentsSection(
                          context,
                          data,
                          query,
                          showTitle: !isFilterApplied,
                        ),
                        if (showCoApplicant || showLoanApp)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Divider(height: 1, thickness: 1, color: AppColors.line),
                          ),
                      ],

                      // Section 2: Co-Applicant Documents
                      if (showCoApplicant) ...[
                        _buildCoApplicantDocumentsSection(
                          context,
                          controller.coApplicantsWithDocuments,
                          query,
                          showTitle: !isFilterApplied,
                        ),
                        if (showLoanApp)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            child: Divider(height: 1, thickness: 1, color: AppColors.line),
                          ),
                      ],

                      // Section 3: Loan Application Documents
                      if (showLoanApp)
                        _buildLoanApplicationDocumentsSection(
                          context,
                          controller.leadsWithDocuments,
                          query,
                          showTitle: !isFilterApplied,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SECTION 1: APPLICANT DOCUMENTS
  // =========================================================================

  Widget _buildApplicantDocumentsSection(
    BuildContext context,
    MyDocumentsResponseData data,
    String query, {
    bool showTitle = true,
  }) {
    final doc = data.document;
    if (doc == null) return const SizedBox.shrink();

    final List<Widget> cards = [];

    // 1. Aadhaar Card
    final hasAadhaar = doc.aadharCardNumber != null ||
        doc.aadharCardImage != null ||
        (data.documentUrls?.aadhaar.isNotEmpty ?? false);

    if (hasAadhaar) {
      final title = 'Aadhaar Card';
      final idNumber = _maskAadhaar(doc.aadharCardNumber);
      final subtitle = 'Identity Number: $idNumber';

      if (query.isEmpty ||
          title.toLowerCase().contains(query) ||
          subtitle.toLowerCase().contains(query)) {
        final List<String> aadhaarUrls = [];
        if (data.documentUrls?.aadhaar.isNotEmpty ?? false) {
          for (final f in data.documentUrls!.aadhaar) {
            if (f.url != null && f.url!.isNotEmpty) {
              aadhaarUrls.add(f.url!);
            }
          }
        } else if (doc.aadharCardImage != null && doc.aadharCardImage!.isNotEmpty) {
          aadhaarUrls.add(doc.aadharCardImage!.startsWith('http')
              ? doc.aadharCardImage!
              : 'https://app.crm.finsphereai.com/storage/${doc.aadharCardImage}');
        }

        final status = (doc.aadhaarStatus != null && doc.aadhaarStatus!.isNotEmpty)
            ? doc.aadhaarStatus!.capitalizeFirst ?? 'Uploaded'
            : 'Uploaded';

        cards.add(
          _buildAppThemeCard(
            title: title,
            subtitle: subtitle,
            badgeText: status,
            icon: Icons.badge_outlined,
            isFeatured: true, // featured card with purple-navy gradient
            onTap: () {
              final List<DocumentDetailImageItem> images = [];
              if (data.documentUrls?.aadhaar.isNotEmpty ?? false) {
                images.addAll(data.documentUrls!.aadhaar.map(
                  (e) => DocumentDetailImageItem.fromMyDocumentFileItem(e),
                ));
              } else {
                for (final u in aadhaarUrls) {
                  images.add(DocumentDetailImageItem(url: u, isImage: true));
                }
              }
              Get.to(() => DocumentViewScreen(
                    detail: DocumentDetailModel(
                      type: 'aadhaar',
                      title: 'Aadhaar Card',
                      number: doc.aadharCardNumber,
                      status: status,
                      imageUrls: images,
                      createdAt: doc.createdAt,
                      updatedAt: doc.updatedAt,
                    ),
                  ));
            },
          ),
        );
      }
    }

    // 2. PAN Card
    final hasPan = doc.panCardNumber != null ||
        doc.panCardImage != null ||
        (data.documentUrls?.pan.isNotEmpty ?? false);

    if (hasPan) {
      final title = 'PAN Card';
      final taxId = _maskPan(doc.panCardNumber);
      final subtitle = 'Tax ID: $taxId';

      if (query.isEmpty ||
          title.toLowerCase().contains(query) ||
          subtitle.toLowerCase().contains(query)) {
        final List<String> panUrls = [];
        if (data.documentUrls?.pan.isNotEmpty ?? false) {
          for (final f in data.documentUrls!.pan) {
            if (f.url != null && f.url!.isNotEmpty) {
              panUrls.add(f.url!);
            }
          }
        } else if (doc.panCardImage != null && doc.panCardImage!.isNotEmpty) {
          panUrls.add(doc.panCardImage!.startsWith('http')
              ? doc.panCardImage!
              : 'https://app.crm.finsphereai.com/storage/${doc.panCardImage}');
        }

        final status = (doc.panStatus != null && doc.panStatus!.isNotEmpty)
            ? doc.panStatus!.capitalizeFirst ?? 'Uploaded'
            : 'Uploaded';

        cards.add(
          _buildAppThemeCard(
            title: title,
            subtitle: subtitle,
            badgeText: status,
            icon: Icons.credit_card_rounded,
            onTap: () {
              final List<DocumentDetailImageItem> images = [];
              if (data.documentUrls?.pan.isNotEmpty ?? false) {
                images.addAll(data.documentUrls!.pan.map(
                  (e) => DocumentDetailImageItem.fromMyDocumentFileItem(e),
                ));
              } else {
                for (final u in panUrls) {
                  images.add(DocumentDetailImageItem(url: u, isImage: true));
                }
              }
              Get.to(() => DocumentViewScreen(
                    detail: DocumentDetailModel(
                      type: 'pan',
                      title: 'PAN Card',
                      number: doc.panCardNumber,
                      status: status,
                      imageUrls: images,
                      createdAt: doc.createdAt,
                      updatedAt: doc.updatedAt,
                    ),
                  ));
            },
          ),
        );
      }
    }

    // 3. Credit Report (CIBIL)
    if (doc.cibilScore != null) {
      final title = 'Credit Report (CIBIL)';
      final scoreStr = doc.cibilScore.toString();
      final subtitle = 'Latest Score: $scoreStr';

      if (query.isEmpty ||
          title.toLowerCase().contains(query) ||
          scoreStr.contains(query)) {
        cards.add(
          _buildAppThemeCard(
            title: title,
            subtitle: subtitle,
            badgeText: 'Generated',
            icon: Icons.analytics_outlined,
            onTap: () {
              Get.to(() => const CibilScoreScreen());
            },
          ),
        );
      }
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) _buildSectionHeader('Applicant Documents'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.22,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) => cards[index],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION 2: CO-APPLICANT DOCUMENTS
  // =========================================================================

  Widget _buildCoApplicantDocumentsSection(
    BuildContext context,
    List<MyDocumentsCoApplicant> coApplicants,
    String query, {
    bool showTitle = true,
  }) {
    final List<Widget> groups = [];

    for (final ca in coApplicants) {
      final List<Widget> cards = [];

      // Aadhaar Card
      final hasAadhaar = (ca.aadhaarCardNumber != null && ca.aadhaarCardNumber!.isNotEmpty) ||
          ca.aadhaarCardImageUrls.isNotEmpty;
      if (hasAadhaar) {
        final title = 'Aadhaar Card';
        final idNumber = _maskAadhaar(ca.aadhaarCardNumber);
        final subtitle = 'Identity Number: $idNumber';

        if (query.isEmpty ||
            title.toLowerCase().contains(query) ||
            subtitle.toLowerCase().contains(query) ||
            (ca.name?.toLowerCase().contains(query) ?? false)) {
          final List<String> aadhaarUrls = ca.aadhaarCardImageUrls
              .map((e) => e.url ?? '')
              .where((u) => u.isNotEmpty)
              .toList();

          cards.add(
            _buildAppThemeCard(
              title: title,
              subtitle: subtitle,
              badgeText: 'Verified',
              icon: Icons.badge_outlined,
              onTap: () {
                _checkVerificationAndProceed(
                  context,
                  coApplicantId: ca.id,
                  docTitle: 'Aadhaar Card',
                  coApplicantName: ca.name,
                  coApplicantPhone: ca.phone,
                  onVerified: () {
                    final List<DocumentDetailImageItem> images = ca
                        .aadhaarCardImageUrls
                        .map((e) =>
                            DocumentDetailImageItem.fromMyDocumentFileItem(e))
                        .toList();
                    if (images.isEmpty) {
                      for (final u in aadhaarUrls) {
                        images.add(
                            DocumentDetailImageItem(url: u, isImage: true));
                      }
                    }
                    Get.to(() => DocumentViewScreen(
                          detail: DocumentDetailModel(
                            type: 'aadhaar',
                            title: '${ca.name ?? "Co-Applicant"} - Aadhaar Card',
                            number: ca.aadhaarCardNumber,
                            status: 'Verified',
                            imageUrls: images,
                            createdAt: ca.createdAt,
                            updatedAt: ca.updatedAt,
                          ),
                        ));
                  },
                );
              },
            ),
          );
        }
      }

      // PAN Card
      final hasPan = (ca.panCardNumber != null && ca.panCardNumber!.isNotEmpty) ||
          (ca.panCardImageUrl != null && ca.panCardImageUrl!.isNotEmpty);
      if (hasPan) {
        final title = 'PAN Card';
        final taxId = _maskPan(ca.panCardNumber);
        final subtitle = 'Tax ID: $taxId';

        if (query.isEmpty ||
            title.toLowerCase().contains(query) ||
            subtitle.toLowerCase().contains(query) ||
            (ca.name?.toLowerCase().contains(query) ?? false)) {
          final panUrl = ca.panCardImageUrl;

          cards.add(
            _buildAppThemeCard(
              title: title,
              subtitle: subtitle,
              badgeText: 'Uploaded',
              icon: Icons.credit_card_rounded,
              onTap: () {
                _checkVerificationAndProceed(
                  context,
                  coApplicantId: ca.id,
                  docTitle: 'PAN Card',
                  coApplicantName: ca.name,
                  coApplicantPhone: ca.phone,
                  onVerified: () {
                    final List<DocumentDetailImageItem> images = [];
                    if (panUrl != null && panUrl.isNotEmpty) {
                      images.add(DocumentDetailImageItem(
                        name: ca.panCardImage,
                        url: panUrl,
                        isImage: true,
                      ));
                    }
                    Get.to(() => DocumentViewScreen(
                          detail: DocumentDetailModel(
                            type: 'pan',
                            title: '${ca.name ?? "Co-Applicant"} - PAN Card',
                            number: ca.panCardNumber,
                            status: 'Uploaded',
                            imageUrls: images,
                            createdAt: ca.createdAt,
                            updatedAt: ca.updatedAt,
                          ),
                        ));
                  },
                );
              },
            ),
          );
        }
      }

      if (cards.isNotEmpty) {
        groups.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoApplicantHeader(ca),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.22,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) => cards[index],
                ),
              ),
            ],
          ),
        );
      }
    }

    if (groups.isEmpty) return const SizedBox.shrink();

    final List<Widget> childrenWithDividers = [];
    for (int i = 0; i < groups.length; i++) {
      childrenWithDividers.add(groups[i]);
      if (i < groups.length - 1) {
        childrenWithDividers.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(height: 1, thickness: 1, color: AppColors.line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) _buildSectionHeader('Co-Applicant Documents'),
        ...childrenWithDividers,
      ],
    );
  }

  // =========================================================================
  // SECTION 3: LOAN APPLICATION DOCUMENTS
  // =========================================================================

  Widget _buildLoanApplicationDocumentsSection(
    BuildContext context,
    List<MyDocumentsLead> leads,
    String query, {
    bool showTitle = true,
  }) {
    final List<Widget> groups = [];

    for (final lead in leads) {
      final List<Widget> cards = [];

      lead.documentFiles.forEach((docKey, fileList) {
        for (final item in fileList) {
          final formattedKey = _formatDocKey(docKey);
          final fileName = item.name ?? '';
          final title = fileName.isNotEmpty ? '$formattedKey: $fileName' : formattedKey;
          final subtitle = 'Uploaded on ${_formatDateOnly(lead.createdAt)}';

          if (query.isEmpty ||
              title.toLowerCase().contains(query) ||
              subtitle.toLowerCase().contains(query) ||
              (lead.loanType?.toLowerCase().contains(query) ?? false)) {
            final status = (item.status != null && item.status!.isNotEmpty)
                ? item.status!.capitalizeFirst ?? 'Pending'
                : 'Pending';

            cards.add(
              _buildAppThemeCard(
                title: title,
                subtitle: subtitle,
                badgeText: status,
                icon: Icons.description_outlined,
                onTap: () {
                  final List<DocumentDetailImageItem> images = [];
                  if (item.url != null && item.url!.isNotEmpty) {
                    images.add(
                      DocumentDetailImageItem.fromMyDocumentFileItem(item),
                    );
                  }
                  Get.to(() => DocumentViewScreen(
                        detail: DocumentDetailModel(
                          type: formattedKey,
                          title: title,
                          number: lead.id != null ? 'Lead #${lead.id}' : null,
                          status: status,
                          imageUrls: images,
                          createdAt: lead.createdAt,
                          updatedAt: lead.updatedAt,
                        ),
                      ));
                },
              ),
            );
          }
        }
      });

      if (cards.isNotEmpty) {
        groups.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeadHeader(lead),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.22,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) => cards[index],
                ),
              ),
            ],
          ),
        );
      }
    }

    if (groups.isEmpty) return const SizedBox.shrink();

    final List<Widget> childrenWithDividers = [];
    for (int i = 0; i < groups.length; i++) {
      childrenWithDividers.add(groups[i]);
      if (i < groups.length - 1) {
        childrenWithDividers.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(height: 1, thickness: 1, color: AppColors.line),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) _buildSectionHeader('Loan Application Documents'),
        ...childrenWithDividers,
      ],
    );
  }

  // =========================================================================
  // APP THEME CARD UI (PRESERVING APP CONSISTENCY)
  // =========================================================================

  Widget _buildAppThemeCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    bool isFeatured = false,
    VoidCallback? onTap,
  }) {
    final Color badgeBg;
    final Color badgeTextColor;

    final lower = badgeText.toLowerCase();
    if (lower == 'verified' || lower == 'uploaded' || lower == 'accepted') {
      badgeBg = isFeatured ? AppColors.successGreenBg : AppColors.successGreenBg;
      badgeTextColor = AppColors.successGreen;
    } else if (lower == 'generated' || lower == 'pending') {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
    } else if (lower == 'rejected') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
    } else {
      badgeBg = AppColors.indigoTint;
      badgeTextColor = AppColors.navy;
    }

    final cardContent = isFeatured
        ? Container(
            padding: const EdgeInsets.all(12),
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
                // Top Row: Amber Icon + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.amber,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                // Bottom Column: Title + Subtitle
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.indigoTint,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.all(12),
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
                        icon,
                        color: AppColors.indigo,
                        size: 19,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                // Bottom Column: Title + Subtitle
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

    return GestureDetector(
      onTap: onTap,
      child: cardContent,
    );
  }

  // =========================================================================
  // HEADERS & BARS
  // =========================================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildCoApplicantHeader(MyDocumentsCoApplicant ca) {
    final name = ca.name ?? 'Co-Applicant';
    final rel = ca.relationship ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    final date = _formatDateOnly(ca.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo, AppColors.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (rel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.indigoTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rel,
                          style: const TextStyle(
                            color: AppColors.indigo,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Added on $date',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadHeader(MyDocumentsLead lead) {
    final loanType = lead.loanType ?? 'Loan';
    final amount = lead.loanAmount != null ? '₹${lead.loanAmount}' : '';
    final appliedTime = _formatDateTime(lead.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.indigoTint,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.navy,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$loanType Application',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ID: #${lead.id}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${amount.isNotEmpty ? "$amount • " : ""}$appliedTime',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<DashboardController>()) {
                  final dash = Get.find<DashboardController>();
                  if (dash.currentNavIndex.value == 3) {
                    dash.currentNavIndex.value = 0;
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

          const Expanded(
            child: Center(
              child: Text(
                'Document Wallet',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          if (showBackButton)
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DocumentWalletController controller) {
    return Container(
      height: 46,
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
          fontSize: 14,
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
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  /// Top side horizontal filter chips for the 3 sections
  Widget _buildSectionFilterChips(DocumentWalletController controller) {
    return Obx(() {
      final selected = controller.selectedSection.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.sectionFilters.map((sec) {
            final isSelected = selected == sec;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.selectedSection.value = sec,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.navy : AppColors.line,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.navy.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    sec,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.navy,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No documents found',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your uploaded and verified documents will appear here.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySectionState(BuildContext context, String section) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.navy,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No $section documents found',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Documents will appear here once uploaded.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Checks co-applicant verification status via GET {{baseUrl}}/co-applicants/{id}/documents/verification-status
  /// If verified -> onVerified() immediately opens DocumentViewScreen
  /// If unverified -> opens CoApplicantOtpBottomSheet, and upon successful OTP verification opens DocumentViewScreen
  Future<void> _checkVerificationAndProceed(
    BuildContext context, {
    required dynamic coApplicantId,
    String? coApplicantName,
    String? coApplicantPhone,
    String? docTitle,
    required VoidCallback onVerified,
  }) async {
    if (coApplicantId == null) {
      onVerified();
      return;
    }

    // Show loading dialog while checking verification status
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Checking Access...',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final res = await ApiService.getCoApplicantDocumentVerificationStatus(
        coApplicantId: coApplicantId,
      );

      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      final isSuccess = res['success'] == true || res['status_code'] == 200;
      if (isSuccess && res['data'] is Map<String, dynamic>) {
        final data = res['data'] as Map<String, dynamic>;
        final docAccess = data['document_access'] is Map<String, dynamic>
            ? data['document_access'] as Map<String, dynamic>
            : null;
        final isVerified = docAccess != null && docAccess['verified'] == true;

        if (isVerified) {
          // Already verified on backend -> View directly
          onVerified();
        } else {
          // Unverified -> Show Verification Required dialog
          if (context.mounted) {
            _showVerificationRequiredDialog(
              context,
              docTitle: docTitle,
              onVerifyNumber: () {
                CoApplicantOtpBottomSheet.show(
                  context: context,
                  coApplicantId: coApplicantId,
                  coApplicantName: coApplicantName ?? 'Co-Applicant',
                  initialPhone: coApplicantPhone,
                  onVerified: onVerified,
                );
              },
            );
          }
        }
      } else {
        // API returned notice/error
        Get.snackbar(
          'Notice',
          res['message']?.toString() ??
              'Unable to verify document access. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      debugPrint('Error in checkVerificationStatus: $e');
      Get.snackbar(
        'Error',
        'Failed to verify document access. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showVerificationRequiredDialog(
    BuildContext context, {
    String? docTitle,
    required VoidCallback onVerifyNumber,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.indigo.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.navy,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verification Required',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                docTitle != null
                    ? 'To view "$docTitle", registered mobile number verification is required.'
                    : 'To view co-applicant documents, registered mobile number verification is required.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.indigo,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'An OTP will be sent to the registered mobile number for verification.',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          onVerifyNumber();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Verify Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // UTILITIES & FORMATTERS
  // =========================================================================

  String _maskAadhaar(String? raw) {
    if (raw == null || raw.isEmpty) return 'Identity Proof';
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length >= 4) {
      return 'XXXX-XXXX-${cleaned.substring(cleaned.length - 4)}';
    }
    return raw;
  }

  String _maskPan(String? raw) {
    if (raw == null || raw.isEmpty) return 'Tax ID';
    if (raw.length >= 5) {
      return '${raw.substring(0, 2)}XXXXXX${raw.substring(raw.length - 1)}';
    }
    return raw;
  }

  String _formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM, yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM, yyyy hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDocKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
