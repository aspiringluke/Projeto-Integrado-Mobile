import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../projects/models/project_image_data.dart';
import '../../projects/models/project_tag_data.dart';
import '../../projects/widgets/project_color_editor.dart';
import '../../projects/utils/project_image_picker.dart';
import '../../projects/utils/project_image_picker_result.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';
import '../../projects/widgets/project_image_transform_view.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../../shared/widgets/main_header.dart';
import '../../tags/controllers/tag_controller.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_card_visuals.dart';
import 'character_fields.dart';
import 'character_placeholder_texts.dart';
import 'character_profile_viewer_dialog.dart';

part 'character_notebook_parts/character_notebook_psychology.dart';
part 'character_notebook_parts/character_notebook_header.dart';
part 'character_notebook_parts/character_notebook_editor_widgets.dart';
part 'character_notebook_parts/character_notebook_relevance.dart';
part 'character_notebook_parts/character_notebook_relevance_model.dart';
part 'character_notebook_parts/character_notebook_navigation.dart';
part 'character_notebook_parts/character_notebook_history.dart';

class CharacterNotebookPage extends StatefulWidget {
  final CharacterCardData data;
  final List<CharacterListItem> availableCharacters;
  final ValueChanged<CharacterCardData>? onChanged;

  const CharacterNotebookPage({
    super.key,
    required this.data,
    this.availableCharacters = const <CharacterListItem>[],
    this.onChanged,
  });

  @override
  State<CharacterNotebookPage> createState() => _CharacterNotebookPageState();
}

class _CharacterNotebookPageState extends State<CharacterNotebookPage> {
  static const Map<_NotebookTab, _NotebookTabMeta> _tabs =
      <_NotebookTab, _NotebookTabMeta>{
        _NotebookTab.geral: _NotebookTabMeta(
          label: 'Geral',
          icon: Icons.person_outline_rounded,
        ),
        _NotebookTab.notas: _NotebookTabMeta(
          label: 'Notas',
          icon: Icons.sticky_note_2_rounded,
        ),
        _NotebookTab.psique: _NotebookTabMeta(
          label: 'Psique',
          icon: Icons.psychology_rounded,
        ),
        _NotebookTab.historia: _NotebookTabMeta(
          label: 'História',
          icon: Icons.history_edu_rounded,
        ),
        _NotebookTab.design: _NotebookTabMeta(
          label: 'Design',
          icon: Icons.palette_outlined,
        ),
      };

  late CharacterCardData _draft;
  late TextEditingController _nameController;
  late TextEditingController _aliasController;
  late TextEditingController _synopsisController;
  late TextEditingController _mottoController;
  late TextEditingController _formationsController;
  late TextEditingController _titlesController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _historySearchController;
  late ScrollController _synopsisScrollController;
  late final ValueNotifier<CharacterCardData> _headerDraftNotifier;
  late Map<_TagKind, TagController> _tagControllers;
  late Map<_NotebookSection, GlobalKey> _sectionKeys;
  _NotebookTab _activeTab = _NotebookTab.geral;
  _CharacterColorTarget _activeColorTarget = _CharacterColorTarget.cover;
  bool _hasPendingParentSync = false;
  bool _didFlushParentSync = false;

  DateTime? _birthdayValue;
  double? _heightCmValue;
  double? _weightKgValue;
  HeightUnit _heightUnit = HeightUnit.centimeters;
  WeightUnit _weightUnit = WeightUnit.kilograms;
  _RelevanceParameterBundle _relevance = _RelevanceParameterBundle.defaults();
  _RelevanceEditorMode _relevanceMode = _RelevanceEditorMode.advanced;
  String _selectedGenderTag = '';
  String _selectedSexualityTag = '';
  String _selectedEthnicityTag = '';
  String _selectedFunctionTag = '';
  String _selectedRelevanceTag = '';
  String? _selectedPsychTraitId;
  String? _selectedPsychFacetId;
  late _CharacterHistoryDraft _historyDraft;
  String _historySearchQuery = '';
  final Set<String> _collapsedHistoryYears = <String>{};

  @override
  void initState() {
    super.initState();
    _draft = widget.data;
    _headerDraftNotifier = ValueNotifier<CharacterCardData>(_draft);
    _birthdayValue = DateTime(
      _draft.birthYear,
      _draft.birthMonth,
      _draft.birthDay,
    );
    _heightCmValue = _draft.heightCm;
    _weightKgValue = _draft.weightKg;
    _nameController = TextEditingController(text: _draft.name);
    _aliasController = TextEditingController(text: _draft.alias);
    _synopsisController = TextEditingController(text: _draft.synopsis);
    _synopsisController.addListener(_syncSynopsisDraft);
    _mottoController = TextEditingController(text: _draft.motto);
    _mottoController.addListener(_syncMottoDraft);
    _formationsController = TextEditingController(
      text: _draft.formationsAndOccupations,
    );
    _titlesController = TextEditingController(text: _draft.titles);
    _heightController = TextEditingController(
      text: formatHeightEditorValue(_draft.heightCm, _heightUnit),
    );
    _weightController = TextEditingController(
      text: formatWeightEditorValue(_draft.weightKg, _weightUnit),
    );
    _historySearchController = TextEditingController();
    _synopsisScrollController = ScrollController();
    _tagControllers = <_TagKind, TagController>{
      for (final kind in _TagKind.values)
        kind: TagController(
          knownTags: _seedTagsFor(kind),
          groupTitle: _tagGroupStorageTitle(kind),
        ),
    };
    _sectionKeys = {
      for (final section in _NotebookSection.values) section: GlobalKey(),
    };

    _relevance = _readStoredRelevanceBundle(
      _draft.notebookComplexityValues,
      fallbackTag: _draft.relevanceTag,
    );
    _relevanceMode = _readStoredRelevanceMode(_draft.notebookComplexityValues);
    _selectedGenderTag = _draft.genderTag;
    _selectedSexualityTag = _draft.sexualityTag;
    _selectedEthnicityTag = _draft.ethnicityTag;
    _selectedFunctionTag = _draft.functionTag;
    _selectedRelevanceTag = _draft.relevanceTag;
    if (_selectedRelevanceTag.isEmpty) {
      _selectedRelevanceTag = _relevance
          .categoryForScore(_relevance.score)
          .name;
    }
    final seededPsychValues = Map<String, String>.from(
      _draft.notebookComplexityValues,
    );
    for (final trait in _psychBigFiveCatalog) {
      for (final facet in trait.facets) {
        seededPsychValues.putIfAbsent(
          _psychFacetStorageKey(trait.id, facet.id),
          () => '5.0',
        );
      }
    }
    if (seededPsychValues.length != _draft.notebookComplexityValues.length) {
      _draft = _draft.copyWith(notebookComplexityValues: seededPsychValues);
    }
    _historyDraft = _decodeCharacterHistory(_draft.notebookComplexityValues);
    _selectedPsychTraitId = _psychBigFiveCatalog.first.id;
    _selectedPsychFacetId = _psychBigFiveCatalog.first.facets.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _synopsisController.removeListener(_syncSynopsisDraft);
    _synopsisController.dispose();
    _mottoController.removeListener(_syncMottoDraft);
    _mottoController.dispose();
    _headerDraftNotifier.dispose();
    _formationsController.dispose();
    _titlesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _historySearchController.dispose();
    _synopsisScrollController.dispose();
    for (final controller in _tagControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setActiveTab(_NotebookTab tab) {
    if (_activeTab == tab) return;

    setState(() {
      _activeTab = tab;
    });
  }

  void _updateDraft(CharacterCardData next, {bool rebuild = true}) {
    if (identical(next, _draft)) return;

    if (rebuild) {
      setState(() {
        _draft = next;
      });
    } else {
      _draft = next;
    }
    _headerDraftNotifier.value = next;
    _hasPendingParentSync = true;
  }

  void _rebuildNotebook() {
    setState(() {});
  }

  void _flushDraftToParent() {
    if (_didFlushParentSync || !_hasPendingParentSync) {
      return;
    }

    _didFlushParentSync = true;
    widget.onChanged?.call(_draft);
  }

  void _closePage() {
    _flushDraftToParent();
    Navigator.of(context).pop();
  }

  void _syncSynopsisDraft() {
    final text = _synopsisController.text;
    if (text == _draft.synopsis) return;
    _updateDraft(_draft.copyWith(synopsis: text), rebuild: false);
  }

  void _syncMottoDraft() {
    final text = _mottoController.text;
    if (text == _draft.motto && text == _draft.quote) return;
    _updateDraft(_draft.copyWith(motto: text, quote: text), rebuild: false);
  }

  void _clearMenuFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  DateTime get _birthday => _birthdayValue ??= DateTime(
    _draft.birthYear,
    _draft.birthMonth,
    _draft.birthDay,
  );

  double get _heightCm => _heightCmValue ??= _draft.heightCm;
  double get _weightKg => _weightKgValue ??= _draft.weightKg;
  ZodiacSignData get _signData => zodiacSignFor(_birthday);

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _flushDraftToParent();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF2F8),
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/images/FUNDO.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.72, -0.88),
                        radius: 1.25,
                        colors: [
                          _draft.accent.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RepaintBoundary(
                  child: ValueListenableBuilder<CharacterCardData>(
                    valueListenable: _headerDraftNotifier,
                    builder: (context, headerDraft, _) {
                      return _NotebookHeader(
                        data: headerDraft,
                        onClose: _closePage,
                        onProfileImageChanged: _updateProfileImage,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PageStickyTabs(
                          accentColor: _draft.accent,
                          activeTab: _activeTab,
                          tabs: _tabs,
                          onTabSelected: _setActiveTab,
                        ),
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
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
                                child: _buildTabContent(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_activeTab) {
      _NotebookTab.geral => _buildGeneralTab(),
      _NotebookTab.psique => _buildPsychologyWorkbench(),
      _NotebookTab.historia => _buildHistoryTab(),
      _NotebookTab.notas => _buildPlaceholderTab(
        title: 'Notas',
        subtitle: 'Observações rápidas, rastros e pendências.',
        icon: Icons.sticky_note_2_rounded,
      ),
      _NotebookTab.design => _buildPlaceholderTab(
        title: 'Design',
        subtitle: 'Paleta, referências visuais e direção estética.',
        icon: Icons.palette_outlined,
      ),
    };
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyedSubtree(
            key: _sectionKeys[_NotebookSection.identidade],
            child: _CollapsibleSection(
              accentColor: _draft.accent,
              leadingIconColor: _draft.avatarColor,
              title: 'Identidade',
              subtitle: '',
              fields: const [
                'Nome',
                'Vulgo',
                'Relevância',
                'Síntese',
                'Frase de efeito',
                'Formações',
                'Títulos',
              ],
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.badge_outlined,
                    label: 'Nome',
                    placeholderText: _namePlaceholderText,
                    controller: _nameController,
                    onChanged: (value) => _updateDraft(
                      _draft.copyWith(name: value),
                      rebuild: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.alternate_email_rounded,
                    label: 'Vulgo',
                    placeholderText: _aliasPlaceholderText,
                    controller: _aliasController,
                    onChanged: (value) => _updateDraft(
                      _draft.copyWith(alias: value),
                      rebuild: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CharacterRelevanceSelectorField(
                    value: _selectedRelevanceTag,
                    selectedColor: _relevance
                        .categoryForScore(_effectiveRelevanceScore())
                        .color,
                    accentColor: _draft.accent,
                    categories: _relevance.categories,
                    showError: false,
                    score: _effectiveRelevanceScore(),
                    onTap: _openRelevanceSelector,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 8),
                      child: Text(
                        'Síntese',
                        style: TextStyle(
                          color: const Color(
                            0xFF3A3339,
                          ).withValues(alpha: 0.92),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  _buildIdentitySynopsisPanel(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 8),
                      child: Text(
                        'Frase de efeito',
                        style: TextStyle(
                          color: const Color(
                            0xFF3A3339,
                          ).withValues(alpha: 0.92),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  CharacterQuoteStrip(
                    accentColor: _draft.accent,
                    controller: _mottoController,
                    isEditing: true,
                    hintText: _mottoPlaceholderText,
                    showHintText: false,
                    tooltipText: _mottoPlaceholderText,
                  ),
                  const SizedBox(height: 12),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.work_outline_rounded,
                    label: 'Formações e ocupações',
                    placeholderText: _formationsPlaceholderText,
                    controller: _formationsController,
                    minLines: 1,
                    maxLines: null,
                    onChanged: (value) => _updateDraft(
                      _draft.copyWith(formationsAndOccupations: value),
                      rebuild: false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.military_tech_outlined,
                    label: 'Títulos',
                    placeholderText: _titlesPlaceholderText,
                    controller: _titlesController,
                    minLines: 1,
                    maxLines: null,
                    onChanged: (value) => _updateDraft(
                      _draft.copyWith(titles: value),
                      rebuild: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _sectionKeys[_NotebookSection.tags],
            child: _CollapsibleSection(
              accentColor: _draft.accent,
              leadingIconColor: _draft.avatarColor,
              title: 'Tags',
              subtitle: '',
              fields: const ['Gênero', 'Sexualidade', 'Etnia', 'Função'],
              icon: Icons.sell_outlined,
              child: _CharacterIdentityTagGrid(
                genderLabel: _selectedGenderTag,
                genderColor: _tagColorFor(_TagKind.gender, _selectedGenderTag),
                sexualityLabel: _selectedSexualityTag,
                sexualityColor: _tagColorFor(
                  _TagKind.sexuality,
                  _selectedSexualityTag,
                ),
                ethnicityLabel: _selectedEthnicityTag,
                ethnicityColor: _tagColorFor(
                  _TagKind.ethnicity,
                  _selectedEthnicityTag,
                ),
                functionLabel: _selectedFunctionTag,
                functionColor: _tagColorFor(
                  _TagKind.function,
                  _selectedFunctionTag,
                ),
                accentColor: _draft.accent,
                showRequiredErrors: false,
                onPickGenderTag: () => _openTagSelector(_TagKind.gender),
                onPickSexualityTag: () => _openTagSelector(_TagKind.sexuality),
                onPickEthnicityTag: () => _openTagSelector(_TagKind.ethnicity),
                onPickFunctionTag: () => _openTagSelector(_TagKind.function),
              ),
            ),
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _sectionKeys[_NotebookSection.medidas],
            child: _CollapsibleSection(
              accentColor: _draft.accent,
              leadingIconColor: _draft.avatarColor,
              title: 'Medidas',
              subtitle: '',
              fields: const ['Aniversário', 'Altura', 'Peso'],
              icon: Icons.straighten_rounded,
              child: Column(
                children: [
                  CharacterBirthdayField(
                    accentColor: _draft.accent,
                    birthdayLabel: formatBirthdayLabel(
                      _birthday.day,
                      _birthday.month,
                    ),
                    signData: _signData,
                    isEditing: true,
                    onTapBirthday: _selectBirthday,
                    onTapSign: (_) => _openBirthdaySignSheet(_signData),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CharacterHeightField(
                          accentColor: _draft.accent,
                          heightLabel: formatHeightLabel(
                            _heightCm,
                            _heightUnit,
                          ),
                          unitLabel: heightUnitCompactLabel(_heightUnit),
                          controller: _heightController,
                          isEditing: true,
                          onTapUnit: _selectHeightUnit,
                          onCommitHeight: _commitHeightText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CharacterWeightField(
                          accentColor: _draft.accent,
                          weightLabel: formatWeightLabel(
                            _weightKg,
                            _weightUnit,
                          ),
                          unitLabel: weightUnitCompactLabel(_weightUnit),
                          controller: _weightController,
                          isEditing: true,
                          onTapUnit: _selectWeightUnit,
                          onCommitWeight: _commitWeightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          KeyedSubtree(
            key: _sectionKeys[_NotebookSection.imagem],
            child: _CollapsibleSection(
              accentColor: _draft.accent,
              leadingIconColor: _draft.avatarColor,
              title: 'Imagem e cor',
              subtitle: '',
              fields: const ['Foto', 'Cor de capa', 'Cor de realce'],
              icon: Icons.auto_awesome_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ColorTile(
                          accentColor: _draft.accent,
                          label: 'Capa',
                          color: _draft.avatarColor,
                          isSelected:
                              _activeColorTarget == _CharacterColorTarget.cover,
                          onTap: () => setState(() {
                            _activeColorTarget = _CharacterColorTarget.cover;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ColorTile(
                          accentColor: _draft.accent,
                          label: 'Realce',
                          color: _draft.accent,
                          isSelected:
                              _activeColorTarget ==
                              _CharacterColorTarget.accent,
                          onTap: () => setState(() {
                            _activeColorTarget = _CharacterColorTarget.accent;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProjectColorEditor(
                    title: _activeColorTarget == _CharacterColorTarget.cover
                        ? 'Cor da capa'
                        : 'Cor de realce',
                    description:
                        _activeColorTarget == _CharacterColorTarget.cover
                        ? 'Ajuste a cor base da capa do personagem em HSL.'
                        : 'Ajuste a cor principal de destaque em HSL.',
                    color: _activeColorTarget == _CharacterColorTarget.cover
                        ? _draft.avatarColor
                        : _draft.accent,
                    accentColor: _draft.accent,
                    hslColor: HSLColor.fromColor(
                      _activeColorTarget == _CharacterColorTarget.cover
                          ? _draft.avatarColor
                          : _draft.accent,
                    ),
                    useSolidCoverPreview:
                        _activeColorTarget == _CharacterColorTarget.cover,
                    onHueChanged: (value) {
                      final sourceColor =
                          _activeColorTarget == _CharacterColorTarget.cover
                          ? _draft.avatarColor
                          : _draft.accent;
                      final next = HSLColor.fromColor(
                        sourceColor,
                      ).withHue(value).toColor();
                      _updateActiveColor(next);
                    },
                    onSaturationChanged: (value) {
                      final sourceColor =
                          _activeColorTarget == _CharacterColorTarget.cover
                          ? _draft.avatarColor
                          : _draft.accent;
                      final next = HSLColor.fromColor(
                        sourceColor,
                      ).withSaturation(value).toColor();
                      _updateActiveColor(next);
                    },
                    onLightnessChanged: (value) {
                      final sourceColor =
                          _activeColorTarget == _CharacterColorTarget.cover
                          ? _draft.avatarColor
                          : _draft.accent;
                      final next = HSLColor.fromColor(
                        sourceColor,
                      ).withLightness(value).toColor();
                      _updateActiveColor(next);
                    },
                  ),
                  const SizedBox(height: 12),
                  CharacterAvatarTile(
                    accent: _draft.accent,
                    avatarColor: _draft.avatarColor,
                    profileImage: _draft.profileImage,
                    isExpanded: true,
                    onTap: _draft.profileImage.bytes == null
                        ? null
                        : _openProfileImageViewer,
                  ),
                  const SizedBox(height: 12),
                  _ImageTile(
                    accentColor: _draft.accent,
                    avatarColor: _draft.avatarColor,
                    image: _draft.profileImage,
                    imageLabel: _draft.profileImage.bytes == null
                        ? 'Nenhuma foto adicionada'
                        : 'Foto de perfil carregada',
                    onScaleChanged: _setProfileImageScale,
                    onOffsetChanged: _setProfileImageOffset,
                    onPickImage: _pickProfileImage,
                    onRemoveImage: _draft.profileImage.bytes == null
                        ? null
                        : _removeProfileImage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: _PlaceholderPageCard(
        accentColor: _draft.accent,
        title: title,
        subtitle: subtitle,
        icon: icon,
      ),
    );
  }

  Widget _buildPsychologyWorkbench() {
    final selectedTrait = _psychTraitDefinitionFor(_selectedPsychTraitId);
    final selectedFacet = _psychFacetDefinitionFor(
      selectedTrait,
      _selectedPsychFacetId ?? selectedTrait.facets.first.id,
    );

    Widget buildBigFiveChart() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PsychRadarCard(
            accentColor: _draft.avatarColor,
            pointColor: _draft.accent,
            title: 'Big Five',
            subtitle: 'clique para mostrar opções do traço',
            nodes: _psychBigFiveRadarNodes,
            values: _psychTraitValues,
            selectedNodeId: _selectedPsychTraitId,
            selectedNodeScale: 1.12,
            onNodeSelected: _selectPsychTrait,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _draft.avatarColor.withValues(alpha: 0.08),
              ),
            ),
            child: SizedBox(
              height: 62,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var index = 0;
                    index < _psychBigFiveCatalog.length;
                    index += 1
                  )
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == _psychBigFiveCatalog.length - 1
                              ? 0
                              : 6,
                        ),
                        child: _PsychTraitQuickButton(
                          accentColor: _draft.accent,
                          icon: _psychTraitIconFor(
                            _psychBigFiveCatalog[index].id,
                          ),
                          trait: _psychBigFiveCatalog[index],
                          selected:
                              _selectedPsychTraitId ==
                              _psychBigFiveCatalog[index].id,
                          onTap: () =>
                              _selectPsychTrait(_psychBigFiveCatalog[index].id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget buildFacetChart() {
      return _PsychFacetBarCard(
        accentColor: _draft.accent,
        trait: selectedTrait,
        values: _psychFacetValuesFor(selectedTrait.id),
        selectedFacetId: selectedFacet.id,
        onFacetSelected: _selectPsychFacet,
        onFacetChanged: _setPsychFacetValue,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.white.withValues(alpha: 0.58),
          border: Border.all(
            color: _draft.accent.withValues(alpha: 0.10),
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final charts = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildBigFiveChart(),
                const SizedBox(height: 10),
                buildFacetChart(),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [charts],
            );
          },
        ),
      ),
    );
  }

  List<_PsychRadarNodeDefinition> get _psychBigFiveRadarNodes {
    return [
      for (final trait in _psychBigFiveCatalog)
        _PsychRadarNodeDefinition(
          id: trait.id,
          label: trait.label,
          chartLabel: trait.chartLabel,
          description: trait.description,
          color: trait.color,
        ),
    ];
  }

  Map<String, double> get _psychTraitValues {
    return {
      for (final trait in _psychBigFiveCatalog)
        trait.id: _psychTraitValue(trait.id),
    };
  }

  double _psychTraitValue(String traitId) {
    final trait = _psychTraitDefinitionFor(traitId);
    if (trait.facets.isEmpty) return 0;
    final total = trait.facets.fold<double>(
      0,
      (sum, facet) => sum + _psychFacetValue(trait.id, facet.id),
    );
    return (total / trait.facets.length).clamp(0.0, 10.0).toDouble();
  }

  Map<String, double> _psychFacetValuesFor(String? traitId) {
    final trait = _psychTraitDefinitionFor(traitId);
    return {
      for (final facet in trait.facets)
        facet.id: _psychFacetValue(trait.id, facet.id),
    };
  }

  double _psychFacetValue(String traitId, String facetId) {
    final storedValue = _draft
        .notebookComplexityValues[_psychFacetStorageKey(traitId, facetId)];
    final parsedValue = double.tryParse(storedValue ?? '');
    return (parsedValue ?? 5.0).clamp(0.0, 10.0).toDouble();
  }

  void _setPsychFacetValue(String traitId, String facetId, double value) {
    final nextValues = Map<String, String>.from(
      _draft.notebookComplexityValues,
    );
    nextValues[_psychFacetStorageKey(traitId, facetId)] = value
        .clamp(0.0, 10.0)
        .toStringAsFixed(1);
    _updateDraft(_draft.copyWith(notebookComplexityValues: nextValues));
  }

  void _selectPsychTrait(String traitId) {
    final trait = _psychTraitDefinitionFor(traitId);
    setState(() {
      _selectedPsychTraitId = traitId;
      final hasCurrentFacet =
          _selectedPsychFacetId != null &&
          trait.facets.any((facet) => facet.id == _selectedPsychFacetId);
      _selectedPsychFacetId = hasCurrentFacet
          ? _selectedPsychFacetId
          : (trait.facets.isEmpty ? null : trait.facets.first.id);
    });
  }

  _PsychTraitDefinition _psychTraitDefinitionFor(String? traitId) {
    if (traitId == null) {
      return _psychBigFiveCatalog.first;
    }
    return _psychBigFiveCatalog.firstWhere(
      (trait) => trait.id == traitId,
      orElse: () => _psychBigFiveCatalog.first,
    );
  }

  _PsychFacetDefinition _psychFacetDefinitionFor(
    _PsychTraitDefinition trait,
    String facetId,
  ) {
    return trait.facets.firstWhere(
      (facet) => facet.id == facetId,
      orElse: () => trait.facets.first,
    );
  }

  void _selectPsychFacet(String facetId) {
    setState(() {
      _selectedPsychFacetId = facetId;
    });
  }

  String _psychFacetStorageKey(String traitId, String facetId) {
    return '$traitId::$facetId';
  }

  Widget _buildIdentitySynopsisPanel() {
    const textStyle = TextStyle(
      color: Color(0xFF8F8990),
      fontSize: 11,
      height: 1.35,
    );
    const placeholderStyle = TextStyle(
      color: Color(0xFF8F8990),
      fontSize: 11,
      height: 1.35,
      fontStyle: FontStyle.italic,
    );
    const scrollPadding = EdgeInsets.only(right: 10);
    final panelPadding = const EdgeInsets.all(12);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _synopsisController,
          builder: (context, value, child) {
            return EditableSynopsisPanel(
              controller: _synopsisController,
              scrollController: _synopsisScrollController,
              isEditing: true,
              height: _calculateSynopsisEditorHeight(
                context: context,
                maxWidth: constraints.maxWidth,
                textStyle: textStyle,
                panelPadding: panelPadding,
                scrollPadding: scrollPadding,
              ),
              focusedBorderColor: _draft.accent,
              placeholderText: synopsisPlaceholderText,
              textStyle: textStyle,
              fillColor: Colors.white.withValues(alpha: 0.72),
              blurSigma: 4,
              backgroundGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  const Color(0xFFFFF8FC).withValues(alpha: 0.68),
                  const Color(0xFFF1E6EE).withValues(alpha: 0.42),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              panelPadding: panelPadding,
              scrollPadding: scrollPadding,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.78),
                width: 0.7,
              ),
              placeholderStyle: placeholderStyle,
              viewerBuilder: (context, text, style) {
                return CharacterMarkdownText(data: text, style: style);
              },
            );
          },
        );
      },
    );
  }

  double _calculateSynopsisEditorHeight({
    required BuildContext context,
    required double maxWidth,
    required TextStyle textStyle,
    required EdgeInsetsGeometry panelPadding,
    required EdgeInsetsGeometry scrollPadding,
  }) {
    final text = _synopsisController.text.trim().isEmpty
        ? synopsisPlaceholderText
        : _synopsisController.text;
    final resolvedPanelPadding = panelPadding.resolve(
      Directionality.of(context),
    );
    final resolvedScrollPadding = scrollPadding.resolve(
      Directionality.of(context),
    );
    final availableWidth = max(
      0.0,
      maxWidth -
          resolvedPanelPadding.horizontal -
          resolvedScrollPadding.horizontal,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: Directionality.of(context),
      maxLines: null,
    )..layout(maxWidth: availableWidth);
    final lineHeight = (textStyle.fontSize ?? 11) * (textStyle.height ?? 1.0);
    final estimatedHeight =
        textPainter.size.height + resolvedPanelPadding.vertical;

    return estimatedHeight.clamp(
      lineHeight + resolvedPanelPadding.vertical,
      220.0,
    );
  }

  Future<void> _pickProfileImage() async {
    ProjectImagePickResult? result;
    try {
      result = await pickProjectImage();
    } on ProjectImagePickException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted || result == null) return;

    _updateDraft(
      _draft.copyWith(
        profileImage: ProjectImageData(
          bytes: result.bytes,
          width: result.width,
          height: result.height,
        ),
      ),
    );
  }

  void _removeProfileImage() {
    _updateDraft(_draft.copyWith(profileImage: const ProjectImageData()));
  }

  void _updateProfileImage(ProjectImageData image) {
    _updateDraft(_draft.copyWith(profileImage: image));
  }

  void _setProfileImageScale(double scale) {
    _updateProfileImage(_draft.profileImage.copyWith(scale: scale));
  }

  void _setProfileImageOffset(double offsetX, double offsetY) {
    _updateProfileImage(
      _draft.profileImage.copyWith(offsetX: offsetX, offsetY: offsetY),
    );
  }

  Future<void> _openProfileImageViewer() async {
    if (_draft.profileImage.bytes == null) {
      return;
    }

    await showCharacterProfileViewerDialog(
      context,
      characterName: _draft.name,
      profileImage: _draft.profileImage,
    );
  }

  void _updateActiveColor(Color color) {
    switch (_activeColorTarget) {
      case _CharacterColorTarget.cover:
        _updateDraft(_draft.copyWith(avatarColor: color));
        break;
      case _CharacterColorTarget.accent:
        _updateDraft(_draft.copyWith(accent: color));
        break;
    }
  }

  Future<void> _selectBirthday() async {
    _clearMenuFocus();
    var tempMonth = _birthday.month;
    var tempDay = _birthday.day;
    final monthController = FixedExtentScrollController(
      initialItem: tempMonth - 1,
    );
    final dayController = FixedExtentScrollController(initialItem: tempDay - 1);

    final selectedDate = await showProjectDismissibleSheet<DateTime>(
      context: context,
      title: 'Aniversario',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 188,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BirthdayWheel(
                          label: 'Mês',
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
                        child: _BirthdayWheel(
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
            );
          },
        );
      },
    );

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      monthController.dispose();
      dayController.dispose();
    });

    _clearMenuFocus();
    if (!mounted || selectedDate == null) return;
    _birthdayValue = selectedDate;
    _updateDraft(
      _draft.copyWith(
        birthYear: selectedDate.year,
        birthMonth: selectedDate.month,
        birthDay: selectedDate.day,
      ),
    );
  }

  Future<void> _openBirthdaySignSheet(ZodiacSignData currentSign) async {
    _clearMenuFocus();
    final selectedDate = await showProjectDismissibleSheet<DateTime>(
      context: context,
      title: '${currentSign.symbol} ${currentSign.name}',
      builder: (context) {
        final accent = _draft.accent;
        final signs = _allZodiacSigns();
        final descriptionLines = currentSign.description.split('\n');
        final signDateRange = descriptionLines.isNotEmpty
            ? descriptionLines.first.trim()
            : '';
        final traits = descriptionLines.length > 1
            ? descriptionLines.sublist(1).join(' ').trim()
            : '';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
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
                              color: _darkenCharacterDialogColor(accent, 0.22),
                              fontSize: 11.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (traits.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      traits,
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
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
                          'Sortear aniversário por signo',
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
        );
      },
    );

    _clearMenuFocus();
    if (!mounted || selectedDate == null) return;
    _birthdayValue = selectedDate;
    _updateDraft(
      _draft.copyWith(
        birthYear: selectedDate.year,
        birthMonth: selectedDate.month,
        birthDay: selectedDate.day,
      ),
    );
  }

  Future<void> _openTagSelector(_TagKind kind) async {
    _clearMenuFocus();
    final inputController = TextEditingController();
    final selectedLabel = _selectedTagFor(kind);
    final result = await showProjectDismissibleSheet<String>(
      context: context,
      title: _tagKindTitle(kind),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tags = _knownTagsFor(kind);
            final accent = _draft.accent;

            return Column(
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
                      ? _NotebookTagEmptyState(accentColor: accent)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 8.0;
                            final columnCount = constraints.maxWidth < 340
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
                                    child: _NotebookTagOptionButton(
                                      tag: tag,
                                      isSelected: tag.label == selectedLabel,
                                      onTap: () =>
                                          Navigator.of(context).pop(tag.label),
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
                            decoration: _buildTagInputDecoration(
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
                            backgroundColor: const Color(0xFFDF6EB8),
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
                const SizedBox(height: 8),
                if (selectedLabel.isNotEmpty) ...[
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
            );
          },
        );
      },
    );

    Future<void>.delayed(
      const Duration(milliseconds: 300),
      inputController.dispose,
    );
    _clearMenuFocus();
    if (!mounted || result == null) return;
    _setSelectedTag(kind, result);
    _updateDraft(
      _draft.copyWith(
        genderTag: _selectedGenderTag,
        sexualityTag: _selectedSexualityTag,
        ethnicityTag: _selectedEthnicityTag,
        functionTag: _selectedFunctionTag,
      ),
    );
  }

  double _effectiveRelevanceScore() {
    return _relevance.score;
  }

  Map<String, double> _applyUniformRelevanceValue({
    required List<_RelevanceParameter> parameters,
    required double score,
  }) {
    final clampedScore = score.clamp(0.0, 10.0).toDouble();
    return {for (final parameter in parameters) parameter.id: clampedScore};
  }

  Future<void> _openRelevanceSelector() async {
    _clearMenuFocus();
    var tempParameters = List<_RelevanceParameter>.from(_relevance.parameters);
    var editingParameterIds = <String>{};
    var tempValues = Map<String, double>.from(_relevance.values);
    var tempWeights = Map<String, double>.from(_relevance.weights);
    var tempMode = _relevanceMode;

    final result = await showDialog<_RelevanceParameterBundle>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tempBundle = _RelevanceParameterBundle(
              parameters: tempParameters,
              values: tempValues,
              weights: tempWeights,
            );
            final score = tempBundle.score;
            final category = tempBundle.categoryForScore(score);
            final screenSize = MediaQuery.sizeOf(context);
            final menuHeight = min(max(screenSize.height - 150, 260.0), 620.0);

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
                      height: menuHeight,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RelevanceSummaryCard(
                            score: score,
                            category: category,
                            categories: tempBundle.categories,
                            onScoreChanged:
                                tempMode == _RelevanceEditorMode.simple
                                ? (nextScore) {
                                    setModalState(() {
                                      tempValues = _applyUniformRelevanceValue(
                                        parameters: tempParameters,
                                        score: nextScore,
                                      );
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _RelevanceEditorToolbar(
                            mode: tempMode,
                            onModeChanged: (mode) {
                              setModalState(() {
                                tempMode = mode;
                              });
                            },
                            onReset: () {
                              setModalState(() {
                                editingParameterIds = <String>{};
                                tempParameters = _defaultRelevanceParameters();
                                tempValues = {
                                  for (final parameter in tempParameters)
                                    parameter.id: 0,
                                };
                                tempWeights = {
                                  for (final parameter in tempParameters)
                                    parameter.id: parameter.weight,
                                };
                              });
                            },
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
                                  if (tempMode ==
                                      _RelevanceEditorMode.advanced) ...[
                                    _RelevanceFormulaNote(
                                      accentColor: _draft.accent,
                                    ),
                                    const SizedBox(height: 10),
                                    for (final parameter in tempParameters) ...[
                                      _RelevanceParameterControl(
                                        parameter: parameter,
                                        value: tempValues[parameter.id] ?? 0,
                                        weight:
                                            tempWeights[parameter.id] ??
                                            parameter.weight,
                                        canRemove: tempParameters.length > 1,
                                        canResetToDefault:
                                            _defaultRelevanceParameterById(
                                              parameter.id,
                                            ) !=
                                            null,
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
                                        onResetToDefault: () {
                                          final defaultParameter =
                                              _defaultRelevanceParameterById(
                                                parameter.id,
                                              );
                                          if (defaultParameter == null) {
                                            return;
                                          }
                                          setModalState(() {
                                            tempParameters = [
                                              for (final item in tempParameters)
                                                item.id == parameter.id
                                                    ? defaultParameter
                                                    : item,
                                            ];
                                            tempWeights =
                                                _redistributeRelevanceWeights(
                                                  parameters: tempParameters,
                                                  weights: {
                                                    ...tempWeights,
                                                    parameter.id:
                                                        defaultParameter.weight,
                                                  },
                                                  changedId: parameter.id,
                                                  requestedWeight:
                                                      defaultParameter.weight,
                                                );
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
                                      _RelevanceParameterBundle(
                                        parameters: tempParameters,
                                        values: tempValues,
                                        weights: tempWeights,
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

    _clearMenuFocus();
    if (!mounted || result == null) return;
    setState(() {
      _relevance = result;
      _relevanceMode = tempMode;
      _selectedRelevanceTag = result.categoryForScore(result.score).name;
      _updateDraft(
        _draft.copyWith(
          relevanceTag: _selectedRelevanceTag,
          notebookComplexityValues: _storeRelevanceBundle(
            _draft.notebookComplexityValues,
            result,
            mode: _relevanceMode,
          ),
        ),
        rebuild: false,
      );
    });
  }

  Future<void> _selectHeightUnit() async {
    _clearMenuFocus();
    final selectedUnit = await showProjectDismissibleSheet<HeightUnit>(
      context: context,
      title: 'Unidade de medida',
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final unit in HeightUnit.values)
              _UnitOption(
                label: heightUnitMenuLabel(unit),
                isSelected: unit == _heightUnit,
                onTap: () => Navigator.of(context).pop(unit),
              ),
          ],
        );
      },
    );

    _clearMenuFocus();
    if (!mounted || selectedUnit == null) return;
    setState(() {
      _heightUnit = selectedUnit;
      _heightController.text = formatHeightEditorValue(_heightCm, _heightUnit);
    });
  }

  Future<void> _selectWeightUnit() async {
    _clearMenuFocus();
    final selectedUnit = await showProjectDismissibleSheet<WeightUnit>(
      context: context,
      title: 'Unidade de peso',
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final unit in WeightUnit.values)
              _UnitOption(
                label: weightUnitMenuLabel(unit),
                isSelected: unit == _weightUnit,
                onTap: () => Navigator.of(context).pop(unit),
              ),
          ],
        );
      },
    );

    _clearMenuFocus();
    if (!mounted || selectedUnit == null) return;
    setState(() {
      _weightUnit = selectedUnit;
      _weightController.text = formatWeightEditorValue(_weightKg, _weightUnit);
    });
  }

  void _commitHeightText() {
    final parsedHeight = parseHeightToCm(_heightController.text, _heightUnit);
    if (parsedHeight != null) {
      _heightCmValue = parsedHeight;
      _updateDraft(_draft.copyWith(heightCm: parsedHeight));
    }
  }

  void _commitWeightText() {
    final parsedWeight = parseWeightToKg(_weightController.text, _weightUnit);
    if (parsedWeight != null) {
      _weightKgValue = parsedWeight;
      _updateDraft(_draft.copyWith(weightKg: parsedWeight));
    }
  }

  List<ProjectTagData> _knownTagsFor(_TagKind kind) {
    return _tagControllers[kind]?.knownTags ?? const <ProjectTagData>[];
  }

  String _selectedTagFor(_TagKind kind) {
    return switch (kind) {
      _TagKind.gender => _selectedGenderTag,
      _TagKind.sexuality => _selectedSexualityTag,
      _TagKind.ethnicity => _selectedEthnicityTag,
      _TagKind.function => _selectedFunctionTag,
    };
  }

  void _setSelectedTag(_TagKind kind, String value) {
    switch (kind) {
      case _TagKind.gender:
        _selectedGenderTag = value;
        break;
      case _TagKind.sexuality:
        _selectedSexualityTag = value;
        break;
      case _TagKind.ethnicity:
        _selectedEthnicityTag = value;
        break;
      case _TagKind.function:
        _selectedFunctionTag = value;
        break;
    }
  }

  String? _addTagFor(_TagKind kind, String input) {
    final controller = _tagControllers[kind];
    if (controller == null) return null;

    final resolved = controller.upsertTagLabel(
      input,
      newTagColor: _tagCategoryColor(kind),
      select: true,
    );
    if (resolved == null) return null;
    return resolved;
  }

  Color? _tagColorFor(_TagKind kind, String label) {
    if (label.trim().isEmpty) return null;
    return _tagControllers[kind]?.colorForLabel(label);
  }

  List<ProjectTagData> _seedTagsFor(_TagKind kind) {
    final labels = switch (kind) {
      _TagKind.gender => const ['Masculino', 'Feminino', 'N/A'],
      _TagKind.sexuality => const [
        'Assexual',
        'Heterossexual',
        'Homossexual',
        'Bissexual',
        'Pansexual',
      ],
      _TagKind.ethnicity => const ['Branco', 'Negro', 'Pardo'],
      _TagKind.function => const ['Vilao', 'Heroi', 'Anti-heroi', 'Anti-vilao'],
    };

    return [
      for (final label in labels)
        ProjectTagData(label: label, color: _tagCategoryColor(kind)),
    ];
  }

  Color _tagCategoryColor(_TagKind kind) {
    return switch (kind) {
      _TagKind.gender => projectTagColorAt(0),
      _TagKind.sexuality => projectTagColorAt(1),
      _TagKind.ethnicity => projectTagColorAt(2),
      _TagKind.function => projectTagColorAt(3),
    };
  }

  String _tagGroupStorageTitle(_TagKind kind) {
    return switch (kind) {
      _TagKind.gender => 'Personagem:Gênero',
      _TagKind.sexuality => 'Personagem:Sexualidade',
      _TagKind.ethnicity => 'Personagem:Etnia',
      _TagKind.function => 'Personagem:Função',
    };
  }
}
