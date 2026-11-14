import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'filter_section_header.dart';

/// H8's "Years": two text fields, the first and the last year, typed by the
/// user (no slider: a 125-year track can't be set to one year with a thumb).
///
/// **Validation**, live, per field: digits only, four at most; a complete year
/// must lie in [minYear]..[maxYear], and the first can't be after the last.
/// A field with a wrong year gets the danger border and **nothing is
/// reported** until both are right, so the filter never holds an invalid
/// range. A half-typed year (fewer than four digits) is neutral — still being
/// typed — and nothing is reported for it either. An empty field is an open
/// end (`null`); with both empty the filter is off. When a field loses focus
/// without a valid year, it goes back to what the filter holds.
class YearRangeFields extends StatefulWidget {
  const YearRangeFields({
    super.key,
    required this.yearFrom,
    required this.yearTo,
    required this.onChanged,
  });

  final int? yearFrom;
  final int? yearTo;

  /// The valid range after an edit; either end `null` when left empty.
  final void Function(int? yearFrom, int? yearTo) onChanged;

  /// The earliest year accepted (TMDB's catalog is thin before it).
  static const int minYear = 1900;

  /// The latest year accepted: a couple of years ahead, for announced titles.
  static int get maxYear => DateTime.now().year + 2;

  @override
  State<YearRangeFields> createState() => _YearRangeFieldsState();
}

class _YearRangeFieldsState extends State<YearRangeFields> {
  late final TextEditingController _from = TextEditingController(
    text: _text(widget.yearFrom),
  );
  late final TextEditingController _to = TextEditingController(
    text: _text(widget.yearTo),
  );
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

  static String _text(int? year) => year?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(_onFocus);
    _toFocus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(YearRangeFields old) {
    super.didUpdateWidget(old);
    // The filter changed from outside (Clear, a preset): show it, unless the
    // user is typing in that field.
    if (!_fromFocus.hasFocus && _parse(_from.text) != widget.yearFrom) {
      _from.text = _text(widget.yearFrom);
    }
    if (!_toFocus.hasFocus && _parse(_to.text) != widget.yearTo) {
      _to.text = _text(widget.yearTo);
    }
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  /// The year in [text], or `null` when empty or incomplete.
  static int? _parse(String text) =>
      text.length == 4 ? int.tryParse(text) : null;

  bool _inRange(int year) =>
      year >= YearRangeFields.minYear && year <= YearRangeFields.maxYear;

  /// Whether the typed years are each complete-and-in-range or empty/half
  /// typed, and in order — what [_report] needs to send them.
  bool _fromWrong(int? from, int? to) =>
      from != null && (!_inRange(from) || (to != null && from > to));
  bool _toWrong(int? from, int? to) =>
      to != null && (!_inRange(to) || (from != null && from > to));

  void _onChanged(String _) {
    final from = _parse(_from.text);
    final to = _parse(_to.text);
    final fromDone = _from.text.isEmpty || from != null;
    final toDone = _to.text.isEmpty || to != null;
    setState(() {});
    if (!fromDone || !toDone) return;
    if (_fromWrong(from, to) || _toWrong(from, to)) return;
    widget.onChanged(from, to);
  }

  /// Leaving a field with no valid year puts the filter's own value back.
  void _onFocus() {
    if (_fromFocus.hasFocus || _toFocus.hasFocus) return;
    final from = _parse(_from.text);
    final to = _parse(_to.text);
    final valid =
        (_from.text.isEmpty || from != null) &&
        (_to.text.isEmpty || to != null) &&
        !_fromWrong(from, to) &&
        !_toWrong(from, to);
    if (!valid) {
      _from.text = _text(widget.yearFrom);
      _to.text = _text(widget.yearTo);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = _parse(_from.text);
    final to = _parse(_to.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(l10n.filterSheetSectionYear),
        Row(
          children: [
            Expanded(
              child: _YearField(
                controller: _from,
                focusNode: _fromFocus,
                hint: '${YearRangeFields.minYear}',
                label: l10n.filterSheetYearFrom,
                wrong: _fromWrong(from, to),
                onChanged: _onChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('–', style: _dashStyle),
            ),
            Expanded(
              child: _YearField(
                controller: _to,
                focusNode: _toFocus,
                hint: '${YearRangeFields.maxYear}',
                label: l10n.filterSheetYearTo,
                wrong: _toWrong(from, to),
                onChanged: _onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static final TextStyle _dashStyle = AppTextStyles.body.copyWith(
    color: AppColors.inkMuted,
  );
}

class _YearField extends StatelessWidget {
  const _YearField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.label,
    required this.wrong,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final String label;
  final bool wrong;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: color),
    );
    final idle = border(wrong ? AppColors.danger : AppColors.lineStrong);
    return Semantics(
      label: label,
      textField: true,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textAlign: TextAlign.start,
        style: AppTextStyles.body,
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkDim),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          enabledBorder: idle,
          focusedBorder: border(wrong ? AppColors.danger : AppColors.ink),
          border: idle,
        ),
      ),
    );
  }
}
