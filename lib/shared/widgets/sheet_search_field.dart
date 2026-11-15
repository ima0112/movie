import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The pill search field a sheet's list is filtered with (H6 Region, C5's
/// platform picker): a search icon, a [hint], and a clear button once there
/// is a [query]. Sits one level down from the sheet (`surface`) with a
/// hairline border. Pure presentation — the query is the sheet's state.
class SheetSearchField extends StatelessWidget {
  const SheetSearchField({
    super.key,
    required this.hint,
    required this.query,
    required this.onChanged,
  });

  final String hint;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        filled: true,
        // The sheet itself is surfaceRaised, so the field sits one level
        // down on `surface` with a hairline border (the "Región" design).
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(AppIcons.close, color: AppColors.inkMuted),
                onPressed: () => onChanged(''),
              ),
      ),
    );
  }
}
