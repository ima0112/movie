import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pako_state.dart';

/// Debug-only screen that renders every color, text style, and spacing
/// token so the design system tokens can be checked visually.
///
/// Not part of the product's screen inventory (`docs/SCREENS.md`) — this
/// exists purely to verify `core/theme/` before building real screens.
class DesignSystemDebugScreen extends StatelessWidget {
  const DesignSystemDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system debug')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _SectionTitle('Colors'),
          const SizedBox(height: AppSpacing.md),
          _ColorSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Text styles'),
          const SizedBox(height: AppSpacing.md),
          const _TextStylesSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Spacing'),
          const SizedBox(height: AppSpacing.md),
          const _SpacingSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Icons'),
          const SizedBox(height: AppSpacing.md),
          const _IconsSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Pako'),
          const SizedBox(height: AppSpacing.md),
          const _PakoSection(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.h2);
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  static const _swatches = <(String, Color)>[
    ('surface', AppColors.surface),
    ('surfaceRaised', AppColors.surfaceRaised),
    ('surfaceRaised2', AppColors.surfaceRaised2),
    ('line', AppColors.line),
    ('lineStrong', AppColors.lineStrong),
    ('ink', AppColors.ink),
    ('inkMuted', AppColors.inkMuted),
    ('inkDim', AppColors.inkDim),
    ('accent', AppColors.accent),
    ('accentDeep', AppColors.accentDeep),
    ('onAccent', AppColors.onAccent),
    ('success', AppColors.success),
    ('danger', AppColors.danger),
    ('profileAmber', AppColors.profileAmber),
    ('profileCoral', AppColors.profileCoral),
    ('profileMint', AppColors.profileMint),
    ('profileLilac', AppColors.profileLilac),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, color) in _swatches) _ColorSwatch(name, color),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.lineStrong),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _TextStylesSection extends StatelessWidget {
  const _TextStylesSection();

  static const _styles = <(String, TextStyle Function())>[
    ('display', _display),
    ('h1', _h1),
    ('h2', _h2),
    ('h3', _h3),
    ('body', _body),
    ('bodySm', _bodySm),
    ('caption', _caption),
    ('micro', _micro),
  ];

  static TextStyle _display() => AppTextStyles.display;
  static TextStyle _h1() => AppTextStyles.h1;
  static TextStyle _h2() => AppTextStyles.h2;
  static TextStyle _h3() => AppTextStyles.h3;
  static TextStyle _body() => AppTextStyles.body;
  static TextStyle _bodySm() => AppTextStyles.bodySm;
  static TextStyle _caption() => AppTextStyles.caption;
  static TextStyle _micro() => AppTextStyles.micro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, styleBuilder) in _styles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    name,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('PakoTV — Aa 0123', style: styleBuilder()),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  static const _tokens = <(String, double)>[
    ('xs', AppSpacing.xs),
    ('sm', AppSpacing.sm),
    ('md', AppSpacing.md),
    ('lg', AppSpacing.lg),
    ('xl', AppSpacing.xl),
    ('xxl', AppSpacing.xxl),
    ('xxxl', AppSpacing.xxxl),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in _tokens)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    '$name (${value.toInt()})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Container(
                  width: value,
                  height: AppSpacing.lg,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IconsSection extends StatelessWidget {
  const _IconsSection();

  static const _icons = <(String, IconData)>[
    ('search', AppIcons.search),
    ('filter', AppIcons.filter),
    ('favorite', AppIcons.favorite),
    ('favoriteFill', AppIcons.favoriteFill),
    ('watchLater', AppIcons.watchLater),
    ('watchLaterFill', AppIcons.watchLaterFill),
    ('watched', AppIcons.watched),
    ('watchedFill', AppIcons.watchedFill),
    ('play', AppIcons.play),
    ('share', AppIcons.share),
    ('back', AppIcons.back),
    ('close', AppIcons.close),
    ('home', AppIcons.home),
    ('compass', AppIcons.compass),
    ('user', AppIcons.user),
    ('settings', AppIcons.settings),
    ('stats', AppIcons.stats),
    ('qrCode', AppIcons.qrCode),
    ('copy', AppIcons.copy),
    ('retry', AppIcons.retry),
    ('check', AppIcons.check),
    ('chevronRight', AppIcons.chevronRight),
    ('chevronDown', AppIcons.chevronDown),
    ('info', AppIcons.info),
    ('hourglass', AppIcons.hourglass),
    ('group', AppIcons.group),
    ('dice', AppIcons.dice),
    ('useMyTastes', AppIcons.useMyTastes),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final (name, icon) in _icons) _IconSwatch(name, icon),
      ],
    );
  }
}

class _IconSwatch extends StatelessWidget {
  const _IconSwatch(this.name, this.icon);

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.ink),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _PakoSection extends StatelessWidget {
  const _PakoSection();

  static const _moods = <(String, PakoMood)>[
    ('off', PakoMood.off),
    ('idle', PakoMood.idle),
    ('asleep', PakoMood.asleep),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (name, mood) in _moods)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xxl),
            child: Column(
              children: [
                PakoState(mood: mood, size: 80),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
