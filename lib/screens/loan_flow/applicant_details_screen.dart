import 'dart:math' as math;
import '../../theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controller/applicant_details_controller.dart';
import '../../models/co_applicants_list_model.dart';
import '../../models/co_applicant_detail_model.dart';
import '../../models/applicant_detail_model.dart';
import 'add_co_applicant_screen.dart';
import 'recommended_loan_offers_screen.dart';
import '../photo_gallery_screen.dart';

/// Screen displaying primary applicant & co-applicant details (Reference Image Left Screen)
class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApplicantDetailsController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, controller),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.navy,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await Future.wait([
                    controller.fetchApplicantDetails(),
                    controller.fetchCoApplicants(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Segmented Tabs: "Applicant" | "Co-applicant · X"
                      _buildSegmentedTabs(controller),

                      const SizedBox(height: 16),

                      // Switch between Primary Applicant and Co-applicants card list
                      Obx(() {
                        if (controller.selectedTabIndex.value == 0) {
                          return _buildPrimaryApplicantContent(context, controller);
                        } else {
                          return _buildCoApplicantsCardList(context, controller);
                        }
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom "Submit application →" Button
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  /// Primary applicant details tab content
  Widget _buildPrimaryApplicantContent(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    if (controller.isLoadingApplicantDetails.value &&
        controller.applicantDetailsData.value == null) {
      return _buildSkeletonApplicantContent();
    }

    final data = controller.applicantDetailsData.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Banner Card with cosmic background
        _buildProfileBanner(controller, data),

        const SizedBox(height: 20),

        // Verification Section
        _buildSectionHeader('VERIFICATION'),
        const SizedBox(height: 8),
        _buildVerificationCard(controller, data),

        const SizedBox(height: 20),

        // Personal & Contact Section
        _buildSectionHeader('PERSONAL & CONTACT'),
        const SizedBox(height: 8),
        _buildPersonalContactCard(controller, data),

        const SizedBox(height: 20),

        // Documents & Proofs Section
        _buildPrimaryApplicantDocumentsSection(context, controller, data),
      ],
    );
  }

  /// Co-applicants card list tab content showing all items from GET /co-applicants
  Widget _buildCoApplicantsCardList(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    if (controller.isLoadingCoApplicants.value) {
      return _buildSkeletonCoApplicantCards();
    }

    final list = controller.coApplicantsList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        _buildSectionHeader('CO-APPLICANTS (${list.length})'),
        const SizedBox(height: 12),

        if (list.isEmpty)
          _buildEmptyCoApplicantsState(context, controller)
        else ...[
          for (int i = 0; i < list.length; i++)
            _buildCoApplicantCard(context, controller, list[i], i),
          const SizedBox(height: 4),
          _buildAddAnotherCoAppButton(context, controller),
        ],
      ],
    );
  }

  /// Empty state when no co-applicants are retrieved
  Widget _buildEmptyCoApplicantsState(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.indigoTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 28,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Co-Applicants Added',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adding a co-applicant can increase your loan eligibility and approval speed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showSelectMemberRoleBottomSheet(context, controller),
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text(
              'Add Co-Applicant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// Card widget for each co-applicant item from API
  Widget _buildCoApplicantCard(
    BuildContext context,
    ApplicantDetailsController controller,
    CoApplicantItem item,
    int index,
  ) {
    final initials = (item.name != null && item.name!.trim().isNotEmpty)
        ? item.name!
            .trim()
            .split(' ')
            .take(2)
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .join()
        : 'CA';

    final hasPhone = item.phone != null && item.phone!.trim().isNotEmpty;
    final hasEmployment =
        item.employmentType != null && item.employmentType!.trim().isNotEmpty;
    final hasEmail = item.email != null && item.email!.trim().isNotEmpty;
    final hasPan =
        item.panCardNumber != null && item.panCardNumber!.trim().isNotEmpty;
    final hasAadhaar =
        item.aadhaarCardNumber != null && item.aadhaarCardNumber!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row with Avatar, Name, Relationship and Applicant Type badges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.indigo.withValues(alpha: 0.85),
                        AppColors.navy,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name and tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name?.trim().isNotEmpty == true
                            ? item.name!
                            : 'Co-Applicant #${index + 1}',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (item.relationship != null &&
                              item.relationship!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.amber.withValues(alpha: 0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                item.relationship!,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          if (item.applicantType != null &&
                              item.applicantType!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.applicantType == 'Financial'
                                    ? AppColors.indigoTint
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: item.applicantType == 'Financial'
                                      ? AppColors.indigo.withValues(alpha: 0.3)
                                      : AppColors.line,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                item.applicantType!,
                                style: TextStyle(
                                  color: item.applicantType == 'Financial'
                                      ? AppColors.indigo
                                      : AppColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: AppColors.successGreen),
                      SizedBox(width: 4),
                      Text(
                        'Added',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.line),

          // Detail Info Rows
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (hasPhone)
                  _buildCoAppInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: _maskPhone(item.phone!),
                  ),
                if (hasEmployment) ...[
                  if (hasPhone) const SizedBox(height: 8),
                  _buildCoAppInfoRow(
                    icon: Icons.work_outline_rounded,
                    label: 'Employment',
                    value: item.employmentType!,
                  ),
                ],
                if (hasEmail) ...[
                  const SizedBox(height: 8),
                  _buildCoAppInfoRow(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: item.email!,
                  ),
                ],
                if (hasPan) ...[
                  const SizedBox(height: 8),
                  _buildCoAppInfoRow(
                    icon: Icons.credit_card_outlined,
                    label: 'PAN Number',
                    value: _maskPan(item.panCardNumber!),
                  ),
                ],
                if (hasAadhaar) ...[
                  const SizedBox(height: 8),
                  _buildCoAppInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Aadhaar Number',
                    value: _maskAadhaar(item.aadhaarCardNumber!),
                  ),
                ],
              ],
            ),
          ),

          // 3 Actions Bar separated by vertical dividers (Edit | View Details | Delete)
          const Divider(height: 1, color: AppColors.line),
          IntrinsicHeight(
            child: Row(
              children: [
                // 1. Edit Action
                Expanded(
                  child: InkWell(
                    onTap: () => _handleEditCoApplicant(context, controller, item),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit_outlined, size: 15, color: AppColors.navy),
                          SizedBox(width: 5),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vertical Divider 1
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.line,
                  indent: 8,
                  endIndent: 8,
                ),

                // 2. View Details Action
                Expanded(
                  child: InkWell(
                    onTap: () => _showCoApplicantDetailsBottomSheet(
                      context,
                      controller,
                      item.id,
                      item.name ?? 'Co-Applicant #${index + 1}',
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.visibility_outlined, size: 15, color: AppColors.navy),
                          SizedBox(width: 5),
                          Text(
                            'View Details',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Vertical Divider 2
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.line,
                  indent: 8,
                  endIndent: 8,
                ),

                // 3. Delete Action
                Expanded(
                  child: InkWell(
                    onTap: () => _showDeleteCoAppConfirmationDialog(context, controller, item),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.errorRed),
                          SizedBox(width: 5),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mask mobile number: e.g. 9898900001 -> +91 98XXXX0001
  String _maskPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      final start = clean.substring(0, 2);
      final end = clean.substring(clean.length - 4);
      return '+91 ${start}XXXX$end';
    }
    return phone;
  }

  /// Mask PAN card number: e.g. PQRSX6789K -> XXXXX6789K (shows last 5)
  String _maskPan(String pan) {
    final trimmed = pan.trim();
    if (trimmed.length == 10) {
      return 'XXXXX${trimmed.substring(5)}';
    }
    return trimmed;
  }

  /// Mask Aadhaar card number: e.g. 555566667777 -> XXXX XXXX 7777 (shows last 4)
  String _maskAadhaar(String aadhaar) {
    final clean = aadhaar.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 12) {
      return 'XXXX XXXX ${clean.substring(8)}';
    }
    return aadhaar;
  }

  /// Handle editing a co-applicant
  void _handleEditCoApplicant(
    BuildContext context,
    ApplicantDetailsController controller,
    CoApplicantItem item,
  ) {
    controller.prepareEditCoApplicant(item);
    final role = item.relationship?.toLowerCase() == 'guarantor' ? 'Guarantor' : 'Co-Applicant';
    Get.to(() => AddCoApplicantScreen(
      role: role,
      isEdit: true,
      coApplicantId: item.id,
    ));
  }

  /// Show delete confirmation dialog
  void _showDeleteCoAppConfirmationDialog(
    BuildContext context,
    ApplicantDetailsController controller,
    CoApplicantItem item,
  ) {
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Co-Applicant',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove ${item.name ?? 'this co-applicant'}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
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
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isDeletingCoApplicant.value
                              ? null
                              : () => controller.deleteCoApplicant(item.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isDeletingCoApplicant.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
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

  /// Opens full details bottom sheet for a co-applicant: GET {{baseUrl}}/co-applicants/{id}
  void _showCoApplicantDetailsBottomSheet(
    BuildContext context,
    ApplicantDetailsController controller,
    dynamic coApplicantId,
    String coApplicantName,
  ) {
    controller.fetchCoApplicantDetails(coApplicantId);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag indicator handle & top header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Co-Applicant Details',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.muted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoadingCoAppDetails.value) {
                  return _buildSkeletonDetailsPlaceholder();
                }

                final details = controller.selectedCoApplicantDetails.value;
                if (details == null || details.coApplicant == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 36, color: AppColors.muted),
                          const SizedBox(height: 10),
                          const Text(
                            'No details available',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => controller.fetchCoApplicantDetails(coApplicantId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final profile = details.coApplicant!;

                return RefreshIndicator(
                  color: AppColors.navy,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await controller.fetchCoApplicantDetails(coApplicantId);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Profile Hero Card
                      _buildDetailHeroCard(profile, details),

                      const SizedBox(height: 10),

                      // Section 1: Personal Details
                      _buildDetailCard(
                        title: 'PERSONAL DETAILS',
                        icon: Icons.person_outline_rounded,
                        children: [
                          if (profile.name?.isNotEmpty == true)
                            _buildDetailItem('Full Name', profile.name!),
                          if (profile.phone?.isNotEmpty == true)
                            _buildDetailItem('Mobile', profile.phone!),
                          if (profile.email?.isNotEmpty == true)
                            _buildDetailItem('Email', profile.email!),
                          if (profile.panCardNumber?.isNotEmpty == true)
                            _buildDetailItem('PAN Card Number', profile.panCardNumber!),
                          if (profile.aadhaarCardNumber?.isNotEmpty == true)
                            _buildDetailItem('Aadhaar Card Number', profile.aadhaarCardNumber!),
                          if (profile.dateOfBirth?.isNotEmpty == true)
                            _buildDetailItem('Date of Birth', profile.dateOfBirth!),
                          if (profile.gender?.isNotEmpty == true)
                            _buildDetailItem('Gender', profile.gender!),
                          if (profile.maritalStatus?.isNotEmpty == true)
                            _buildDetailItem('Marital Status', profile.maritalStatus!),
                          if (profile.religion?.isNotEmpty == true)
                            _buildDetailItem('Religion', profile.religion!),
                          if (profile.fatherName?.isNotEmpty == true)
                            _buildDetailItem("Father's Name", profile.fatherName!),
                          if (profile.motherName?.isNotEmpty == true)
                            _buildDetailItem("Mother's Name", profile.motherName!),
                          if (profile.currentResidenceType?.isNotEmpty == true)
                            _buildDetailItem('Residence Type', profile.currentResidenceType!),
                          if (profile.permanentAddress?.isNotEmpty == true)
                            _buildDetailItem('Permanent Address', profile.permanentAddress!),
                          if (profile.communicationAddress?.isNotEmpty == true)
                            _buildDetailItem('Communication Address', profile.communicationAddress!),
                        ],
                      ),

                      // Section 2: Employment & Income
                      _buildDetailCard(
                        title: 'EMPLOYMENT & INCOME',
                        icon: Icons.work_outline_rounded,
                        children: [
                          if (profile.employmentType?.isNotEmpty == true)
                            _buildDetailItem('Employment Type', profile.employmentType!),
                          if (profile.companyName?.isNotEmpty == true)
                            _buildDetailItem('Company Name', profile.companyName!),
                          if (profile.sector?.isNotEmpty == true)
                            _buildDetailItem('Sector', profile.sector!),
                          if (profile.companyType?.isNotEmpty == true)
                            _buildDetailItem('Company Type', profile.companyType!),
                          if (profile.designation?.isNotEmpty == true)
                            _buildDetailItem('Designation', profile.designation!),
                          if (profile.monthlySalary?.isNotEmpty == true)
                            _buildDetailItem('Monthly Salary', '₹${profile.monthlySalary!}'),
                          if (profile.incomeType?.isNotEmpty == true)
                            _buildDetailItem('Income Type', profile.incomeType!),
                          if (profile.bankSalaryAmount?.isNotEmpty == true)
                            _buildDetailItem('Bank Salary', '₹${profile.bankSalaryAmount!}'),
                          if (profile.cashSalaryAmount?.isNotEmpty == true)
                            _buildDetailItem('Cash Salary', '₹${profile.cashSalaryAmount!}'),
                          if (profile.workExperience?.isNotEmpty == true)
                            _buildDetailItem('Total Experience', '${profile.workExperience!} yrs'),
                          if (profile.currentExperience?.isNotEmpty == true)
                            _buildDetailItem('Current Experience', '${profile.currentExperience!} yrs'),
                          if (profile.companyAddress?.isNotEmpty == true)
                            _buildDetailItem('Company Address', profile.companyAddress!),
                          if (profile.businessName?.isNotEmpty == true)
                            _buildDetailItem('Business Name', profile.businessName!),
                          if (profile.businessTurnover?.isNotEmpty == true)
                            _buildDetailItem('Business Turnover', profile.businessTurnover!),
                        ],
                      ),

                      // Section 3: Credit & Obligations
                      _buildDetailCard(
                        title: 'CREDIT & OBLIGATIONS',
                        icon: Icons.account_balance_outlined,
                        children: [
                          if (profile.cibilScore != null)
                            _buildDetailItem('CIBIL Score', '${profile.cibilScore}'),
                          if (profile.cibilIssue?.isNotEmpty == true)
                            _buildDetailItem('CIBIL Issue', profile.cibilIssue!),
                          if (profile.obligations.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Existing Loan Obligations',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            for (final obl in profile.obligations)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.lightBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          obl.bankName ?? 'Bank',
                                          style: const TextStyle(
                                            color: AppColors.textDark,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        if (obl.loanType?.isNotEmpty == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.indigoTint,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColors.indigo.withValues(alpha: 0.25),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              obl.loanType!,
                                              style: const TextStyle(
                                                color: AppColors.indigo,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (obl.emiAmount != null)
                                          Text(
                                            'EMI: ₹${obl.emiAmount}',
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        if (obl.outstandingAmount != null)
                                          Text(
                                            'Outstanding: ₹${obl.outstandingAmount}',
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (obl.remainingTenure?.isNotEmpty == true) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Remaining: ${obl.remainingTenure!}',
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),

                      // Section 4: Documents & Proofs
                      _buildDocumentsSection(context, details),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Profile Hero Card inside details bottom sheet
  Widget _buildDetailHeroCard(CoApplicantDetailProfile profile, CoApplicantDetailData details) {
    final name = profile.name ?? 'Co-Applicant';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join()
        : 'CA';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.indigo, AppColors.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (profile.relationship?.isNotEmpty == true)
                      _buildPillTag(profile.relationship!, AppColors.amber.withValues(alpha: 0.15), AppColors.textDark),
                    if (profile.applicantType?.isNotEmpty == true)
                      _buildPillTag(profile.applicantType!, AppColors.indigoTint, AppColors.indigo),
                    if (profile.employmentType?.isNotEmpty == true)
                      _buildPillTag(profile.employmentType!, AppColors.canvas, AppColors.muted),
                  ],
                ),
              ],
            ),
          ),
          if (profile.cibilScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successGreenBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  const Text(
                    'CIBIL',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${profile.cibilScore}',
                    style: const TextStyle(
                      color: AppColors.successGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPillTag(String label, Color bg, Color textColor, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor ?? textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Collapsible/Structured Card widget for sections in details bottom sheet
  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.navy, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 1, color: AppColors.line),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  /// Single Key-Value row inside detail bottom sheet
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Documents & Proofs section — card-based style matching Upload Documents screen
  Widget _buildDocumentsSection(BuildContext context, CoApplicantDetailData details) {
    final hasDocuments = details.documents.isNotEmpty;
    final uploadedCount = details.documents
        .where((d) => d.uploaded == true || d.files.isNotEmpty)
        .length;
    final totalCount = details.documents.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header OUTSIDE card (consistent with upload document screen)
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_open_rounded, color: AppColors.navy, size: 15),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DOCUMENTS & PROOFS',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (hasDocuments)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: uploadedCount == totalCount && totalCount > 0
                        ? AppColors.successGreenBg
                        : AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    '$uploadedCount/$totalCount',
                    style: TextStyle(
                      color: uploadedCount == totalCount && totalCount > 0
                          ? AppColors.successGreen
                          : AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Document Cards
        if (hasDocuments)
          for (final doc in details.documents)
            _buildDocUploadStyleCard(context, doc)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.folder_open_rounded,
                      color: AppColors.navy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No Documents Uploaded',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No documents or proofs have been uploaded for this co-applicant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Individual Document Card matching the Upload Document screen card style
  Widget _buildDocUploadStyleCard(BuildContext context, CoApplicantDocumentConfig doc) {
    final isUploaded = doc.uploaded == true ||
        doc.status?.toLowerCase() == 'uploaded' ||
        doc.files.isNotEmpty;
    final fileCount = doc.files.length;
    final hasRejected = doc.files.any((f) => f.status?.toLowerCase() == 'rejected');
    final String label = doc.label ?? _formatDocKey(doc.key ?? 'Document');
    final docKey = doc.key ?? '';

    // Collect all valid URLs for viewing in photo gallery
    final allUrls = doc.files
        .map((f) => (f.url?.isNotEmpty == true) ? f.url! : (f.name ?? ''))
        .where((u) => u.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRejected
              ? AppColors.errorRed
              : isUploaded
                  ? AppColors.indigo.withValues(alpha: 0.35)
                  : AppColors.line,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Leading Icon Container (42x42 squircle matching upload screen)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasRejected
                        ? AppColors.errorRedBg
                        : isUploaded
                            ? AppColors.successGreenBg
                            : AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      hasRejected
                          ? Icons.error_outline_rounded
                          : isUploaded
                              ? Icons.check_circle_rounded
                              : _getDocIcon(docKey),
                      color: hasRejected
                          ? AppColors.errorRed
                          : isUploaded
                              ? AppColors.successGreen
                              : AppColors.navy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Subtitle / File count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (fileCount > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Text(
                                '$fileCount',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isUploaded
                            ? (fileCount == 1
                                ? (doc.files.first.name ?? 'Uploaded ✓')
                                : '$fileCount files attached')
                            : 'Upload pending',
                        style: TextStyle(
                          color: hasRejected
                              ? AppColors.errorRed
                              : isUploaded
                                  ? AppColors.successGreen
                                  : AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Action: View Document Button (if uploaded) or Pending Tag
                if (isUploaded)
                  GestureDetector(
                    onTap: () => _showVerifyToViewDocDialog(
                      context,
                      docTitle: label,
                      imagePaths: allUrls,
                      initialIndex: 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.indigoTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.indigo.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.navy,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // If multiple files, display file pills list below
            if (fileCount > 1) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: AppColors.line),
              const SizedBox(height: 8),
              ...doc.files.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                final fileName = file.name?.trim().isNotEmpty == true
                    ? file.name!
                    : 'Attached Document #${idx + 1}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showVerifyToViewDocDialog(
                          context,
                          docTitle: label,
                          fileName: fileName,
                          imagePaths: allUrls,
                          initialIndex: idx,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 11,
                                color: AppColors.navy,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'View',
                                style: TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// Get icon for document key matching upload documents screen
  IconData _getDocIcon(String key) {
    final k = key.toLowerCase();
    if (k.contains('profile')) return Icons.account_circle_outlined;
    if (k.contains('aadhar') || k.contains('aadhaar')) return Icons.badge_outlined;
    if (k.contains('pan')) return Icons.credit_card_outlined;
    if (k.contains('bank')) return Icons.account_balance_outlined;
    if (k.contains('salary') || k.contains('payslip')) return Icons.receipt_long_outlined;
    if (k.contains('itr') || k.contains('form_16') || k.contains('tax')) return Icons.request_quote_outlined;
    return Icons.description_outlined;
  }

  /// Confirmation dialog before viewing documents (requires number verification)
  void _showVerifyToViewDocDialog(
    BuildContext context, {
    String? docTitle,
    String? fileName,
    List<String> imagePaths = const [],
    int initialIndex = 0,
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
              // Security Shield / Lock Icon
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

              // Info note badge
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
                        'Mobile number verification feature will be implemented soon.',
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
                          if (imagePaths.isNotEmpty) {
                            Get.to(() => PhotoGalleryScreen(
                                  imagePaths: imagePaths,
                                  initialIndex: initialIndex,
                                ));
                          } else {
                            Get.snackbar(
                              'Notice',
                              'No document file available to view.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.navy,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                            );
                          }
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

  /// Format document key to readable label
  String _formatDocKey(String key) {
    if (key == 'aadhar_card_front') return 'Aadhaar Card (Front)';
    if (key == 'aadhar_card_back') return 'Aadhaar Card (Back)';
    if (key == 'aadhar_card_combined_pdf') return 'Aadhaar Card (Single PDF)';
    if (key == 'aadhar_card' || key == 'aadhaar_card') return 'Aadhaar Card';
    if (key == 'pan_card_image' || key == 'pan_card') return 'PAN Card';
    if (key == 'profile_image') return 'Co-Applicant Photo';
    if (key == 'latest_salary_slips') return 'Salary Slip';
    if (key == 'bank_statement') return 'Bank Statement';
    if (key == 'form_16_itr') return 'Form 16 / ITR';
    if (key == 'salary_letterpad') return 'Company Letterpad';
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Skeleton shimmer placeholder for co-applicants list
  Widget _buildSkeletonCoApplicantCards() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CO-APPLICANTS (2)'),
          const SizedBox(height: 12),
          for (int i = 0; i < 2; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.canvas,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 65,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.canvas,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 65,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.canvas,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCoAppInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Mobile',
                          value: '+91 98XXXX0001',
                        ),
                        const SizedBox(height: 8),
                        _buildCoAppInfoRow(
                          icon: Icons.work_outline_rounded,
                          label: 'Employment',
                          value: 'Salaried Professional',
                        ),
                        const SizedBox(height: 8),
                        _buildCoAppInfoRow(
                          icon: Icons.credit_card_outlined,
                          label: 'PAN Number',
                          value: 'XXXXX6789K',
                        ),
                        const SizedBox(height: 8),
                        _buildCoAppInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Aadhaar Number',
                          value: 'XXXX XXXX 7777',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.line),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Edit', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                        Text('|', style: TextStyle(color: AppColors.line)),
                        Text('View Details', style: TextStyle(color: AppColors.indigo, fontWeight: FontWeight.w700)),
                        Text('|', style: TextStyle(color: AppColors.line)),
                        Text('Delete', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Shimmer loading placeholder for Co-Applicant Details bottom sheet
  Widget _buildSkeletonDetailsPlaceholder() {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.canvas,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 70,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Skeleton Section 1: Personal Details
            _buildDetailCard(
              title: 'PERSONAL DETAILS',
              icon: Icons.person_outline_rounded,
              children: [
                _buildDetailItem('Full Name', 'Sample Applicant Name'),
                _buildDetailItem('Mobile', '+91 98765 43210'),
                _buildDetailItem('PAN Card Number', 'ABCDE1234F'),
                _buildDetailItem('Aadhaar Card Number', '1234 5678 9012'),
                _buildDetailItem('Date of Birth', '1990-01-01'),
              ],
            ),
            const SizedBox(height: 14),

            // Skeleton Section 2: Employment & Income
            _buildDetailCard(
              title: 'EMPLOYMENT & INCOME',
              icon: Icons.work_outline_rounded,
              children: [
                _buildDetailItem('Employment Type', 'Salaried Professional'),
                _buildDetailItem('Company Name', 'Enterprise Tech Solutions'),
                _buildDetailItem('Monthly Salary', '₹75,000.00'),
                _buildDetailItem('Total Experience', '5 yrs'),
              ],
            ),
            const SizedBox(height: 14),

            // Skeleton Section 3: Documents
            _buildDetailCard(
              title: 'DOCUMENTS & PROOFS',
              icon: Icons.folder_open_rounded,
              children: [
                _buildDetailItem('Bank Statement', '6 Months Statement'),
                _buildDetailItem('Salary Slips', 'Latest 3 Months'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Key-value detail row inside co-applicant card
  Widget _buildCoAppInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: AppColors.muted),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Button to add another co-applicant
  Widget _buildAddAnotherCoAppButton(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    return GestureDetector(
      onTap: () => _showSelectMemberRoleBottomSheet(context, controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.indigo.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.navy,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Add another co-applicant / guarantor',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button, centered title, and add co-applicant action button
  Widget _buildTopBar(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
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

          // Screen Title
          const Expanded(
            child: Center(
              child: Text(
                'Applicant details',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Header Action Button: Add another co-applicant / guarantor
          GestureDetector(
            onTap: () => _showSelectMemberRoleBottomSheet(context, controller),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line, width: 1.2),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 20,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented pills: "Applicant" and "Co-applicant · X"
  Widget _buildSegmentedTabs(ApplicantDetailsController controller) {
    return Obx(() {
      final selectedTab = controller.selectedTabIndex.value;
      final coAppCount = controller.coApplicantsList.length;

      return Container(
        height: 44,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            // Left Pill: Applicant
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedTab == 0 ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    'Applicant',
                    style: TextStyle(
                      color: selectedTab == 0 ? Colors.white : AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Right Pill: Co-applicant · X
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(1),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedTab == 1 ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Text(
                    'Co-applicant · $coAppCount',
                    style: TextStyle(
                      color: selectedTab == 1 ? Colors.white : AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Shimmer skeleton for primary applicant tab
  Widget _buildSkeletonApplicantContent() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('VERIFICATION'),
          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('PERSONAL & CONTACT'),
          const SizedBox(height: 8),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  /// Profile Banner Card with cosmic orbit curves and avatar for primary applicant
  Widget _buildProfileBanner(
    ApplicantDetailsController controller, [
    ApplicantDetailModel? data,
  ]) {
    final applicant = data?.applicant;
    final loanApp = data?.loanApplications.isNotEmpty == true
        ? data!.loanApplications.first
        : null;

    final name = applicant?.name?.trim().isNotEmpty == true
        ? applicant!.name!.trim()
        : 'Applicant';

    final initials = name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    final employment = loanApp?.employmentDetails?.employmentType ??
        applicant?.currentResidenceType ??
        'Salaried';

    final hasPhoto = applicant?.profilePhotoUrl != null &&
        applicant!.profilePhotoUrl!.trim().isNotEmpty;

    return Container(
      height: 84,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background cosmic curve
          Positioned.fill(
            child: CustomPaint(
              painter: const _BannerCosmicPainter(),
            ),
          ),

          // Avatar & Name content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Circular Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: hasPhoto
                      ? Image.network(
                          applicant.profilePhotoUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            initials.isNotEmpty ? initials : 'AM',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : Text(
                          initials.isNotEmpty ? initials : 'AM',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(width: 14),

                // Name & Role Subtitle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Primary applicant · $employment',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Small section heading label
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  /// Verification card container with Aadhaar, PAN, Mobile, and CIBIL rows
  Widget _buildVerificationCard(
    ApplicantDetailsController controller, [
    ApplicantDetailModel? data,
  ]) {
    final kyc = data?.kyc;
    final applicant = data?.applicant;

    final aadhaarNum = applicant?.aadhaarCardNumber ?? kyc?.aadhaar?.number;
    final maskedAadhaar = aadhaarNum != null && aadhaarNum.length >= 4
        ? '•••• •••• ${aadhaarNum.substring(aadhaarNum.length - 4)}'
        : 'Identity verified';

    final isAadhaarVerified =
        kyc?.aadhaar?.status == 'verified' || kyc?.aadhaar?.uploaded == true;

    final panNum =
        applicant?.panCardNumber ?? kyc?.pan?.number ?? 'Tax ID verified';
    final isPanVerified =
        kyc?.pan?.status == 'verified' || kyc?.pan?.uploaded == true;

    final phoneNum = applicant?.phone != null && applicant!.phone!.isNotEmpty
        ? '+91 ${applicant.phone}'
        : '+91 ••••• •••••';

    final cibil = kyc?.cibilScore;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _buildVerificationRow(
            icon: Icons.shield_outlined,
            title: 'Aadhaar',
            subtitle: maskedAadhaar,
            badgeText: isAadhaarVerified ? 'Verified' : 'Pending',
            badgeBg: isAadhaarVerified
                ? AppColors.successGreenBg
                : AppColors.canvas,
            badgeColor:
                isAadhaarVerified ? AppColors.successGreen : AppColors.muted,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildVerificationRow(
            icon: Icons.credit_card_rounded,
            title: 'PAN card',
            subtitle: panNum,
            badgeText: isPanVerified ? 'Verified' : 'Pending',
            badgeBg: isPanVerified
                ? AppColors.successGreenBg
                : AppColors.canvas,
            badgeColor:
                isPanVerified ? AppColors.successGreen : AppColors.muted,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildVerificationRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Mobile OTP',
            subtitle: phoneNum,
            badgeText: 'Verified',
            badgeBg: AppColors.successGreenBg,
            badgeColor: AppColors.successGreen,
          ),
          if (cibil != null && cibil > 0) ...[
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildVerificationRow(
              icon: Icons.speed_rounded,
              title: 'CIBIL Score: $cibil',
              subtitle: cibil >= 750
                  ? 'Excellent credit profile'
                  : 'Good credit profile',
              badgeText: cibil >= 750 ? 'Strong' : 'Active',
              badgeBg: AppColors.successGreenBg,
              badgeColor: AppColors.successGreen,
            ),
          ],
        ],
      ),
    );
  }

  /// Single verification list tile
  Widget _buildVerificationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Green Squircle Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.successGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Personal & Contact info card container
  Widget _buildPersonalContactCard(
    ApplicantDetailsController controller, [
    ApplicantDetailModel? data,
  ]) {
    final applicant = data?.applicant;

    final name = applicant?.name ?? '-';
    final dobGender =
        '${applicant?.dateOfBirth ?? '-'} · ${applicant?.gender ?? '-'}';
    final email = applicant?.email ?? '-';
    final phone = applicant?.phone != null && applicant!.phone!.isNotEmpty
        ? '+91 ${applicant.phone}'
        : '-';
    final address = applicant?.address ??
        applicant?.communicationAddress ??
        applicant?.permanentAddress ??
        '-';
    final cityState = (applicant?.city != null && applicant!.city!.isNotEmpty)
        ? '${applicant.city}${applicant.state != null ? ', ${applicant.state}' : ''}'
        : null;
    final residence = applicant?.currentResidenceType;
    final marital = applicant?.maritalStatus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _buildContactRow(
            icon: Icons.person_outline_rounded,
            label: 'Full name',
            value: name,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date of birth · Gender',
            value: dobGender,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: email,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.phone_android_rounded,
            label: 'Mobile number',
            value: phone,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: address,
          ),
          if (cityState != null) ...[
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.apartment_rounded,
              label: 'City · State',
              value: cityState,
            ),
          ],
          if (residence != null && residence.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.home_outlined,
              label: 'Residence type',
              value: residence,
            ),
          ],
          if (marital != null && marital.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.canvas, indent: 56),
            _buildContactRow(
              icon: Icons.favorite_border_rounded,
              label: 'Marital status',
              value: marital,
            ),
          ],
        ],
      ),
    );
  }

  /// Single personal & contact list tile
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lavender Squircle Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.indigoTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: AppColors.indigo,
            ),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Primary applicant Documents & Proofs section
  Widget _buildPrimaryApplicantDocumentsSection(
    BuildContext context,
    ApplicantDetailsController controller,
    ApplicantDetailModel? data,
  ) {
    final docs = controller.primaryApplicantDocuments;
    final uploadedCount = docs.where((d) => d.uploaded == true || d.files.isNotEmpty).length;
    final totalCount = docs.length;

    if (docs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final filter = controller.applicantDocFilter.value;
      final displayDocs = filter == 'uploaded'
          ? docs.where((d) => d.uploaded == true || d.files.isNotEmpty).toList()
          : docs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: AppColors.navy,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'DOCUMENTS & PROOFS',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: uploadedCount == totalCount && totalCount > 0
                          ? AppColors.successGreenBg
                          : AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      '$uploadedCount/$totalCount',
                      style: TextStyle(
                        color: uploadedCount == totalCount && totalCount > 0
                            ? AppColors.successGreen
                            : AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Filter chips if there are both uploaded and pending documents
          if (uploadedCount > 0 && uploadedCount < totalCount) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                _buildApplicantDocFilterChip(
                  label: 'All ($totalCount)',
                  isSelected: filter == 'all',
                  onTap: () => controller.applicantDocFilter.value = 'all',
                ),
                const SizedBox(width: 8),
                _buildApplicantDocFilterChip(
                  label: 'Uploaded ($uploadedCount)',
                  isSelected: filter == 'uploaded',
                  onTap: () => controller.applicantDocFilter.value = 'uploaded',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ] else ...[
            const SizedBox(height: 6),
          ],

          // Document Cards
          if (displayDocs.isNotEmpty)
            for (final doc in displayDocs)
              _buildApplicantDocCard(context, doc)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.indigoTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.folder_open_rounded,
                        color: AppColors.navy,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No Documents Uploaded',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No documents or proofs have been uploaded yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  /// Filter pill chip for primary applicant documents
  Widget _buildApplicantDocFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.muted,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Individual card for primary applicant document
  Widget _buildApplicantDocCard(BuildContext context, ApplicantDocumentItem doc) {
    final isUploaded = doc.uploaded == true ||
        doc.status?.toLowerCase() == 'uploaded' ||
        doc.status?.toLowerCase() == 'accepted' ||
        doc.files.isNotEmpty;
    final fileCount = doc.files.length;
    final hasRejected = doc.files.any((f) => f.status?.toLowerCase() == 'rejected') ||
        doc.status?.toLowerCase() == 'rejected';
    final String label = doc.label ?? _formatDocKey(doc.key ?? 'Document');
    final docKey = doc.key ?? '';

    // Collect all valid URLs for viewing in photo gallery
    final allUrls = doc.files
        .map((f) => (f.url?.isNotEmpty == true) ? f.url! : (f.viewEndpoint ?? f.name ?? ''))
        .where((u) => u.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasRejected
              ? AppColors.errorRed
              : isUploaded
                  ? AppColors.indigo.withValues(alpha: 0.35)
                  : AppColors.line,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Leading Icon Container (42x42 squircle)
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasRejected
                        ? AppColors.errorRedBg
                        : isUploaded
                            ? AppColors.successGreenBg
                            : AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      hasRejected
                          ? Icons.error_outline_rounded
                          : isUploaded
                              ? Icons.check_circle_rounded
                              : _getDocIcon(docKey),
                      color: hasRejected
                          ? AppColors.errorRed
                          : isUploaded
                              ? AppColors.successGreen
                              : AppColors.navy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Subtitle / File count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (fileCount > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Text(
                                '$fileCount',
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isUploaded
                            ? (fileCount == 1
                                ? (doc.files.first.name ?? 'Uploaded ✓')
                                : '$fileCount files attached')
                            : 'Upload pending',
                        style: TextStyle(
                          color: hasRejected
                              ? AppColors.errorRed
                              : isUploaded
                                  ? AppColors.successGreen
                                  : AppColors.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Action: View Document Button (if uploaded) or Pending Tag
                if (isUploaded && allUrls.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showVerifyToViewDocDialog(
                      context,
                      docTitle: label,
                      imagePaths: allUrls,
                      initialIndex: 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.indigoTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.indigo.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.navy,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isUploaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Uploaded',
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // If multiple files, display file pills list below (like Front & Back for Aadhaar)
            if (fileCount > 1) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: AppColors.line),
              const SizedBox(height: 8),
              ...doc.files.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                final fileSide = file.side != null ? ' (${file.side!.capitalizeFirst})' : '';
                final fileName = (file.name?.trim().isNotEmpty == true)
                    ? '${file.name!}$fileSide'
                    : 'Attached Document #${idx + 1}$fileSide';
                final fileUrl = (file.url?.isNotEmpty == true) ? file.url! : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        size: 13,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (fileUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showVerifyToViewDocDialog(
                            context,
                            docTitle: label,
                            fileName: fileName,
                            imagePaths: allUrls,
                            initialIndex: idx,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 11,
                                  color: AppColors.navy,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
  void _showSelectMemberRoleBottomSheet(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator handle
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Member',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.muted,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select role for the new member you want to add:',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),

            // Option 1: Co-Applicant
            _buildRoleOptionCard(
              title: 'Co-Applicant',
              subtitle: 'Shares loan liability and improves loan eligibility',
              icon: Icons.people_alt_rounded,
              onTap: () {
                Get.back();
                controller.selectRole('Co-Applicant');
                Get.to(() => const AddCoApplicantScreen(role: 'Co-Applicant'));
              },
            ),
            const SizedBox(height: 12),

            // Option 2: Guarantor
            _buildRoleOptionCard(
              title: 'Guarantor',
              subtitle: 'Guarantees repayment without sharing loan ownership',
              icon: Icons.verified_user_rounded,
              onTap: () {
                Get.back();
                controller.selectRole('Guarantor');
                Get.to(() => const AddCoApplicantScreen(role: 'Guarantor'));
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildRoleOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                color: AppColors.indigoTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.navy,
                  size: 22,
                ),
              ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  /// Handler for submitting application with animated loader dialog for bank suggestions
  void _handleSubmitApplication(BuildContext context) async {
    // Show loader dialog
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated progress container with bank icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy),
                        backgroundColor: AppColors.indigo.withValues(alpha: 0.12),
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.indigoTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.navy,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Title
                const Text(
                  'Fetching Suggested Banks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Analyzing your eligibility and matching the best partner banks for your loan...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),

                // AI Processing Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: AppColors.amber,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Finding Best Interest Rates',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Delay for 5 seconds to simulate matching and let suggestions prepare
    await Future.delayed(const Duration(seconds: 5));

    // Close the loader dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    // Navigate to Recommended Loan Offers Screen
    Get.to(() => const RecommendedLoanOffersScreen());
  }

  /// Bottom Section: "Submit application →" button
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.lightBackground,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => _handleSubmitApplication(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Submit application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.amber,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cosmic orbit line painter for profile banner card
class _BannerCosmicPainter extends CustomPainter {
  const _BannerCosmicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Anchor centered on the right side, matching dashboard CIBIL card
    final anchor = Offset(size.width - 44, size.height * 0.33);

    final orbitPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    // 1. Concentric guide rings (same as dashboard top card)
    canvas.drawCircle(anchor, 58, orbitPaint);
    canvas.drawCircle(anchor, 105, orbitPaint);

    // 2. Wide flat tilted cosmic orbit ellipse
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(-28 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 270,
        height: 75,
      ),
      orbitPaint..color = AppColors.indigo.withValues(alpha: 0.32),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
