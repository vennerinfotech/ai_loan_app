import 'dart:math' as math;
import '../../theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/applicant_details_controller.dart';
import '../../models/co_applicants_list_model.dart';
import 'add_co_applicant_screen.dart';
import 'recommended_loan_offers_screen.dart';

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
              child: SingleChildScrollView(
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
                        return _buildPrimaryApplicantContent(controller);
                      } else {
                        return _buildCoApplicantsCardList(context, controller);
                      }
                    }),

                    const SizedBox(height: 24),
                  ],
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
  Widget _buildPrimaryApplicantContent(ApplicantDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Banner Card with cosmic background
        _buildProfileBanner(controller),

        const SizedBox(height: 20),

        // Verification Section
        _buildSectionHeader('VERIFICATION'),
        const SizedBox(height: 8),
        _buildVerificationCard(controller),

        const SizedBox(height: 20),

        // Personal & Contact Section
        _buildSectionHeader('PERSONAL & CONTACT'),
        const SizedBox(height: 8),
        _buildPersonalContactCard(controller),
      ],
    );
  }

  /// Co-applicants card list tab content showing all items from GET /co-applicants
  Widget _buildCoApplicantsCardList(
    BuildContext context,
    ApplicantDetailsController controller,
  ) {
    if (controller.isLoadingCoApplicants.value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: const [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Fetching co-applicants...',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final list = controller.coApplicantsList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count & refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('CO-APPLICANTS (${list.length})'),
            GestureDetector(
              onTap: () => controller.fetchCoApplicants(),
              child: Row(
                children: const [
                  Icon(Icons.refresh_rounded, size: 15, color: AppColors.indigo),
                  SizedBox(width: 4),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      color: AppColors.indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (list.isEmpty)
          _buildEmptyCoApplicantsState(context, controller)
        else ...[
          for (int i = 0; i < list.length; i++)
            _buildCoApplicantCard(context, list[i], i),
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
                    value: item.phone!,
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
                    value: item.panCardNumber!,
                  ),
                ],
                if (hasAadhaar) ...[
                  const SizedBox(height: 8),
                  _buildCoAppInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Aadhaar Number',
                    value: item.aadhaarCardNumber!,
                  ),
                ],
              ],
            ),
          ),
        ],
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

  /// Profile Banner Card with cosmic orbit curves and avatar for primary applicant
  Widget _buildProfileBanner(ApplicantDetailsController controller) {
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
                  alignment: Alignment.center,
                  child: const Text(
                    'AM',
                    style: TextStyle(
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
                      const Text(
                        'Aarav Mehta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Primary applicant · Salaried',
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

  /// Verification card container with Aadhaar, PAN, and Mobile rows
  Widget _buildVerificationCard(ApplicantDetailsController controller) {
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
            subtitle: 'Identity verified',
            badgeText: 'Verified',
            badgeBg: AppColors.successGreenBg,
            badgeColor: AppColors.successGreen,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildVerificationRow(
            icon: Icons.credit_card_rounded,
            title: 'PAN card',
            subtitle: 'Tax ID verified',
            badgeText: 'Verified',
            badgeBg: AppColors.successGreenBg,
            badgeColor: AppColors.successGreen,
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildVerificationRow(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Mobile OTP',
            subtitle: '+91 98765 •••10',
            badgeText: 'Verified',
            badgeBg: AppColors.successGreenBg,
            badgeColor: AppColors.successGreen,
          ),
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
  Widget _buildPersonalContactCard(ApplicantDetailsController controller) {
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
            value: 'Aarav Mehta',
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date of birth · Gender',
            value: '15 Aug 1993 · Male',
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: 'aarav@example.com',
          ),
          const Divider(height: 1, color: AppColors.canvas, indent: 56),
          _buildContactRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: '123, MG Road, Bengaluru, Karnataka – 560001',
          ),
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


  /// Opens bottom sheet to select Co-Applicant or Guarantor
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

  /// Bottom Section: "Submit application →" button
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.lightBackground,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to Recommended Loan Offers Screen
            Get.to(() => const RecommendedLoanOffersScreen());
          },
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
