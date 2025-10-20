// lib/widgets/glowing_text_field.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/color.dart';
import '../providers/theme_provider.dart';

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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        
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
              : (isDark ? AppColors.neonCyan : const Color(0xFF004080)); // Grace's blue for light mode
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
                        : glowColor.withValues(
                            alpha: (_hasFocus || hasError) ? 0.7 : 0.0,
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
                  ? (isDark ? AppColors.textSecondary : const Color(0xFF004080))
                  : (isDark ? AppColors.textPrimary : const Color(0xFF004080)), // Grace's blue text
              fontSize: 16,
            ),
            obscureText: widget.isObscured,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: isDark ? AppColors.textSecondary : const Color(0xFF004080).withValues(alpha: 0.7),
              ),
              prefixIcon:
                  widget.prefixWidget ??
                  (widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(
                            widget.icon,
                            color: isEffectivelyReadOnly
                                ? AppColors.textSecondary.withValues(alpha: 0.5)
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                          ),
                        )
                      : null),
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: isDark
                  ? (isEffectivelyReadOnly
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.4))
                  : (isEffectivelyReadOnly
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.9)), // White background for Grace's blue theme
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isDark
                      ? (isEffectivelyReadOnly
                          ? AppColors.borderColor.withValues(alpha: 0.5)
                          : AppColors.borderColor)
                      : const Color(0xFF004080).withValues(alpha: 0.3), // Grace's blue border
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isDark
                      ? (isEffectivelyReadOnly
                          ? AppColors.borderColor.withValues(alpha: 0.5)
                          : AppColors.borderColor)
                      : const Color(0xFF004080), // Grace's blue focused border
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderColor : AppColors.brightRed,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderColor : AppColors.brightRed,
                  width: 2,
                ),
              ),
              errorStyle: TextStyle(
                color: isDark ? AppColors.goldenrod : AppColors.brightRed,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              errorText: field.errorText,
            ),
          ),
          );
        },
      );
      },
    );
  }
}
