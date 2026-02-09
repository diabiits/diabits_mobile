import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({
    super.key,
    required this.child,
  });

  static Color outerColor(BuildContext context, {double alpha = 0.65}) {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceContainerHighest.withValues(alpha: alpha);
  }

  static Color innerColor(BuildContext context, {double alpha = 0.40}) {
    final theme = Theme.of(context);
    return theme.colorScheme.surfaceContainerHighest.withValues(alpha: alpha);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outerColor(context),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
