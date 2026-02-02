import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

enum StartLinkButtonVariant { primary, secondary, outline, ghost }

class StartLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final StartLinkButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const StartLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = StartLinkButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case StartLinkButtonVariant.primary:
        return _buildPrimaryButton(context);
      case StartLinkButtonVariant.secondary:
        return _buildSecondaryButton(context);
      case StartLinkButtonVariant.outline:
        return _buildOutlineButton(context);
      case StartLinkButtonVariant.ghost:
        return _buildGhostButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final customColors = Theme.of(context).extension<StartLinkColors>();

    final buttonContent = Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? (customColors?.brandGradient ?? AppColors.startLinkGradient)
            : null,
        color: onPressed == null ? Colors.grey[800] : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.brandPurple.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: _buildChild(context),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: buttonContent)
        : buttonContent;
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return _wrapButton(
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceGlass,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context) {
    return _wrapButton(
      OutlinedButton(onPressed: onPressed, child: _buildChild(context)),
    );
  }

  Widget _buildGhostButton(BuildContext context) {
    return _wrapButton(
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: _buildChild(context),
      ),
    );
  }

  Widget _wrapButton(Widget child) {
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
      );
    }

    return Text(label);
  }
}
