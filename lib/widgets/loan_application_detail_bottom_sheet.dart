import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/active_application_model.dart';
import '../screens/loan_flow/application_status_screen.dart';

/// Modal bottom sheet displaying complete details of an active loan application.
/// Sections and rows without valid data are completely hidden (no empty states or zero-value cards).
class LoanApplicationDetailBottomSheet extends StatelessWidget {
  final ActiveApplicationModel app;

  const LoanApplicationDetailBottomSheet({super.key, required this.app});

  static Future<void> show(BuildContext context, ActiveApplicationModel app) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoanApplicationDetailBottomSheet(app: app),
    );
  }

  @override
  Widget build(BuildContext context) {
    final raw = app.raw;
    final bank = raw?.bankDetails;
    final charges = raw?.charges;
    final emp = raw?.employmentDetails;
    final docs = raw?.documentsSummary;
    final applicant = raw?.applicant;

    // 1. Bank details visibility check
    final bankName = bank?.bankName?.toString().trim();
    final sanctionedAmt = bank?.sanctionedAmount;
    final disbursedAmt = bank?.disbursedAmount;
    final roi = bank?.interestRate?.toString().trim();
    final employee = bank?.bankEmployeeName?.toString().trim();
    final sanctionDate = bank?.sanctionDate?.toString().trim();
    final hasBankDetails = (bankName != null && bankName.isNotEmpty && bankName != '-') ||
        (sanctionedAmt != null && sanctionedAmt > 0) ||
        (disbursedAmt != null && disbursedAmt > 0) ||
        (roi != null && roi.isNotEmpty && roi != '-') ||
        (employee != null && employee.isNotEmpty && employee != '-') ||
        (sanctionDate != null && sanctionDate.isNotEmpty && sanctionDate != '-');

    // 2. Charges visibility check (only if at least one charge is > 0)
    final pFee = charges?.processingFees;
    final insurance = charges?.insuranceAmount;
    final docFee = charges?.documentCharges;
    final other = charges?.otherCharges;
    final totalDeductions = charges?.totalDeductionsFromLoan;
    final totalUpfront = charges?.totalUpfrontCharges;
    final hasAnyCharges = (pFee != null && pFee > 0) ||
        (insurance != null && insurance > 0) ||
        (docFee != null && docFee > 0) ||
        (other != null && other > 0) ||
        (totalDeductions != null && totalDeductions > 0) ||
        (totalUpfront != null && totalUpfront > 0);

    // 3. Employment visibility check
    final empType = emp?.employmentType?.toString().trim();
    final empCompany = (emp?.companyName ?? emp?.businessName)?.toString().trim();
    final empDesignation = emp?.designation?.toString().trim();
    final empSalary = emp?.monthlySalary?.toString().trim();
    final empVintage = emp?.businessVintage?.toString().trim();
    final empTurnover = emp?.businessTurnover?.toString().trim();
    final hasEmployment = (empType != null && empType.isNotEmpty && empType != '-') ||
        (empCompany != null && empCompany.isNotEmpty && empCompany != '-') ||
        (empDesignation != null && empDesignation.isNotEmpty && empDesignation != '-') ||
        (empSalary != null && empSalary.isNotEmpty && empSalary != '-' && empSalary != '0.00' && empSalary != '0') ||
        (empVintage != null && empVintage.isNotEmpty && empVintage != '-') ||
        (empTurnover != null && empTurnover.isNotEmpty && empTurnover != '-');

    // 4. Documents visibility check
    final totalDocs = docs?.total ?? 0;
    final uploadedDocs = docs?.uploaded ?? 0;
    final hasDocs = totalDocs > 0 || uploadedDocs > 0;

    // 5. Applicant visibility check
    final appName = applicant?.name?.toString().trim();
    final appPhone = applicant?.phone?.toString().trim();
    final appEmail = applicant?.email?.toString().trim();
    final appPan = applicant?.panCardNumber?.toString().trim();
    final appAadhaar = applicant?.aadhaarCardNumber?.toString().trim();
    final appAddress = applicant?.address?.toString().trim();
    final hasApplicant = (appName != null && appName.isNotEmpty && appName != '-') ||
        (appPhone != null && appPhone.isNotEmpty && appPhone != '-') ||
        (appEmail != null && appEmail.isNotEmpty && appEmail != '-') ||
        (appPan != null && appPan.isNotEmpty && appPan != '-') ||
        (appAadhaar != null && appAadhaar.isNotEmpty && appAadhaar != '-') ||
        (appAddress != null && appAddress.isNotEmpty && appAddress != '-');

    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Title, Application ID, Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.title,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          app.id,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusPill(app.statusType),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textDark,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.line),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Amount & Key Overview Card
                    _buildOverviewCard(bank),

                    // Section: Bank & Sanction Details (hidden if empty)
                    if (hasBankDetails) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'Bank & Sanction Details',
                        icon: Icons.account_balance_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildBankDetailsCard(bank),
                    ],

                    // Section: Charges & Deductions (hidden if empty / all zero)
                    if (hasAnyCharges) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'Fees & Deductions',
                        icon: Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildChargesCard(charges),
                    ],

                    // Section: Employment & Income (hidden if empty)
                    if (hasEmployment) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'Employment Details',
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildEmploymentCard(emp),
                    ],

                    // Section: Documents Status (hidden if empty)
                    if (hasDocs) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'Documents Status',
                        icon: Icons.folder_shared_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildDocumentsCard(docs),
                    ],

                    // Section: Applicant Information (hidden if empty)
                    if (hasApplicant) ...[
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        title: 'Applicant Information',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 8),
                      _buildApplicantCard(applicant),
                    ],

                    const SizedBox(height: 16),
                    // Applied Timestamp
                    Center(
                      child: Text(
                        'Application submitted on ${app.appliedDate}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Floating Track Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.line, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(
                      () => const ApplicationStatusScreen(),
                      transition: Transition.noTransition,
                      duration: Duration.zero,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Track Application Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Highlight Banner (Amount, Net Disbursable, EMI, Tenure)
  Widget _buildOverviewCard(dynamic bank) {
    final netDisbursable = bank?.netDisbursableAmount;
    final formattedNet = (netDisbursable != null && netDisbursable > 0)
        ? _formatCurrency(netDisbursable)
        : null;

    final metrics = <Widget>[];
    if (app.tenure.isNotEmpty && app.tenure != '-') {
      metrics.add(_buildMetricItem('Tenure', app.tenure));
    }
    if (app.emi.isNotEmpty && app.emi != '-') {
      metrics.add(_buildMetricItem('Est. EMI', app.emi));
    }
    if (app.currentStep.isNotEmpty && app.currentStep != '-') {
      metrics.add(_buildMetricItem('Current Stage', app.currentStep));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dashboardCardBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Applied Loan Amount',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    app.amount,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (formattedNet != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Net Disbursable',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formattedNet,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: metrics,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Section Header with Icon
  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryPurple),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// Bank Details Card (hides completely if no fields are present)
  Widget _buildBankDetailsCard(dynamic bank) {
    final bankName = bank?.bankName?.toString().trim();
    final sanctionedAmt = bank?.sanctionedAmount;
    final disbursedAmt = bank?.disbursedAmount;
    final roi = bank?.interestRate?.toString().trim();
    final employee = bank?.bankEmployeeName?.toString().trim();
    final sanctionDate = bank?.sanctionDate?.toString().trim();

    final items = <Widget>[];
    if (bankName != null && bankName.isNotEmpty && bankName != '-') {
      items.add(_buildInfoRow('Lending Bank', bankName));
    }
    if (sanctionedAmt != null && sanctionedAmt > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Sanctioned Amount', _formatCurrency(sanctionedAmt)));
    }
    if (disbursedAmt != null && disbursedAmt > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Disbursed Amount', _formatCurrency(disbursedAmt)));
    }
    if (roi != null && roi.isNotEmpty && roi != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Interest Rate', '$roi% p.a.'));
    }
    if (sanctionDate != null && sanctionDate.isNotEmpty && sanctionDate != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Sanction Date', _formatDate(sanctionDate)));
    }
    if (employee != null && employee.isNotEmpty && employee != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Loan Officer', employee));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder),
      ),
      child: Column(children: items),
    );
  }

  /// Charges & Deductions Card (hides completely if all fees are 0 or null)
  Widget _buildChargesCard(dynamic charges) {
    final pFee = charges?.processingFees;
    final insurance = charges?.insuranceAmount;
    final docFee = charges?.documentCharges;
    final other = charges?.otherCharges;
    final totalDeductions = charges?.totalDeductionsFromLoan;
    final totalUpfront = charges?.totalUpfrontCharges;

    final items = <Widget>[];
    if (pFee != null && pFee > 0) {
      items.add(_buildInfoRow('Processing Fee', _formatCurrency(pFee)));
    }
    if (insurance != null && insurance > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Insurance', _formatCurrency(insurance)));
    }
    if (docFee != null && docFee > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Documentation Fee', _formatCurrency(docFee)));
    }
    if (other != null && other > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Other Charges', _formatCurrency(other)));
    }
    if (totalDeductions != null && totalDeductions > 0) {
      if (items.isNotEmpty) {
        items.add(const SizedBox(height: 10));
        items.add(const Divider(height: 1, color: AppColors.line));
        items.add(const SizedBox(height: 10));
      }
      items.add(_buildInfoRow(
        'Total Deductions',
        _formatCurrency(totalDeductions),
        isBold: true,
        highlightColor: AppColors.textDark,
      ));
    }
    if (totalUpfront != null && totalUpfront > 0) {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow(
        'Upfront Payable',
        _formatCurrency(totalUpfront),
        isBold: true,
        highlightColor: AppColors.warningAmber,
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder),
      ),
      child: Column(children: items),
    );
  }

  /// Employment Card (only shows fields that have non-empty values)
  Widget _buildEmploymentCard(dynamic emp) {
    final type = emp?.employmentType?.toString().trim();
    final company = (emp?.companyName ?? emp?.businessName)?.toString().trim();
    final designation = emp?.designation?.toString().trim();
    final salary = emp?.monthlySalary?.toString().trim();
    final vintage = emp?.businessVintage?.toString().trim();
    final turnover = emp?.businessTurnover?.toString().trim();

    final items = <Widget>[];
    if (type != null && type.isNotEmpty && type != '-') {
      items.add(_buildInfoRow('Employment Type', type));
    }
    if (company != null && company.isNotEmpty && company != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Company / Firm', company));
    }
    if (designation != null && designation.isNotEmpty && designation != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Designation', designation));
    }
    if (salary != null && salary.isNotEmpty && salary != '-' && salary != '0.00' && salary != '0') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Monthly Salary', _formatAmountString(salary)));
    }
    if (turnover != null && turnover.isNotEmpty && turnover != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Business Turnover', turnover));
    }
    if (vintage != null && vintage.isNotEmpty && vintage != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Business Vintage', vintage));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder),
      ),
      child: Column(children: items),
    );
  }

  /// Documents Summary Card (hidden if total docs is 0)
  Widget _buildDocumentsCard(dynamic docs) {
    final total = docs?.total ?? 0;
    final uploaded = docs?.uploaded ?? 0;
    final rejected = docs?.rejected ?? 0;
    if (total <= 0 && uploaded <= 0) return const SizedBox.shrink();

    final progress = total > 0 ? (uploaded / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$uploaded of $total uploaded',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
              minHeight: 6,
            ),
          ),
          if (rejected > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$rejected documents need re-upload',
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Applicant Card (only shows fields that have non-empty values)
  Widget _buildApplicantCard(dynamic applicant) {
    final name = applicant?.name?.toString().trim();
    final phone = applicant?.phone?.toString().trim();
    final email = applicant?.email?.toString().trim();
    final pan = applicant?.panCardNumber?.toString().trim();
    final aadhaar = applicant?.aadhaarCardNumber?.toString().trim();
    final address = applicant?.address?.toString().trim();

    final items = <Widget>[];
    if (name != null && name.isNotEmpty && name != '-') {
      items.add(_buildInfoRow('Full Name', name));
    }
    if (phone != null && phone.isNotEmpty && phone != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Mobile', phone));
    }
    if (email != null && email.isNotEmpty && email != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Email', email));
    }
    if (pan != null && pan.isNotEmpty && pan != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('PAN', pan));
    }
    if (aadhaar != null && aadhaar.isNotEmpty && aadhaar != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Aadhaar', _maskAadhaar(aadhaar)));
    }
    if (address != null && address.isNotEmpty && address != '-') {
      if (items.isNotEmpty) items.add(const SizedBox(height: 8));
      items.add(_buildInfoRow('Address', address));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlightColor ?? AppColors.textDark,
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(ApplicationStatusType type) {
    Color bg;
    Color text;
    String label;

    switch (type) {
      case ApplicationStatusType.approved:
        bg = AppColors.successGreenBg;
        text = AppColors.successGreen;
        label = 'Approved';
        break;
      case ApplicationStatusType.rejected:
        bg = AppColors.errorRedBg;
        text = AppColors.errorRed;
        label = 'Rejected';
        break;
      case ApplicationStatusType.pending:
        bg = AppColors.canvas;
        text = AppColors.muted;
        label = 'Pending';
        break;
      case ApplicationStatusType.inReview:
        bg = AppColors.reviewPillBg;
        text = AppColors.reviewPillText;
        label = 'In review';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatCurrency(num amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  String _formatAmountString(String amountStr) {
    final parsed = double.tryParse(amountStr.replaceAll(',', ''));
    if (parsed != null) {
      return _formatCurrency(parsed);
    }
    return amountStr;
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(parsed.toLocal());
    } catch (_) {
      return raw;
    }
  }

  String _maskAadhaar(String aadhaar) {
    final clean = aadhaar.replaceAll(' ', '');
    if (clean.length >= 4) {
      return '•••• •••• ${clean.substring(clean.length - 4)}';
    }
    return aadhaar;
  }
}
