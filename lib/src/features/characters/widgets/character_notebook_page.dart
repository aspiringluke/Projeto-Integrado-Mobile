import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../projects/models/project_image_data.dart';
import '../../projects/models/project_tag_data.dart';
import '../../projects/widgets/project_color_editor.dart';
import '../../projects/utils/project_image_picker.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';
import '../../projects/widgets/project_image_transform_view.dart';
import '../../../shared/widgets/main_header.dart';
import '../../tags/controllers/tag_controller.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_card_visuals.dart';
import 'character_fields.dart';

class CharacterNotebookPage extends StatefulWidget {
  final CharacterCardData data;
  final ValueChanged<CharacterCardData>? onChanged;

  const CharacterNotebookPage({super.key, required this.data, this.onChanged});

  @override
  State<CharacterNotebookPage> createState() => _CharacterNotebookPageState();
}

enum _TagKind { gender, sexuality, ethnicity, function }

enum _NotebookTab { geral, psique, historia, notas, design }

enum _NotebookSection { identidade, tags, medidas, narrativa, imagem }

enum _CharacterColorTarget { cover, accent }

class _NotebookTabMeta {
  final String label;
  final IconData icon;

  const _NotebookTabMeta({required this.label, required this.icon});
}

class _PageStickyTabs extends StatelessWidget {
  final Color accentColor;
  final _NotebookTab activeTab;
  final Map<_NotebookTab, _NotebookTabMeta> tabs;
  final ValueChanged<_NotebookTab> onTabSelected;

  const _PageStickyTabs({
    required this.accentColor,
    required this.activeTab,
    required this.tabs,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 46,
          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                const Color(0xFFF3F0F3).withValues(alpha: 0.62),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.045)),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in tabs.entries) ...[
                  _PageStickyTabChip(
                    label: entry.value.label,
                    icon: entry.value.icon,
                    accentColor: accentColor,
                    selected: entry.key == activeTab,
                    onTap: () => onTabSelected(entry.key),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageStickyTabChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _PageStickyTabChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? accentColor.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? accentColor.withValues(alpha: 0.34)
                      : Colors.white.withValues(alpha: 0.82),
                  width: 0.9,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: selected ? 0.42 : 0.52),
                    selected
                        ? accentColor.withValues(alpha: 0.14)
                        : Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: selected
                        ? _darkenCharacterDialogColor(accentColor, 0.22)
                        : const Color(0xFF544959),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? _darkenCharacterDialogColor(accentColor, 0.22)
                          : const Color(0xFF2C262C),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPageCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderPageCard({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterNotebookPageState extends State<CharacterNotebookPage> {
  static const Map<_NotebookTab, _NotebookTabMeta> _tabs =
      <_NotebookTab, _NotebookTabMeta>{
        _NotebookTab.geral: _NotebookTabMeta(
          label: 'Geral',
          icon: Icons.person_outline_rounded,
        ),
        _NotebookTab.psique: _NotebookTabMeta(
          label: 'Psique',
          icon: Icons.psychology_rounded,
        ),
        _NotebookTab.historia: _NotebookTabMeta(
          label: 'História',
          icon: Icons.history_edu_rounded,
        ),
        _NotebookTab.notas: _NotebookTabMeta(
          label: 'Notas',
          icon: Icons.sticky_note_2_rounded,
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
  late Map<_TagKind, TagController> _tagControllers;
  late Map<_NotebookSection, GlobalKey> _sectionKeys;
  _NotebookTab _activeTab = _NotebookTab.geral;
  _CharacterColorTarget _activeColorTarget = _CharacterColorTarget.cover;

  DateTime? _birthdayValue;
  double? _heightCmValue;
  double? _weightKgValue;
  HeightUnit _heightUnit = HeightUnit.centimeters;
  WeightUnit _weightUnit = WeightUnit.kilograms;
  _RelevanceParameterBundle _relevance = _RelevanceParameterBundle.defaults();
  String _selectedGenderTag = '';
  String _selectedSexualityTag = '';
  String _selectedEthnicityTag = '';
  String _selectedFunctionTag = '';
  String _selectedRelevanceTag = '';

  @override
  void initState() {
    super.initState();
    _draft = widget.data;
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
    _mottoController = TextEditingController(text: _draft.motto);
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _synopsisController.dispose();
    _mottoController.dispose();
    _formationsController.dispose();
    _titlesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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

  void _updateDraft(CharacterCardData next) {
    setState(() {
      _draft = next;
    });
    widget.onChanged?.call(_draft);
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
                      _draft.accent.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NotebookHeader(
                data: _draft,
                onClose: () => Navigator.of(context).pop(),
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
                                  if (currentChild != null) currentChild,
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
    );
  }

  Widget _buildTabContent() {
    return switch (_activeTab) {
      _NotebookTab.geral => _buildGeneralTab(),
      _NotebookTab.psique => _buildPlaceholderTab(
        title: 'Psique',
        subtitle: 'Mapa emocional, impulsos e contradições.',
        icon: Icons.psychology_rounded,
      ),
      _NotebookTab.historia => _buildPlaceholderTab(
        title: 'História',
        subtitle: 'Linha do tempo, origem e viradas importantes.',
        icon: Icons.history_edu_rounded,
      ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyedSubtree(
            key: _sectionKeys[_NotebookSection.identidade],
            child: _CollapsibleSection(
              accentColor: _draft.accent,
              title: 'Identidade',
              subtitle: 'Nome, síntese, frase central e relevância narrativa.',
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.badge_outlined,
                    label: 'Nome',
                    controller: _nameController,
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(name: value)),
                  ),
                  const SizedBox(height: 10),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.alternate_email_rounded,
                    label: 'Vulgo',
                    controller: _aliasController,
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(alias: value)),
                  ),
                  const SizedBox(height: 10),
                  _CharacterRelevanceSelectorField(
                    value: _selectedRelevanceTag,
                    selectedColor: _relevance
                        .categoryForScore(_relevance.score)
                        .color,
                    accentColor: _draft.accent,
                    categories: _relevance.categories,
                    showError: false,
                    score: _relevance.score,
                    onTap: _openRelevanceSelector,
                  ),
                  const SizedBox(height: 12),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.short_text_rounded,
                    label: 'Síntese',
                    controller: _synopsisController,
                    minLines: 3,
                    maxLines: null,
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(synopsis: value)),
                  ),
                  const SizedBox(height: 12),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.format_quote_rounded,
                    label: 'Frase de efeito',
                    controller: _mottoController,
                    minLines: 2,
                    maxLines: 2,
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(motto: value)),
                  ),
                  const SizedBox(height: 12),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.work_outline_rounded,
                    label: 'Formações e ocupações',
                    controller: _formationsController,
                    minLines: 3,
                    maxLines: null,
                    onChanged: (value) => _updateDraft(
                      _draft.copyWith(formationsAndOccupations: value),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.military_tech_outlined,
                    label: 'Títulos',
                    controller: _titlesController,
                    minLines: 2,
                    maxLines: null,
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(titles: value)),
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
              title: 'Tags',
              subtitle: 'Use uma opção existente ou crie uma nova.',
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
              title: 'Medidas',
              subtitle: 'Aniversário, altura e peso como no criador.',
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
                    onTapAge: (_) {},
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
              title: 'Imagem e cor',
              subtitle: 'Foto, cor de capa e cor de realce.',
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
                    onTap: null,
                  ),
                  const SizedBox(height: 12),
                  _ImageTile(
                    accentColor: _draft.accent,
                    imageLabel: _draft.profileImage.bytes == null
                        ? 'Nenhuma foto adicionada'
                        : 'Foto de perfil carregada',
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

  Future<void> _pickProfileImage() async {
    final result = await pickProjectImage();
    if (!mounted || result == null) return;

    final codec = await instantiateImageCodec(result.bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    codec.dispose();

    _updateDraft(
      _draft.copyWith(
        profileImage: ProjectImageData(
          bytes: result.bytes,
          width: size.width,
          height: size.height,
        ),
      ),
    );
  }

  void _removeProfileImage() {
    _updateDraft(_draft.copyWith(profileImage: const ProjectImageData()));
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

  Future<void> _pickAccentColor() async {
    final selected = await _showHslColorEditorSheet(
      title: 'Cor de acento',
      description:
          'Ajuste a cor principal de destaque em matiz, saturação e luminosidade.',
      currentColor: _draft.accent,
      useSolidCoverPreview: false,
    );
    if (selected != null) {
      _updateDraft(_draft.copyWith(accent: selected));
    }
  }

  Future<void> _pickCoverColor() async {
    final selected = await _showHslColorEditorSheet(
      title: 'Cor da capa',
      description: 'Ajuste a cor base da capa do personagem usando HSL.',
      currentColor: _draft.avatarColor,
      useSolidCoverPreview: true,
    );
    if (selected != null) {
      _updateDraft(_draft.copyWith(avatarColor: selected));
    }
  }

  Future<Color?> _showHslColorEditorSheet({
    required String title,
    required String description,
    required Color currentColor,
    required bool useSolidCoverPreview,
  }) {
    return showModalBottomSheet<Color>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        var workingColor = currentColor;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final hslColor = HSLColor.fromColor(workingColor);

            return ProjectBottomSheetFrame(
              title: title,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProjectColorEditor(
                    title: title,
                    description: description,
                    color: workingColor,
                    accentColor: _draft.accent,
                    hslColor: hslColor,
                    useSolidCoverPreview: useSolidCoverPreview,
                    onHueChanged: (value) {
                      setModalState(() {
                        workingColor = HSLColor.fromColor(
                          workingColor,
                        ).withHue(value).toColor();
                      });
                    },
                    onSaturationChanged: (value) {
                      setModalState(() {
                        workingColor = HSLColor.fromColor(
                          workingColor,
                        ).withSaturation(value).toColor();
                      });
                    },
                    onLightnessChanged: (value) {
                      setModalState(() {
                        workingColor = HSLColor.fromColor(
                          workingColor,
                        ).withLightness(value).toColor();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(workingColor),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFDF6EB8),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      isScrollControlled: true,
      builder: (context) {
        final accent = _draft.accent;
        final currentSign = zodiacSignFor(DateTime(2000, tempMonth, tempDay));
        final signDescriptionLines = currentSign.description.split('\n');
        final signDateRange = signDescriptionLines.isNotEmpty
            ? signDescriptionLines.first.trim()
            : '';
        final signTraits = signDescriptionLines.length > 1
            ? signDescriptionLines.sublist(1).join(' ').trim()
            : '';

        return ProjectBottomSheetFrame(
          title: 'Aniversário',
          child: StatefulBuilder(
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
                              'Período do signo',
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
          ),
        );
      },
    );

    monthController.dispose();
    dayController.dispose();

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
    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
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
          ),
        );
      },
    );

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
    final inputController = TextEditingController();
    final selectedLabel = _selectedTagFor(kind);
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tags = _knownTagsFor(kind);
            final accent = _draft.accent;

            return ProjectBottomSheetFrame(
              title: _tagKindTitle(kind),
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
              ),
            );
          },
        );
      },
    );

    inputController.dispose();
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

  Future<void> _openTagSelectorLegacy(_TagKind kind) async {
    final inputController = TextEditingController();
    final selectedLabel = _selectedTagFor(kind);
    final isRequired = kind == _TagKind.gender;
    final currentValue = selectedLabel;
    final options = _knownTagsFor(kind);

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProjectBottomSheetFrame(
          title: _tagKindTitle(kind),
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
                      color: _darkenCharacterDialogColor(
                        _tagColorFor(kind, currentValue) ?? _draft.accent,
                        0.16,
                      ),
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in options)
                      _OptionChip(
                        label: option.label,
                        color: option.color,
                        isSelected: option.label == currentValue,
                        onTap: () => Navigator.of(context).pop(option.label),
                      ),
                  ],
                ),
              ),
              if (kind != _TagKind.gender) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(''),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Limpar seleção'),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      switch (kind) {
        case _TagKind.gender:
          _selectedGenderTag = result;
          _updateDraft(_draft.copyWith(genderTag: result));
          break;
        case _TagKind.sexuality:
          _selectedSexualityTag = result;
          _updateDraft(_draft.copyWith(sexualityTag: result));
          break;
        case _TagKind.ethnicity:
          _selectedEthnicityTag = result;
          _updateDraft(_draft.copyWith(ethnicityTag: result));
          break;
        case _TagKind.function:
          _selectedFunctionTag = result;
          _updateDraft(_draft.copyWith(functionTag: result));
          break;
      }
    });
  }

  Future<void> _openRelevanceSelector() async {
    var temp = _relevance.copyWith();

    final result = await showModalBottomSheet<_RelevanceParameterBundle>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final score = temp.score;
            final category = temp.categoryForScore(score);
            final screenHeight = MediaQuery.sizeOf(context).height;

            return ProjectBottomSheetFrame(
              title: 'Relevância narrativa',
              child: SizedBox(
                height: min(screenHeight * 0.82, 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RelevanceSummaryCard(
                      score: score,
                      category: category,
                      categories: temp.categories,
                    ),
                    const SizedBox(height: 10),
                    _RelevanceFormulaNote(accentColor: _draft.accent),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: temp.parameters.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final parameter = temp.parameters[index];
                          return _RelevanceParameterControl(
                            parameter: parameter,
                            value: temp.values[parameter.id] ?? 0,
                            weight:
                                temp.weights[parameter.id] ?? parameter.weight,
                            onValueChanged: (value) {
                              setModalState(() {
                                temp = temp.copyWith(
                                  values: {...temp.values, parameter.id: value},
                                );
                              });
                            },
                            onWeightChanged: (value) {
                              setModalState(() {
                                temp = temp.copyWith(
                                  weights: _redistributeRelevanceWeights(
                                    parameters: temp.parameters,
                                    weights: temp.weights,
                                    changedId: parameter.id,
                                    requestedWeight: value,
                                  ),
                                );
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(temp),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDF6EB8),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _relevance = result;
      _selectedRelevanceTag = result.categoryForScore(result.score).name;
      _updateDraft(_draft.copyWith(relevanceTag: _selectedRelevanceTag));
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
                _UnitOption(
                  label: heightUnitMenuLabel(unit),
                  isSelected: unit == _heightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedUnit == null) return;
    setState(() {
      _heightUnit = selectedUnit;
      _heightController.text = formatHeightEditorValue(_heightCm, _heightUnit);
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
                _UnitOption(
                  label: weightUnitMenuLabel(unit),
                  isSelected: unit == _weightUnit,
                  onTap: () => Navigator.of(context).pop(unit),
                ),
            ],
          ),
        );
      },
    );

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

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Signo',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
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
                left: (anchorRect.center.dx - 116).clamp(
                  12.0,
                  MediaQuery.sizeOf(context).width - 244,
                ),
                top: (anchorRect.bottom + 8).clamp(
                  12.0,
                  MediaQuery.sizeOf(context).height - 160,
                ),
                width: 232,
                child: _AnchoredBubble(
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
                          ),
                        ),
                      ],
                      if (traits.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final trait in traits)
                              _TraitPill(label: trait),
                          ],
                        ),
                      ],
                    ],
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

  List<ProjectTagData> _optionsFor(_TagKind kind) => _knownTagsFor(kind);

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
    setState(() {});
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
      _TagKind.gender => 'Personagem:GÃªnero',
      _TagKind.sexuality => 'Personagem:Sexualidade',
      _TagKind.ethnicity => 'Personagem:Etnia',
      _TagKind.function => 'Personagem:FunÃ§Ã£o',
    };
  }
}

class _NotebookHeader extends StatelessWidget {
  final CharacterCardData data;
  final VoidCallback onClose;

  const _NotebookHeader({required this.data, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final tags = _buildNotebookHeaderTags(data);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MainHeader(
          asSliver: false,
          title: data.name,
          onBackPressed: onClose,
          onConfigPressed: () {},
          headerHeight: 154,
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          titleHorizontalPadding: 60,
          titleShadow: true,
          centerChild: _NotebookHeaderTitleBlock(data: data),
          bottomChild: tags.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: _NotebookHeaderTagWrap(tags: tags),
                ),
          backgroundChild: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(child: _NotebookHeaderCoverBackground(data: data)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        data.accent.withValues(alpha: 0.035),
                        Colors.black.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.03),
                        Colors.black.withValues(alpha: 0.12),
                        data.accent.withValues(alpha: 0.035),
                      ],
                      stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotebookHeaderTagWrap extends StatelessWidget {
  final List<_NotebookHeaderTagItem> tags;

  const _NotebookHeaderTagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < tags.length; index += 1) ...[
              if (index > 0) const SizedBox(width: 6),
              _MiniChip(
                icon: tags[index].icon,
                label: tags[index].label,
                color: tags[index].color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotebookHeaderTagItem {
  final IconData icon;
  final String label;
  final Color color;

  const _NotebookHeaderTagItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

List<_NotebookHeaderTagItem> _buildNotebookHeaderTags(CharacterCardData data) {
  final tags = <_NotebookHeaderTagItem>[
    _NotebookHeaderTagItem(
      icon: Icons.star_rounded,
      label: data.relevanceTag.isEmpty ? 'N/A' : data.relevanceTag,
      color: _notebookHeaderRelevanceColor(data.relevanceTag),
    ),
  ];

  void addTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    if (label.trim().isEmpty) return;
    tags.add(_NotebookHeaderTagItem(icon: icon, label: label, color: color));
  }

  addTag(
    icon: Icons.wc_rounded,
    label: data.genderTag,
    color: projectTagColorAt(0),
  );
  addTag(
    icon: Icons.favorite_border_rounded,
    label: data.sexualityTag,
    color: projectTagColorAt(1),
  );
  addTag(
    icon: Icons.groups_2_outlined,
    label: data.ethnicityTag,
    color: projectTagColorAt(2),
  );
  addTag(
    icon: Icons.badge_outlined,
    label: data.functionTag,
    color: projectTagColorAt(3),
  );

  return tags;
}

Color _notebookHeaderRelevanceColor(String label) {
  return switch (label.trim().toLowerCase()) {
    'contorno' => const Color(0xFF8E838B),
    'periferico' => const Color(0xFF8EAFF1),
    'orbital' => const Color(0xFFDF9C53),
    'nucleo' => const Color(0xFFDF6EB8),
    _ => const Color(0xFF8E838B),
  };
}

class _NotebookHeaderInfoPanel extends StatelessWidget {
  final CharacterCardData data;

  const _NotebookHeaderInfoPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    final glowColor = data.accent.withValues(alpha: 0.26);
    final dropShadow = Colors.black.withValues(alpha: 0.22);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Text(
        data.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFF9F5F8),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.1,
          shadows: [
            Shadow(color: glowColor, blurRadius: 14),
            Shadow(
              color: dropShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookHeaderTitleBlock extends StatelessWidget {
  final CharacterCardData data;

  const _NotebookHeaderTitleBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NotebookHeaderInfoPanel(data: data),
          const SizedBox(height: 4),
          Container(
            width: 82,
            height: 1,
            color: Colors.white.withValues(alpha: 0.46),
          ),
          const SizedBox(height: 4),
          Text(
            data.alias.isEmpty ? 'Sem vulgo' : data.alias,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF1ECF0).withValues(alpha: 0.74),
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookHeaderCoverBackground extends StatelessWidget {
  final CharacterCardData data;

  const _NotebookHeaderCoverBackground({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  data.accent.withValues(alpha: 0.11),
                  data.avatarColor.withValues(alpha: 0.94),
                ),
                Color.alphaBlend(
                  data.avatarColor.withValues(alpha: 0.93),
                  Colors.black.withValues(alpha: 0.06),
                ),
                Color.alphaBlend(
                  data.accent.withValues(alpha: 0.075),
                  Colors.white.withValues(alpha: 0.1),
                ),
              ],
              stops: const [0.0, 0.56, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  data.accent.withValues(alpha: 0.055),
                  Colors.transparent,
                  Colors.transparent,
                  data.accent.withValues(alpha: 0.055),
                ],
                stops: const [0.0, 0.22, 0.78, 1.0],
              ),
            ),
          ),
        ),
        if (data.profileImage.bytes != null) ...[
          _NotebookHeaderCoverImageLayer(
            profileImage: data.profileImage,
            sigma: 0.8,
            opacity: 0.9,
            maskColors: const [
              Colors.black,
              Colors.black,
              Color(0xAA000000),
              Color(0x44000000),
              Colors.transparent,
            ],
            maskStops: const [0.0, 0.42, 0.78, 0.92, 1.0],
          ),
          _NotebookHeaderCoverImageLayer(
            profileImage: data.profileImage,
            sigma: 10,
            opacity: 0.3,
            maskColors: const [
              Colors.transparent,
              Color(0x66000000),
              Color(0x99000000),
              Color(0x33000000),
              Colors.transparent,
            ],
            maskStops: const [0.0, 0.48, 0.76, 0.92, 1.0],
          ),
          _NotebookHeaderCoverImageLayer(
            profileImage: data.profileImage,
            sigma: 20,
            opacity: 0.15,
            maskColors: const [
              Colors.transparent,
              Colors.transparent,
              Color(0x22000000),
              Color(0x33000000),
              Colors.transparent,
            ],
            maskStops: const [0.0, 0.56, 0.82, 0.94, 1.0],
          ),
        ] else ...[
          _NotebookHeaderCoverIconLayer(
            accentColor: data.accent,
            sigma: 3,
            opacity: 0.36,
            maskColors: const [
              Colors.black,
              Colors.black,
              Color(0x88000000),
              Color(0x33000000),
              Colors.transparent,
            ],
            maskStops: const [0.0, 0.42, 0.78, 0.92, 1.0],
          ),
          _NotebookHeaderCoverIconLayer(
            accentColor: data.accent,
            sigma: 16,
            opacity: 0.18,
            maskColors: const [
              Colors.transparent,
              Color(0x44000000),
              Color(0x77000000),
              Color(0x22000000),
              Colors.transparent,
            ],
            maskStops: const [0.0, 0.5, 0.78, 0.94, 1.0],
          ),
        ],
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.16),
                ],
                stops: const [0.0, 0.34, 0.76, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.06),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotebookHeaderCoverImageLayer extends StatelessWidget {
  final ProjectImageData profileImage;
  final double sigma;
  final double opacity;
  final List<Color> maskColors;
  final List<double> maskStops;

  const _NotebookHeaderCoverImageLayer({
    required this.profileImage,
    required this.sigma,
    required this.opacity,
    required this.maskColors,
    required this.maskStops,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: maskColors,
            stops: maskStops,
          ).createShader(bounds);
        },
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: SizedBox.expand(
            child: ProjectImageTransformView(
              imageBytes: profileImage.bytes!,
              imageWidth: profileImage.width ?? 1,
              imageHeight: profileImage.height ?? 1,
              scale: profileImage.scale,
              offsetX: profileImage.offsetX,
              offsetY: profileImage.offsetY,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookHeaderCoverIconLayer extends StatelessWidget {
  final Color accentColor;
  final double sigma;
  final double opacity;
  final List<Color> maskColors;
  final List<double> maskStops;

  const _NotebookHeaderCoverIconLayer({
    required this.accentColor,
    required this.sigma,
    required this.opacity,
    required this.maskColors,
    required this.maskStops,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: maskColors,
            stops: maskStops,
          ).createShader(bounds);
        },
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Transform.translate(
              offset: const Offset(-14, 0),
              child: Icon(
                Icons.person_rounded,
                size: 220,
                color: accentColor.withValues(alpha: 0.96),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = Colors.white.withValues(alpha: 0.98);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.52),
              width: 0.9,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                color.withValues(alpha: 0.5),
                color.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: foreground),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageTileLegacy2 extends StatelessWidget {
  final Color accentColor;
  final String imageLabel;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const _ImageTileLegacy2({
    required this.accentColor,
    required this.imageLabel,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto',
            style: TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            imageLabel,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Imagem'),
                ),
              ),
              if (onRemoveImage != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onRemoveImage,
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionStickyNote extends StatelessWidget {
  final Color accentColor;
  final ValueChanged<_NotebookSection> onJumpTo;

  const _SectionStickyNote({required this.accentColor, required this.onJumpTo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.14),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sticky_note_2_rounded,
                    size: 16,
                    color: _darkenCharacterDialogColor(accentColor, 0.16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Seções',
                    style: TextStyle(
                      color: Color(0xFF2C262C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SectionChip(
                    label: 'Identidade',
                    icon: Icons.person_outline_rounded,
                    accentColor: accentColor,
                    onTap: () => onJumpTo(_NotebookSection.identidade),
                  ),
                  _SectionChip(
                    label: 'Tags',
                    icon: Icons.sell_outlined,
                    accentColor: accentColor,
                    onTap: () => onJumpTo(_NotebookSection.tags),
                  ),
                  _SectionChip(
                    label: 'Medidas',
                    icon: Icons.straighten_rounded,
                    accentColor: accentColor,
                    onTap: () => onJumpTo(_NotebookSection.medidas),
                  ),
                  _SectionChip(
                    label: 'Narrativa',
                    icon: Icons.chat_bubble_outline_rounded,
                    accentColor: accentColor,
                    onTap: () => onJumpTo(_NotebookSection.narrativa),
                  ),
                  _SectionChip(
                    label: 'Imagem',
                    icon: Icons.auto_awesome_rounded,
                    accentColor: accentColor,
                    onTap: () => onJumpTo(_NotebookSection.imagem),
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

class _SectionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _SectionChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _CollapsibleSection({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = true;

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
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 17,
                          color: const Color(0xFF544959),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Color(0xFF2C262C),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.black.withValues(alpha: 0.58),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: widget.child,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookTextFieldCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;

  const _NotebookTextFieldCard({
    required this.accentColor,
    required this.icon,
    required this.label,
    this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: const Color(0xFF544959)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            keyboardType: maxLines == 1
                ? TextInputType.text
                : TextInputType.multiline,
            textInputAction: maxLines == 1
                ? TextInputAction.next
                : TextInputAction.newline,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.7),
              hintText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accentColor.withValues(alpha: 0.7),
                  width: 1.05,
                ),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final Color accentColor;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.accentColor,
    required this.label,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isSelected ? 0.66 : 0.54),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.34)
                  : accentColor.withValues(alpha: 0.16),
              width: isSelected ? 1.1 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.24),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.56),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
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

class _ImageTileLegacy extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final VoidCallback onPickIcon;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const _ImageTileLegacy({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.onPickIcon,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Símbolo',
            style: TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF544959)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.56),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Imagem'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickIcon,
                  icon: const Icon(Icons.apps_rounded, size: 18),
                  label: const Text('Ícone'),
                ),
              ),
              if (onRemoveImage != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onRemoveImage,
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Color accentColor;
  final String imageLabel;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const _ImageTile({
    required this.accentColor,
    required this.imageLabel,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto',
            style: TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            imageLabel,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Imagem'),
                ),
              ),
              if (onRemoveImage != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onRemoveImage,
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _iconLabelFor(IconData icon) {
  if (icon == Icons.person_rounded) return 'Personagem';
  if (icon == Icons.auto_awesome_rounded) return 'Auto';
  if (icon == Icons.psychology_rounded) return 'Psique';
  if (icon == Icons.book_rounded) return 'Livro';
  if (icon == Icons.palette_rounded) return 'Paleta';
  if (icon == Icons.bolt_rounded) return 'Energia';
  if (icon == Icons.sports_martial_arts_rounded) return 'Combate';
  if (icon == Icons.theater_comedy_rounded) return 'Palco';
  return 'Personalizado';
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
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Gênero',
                value: genderLabel,
                accentColor: accentColor,
                selectedColor: genderColor,
                isRequired: false,
                showError: false,
                onTap: onPickGenderTag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Sexualidade',
                value: sexualityLabel,
                accentColor: accentColor,
                selectedColor: sexualityColor,
                onTap: onPickSexualityTag,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Etnia',
                value: ethnicityLabel,
                accentColor: accentColor,
                selectedColor: ethnicityColor,
                onTap: onPickEthnicityTag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Função',
                value: functionLabel,
                accentColor: accentColor,
                selectedColor: functionColor,
                onTap: onPickFunctionTag,
              ),
            ),
          ],
        ),
      ],
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
                          : 'Selecionar opção',
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

class _CharacterRelevanceSelectorField extends StatelessWidget {
  final String value;
  final Color? selectedColor;
  final Color accentColor;
  final List<_RelevanceCategory> categories;
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
    final labelColor = showError
        ? const Color(0xFFC96775)
        : hasValue
        ? _darkenCharacterDialogColor(categoryColor, 0.2)
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
                  accentColor: categoryColor,
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
                  color: categoryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Center(
                  child: Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(categoryColor, 0.18),
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

class _RelevanceSummaryCard extends StatelessWidget {
  final double score;
  final _RelevanceCategory category;
  final List<_RelevanceCategory> categories;

  const _RelevanceSummaryCard({
    required this.score,
    required this.category,
    required this.categories,
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
  final List<_RelevanceCategory> categories;
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
        'Os pesos fecham 100%. Ao mudar um peso, os demais se redistribuem automaticamente.',
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

class _RelevanceParameterControl extends StatelessWidget {
  final _RelevanceParameter parameter;
  final double value;
  final double weight;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<double> onWeightChanged;

  const _RelevanceParameterControl({
    required this.parameter,
    required this.value,
    required this.weight,
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
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
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
            ],
          ),
          const SizedBox(height: 4),
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

InputDecoration _buildTagInputDecoration({
  required String hintText,
  required Color focusedColor,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.black.withValues(alpha: 0.42),
      fontSize: 12,
      fontStyle: FontStyle.italic,
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.82),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: focusedColor.withValues(alpha: 0.34)),
    ),
  );
}

class _TagEmptyState extends StatelessWidget {
  final Color accentColor;

  const _TagEmptyState({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Text(
        'Nenhuma opção cadastrada ainda.',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.55),
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionChip({
    required this.label,
    required this.color,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.82),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? _darkenCharacterDialogColor(color, 0.2)
                  : const Color(0xFF2C262C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookTagEmptyState extends StatelessWidget {
  final Color accentColor;

  const _NotebookTagEmptyState({required this.accentColor});

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

class _NotebookTagOptionButton extends StatelessWidget {
  final ProjectTagData tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotebookTagOptionButton({
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

class _SwatchButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SwatchButton({
    required this.color,
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
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2C262C)
                  : Colors.white.withValues(alpha: 0.7),
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconButtonChip extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconButtonChip({
    required this.icon,
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
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2C262C)
                  : Colors.white.withValues(alpha: 0.8),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Icon(icon, color: const Color(0xFF544959), size: 20),
        ),
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.label,
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
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFDF6EB8).withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFDF6EB8).withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.82),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF2C262C)
                  : const Color(0xFF544959),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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
    final lines = signData.description.split('\n');
    final range = lines.isNotEmpty ? lines.first : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.82),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${signData.symbol} ${signData.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                range,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.54),
                  fontSize: 10.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BirthdayWheel extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onSelectedItemChanged;
  final List<Widget> children;

  const _BirthdayWheel({
    required this.label,
    required this.controller,
    required this.onSelectedItemChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        ),
        child: CupertinoPicker(
          scrollController: controller,
          itemExtent: 36,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: onSelectedItemChanged,
          children: children,
        ),
      ),
    );
  }
}

class _TraitPill extends StatelessWidget {
  final String label;

  const _TraitPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2C262C),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AnchoredBubble extends StatelessWidget {
  final Widget child;

  const _AnchoredBubble({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RelevanceParameter {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final double weight;

  const _RelevanceParameter({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    required this.weight,
  });
}

class _RelevanceCategory {
  final String name;
  final double min;
  final double max;
  final String description;
  final Color color;

  const _RelevanceCategory({
    required this.name,
    required this.min,
    required this.max,
    required this.description,
    required this.color,
  });
}

class _RelevanceParameterBundle {
  final List<_RelevanceParameter> parameters;
  final Map<String, double> values;
  final Map<String, double> weights;

  const _RelevanceParameterBundle({
    required this.parameters,
    required this.values,
    required this.weights,
  });

  factory _RelevanceParameterBundle.defaults() {
    final parameters = _defaultRelevanceParameters();
    return _RelevanceParameterBundle(
      parameters: parameters,
      values: {for (final parameter in parameters) parameter.id: 0},
      weights: {
        for (final parameter in parameters) parameter.id: parameter.weight,
      },
    );
  }

  List<_RelevanceCategory> get categories => _defaultRelevanceCategories();

  double get score => _calculateScore();

  _RelevanceCategory categoryForScore(double score) {
    return categories.firstWhere(
      (category) => score >= category.min && score <= category.max,
      orElse: () => categories.last,
    );
  }

  _RelevanceParameterBundle copyWith({
    Map<String, double>? values,
    Map<String, double>? weights,
    List<_RelevanceParameter>? parameters,
  }) {
    return _RelevanceParameterBundle(
      parameters: parameters ?? this.parameters,
      values: values ?? this.values,
      weights: weights ?? this.weights,
    );
  }

  double _calculateScore() {
    var weightedTotal = 0.0;
    var weightTotal = 0.0;
    for (final parameter in parameters) {
      final weight = weights[parameter.id] ?? parameter.weight;
      weightedTotal += (values[parameter.id] ?? 0) * weight;
      weightTotal += weight;
    }
    if (weightTotal <= 0) return 0;
    return (weightedTotal / weightTotal).clamp(0, 10);
  }
}

List<_RelevanceParameter> _defaultRelevanceParameters() {
  return const [
    _RelevanceParameter(
      id: 'causal',
      symbol: 'Cc',
      name: 'Centralidade causal',
      description:
          'Baixo: reage aos eventos. Alto: cria viradas, escolhas vitais e consequencias irreversiveis.',
      weight: 0.45,
    ),
    _RelevanceParameter(
      id: 'relational',
      symbol: 'Dr',
      name: 'Densidade relacional',
      description:
          'Baixo: poucas conexoes. Alto: conecta grupos, move relacoes e irradia influencia no elenco.',
      weight: 0.25,
    ),
    _RelevanceParameter(
      id: 'thematic',
      symbol: 'Ct',
      name: 'Carga tematica',
      description:
          'Baixo: pouca tese propria. Alto: encarna conflitos, ideias e perguntas centrais da obra.',
      weight: 0.15,
    ),
    _RelevanceParameter(
      id: 'presence',
      symbol: 'Pd',
      name: 'Presenca discursiva',
      description:
          'Baixo: aparece pouco. Alto: ocupa cenas, falas, paginas ou atencao recorrente.',
      weight: 0.10,
    ),
    _RelevanceParameter(
      id: 'mutability',
      symbol: 'Me',
      name: 'Mutabilidade estrutural',
      description:
          'Baixo: permanece estavel. Alto: muda psicologicamente ou reposiciona sua funcao na trama.',
      weight: 0.05,
    ),
  ];
}

List<_RelevanceCategory> _defaultRelevanceCategories() {
  return const [
    _RelevanceCategory(
      name: 'Contorno',
      min: 0,
      max: 1.9,
      description: 'Figura passiva ou cenografica.',
      color: Color(0xFF8E838B),
    ),
    _RelevanceCategory(
      name: 'Periferico',
      min: 2,
      max: 4.9,
      description: 'Agente funcional, gatilho ou catalisador.',
      color: Color(0xFF8EAFF1),
    ),
    _RelevanceCategory(
      name: 'Orbital',
      min: 5,
      max: 7.9,
      description: 'Sustentacao critica ao redor do nucleo.',
      color: Color(0xFFDF9C53),
    ),
    _RelevanceCategory(
      name: 'Nucleo',
      min: 8,
      max: 10,
      description: 'Entidade vital da espinha causal da historia.',
      color: Color(0xFFDF6EB8),
    ),
  ];
}

Map<String, double> _redistributeRelevanceWeights({
  required List<_RelevanceParameter> parameters,
  required Map<String, double> weights,
  required String changedId,
  required double requestedWeight,
}) {
  final clamped = requestedWeight.clamp(0.0, 1.0).toDouble();
  if (parameters.length <= 1) {
    return {changedId: 1};
  }

  final remaining = (1.0 - clamped).clamp(0.0, 1.0).toDouble();
  final otherIds = parameters
      .map((p) => p.id)
      .where((id) => id != changedId)
      .toList();
  final otherTotal = otherIds.fold<double>(
    0,
    (sum, id) => sum + (weights[id] ?? 0),
  );

  if (otherTotal <= 0) {
    final equal = remaining / otherIds.length;
    return {
      for (final parameter in parameters)
        parameter.id: parameter.id == changedId ? clamped : equal.toDouble(),
    };
  }

  final result = <String, double>{changedId: clamped};
  for (final id in otherIds) {
    final base = weights[id] ?? 0;
    result[id] = ((base / otherTotal) * remaining).toDouble();
  }
  return result;
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

String _tagKindTitle(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => 'Gênero',
    _TagKind.sexuality => 'Sexualidade',
    _TagKind.ethnicity => 'Etnia',
    _TagKind.function => 'Função',
  };
}

String _tagKindDescription(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => 'Escolha uma opção para o gênero do personagem.',
    _TagKind.sexuality => 'Escolha uma opção para a sexualidade do personagem.',
    _TagKind.ethnicity => 'Escolha uma opção para a etnia do personagem.',
    _TagKind.function => 'Escolha a função dramática principal do personagem.',
  };
}

IconData _tagKindIcon(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => Icons.wc_rounded,
    _TagKind.sexuality => Icons.favorite_border_rounded,
    _TagKind.ethnicity => Icons.groups_2_outlined,
    _TagKind.function => Icons.theater_comedy_outlined,
  };
}

Color _darkenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
}

BoxDecoration _buildCharacterDialogSurfaceDecoration({
  required Color accentColor,
  required bool selected,
  required BorderRadius borderRadius,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: selected ? 0.62 : 0.54),
    borderRadius: borderRadius,
    border: Border.all(
      color: selected
          ? accentColor.withValues(alpha: 0.28)
          : Colors.white.withValues(alpha: 0.82),
      width: 0.8,
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
