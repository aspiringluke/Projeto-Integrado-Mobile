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
import '../../tags/controllers/tag_controller.dart';
import '../utils/characters_utils.dart';
import 'character_card_visuals.dart';
import 'character_fields.dart';

part 'create_character_dialog_parts/configuration.dart';
part 'create_character_dialog_parts/metadata_fields.dart';
part 'create_character_dialog_parts/selectors.dart';
part 'create_character_dialog_parts/relevance_controls.dart';
part 'create_character_dialog_parts/image_editor.dart';
part 'create_character_dialog_parts/actions.dart';

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
  late final Map<_CharacterTagKind, TagController> _tagControllers;
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
    _tagControllers = <_CharacterTagKind, TagController>{
      for (final kind in _CharacterTagKind.values)
        kind: TagController(
          knownTags: _seedCharacterTags(kind),
          draftTagColor: _tagCategoryColor(kind),
          groupTitle: _tagGroupStorageTitle(kind),
        ),
    };
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
    for (final controller in _tagControllers.values) {
      controller.dispose();
    }
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
                                alignment: WrapAlignment.spaceBetween,
                                runAlignment: WrapAlignment.spaceBetween,
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
                    title: 'Relevância narrativa',
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
    return _tagControllers[kind]?.knownTags ?? const <ProjectTagData>[];
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
    return _tagControllers[kind]?.colorForLabel(label);
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
    final controller = _tagControllers[kind];
    if (controller == null) {
      return null;
    }

    final resolved = controller.upsertTagLabel(
      input,
      newTagColor: _tagCategoryColor(kind),
    );
    if (resolved == null) return null;
    setState(() {});
    return resolved;
  }
}
