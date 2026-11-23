import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Reusable overlay-based Custom Dropdown widget matching Finsphere AI theme.
/// Replaces standard DropdownButton / modal bottom sheet with a floating overlay menu.
/// Supports standard Flutter Form validation via [validator].
class CustomAppDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final IconData? prefixIcon;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool compact;
  final bool isRequired;
  final FormFieldValidator<String>? validator;

  const CustomAppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.prefixIcon,
    required this.onChanged,
    this.hintText,
    this.compact = false,
    this.isRequired = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return FormField<String>(
        initialValue: value,
        validator: validator,
        builder: (FormFieldState<String> fieldState) {
          // If outer reactive value changed, update field state
          if (fieldState.value != value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (fieldState.mounted) {
                fieldState.didChange(value);
              }
            });
          }

          return _CustomAppDropdownInternal(
            label: label,
            value: value,
            items: items,
            prefixIcon: prefixIcon,
            onChanged: (val) {
              fieldState.didChange(val);
              onChanged(val);
            },
            hintText: hintText,
            compact: compact,
            isRequired: isRequired,
            errorText: fieldState.errorText,
          );
        },
      );
    }

    return _CustomAppDropdownInternal(
      label: label,
      value: value,
      items: items,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
      hintText: hintText,
      compact: compact,
      isRequired: isRequired,
      errorText: null,
    );
  }
}

class _CustomAppDropdownInternal extends StatefulWidget {
  final String label;
  final String value;
  final List<String> items;
  final IconData? prefixIcon;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final bool compact;
  final bool isRequired;
  final String? errorText;

  const _CustomAppDropdownInternal({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.hintText,
    this.compact = false,
    this.isRequired = false,
    this.errorText,
  });

  @override
  State<_CustomAppDropdownInternal> createState() => _CustomAppDropdownInternalState();
}

class _CustomAppDropdownInternalState extends State<_CustomAppDropdownInternal> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final GlobalKey _triggerKey = GlobalKey();

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    // Dismiss any active keyboard
    FocusScope.of(context).unfocus();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final Size size = renderBox?.size ?? Size.zero;
    final Offset position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final double availableHeightBelow = screenHeight - (position.dy + size.height) - 16;
    final double availableHeightAbove = position.dy - mediaQuery.padding.top - 16;

    // Determine if we should show the dropdown above the trigger
    final bool showAbove = availableHeightBelow < 180 && availableHeightAbove > availableHeightBelow;

    // The maximum height the dropdown can take
    final double maxHeight = showAbove
        ? availableHeightAbove.clamp(100.0, 240.0)
        : availableHeightBelow.clamp(100.0, 240.0);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent dismiss barrier
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          _DropdownMenuOverlay(
            items: widget.items,
            value: widget.value,
            onChanged: widget.onChanged,
            width: size.width,
            layerLink: _layerLink,
            triggerSize: size,
            onClose: _closeDropdown,
            showAbove: showAbove,
            maxHeight: maxHeight,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = widget.compact ? 12.0 : 14.0;
    final double labelSpacing = widget.compact ? 4.0 : 6.0;
    final double containerHeight = widget.compact ? 40.0 : 48.0;
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: labelSpacing),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            key: _triggerKey,
            onTap: _toggleDropdown,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: containerHeight,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? AppColors.errorRed
                      : (_isOpen ? AppColors.navy : AppColors.line),
                  width: (hasError || _isOpen) ? 1.4 : 1.0,
                ),
                boxShadow: _isOpen
                    ? [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      color: hasError
                          ? AppColors.errorRed
                          : (_isOpen ? AppColors.navy : AppColors.muted),
                      size: widget.compact ? 17 : 19,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      widget.value.isNotEmpty ? widget.value : (widget.hintText ?? 'Select option'),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: widget.value.isNotEmpty ? AppColors.textDark : AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: hasError
                          ? AppColors.errorRed
                          : (_isOpen ? AppColors.navy : AppColors.muted),
                      size: widget.compact ? 18 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DropdownMenuOverlay extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  final double width;
  final LayerLink layerLink;
  final Size triggerSize;
  final VoidCallback onClose;
  final bool showAbove;
  final double maxHeight;

  const _DropdownMenuOverlay({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.width,
    required this.layerLink,
    required this.triggerSize,
    required this.onClose,
    required this.showAbove,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        followerAnchor: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
        targetAnchor: showAbove ? Alignment.topLeft : Alignment.bottomLeft,
        offset: Offset(0, showAbove ? -4 : 4),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          shadowColor: AppColors.navy.withValues(alpha: 0.18),
          child: Container(
            width: width,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line, width: 1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.line,
                  height: 1,
                  thickness: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == value;

                  return InkWell(
                    onTap: () {
                      onChanged(item);
                      onClose();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      color: isSelected ? AppColors.indigoTint : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.navy : AppColors.textDark,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.navy,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
