import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../models/characters_models.dart';
import '../../projects/controllers/create_project_dialog_controller.dart';
import '../../projects/controllers/create_project_dialog_image_controller.dart';
import '../../projects/models/project_image_data.dart';
import '../../projects/models/project_tag_data.dart';
import '../../projects/widgets/create_project_dialog_image_widgets.dart';
import '../../projects/widgets/create_project_dialog_sections.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';
import '../../projects/widgets/project_image_transform_view.dart';
import '../utils/characters_utils.dart';
import 'character_card_visuals.dart';
import 'character_fields.dart';

Future<CreateCharacterDraft?> showCreateCharacterDialog(BuildContext context) {
  return showDialog<CreateCharacterDraft>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _CreateCharacterDialog(),
  );
}

class CreateCharacterDraft {
  final String name;
  final String synopsis;
  final String motto;
  final String alias;
  final String formationsAndOccupations;
  final String titles;
  final int birthDay;
  final int birthMonth;
  final double weightKg;
  final double heightCm;
  final String genderTag;
  final String sexualityTag;
  final String ethnicityTag;
  final String functionTag;
  final String relevanceTag;
  final Set<CharacterProfileFieldId> visibleProfileFields;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData profileImage;

  const CreateCharacterDraft({
    required this.name,
    required this.synopsis,
    required this.motto,
    required this.alias,
    required this.formationsAndOccupations,
    required this.titles,
    required this.birthDay,
    required this.birthMonth,
    required this.weightKg,
    required this.heightCm,
    required this.genderTag,
    required this.sexualityTag,
    required this.ethnicityTag,
    required this.functionTag,
    required this.relevanceTag,
    required this.visibleProfileFields,
    required this.coverColor,
    required this.accentColor,
    required this.profileImage,
  });
}

const double _characterDialogPrefixWidth = 124;
const double _characterDialogCompactPrefixWidth = 108;
const double _characterDialogSingleLineFieldHeight = 58;
const double _characterDialogNameFieldHeight = 70;
const double _characterDialogMeasureControlHeight = 50;
const double _characterDialogMeasureFieldWidth = 150;
const double _characterDialogMeasureUnitWidth = 44;
const double _characterDialogMeasureLayoutBreakpoint = 414;

class _CreateCharacterDialog extends StatefulWidget {
  const _CreateCharacterDialog();

  @override
  State<_CreateCharacterDialog> createState() => _CreateCharacterDialogState();
}

class _CreateCharacterDialogState extends State<_CreateCharacterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _mottoController;
  late final TextEditingController _aliasController;
  late final TextEditingController _formationsController;
  late final TextEditingController _titlesController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late DateTime _birthdayValue;
  late HeightUnit _heightUnit;
  late WeightUnit _weightUnit;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late final CreateProjectDialogController _dialogController;
  late final CreateProjectDialogImageController _imageController;
  late final Set<CharacterProfileFieldId> _visibleProfileFields;
  late List<ProjectTagData> _genderTags;
  late List<ProjectTagData> _sexualityTags;
  late List<ProjectTagData> _ethnicityTags;
  List<ProjectTagData>? _functionTags;
  late List<_RelevanceParameterConfig> _relevanceParameters;
  late List<_RelevanceCategoryConfig> _relevanceCategories;
  late Map<String, double> _relevanceValues;
  late Map<String, double> _relevanceWeights;
  bool _detailsExpanded = false;
  bool? _showRequiredTagErrors = false;
  String _selectedGenderTag = '';
  String _selectedSexualityTag = '';
  String _selectedEthnicityTag = '';
  String? _selectedFunctionTag = '';
  String _selectedRelevanceTag = '';

  static const double _synopsisMaxHeight = 196;

  static const TextStyle _synopsisTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF3A3339),
    height: 1.35,
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _synopsisController = TextEditingController();
    _mottoController = TextEditingController();
    _aliasController = TextEditingController();
    _formationsController = TextEditingController();
    _titlesController = TextEditingController();
    _birthdayValue = DateTime(2000, 1, 1);
    _heightUnit = HeightUnit.centimeters;
    _weightUnit = WeightUnit.kilograms;
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _synopsisController.addListener(_refresh);
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _dialogController = CreateProjectDialogController(availableTags: const []);
    _dialogController.setActiveColorTarget(
      CreateProjectDialogColorTarget.accent,
    );
    _imageController = CreateProjectDialogImageController();
    _visibleProfileFields = <CharacterProfileFieldId>{
      CharacterProfileFieldId.motto,
      CharacterProfileFieldId.weight,
      CharacterProfileFieldId.height,
    };
    _genderTags = _seedCharacterTags(_CharacterTagKind.gender);
    _sexualityTags = _seedCharacterTags(_CharacterTagKind.sexuality);
    _ethnicityTags = _seedCharacterTags(_CharacterTagKind.ethnicity);
    _functionTags = _seedCharacterTags(_CharacterTagKind.function);
    _relevanceParameters = _defaultRelevanceParameters();
    _relevanceCategories = _defaultRelevanceCategories();
    _relevanceValues = {
      for (final parameter in _relevanceParameters) parameter.id: 0,
    };
    _relevanceWeights = {
      for (final parameter in _relevanceParameters)
        parameter.id: parameter.weight,
    };
    _selectedRelevanceTag = _relevanceCategoryForScore(0).name;
    _dialogController.addListener(_refresh);
    _imageController.addListener(_refresh);
  }

  @override
  void dispose() {
    _imageController.removeListener(_refresh);
    _imageController.dispose();
    _dialogController.removeListener(_refresh);
    _dialogController.dispose();
    _synopsisController.removeListener(_refresh);
    _nameController.dispose();
    _synopsisController.dispose();
    _mottoController.dispose();
    _aliasController.dispose();
    _formationsController.dispose();
    _titlesController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _contentScrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  double _calculateSynopsisHeight(double maxWidth) {
    final text = _synopsisController.text.trim().isEmpty
        ? synopsisPlaceholderText
        : _synopsisController.text;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _synopsisTextStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    textPainter.layout(maxWidth: maxWidth - 16);
    const verticalPadding = 16.0;
    final estimatedHeight = textPainter.size.height + verticalPadding;
    final minimumHeight =
        (_synopsisTextStyle.fontSize! * _synopsisTextStyle.height!) +
        verticalPadding;

    return estimatedHeight.clamp(minimumHeight, _synopsisMaxHeight);
  }

  void _submit() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    final requiredTagsAreValid =
        _selectedGenderTag.trim().isNotEmpty &&
        _selectedRelevanceTag.trim().isNotEmpty;

    setState(() {
      _showRequiredTagErrors = !requiredTagsAreValid;
    });

    if (!formIsValid || !requiredTagsAreValid) {
      return;
    }

    Navigator.of(context).pop(
      CreateCharacterDraft(
        name: _nameController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        motto: _mottoController.text.trim(),
        alias: _aliasController.text.trim(),
        formationsAndOccupations: _formationsController.text.trim(),
        titles: _titlesController.text.trim(),
        birthDay: _birthdayValue.day,
        birthMonth: _birthdayValue.month,
        weightKg: parseWeightToKg(_weightController.text, _weightUnit) ?? 70,
        heightCm: parseHeightToCm(_heightController.text, _heightUnit) ?? 170,
        genderTag: _selectedGenderTag,
        sexualityTag: _selectedSexualityTag,
        ethnicityTag: _selectedEthnicityTag,
        functionTag: _selectedFunctionTag ?? '',
        relevanceTag: _selectedRelevanceTag,
        visibleProfileFields: _visibleProfileFields.toSet(),
        coverColor: _dialogController.coverColor,
        accentColor: _dialogController.accentColor,
        profileImage: _imageController.coverImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 470,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.98),
                const Color(0xFFF9EEF4).withValues(alpha: 0.97),
                const Color(0xFFF1DCE8).withValues(alpha: 0.93),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportHeight = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : MediaQuery.sizeOf(context).height - 96;

                return Form(
                  key: _formKey,
                  child: SynopsisScrollBox(
                    controller: _contentScrollController,
                    childIsScrollable: true,
                    height: viewportHeight,
                    contentPadding: const EdgeInsets.only(right: 8),
                    child: SingleChildScrollView(
                      controller: _contentScrollController,
                      physics: const BouncingScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CreateCharacterDialogHeader(
                            onClose: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.94),
                                  const Color(
                                    0xFFDFC7D6,
                                  ).withValues(alpha: 0.82),
                                  Colors.white.withValues(alpha: 0.28),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _CreateCharacterNameField(
                            nameController: _nameController,
                            aliasController: _aliasController,
                            focusedColor: _dialogController.accentColor,
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CreateProjectDialogSynopsisField(
                                controller: _synopsisController,
                                scrollController: _synopsisScrollController,
                                textStyle: _synopsisTextStyle,
                                height: _calculateSynopsisHeight(
                                  constraints.maxWidth,
                                ),
                                focusedBorderColor:
                                    _dialogController.accentColor,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _CharacterRelevanceSelectorField(
                            value: _selectedRelevanceTag,
                            selectedColor: _relevanceCategoryForScore(
                              _calculateRelevanceScore(),
                            ).color,
                            accentColor: _dialogController.accentColor,
                            categories: _relevanceCategories,
                            showError:
                                _showRequiredTagErrors == true &&
                                _selectedRelevanceTag.trim().isEmpty,
                            score: _calculateRelevanceScore(),
                            onTap: _openRelevanceSelector,
                          ),
                          const SizedBox(height: 10),
                          _CharacterBirthdayDraftField(
                            label: 'Aniversario',
                            valueLabel: formatBirthdayLabel(
                              _birthdayValue.day,
                              _birthdayValue.month,
                            ),
                            signData: zodiacSignFor(_birthdayValue),
                            accentColor: _dialogController.accentColor,
                            onTap: _selectBirthday,
                            onTapSign: () => _openBirthdaySignSheet(
                              zodiacSignFor(_birthdayValue),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _CharacterIdentityTagGrid(
                            genderLabel: _selectedGenderTag,
                            genderColor: _tagColorFor(
                              _CharacterTagKind.gender,
                              _selectedGenderTag,
                            ),
                            sexualityLabel: _selectedSexualityTag,
                            sexualityColor: _tagColorFor(
                              _CharacterTagKind.sexuality,
                              _selectedSexualityTag,
                            ),
                            ethnicityLabel: _selectedEthnicityTag,
                            ethnicityColor: _tagColorFor(
                              _CharacterTagKind.ethnicity,
                              _selectedEthnicityTag,
                            ),
                            functionLabel: _selectedFunctionTag ?? '',
                            functionColor: _tagColorFor(
                              _CharacterTagKind.function,
                              _selectedFunctionTag ?? '',
                            ),
                            accentColor: _dialogController.accentColor,
                            showRequiredErrors: _showRequiredTagErrors == true,
                            onPickGenderTag: () =>
                                _openTagSelector(_CharacterTagKind.gender),
                            onPickSexualityTag: () =>
                                _openTagSelector(_CharacterTagKind.sexuality),
                            onPickEthnicityTag: () =>
                                _openTagSelector(_CharacterTagKind.ethnicity),
                            onPickFunctionTag: () =>
                                _openTagSelector(_CharacterTagKind.function),
                          ),
                          const SizedBox(height: 12),
                          _CharacterMetadataSection(
                            accentColor: _dialogController.accentColor,
                            mottoController: _mottoController,
                            formationsController: _formationsController,
                            titlesController: _titlesController,
                            weightController: _weightController,
                            heightController: _heightController,
                            heightUnitLabel: heightUnitCompactLabel(
                              _heightUnit,
                            ),
                            weightUnitLabel: weightUnitCompactLabel(
                              _weightUnit,
                            ),
                            onPickHeightUnit: _selectHeightUnit,
                            onPickWeightUnit: _selectWeightUnit,
                            isExpanded: _detailsExpanded,
                            onToggleExpanded: () {
                              setState(() {
                                _detailsExpanded = !_detailsExpanded;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _CharacterProfilePhotoSection(
                            imageController: _imageController,
                            coverColor: _dialogController.coverColor,
                            accentColor: _dialogController.accentColor,
                          ),
                          const SizedBox(height: 12),
                          CreateProjectDialogColorSection(
                            controller: _dialogController,
                          ),
                          const SizedBox(height: 12),
                          _CreateCharacterActionsRow(
                            onCancel: () => Navigator.of(context).pop(),
                            onSubmit: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required Color focusedColor,
  }) {
    return _buildCharacterDialogFieldDecoration(
      hintText: hintText,
      focusedColor: focusedColor,
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
                _DialogSelectOption(
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
      final currentText = _heightController.text.trim();
      final resolvedHeight = currentText.isEmpty
          ? null
          : parseHeightToCm(currentText, _heightUnit);
      _heightUnit = selectedUnit;
      if (resolvedHeight != null) {
        _heightController.text = formatHeightEditorValue(
          resolvedHeight,
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
                _DialogSelectOption(
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
      final currentText = _weightController.text.trim();
      final resolvedWeight = currentText.isEmpty
          ? null
          : parseWeightToKg(currentText, _weightUnit);
      _weightUnit = selectedUnit;
      if (resolvedWeight != null) {
        _weightController.text = formatWeightEditorValue(
          resolvedWeight,
          _weightUnit,
        );
      }
    });
  }

  Future<void> _selectBirthday() async {
    var tempMonth = _birthdayValue.month;
    var tempDay = _birthdayValue.day;
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
                        ).pop(DateTime(2000, tempMonth, tempDay));
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

  Future<void> _openBirthdaySignSheet(ZodiacSignData currentSign) async {
    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final accent = _dialogController.accentColor;
        final signs = _allZodiacSigns();
        final signDescriptionLines = currentSign.description.split('\n');
        final signDateRange = signDescriptionLines.first.trim();
        final signTraits = signDescriptionLines.skip(1).join('\n').trim();

        return ProjectBottomSheetFrame(
          title: '${currentSign.symbol} ${currentSign.name}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: _darkenCharacterDialogColor(accent, 0.16),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Período',
                          style: TextStyle(
                            color: Color(0xFF3A3339),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              signDateRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _darkenCharacterDialogColor(
                                  accent,
                                  0.22,
                                ),
                                fontSize: 11.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (signTraits.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        signTraits,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.64),
                          fontSize: 12,
                          height: 1.35,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.casino_rounded,
                          size: 16,
                          color: _darkenCharacterDialogColor(accent, 0.16),
                        ),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: Text(
                            'Sortear aniversario por signo',
                            style: TextStyle(
                              color: Color(0xFF3A3339),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toque em um signo para gerar uma data aleatória dentro do período.',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.52),
                        fontSize: 11,
                        height: 1.25,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 8.0;
                        final columnCount = constraints.maxWidth < 340 ? 2 : 3;
                        final optionWidth =
                            (constraints.maxWidth -
                                (spacing * (columnCount - 1))) /
                            columnCount;

                        return Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final sign in signs)
                              SizedBox(
                                width: optionWidth,
                                child: _ZodiacRandomOption(
                                  signData: sign,
                                  accentColor: accent,
                                  isSelected: sign.symbol == currentSign.symbol,
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pop(_randomBirthdayForSign(sign));
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _birthdayValue = selectedDate;
    });
  }

  Future<void> _openTagSelector(_CharacterTagKind kind) async {
    final inputController = TextEditingController();
    final selectedLabel = _selectedTagFor(kind);
    final isRequired = _isRequiredTagKind(kind);

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tags = _knownTagsFor(kind);
            final accent = _dialogController.accentColor;

            return ProjectBottomSheetFrame(
              title: '${_tagKindTitle(kind)}${isRequired ? ' *' : ''}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _tagKindIcon(kind),
                          size: 16,
                          color: _darkenCharacterDialogColor(accent, 0.16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tagKindDescription(kind),
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.58),
                              fontSize: 12,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    child: tags.isEmpty
                        ? _CharacterTagEmptyState(accentColor: accent)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              const spacing = 8.0;
                              final columnCount = constraints.maxWidth < 320
                                  ? 2
                                  : 3;
                              final optionWidth =
                                  (constraints.maxWidth -
                                      (spacing * (columnCount - 1))) /
                                  columnCount;

                              return Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  for (final tag in tags)
                                    SizedBox(
                                      width: optionWidth,
                                      child: _CharacterTagOptionButton(
                                        tag: tag,
                                        isSelected: tag.label == selectedLabel,
                                        onTap: () => Navigator.of(
                                          context,
                                        ).pop(tag.label),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: TextField(
                              controller: inputController,
                              textInputAction: TextInputAction.done,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: _buildInputDecoration(
                                hintText: 'Adicionar nova opção',
                                focusedColor: accent,
                              ),
                              onSubmitted: (value) {
                                final added = _addTagFor(kind, value);
                                if (added != null) {
                                  Navigator.of(context).pop(added);
                                }
                              },
                              onChanged: (_) => setModalState(() {}),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: FilledButton(
                            onPressed: inputController.text.trim().isEmpty
                                ? null
                                : () {
                                    final added = _addTagFor(
                                      kind,
                                      inputController.text,
                                    );
                                    if (added != null) {
                                      Navigator.of(context).pop(added);
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.white.withValues(
                                alpha: 0.42,
                              ),
                              disabledForegroundColor: Colors.black.withValues(
                                alpha: 0.26,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.add_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedLabel.isNotEmpty && !isRequired) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(''),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7D7179),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Limpar seleção'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    inputController.dispose();

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _setSelectedTag(kind, result);
    });
  }

  Future<void> _openRelevanceSelector() async {
    var tempParameters = List<_RelevanceParameterConfig>.from(
      _relevanceParameters,
    );
    var editingParameterIds = <String>{};
    var tempValues = Map<String, double>.from(_relevanceValues);
    var tempWeights = Map<String, double>.from(_relevanceWeights);

    final result = await showDialog<_RelevanceSelectionResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final accent = _dialogController.accentColor;
            final screenSize = MediaQuery.sizeOf(context);
            final score = _calculateRelevanceScore(
              values: tempValues,
              weights: tempWeights,
              parameters: tempParameters,
            );
            final category = _relevanceCategoryForScore(score);

            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 22,
              ),
              child: Center(
                child: SizedBox(
                  width: min(screenSize.width - 28, 620),
                  child: _CharacterCenteredMenuFrame(
                    title: 'Relevancia narrativa',
                    child: SizedBox(
                      height: min(screenSize.height * 0.78, 620),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RelevanceScoreSummary(
                            score: score,
                            category: category,
                            categories: _relevanceCategories,
                            accentColor: accent,
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                parent: ClampingScrollPhysics(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _RelevanceFormulaNote(accentColor: accent),
                                  const SizedBox(height: 10),
                                  for (final parameter in tempParameters) ...[
                                    _RelevanceParameterControl(
                                      parameter: parameter,
                                      value: tempValues[parameter.id] ?? 0,
                                      weight:
                                          tempWeights[parameter.id] ??
                                          parameter.weight,
                                      canRemove: tempParameters.length > 1,
                                      isEditing: editingParameterIds.contains(
                                        parameter.id,
                                      ),
                                      onEdit: () {
                                        setModalState(() {
                                          editingParameterIds = {
                                            ...editingParameterIds,
                                          };
                                          if (!editingParameterIds.add(
                                            parameter.id,
                                          )) {
                                            editingParameterIds.remove(
                                              parameter.id,
                                            );
                                          }
                                        });
                                      },
                                      onNameChanged: (value) {
                                        setModalState(() {
                                          tempParameters = [
                                            for (final item in tempParameters)
                                              item.id == parameter.id
                                                  ? item.copyWith(name: value)
                                                  : item,
                                          ];
                                        });
                                      },
                                      onDescriptionChanged: (value) {
                                        setModalState(() {
                                          tempParameters = [
                                            for (final item in tempParameters)
                                              item.id == parameter.id
                                                  ? item.copyWith(
                                                      description: value,
                                                    )
                                                  : item,
                                          ];
                                        });
                                      },
                                      onRemove: () {
                                        if (tempParameters.length <= 1) {
                                          return;
                                        }
                                        setModalState(() {
                                          tempParameters = tempParameters
                                              .where(
                                                (item) =>
                                                    item.id != parameter.id,
                                              )
                                              .toList();
                                          tempValues = {...tempValues}
                                            ..remove(parameter.id);
                                          tempWeights = {...tempWeights}
                                            ..remove(parameter.id);
                                          editingParameterIds = {
                                            ...editingParameterIds,
                                          }..remove(parameter.id);
                                          tempWeights =
                                              _normalizeRelevanceWeights(
                                                parameters: tempParameters,
                                                weights: tempWeights,
                                              );
                                        });
                                      },
                                      onValueChanged: (value) {
                                        setModalState(() {
                                          tempValues = {
                                            ...tempValues,
                                            parameter.id: value,
                                          };
                                        });
                                      },
                                      onWeightChanged: (value) {
                                        setModalState(() {
                                          tempWeights =
                                              _redistributeRelevanceWeights(
                                                parameters: tempParameters,
                                                weights: tempWeights,
                                                changedId: parameter.id,
                                                requestedWeight: value,
                                              );
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  _AddRelevanceParameterButton(
                                    onTap: () {
                                      final newParameter =
                                          _createBlankRelevanceParameter(
                                            tempParameters,
                                          );
                                      setModalState(() {
                                        tempParameters = [
                                          ...tempParameters,
                                          newParameter,
                                        ];
                                        tempValues = {
                                          ...tempValues,
                                          newParameter.id: 0,
                                        };
                                        editingParameterIds = {
                                          ...editingParameterIds,
                                          newParameter.id,
                                        };
                                        tempWeights =
                                            _redistributeRelevanceWeights(
                                              parameters: tempParameters,
                                              weights: {
                                                ...tempWeights,
                                                newParameter.id:
                                                    newParameter.weight,
                                              },
                                              changedId: newParameter.id,
                                              requestedWeight:
                                                  newParameter.weight,
                                            );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF514752),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                      _RelevanceSelectionResult(
                                        values: tempValues,
                                        weights: tempWeights,
                                        parameters: tempParameters,
                                        categoryName: category.name,
                                      ),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Aplicar'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _relevanceParameters = result.parameters;
      _relevanceValues = result.values;
      _relevanceWeights = result.weights;
      _selectedRelevanceTag = result.categoryName;
    });
  }

  double _calculateRelevanceScore({
    Map<String, double>? values,
    Map<String, double>? weights,
    List<_RelevanceParameterConfig>? parameters,
  }) {
    final activeValues = values ?? _relevanceValues;
    final activeWeights = weights ?? _relevanceWeights;
    final activeParameters = parameters ?? _relevanceParameters;
    var weightedTotal = 0.0;
    var weightTotal = 0.0;
    for (final parameter in activeParameters) {
      final weight = activeWeights[parameter.id] ?? parameter.weight;
      weightedTotal += (activeValues[parameter.id] ?? 0) * weight;
      weightTotal += weight;
    }

    if (weightTotal <= 0) {
      return 0;
    }

    return (weightedTotal / weightTotal).clamp(0, 10);
  }

  Map<String, double> _redistributeRelevanceWeights({
    List<_RelevanceParameterConfig>? parameters,
    required Map<String, double> weights,
    required String changedId,
    required double requestedWeight,
  }) {
    const totalWeightUnits = 20;
    final activeParameters = parameters ?? _relevanceParameters;
    final ids = [for (final parameter in activeParameters) parameter.id];
    final current = {
      for (final parameter in activeParameters)
        parameter.id: weights[parameter.id] ?? parameter.weight,
    };
    final changedUnits = (requestedWeight.clamp(0.0, 1.0) * totalWeightUnits)
        .round()
        .clamp(0, totalWeightUnits);
    final remainingUnits = totalWeightUnits - changedUnits;
    final otherIds = ids.where((id) => id != changedId).toList();
    final otherCurrentTotal = otherIds.fold<double>(
      0,
      (total, id) => total + (current[id] ?? 0),
    );

    final adjustedUnits = <String, int>{changedId: changedUnits};
    if (otherIds.isEmpty) {
      return {changedId: changedUnits / totalWeightUnits};
    }

    if (remainingUnits == 0) {
      for (final id in otherIds) {
        adjustedUnits[id] = 0;
      }
      return {
        for (final entry in adjustedUnits.entries)
          entry.key: entry.value / totalWeightUnits,
      };
    }

    if (otherCurrentTotal <= 0) {
      final baseUnits = remainingUnits ~/ otherIds.length;
      final leftoverUnits = remainingUnits % otherIds.length;
      for (var index = 0; index < otherIds.length; index += 1) {
        adjustedUnits[otherIds[index]] =
            baseUnits + (index < leftoverUnits ? 1 : 0);
      }
      return {
        for (final entry in adjustedUnits.entries)
          entry.key: entry.value / totalWeightUnits,
      };
    }

    final quotas = <String, double>{};
    var allocatedUnits = changedUnits;
    for (final id in otherIds) {
      final quota = ((current[id] ?? 0) / otherCurrentTotal) * remainingUnits;
      quotas[id] = quota;
      final units = quota.floor();
      adjustedUnits[id] = units;
      allocatedUnits += units;
    }

    final sortedRemainders = otherIds.toList()
      ..sort(
        (a, b) => ((quotas[b] ?? 0) - (quotas[b] ?? 0).floor()).compareTo(
          (quotas[a] ?? 0) - (quotas[a] ?? 0).floor(),
        ),
      );

    var remainderIndex = 0;
    while (allocatedUnits < totalWeightUnits) {
      final id = sortedRemainders[remainderIndex % sortedRemainders.length];
      adjustedUnits[id] = (adjustedUnits[id] ?? 0) + 1;
      allocatedUnits += 1;
      remainderIndex += 1;
    }

    return {
      for (final entry in adjustedUnits.entries)
        entry.key: entry.value / totalWeightUnits,
    };
  }

  Map<String, double> _normalizeRelevanceWeights({
    required List<_RelevanceParameterConfig> parameters,
    required Map<String, double> weights,
  }) {
    if (parameters.isEmpty) {
      return {};
    }

    final total = parameters.fold<double>(
      0,
      (sum, parameter) => sum + (weights[parameter.id] ?? parameter.weight),
    );

    if (total <= 0) {
      final equalWeight = 1 / parameters.length;
      return {for (final parameter in parameters) parameter.id: equalWeight};
    }

    return {
      for (final parameter in parameters)
        parameter.id: (weights[parameter.id] ?? parameter.weight) / total,
    };
  }

  _RelevanceParameterConfig _createBlankRelevanceParameter(
    List<_RelevanceParameterConfig> parameters,
  ) {
    var index = parameters.length + 1;
    var id = 'custom_$index';
    while (parameters.any((parameter) => parameter.id == id)) {
      index += 1;
      id = 'custom_$index';
    }

    return _RelevanceParameterConfig(
      id: id,
      symbol: 'P$index',
      name: 'Novo parametro',
      description: 'Descreva o criterio narrativo.',
      weight: 0.10,
    );
  }

  _RelevanceCategoryConfig _relevanceCategoryForScore(double score) {
    for (final category in _relevanceCategories) {
      if (score >= category.min && score <= category.max) {
        return category;
      }
    }

    return _relevanceCategories.last;
  }

  List<ProjectTagData> _knownTagsFor(_CharacterTagKind kind) {
    return switch (kind) {
      _CharacterTagKind.gender => _genderTags,
      _CharacterTagKind.sexuality => _sexualityTags,
      _CharacterTagKind.ethnicity => _ethnicityTags,
      _CharacterTagKind.function => _functionTags ??= _seedCharacterTags(
        _CharacterTagKind.function,
      ),
    };
  }

  String _selectedTagFor(_CharacterTagKind kind) {
    return switch (kind) {
      _CharacterTagKind.gender => _selectedGenderTag,
      _CharacterTagKind.sexuality => _selectedSexualityTag,
      _CharacterTagKind.ethnicity => _selectedEthnicityTag,
      _CharacterTagKind.function => _selectedFunctionTag ?? '',
    };
  }

  Color? _tagColorFor(_CharacterTagKind kind, String label) {
    if (label.trim().isEmpty) {
      return null;
    }

    final normalized = normalizeProjectTagLabel(label);
    final tags = _knownTagsFor(kind);

    for (final tag in tags) {
      if (tag.normalizedLabel == normalized) {
        return tag.color;
      }
    }

    return null;
  }

  void _setSelectedTag(_CharacterTagKind kind, String value) {
    switch (kind) {
      case _CharacterTagKind.gender:
        _selectedGenderTag = value;
        break;
      case _CharacterTagKind.sexuality:
        _selectedSexualityTag = value;
        break;
      case _CharacterTagKind.ethnicity:
        _selectedEthnicityTag = value;
        break;
      case _CharacterTagKind.function:
        _selectedFunctionTag = value;
        break;
    }
  }

  bool _isRequiredTagKind(_CharacterTagKind kind) {
    return kind == _CharacterTagKind.gender;
  }

  String? _addTagFor(_CharacterTagKind kind, String input) {
    final sanitized = sanitizeProjectTagLabel(input);
    if (sanitized.isEmpty) {
      return null;
    }

    List<ProjectTagData> tags = _knownTagsFor(kind);
    final normalized = normalizeProjectTagLabel(sanitized);
    final existing = tags.where((tag) => tag.normalizedLabel == normalized);
    if (existing.isNotEmpty) {
      return existing.first.label;
    }

    final newTag = ProjectTagData(
      label: sanitized,
      color: projectTagColorAt(tags.length),
    );

    setState(() {
      tags = <ProjectTagData>[...tags, newTag];
      switch (kind) {
        case _CharacterTagKind.gender:
          _genderTags = tags;
          break;
        case _CharacterTagKind.sexuality:
          _sexualityTags = tags;
          break;
        case _CharacterTagKind.ethnicity:
          _ethnicityTags = tags;
          break;
        case _CharacterTagKind.function:
          _functionTags = tags;
          break;
      }
    });

    return newTag.label;
  }
}

enum _CharacterTagKind { gender, sexuality, ethnicity, function }

class _RelevanceParameterConfig {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final double weight;

  const _RelevanceParameterConfig({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    required this.weight,
  });

  _RelevanceParameterConfig copyWith({
    String? name,
    String? description,
    double? weight,
  }) {
    return _RelevanceParameterConfig(
      id: id,
      symbol: symbol,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
    );
  }
}

class _RelevanceCategoryConfig {
  final String name;
  final double min;
  final double max;
  final String description;
  final Color color;

  const _RelevanceCategoryConfig({
    required this.name,
    required this.min,
    required this.max,
    required this.description,
    required this.color,
  });
}

class _RelevanceSelectionResult {
  final Map<String, double> values;
  final Map<String, double> weights;
  final List<_RelevanceParameterConfig> parameters;
  final String categoryName;

  const _RelevanceSelectionResult({
    required this.values,
    required this.weights,
    required this.parameters,
    required this.categoryName,
  });
}

List<_RelevanceParameterConfig> _defaultRelevanceParameters() {
  return const [
    _RelevanceParameterConfig(
      id: 'causal',
      symbol: 'Cc',
      name: 'Centralidade causal',
      description:
          'Baixo: reage aos eventos. Alto: cria viradas, escolhas vitais e consequencias irreversiveis.',
      weight: 0.45,
    ),
    _RelevanceParameterConfig(
      id: 'relational',
      symbol: 'Dr',
      name: 'Densidade relacional',
      description:
          'Baixo: poucas conexoes. Alto: conecta grupos, move relacoes e irradia influencia no elenco.',
      weight: 0.25,
    ),
    _RelevanceParameterConfig(
      id: 'thematic',
      symbol: 'Ct',
      name: 'Carga tematica',
      description:
          'Baixo: pouca tese propria. Alto: encarna conflitos, ideias e perguntas centrais da obra.',
      weight: 0.15,
    ),
    _RelevanceParameterConfig(
      id: 'presence',
      symbol: 'Pd',
      name: 'Presenca discursiva',
      description:
          'Baixo: aparece pouco. Alto: ocupa cenas, falas, paginas ou atencao recorrente.',
      weight: 0.10,
    ),
    _RelevanceParameterConfig(
      id: 'mutability',
      symbol: 'Me',
      name: 'Mutabilidade estrutural',
      description:
          'Baixo: permanece estavel. Alto: muda psicologicamente ou reposiciona sua funcao na trama.',
      weight: 0.05,
    ),
  ];
}

List<_RelevanceCategoryConfig> _defaultRelevanceCategories() {
  return const [
    _RelevanceCategoryConfig(
      name: 'Contorno',
      min: 0,
      max: 1.9,
      description: 'Figura passiva ou cenografica.',
      color: Color(0xFF8E838B),
    ),
    _RelevanceCategoryConfig(
      name: 'Periferico',
      min: 2,
      max: 4.9,
      description: 'Agente funcional, gatilho ou catalisador.',
      color: Color(0xFF8EAFF1),
    ),
    _RelevanceCategoryConfig(
      name: 'Orbital',
      min: 5,
      max: 7.9,
      description: 'Sustentacao critica ao redor do nucleo.',
      color: Color(0xFFDF9C53),
    ),
    _RelevanceCategoryConfig(
      name: 'Nuclear',
      min: 8,
      max: 10,
      description: 'Entidade vital da espinha causal da historia.',
      color: Color(0xFFDF6EB8),
    ),
  ];
}

List<ZodiacSignData> _allZodiacSigns() {
  return [
    DateTime(2000, 3, 21),
    DateTime(2000, 4, 20),
    DateTime(2000, 5, 21),
    DateTime(2000, 6, 21),
    DateTime(2000, 7, 23),
    DateTime(2000, 8, 23),
    DateTime(2000, 9, 23),
    DateTime(2000, 10, 23),
    DateTime(2000, 11, 22),
    DateTime(2000, 12, 22),
    DateTime(2000, 1, 20),
    DateTime(2000, 2, 19),
  ].map(zodiacSignFor).toList(growable: false);
}

DateTime _randomBirthdayForSign(ZodiacSignData signData) {
  final dates = <DateTime>[];

  for (var month = 1; month <= 12; month += 1) {
    for (var day = 1; day <= daysInMonth(month); day += 1) {
      final date = DateTime(2000, month, day);
      if (zodiacSignFor(date).symbol == signData.symbol) {
        dates.add(date);
      }
    }
  }

  return dates[Random().nextInt(dates.length)];
}

List<ProjectTagData> _seedCharacterTags(_CharacterTagKind kind) {
  final labels = switch (kind) {
    _CharacterTagKind.gender => const ['Homem', 'Mulher', 'N/A'],
    _CharacterTagKind.sexuality => const [
      'Assexual',
      'Heterossexual',
      'Homossexual',
      'Bissexual',
      'Pansexual',
    ],
    _CharacterTagKind.ethnicity => const ['Branco', 'Negro', 'Pardo'],
    _CharacterTagKind.function => const [
      'Vilao',
      'Heroi',
      'Anti-heroi',
      'Anti-vilao',
    ],
  };

  return [
    for (var i = 0; i < labels.length; i += 1)
      ProjectTagData(label: labels[i], color: projectTagColorAt(i)),
  ];
}

String _tagKindTitle(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => 'Gênero',
    _CharacterTagKind.sexuality => 'Sexualidade',
    _CharacterTagKind.ethnicity => 'Etnia',
    _CharacterTagKind.function => 'Funcao',
  };
}

String _tagKindDescription(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender =>
      'Escolha uma opção existente ou adicione uma nova para o gênero do personagem.',
    _CharacterTagKind.sexuality =>
      'Escolha uma opção existente ou adicione uma nova para a sexualidade do personagem.',
    _CharacterTagKind.ethnicity =>
      'Escolha uma opção existente ou adicione uma nova para a etnia do personagem.',
    _CharacterTagKind.function =>
      'Escolha a funcao dramatica principal do personagem.',
  };
}

IconData _tagKindIcon(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => Icons.wc_rounded,
    _CharacterTagKind.sexuality => Icons.favorite_border_rounded,
    _CharacterTagKind.ethnicity => Icons.groups_2_outlined,
    _CharacterTagKind.function => Icons.theater_comedy_outlined,
  };
}

class _CreateCharacterDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _CreateCharacterDialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Novo personagem',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C262C),
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          color: const Color(0xFF544959),
        ),
      ],
    );
  }
}

class _CreateCharacterNameField extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController aliasController;
  final Color focusedColor;

  const _CreateCharacterNameField({
    required this.nameController,
    required this.aliasController,
    required this.focusedColor,
  });

  @override
  Widget build(BuildContext context) {
    final nameField = _CharacterCompactField(
      label: 'Nome *',
      controller: nameController,
      hintText: 'Nome do personagem',
      focusedColor: focusedColor,
      icon: Icons.badge_outlined,
      prefixWidth: _characterDialogCompactPrefixWidth,
      fieldHeight: _characterDialogNameFieldHeight,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe um nome para o personagem.';
        }
        return null;
      },
    );

    final aliasField = _CharacterCompactField(
      label: 'Vulgo',
      controller: aliasController,
      hintText: 'Apelido, nome de guerra ou nome publico',
      focusedColor: focusedColor,
      icon: Icons.alternate_email_rounded,
      prefixWidth: _characterDialogCompactPrefixWidth,
      fieldHeight: _characterDialogNameFieldHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [nameField, const SizedBox(height: 10), aliasField],
    );
  }
}

class _CharacterMetadataSection extends StatelessWidget {
  final Color accentColor;
  final TextEditingController mottoController;
  final TextEditingController formationsController;
  final TextEditingController titlesController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final String heightUnitLabel;
  final String weightUnitLabel;
  final VoidCallback onPickHeightUnit;
  final VoidCallback onPickWeightUnit;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const _CharacterMetadataSection({
    required this.accentColor,
    required this.mottoController,
    required this.formationsController,
    required this.titlesController,
    required this.weightController,
    required this.heightController,
    required this.heightUnitLabel,
    required this.weightUnitLabel,
    required this.onPickHeightUnit,
    required this.onPickWeightUnit,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final complementaryCount = <String>[
      mottoController.text.trim(),
      formationsController.text.trim(),
      titlesController.text.trim(),
    ].where((value) => value.isNotEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CharacterDisclosureTile(
          title: 'Medidas e complementos',
          summary: complementaryCount == 0
              ? 'Peso, altura, frase, títulos e ocupações'
              : '$complementaryCount complemento(s) preenchido(s)',
          accentColor: accentColor,
          isExpanded: isExpanded,
          onTap: onToggleExpanded,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: isExpanded
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        Widget measureRow({
                          required String label,
                          required TextEditingController controller,
                          required String hintText,
                          required IconData icon,
                          required String unitLabel,
                          required VoidCallback onPickUnit,
                        }) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _CharacterMeasureField(
                                label: label,
                                controller: controller,
                                hintText: hintText,
                                focusedColor: accentColor,
                                icon: icon,
                              ),
                              const SizedBox(width: 8),
                              _CharacterUnitPillButton(
                                accentColor: accentColor,
                                label: unitLabel,
                                onTap: onPickUnit,
                              ),
                            ],
                          );
                        }

                        final weightRow = measureRow(
                          label: 'Peso',
                          controller: weightController,
                          hintText: 'Peso',
                          icon: Icons.balance_outlined,
                          unitLabel: weightUnitLabel,
                          onPickUnit: onPickWeightUnit,
                        );
                        final heightRow = measureRow(
                          label: 'Altura',
                          controller: heightController,
                          hintText: 'Altura',
                          icon: Icons.straighten_rounded,
                          unitLabel: heightUnitLabel,
                          onPickUnit: onPickHeightUnit,
                        );

                        if (constraints.maxWidth <
                            _characterDialogMeasureLayoutBreakpoint) {
                          return Column(
                            children: [
                              weightRow,
                              const SizedBox(height: 10),
                              heightRow,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: weightRow),
                            const SizedBox(width: 10),
                            Expanded(child: heightRow),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _CharacterToggleField(
                      label: 'Frase de efeito',
                      controller: mottoController,
                      hintText:
                          'Frase curta, lema ou linha marcante que ajuda a definir o personagem',
                      accentColor: accentColor,
                      icon: Icons.format_quote_rounded,
                      maxLines: 2,
                      fieldHeight: 82,
                    ),
                    const SizedBox(height: 10),
                    _CharacterCompactField(
                      label: 'Formações e ocupações',
                      controller: formationsController,
                      hintText:
                          'Área de estudo, ofício, cargo ou função social do personagem',
                      focusedColor: accentColor,
                      icon: Icons.work_outline_rounded,
                      maxLines: 3,
                      fieldHeight: 90,
                    ),
                    const SizedBox(height: 10),
                    _CharacterCompactField(
                      label: 'Títulos',
                      controller: titlesController,
                      hintText:
                          'Honrarias, classificações, patentes ou nomes cerimoniais associados ao personagem',
                      focusedColor: accentColor,
                      icon: Icons.military_tech_outlined,
                      maxLines: 3,
                      fieldHeight: 90,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CharacterCompactField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color focusedColor;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;
  final double? fieldHeight;
  final double? prefixWidth;

  const _CharacterCompactField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.focusedColor,
    required this.icon,
    this.maxLines = 1,
    this.validator,
    this.fieldHeight,
    this.prefixWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;
    final fillsCustomHeight = isMultiline || fieldHeight != null;
    final resolvedFieldHeight =
        fieldHeight ??
        (isMultiline ? 84 : _characterDialogSingleLineFieldHeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: resolvedFieldHeight,
          child: TextFormField(
            controller: controller,
            textInputAction: isMultiline
                ? TextInputAction.newline
                : TextInputAction.next,
            minLines: fillsCustomHeight ? null : 1,
            maxLines: fillsCustomHeight ? null : 1,
            expands: fillsCustomHeight,
            validator: validator,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 12.5,
              height: 1.3,
            ),
            decoration: _buildCharacterDialogFieldDecoration(
              hintText: hintText,
              focusedColor: focusedColor,
              prefixIcon: _CharacterFieldPrefix(
                icon: icon,
                label: label,
                accentColor: focusedColor,
                width: prefixWidth,
              ),
              contentPadding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
              constraints: BoxConstraints.tightFor(height: resolvedFieldHeight),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterToggleField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color accentColor;
  final IconData icon;
  final int maxLines;
  final double? fieldHeight;

  const _CharacterToggleField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.accentColor,
    required this.icon,
    this.maxLines = 1,
    this.fieldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height:
                    fieldHeight ??
                    (isMultiline ? 84 : _characterDialogSingleLineFieldHeight),
                child: TextFormField(
                  controller: controller,
                  textInputAction: isMultiline
                      ? TextInputAction.newline
                      : TextInputAction.next,
                  minLines: isMultiline ? null : 1,
                  maxLines: isMultiline ? null : 1,
                  expands: isMultiline,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    color: Color(0xFF3A3339),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                  decoration: _buildCharacterDialogFieldDecoration(
                    hintText: hintText,
                    focusedColor: accentColor,
                    prefixIcon: _CharacterFieldPrefix(
                      icon: icon,
                      label: label,
                      accentColor: accentColor,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CharacterMeasureField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color focusedColor;
  final IconData icon;

  const _CharacterMeasureField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.focusedColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _characterDialogMeasureFieldWidth,
      height: _characterDialogMeasureControlHeight,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        textAlignVertical: TextAlignVertical.center,
        minLines: null,
        maxLines: null,
        expands: true,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.68),
          fontSize: 11.8,
          fontStyle: FontStyle.italic,
        ),
        decoration: _buildCharacterDialogFieldDecoration(
          hintText: hintText,
          focusedColor: focusedColor,
          prefixIcon: _CharacterMeasureFieldPrefix(
            icon: icon,
            label: label,
            accentColor: focusedColor,
          ),
          contentPadding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
          constraints: const BoxConstraints.tightFor(
            height: _characterDialogMeasureControlHeight,
          ),
        ),
      ),
    );
  }
}

class _CharacterMeasureFieldPrefix extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _CharacterMeasureFieldPrefix({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF171419)),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 10.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            width: 1.2,
            height: 16,
            margin: const EdgeInsets.only(left: 6),
            color: accentColor.withValues(alpha: 0.76),
          ),
        ],
      ),
    );
  }
}

class _CharacterIdentityTagGrid extends StatelessWidget {
  final String genderLabel;
  final Color? genderColor;
  final String sexualityLabel;
  final Color? sexualityColor;
  final String ethnicityLabel;
  final Color? ethnicityColor;
  final String functionLabel;
  final Color? functionColor;
  final Color accentColor;
  final bool showRequiredErrors;
  final VoidCallback onPickGenderTag;
  final VoidCallback onPickSexualityTag;
  final VoidCallback onPickEthnicityTag;
  final VoidCallback onPickFunctionTag;

  const _CharacterIdentityTagGrid({
    required this.genderLabel,
    required this.genderColor,
    required this.sexualityLabel,
    required this.sexualityColor,
    required this.ethnicityLabel,
    required this.ethnicityColor,
    required this.functionLabel,
    required this.functionColor,
    required this.accentColor,
    required this.showRequiredErrors,
    required this.onPickGenderTag,
    required this.onPickSexualityTag,
    required this.onPickEthnicityTag,
    required this.onPickFunctionTag,
  });

  @override
  Widget build(BuildContext context) {
    final tagFields = <Widget>[
      _CharacterTagSelectorField(
        label: 'Gênero',
        value: genderLabel,
        accentColor: accentColor,
        selectedColor: genderColor,
        isRequired: true,
        showError: showRequiredErrors && genderLabel.trim().isEmpty,
        onTap: onPickGenderTag,
      ),
      _CharacterTagSelectorField(
        label: 'Sexualidade',
        value: sexualityLabel,
        accentColor: accentColor,
        selectedColor: sexualityColor,
        onTap: onPickSexualityTag,
      ),
      _CharacterTagSelectorField(
        label: 'Etnia',
        value: ethnicityLabel,
        accentColor: accentColor,
        selectedColor: ethnicityColor,
        onTap: onPickEthnicityTag,
      ),
      _CharacterTagSelectorField(
        label: 'Funcao',
        value: functionLabel,
        accentColor: accentColor,
        selectedColor: functionColor,
        onTap: onPickFunctionTag,
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tagFields[0]),
            const SizedBox(width: 10),
            Expanded(child: tagFields[1]),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tagFields[2]),
            const SizedBox(width: 10),
            Expanded(child: tagFields[3]),
          ],
        ),
      ],
    );
  }
}

class _CharacterRelevanceSelectorField extends StatelessWidget {
  final String value;
  final Color? selectedColor;
  final Color accentColor;
  final List<_RelevanceCategoryConfig> categories;
  final bool showError;
  final double score;
  final VoidCallback onTap;

  const _CharacterRelevanceSelectorField({
    required this.value,
    required this.selectedColor,
    required this.accentColor,
    required this.categories,
    required this.showError,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final categoryColor = selectedColor ?? accentColor;
    final surfaceColor = accentColor;
    final labelColor = showError
        ? const Color(0xFFC96775)
        : hasValue
        ? _darkenCharacterDialogColor(surfaceColor, 0.2)
        : const Color(0xFF8E838B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 112,
          padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
          decoration: showError
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFC96775),
                    width: 1.1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.72),
                      const Color(0xFFC96775).withValues(alpha: 0.08),
                    ],
                  ),
                )
              : _buildCharacterDialogSurfaceDecoration(
                  accentColor: surfaceColor,
                  selected: hasValue,
                  borderRadius: BorderRadius.circular(16),
                ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                child: Icon(
                  Icons.stars_rounded,
                  size: 17,
                  color: _darkenCharacterDialogColor(categoryColor, 0.18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Relevância *',
                      style: TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasValue
                          ? value
                          : showError
                          ? 'Campo obrigatório'
                          : 'Selecionar relevância narrativa',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: hasValue
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RelevanceSpectrumBar(
                      score: score,
                      categories: categories,
                      compact: true,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        for (final category in categories)
                          Expanded(
                            flex: ((category.max - category.min) * 10).round(),
                            child: Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.46),
                                fontSize: 8.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 28,
                decoration: BoxDecoration(
                  color: surfaceColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: surfaceColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Center(
                  child: Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(surfaceColor, 0.18),
                      fontSize: 10.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterTagSelectorField extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final Color? selectedColor;
  final bool isRequired;
  final bool showError;
  final VoidCallback onTap;

  const _CharacterTagSelectorField({
    required this.label,
    required this.value,
    required this.accentColor,
    this.selectedColor,
    this.isRequired = false,
    this.showError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final effectiveColor = selectedColor ?? accentColor;
    final borderColor = showError
        ? const Color(0xFFC96775)
        : Colors.white.withValues(alpha: 0.82);
    final decoration = showError
        ? BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.72),
                const Color(0xFFC96775).withValues(alpha: 0.08),
              ],
            ),
          )
        : _buildCharacterDialogSurfaceDecoration(
            accentColor: effectiveColor,
            selected: hasValue,
            borderRadius: BorderRadius.circular(16),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 78,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: decoration,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isRequired ? '$label *' : label,
                      style: const TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasValue
                          ? value
                          : showError
                          ? 'Campo obrigatório'
                          : 'Selecionar ou criar',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: showError
                            ? const Color(0xFFC96775)
                            : hasValue
                            ? _darkenCharacterDialogColor(effectiveColor, 0.2)
                            : const Color(0xFF8E838B),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: hasValue
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.56),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
                child: Icon(
                  hasValue ? Icons.edit_rounded : Icons.add_rounded,
                  size: 15,
                  color: _darkenCharacterDialogColor(effectiveColor, 0.16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterBirthdayDraftField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final ZodiacSignData signData;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onTapSign;

  const _CharacterBirthdayDraftField({
    required this.label,
    required this.valueLabel,
    required this.signData,
    required this.accentColor,
    required this.onTap,
    required this.onTapSign,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.only(right: 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _CharacterFieldPrefix(
                icon: Icons.cake_outlined,
                label: label,
                accentColor: accentColor,
              ),
              Expanded(
                child: Text(
                  valueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.68),
                    fontSize: 11.8,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CharacterSignBadge(
                accentColor: accentColor,
                signData: signData,
                onTap: onTapSign,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterDisclosureTile extends StatelessWidget {
  final String title;
  final String summary;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CharacterDisclosureTile({
    required this.title,
    required this.summary,
    required this.accentColor,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E838B),
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              MiniGlassButton(
                accentColor: accentColor,
                icon: isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterSignBadge extends StatelessWidget {
  final Color accentColor;
  final ZodiacSignData signData;
  final VoidCallback? onTap;

  const _CharacterSignBadge({
    required this.accentColor,
    required this.signData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.62),
            _lightenCharacterDialogColor(
              accentColor,
              0.16,
            ).withValues(alpha: 0.24),
            accentColor.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            signData.symbol,
            style: TextStyle(
              color: _darkenCharacterDialogColor(accentColor, 0.24),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            signData.name,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.54),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: content,
      ),
    );
  }
}

class _CharacterUnitPillButton extends StatelessWidget {
  final Color accentColor;
  final String label;
  final VoidCallback onTap;

  const _CharacterUnitPillButton({
    required this.accentColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: _characterDialogMeasureUnitWidth,
          height: _characterDialogMeasureControlHeight,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.64),
                _lightenCharacterDialogColor(
                  accentColor,
                  0.18,
                ).withValues(alpha: 0.3),
                accentColor.withValues(alpha: 0.28),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _darkenCharacterDialogColor(accentColor, 0.22),
                    fontSize: 9.4,
                    height: 1,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: 12,
                color: _darkenCharacterDialogColor(accentColor, 0.18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZodiacRandomOption extends StatelessWidget {
  final ZodiacSignData signData;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZodiacRandomOption({
    required this.signData,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected
        ? _darkenCharacterDialogColor(accentColor, 0.24)
        : const Color(0xFF3A3339);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.46)
                  : Colors.white.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                signData.symbol,
                style: TextStyle(
                  color: _darkenCharacterDialogColor(accentColor, 0.2),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                signData.name,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: _darkenCharacterDialogColor(accentColor, 0.16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogSelectOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DialogSelectOption({
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

class _CharacterTagEmptyState extends StatelessWidget {
  final Color accentColor;

  const _CharacterTagEmptyState({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: const Text(
        'Nenhuma opção cadastrada ainda.',
        style: TextStyle(color: Color(0xFF6A6167), fontSize: 12),
      ),
    );
  }
}

class _CharacterTagOptionButton extends StatelessWidget {
  final ProjectTagData tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterTagOptionButton({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? tag.color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tag.color.withValues(alpha: isSelected ? 0.86 : 0.42),
              width: isSelected ? 1.15 : 0.9,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: tag.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tag.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tag.color.withValues(alpha: 0.98),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                Icon(Icons.check_rounded, size: 13, color: tag.color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCenteredMenuFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _CharacterCenteredMenuFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.58),
              width: 0.9,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C262C),
                ),
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

class _RelevanceScoreSummary extends StatelessWidget {
  final double score;
  final _RelevanceCategoryConfig category;
  final List<_RelevanceCategoryConfig> categories;
  final Color accentColor;

  const _RelevanceScoreSummary({
    required this.score,
    required this.category,
    required this.categories,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: category.color.withValues(alpha: 0.42)),
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: _darkenCharacterDialogColor(category.color, 0.16),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: _darkenCharacterDialogColor(category.color, 0.2),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                _RelevanceSpectrumBar(score: score, categories: categories),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.58),
                          fontSize: 11.2,
                          height: 1.2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${category.min.toStringAsFixed(1)}-${category.max.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: _darkenCharacterDialogColor(
                          category.color,
                          0.18,
                        ),
                        fontSize: 10.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelevanceSpectrumBar extends StatelessWidget {
  final double score;
  final List<_RelevanceCategoryConfig> categories;
  final bool compact;

  const _RelevanceSpectrumBar({
    required this.score,
    required this.categories,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final markerWidth = compact ? 8.0 : 12.0;
        final markerHeight = compact ? 14.0 : 20.0;
        final markerLeft =
            (constraints.maxWidth - markerWidth) * (score.clamp(0, 10) / 10);

        return SizedBox(
          height: compact ? 16 : 24,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: compact ? 5 : 6,
                bottom: compact ? 5 : 6,
                child: Row(
                  children: [
                    for (final category in categories)
                      Expanded(
                        flex: ((category.max - category.min) * 10).round(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: markerLeft,
                top: compact ? 1 : 2,
                child: Container(
                  width: markerWidth,
                  height: markerHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C262C),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.88),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelevanceFormulaNote extends StatelessWidget {
  final Color accentColor;

  const _RelevanceFormulaNote({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Text(
        'R usa a soma ponderada das notas. Os pesos sempre fecham 100%; ao ajustar um peso, os demais se redistribuem automaticamente.',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.56),
          fontSize: 10.4,
          height: 1.22,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _AddRelevanceParameterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddRelevanceParameterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const projectPink = Color(0xFFDF6EB8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: projectPink.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: projectPink.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 18,
                color: _darkenCharacterDialogColor(projectPink, 0.18),
              ),
              const SizedBox(width: 6),
              Text(
                'Adicionar parametro',
                style: TextStyle(
                  color: _darkenCharacterDialogColor(projectPink, 0.18),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelevanceParameterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RelevanceParameterIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? const Color(0xFF7D6171) : const Color(0xFFB9AFB6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _RelevanceParameterControl extends StatelessWidget {
  final _RelevanceParameterConfig parameter;
  final double value;
  final double weight;
  final bool canRemove;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<double> onWeightChanged;

  const _RelevanceParameterControl({
    required this.parameter,
    required this.value,
    required this.weight,
    required this.canRemove,
    required this.isEditing,
    required this.onEdit,
    required this.onRemove,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onValueChanged,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    const projectPink = Color(0xFFDF6EB8);
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: projectPink,
      inactiveTrackColor: projectPink.withValues(alpha: 0.18),
      activeTickMarkColor: Colors.white.withValues(alpha: 0.42),
      inactiveTickMarkColor: projectPink.withValues(alpha: 0.28),
      thumbColor: projectPink,
      overlayColor: projectPink.withValues(alpha: 0.14),
      valueIndicatorColor: projectPink,
      trackHeight: 5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 24,
                decoration: BoxDecoration(
                  color: projectPink.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    parameter.symbol,
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(projectPink, 0.18),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parameter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A3339),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              _RelevanceParameterIconButton(
                icon: isEditing ? Icons.check_rounded : Icons.edit_rounded,
                onTap: onEdit,
              ),
              _RelevanceParameterIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: canRemove ? onRemove : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (isEditing) ...[
            TextFormField(
              key: ValueKey('relevance-name-${parameter.id}'),
              initialValue: parameter.name,
              textInputAction: TextInputAction.next,
              onChanged: onNameChanged,
              decoration: _buildCharacterDialogFieldDecoration(
                hintText: 'Nome do parametro',
                focusedColor: projectPink,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey('relevance-description-${parameter.id}'),
              initialValue: parameter.description,
              minLines: 2,
              maxLines: 3,
              onChanged: onDescriptionChanged,
              decoration: _buildCharacterDialogFieldDecoration(
                hintText: 'Descricao: o que significa ter pouco ou muito',
                focusedColor: projectPink,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ] else
            Text(
              parameter.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.54),
                fontSize: 10.2,
                height: 1.22,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 2),
          SliderTheme(
            data: sliderTheme,
            child: Slider(
              value: value.clamp(0, 10),
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: onValueChanged,
            ),
          ),
          Row(
            children: [
              const Text(
                'Peso',
                style: TextStyle(
                  color: Color(0xFF6A6167),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: sliderTheme,
                  child: Slider(
                    value: weight.clamp(0, 1),
                    min: 0,
                    max: 1,
                    divisions: 20,
                    onChanged: onWeightChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '${(weight * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF6A6167),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CharacterProfilePhotoSection extends StatelessWidget {
  final CreateProjectDialogImageController imageController;
  final Color coverColor;
  final Color accentColor;

  const _CharacterProfilePhotoSection({
    required this.imageController,
    required this.coverColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = imageController.coverImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de perfil',
            style: TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          CreateProjectDialogFieldDescription(
            text:
                'Escolha a imagem principal do personagem. O enquadramento abaixo replica a mesma moldura usada no card.',
          ),
          const SizedBox(height: 8),
          _CharacterProfileImageEditor(
            image: profileImage,
            imageName: imageController.coverImageName,
            coverColor: coverColor,
            accentColor: accentColor,
            onScaleChanged: (value) => imageController.setImageScale(
              CreateProjectDialogColorTarget.cover,
              value,
            ),
            onOffsetChanged: (offsetX, offsetY) =>
                imageController.setImageOffset(
                  CreateProjectDialogColorTarget.cover,
                  offsetX,
                  offsetY,
                ),
            onPick: () =>
                imageController.pickImage(CreateProjectDialogColorTarget.cover),
            onRemove: profileImage.bytes == null
                ? null
                : () => imageController.removeImage(
                    CreateProjectDialogColorTarget.cover,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CharacterProfileImageEditor extends StatelessWidget {
  final ProjectImageData image;
  final String? imageName;
  final Color coverColor;
  final Color accentColor;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _CharacterProfileImageEditor({
    required this.image,
    required this.imageName,
    required this.coverColor,
    required this.accentColor,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = 22.0;
        final frameWidth = (constraints.maxWidth - (horizontalPadding * 2))
            .clamp(160.0, 230.0)
            .toDouble();
        final frameHeight =
            frameWidth *
            (characterProfileTileHeight / characterProfileTileWidth);
        final canvasHeight = frameHeight + 44;
        final frameTop = (canvasHeight - frameHeight) / 2;
        final frameLeft = (constraints.maxWidth - frameWidth) / 2;
        final metrics =
            image.bytes != null && image.width != null && image.height != null
            ? computeProjectImageViewportMetrics(
                viewportSize: Size(frameWidth, frameHeight),
                imageWidth: image.width!,
                imageHeight: image.height!,
                scale: image.scale,
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: canvasHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.84),
                      ),
                      Color.alphaBlend(
                        coverColor.withValues(alpha: 0.36),
                        const Color(0xFFF8F1F5),
                      ),
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.12),
                        const Color(0xFFF0E2EA),
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                child: image.bytes == null
                    ? Center(
                        child: Text(
                          'Nenhuma foto selecionada',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onPanUpdate: (details) {
                          final dx =
                              image.offsetX +
                              ((metrics?.maxTranslationX ?? 0) <= 0
                                  ? 0
                                  : details.delta.dx /
                                        metrics!.maxTranslationX);
                          final dy =
                              image.offsetY +
                              ((metrics?.maxTranslationY ?? 0) <= 0
                                  ? 0
                                  : details.delta.dy /
                                        metrics!.maxTranslationY);
                          onOffsetChanged(dx, dy);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: SizedBox(
                                width: frameWidth,
                                height: frameHeight,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  child: ProjectImageTransformView(
                                    imageBytes: image.bytes!,
                                    imageWidth: image.width ?? frameWidth,
                                    imageHeight: image.height ?? frameHeight,
                                    scale: image.scale,
                                    offsetX: image.offsetX,
                                    offsetY: image.offsetY,
                                    viewportWidth: frameWidth,
                                    viewportHeight: frameHeight,
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    height: frameTop,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: frameTop,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: frameLeft,
                                    top: frameTop,
                                    width: frameWidth,
                                    height: frameHeight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                          topRight: Radius.circular(18),
                                          bottomRight: Radius.circular(18),
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.94,
                                          ),
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (imageName != null) ...[
              const SizedBox(height: 8),
              Text(
                imageName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6A6167),
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (image.bytes != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Zoom',
                    style: TextStyle(
                      color: Color(0xFF514752),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: image.scale,
                        min: 1,
                        max: 3,
                        onChanged: onScaleChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${image.scale.toStringAsFixed(1)}x',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF7A7079),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      image.bytes == null ? 'Escolher foto' : 'Trocar foto',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF514752),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5668),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Remover'),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CreateCharacterActionsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _CreateCharacterActionsRow({
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF514752),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDF6EB8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Criar personagem'),
          ),
        ),
      ],
    );
  }
}

class _CharacterFieldPrefix extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final double? width;

  const _CharacterFieldPrefix({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? _characterDialogPrefixWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF171419)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFF3A3339),
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            Container(
              width: 1.2,
              height: 18,
              margin: const EdgeInsets.only(left: 8),
              color: accentColor.withValues(alpha: 0.76),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _buildCharacterDialogFieldDecoration({
  required String hintText,
  required Color focusedColor,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
  BoxConstraints? constraints,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
  );

  return InputDecoration(
    hintText: hintText,
    hintMaxLines: 4,
    prefixIcon: prefixIcon,
    prefixIconConstraints: prefixIcon == null
        ? null
        : const BoxConstraints(minWidth: 0, minHeight: 0),
    hintStyle: const TextStyle(
      color: Color(0xFF8E838B),
      fontSize: 12.5,
      fontStyle: FontStyle.italic,
      height: 1.3,
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.56),
    isDense: true,
    constraints: constraints,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: focusedColor, width: 1.1),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
    ),
  );
}

BoxDecoration _buildCharacterDialogSurfaceDecoration({
  required Color accentColor,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  bool selected = false,
}) {
  final tint = selected
      ? accentColor
      : _lightenCharacterDialogColor(accentColor, 0.06);

  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.44),
    borderRadius: borderRadius,
    border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.7),
        tint.withValues(alpha: selected ? 0.16 : 0.1),
        _lightenCharacterDialogColor(accentColor, 0.22).withValues(alpha: 0.08),
      ],
      stops: const [0, 0.58, 1],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

Color _lightenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darkenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
