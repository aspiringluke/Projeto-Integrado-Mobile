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
import '../../projects/widgets/create_project_dialog_support_widgets.dart';
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
    required this.relevanceTag,
    required this.visibleProfileFields,
    required this.coverColor,
    required this.accentColor,
    required this.profileImage,
  });
}

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
  late List<ProjectTagData> _relevanceTags;
  bool _bodyExpanded = false;
  bool _detailsExpanded = false;
  String _selectedGenderTag = '';
  String _selectedSexualityTag = '';
  String _selectedEthnicityTag = '';
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
    _heightController = TextEditingController(
      text: formatHeightEditorValue(170, _heightUnit),
    );
    _weightController = TextEditingController(
      text: formatWeightEditorValue(70, _weightUnit),
    );
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
    _relevanceTags = _seedCharacterTags(_CharacterTagKind.relevance);
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
    if (!(_formKey.currentState?.validate() ?? false)) {
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
                          const SizedBox(height: 12),
                          _CharacterMetadataSection(
                            accentColor: _dialogController.accentColor,
                            visibleFields: _visibleProfileFields,
                            onToggleFieldVisibility: _toggleFieldVisibility,
                            mottoController: _mottoController,
                            formationsController: _formationsController,
                            titlesController: _titlesController,
                            detailsExpanded: _detailsExpanded,
                            weightController: _weightController,
                            heightController: _heightController,
                            birthdayLabel: formatBirthdayLabel(
                              _birthdayValue.day,
                              _birthdayValue.month,
                            ),
                            birthdaySignData: zodiacSignFor(_birthdayValue),
                            heightUnitLabel: heightUnitCompactLabel(
                              _heightUnit,
                            ),
                            weightUnitLabel: weightUnitCompactLabel(
                              _weightUnit,
                            ),
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
                            relevanceLabel: _selectedRelevanceTag,
                            relevanceColor: _tagColorFor(
                              _CharacterTagKind.relevance,
                              _selectedRelevanceTag,
                            ),
                            onPickBirthday: _selectBirthday,
                            onOpenBirthdaySign: () => _openBirthdaySignSheet(
                              zodiacSignFor(_birthdayValue),
                            ),
                            onPickHeightUnit: _selectHeightUnit,
                            onPickWeightUnit: _selectWeightUnit,
                            onPickGenderTag: () =>
                                _openTagSelector(_CharacterTagKind.gender),
                            onPickSexualityTag: () =>
                                _openTagSelector(_CharacterTagKind.sexuality),
                            onPickEthnicityTag: () =>
                                _openTagSelector(_CharacterTagKind.ethnicity),
                            onPickRelevanceTag: () =>
                                _openTagSelector(_CharacterTagKind.relevance),
                            onToggleDetailsExpanded: () {
                              setState(() {
                                _detailsExpanded = !_detailsExpanded;
                              });
                            },
                            bodyExpanded: _bodyExpanded,
                            onToggleBodyExpanded: () {
                              setState(() {
                                _bodyExpanded = !_bodyExpanded;
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

  void _toggleFieldVisibility(CharacterProfileFieldId fieldId) {
    setState(() {
      if (_visibleProfileFields.contains(fieldId)) {
        _visibleProfileFields.remove(fieldId);
      } else {
        _visibleProfileFields.add(fieldId);
      }
    });
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
      final resolvedHeight = parseHeightToCm(
        _heightController.text,
        _heightUnit,
      );
      _heightUnit = selectedUnit;
      _heightController.text = formatHeightEditorValue(
        resolvedHeight ?? 170,
        _heightUnit,
      );
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
      final resolvedWeight = parseWeightToKg(
        _weightController.text,
        _weightUnit,
      );
      _weightUnit = selectedUnit;
      _weightController.text = formatWeightEditorValue(
        resolvedWeight ?? 70,
        _weightUnit,
      );
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

        return ProjectBottomSheetFrame(
          title: '${currentSign.symbol} ${currentSign.name}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: _buildCharacterDialogSurfaceDecoration(
                  accentColor: accent,
                  selected: true,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currentSign.description,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.64),
                    fontSize: 12,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(_randomBirthdayForSign(currentSign));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.casino_rounded, size: 18),
                  label: const Text('Gerar nesse signo'),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sign in signs)
                    _ZodiacRandomOption(
                      signData: sign,
                      accentColor: accent,
                      isSelected: sign.symbol == currentSign.symbol,
                      onTap: () {
                        Navigator.of(context).pop(_randomBirthdayForSign(sign));
                      },
                    ),
                ],
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

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tags = _knownTagsFor(kind);
            final accent = _dialogController.accentColor;

            return ProjectBottomSheetFrame(
              title: _tagKindTitle(kind),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tagKindDescription(kind),
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.56),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (tags.isEmpty)
                    _CharacterTagEmptyState(accentColor: accent)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          CreateProjectDialogSelectableTagChip(
                            tag: tag,
                            isSelected: tag.label == selectedLabel,
                            onTap: () => Navigator.of(context).pop(tag.label),
                          ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          textInputAction: TextInputAction.done,
                          decoration: _buildInputDecoration(
                            hintText: 'Adicionar nova opcao',
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
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 44,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: const Icon(Icons.add_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                  if (selectedLabel.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(''),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7D7179),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Limpar selecao'),
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

  List<ProjectTagData> _knownTagsFor(_CharacterTagKind kind) {
    return switch (kind) {
      _CharacterTagKind.gender => _genderTags,
      _CharacterTagKind.sexuality => _sexualityTags,
      _CharacterTagKind.ethnicity => _ethnicityTags,
      _CharacterTagKind.relevance => _relevanceTags,
    };
  }

  String _selectedTagFor(_CharacterTagKind kind) {
    return switch (kind) {
      _CharacterTagKind.gender => _selectedGenderTag,
      _CharacterTagKind.sexuality => _selectedSexualityTag,
      _CharacterTagKind.ethnicity => _selectedEthnicityTag,
      _CharacterTagKind.relevance => _selectedRelevanceTag,
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
      case _CharacterTagKind.relevance:
        _selectedRelevanceTag = value;
        break;
    }
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
        case _CharacterTagKind.relevance:
          _relevanceTags = tags;
          break;
      }
    });

    return newTag.label;
  }
}

enum _CharacterTagKind { gender, sexuality, ethnicity, relevance }

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
    _CharacterTagKind.gender => const ['Mulher', 'Homem', 'Nao binarie'],
    _CharacterTagKind.sexuality => const [
      'Heterossexual',
      'Bissexual',
      'Lesbica',
    ],
    _CharacterTagKind.ethnicity => const ['Branca', 'Preta', 'Parda'],
    _CharacterTagKind.relevance => const [
      'Protagonista',
      'Secundario',
      'Antagonista',
    ],
  };

  return [
    for (var i = 0; i < labels.length; i += 1)
      ProjectTagData(label: labels[i], color: projectTagColorAt(i)),
  ];
}

String _tagKindTitle(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => 'Genero',
    _CharacterTagKind.sexuality => 'Sexualidade',
    _CharacterTagKind.ethnicity => 'Etnia',
    _CharacterTagKind.relevance => 'Relevancia',
  };
}

String _tagKindDescription(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender =>
      'Escolha uma opcao existente ou adicione uma nova para o genero do personagem.',
    _CharacterTagKind.sexuality =>
      'Escolha uma opcao existente ou adicione uma nova para a sexualidade do personagem.',
    _CharacterTagKind.ethnicity =>
      'Escolha uma opcao existente ou adicione uma nova para a etnia do personagem.',
    _CharacterTagKind.relevance =>
      'Escolha uma opcao existente ou adicione uma nova para a relevancia narrativa do personagem.',
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
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [nameField, const SizedBox(height: 10), aliasField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: nameField),
            const SizedBox(width: 10),
            Expanded(child: aliasField),
          ],
        );
      },
    );
  }
}

class _CharacterMetadataSection extends StatelessWidget {
  final Color accentColor;
  final Set<CharacterProfileFieldId> visibleFields;
  final ValueChanged<CharacterProfileFieldId> onToggleFieldVisibility;
  final TextEditingController mottoController;
  final TextEditingController formationsController;
  final TextEditingController titlesController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final bool detailsExpanded;
  final String birthdayLabel;
  final ZodiacSignData birthdaySignData;
  final String heightUnitLabel;
  final String weightUnitLabel;
  final String genderLabel;
  final Color? genderColor;
  final String sexualityLabel;
  final Color? sexualityColor;
  final String ethnicityLabel;
  final Color? ethnicityColor;
  final String relevanceLabel;
  final Color? relevanceColor;
  final VoidCallback onPickBirthday;
  final VoidCallback onOpenBirthdaySign;
  final VoidCallback onPickHeightUnit;
  final VoidCallback onPickWeightUnit;
  final VoidCallback onPickGenderTag;
  final VoidCallback onPickSexualityTag;
  final VoidCallback onPickEthnicityTag;
  final VoidCallback onPickRelevanceTag;
  final VoidCallback onToggleDetailsExpanded;
  final bool bodyExpanded;
  final VoidCallback onToggleBodyExpanded;

  const _CharacterMetadataSection({
    required this.accentColor,
    required this.visibleFields,
    required this.onToggleFieldVisibility,
    required this.mottoController,
    required this.formationsController,
    required this.titlesController,
    required this.weightController,
    required this.heightController,
    required this.detailsExpanded,
    required this.birthdayLabel,
    required this.birthdaySignData,
    required this.heightUnitLabel,
    required this.weightUnitLabel,
    required this.genderLabel,
    required this.genderColor,
    required this.sexualityLabel,
    required this.sexualityColor,
    required this.ethnicityLabel,
    required this.ethnicityColor,
    required this.relevanceLabel,
    required this.relevanceColor,
    required this.onPickBirthday,
    required this.onOpenBirthdaySign,
    required this.onPickHeightUnit,
    required this.onPickWeightUnit,
    required this.onPickGenderTag,
    required this.onPickSexualityTag,
    required this.onPickEthnicityTag,
    required this.onPickRelevanceTag,
    required this.onToggleDetailsExpanded,
    required this.bodyExpanded,
    required this.onToggleBodyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final complementaryCount = <String>[
      mottoController.text.trim(),
      formationsController.text.trim(),
      titlesController.text.trim(),
      genderLabel.trim(),
      sexualityLabel.trim(),
      ethnicityLabel.trim(),
      relevanceLabel.trim(),
    ].where((value) => value.isNotEmpty).length;

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
            'Informacoes do perfil',
            style: TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _CharacterBirthdayDraftField(
            label: 'Aniversario',
            valueLabel: birthdayLabel,
            signData: birthdaySignData,
            accentColor: accentColor,
            onTap: onPickBirthday,
            onTapSign: onOpenBirthdaySign,
          ),
          const SizedBox(height: 10),
          _CharacterDisclosureTile(
            title: 'Medidas',
            summary: 'Peso e altura do personagem',
            accentColor: accentColor,
            isExpanded: bodyExpanded,
            onTap: onToggleBodyExpanded,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: bodyExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final weightField = _CharacterMeasureField(
                            fieldId: CharacterProfileFieldId.weight,
                            label: 'Peso',
                            controller: weightController,
                            hintText: 'Peso do personagem',
                            accentColor: accentColor,
                            visibleFields: visibleFields,
                            onToggleVisibility: onToggleFieldVisibility,
                            icon: Icons.balance_outlined,
                            unitLabel: weightUnitLabel,
                            onPickUnit: onPickWeightUnit,
                          );
                          final heightField = _CharacterMeasureField(
                            fieldId: CharacterProfileFieldId.height,
                            label: 'Altura',
                            controller: heightController,
                            hintText: 'Altura do personagem',
                            accentColor: accentColor,
                            visibleFields: visibleFields,
                            onToggleVisibility: onToggleFieldVisibility,
                            icon: Icons.straighten_rounded,
                            unitLabel: heightUnitLabel,
                            onPickUnit: onPickHeightUnit,
                          );

                          if (constraints.maxWidth < 420) {
                            return Column(
                              children: [
                                weightField,
                                const SizedBox(height: 10),
                                heightField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: weightField),
                              const SizedBox(width: 10),
                              Expanded(child: heightField),
                            ],
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          _CharacterDisclosureTile(
            title: 'Complementos',
            summary: complementaryCount == 0
                ? 'Frase, titulos, ocupacoes e tags'
                : '$complementaryCount campo(s) preenchido(s)',
            accentColor: accentColor,
            isExpanded: detailsExpanded,
            onTap: onToggleDetailsExpanded,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: detailsExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 10),
                      _CharacterToggleField(
                        fieldId: CharacterProfileFieldId.motto,
                        label: 'Frase de efeito',
                        controller: mottoController,
                        hintText:
                            'Frase curta, lema ou linha marcante que ajuda a definir o personagem',
                        accentColor: accentColor,
                        visibleFields: visibleFields,
                        onToggleVisibility: onToggleFieldVisibility,
                        icon: Icons.format_quote_rounded,
                        maxLines: 2,
                        fieldHeight: 82,
                      ),
                      const SizedBox(height: 10),
                      _CharacterCompactField(
                        label: 'Formacoes e ocupacoes',
                        controller: formationsController,
                        hintText:
                            'Area de estudo, oficio, cargo ou funcao social do personagem',
                        focusedColor: accentColor,
                        icon: Icons.work_outline_rounded,
                        maxLines: 3,
                        fieldHeight: 90,
                      ),
                      const SizedBox(height: 10),
                      _CharacterCompactField(
                        label: 'Titulos',
                        controller: titlesController,
                        hintText:
                            'Honrarias, classificacoes, patentes ou nomes cerimoniais associados ao personagem',
                        focusedColor: accentColor,
                        icon: Icons.military_tech_outlined,
                        maxLines: 3,
                        fieldHeight: 90,
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final tagFields = <Widget>[
                            _CharacterTagSelectorField(
                              label: 'Genero',
                              value: genderLabel,
                              accentColor: accentColor,
                              selectedColor: genderColor,
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
                              label: 'Relevancia',
                              value: relevanceLabel,
                              accentColor: accentColor,
                              selectedColor: relevanceColor,
                              onTap: onPickRelevanceTag,
                            ),
                          ];

                          if (constraints.maxWidth < 360) {
                            return Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < tagFields.length;
                                  index++
                                ) ...[
                                  tagFields[index],
                                  if (index < tagFields.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            );
                          }

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
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
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

  const _CharacterCompactField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.focusedColor,
    required this.icon,
    this.maxLines = 1,
    this.validator,
    this.fieldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: fieldHeight ?? (isMultiline ? 84 : 48),
          child: TextFormField(
            controller: controller,
            textInputAction: isMultiline
                ? TextInputAction.newline
                : TextInputAction.next,
            minLines: isMultiline ? null : 1,
            maxLines: isMultiline ? null : 1,
            expands: isMultiline,
            validator: validator,
            textAlignVertical: isMultiline
                ? TextAlignVertical.top
                : TextAlignVertical.center,
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
              ),
              contentPadding: EdgeInsets.fromLTRB(
                8,
                isMultiline ? 12 : 0,
                14,
                isMultiline ? 12 : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterToggleField extends StatelessWidget {
  final CharacterProfileFieldId fieldId;
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color accentColor;
  final Set<CharacterProfileFieldId> visibleFields;
  final ValueChanged<CharacterProfileFieldId> onToggleVisibility;
  final IconData icon;
  final int maxLines;
  final double? fieldHeight;

  const _CharacterToggleField({
    required this.fieldId,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.accentColor,
    required this.visibleFields,
    required this.onToggleVisibility,
    required this.icon,
    this.maxLines = 1,
    this.fieldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = visibleFields.contains(fieldId);
    final isMultiline = maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: fieldHeight ?? (isMultiline ? 84 : 48),
                child: TextFormField(
                  controller: controller,
                  textInputAction: isMultiline
                      ? TextInputAction.newline
                      : TextInputAction.next,
                  minLines: isMultiline ? null : 1,
                  maxLines: isMultiline ? null : 1,
                  expands: isMultiline,
                  textAlignVertical: isMultiline
                      ? TextAlignVertical.top
                      : TextAlignVertical.center,
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
                    contentPadding: EdgeInsets.fromLTRB(
                      8,
                      isMultiline ? 12 : 0,
                      14,
                      isMultiline ? 12 : 0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CharacterVisibilityToggle(
              isVisible: isVisible,
              accentColor: accentColor,
              onTap: () => onToggleVisibility(fieldId),
            ),
          ],
        ),
      ],
    );
  }
}

class _CharacterMeasureField extends StatelessWidget {
  final CharacterProfileFieldId fieldId;
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color accentColor;
  final Set<CharacterProfileFieldId> visibleFields;
  final ValueChanged<CharacterProfileFieldId> onToggleVisibility;
  final IconData icon;
  final String unitLabel;
  final VoidCallback onPickUnit;

  const _CharacterMeasureField({
    required this.fieldId,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.accentColor,
    required this.visibleFields,
    required this.onToggleVisibility,
    required this.icon,
    required this.unitLabel,
    required this.onPickUnit,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = visibleFields.contains(fieldId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _buildCharacterDialogPillDecoration(
                    accentColor: accentColor,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: const Color(0xFF171419)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF3A3339),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        width: 1.3,
                        height: 18,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: accentColor.withValues(alpha: 0.84),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.68),
                            fontSize: 11.8,
                            fontStyle: FontStyle.italic,
                          ),
                          decoration:
                              const InputDecoration.collapsed(
                                hintText: '',
                              ).copyWith(
                                hintText: hintText,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF8E838B),
                                  fontSize: 11.8,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CharacterUnitPillButton(
              accentColor: accentColor,
              label: unitLabel,
              onTap: onPickUnit,
            ),
            const SizedBox(width: 8),
            _CharacterVisibilityToggle(
              isVisible: isVisible,
              accentColor: accentColor,
              onTap: () => onToggleVisibility(fieldId),
            ),
          ],
        ),
      ],
    );
  }
}

class _CharacterVisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final Color accentColor;
  final VoidCallback onTap;

  const _CharacterVisibilityToggle({
    required this.isVisible,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MiniGlassButton(
      accentColor: accentColor,
      icon: isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
      onTap: onTap,
      fillColor: isVisible
          ? accentColor.withValues(alpha: 0.24)
          : Colors.white.withValues(alpha: 0.28),
    );
  }
}

class _CharacterTagSelectorField extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final Color? selectedColor;
  final VoidCallback onTap;

  const _CharacterTagSelectorField({
    required this.label,
    required this.value,
    required this.accentColor,
    this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final effectiveColor = selectedColor ?? accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 78,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: effectiveColor,
            selected: hasValue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasValue ? value : 'Selecionar ou criar',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasValue
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
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 42,
            child: Row(
              children: [
                const Icon(
                  Icons.cake_outlined,
                  size: 18,
                  color: Color(0xFF171419),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3A3339),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  width: 1.3,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: accentColor.withValues(alpha: 0.84),
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
                const SizedBox(width: 8),
                MiniGlassButton(
                  accentColor: accentColor,
                  icon: Icons.edit_calendar_outlined,
                  onTap: onTap,
                ),
              ],
            ),
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
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            signData.name,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.54),
              fontSize: 10,
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
          width: 66,
          height: 48,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Unidade',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.46),
                  fontSize: 7.6,
                  height: 0.9,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(accentColor, 0.22),
                      fontSize: 8.8,
                      height: 0.9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 12,
                    color: _darkenCharacterDialogColor(accentColor, 0.18),
                  ),
                ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                style: const TextStyle(
                  color: Color(0xFF3A3339),
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.casino_rounded,
                size: 13,
                color: _darkenCharacterDialogColor(accentColor, 0.16),
              ),
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
        'Nenhuma opcao cadastrada ainda.',
        style: TextStyle(color: Color(0xFF6A6167), fontSize: 12),
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

  const _CharacterFieldPrefix({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF171419)),
          const SizedBox(width: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 86),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 1.2,
            height: 18,
            margin: const EdgeInsets.only(left: 9),
            color: accentColor.withValues(alpha: 0.76),
          ),
        ],
      ),
    );
  }
}

InputDecoration _buildCharacterDialogFieldDecoration({
  required String hintText,
  required Color focusedColor,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
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

BoxDecoration _buildCharacterDialogPillDecoration({
  required Color accentColor,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.42),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: Colors.white.withValues(alpha: 0.76)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.64),
        accentColor.withValues(alpha: 0.12),
        _lightenCharacterDialogColor(accentColor, 0.22).withValues(alpha: 0.08),
      ],
    ),
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
