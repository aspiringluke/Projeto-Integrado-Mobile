// ignore_for_file: unused_element, unused_local_variable

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../projects/models/project_image_data.dart';
import '../../projects/models/project_tag_data.dart';
import '../../projects/widgets/project_color_editor.dart';
import '../../projects/utils/project_image_picker.dart';
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

const String _namePlaceholderText = characterNamePlaceholderText;
const String _aliasPlaceholderText = characterAliasPlaceholderText;
const String _mottoPlaceholderText =
    'Frase de efeito é um "motto", ou lema. Uma frase curta que encapsula os ideais, propósitos e/ou crenças de uma pessoa de forma a caracterizá-las.';
const String _formationsPlaceholderText =
    'Em que o personagem é formalmente formado e com o que o personagem formalmente trabalha.';
const String _titlesPlaceholderText =
    'Títulos formais e informais que designam o personagem.';

enum _CharacterColorTarget { cover, accent }

enum _PsychViewMode { bigFive, facet }

enum _PsychSplitFocus { none, traits, facets }

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
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.9),
            const Color(0xFFF3F0F3).withValues(alpha: 0.84),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.045)),
        ),
      ),
      child: Row(
        children: [
          for (final entry in tabs.entries)
            Expanded(
              child: _PageStickyTabChip(
                label: entry.value.label,
                icon: entry.value.icon,
                accentColor: accentColor,
                selected: entry.key == activeTab,
                onTap: () => onTabSelected(entry.key),
              ),
            ),
        ],
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
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.2),
            border: Border(
              right: BorderSide(color: Colors.white.withValues(alpha: 0.34)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: selected ? 0.46 : 0.34),
                selected
                    ? accentColor.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 0,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: selected
                          ? _darkenCharacterDialogColor(accentColor, 0.22)
                          : const Color(0xFF544959),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            ],
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

class _PsychRadarNodeDefinition {
  final String id;
  final String label;
  final String chartLabel;
  final String description;
  final Color color;

  const _PsychRadarNodeDefinition({
    required this.id,
    required this.label,
    required this.chartLabel,
    required this.description,
    required this.color,
  });
}

const List<_PsychTraitDefinition> _psychBigFiveTraits = <_PsychTraitDefinition>[
  _PsychTraitDefinition(
    id: 'consciencia',
    label: 'Consciência',
    chartLabel: 'Consciência',
    description:
        'Diz respeito à forma como controlamos, conduzimos e direcionamos nossos impulsos.',
    color: Color(0xFF2F7D73),
    facets: <_PsychFacetDefinition>[
      _PsychFacetDefinition(
        id: 'competencia',
        label: 'Competência',
        description:
            'Faceta em ajuste para detalhar como a capacidade percebida aparece no personagem.',
      ),
      _PsychFacetDefinition(
        id: 'ordem',
        label: 'Ordem',
        description:
            'Faceta em ajuste para detalhar organização, arranjo e previsibilidade.',
      ),
      _PsychFacetDefinition(
        id: 'senso_de_dever',
        label: 'Senso de dever',
        description:
            'Faceta em ajuste para detalhar responsabilidade, compromisso e consistência.',
      ),
      _PsychFacetDefinition(
        id: 'busca_de_realizacao',
        label: 'Busca de realização',
        description:
            'Faceta em ajuste para detalhar ambição, foco em metas e entrega.',
      ),
      _PsychFacetDefinition(
        id: 'autodisciplina',
        label: 'Autodisciplina',
        description:
            'Faceta em ajuste para detalhar persistência, autocontrole e execução.',
      ),
      _PsychFacetDefinition(
        id: 'deliberacao',
        label: 'Deliberação',
        description:
            'Faceta em ajuste para detalhar cautela, ponderação e escolha consciente.',
      ),
    ],
  ),
  _PsychTraitDefinition(
    id: 'neuroticismo',
    label: 'Neuroticismo',
    chartLabel: 'Neuroticismo',
    description: 'Tendência a sentir emoções negativas.',
    color: Color(0xFFC65B6A),
    facets: <_PsychFacetDefinition>[
      _PsychFacetDefinition(
        id: 'ansiedade',
        label: 'Ansiedade',
        description:
            'Faceta em ajuste para detalhar tensão antecipatória e preocupação.',
      ),
      _PsychFacetDefinition(
        id: 'raiva',
        label: 'Raiva / hostilidade',
        description:
            'Faceta em ajuste para detalhar irritação, dureza e reatividade.',
      ),
      _PsychFacetDefinition(
        id: 'depressao',
        label: 'Depressão',
        description:
            'Faceta em ajuste para detalhar abatimento, pessimismo e recesso emocional.',
      ),
      _PsychFacetDefinition(
        id: 'autoconsciencia',
        label: 'Autoconsciência',
        description:
            'Faceta em ajuste para detalhar vergonha, exposição e autocensura.',
      ),
      _PsychFacetDefinition(
        id: 'impulsividade',
        label: 'Impulsividade',
        description:
            'Faceta em ajuste para detalhar dificuldade de inibir reações imediatas.',
      ),
      _PsychFacetDefinition(
        id: 'vulnerabilidade',
        label: 'Vulnerabilidade',
        description:
            'Faceta em ajuste para detalhar sensibilidade a pressão, ameaça ou sobrecarga.',
      ),
    ],
  ),
  _PsychTraitDefinition(
    id: 'afabilidade',
    label: 'Afabilidade',
    chartLabel: 'Afabilidade',
    description:
        'Pessoas agradáveis aos outros, simpáticas. Se preocupam com a cooperação e a harmonia social e facilmente se dão bem com outras pessoas.',
    color: Color(0xFF4E87B7),
    facets: <_PsychFacetDefinition>[
      _PsychFacetDefinition(
        id: 'confianca',
        label: 'Confiança',
        description:
            'Faceta em ajuste para detalhar abertura inicial e presunção de boa-fé.',
      ),
      _PsychFacetDefinition(
        id: 'sinceridade',
        label: 'Sinceridade',
        description:
            'Faceta em ajuste para detalhar franqueza, transparência e intenção clara.',
      ),
      _PsychFacetDefinition(
        id: 'altruismo',
        label: 'Altruísmo',
        description:
            'Faceta em ajuste para detalhar ajuda, cuidado e orientação ao outro.',
      ),
      _PsychFacetDefinition(
        id: 'complacencia',
        label: 'Complacência',
        description:
            'Faceta em ajuste para detalhar flexibilidade, concessão e baixa confrontação.',
      ),
      _PsychFacetDefinition(
        id: 'modestia',
        label: 'Modéstia',
        description:
            'Faceta em ajuste para detalhar humildade, discrição e pouca autopromoção.',
      ),
      _PsychFacetDefinition(
        id: 'ternura',
        label: 'Ternura',
        description:
            'Faceta em ajuste para detalhar empatia, acolhimento e delicadeza.',
      ),
    ],
  ),
  _PsychTraitDefinition(
    id: 'abertura',
    label: 'Abertura à experiência',
    chartLabel: 'Abertura\nà experiência',
    description:
        'Pessoas criativas, apreciadoras da arte e da beleza e que gostam do novo.',
    color: Color(0xFFB47B38),
    facets: <_PsychFacetDefinition>[
      _PsychFacetDefinition(
        id: 'fantasia',
        label: 'Fantasia',
        description:
            'Faceta em ajuste para detalhar imaginação, invenção e pensamento simbólico.',
      ),
      _PsychFacetDefinition(
        id: 'estetica',
        label: 'Estética',
        description:
            'Faceta em ajuste para detalhar sensibilidade à forma, beleza e composição.',
      ),
      _PsychFacetDefinition(
        id: 'sentimentos',
        label: 'Sentimentos',
        description:
            'Faceta em ajuste para detalhar abertura à vida interna e ao sentir.',
      ),
      _PsychFacetDefinition(
        id: 'acoes',
        label: 'Ações',
        description:
            'Faceta em ajuste para detalhar vontade de experimentar, variar e testar.',
      ),
      _PsychFacetDefinition(
        id: 'ideias',
        label: 'Ideias',
        description:
            'Faceta em ajuste para detalhar curiosidade intelectual e interesse conceitual.',
      ),
      _PsychFacetDefinition(
        id: 'valores',
        label: 'Valores',
        description:
            'Faceta em ajuste para detalhar flexibilidade ideológica e revisão de crenças.',
      ),
    ],
  ),
  _PsychTraitDefinition(
    id: 'extroversao',
    label: 'Extroversão',
    chartLabel: 'Extroversão',
    description:
        'A extroversão é marcada pela sociabilidade, engajamento com o mundo externo.',
    color: Color(0xFF5C9B6C),
    facets: <_PsychFacetDefinition>[
      _PsychFacetDefinition(
        id: 'cordialidade',
        label: 'Cordialidade',
        description:
            'Faceta em ajuste para detalhar calor social, abertura e prontidão relacional.',
      ),
      _PsychFacetDefinition(
        id: 'gregariedade',
        label: 'Gregariedade',
        description:
            'Faceta em ajuste para detalhar gosto por grupo, convivência e circulação social.',
      ),
      _PsychFacetDefinition(
        id: 'assertividade',
        label: 'Assertividade',
        description:
            'Faceta em ajuste para detalhar iniciativa, fala ativa e ocupação de espaço.',
      ),
      _PsychFacetDefinition(
        id: 'atividade',
        label: 'Atividade',
        description:
            'Faceta em ajuste para detalhar ritmo, energia e dinamismo cotidiano.',
      ),
      _PsychFacetDefinition(
        id: 'excitação',
        label: 'Busca de excitação',
        description:
            'Faceta em ajuste para detalhar busca de estímulo, intensidade e novidade.',
      ),
      _PsychFacetDefinition(
        id: 'emocao_positiva',
        label: 'Emoções positivas',
        description:
            'Faceta em ajuste para detalhar entusiasmo, alegria e disposição afetiva.',
      ),
    ],
  ),
];

class _PsychRadarCard extends StatelessWidget {
  final Color accentColor;
  final Color? pointColor;
  final String title;
  final String? subtitle;
  final List<_PsychRadarNodeDefinition> nodes;
  final Map<String, double> values;
  final String? selectedNodeId;
  final double selectedNodeScale;
  final ValueChanged<String> onNodeSelected;
  final String? interactiveNodeId;
  final ValueChanged<double>? onInteractiveNodeValueChanged;

  const _PsychRadarCard({
    required this.accentColor,
    this.pointColor,
    required this.title,
    this.subtitle,
    required this.nodes,
    required this.values,
    required this.selectedNodeId,
    required this.selectedNodeScale,
    required this.onNodeSelected,
    this.interactiveNodeId,
    this.onInteractiveNodeValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.radar_rounded,
                size: 17,
                color: _darkenCharacterDialogColor(accentColor, 0.16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B262C),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.52),
                          fontSize: 10.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartSide = constraints.maxWidth.isFinite
                  ? min(constraints.maxWidth, 220.0)
                  : 208.0;
              final chartSize = Size.square(chartSide);
              final geometry = _PsychRadarGeometry(
                nodes: nodes,
                values: values,
              );
              return Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final selected = geometry.hitTest(
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                    if (selected != null) {
                      onNodeSelected(selected);
                    }
                    _updateInteractiveValue(
                      geometry: geometry,
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                  },
                  onPanStart: (details) {
                    _updateInteractiveValue(
                      geometry: geometry,
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                  },
                  onPanUpdate: (details) {
                    _updateInteractiveValue(
                      geometry: geometry,
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                  },
                  child: SizedBox.square(
                    dimension: chartSide,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 1.0, end: selectedNodeScale),
                      builder: (context, scale, child) {
                        final chartZoom = 1.0 + ((scale - 1.0) * 0.22);
                        return Transform.scale(
                          scale: chartZoom,
                          child: CustomPaint(
                            painter: _PsychRadarPainter(
                              accentColor: accentColor,
                              pointColor: pointColor ?? accentColor,
                              nodes: nodes,
                              values: values,
                              selectedNodeId: selectedNodeId,
                              selectedNodeScale: scale,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateInteractiveValue({
    required _PsychRadarGeometry geometry,
    required Size size,
    required Offset localPosition,
  }) {
    final nodeId = interactiveNodeId;
    final callback = onInteractiveNodeValueChanged;
    if (nodeId == null || callback == null) return;
    callback(
      geometry.valueFromPosition(size: size, localPosition: localPosition),
    );
  }
}

class _PsychFacetRadarCard extends StatelessWidget {
  final Color accentColor;
  final _PsychTraitDefinition trait;
  final List<_PsychRadarNodeDefinition> nodes;
  final Map<String, double> values;
  final String? selectedFacetId;
  final ValueChanged<String> onFacetSelected;
  final VoidCallback onBack;
  final void Function(String traitId, String facetId, double value)
  onFacetChanged;
  final void Function(_PsychTraitDefinition trait, _PsychFacetDefinition facet)
  onFacetEdit;

  const _PsychFacetRadarCard({
    required this.accentColor,
    required this.trait,
    required this.nodes,
    required this.values,
    required this.selectedFacetId,
    required this.onFacetSelected,
    required this.onBack,
    required this.onFacetChanged,
    required this.onFacetEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 15,
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trait.label,
                      style: const TextStyle(
                        color: Color(0xFF2B262C),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'selecione uma faceta sem abrir menus',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.52),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trait.description,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 11,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          _PsychRadarCard(
            accentColor: accentColor,
            title: 'Facetas',
            subtitle: 'toque no ponto ou arraste para definir o valor',
            nodes: nodes,
            values: values,
            selectedNodeId: selectedFacetId,
            selectedNodeScale: selectedFacetId == null ? 1.0 : 1.6,
            onNodeSelected: onFacetSelected,
            interactiveNodeId: selectedFacetId,
            onInteractiveNodeValueChanged: (value) {
              final facetId = selectedFacetId ?? nodes.first.id;
              onFacetChanged(trait.id, facetId, value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '6 facetas',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.72),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'lápis = valor preciso',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.7,
                children: [
                  for (final facet in trait.facets)
                    _PsychFacetTile(
                      accentColor: accentColor,
                      label: facet.label,
                      value: values[facet.id] ?? 5,
                      selected: facet.id == selectedFacetId,
                      onTap: () => onFacetSelected(facet.id),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PsychFacetBarCard extends StatelessWidget {
  final Color accentColor;
  final _PsychTraitDefinition trait;
  final Map<String, double> values;
  final String? selectedFacetId;
  final ValueChanged<String> onFacetSelected;
  final void Function(String traitId, String facetId, double value)
  onFacetChanged;

  const _PsychFacetBarCard({
    required this.accentColor,
    required this.trait,
    required this.values,
    required this.selectedFacetId,
    required this.onFacetSelected,
    required this.onFacetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFacet = selectedFacetId == null
        ? trait.facets.first
        : trait.facets.firstWhere(
            (facet) => facet.id == selectedFacetId,
            orElse: () => trait.facets.first,
          );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.stacked_bar_chart_rounded,
                  size: 14,
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trait.label,
                      style: const TextStyle(
                        color: Color(0xFF2B262C),
                        fontSize: 13.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'toque ou arraste',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.52),
                        fontSize: 10.2,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            trait.description,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 10.2,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          for (final facet in trait.facets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _PsychFacetBarRow(
                accentColor: accentColor,
                traitId: trait.id,
                facet: facet,
                value: values[facet.id] ?? 5,
                selected: facet.id == selectedFacet.id,
                onFacetSelected: onFacetSelected,
                onFacetChanged: onFacetChanged,
              ),
            ),
        ],
      ),
    );
  }
}

class _PsychFacetBarRow extends StatelessWidget {
  final Color accentColor;
  final String traitId;
  final _PsychFacetDefinition facet;
  final double value;
  final bool selected;
  final ValueChanged<String> onFacetSelected;
  final void Function(String traitId, String facetId, double value)
  onFacetChanged;

  const _PsychFacetBarRow({
    required this.accentColor,
    required this.traitId,
    required this.facet,
    required this.value,
    required this.selected,
    required this.onFacetSelected,
    required this.onFacetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = selected
        ? Color.alphaBlend(
            accentColor.withValues(alpha: 0.28),
            const Color(0xFF171419),
          )
        : accentColor.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFacetSelected(facet.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.09)
                : Colors.white.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.18)
                  : accentColor.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      facet.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2E2830),
                        fontSize: 10.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(accentColor, 0.18),
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: fillColor,
                  inactiveTrackColor: Colors.black.withValues(alpha: 0.05),
                  thumbColor: fillColor,
                  overlayColor: fillColor.withValues(alpha: 0.12),
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  min: 0,
                  max: 10,
                  divisions: 100,
                  value: value.clamp(0, 10),
                  onChanged: (next) {
                    onFacetSelected(facet.id);
                    onFacetChanged(
                      traitId,
                      facet.id,
                      next.clamp(0, 10).toDouble(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PsychTraitOverviewTile extends StatelessWidget {
  final Color accentColor;
  final _PsychTraitDefinition trait;
  final double value;
  final bool selected;
  final VoidCallback onTap;

  const _PsychTraitOverviewTile({
    required this.accentColor,
    required this.trait,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFillColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFF171419),
    );
    final selectedBorderColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFF171419),
    );
    final selectedTextColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFF171419),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? selectedFillColor
                : Colors.white.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? selectedBorderColor
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: trait.color,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 108),
                child: Text(
                  trait.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2E2830),
                    fontSize: 11.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: selected
                      ? selectedTextColor
                      : _darkenCharacterDialogColor(accentColor, 0.18),
                  fontSize: 11,
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

class _PsychTraitQuickButton extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final _PsychTraitDefinition trait;
  final bool selected;
  final VoidCallback onTap;

  const _PsychTraitQuickButton({
    required this.accentColor,
    required this.icon,
    required this.trait,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedFillColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFF171419),
    );
    final selectedBorderColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFF171419),
    );
    final selectedTextColor = Color.alphaBlend(
      accentColor.withValues(alpha: 0.35),
      const Color(0xFFF4EEF2),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? selectedFillColor
                : Colors.white.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? selectedBorderColor
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? selectedTextColor : const Color(0xFF544959),
              ),
              const SizedBox(height: 3),
              Text(
                trait.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? selectedTextColor
                      : Colors.black.withValues(alpha: 0.82),
                  fontSize: 9.1,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                width: selected ? 12 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: selected
                      ? selectedTextColor.withValues(alpha: 0.35)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PsychFacetTile extends StatelessWidget {
  final Color accentColor;
  final String label;
  final double value;
  final bool selected;
  final VoidCallback onTap;

  const _PsychFacetTile({
    required this.accentColor,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.24)
                  : accentColor.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2E2830),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                  fontSize: 11,
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

class _PsychFacetValueControl extends StatelessWidget {
  final Color accentColor;
  final _PsychFacetDefinition facet;
  final double value;
  final ValueChanged<double> onChanged;

  const _PsychFacetValueControl({
    required this.accentColor,
    required this.facet,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  facet.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: _darkenCharacterDialogColor(accentColor, 0.18),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '0-10',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            facet.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.54),
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.14),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.10),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              min: 0,
              max: 10,
              divisions: 100,
              value: value.clamp(0, 10),
              onChanged: onChanged,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => onChanged((value - 0.5).clamp(0, 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                iconSize: 18,
                color: _darkenCharacterDialogColor(accentColor, 0.18),
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => onChanged((value + 0.5).clamp(0, 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                iconSize: 18,
                color: _darkenCharacterDialogColor(accentColor, 0.18),
                icon: const Icon(Icons.add_rounded),
              ),
              const Spacer(),
              Text(
                'ajuste preciso',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.44),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PsychRadarPainter extends CustomPainter {
  final Color accentColor;
  final Color pointColor;
  final List<_PsychRadarNodeDefinition> nodes;
  final Map<String, double> values;
  final String? selectedNodeId;
  final double selectedNodeScale;

  const _PsychRadarPainter({
    required this.accentColor,
    required this.pointColor,
    required this.nodes,
    required this.values,
    required this.selectedNodeId,
    required this.selectedNodeScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final geometry = _PsychRadarGeometry(nodes: nodes, values: values);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = geometry.outerRadius(size);
    final points = geometry.pointsFor(size);
    final labels = geometry.labelPointsFor(size);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.07);
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.06);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withValues(alpha: 0.18);
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accentColor.withValues(alpha: 0.76);

    for (var level = 1; level <= 5; level += 1) {
      final radius = outerRadius * (level / 5);
      final polygon = _polygonPoints(center, radius, nodes.length);
      canvas.drawPath(_polygonPath(polygon), gridPaint);
    }

    for (final node in nodes) {
      final index = nodes.indexOf(node);
      final angle = _psychAngleForIndex(index, nodes.length);
      canvas.drawLine(
        center,
        center + Offset(cos(angle), sin(angle)) * outerRadius,
        axisPaint,
      );
    }

    canvas.drawPath(_polygonPath(points), fillPaint);
    canvas.drawPath(_polygonPath(points), outlinePaint);

    for (var index = 0; index < points.length; index += 1) {
      final node = nodes[index];
      final point = points[index];
      final isSelected = node.id == selectedNodeId;
      final pointRadius = isSelected ? 3.8 * selectedNodeScale : 2.7;
      final pointPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = isSelected ? pointColor : pointColor.withValues(alpha: 0.82);
      canvas.drawCircle(
        point,
        pointRadius + 4,
        Paint()
          ..style = PaintingStyle.fill
          ..color = pointColor.withValues(alpha: isSelected ? 0.10 : 0.07)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, pointRadius, pointPaint);

      final valuePainter = TextPainter(
        text: TextSpan(
          text: values[node.id]?.toStringAsFixed(1) ?? '0.0',
          style: TextStyle(
            color: _darkenCharacterDialogColor(pointColor, 0.12),
            fontSize: 9.2,
            fontWeight: FontWeight.w800,
            height: 1,
            shadows: [
              Shadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 4),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 26);
      final labelDirection = point - center;
      final labelDistance = labelDirection.distance;
      final valueOffset = labelDistance == 0
          ? point + const Offset(0, -14)
          : point + (labelDirection / labelDistance) * 14;
      valuePainter.paint(
        canvas,
        valueOffset - Offset(valuePainter.width / 2, valuePainter.height / 2),
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: node.chartLabel,
          style: TextStyle(
            color: isSelected
                ? Color.alphaBlend(
                    pointColor.withValues(alpha: 0.35),
                    const Color(0xFF171419),
                  )
                : Colors.black.withValues(alpha: 0.60),
            fontSize: 10.0,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.68),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 72);

      final labelOffset =
          labels[index] -
          Offset(labelPainter.width / 2, labelPainter.height / 2);
      labelPainter.paint(canvas, labelOffset);
    }
  }

  List<Offset> _polygonPoints(Offset center, double radius, int count) {
    return List<Offset>.generate(count, (index) {
      final angle = _psychAngleForIndex(index, count);
      return center + Offset(cos(angle), sin(angle)) * radius;
    });
  }

  Path _polygonPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i += 1) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PsychRadarPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.selectedNodeScale != selectedNodeScale ||
        oldDelegate.values != values ||
        oldDelegate.nodes != nodes;
  }
}

class _PsychRadarGeometry {
  final List<_PsychRadarNodeDefinition> nodes;
  final Map<String, double> values;

  const _PsychRadarGeometry({required this.nodes, required this.values});

  double outerRadius(Size size) => min(size.width, size.height) * 0.34;

  List<Offset> pointsFor(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = outerRadius(size);
    return List<Offset>.generate(nodes.length, (index) {
      final node = nodes[index];
      final value = (values[node.id] ?? 5).clamp(0.0, 10.0).toDouble();
      final angle = _psychAngleForIndex(index, nodes.length);
      return center + Offset(cos(angle), sin(angle)) * (radius * value / 10);
    });
  }

  List<Offset> labelPointsFor(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = outerRadius(size) + 22;
    return List<Offset>.generate(nodes.length, (index) {
      final angle = _psychAngleForIndex(index, nodes.length);
      return center + Offset(cos(angle), sin(angle)) * radius;
    });
  }

  String? hitTest({required Size size, required Offset localPosition}) {
    final points = pointsFor(size);
    var bestIndex = -1;
    var bestDistance = double.infinity;
    for (var index = 0; index < points.length; index += 1) {
      final distance = (points[index] - localPosition).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = index;
      }
    }

    final hitRadius = max(28.0, outerRadius(size) * 0.18);
    if (bestIndex < 0 || bestDistance > hitRadius) {
      return null;
    }
    return nodes[bestIndex].id;
  }

  double valueFromPosition({
    required Size size,
    required Offset localPosition,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = outerRadius(size);
    if (radius <= 0) return 0;
    final distance = (localPosition - center).distance;
    return ((distance / radius) * 10).clamp(0.0, 10.0).toDouble();
  }
}

double _psychAngleForIndex(int index, int count) {
  return -pi / 2 + (2 * pi * index / count);
}

class _PsychTraitDefinition {
  final String id;
  final String label;
  final String chartLabel;
  final String description;
  final Color color;
  final List<_PsychFacetDefinition> facets;

  const _PsychTraitDefinition({
    required this.id,
    required this.label,
    required this.chartLabel,
    required this.description,
    required this.color,
    required this.facets,
  });
}

class _PsychFacetDefinition {
  final String id;
  final String label;
  final String description;

  const _PsychFacetDefinition({
    required this.id,
    required this.label,
    required this.description,
  });
}

IconData _psychTraitIconFor(String traitId) {
  switch (traitId) {
    case 'consciencia':
      return Icons.checklist_rounded;
    case 'neuroticismo':
      return Icons.bolt_rounded;
    case 'extroversao':
      return Icons.groups_rounded;
    case 'afabilidade':
      return Icons.handshake_rounded;
    case 'abertura':
      return Icons.auto_awesome_rounded;
    default:
      return Icons.psychology_rounded;
  }
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
  late ScrollController _synopsisScrollController;
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
  String _selectedGenderTag = '';
  String _selectedSexualityTag = '';
  String _selectedEthnicityTag = '';
  String _selectedFunctionTag = '';
  String _selectedRelevanceTag = '';
  String? _selectedPsychTraitId;
  String? _selectedPsychFacetId;
  _PsychSplitFocus _psychSplitFocus = _PsychSplitFocus.none;
  _PsychViewMode _psychViewMode = _PsychViewMode.bigFive;
  String? _psychTransitionTraitId;
  Timer? _psychTransitionTimer;

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
    for (final trait in _psychBigFiveTraits) {
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
    _selectedPsychTraitId = _psychBigFiveTraits.first.id;
    _selectedPsychFacetId = _psychBigFiveTraits.first.facets.first.id;
  }

  @override
  void dispose() {
    _psychTransitionTimer?.cancel();
    _nameController.dispose();
    _aliasController.dispose();
    _synopsisController.removeListener(_syncSynopsisDraft);
    _synopsisController.dispose();
    _mottoController.removeListener(_syncMottoDraft);
    _mottoController.dispose();
    _formationsController.dispose();
    _titlesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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
    _hasPendingParentSync = true;
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
                  child: _NotebookHeader(data: _draft, onClose: _closePage),
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
                    onChanged: (value) =>
                        _updateDraft(_draft.copyWith(name: value)),
                  ),
                  const SizedBox(height: 10),
                  _NotebookTextFieldCard(
                    accentColor: _draft.accent,
                    icon: Icons.alternate_email_rounded,
                    label: 'Vulgo',
                    placeholderText: _aliasPlaceholderText,
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

  Widget _buildPsychologyTabCompact() {
    final selectedTrait = _psychTraitDefinitionFor(_selectedPsychTraitId);
    final selectedFacet = _selectedPsychFacetId == null
        ? selectedTrait.facets.first
        : _psychFacetDefinitionFor(selectedTrait, _selectedPsychFacetId!);
    final leftFlex = _psychSplitFocus == _PsychSplitFocus.facets ? 1 : 4;
    final rightFlex = _psychSplitFocus == _PsychSplitFocus.traits ? 1 : 4;

    Widget buildBigFiveCard() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PsychRadarCard(
            accentColor: _draft.accent,
            title: 'Big Five',
            subtitle: 'toque num vértice para selecionar',
            nodes: _psychBigFiveRadarNodes,
            values: _psychTraitValues,
            selectedNodeId: _selectedPsychTraitId,
            selectedNodeScale: 1.06,
            onNodeSelected: _selectPsychTrait,
          ),
          const SizedBox(height: 8),
          Container(
            height: 62,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _draft.accent.withValues(alpha: 0.08)),
            ),
            child: SizedBox(
              height: 62,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var index = 0;
                    index < _psychBigFiveTraits.length;
                    index += 1
                  )
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == _psychBigFiveTraits.length - 1
                              ? 0
                              : 6,
                        ),
                        child: _PsychTraitQuickButton(
                          accentColor: _draft.accent,
                          icon: _psychTraitIconFor(
                            _psychBigFiveTraits[index].id,
                          ),
                          trait: _psychBigFiveTraits[index],
                          selected:
                              _selectedPsychTraitId ==
                              _psychBigFiveTraits[index].id,
                          onTap: () =>
                              _selectPsychTrait(_psychBigFiveTraits[index].id),
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

    final facetCard = _PsychFacetBarCard(
      accentColor: _draft.accent,
      trait: selectedTrait,
      values: _psychFacetValuesFor(selectedTrait.id),
      selectedFacetId: selectedFacet.id,
      onFacetSelected: _selectPsychFacet,
      onFacetChanged: _setPsychFacetValue,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: leftFlex, child: buildBigFiveCard()),
                const SizedBox(width: 12),
                Expanded(flex: rightFlex, child: facetCard),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildBigFiveCard(),
              const SizedBox(height: 12),
              facetCard,
            ],
          );
        },
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
                    index < _psychBigFiveTraits.length;
                    index += 1
                  )
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == _psychBigFiveTraits.length - 1
                              ? 0
                              : 6,
                        ),
                        child: _PsychTraitQuickButton(
                          accentColor: _draft.accent,
                          icon: _psychTraitIconFor(
                            _psychBigFiveTraits[index].id,
                          ),
                          trait: _psychBigFiveTraits[index],
                          selected:
                              _selectedPsychTraitId ==
                              _psychBigFiveTraits[index].id,
                          onTap: () =>
                              _selectPsychTrait(_psychBigFiveTraits[index].id),
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

    Widget buildBigFiveOptions() {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _draft.accent.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Opções do Big Five',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.74),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 62,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (
                    var index = 0;
                    index < _psychBigFiveTraits.length;
                    index += 1
                  )
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == _psychBigFiveTraits.length - 1
                              ? 0
                              : 6,
                        ),
                        child: _PsychTraitQuickButton(
                          accentColor: _draft.accent,
                          icon: _psychTraitIconFor(
                            _psychBigFiveTraits[index].id,
                          ),
                          trait: _psychBigFiveTraits[index],
                          selected:
                              _selectedPsychTraitId ==
                              _psychBigFiveTraits[index].id,
                          onTap: () =>
                              _selectPsychTrait(_psychBigFiveTraits[index].id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget buildFacetOptions() {
      final selectedFacetValue = _psychFacetValue(
        selectedTrait.id,
        selectedFacet.id,
      );

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.56),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _draft.accent.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  "Faceta selecionada",
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.74),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _draft.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    selectedFacetValue.toStringAsFixed(1),
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(_draft.accent, 0.14),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedFacet.label,
              style: const TextStyle(
                color: Color(0xFF2B262C),
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedFacet.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.56),
                fontSize: 11,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajuste direto no gráfico de barras acima.",
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.46),
                fontSize: 10.5,
                height: 1.25,
              ),
            ),
          ],
        ),
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

  Widget _buildPsychologyTab() {
    final selectedTrait = _psychTraitDefinitionFor(_selectedPsychTraitId);
    final selectedFacet = _selectedPsychFacetId == null
        ? null
        : _psychFacetDefinitionFor(selectedTrait, _selectedPsychFacetId!);
    final modeKey = _psychViewMode == _PsychViewMode.bigFive
        ? 'bigFive'
        : 'facet:${selectedTrait.id}:${selectedFacet?.id ?? ""}';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final scale = Tween<double>(
            begin: 0.98,
            end: 1,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(modeKey),
          child: _psychViewMode == _PsychViewMode.bigFive
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PsychRadarCard(
                      accentColor: _draft.accent,
                      title: 'Big Five',
                      subtitle: 'toque num vértice para abrir',
                      nodes: _psychBigFiveRadarNodes,
                      values: _psychTraitValues,
                      selectedNodeId: _psychTransitionTraitId,
                      selectedNodeScale: _psychTransitionTraitId == null
                          ? 1.0
                          : 1.7,
                      onNodeSelected: _selectPsychTrait,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Resumo dos traços',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.74),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final trait in _psychBigFiveTraits)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PsychTraitOverviewTile(
                          accentColor: _draft.accent,
                          trait: trait,
                          value: _psychTraitValue(trait.id),
                          selected: _selectedPsychTraitId == trait.id,
                          onTap: () => _selectPsychTrait(trait.id),
                        ),
                      ),
                  ],
                )
              : _PsychFacetRadarCard(
                  accentColor: _draft.accent,
                  trait: selectedTrait,
                  nodes: _psychFacetRadarNodesFor(selectedTrait),
                  values: _psychFacetValuesFor(selectedTrait.id),
                  selectedFacetId: selectedFacet?.id,
                  onFacetSelected: _selectPsychFacet,
                  onBack: _returnToBigFive,
                  onFacetChanged: _setPsychFacetValue,
                  onFacetEdit: _editPsychFacetValue,
                ),
        ),
      ),
    );
  }

  Future<void> _editPsychFacetValue(
    _PsychTraitDefinition trait,
    _PsychFacetDefinition facet,
  ) async {
    final initialValue = _psychFacetValue(trait.id, facet.id);
    final controller = TextEditingController(
      text: initialValue.toStringAsFixed(1),
    );
    double workingValue = initialValue;

    void syncController(double value) {
      final text = value.toStringAsFixed(1);
      controller.value = controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
        composing: TextRange.empty,
      );
    }

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              void updateValue(double value) {
                final nextValue = value.clamp(0.0, 10.0).toDouble();
                setModalState(() {
                  workingValue = nextValue;
                  syncController(nextValue);
                });
                _setPsychFacetValue(trait.id, facet.id, nextValue);
              }

              return ProjectBottomSheetFrame(
                title: 'Ajustar ${facet.label}',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trait.label,
                      style: const TextStyle(
                        color: Color(0xFF2C262C),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      facet.description,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.56),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.42),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _draft.accent,
                              inactiveTrackColor: _draft.accent.withValues(
                                alpha: 0.14,
                              ),
                              thumbColor: _draft.accent,
                              overlayColor: _draft.accent.withValues(
                                alpha: 0.12,
                              ),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              min: 0,
                              max: 10,
                              divisions: 100,
                              value: workingValue.clamp(0, 10),
                              onChanged: updateValue,
                            ),
                          ),
                        ),
                        Text(
                          '10',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.42),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,\.]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Valor preciso',
                              helperText: '0 a 10, com uma casa decimal',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onSubmitted: (text) {
                              final parsed = double.tryParse(
                                text.replaceAll(',', '.'),
                              );
                              if (parsed != null) {
                                updateValue(parsed);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => updateValue(workingValue - 0.5),
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            IconButton(
                              onPressed: () => updateValue(workingValue + 0.5),
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Concluir'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  List<_PsychRadarNodeDefinition> get _psychBigFiveRadarNodes {
    return [
      for (final trait in _psychBigFiveTraits)
        _PsychRadarNodeDefinition(
          id: trait.id,
          label: trait.label,
          chartLabel: trait.chartLabel,
          description: trait.description,
          color: trait.color,
        ),
    ];
  }

  List<_PsychRadarNodeDefinition> _psychFacetRadarNodesFor(
    _PsychTraitDefinition trait,
  ) {
    return [
      for (final facet in trait.facets)
        _PsychRadarNodeDefinition(
          id: facet.id,
          label: facet.label,
          chartLabel: facet.label,
          description: facet.description,
          color: trait.color,
        ),
    ];
  }

  Map<String, double> get _psychTraitValues {
    return {
      for (final trait in _psychBigFiveTraits)
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
      _psychSplitFocus = _PsychSplitFocus.traits;
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
      return _psychBigFiveTraits.first;
    }
    return _psychBigFiveTraits.firstWhere(
      (trait) => trait.id == traitId,
      orElse: () => _psychBigFiveTraits.first,
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

  void _returnToBigFive() {
    setState(() {
      _psychSplitFocus = _PsychSplitFocus.traits;
      _selectedPsychTraitId = _psychBigFiveTraits.first.id;
      _selectedPsychFacetId = _psychBigFiveTraits.first.facets.first.id;
    });
  }

  void _selectPsychFacet(String facetId) {
    setState(() {
      _psychSplitFocus = _PsychSplitFocus.facets;
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

  Future<void> _openTagSelectorLegacy(_TagKind kind) async {
    _clearMenuFocus();
    final selectedLabel = _selectedTagFor(kind);
    final isRequired = kind == _TagKind.gender;
    final currentValue = selectedLabel;
    final options = _knownTagsFor(kind);

    final result = await showProjectDismissibleSheet<String>(
      context: context,
      title: _tagKindTitle(kind),
      builder: (context) {
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
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
        );
      },
    );

    _clearMenuFocus();
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
    _clearMenuFocus();
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
            final sheetHeight = min(max(screenHeight - 180, 280.0), 640.0);

            return ProjectBottomSheetFrame(
              title: 'Relevância narrativa',
              child: SizedBox(
                height: sheetHeight,
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

    _clearMenuFocus();
    if (!mounted || result == null) return;
    setState(() {
      _relevance = result;
      _selectedRelevanceTag = result.categoryForScore(result.score).name;
      _updateDraft(_draft.copyWith(relevanceTag: _selectedRelevanceTag));
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
          headerHeight: 200,
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
    final glowColor = data.accent.withValues(alpha: 0.34);
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
            Shadow(color: glowColor, blurRadius: 18),
            Shadow(color: glowColor, blurRadius: 8),
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
          if (data.alias.trim().isNotEmpty)
            Text(
              data.alias,
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
            sigma: 0,
            opacity: 0.9,
          ),
        ] else ...[
          _NotebookHeaderCoverIconLayer(
            accentColor: data.accent,
            sigma: 0,
            opacity: 0.36,
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

  const _NotebookHeaderCoverImageLayer({
    required this.profileImage,
    required this.sigma,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final image = SizedBox.expand(
      child: ProjectImageTransformView(
        imageBytes: profileImage.bytes!,
        imageWidth: profileImage.width ?? 1,
        imageHeight: profileImage.height ?? 1,
        scale: profileImage.scale,
        offsetX: profileImage.offsetX,
        offsetY: profileImage.offsetY,
      ),
    );

    return Opacity(
      opacity: opacity,
      child: sigma <= 0
          ? image
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: image,
            ),
    );
  }
}

class _NotebookHeaderCoverIconLayer extends StatelessWidget {
  final Color accentColor;
  final double sigma;
  final double opacity;

  const _NotebookHeaderCoverIconLayer({
    required this.accentColor,
    required this.sigma,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-14, 0),
        child: Icon(
          Icons.person_rounded,
          size: 220,
          color: accentColor.withValues(alpha: 0.96),
        ),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: sigma <= 0
          ? icon
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: icon,
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

    return DecoratedBox(
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
  final Color leadingIconColor;
  final String title;
  final String subtitle;
  final List<String>? fields;
  final IconData icon;
  final Widget child;

  const _CollapsibleSection({
    required this.accentColor,
    required this.leadingIconColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.fields,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
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
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.75, 1.0],
                  ).createShader(bounds);
                },
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
                        color: widget.leadingIconColor,
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
                          const SizedBox(height: 4),
                          if (widget.fields != null &&
                              widget.fields!.isNotEmpty)
                            Text(
                              widget.fields!.map((f) => '• $f').join('  '),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.48),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _NotebookTextFieldCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final String placeholderText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;

  const _NotebookTextFieldCard({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.placeholderText,
    required this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color(0xFF544959),
      fontSize: 12.5,
      height: 1.35,
    );
    const placeholderStyle = TextStyle(
      color: Color(0xFF8F8990),
      fontSize: 11,
      height: 1.35,
      fontStyle: FontStyle.italic,
    );

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
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NotebookDynamicTextFieldPanel(
            accentColor: accentColor,
            placeholderText: placeholderText,
            controller: controller,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            textStyle: textStyle,
            placeholderStyle: placeholderStyle,
          ),
        ],
      ),
    );
  }
}

class _NotebookDynamicTextFieldPanel extends StatefulWidget {
  final Color accentColor;
  final String placeholderText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;
  final TextStyle textStyle;
  final TextStyle placeholderStyle;

  const _NotebookDynamicTextFieldPanel({
    required this.accentColor,
    required this.placeholderText,
    required this.controller,
    required this.onChanged,
    required this.minLines,
    required this.maxLines,
    required this.textStyle,
    required this.placeholderStyle,
  });

  @override
  State<_NotebookDynamicTextFieldPanel> createState() =>
      _NotebookDynamicTextFieldPanelState();
}

class _NotebookDynamicTextFieldPanelState
    extends State<_NotebookDynamicTextFieldPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const panelPadding = EdgeInsets.all(12);
    const scrollPadding = EdgeInsets.only(right: 8);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            return EditableSynopsisPanel(
              controller: widget.controller,
              scrollController: _scrollController,
              isEditing: true,
              onChanged: widget.onChanged,
              height: _calculateHeight(
                context: context,
                maxWidth: constraints.maxWidth,
                panelPadding: panelPadding,
                scrollPadding: scrollPadding,
              ),
              placeholderText: widget.placeholderText,
              textStyle: widget.textStyle,
              placeholderStyle: widget.placeholderStyle,
              focusedBorderColor: widget.accentColor,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              keyboardType: widget.maxLines == 1
                  ? TextInputType.text
                  : TextInputType.multiline,
              textInputAction: widget.maxLines == 1
                  ? TextInputAction.next
                  : TextInputAction.newline,
              panelPadding: panelPadding,
              scrollPadding: scrollPadding,
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.78),
                width: 0.7,
              ),
              viewerBuilder: (context, text, style) => Text(text, style: style),
            );
          },
        );
      },
    );
  }

  double _calculateHeight({
    required BuildContext context,
    required double maxWidth,
    required EdgeInsetsGeometry panelPadding,
    required EdgeInsetsGeometry scrollPadding,
  }) {
    final text = widget.controller.text.trim().isEmpty
        ? widget.placeholderText
        : widget.controller.text;
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
    final measurementStyle = widget.controller.text.trim().isEmpty
        ? widget.placeholderStyle
        : widget.textStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: measurementStyle),
      textDirection: Directionality.of(context),
      maxLines: widget.maxLines,
    )..layout(maxWidth: availableWidth);
    final lineStyle = measurementStyle;
    final lineHeight = (lineStyle.fontSize ?? 11) * (lineStyle.height ?? 1.0);
    final minimumHeight =
        (lineHeight * widget.minLines) + resolvedPanelPadding.vertical;
    final maxHeight = widget.maxLines == 1 ? minimumHeight : 220.0;
    final estimatedHeight =
        textPainter.size.height + resolvedPanelPadding.vertical;

    return estimatedHeight.clamp(minimumHeight, maxHeight);
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
