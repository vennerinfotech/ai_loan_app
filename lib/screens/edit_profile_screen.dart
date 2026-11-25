import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../controller/profile_controller.dart';

/// Screen allowing the user to view and edit profile details (Reference Image)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController profileController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController mobileController;
  late final TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController());
    firstNameController =
        TextEditingController(text: profileController.firstName);
    lastNameController =
        TextEditingController(text: profileController.lastName);
    emailController =
        TextEditingController(text: profileController.email);
    mobileController =
        TextEditingController(text: profileController.phone);
    addressController =
        TextEditingController(text: profileController.address);
    profileController.clearTempImage();
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

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centered Avatar with Camera Badge
                    _buildAvatarSection(context),

                    const SizedBox(height: 24),

                    // First name & Last name row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'First name',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _FocusableInputField(
                                controller: firstNameController,
                                hintText: 'Aarav',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last name',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _FocusableInputField(
                                controller: lastNameController,
                                hintText: 'Mehta',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FocusableInputField(
                      controller: emailController,
                      hintText: 'aarav@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    // Mobile number (Locked)
                    const Text(
                      'Mobile number',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLockedMobileField(),

                    const SizedBox(height: 18),

                    // Address
                    const Text(
                      'Address',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FocusableInputField(
                      controller: addressController,
                      hintText: '123, MG Road, Bengaluru 560001',
                    ),

                    const SizedBox(height: 14),

                    // Notice / Helper Text
                    const Text(
                      'Changing your name needs a fresh KYC check. Mobile number is linked to your account.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button and centered title
  Widget _buildTopBar(BuildContext context) {
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
          const Expanded(
            child: Center(
              child: Text(
                'Edit profile',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          // Symmetrical spacer
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Centered circular avatar with camera badge and outer ring
  Widget _buildAvatarSection(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Outer delicate guide ring
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.indigo.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Obx(() {
              final imageBytes = profileController.tempImageBytes.value ??
                  profileController.profileImageBytes.value;

              return Container(
                width: 82,
                height: 82,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        width: 82,
                        height: 82,
                      )
                    : const Text(
                        'AM',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              );
            }),
          ),

          // Small Navy Camera Action Badge
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: () async {
                final file = await ImagePickerBottomSheet.show(
                  title: 'Profile photo',
                  subtitle: 'Take a photo or choose from gallery',
                );
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  profileController.setTempImage(bytes, file.path);
                  Get.snackbar(
                    'Photo Selected',
                    'Photo preview loaded.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: AppColors.navy,
                    colorText: Colors.white,
                  );
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.amber,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Locked mobile number container
  Widget _buildLockedMobileField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.indigoTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '+91 98765 43210',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: const [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.indigo,
              ),
              SizedBox(width: 4),
              Text(
                'Locked',
                style: TextStyle(
                  color: AppColors.indigo,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bottom button row: Cancel & Save changes
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: AppColors.lightBackground,
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  profileController.clearTempImage();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.line,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Save changes Button
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  profileController.saveProfile(
                    first: firstNameController.text.trim(),
                    last: lastNameController.text.trim(),
                    emailAddress: emailController.text.trim(),
                    addr: addressController.text.trim(),
                  );
                  Get.back();
                  Get.snackbar(
                    'Profile Saved',
                    'Your profile details and picture have been updated.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: AppColors.navy,
                    colorText: Colors.white,
                  );
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
                      'Save changes',
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
          ),
        ],
      ),
    );
  }
}

/// Dynamically focusable input field:
/// - Unfocused: Soft-blue background AppColors.inputFill without active border
/// - Focused: White background with active purple border AppColors.indigo
class _FocusableInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;

  const _FocusableInputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_FocusableInputField> createState() => _FocusableInputFieldState();
}

class _FocusableInputFieldState extends State<_FocusableInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 50,
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? AppColors.indigo : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
