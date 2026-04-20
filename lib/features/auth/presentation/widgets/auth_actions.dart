import 'package:flutter/material.dart';
import 'package:e_ticketing/core/widgets/primary_button.dart';

class AuthActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool loading;

  const AuthActions({
    super.key,
    required this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: PrimaryButton(
            label: primaryLabel,
            onPressed: onPrimary,
            loading: loading,
          ),
        ),
        if (secondaryLabel != null)
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
      ],
    );
  }
}
