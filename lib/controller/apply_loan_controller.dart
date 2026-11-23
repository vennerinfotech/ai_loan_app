import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../models/employment_type_model.dart';
import '../models/emi_calculation_model.dart';
import '../models/loan_types_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/image_picker_bottom_sheet.dart';

class LoanTypeOption {
  final String title;
  final String subtitle;
  final String iconKey;

  const LoanTypeOption({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });
}

class EmploymentTypeOption {
  final String title;
  final String subtitle;
  final String iconKey;

  const EmploymentTypeOption({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });
}

class LoanDocItem {
  final String title;
  final String subtitle;
  final RxBool isAdded;
  final RxString fileName;
  final RxString fileSize;
  final RxBool isUploading;
  final RxDouble uploadProgress;

  LoanDocItem({
    required this.title,
    this.subtitle = '',
    bool isAdded = false,
    String fileName = '',
    String fileSize = '',
    bool isUploading = false,
    double uploadProgress = 0.0,
  })  : isAdded = isAdded.obs,
        fileName = fileName.obs,
        fileSize = fileSize.obs,
        isUploading = isUploading.obs,
        uploadProgress = uploadProgress.obs;
}

/// GetX controller managing the 4-step Apply Loan Flow
class ApplyLoanController extends GetxController {
  // Step Coordination (Sticky Header Flow matching Aadhaar verification flow)
  final currentStep = 1.obs; // 1 = Type, 2 = Plan, 3 = Work, 4 = Docs
  final List<int> stepHistory = [1];

  void goToStep(int step) {
    if (currentStep.value != step) {
      stepHistory.add(step);
      currentStep.value = step;
      if (step == 2) {
        if (monthlyEmi.value == 0) {
          calculateEmiApi();
        }
      } else if (step == 3) {
        if (apiEmploymentTypes.isEmpty) {
          fetchEmploymentTypes();
        }
      }
    }
  }

  void handleBack() {
    if (stepHistory.length > 1) {
      stepHistory.removeLast();
      currentStep.value = stepHistory.last;
    } else {
      Get.back();
    }
  }

  void resetFlow() {
    currentStep.value = 1;
    stepHistory.clear();
    stepHistory.add(1);
  }

  @override
  void onInit() {
    super.onInit();
    // Only call GET /loan/types on Step 1 as requested
    fetchLoanTypes();
  }

  @override
  void onClose() {
    _emiDebounceTimer?.cancel();
    super.onClose();
  }

  // Step 1: Loan Type (GET /loan/types)
  // By default, no option is selected
  final selectedLoanType = ''.obs;
  final isOtherLoansExpanded = false.obs;
  final isLoadingLoanTypes = false.obs;

  /// Holds the data payload from GET /loan/types (storing only data, not status/messages)
  final loanTypesData = Rxn<LoanTypesData>();

  /// Primary 6 loan types from API if available
  List<LoanTypeItem> get apiPrimaryLoanTypes {
    if (loanTypesData.value != null &&
        loanTypesData.value!.loanTypes.isNotEmpty) {
      final all = loanTypesData.value!.loanTypes;
      return all.length > 6 ? all.sublist(0, 6) : all;
    }
    return [];
  }

  /// Remaining loan types shown under "Other loans" section
  List<LoanTypeItem> get apiOtherLoanTypes {
    if (loanTypesData.value != null &&
        loanTypesData.value!.loanTypes.length > 6) {
      return loanTypesData.value!.loanTypes.sublist(6);
    }
    return [];
  }

  Future<void> fetchLoanTypes() async {
    isLoadingLoanTypes.value = true;
    try {
      final res = await ApiService.getLoanTypes();
      if (res['success'] == true && res['data'] != null && res['data'] is Map) {
        final model =
            LoanTypesData.fromJson(Map<String, dynamic>.from(res['data']));
        loanTypesData.value = model;

        if (model.amountLimits?.min != null) {
          minLoanAmount.value = model.amountLimits!.min!.toDouble();
        }
        if (model.amountLimits?.max != null) {
          maxLoanAmount.value = model.amountLimits!.max!.toDouble();
        }
        if (model.tenureLimits?.min != null) {
          minTenureMonths.value = model.tenureLimits!.min!.toDouble();
        }
        if (model.tenureLimits?.max != null) {
          maxTenureMonths.value = model.tenureLimits!.max!.toDouble();
        }
        if (model.tenureLimits?.defaultTenure != null) {
          tenureMonths.value = model.tenureLimits!.defaultTenure!.toDouble();
          if (selectedTenureYears.value == 0) {
            selectedTenureYears.value =
                (model.tenureLimits!.defaultTenure! ~/ 12);
          }
        }
        if (model.amountPresets.isNotEmpty && loanAmount.value == 0) {
          loanAmount.value = model.amountPresets.first.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchLoanTypes: $e');
    } finally {
      isLoadingLoanTypes.value = false;
    }
  }

  final loanTypes = const [
    LoanTypeOption(
      title: 'Home loan',
      subtitle: 'Buy or build a home',
      iconKey: 'home',
    ),
    LoanTypeOption(
      title: 'Mortgage loan',
      subtitle: 'Against your property',
      iconKey: 'property',
    ),
    LoanTypeOption(
      title: 'Business loan',
      subtitle: 'Grow your business',
      iconKey: 'business',
    ),
    LoanTypeOption(
      title: 'Personal loan',
      subtitle: 'For life\'s plans',
      iconKey: 'personal',
    ),
    LoanTypeOption(
      title: 'Car loan',
      subtitle: 'New or used car',
      iconKey: 'car',
    ),
    LoanTypeOption(
      title: 'CC / OD loan',
      subtitle: 'Working capital limit',
      iconKey: 'card',
    ),
  ];

  final otherLoanTypes = const [
    LoanTypeOption(
      title: 'Education loan',
      subtitle: 'Higher education in India or abroad',
      iconKey: 'education',
    ),
    LoanTypeOption(
      title: 'Machinery loan',
      subtitle: 'Finance new or used equipment',
      iconKey: 'machinery',
    ),
    LoanTypeOption(
      title: 'BT + Top-up loan',
      subtitle: 'Balance transfer with extra top-up',
      iconKey: 'bt_topup',
    ),
    LoanTypeOption(
      title: 'Agri loan',
      subtitle: 'Farming & allied agricultural activities',
      iconKey: 'agri',
    ),
  ];

  void toggleOtherLoans() {
    isOtherLoansExpanded.toggle();
  }

  void selectLoanType(String type) {
    selectedLoanType.value = type;
  }

  IconData getIconForLoanType(String titleOrIcon) {
    final lower = titleOrIcon.toLowerCase().trim();
    switch (lower) {
      case 'home':
      case 'home loan':
        return Icons.home_rounded;
      case 'building-columns':
      case 'property':
      case 'mortgage loan':
        return Icons.account_balance_rounded;
      case 'business-time':
      case 'business':
      case 'business loan':
        return Icons.work_outline_rounded;
      case 'user':
      case 'personal':
      case 'personal loan':
        return Icons.person_outline_rounded;
      case 'car':
      case 'vehicle loan':
      case 'car loan':
        return Icons.directions_car_rounded;
      case 'credit-card':
      case 'card':
      case 'cc / od loan':
      case 'cc- od loan':
      case 'cc- od':
      case 'cc / od':
        return Icons.credit_card_rounded;
      case 'graduation-cap':
      case 'education':
      case 'education loan':
        return Icons.school_rounded;
      case 'cogs':
      case 'machinery':
      case 'machinery loan':
        return Icons.precision_manufacturing_rounded;
      case 'arrow-up-right-dots':
      case 'bt_topup':
      case 'bt + top-up loan':
      case 'bt+top-up loan':
        return Icons.trending_up_rounded;
      case 'seedling':
      case 'agri':
      case 'agri loan':
        return Icons.eco_rounded;
      case 'pen-nib':
      case 'other loan':
        return Icons.edit_note_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  // Step 2: Loan Amount and Dynamic EMI (POST /emi-calculate & GET /dashboard)
  final loanAmount = 0.0.obs;
  final minLoanAmount = 0.0.obs;
  final maxLoanAmount = 0.0.obs;
  final stepLoanAmount = 0.0.obs;
  final minTenureMonths = 6.0.obs;
  final maxTenureMonths = 360.0.obs;
  final tenureMonths = 240.0.obs;
  final selectedTenureYears = 0.obs;
  final annualInterestRate = 0.0.obs;
  final apiInterestRate = 0.0.obs;
  final monthlyEmi = 0.obs;
  final totalInterest = 0.obs;
  final totalPayable = 0.obs;
  final isCalculatingEmi = false.obs;
  final isEmiLoaded = false.obs;
  final emiCalculationData = Rxn<EmiCalculationData>();
  Timer? _emiDebounceTimer;

  final tenureOptions = const [5, 10, 15, 20];
  final quickAmountPresets = const [100000.0, 300000.0, 450000.0, 1000000.0, 2500000.0];

  void setLoanAmount(double amount) {
    loanAmount.value = amount;
    _emiDebounceTimer?.cancel();
    _emiDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      calculateEmiApi(amount: amount);
    });
  }

  void setTenureYears(int years) {
    selectedTenureYears.value = years;
  }

  /// Calls POST {{baseUrl}}/emi-calculate
  /// Per user requirement: passes only loan_amount
  Future<void> calculateEmiApi({double? amount}) async {
    final amt = amount ?? loanAmount.value;
    isCalculatingEmi.value = true;
    try {
      // Per user instruction: pass only amount
      var res = await ApiService.calculateEmi(loanAmount: amt.toInt());

      // If backend validator requires interest_rate / tenure_months, fallback with defaults
      if (res['status_code'] == 422 && res['errors'] is Map) {
        final errors = res['errors'] as Map;
        if (errors.containsKey('interest_rate') || errors.containsKey('tenure_months')) {
          res = await ApiService.calculateEmi(
            loanAmount: amt.toInt(),
            interestRate: 9.5,
            tenureMonths: 36,
          );
        }
      }

      if (res['success'] == true || res['status_code'] == 200) {
        final model = EmiCalculationResponseModel.fromJson(res);
        if (model.data != null) {
          emiCalculationData.value = model.data;
          monthlyEmi.value = model.data!.monthlyEmi?.toInt() ?? 0;
          totalInterest.value = model.data!.totalInterest?.toInt() ?? 0;
          totalPayable.value = model.data!.totalPayable?.toInt() ?? 0;
          if (model.data!.interestRate != null) {
            apiInterestRate.value = model.data!.interestRate!.toDouble();
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating EMI: $e');
    } finally {
      isCalculatingEmi.value = false;
    }
  }

  /// Monthly EMI (strictly dynamic from API response, no static dummy math)
  int get estimatedMonthlyEmi => monthlyEmi.value;

  /// Total Interest Payable (strictly dynamic from API response, no static dummy math)
  int get totalInterestPayable => totalInterest.value;

  /// Formatted currency string in Indian Numbering System (e.g. ₹4,50,000)
  String formatIndianCurrency(num amount) {
    final numStr = amount.round().toString();
    if (numStr.length <= 3) return '₹$numStr';

    final lastThree = numStr.substring(numStr.length - 3);
    final remaining = numStr.substring(0, numStr.length - 3);

    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return '₹${buffer.toString()}';
  }

  // Step 3: Employment Type (Dynamic API Integration)
  final selectedEmploymentType = 'Salaried'.obs;
  final isLoadingEmploymentTypes = false.obs;
  final isSelectingEmploymentType = false.obs;

  final apiEmploymentTypes = <EmploymentTypeItem>[].obs;
  final employmentTypesData = Rxn<EmploymentTypesData>();
  final selectionData = Rxn<EmploymentTypeSelectionData>();
  final dynamicDocuments = <LoanDocumentItem>[].obs;

  // Selected salary mode (for salaried)
  final selectedSalaryMode = ''.obs;

  // Dynamic detail fields resolved directly from the API response for the selected employment type
  EmploymentTypeItem? get currentSelectedEmploymentTypeItem {
    final sel = selectedEmploymentType.value.toLowerCase().trim();
    return apiEmploymentTypes.firstWhereOrNull(
      (e) =>
          (e.label ?? '').toLowerCase().trim() == sel ||
          (e.key ?? '').toLowerCase().trim() == sel,
    );
  }

  List<DetailFieldItem> get activeDetailFields {
    return currentSelectedEmploymentTypeItem?.detailFields ?? [];
  }

  List<SalaryModeItem> get activeSalaryModes {
    return currentSelectedEmploymentTypeItem?.salaryModes ?? [];
  }

  // Dynamic field controllers mapped strictly by field name from API
  final detailFieldControllers = <String, TextEditingController>{};
  final detailDropdownValues = <String, RxString>{};

  TextEditingController getControllerForField(String name) {
    if (!detailFieldControllers.containsKey(name)) {
      detailFieldControllers[name] = TextEditingController();
    }
    return detailFieldControllers[name]!;
  }

  RxString getDropdownValueForField(String name, String defaultValue) {
    if (!detailDropdownValues.containsKey(name)) {
      detailDropdownValues[name] = defaultValue.obs;
    }
    return detailDropdownValues[name]!;
  }

  // Dynamic Document Upload states
  final uploadedDocFileNames = <String, String>{}.obs; // doc.key -> fileName
  final uploadedDocFileSizes = <String, String>{}.obs; // doc.key -> fileSize
  final uploadingDocKeys = <String, bool>{}.obs; // doc.key -> isUploading
  final selectedDocCheckboxes = <String, bool>{}.obs; // doc.key -> isChecked

  // Fallback static list used only if API is loading
  final employmentTypes = const [
    EmploymentTypeOption(
      title: 'Salaried',
      subtitle: 'Regular monthly salary from an employer',
      iconKey: 'briefcase',
    ),
    EmploymentTypeOption(
      title: 'Self-employed / Business',
      subtitle: 'You run your own business or practice',
      iconKey: 'home_office',
    ),
    EmploymentTypeOption(
      title: 'Freelancer',
      subtitle: 'Project-based work for multiple clients',
      iconKey: 'laptop',
    ),
    EmploymentTypeOption(
      title: 'Pensioner',
      subtitle: 'Receiving retirement or pension benefits',
      iconKey: 'pension',
    ),
  ];

  void selectEmploymentType(String type) {
    selectedEmploymentType.value = type;
  }

  /// Calls GET {{baseUrl}}/loan/employment-types
  Future<void> fetchEmploymentTypes() async {
    isLoadingEmploymentTypes.value = true;
    try {
      final res = await ApiService.getEmploymentTypes();
      if (res['status_code'] == 200 || res['success'] == true) {
        final model = EmploymentTypesResponseModel.fromJson(res);
        if (model.data != null) {
          employmentTypesData.value = model.data;
          apiEmploymentTypes.assignAll(model.data!.employmentTypes);
          if (apiEmploymentTypes.isNotEmpty) {
            // Keep existing selection if valid or pick first
            final exists = apiEmploymentTypes.any(
              (e) => (e.label ?? e.key ?? '').toLowerCase() == selectedEmploymentType.value.toLowerCase(),
            );
            if (!exists) {
              selectedEmploymentType.value = apiEmploymentTypes.first.label ?? 'Salaried';
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error in fetchEmploymentTypes: $e');
    } finally {
      isLoadingEmploymentTypes.value = false;
    }
  }

  /// Calls POST {{baseUrl}}/loan/employment-type
  Future<bool> submitEmploymentTypeSelection() async {
    isSelectingEmploymentType.value = true;
    try {
      final res = await ApiService.selectEmploymentType(
        employmentType: selectedEmploymentType.value,
        loanType: selectedLoanType.value,
        loanAmount: loanAmount.value.toInt(),
        businessEntity: selectedEmploymentType.value.toLowerCase().contains('self')
            ? getDropdownValueForField('business_entity', 'Proprietorship').value
            : null,
      );

      if (res['status_code'] == 200 || res['success'] == true) {
        final model = EmploymentTypeSelectionResponseModel.fromJson(res);
        if (model.data != null) {
          selectionData.value = model.data;
          dynamicDocuments.assignAll(model.data!.documents);

          // Initialize checkboxes: default to checked for all documents
          for (final doc in model.data!.documents) {
            final key = doc.key ?? '';
            if (key.isNotEmpty) {
              selectedDocCheckboxes[key] = true;
              if (doc.uploaded == true) {
                uploadedDocFileNames[key] = '${doc.label ?? 'Document'} (Uploaded)';
              }
            }
          }

          // Advance to Step 4 (Upload Documents / Proof screen)
          goToStep(4);
          return true;
        }
      } else {
        final msg = ApiService.getErrorMessage(res);
        Get.snackbar(
          'Notice',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error in submitEmploymentTypeSelection: $e');
      // Advance to step 4 even if network issue occurs
      goToStep(4);
      return false;
    } finally {
      isSelectingEmploymentType.value = false;
    }
  }

  /// Upload dynamic document item
  Future<void> pickAndUploadDynamicDoc(LoanDocumentItem doc, {BuildContext? context}) async {
    final key = doc.key ?? '';
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload ${doc.label ?? 'Document'}',
      subtitle: 'Take a clear photo or select from your gallery',
    );

    if (file == null) return;

    final length = await file.length();
    final sizeStr = length > 1024 * 1024
        ? '${(length / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(length / 1024).toStringAsFixed(0)} KB';

    uploadingDocKeys[key] = true;

    // Simulate upload delay
    await Future.delayed(const Duration(milliseconds: 900));

    uploadingDocKeys[key] = false;
    uploadedDocFileNames[key] = file.name;
    uploadedDocFileSizes[key] = sizeStr;
    selectedDocCheckboxes[key] = true;

    Get.snackbar(
      'Document Uploaded',
      '${doc.label ?? 'Document'} uploaded successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Remove dynamic document
  void removeDynamicDoc(LoanDocumentItem doc) {
    final key = doc.key ?? '';
    uploadedDocFileNames.remove(key);
    uploadedDocFileSizes.remove(key);
    uploadingDocKeys.remove(key);
  }

  // ========================================================
  // Step 4: Documents Data by Employment Type (All empty by default)
  // ========================================================

  // 1. Salaried Documents (4 items, all empty by default)
  final salariedDocs = <LoanDocItem>[
    LoanDocItem(
      title: 'Salary slips · last 3 months',
      subtitle: 'PDF, JPG or PNG · max 5 MB',
      isAdded: false,
    ),
    LoanDocItem(
      title: 'Bank statement · 6 months',
      subtitle: 'PDF, JPG or PNG · max 5 MB',
      isAdded: false,
    ),
    LoanDocItem(
      title: 'Form 16 / ITR',
      subtitle: 'PDF, JPG or PNG · max 5 MB',
      isAdded: false,
    ),
    LoanDocItem(
      title: 'Employee ID card',
      subtitle: 'Front side is enough',
      isAdded: false,
    ),
  ];

  // 2. Self-employed / Business Documents (9 items, all empty by default)
  final selfEmployedDocs = <LoanDocItem>[
    LoanDocItem(title: 'GST registration', isAdded: false),
    LoanDocItem(title: 'Udyam registration', isAdded: false),
    LoanDocItem(title: 'MOA / AOA', isAdded: false),
    LoanDocItem(title: 'FSSAI licence', isAdded: false),
    LoanDocItem(title: 'EPFO registration', isAdded: false),
    LoanDocItem(title: 'Gumasta licence', isAdded: false),
    LoanDocItem(title: 'ISO certificate', isAdded: false),
    LoanDocItem(title: 'Shop Act licence', isAdded: false),
    LoanDocItem(title: 'Import-Export Code (IEC)', isAdded: false),
  ];

  // 3. Freelancer Documents (6 items, all empty by default)
  final freelancerDocs = <LoanDocItem>[
    LoanDocItem(title: 'Engagement / work certificate', isAdded: false),
    LoanDocItem(title: 'Portfolio', isAdded: false),
    LoanDocItem(title: 'Increment or renewal letter', isAdded: false),
    LoanDocItem(title: 'Client invoices', isAdded: false),
    LoanDocItem(title: 'Payment records (PayPal, Upwork...)', isAdded: false),
    LoanDocItem(title: 'ITR', isAdded: false),
  ];

  // 4. Pensioner Documents (6 items, all empty by default)
  final pensionerDocs = <LoanDocItem>[
    LoanDocItem(title: 'Pension Payment Order (PPO)', isAdded: false),
    LoanDocItem(title: 'Latest pension slip', isAdded: false),
    LoanDocItem(title: 'Bank statement', isAdded: false),
    LoanDocItem(title: 'Utility bill', isAdded: false),
    LoanDocItem(title: 'Life certificate', isAdded: false),
    LoanDocItem(title: 'ITR', isAdded: false),
  ];

  /// Get active document list for the currently selected employment type
  List<LoanDocItem> get activeDocs {
    final type = selectedEmploymentType.value.toLowerCase();
    if (type.contains('self') || type.contains('business')) {
      return selfEmployedDocs;
    } else if (type.contains('freelancer')) {
      return freelancerDocs;
    } else if (type.contains('pension')) {
      return pensionerDocs;
    } else {
      return salariedDocs;
    }
  }

  /// Get count of added documents for active category
  int get activeAddedCount {
    return activeDocs.where((d) => d.isAdded.value).length;
  }

  /// Opens ImagePickerBottomSheet to take photo or choose from gallery,
  /// then updates document name, size, and shows upload progress animation.
  Future<void> pickAndUploadDocument(LoanDocItem doc, {BuildContext? context}) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload ${doc.title}',
      subtitle: 'Take a clear photo or select from your gallery',
    );

    if (file == null) return;

    final length = await file.length();
    final sizeStr = length > 1024 * 1024
        ? '${(length / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(length / 1024).toStringAsFixed(0)} KB';

    doc.fileName.value = file.name;
    doc.fileSize.value = sizeStr;
    doc.isUploading.value = true;
    doc.isAdded.value = false;

    // Smooth upload delay while LinearProgressIndicator animates
    await Future.delayed(const Duration(milliseconds: 1000));
    doc.isUploading.value = false;
    doc.isAdded.value = true;

    Get.snackbar(
      'Document Uploaded',
      '${doc.title} uploaded successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Direct quick upload fallback if needed
  void uploadDocument(LoanDocItem doc, {BuildContext? context}) {
    pickAndUploadDocument(doc, context: context);
  }

  /// Remove document action
  void removeDocument(LoanDocItem doc) {
    doc.isAdded.value = false;
    doc.isUploading.value = false;
    doc.uploadProgress.value = 0.0;
  }
}
