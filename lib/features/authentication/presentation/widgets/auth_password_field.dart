import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelKey;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.errorText,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const [AutofillHints.password],
      textInputAction: widget.textInputAction,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.labelKey.tr(),
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip:
              (_obscureText
                      ? 'authentication.show_password'
                      : 'authentication.hide_password')
                  .tr(),
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
