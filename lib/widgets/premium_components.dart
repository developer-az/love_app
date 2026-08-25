import 'package:flutter/material.dart';
import 'package:my_special_app/theme/app_theme.dart';

/// Premium reusable components for the app
class PremiumComponents {
  /// Premium search bar with glassmorphism effect
  static Widget searchBar({
    required String hintText,
    required Function(String) onChanged,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) {
    return PremiumSearchBar(
      hintText: hintText,
      onChanged: onChanged,
      controller: controller,
      onTap: onTap,
    );
  }

  /// Premium category chip
  static Widget categoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Premium stats card
  static Widget statsCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color ?? AppTheme.primaryColor,
                size: 24,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color ?? AppTheme.primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTheme.headingStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.captionStyle,
          ),
        ],
      ),
    );
  }

  /// Premium floating action button with animation
  static Widget premiumFAB({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return Container(
      decoration: AppTheme.gradientButtonDecoration,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        tooltip: tooltip,
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  /// Premium loading indicator
  static Widget loadingIndicator({String? message}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Premium snackbar
  static SnackBar premiumSnackBar({
    required String message,
    required IconData icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: duration,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Premium section header
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.subheadingStyle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See All',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PremiumSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final VoidCallback? onTap;

  const PremiumSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.onTap,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTheme.bodyStyle,
      ),
    );
  }
}
