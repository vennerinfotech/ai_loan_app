import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/profile_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';

/// Screen displaying user personal details, with an edit action button in header.
/// Fields are read-only by default and become editable only after tapping edit.
class PersonalDetailsScreen extends StatefulWidget {
  final bool initiallyEditing;

  const PersonalDetailsScreen({
    super.key,
    this.initiallyEditing = false,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final ProfileController profileController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;

  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.initiallyEditing;
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    firstNameController =
        TextEditingController(text: profileController.firstName.value);
    lastNameController =
        TextEditingController(text: profileController.lastName.value);
    emailController =
        TextEditingController(text: profileController.email.value);
    addressController =
        TextEditingController(text: profileController.address.value);

    profileController.clearTempImage();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    profileController.saveProfile(
      first: firstNameController.text.trim(),
      last: lastNameController.text.trim(),
      emailAddress: emailController.text.trim(),
      addr: addressController.text.trim(),
    );

    setState(() {
      _isEditing = false;
    });

    Get.snackbar(
      'Profile updated',
      'Your personal details have been saved successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void _cancelEditing() {
    setState(() {
      firstNameController.text = profileController.firstName.value;
      lastNameController.text = profileController.lastName.value;
      emailController.text = profileController.email.value;
      addressController.text = profileController.address.value;
      profileController.clearTempImage();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Edit Icon Button Action
            _buildTopBar(context),

            // Scrollable Cards Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Avatar (with Camera Edit Badge when editing)
                    _buildAvatarSection(context),

                    const SizedBox(height: 20),

                    // Card 1: Personal Information (First Name & Last Name)
                    _buildPersonalInfoCard(),

                    const SizedBox(height: 16),

                    // Card 2: Contact Information (Mobile Number & Email)
                    _buildContactInfoCard(),

                    const SizedBox(height: 16),

                    // Card 3: Address Details
                    _buildAddressDetailsCard(),

                    const SizedBox(height: 16),

                    // KYC Notice Note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Changing your name needs a fresh KYC check. Mobile number is linked to your account.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons (Only visible during edit mode)
            if (_isEditing) _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button, centered title, and edit toggle button
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Squircle Back Button
          GestureDetector(
            onTap: () {
              profileController.clearTempImage();
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
          ),

          // Title
          const Text(
            'Personal details',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          // Squircle Edit Action Button
          GestureDetector(
            onTap: () {
              if (_isEditing) {
                _cancelEditing();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isEditing ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isEditing
                      ? AppColors.navy
                      : AppColors.line,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_outlined,
                size: 18,
                color: _isEditing ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Circular Avatar with Golden Amber ring and camera edit badge
  Widget _buildAvatarSection(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer Soft Brand Ring
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.35),
                width: 2.2,
              ),
            ),
            child: Obx(() {
              final tempBytes = profileController.tempImageBytes.value;
              final savedBytes = profileController.profileImageBytes.value;
              final bytesToUse = tempBytes ?? savedBytes;

              return Container(
                width: 86,
                height: 86,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: bytesToUse != null
                    ? Image.memory(
                        bytesToUse,
                        fit: BoxFit.cover,
                        width: 86,
                        height: 86,
                      )
                    : Text(
                        profileController.initials,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              );
            }),
          ),

          // Camera Action Badge (only interactive when editing)
          if (_isEditing)
            Positioned(
              right: 2,
              bottom: 4,
              child: GestureDetector(
                onTap: () async {
                  final file = await ImagePickerBottomSheet.show(
                    context: context,
                    title: 'Change profile photo',
                    subtitle: 'Take a new selfie or choose from gallery',
                  );
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    profileController.setTempImage(bytes, file.path);
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Card 1: Personal Information (First name & Last name)
  Widget _buildPersonalInfoCard() {
    return _buildSectionCard(
      icon: Icons.info_rounded,
      iconColor: AppColors.primaryPurple,
      title: 'Personal Information',
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('First name'),
                  const SizedBox(height: 6),
                  _PersonalInputField(
                    controller: firstNameController,
                    hintText: 'Aarav',
                    readOnly: !_isEditing,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Last name'),
                  const SizedBox(height: 6),
                  _PersonalInputField(
                    controller: lastNameController,
                    hintText: 'Mehta',
                    readOnly: !_isEditing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card 2: Contact Information (Phone number locked, Email address)
  Widget _buildContactInfoCard() {
    return _buildSectionCard(
      icon: Icons.phone_rounded,
      iconColor: AppColors.primaryPurple,
      title: 'Contact Information',
      children: [
        _buildFieldLabel('Phone Number'),
        const SizedBox(height: 6),
        // Locked Mobile Number Field (matching Edit Profile screen)
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                profileController.phone.value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: const [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.primaryPurple,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Locked',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildFieldLabel('Email Address'),
        const SizedBox(height: 6),
        _PersonalInputField(
          controller: emailController,
          hintText: 'aarav@example.com',
          keyboardType: TextInputType.emailAddress,
          readOnly: !_isEditing,
        ),
      ],
    );
  }

  /// Card 3: Address Details (Address)
  Widget _buildAddressDetailsCard() {
    return _buildSectionCard(
      icon: Icons.location_on_rounded,
      iconColor: AppColors.primaryPurple,
      title: 'Address Details',
      children: [
        _buildFieldLabel('Address'),
        const SizedBox(height: 6),
        _PersonalInputField(
          controller: addressController,
          hintText: '123, MG Road, Bengaluru 560001',
          maxLines: 2,
          readOnly: !_isEditing,
        ),
      ],
    );
  }

  /// Reusable section card wrapper with header icon, title, and divider
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon + Title
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.canvas),
          const SizedBox(height: 14),

          // Card contents
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 13,
        fontWeight: FontWeight.w700,
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
                onPressed: _cancelEditing,
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
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Save changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
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

/// Custom Focusable Input Field matching card style with readOnly support
class _PersonalInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;

  const _PersonalInputField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  State<_PersonalInputField> createState() => _PersonalInputFieldState();
}

class _PersonalInputFieldState extends State<_PersonalInputField> {
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
    final isFieldFocused = !widget.readOnly && _isFocused;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: widget.readOnly
            ? AppColors.canvas
            : (isFieldFocused ? Colors.white : AppColors.canvas),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFieldFocused
              ? AppColors.primaryPurple
              : AppColors.line,
          width: isFieldFocused ? 1.5 : 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: widget.maxLines > 1 ? 10 : 0,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.readOnly ? null : _focusNode,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        style: TextStyle(
          color: widget.readOnly
              ? AppColors.textDark
              : AppColors.textDark,
          fontSize: 14,
          fontWeight: widget.readOnly ? FontWeight.w600 : FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.maxLines > 1 ? 0 : 13,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
