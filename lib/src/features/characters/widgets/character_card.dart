import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/anchored_info_bubble.dart';
import '../../../shared/widgets/buttons/botao_voltar.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_card_expanded_body.dart';
import 'character_profile_viewer_dialog.dart';
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

class _CharacterCardState extends State<CharacterCard>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;
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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _synopsisScrollController = ScrollController();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _synopsisScrollController.dispose();
    _heightController?.dispose();
    _weightController?.dispose();
    _quoteController?.dispose();
    _synopsisController?.dispose();
    _controller.dispose();
    _entranceController.dispose();
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
        builder: (_) => _CharacterNotebookPage(data: widget.data),
      ),
    );
  }

  Future<void> _openCharacterProfileViewer() async {
    if (widget.data.profileImage.bytes == null) {
      return;
    }

    await showCharacterProfileViewerDialog(
      context,
      characterName: widget.data.name,
      profileImage: widget.data.profileImage,
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
    final traitsLine = descriptionLines.length > 1
        ? descriptionLines.sublist(1).join(' ')
        : '';
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
        _heightTextController.text = formatHeightEditorValue(
          _heightCm,
          _heightUnit,
        );
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
        _weightTextController.text = formatWeightEditorValue(
          _weightKg,
          _weightUnit,
        );
      }
    });
  }

  Future<void> _selectBirthday() async {
    var tempMonth = _birthday.month;
    var tempDay = _birthday.day;
    final monthController = FixedExtentScrollController(
      initialItem: tempMonth - 1,
    );
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
                              for (
                                var index = 0;
                                index < monthLabels.length;
                                index += 1
                              )
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
                              for (
                                var day = 1;
                                day <= daysInMonth(tempMonth);
                                day += 1
                              )
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
    final parsedHeight = parseHeightToCm(
      _heightTextController.text,
      _heightUnit,
    );

    if (parsedHeight != null) {
      _heightCmValue = parsedHeight;
    }

    if (restoreText) {
      _heightTextController.text = formatHeightEditorValue(
        _heightCm,
        _heightUnit,
      );
    }
  }

  void _commitWeightText({bool restoreText = true}) {
    final parsedWeight = parseWeightToKg(
      _weightTextController.text,
      _weightUnit,
    );

    if (parsedWeight != null) {
      _weightKgValue = parsedWeight;
    }

    if (restoreText) {
      _weightTextController.text = formatWeightEditorValue(
        _weightKg,
        _weightUnit,
      );
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
        _heightTextController.text = formatHeightEditorValue(
          _heightCm,
          _heightUnit,
        );
        _weightTextController.text = formatWeightEditorValue(
          _weightKg,
          _weightUnit,
        );
      }

      _isEditing = !wasEditing;
    });
  }

  TextEditingController get _quoteTextController {
    return _quoteController ??= TextEditingController(text: widget.data.quote);
  }

  TextEditingController get _synopsisTextController {
    return _synopsisController ??= TextEditingController(
      text: widget.data.synopsis,
    );
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

  CharacterDateEntry get _currentDateEntry =>
      _effectiveDateEntries.forType(_dateType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _entranceAnimation,
        builder: (context, child) {
          final offsetY = (1 - _entranceAnimation.value) * 10;
          return Opacity(
            opacity: _entranceAnimation.value,
            child: Transform.translate(
              offset: Offset(0, offsetY),
              child: child,
            ),
          );
        },
        child: RepaintBoundary(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.accent.withValues(
                          alpha: _isExpanded ? 0.12 : 0.08,
                        ),
                        blurRadius: _isExpanded ? 12 : 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _isExpanded ? 0.08 : 0.05,
                        ),
                        blurRadius: _isExpanded ? 12 : 9,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildCharacterShellGradient(
                          widget.data.accent,
                          isExpanded: _isExpanded,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: _isExpanded ? 0.7 : 0.58,
                          ),
                          width: 0.85,
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.13),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.28, 0.56, 1.0],
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, _) {
                          final bottomRadius = Radius.circular(
                            16 * (1 - _expandAnimation.value),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CharacterHeader(
                                data: widget.data,
                                isExpanded: _isExpanded,
                                bottomRadius: bottomRadius,
                                onOpenCharacterPage: _openCharacterPage,
                                onOpenCharacterProfileViewer:
                                    _openCharacterProfileViewer,
                                onToggleExpand: _toggleExpanded,
                              ),
                              ClipRect(
                                child: SizeTransition(
                                  sizeFactor: _expandAnimation,
                                  axisAlignment: -1,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient:
                                              _buildCharacterDetailsGradient(
                                                widget.data.accent,
                                              ),
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white.withValues(
                                                alpha: 0.22,
                                              ),
                                              width: 0.7,
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: IgnorePointer(
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Colors.white.withValues(
                                                          alpha: 0.12,
                                                        ),
                                                        Colors.white.withValues(
                                                          alpha: 0.04,
                                                        ),
                                                        Colors.transparent,
                                                      ],
                                                      stops: const [
                                                        0.0,
                                                        0.24,
                                                        0.6,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ExpandedCharacterBody(
                                              accentColor: widget.data.accent,
                                              data: widget.data,
                                              dateEntry: _currentDateEntry,
                                              isEditing: _editing,
                                              birthdayLabel:
                                                  formatBirthdayLabel(
                                                    _birthday.day,
                                                    _birthday.month,
                                                  ),
                                              heightLabel: formatHeightLabel(
                                                _heightCm,
                                                _heightUnit,
                                              ),
                                              weightLabel: formatWeightLabel(
                                                _weightKg,
                                                _weightUnit,
                                              ),
                                              heightUnit: _heightUnit,
                                              weightUnit: _weightUnit,
                                              signData: _signData,
                                              synopsisController:
                                                  _synopsisTextController,
                                              synopsisScrollController:
                                                  _synopsisScrollController,
                                              quoteController:
                                                  _quoteTextController,
                                              heightController:
                                                  _heightTextController,
                                              weightController:
                                                  _weightTextController,
                                              onCycleDateType: _cycleDateType,
                                              onTapSign: _showSignDescription,
                                              onTapAge: _showCharacterAge,
                                              onTapBirthday: _selectBirthday,
                                              onTapHeightUnit:
                                                  _selectHeightUnit,
                                              onTapWeightUnit:
                                                  _selectWeightUnit,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: -4,
                child: CharacterPinBadge(
                  isActive: widget.isPinned,
                  onTap: widget.onTogglePinned,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterHeader extends StatelessWidget {
  final CharacterCardData data;
  final bool isExpanded;
  final Radius bottomRadius;
  final VoidCallback onOpenCharacterPage;
  final VoidCallback onOpenCharacterProfileViewer;
  final VoidCallback onToggleExpand;

  const _CharacterHeader({
    required this.data,
    required this.isExpanded,
    required this.bottomRadius,
    required this.onOpenCharacterPage,
    required this.onOpenCharacterProfileViewer,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: bottomRadius,
        ),
        border: Border(
          bottom: BorderSide(
            color: isExpanded
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            width: 0.7,
          ),
        ),
      ),
      child: SizedBox(
        height: characterProfileTileHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(16),
                    bottom: bottomRadius,
                  ),
                  gradient: _buildCharacterHeaderGradient(
                    data.accent,
                    data.avatarColor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: CharacterAvatarTile(
                accent: data.accent,
                avatarColor: data.avatarColor,
                profileImage: data.profileImage,
                icon: data.icon,
                isExpanded: isExpanded,
                onTap: data.profileImage.bytes == null
                    ? null
                    : onOpenCharacterProfileViewer,
              ),
            ),
            Positioned.fill(
              left: characterProfileTileWidth,
              right: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenCharacterPage,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isExpanded
                                  ? const Color(0xFFF9F6FA)
                                  : const Color(0xFFF7F4F8),
                              fontSize: 18.5,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.52),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            data.alias,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 26,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: Radius.circular(bottomRadius.x),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.92),
                        size: 26,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

  const _ZodiacTraitPill({required this.label});

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
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFFDF6EB8)
                      : const Color(0xFF544959),
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
                  data: const CupertinoThemeData(brightness: Brightness.light),
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
  return showAnchoredInfoBubbleDialog(
    context: context,
    anchorRect: anchorRect,
    child: child,
    width: width,
    estimatedHeight: 110,
    bubbleBuilder:
        (
          context, {
          required showAbove,
          required pointerLeft,
          required arrowSize,
          required child,
        }) {
          return AnchoredInfoBubbleFrame(
            showAbove: showAbove,
            pointerLeft: pointerLeft,
            arrowSize: arrowSize,
            borderRadius: BorderRadius.circular(18),
            blurSigma: 10,
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
            arrowColor: Colors.white.withValues(alpha: 0.9),
            child: child,
          );
        },
  );
}

// ignore: unused_element
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
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotaoVoltar(onPressed: () => Navigator.of(context).pop()),
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
                    'Página interna do personagem em construção.',
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

enum _CharacterNotebookTab { geral, psique, historia, notas, design }

class _CharacterNotebookPage extends StatefulWidget {
  final CharacterCardData data;

  const _CharacterNotebookPage({required this.data});

  @override
  State<_CharacterNotebookPage> createState() => _CharacterNotebookPageState();
}

class _CharacterNotebookPageState extends State<_CharacterNotebookPage> {
  static const Map<_CharacterNotebookTab, _CharacterNotebookTabMeta> _tabs = {
    _CharacterNotebookTab.geral: _CharacterNotebookTabMeta(
      label: 'Geral',
      icon: Icons.person_outline_rounded,
    ),
    _CharacterNotebookTab.psique: _CharacterNotebookTabMeta(
      label: 'Psique',
      icon: Icons.psychology_rounded,
    ),
    _CharacterNotebookTab.historia: _CharacterNotebookTabMeta(
      label: 'História',
      icon: Icons.history_edu_rounded,
    ),
    _CharacterNotebookTab.notas: _CharacterNotebookTabMeta(
      label: 'Notas',
      icon: Icons.sticky_note_2_rounded,
    ),
    _CharacterNotebookTab.design: _CharacterNotebookTabMeta(
      label: 'Design',
      icon: Icons.palette_outlined,
    ),
  };

  _CharacterNotebookTab _activeTab = _CharacterNotebookTab.geral;

  void _setTab(_CharacterNotebookTab tab) {
    if (_activeTab == tab) return;
    setState(() => _activeTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.72, -0.88),
                    radius: 1.25,
                    colors: [
                      data.accent.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CharacterNotebookHeader(data: data),
                  const SizedBox(height: 12),
                  _CharacterStickyTabs(
                    activeTab: _activeTab,
                    accentColor: data.accent,
                    onTabSelected: _setTab,
                    tabs: _tabs,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [...previousChildren, ?currentChild],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_activeTab),
                        child: _buildTabContent(data),
                      ),
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

  Widget _buildTabContent(CharacterCardData data) {
    return switch (_activeTab) {
      _CharacterNotebookTab.geral => _CharacterGeneralTab(data: data),
      _CharacterNotebookTab.psique => _CharacterPlaceholderTab(
        data: data,
        title: 'Psique',
        subtitle: 'Mapa emocional, impulsos e contradições.',
        icon: Icons.psychology_rounded,
      ),
      _CharacterNotebookTab.historia => _CharacterPlaceholderTab(
        data: data,
        title: 'História',
        subtitle: 'Linha do tempo, origem e viradas importantes.',
        icon: Icons.history_edu_rounded,
      ),
      _CharacterNotebookTab.notas => _CharacterPlaceholderTab(
        data: data,
        title: 'Notas',
        subtitle: 'Observações rápidas, rastros e pendências.',
        icon: Icons.sticky_note_2_rounded,
      ),
      _CharacterNotebookTab.design => _CharacterPlaceholderTab(
        data: data,
        title: 'Design',
        subtitle: 'Paleta, referências visuais e direção estética.',
        icon: Icons.palette_outlined,
      ),
    };
  }
}

class _CharacterNotebookTabMeta {
  final String label;
  final IconData icon;

  const _CharacterNotebookTabMeta({required this.label, required this.icon});
}

class _CharacterNotebookHeader extends StatelessWidget {
  final CharacterCardData data;

  const _CharacterNotebookHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.62),
                data.accent.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.32),
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.82),
              width: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CharacterAvatarTile(
                accent: data.accent,
                avatarColor: data.avatarColor,
                profileImage: data.profileImage,
                icon: data.icon,
                isExpanded: true,
                onTap: null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2C262C),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.alias.isEmpty ? 'Sem vulgo' : data.alias,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.56),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _NotebookInfoChip(
                          icon: Icons.star_rounded,
                          label: data.relevanceTag.isEmpty
                              ? 'Relevância não definida'
                              : data.relevanceTag,
                          accentColor: data.accent,
                        ),
                        if (data.genderTag.isNotEmpty)
                          _NotebookInfoChip(
                            icon: Icons.wc_rounded,
                            label: data.genderTag,
                            accentColor: data.accent,
                          ),
                        if (data.functionTag.isNotEmpty)
                          _NotebookInfoChip(
                            icon: Icons.badge_outlined,
                            label: data.functionTag,
                            accentColor: data.accent,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFF2C262C),
                tooltip: 'Fechar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _NotebookInfoChip({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.24),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF544959)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C262C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterStickyTabs extends StatelessWidget {
  final _CharacterNotebookTab activeTab;
  final Color accentColor;
  final ValueChanged<_CharacterNotebookTab> onTabSelected;
  final Map<_CharacterNotebookTab, _CharacterNotebookTabMeta> tabs;

  const _CharacterStickyTabs({
    required this.activeTab,
    required this.accentColor,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFF8F2).withValues(alpha: 0.92),
                Colors.white.withValues(alpha: 0.62),
                accentColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.86),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              for (final entry in tabs.entries) ...[
                Expanded(
                  child: _CharacterStickyTabButton(
                    label: entry.value.label,
                    icon: entry.value.icon,
                    isActive: activeTab == entry.key,
                    accentColor: accentColor,
                    onTap: () => onTabSelected(entry.key),
                  ),
                ),
                if (entry.key != tabs.keys.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterStickyTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _CharacterStickyTabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.62)
                : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? accentColor.withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.58),
              width: 0.8,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: isActive
                    ? const Color(0xFF2C262C)
                    : const Color(0xFF544959).withValues(alpha: 0.78),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF2C262C)
                      : const Color(0xFF544959).withValues(alpha: 0.82),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookSectionCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _NotebookSectionCard({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF2C262C), size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF2C262C),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.54),
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterGeneralTab extends StatelessWidget {
  final CharacterCardData data;

  const _CharacterGeneralTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NotebookSectionCard(
            accentColor: data.accent,
            title: 'Resumo geral',
            subtitle: 'Ponto de entrada da ficha do personagem.',
            icon: Icons.dashboard_customize_rounded,
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nome',
                  value: data.name,
                ),
                _DetailRow(
                  icon: Icons.alternate_email_rounded,
                  label: 'Vulgo',
                  value: data.alias.isEmpty ? 'Sem vulgo' : data.alias,
                ),
                _DetailRow(
                  icon: Icons.star_rounded,
                  label: 'Relevância',
                  value: data.relevanceTag.isEmpty
                      ? 'Não definida'
                      : data.relevanceTag,
                ),
                _DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Função',
                  value: data.functionTag.isEmpty
                      ? 'Não definida'
                      : data.functionTag,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _NotebookSectionCard(
            accentColor: data.accent,
            title: 'Marca visual',
            subtitle: 'A imagem atual e a base cromática do personagem.',
            icon: Icons.auto_awesome_rounded,
            child: Row(
              children: [
                CharacterAvatarTile(
                  accent: data.accent,
                  avatarColor: data.avatarColor,
                  profileImage: data.profileImage,
                  icon: data.icon,
                  isExpanded: true,
                  onTap: null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cor acento',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.52),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ColorSampleRow(
                        accentColor: data.accent,
                        avatarColor: data.avatarColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.profileImage.bytes == null
                            ? 'Sem imagem de perfil adicionada.'
                            : 'Imagem de perfil disponível para visualização.',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.58),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _NotebookSectionCard(
            accentColor: data.accent,
            title: 'Campo livre',
            subtitle: 'Espaço para frase, sinopse curta ou observação central.',
            icon: Icons.chat_bubble_outline_rounded,
            child: Text(
              data.motto.isEmpty
                  ? 'Nenhuma frase de destaque definida ainda.'
                  : data.motto,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.62),
                fontSize: 13,
                height: 1.45,
                fontStyle: data.motto.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPlaceholderTab extends StatelessWidget {
  final CharacterCardData data;
  final String title;
  final String subtitle;
  final IconData icon;

  const _CharacterPlaceholderTab({
    required this.data,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NotebookSectionCard(
            accentColor: data.accent,
            title: title,
            subtitle: subtitle,
            icon: icon,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estrutura inicial pronta.',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.66),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Essa aba já existe na navegação e pode receber os campos específicos depois, sem quebrar a identidade visual da ficha.',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.56),
                    fontSize: 12.5,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF544959)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2C262C),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSampleRow extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;

  const _ColorSampleRow({required this.accentColor, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ColorSample(color: accentColor, label: 'Acento'),
        const SizedBox(width: 8),
        _ColorSample(color: avatarColor, label: 'Avatar'),
      ],
    );
  }
}

class _ColorSample extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSample({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34), width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C262C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

LinearGradient _buildCharacterShellGradient(
  Color accentColor, {
  required bool isExpanded,
}) {
  final leading = Color.alphaBlend(
    accentColor.withValues(alpha: isExpanded ? 0.16 : 0.08),
    Colors.white.withValues(alpha: 0.84),
  );
  final center = Colors.white.withValues(alpha: isExpanded ? 0.82 : 0.76);
  final trailing = Color.alphaBlend(
    _lightenCharacterColor(
      accentColor,
      0.22,
    ).withValues(alpha: isExpanded ? 0.18 : 0.1),
    const Color(0xFFF8F2F6).withValues(alpha: 0.82),
  );

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leading, center, trailing],
    stops: const [0.0, 0.48, 1.0],
  );
}

LinearGradient _buildCharacterHeaderGradient(Color accent, Color avatarColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        accent.withValues(alpha: 0.78),
        const Color(0xFF8A7485).withValues(alpha: 0.88),
      ),
      Color.alphaBlend(
        avatarColor.withValues(alpha: 0.2),
        Colors.white.withValues(alpha: 0.18),
      ),
      Color.alphaBlend(
        _lightenCharacterColor(accent, 0.18).withValues(alpha: 0.92),
        Colors.white.withValues(alpha: 0.16),
      ),
    ],
    stops: const [0.0, 0.58, 1.0],
  );
}

LinearGradient _buildCharacterDetailsGradient(Color accentColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor.withValues(alpha: 0.12),
      Colors.white.withValues(alpha: 0.5),
      const Color(0xFFF6F1F4).withValues(alpha: 0.36),
    ],
    stops: const [0.0, 0.46, 1.0],
  );
}

Color _lightenCharacterColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
