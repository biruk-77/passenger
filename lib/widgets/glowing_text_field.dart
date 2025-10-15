// lib/widgets/glowing_text_field.dart

import 'package:flutter/material.dart';
import '../theme/color.dart'; // Ensure this path is correct

class GlowingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final Widget? prefixWidget;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isObscured;
  final bool isReadOnly;
  final Widget? suffixIcon;
  final FocusNode? focusNode; // ✅ MADE THIS PARAMETER OPTIONAL

  const GlowingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.prefixWidget,
    this.validator,
    this.keyboardType,
    this.isObscured = false,
    this.isReadOnly = false,
    this.suffixIcon,
    this.focusNode, // ✅ ADDED TO CONSTRUCTOR
  });

  @override
  State<GlowingTextField> createState() => _GlowingTextFieldState();
}

class _GlowingTextFieldState extends State<GlowingTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _effectiveFocusNode; // Will be used by the widget
  bool _isInternalFocusNode = false; // Flag to know if we need to dispose it

  late AnimationController _animationController;
  String? _errorText;
  bool _hasFocus = false;

  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();

    // ✅ CORE LOGIC: Use the provided FocusNode or create a new one
    if (widget.focusNode == null) {
      _effectiveFocusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _effectiveFocusNode = widget.focusNode!;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _effectiveFocusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChange() {
    if (widget.isReadOnly) {
      _effectiveFocusNode.unfocus();
      return;
    }
    if (mounted) {
      setState(() {
        _hasFocus = _effectiveFocusNode.hasFocus;
        if (_hasFocus) {
          _animationController.forward();
        } else {
          _animationController.reverse();
          _formFieldKey.currentState?.validate();
        }
      });
    }
  }

  void _onTextChanged() {
    if (_hasFocus) {
      _formFieldKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);

    // ✅ Dispose the focus node ONLY if we created it internally
    if (_isInternalFocusNode) {
      _effectiveFocusNode.dispose();
    }

    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _formFieldKey,
      initialValue: widget.controller.text,
      validator: (value) {
        final error = widget.validator?.call(widget.controller.text);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _errorText = error);
        });
        return error;
      },
      builder: (field) {
        final hasError = _errorText != null && _errorText!.isNotEmpty;
        final glowColor = hasError
            ? AppColors.brightRed
            : AppColors.accentColor;
        final bool isEffectivelyReadOnly = widget.isReadOnly;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: isEffectivelyReadOnly
                        ? Colors.transparent
                        : glowColor.withOpacity(
                            (_hasFocus || hasError) ? 0.7 : 0.0,
                          ),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode, // ✅ USE THE EFFECTIVE NODE
            readOnly: isEffectivelyReadOnly,
            style: TextStyle(
              color: isEffectivelyReadOnly
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 16,
            ),
            obscureText: widget.isObscured,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon:
                  widget.prefixWidget ??
                  (widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(
                            widget.icon,
                            color: isEffectivelyReadOnly
                                ? AppColors.textSecondary.withOpacity(0.5)
                                : AppColors.textSecondary.withOpacity(0.7),
                          ),
                        )
                      : null),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: isEffectivelyReadOnly
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.4),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isEffectivelyReadOnly
                      ? AppColors.borderColor.withOpacity(0.5)
                      : AppColors.borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isEffectivelyReadOnly
                      ? AppColors.borderColor.withOpacity(0.5)
                      : AppColors.borderColor,
                  width: 2,
                ),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(color: AppColors.borderColor, width: 2),
              ),
              errorStyle: const TextStyle(
                color: AppColors.goldenrod,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              errorText: field.errorText,
            ),
          ),
        );
      },
    );
  }
}
