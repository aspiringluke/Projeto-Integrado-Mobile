import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/botao_voltar.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_card_expanded_body.dart';
import 'character_card_visuals.dart';

class CharacterCard extends StatefulWidget {
  final CharacterCardData data;
  final bool isPinned;
  final VoidCallback onTogglePinned;

  const CharacterCard({
    super.key,
    required this.data,
    required this.isPinned,
    required this.onTogglePinned,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  late final ScrollController _synopsisScrollController;
  CharacterDateEntries? _dateEntries;
  DateTime? _birthdayValue;
  double? _heightCmValue;
  double? _weightKgValue;
  TextEditingController? _heightController;
  TextEditingController? _weightController;
  TextEditingController? _quoteController;
  TextEditingController? _synopsisController;
  bool? _isEditing;
  CharacterDateType _dateType = CharacterDateType.lastModified;
  HeightUnit _heightUnit = HeightUnit.centimeters;
  WeightUnit _weightUnit = WeightUnit.kilograms;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _dateEntries = CharacterDateEntries.fromSeed(widget.data.seed);
    _birthdayValue = DateTime(
      widget.data.birthYear,
      widget.data.birthMonth,
      widget.data.birthDay,
    );
    _heightCmValue = widget.data.heightCm;
    _weightKgValue = widget.data.weightKg;
    _heightController = TextEditingController(
      text: formatHeightEditorValue(widget.data.heightCm, _heightUnit),
    );
    _weightController = TextEditingController(
      text: formatWeightEditorValue(widget.data.weightKg, _weightUnit),
    );
    _quoteController = TextEditingController(text: widget.data.quote);
    _synopsisController = TextEditingController(text: widget.data.synopsis);
    _isEditing = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _isExpanded ? 1 : 0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 1, curve: Curves.easeOut),
      reverseCurve: const Interval(0, 0.82, curve: Curves.easeIn),
    );
    _synopsisScrollController = ScrollController();
  }

  @override
  void dispose() {
    _synopsisScrollController.dispose();
    _heightController?.dispose();
    _weightController?.dispose();
    _quoteController?.dispose();
    _synopsisController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _openCharacterPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _CharacterPlaceholderPage(title: widget.data.name),
      ),
    );
  }

  void _cycleDateType() {
    setState(() {
      _dateType = switch (_dateType) {
        CharacterDateType.lastModified => CharacterDateType.lastAccessed,
        CharacterDateType.lastAccessed => CharacterDateType.createdAt,
        CharacterDateType.createdAt => CharacterDateType.lastModified,
      };
    });
  }

  Future<void> _showSignDescription(Rect anchorRect) async {
    final sign = _signData;
    final descriptionLines = sign.description.split('\n');
    final dateRange = descriptionLines.isNotEmpty ? descriptionLines.first : '';
    final traitsLine = descriptionLines.length > 1 ? descriptionLines.sublist(1).join(' ') : '';
    final traits = traitsLine
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);

    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 232,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${sign.symbol} ${sign.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C262C),
            ),
          ),
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              dateRange,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.46),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            ),
          ],
          if (traits.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final trait in traits) _ZodiacTraitPill(label: trait),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCharacterAge(Rect anchorRect) async {
    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 150,
      child: Text(
        'Idade: ${calculateAge(_birthday)} anos',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.68),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Future<void> _selectHeightUnit() async {
    final selectedUnit = await showModalBottomSheet<HeightUnit>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProjectBottomSheetFrame(
          title: 'Unidade de medida',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in HeightUnit.values)
                _HeightUnitOption(
                  label: heightUnitMenuLabel(unit),
                  isSelected: unit == _heightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedUnit == null) {
      return;
    }

    setState(() {
      if (_editing) {
        _commitHeightText(restoreText: false);
      }
      _heightUnit = selectedUnit;
      if (_editing) {
        _heightTextController.text = formatHeightEditorValue(_heightCm, _heightUnit);
      }
    });
  }

  Future<void> _selectWeightUnit() async {
    final selectedUnit = await showModalBottomSheet<WeightUnit>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProjectBottomSheetFrame(
          title: 'Unidade de peso',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in WeightUnit.values)
                _HeightUnitOption(
                  label: weightUnitMenuLabel(unit),
                  isSelected: unit == _weightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedUnit == null) {
      return;
    }

    setState(() {
      if (_editing) {
        _commitWeightText(restoreText: false);
      }
      _weightUnit = selectedUnit;
      if (_editing) {
        _weightTextController.text = formatWeightEditorValue(_weightKg, _weightUnit);
      }
    });
  }

  Future<void> _selectBirthday() async {
    var tempMonth = _birthday.month;
    var tempDay = _birthday.day;
    final monthController = FixedExtentScrollController(initialItem: tempMonth - 1);
    final dayController = FixedExtentScrollController(initialItem: tempDay - 1);

    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ProjectBottomSheetFrame(
              title: 'Aniversario',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 188,
                    child: Row(
                      children: [
                        Expanded(
                          child: _CharacterBirthdayWheel(
                            label: 'Mes',
                            controller: monthController,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempMonth = index + 1;
                                final maxDay = daysInMonth(tempMonth);

                                if (tempDay > maxDay) {
                                  tempDay = maxDay;
                                  dayController.jumpToItem(tempDay - 1);
                                }
                              });
                            },
                            children: [
                              for (var index = 0; index < monthLabels.length; index += 1)
                                Center(
                                  child: Text(
                                    monthLabels[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF2C262C),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CharacterBirthdayWheel(
                            label: 'Dia',
                            controller: dayController,
                            onSelectedItemChanged: (index) {
                              tempDay = index + 1;
                            },
                            children: [
                              for (var day = 1; day <= daysInMonth(tempMonth); day += 1)
                                Center(
                                  child: Text(
                                    day.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF2C262C),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pop(DateTime(_birthday.year, tempMonth, tempDay));
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    monthController.dispose();
    dayController.dispose();

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _birthdayValue = selectedDate;
    });
  }

  void _commitHeightText({bool restoreText = true}) {
    final parsedHeight = parseHeightToCm(_heightTextController.text, _heightUnit);

    if (parsedHeight != null) {
      _heightCmValue = parsedHeight;
    }

    if (restoreText) {
      _heightTextController.text = formatHeightEditorValue(_heightCm, _heightUnit);
    }
  }

  void _commitWeightText({bool restoreText = true}) {
    final parsedWeight = parseWeightToKg(_weightTextController.text, _weightUnit);

    if (parsedWeight != null) {
      _weightKgValue = parsedWeight;
    }

    if (restoreText) {
      _weightTextController.text = formatWeightEditorValue(_weightKg, _weightUnit);
    }
  }

  void _toggleEditing() {
    FocusScope.of(context).unfocus();
    final wasEditing = _editing;

    setState(() {
      if (wasEditing) {
        _commitHeightText();
        _commitWeightText();
      } else {
        _heightTextController.text = formatHeightEditorValue(_heightCm, _heightUnit);
        _weightTextController.text = formatWeightEditorValue(_weightKg, _weightUnit);
      }

      _isEditing = !wasEditing;
    });
  }

  TextEditingController get _quoteTextController {
    return _quoteController ??= TextEditingController(text: widget.data.quote);
  }

  TextEditingController get _synopsisTextController {
    return _synopsisController ??= TextEditingController(text: widget.data.synopsis);
  }

  TextEditingController get _heightTextController {
    return _heightController ??= TextEditingController(
      text: formatHeightEditorValue(_heightCm, _heightUnit),
    );
  }

  TextEditingController get _weightTextController {
    return _weightController ??= TextEditingController(
      text: formatWeightEditorValue(_weightKg, _weightUnit),
    );
  }

  bool get _editing => _isEditing ?? false;

  DateTime get _birthday => _birthdayValue ??= DateTime(
    widget.data.birthYear,
    widget.data.birthMonth,
    widget.data.birthDay,
  );

  double get _heightCm => _heightCmValue ??= widget.data.heightCm;

  double get _weightKg => _weightKgValue ??= widget.data.weightKg;

  ZodiacSignData get _signData => zodiacSignFor(_birthday);

  CharacterDateEntries get _effectiveDateEntries {
    return _dateEntries ??= CharacterDateEntries.fromSeed(widget.data.seed);
  }

  CharacterDateEntry get _currentDateEntry => _effectiveDateEntries.forType(_dateType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.data.accent.withValues(alpha: 0.46),
                      Colors.white.withValues(alpha: 0.62),
                      const Color(0xFFF4F2F4).withValues(alpha: 0.74),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.68),
                    width: 0.75,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.03),
                                const Color(0x2AD8AFC2),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: const Radius.circular(16),
                              bottom: Radius.circular(_isExpanded ? 0 : 16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.data.accent.withValues(alpha: 0.94),
                                Colors.white.withValues(alpha: 0.92),
                                const Color(0xFFF2EED7).withValues(alpha: 0.84),
                              ],
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              CharacterAvatarTile(
                                accent: widget.data.accent,
                                avatarColor: widget.data.avatarColor,
                                icon: widget.data.icon,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _openCharacterPage,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.data.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.28),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            widget.data.alias,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.86),
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withValues(alpha: 0.16),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _toggleExpanded,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                                    child: AnimatedRotation(
                                      turns: _isExpanded ? 0.5 : 0,
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.black.withValues(alpha: 0.48),
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRect(
                          child: SizeTransition(
                            sizeFactor: _expandAnimation,
                            axisAlignment: -1,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ExpandedCharacterBody(
                                dateEntry: _currentDateEntry,
                                isEditing: _editing,
                                birthdayLabel: formatBirthdayLabel(_birthday.day, _birthday.month),
                                heightLabel: formatHeightLabel(_heightCm, _heightUnit),
                                weightLabel: formatWeightLabel(_weightKg, _weightUnit),
                                heightUnit: _heightUnit,
                                weightUnit: _weightUnit,
                                signData: _signData,
                                synopsisController: _synopsisTextController,
                                synopsisScrollController: _synopsisScrollController,
                                quoteController: _quoteTextController,
                                heightController: _heightTextController,
                                weightController: _weightTextController,
                                onCycleDateType: _cycleDateType,
                                onTapSign: _showSignDescription,
                                onTapAge: _showCharacterAge,
                                onTapBirthday: _selectBirthday,
                                onTapHeightUnit: _selectHeightUnit,
                                onTapWeightUnit: _selectWeightUnit,
                                onCommitHeight: () {
                                  setState(() {
                                    _commitHeightText();
                                  });
                                },
                                onCommitWeight: () {
                                  setState(() {
                                    _commitWeightText();
                                  });
                                },
                                onToggleEditing: _toggleEditing,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -4,
              top: -4,
              child: CharacterPinBadge(
                isActive: widget.isPinned,
                onTap: widget.onTogglePinned,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZodiacTraitPill extends StatelessWidget {
  final String label;

  const _ZodiacTraitPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEF3).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _HeightUnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeightUnitOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFFDF6EB8) : const Color(0xFF544959),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterBirthdayWheel extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onSelectedItemChanged;
  final List<Widget> children;

  const _CharacterBirthdayWheel({
    required this.label,
    required this.controller,
    required this.onSelectedItemChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.58),
                    width: 0.8,
                  ),
                ),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.light,
                  ),
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 36,
                    diameterRatio: 1.25,
                    useMagnifier: true,
                    magnification: 1.06,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: const Color(0x1CFFFFFF),
                    ),
                    onSelectedItemChanged: onSelectedItemChanged,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Info',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenSize = MediaQuery.of(context).size;
      const horizontalPadding = 12.0;
      const arrowSize = 12.0;
      const verticalGap = 8.0;
      const estimatedHeight = 110.0;
      final left = (anchorRect.center.dx - (width / 2))
          .clamp(
            horizontalPadding,
            screenSize.width - width - horizontalPadding,
          )
          .toDouble();
      final showAbove = anchorRect.bottom + estimatedHeight > screenSize.height - 24;
      final top = (showAbove
              ? anchorRect.top - estimatedHeight - arrowSize - verticalGap
              : anchorRect.bottom + verticalGap)
          .clamp(12.0, screenSize.height - estimatedHeight - 12.0)
          .toDouble();
      final pointerLeft = (anchorRect.center.dx - left - (arrowSize / 2))
          .clamp(
            18.0,
            width - 18.0,
          )
          .toDouble();

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 140),
                tween: Tween<double>(begin: 0.96, end: 1),
                builder: (context, scale, dialogChild) {
                  return Transform.scale(
                    scale: scale,
                    alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: dialogChild,
                  );
                },
                child: _AnchoredInfoBubble(
                  showAbove: showAbove,
                  pointerLeft: pointerLeft,
                  arrowSize: arrowSize,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _AnchoredInfoBubble extends StatelessWidget {
  final bool showAbove;
  final double pointerLeft;
  final double arrowSize;
  final Widget child;

  const _AnchoredInfoBubble({
    required this.showAbove,
    required this.pointerLeft,
    required this.arrowSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.86),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final arrow = Positioned(
      left: pointerLeft,
      top: showAbove ? null : 0,
      bottom: showAbove ? 0 : null,
      child: CustomPaint(
        size: Size(arrowSize, arrowSize),
        painter: _BubbleArrowPainter(
          color: Colors.white.withValues(alpha: 0.9),
          pointUp: !showAbove,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: showAbove
              ? EdgeInsets.only(bottom: arrowSize - 1)
              : EdgeInsets.only(top: arrowSize - 1),
          child: bubble,
        ),
        arrow,
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _BubbleArrowPainter({
    required this.color,
    required this.pointUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (pointUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}

class _CharacterPlaceholderPage extends StatelessWidget {
  final String title;

  const _CharacterPlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/FUNDO.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotaoVoltar(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pagina interna do personagem em construcao.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
