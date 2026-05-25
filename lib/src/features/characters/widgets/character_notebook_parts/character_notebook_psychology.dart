part of '../character_notebook_page.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
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
                    final pointSelection = geometry.hitTestPoint(
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                    final labelSelection = geometry.hitTestLabel(
                      size: chartSize,
                      localPosition: details.localPosition,
                    );
                    final selected = pointSelection ?? labelSelection;
                    if (selected != null) {
                      onNodeSelected(selected);
                    }
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
          LayoutBuilder(
            builder: (context, constraints) {
              final tileHeight = switch (constraints.maxWidth) {
                >= 620 => 96.0,
                >= 500 => 92.0,
                _ => 90.0,
              };

              return GridView.builder(
                itemCount: trait.facets.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: tileHeight,
                ),
                itemBuilder: (context, index) {
                  final facet = trait.facets[index];
                  return _PsychFacetBarRow(
                    accentColor: accentColor,
                    traitId: trait.id,
                    facet: facet,
                    value: values[facet.id] ?? 5,
                    selected: facet.id == selectedFacet.id,
                    onFacetSelected: onFacetSelected,
                    onFacetChanged: onFacetChanged,
                  );
                },
              );
            },
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
    final tooltipTheme = Theme.of(context).copyWith(
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF181419),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11.2,
          height: 1.35,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        waitDuration: Duration.zero,
        showDuration: const Duration(seconds: 8),
        preferBelow: false,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onFacetSelected(facet.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.42 : 0.34),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.52)
                  : accentColor.withValues(alpha: 0.07),
              width: selected ? 1.15 : 0.9,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 0,
                      spreadRadius: 1.1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            facet.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF2E2830),
                              fontSize: 10.3,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Theme(
                          data: tooltipTheme,
                          child: Tooltip(
                            message: facet.description,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outline_rounded,
                              size: 12,
                              color: Colors.black.withValues(alpha: 0.42),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: _darkenCharacterDialogColor(accentColor, 0.18),
                        fontSize: 9.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 20,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: fillColor,
                    inactiveTrackColor: Colors.black.withValues(alpha: 0.05),
                    thumbColor: fillColor,
                    overlayColor: fillColor.withValues(alpha: 0.1),
                    trackHeight: 3.2,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 4.5,
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

  String? hitTestPoint({required Size size, required Offset localPosition}) {
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

  String? hitTestLabel({required Size size, required Offset localPosition}) {
    final labels = labelPointsFor(size);
    for (var index = 0; index < labels.length; index += 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: nodes[index].chartLabel,
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 72);

      final labelOffset =
          labels[index] - Offset(textPainter.width / 2, textPainter.height / 2);
      final labelRect = (labelOffset & textPainter.size).inflate(8);
      if (labelRect.contains(localPosition)) {
        return nodes[index].id;
      }
    }
    return null;
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

class _PsychTraitContentOverride {
  final String label;
  final String chartLabel;
  final String description;

  const _PsychTraitContentOverride({
    required this.label,
    required this.chartLabel,
    required this.description,
  });
}

class _PsychFacetContentOverride {
  final String label;
  final String description;

  const _PsychFacetContentOverride({
    required this.label,
    required this.description,
  });
}

const Map<String, _PsychTraitContentOverride>
_psychTraitContentOverrides = <String, _PsychTraitContentOverride>{
  'consciencia': _PsychTraitContentOverride(
    label: 'Consciência',
    chartLabel: 'Consciência',
    description:
        'Diz respeito à forma como controlamos, conduzimos e direcionamos nossos impulsos.',
  ),
  'neuroticismo': _PsychTraitContentOverride(
    label: 'Neuroticismo',
    chartLabel: 'Neuroticismo',
    description: 'Tendência a sentir emoções negativas.',
  ),
  'afabilidade': _PsychTraitContentOverride(
    label: 'Afabilidade',
    chartLabel: 'Afabilidade',
    description:
        'Pessoas agradáveis aos outros, simpáticas. Se preocupam com a cooperação e a harmonia social e facilmente se dão bem com outras pessoas.',
  ),
  'abertura': _PsychTraitContentOverride(
    label: 'Abertura à experiência',
    chartLabel: 'Abertura\nà experiência',
    description:
        'Pessoas criativas, apreciadoras da arte e da beleza e que gostam do novo.',
  ),
  'extroversao': _PsychTraitContentOverride(
    label: 'Extroversão',
    chartLabel: 'Extroversão',
    description:
        'A extroversão é marcada pela sociabilidade, engajamento com o mundo externo.',
  ),
};

const Map<String, Map<String, _PsychFacetContentOverride>>
_psychFacetContentOverrides = <String, Map<String, _PsychFacetContentOverride>>{
  'consciencia': <String, _PsychFacetContentOverride>{
    'competencia': _PsychFacetContentOverride(
      label: 'Autoeficácia',
      description:
          'Quem pontua alto normalmente tem confiança para realizar as coisas. Se sente capaz, acredita que tem a inteligência (senso comum) e autocontrole necessários para alcançar o sucesso e lida tranquilamente com os desafios e dificuldades da vida. Pessoas com pontuação baixa não se sentem eficazes e podem se sentir perdidas, como se não estivessem no controle de suas vidas.',
    ),
    'ordem': _PsychFacetContentOverride(
      label: 'Ordem',
      description:
          'Pontuação alta indica clareza e abordagem metódica das tarefas. Essas pessoas gostam de viver de acordo com rotinas e horários, costumam criar listas e fazer planejamento. Organização é seu sobrenome. Pessoas com baixa pontuação tendem a ser desorganizadas e dispersas.',
    ),
    'senso_de_dever': _PsychFacetContentOverride(
      label: 'Senso de Dever',
      description:
          'Pessoas conscienciosas, muito dogmáticas em seus valores. Valorizam o dever e a obrigação. Têm um forte senso moral. Pessoas com pontuação baixa consideram regras, contratos e regulamentações exageradas, podendo ser vistas como não confiáveis ou até mesmo irresponsáveis.',
    ),
    'busca_de_realizacao': _PsychFacetContentOverride(
      label: 'Realização-Esforço',
      description:
          "Disposição para trabalhar duro e motivação por metas, com esforço para alcançar a excelência. Gostam de se sentir reconhecidas e têm objetivos claros na vida. Às vezes a busca por perfeição as torna 'workaholic', obcecadas com o trabalho. Pessoas que pontuam pouco nessa competência se sentem realizadas quando cumprem determinada tarefa com o mínimo de trabalho e esforço, podendo ser vistas como preguiçosas.",
    ),
    'autodisciplina': _PsychFacetContentOverride(
      label: 'Autodisciplina',
      description:
          "Alta capacidade de seguir com as tarefas e limitar a distração. Se mantêm persistentes mesmo em tarefas difíceis ou de que não gostem. Não procrastinam para começar e finalizar tarefas e são extremamente focadas quando iniciam uma atividade. Pessoas com pouca autodisciplina procrastinam e têm mais dificuldade de 'acompanhar o ritmo'. Muitas vezes não conseguem completar tarefas, mesmo as que querem muito finalizar.",
    ),
    'deliberacao': _PsychFacetContentOverride(
      label: 'Cautela',
      description:
          'Tendem a refletir cuidadosamente sobre as decisões antes de agir. Pensam nas possibilidades e consequências das ações antes de tomar uma decisão. Já os que pontuam baixo normalmente falam ou fazem a primeira coisa que vem à mente sem pensar muito nas consequências de suas palavras e ações.',
    ),
  },
  'afabilidade': <String, _PsychFacetContentOverride>{
    'confianca': _PsychFacetContentOverride(
      label: 'Confiança',
      description:
          'Quem pontua alto em confiança normalmente acredita que a maioria das pessoas é justa, honesta e bem-intencionada por natureza. Pessoas com baixa pontuação são desconfiadas e enxergam os outros como egoístas, desonestos e perigosos.',
    ),
    'sinceridade': _PsychFacetContentOverride(
      label: 'Moralidade',
      description:
          'Pessoas que se baseiam na ética e na justiça, sinceras e francas. Esse grupo tem facilidade em lidar com outras pessoas e normalmente não gosta de manipulações nas relações. Pontuação baixa caracteriza pessoas que acreditam que é necessário ou comum que as relações sociais causem decepção.',
    ),
    'altruismo': _PsychFacetContentOverride(
      label: 'Altruísmo',
      description:
          'Se sentem recompensadas ao ajudar outras pessoas como forma de autorrealização, fortemente movidas pela compaixão e dedicadas a promover o bem-estar dos outros. Extremamente generosas e dispostas a ajudar quem está em necessidade. Pontuação baixa para altruísmo indica pessoas que não se sentem bem ajudando necessitados. Ajudar parece mais uma obrigação do que uma ação gratificante.',
    ),
    'complacencia': _PsychFacetContentOverride(
      label: 'Cooperação',
      description:
          'Indivíduos que não gostam de confrontos ou agressividade. Preferem comprometer ou negar suas próprias necessidades, se isso resultar em harmonia entre os demais. Já os que pontuam pouco são mais propensos a intimidar os outros para conseguir o que querem.',
    ),
    'modestia': _PsychFacetContentOverride(
      label: 'Modéstia',
      description:
          'Pessoas que falam de realizações próprias com bastante humildade. Não gostam de ser consideradas superiores ou melhores do que as outras. Em alguns casos essa atitude pode ocasionar baixa autoconfiança ou autoestima. As que têm pontuação baixa se consideram superiores e podem ser vistas como arrogantes por outras pessoas.',
    ),
    'ternura': _PsychFacetContentOverride(
      label: 'Empatia',
      description:
          'Pontuação alta indica capacidade de se pôr no lugar do outro. Sentem a dor alheia com compaixão e se preocupam com os demais. O sofrimento humano é algo que as afeta fortemente. Pessoas com baixa pontuação nessa competência não se afetam muito pelo sofrimento humano. Acreditam na meritocracia e que julgamentos são baseados na razão. Estão mais preocupadas com a verdade e a justiça imparcial do que com a misericórdia ou pena.',
    ),
  },
  'abertura': <String, _PsychFacetContentOverride>{
    'fantasia': _PsychFacetContentOverride(
      label: 'Fantasia',
      description:
          'Vida mental ativa, criativa e de forte imaginação. Para essas pessoas o mundo real é muito comum, normal e rotineiro, por isso estão sempre criando maneiras de fantasiar um mundo mais interessante e fabuloso. Quem não tem pontuação alta para fantasia é mais orientado por fatos do que por imaginação.',
    ),
    'estetica': _PsychFacetContentOverride(
      label: 'Estética',
      description:
          'Forte valorização da arte e da beleza, interesse por poesia, arte e música. Essas pessoas normalmente desenvolvem habilidades artísticas e têm sensibilidade a eventos naturais e à estética. Já as que têm baixa pontuação têm pouca ou nenhuma sensibilidade estética e interesse pela arte.',
    ),
    'sentimentos': _PsychFacetContentOverride(
      label: 'Emotividade',
      description:
          'Receptivas e conscientes de seus próprios sentimentos e emoções. Sentem emoções fortes e tendem a expressá-las abertamente. Pessoas pouco emotivas tendem a não expressar suas emoções de forma aberta.',
    ),
    'acoes': _PsychFacetContentOverride(
      label: 'Aventura',
      description:
          'Dispostas a explorar novos lugares, experimentar novos alimentos e começar novas atividades. Pessoas aventureiras estão sempre em busca do desconhecido, gostam de desbravar lugares e não gostam de rotina. É aquela pessoa que gosta de mudar a cada dia seu caminho de volta para casa. Ao contrário, pessoas com baixa pontuação em aventura se sentem desconfortáveis com mudanças e preferem rotinas familiares.',
    ),
    'ideias': _PsychFacetContentOverride(
      label: 'Intelecto',
      description:
          'Curiosas e cheias de ideias. Interesse por argumentos filosóficos. Pessoas abertas para o novo e o incomum gostam de debater questões intelectuais, decifrar enigmas e enfrentar desafios para a mente. Normalmente se saem melhor em questões de raciocínio rápido e lógica. Já pessoas com baixa pontuação preferem lidar com pessoas em vez de ideias e consideram exercícios intelectuais uma perda de tempo.',
    ),
    'valores': _PsychFacetContentOverride(
      label: 'Liberalismo',
      description:
          'Gosta de explorar e avaliar seus próprios valores sociais, políticos e religiosos. Liberalismo psicológico refere-se a uma abertura para desafiar a autoridade, o convencional e o tradicional. Demonstra aversão em relação às regras, se questiona com frequência sobre o que é imposto e aprecia revoluções sociais. Não se importa com estabilidade e segurança, é inconformada e entra em conflito com a tradição. Já o contrário, pessoas conservadoras psicologicamente, preferem segurança e estabilidade. Sentem-se bem com o tradicional e normalmente não saem da zona de conforto.',
    ),
  },
  'extroversao': <String, _PsychFacetContentOverride>{
    'cordialidade': _PsychFacetContentOverride(
      label: 'Simpatia',
      description:
          'Pessoas amigáveis, que fazem amigos rapidamente e com muita facilidade. As que pontuam baixo em simpatia não são necessariamente frias e hostis, são apenas menos comunicativas, mais distantes e reservadas.',
    ),
    'gregariedade': _PsychFacetContentOverride(
      label: 'Sociabilidade',
      description:
          'Preferência pela companhia dos outros e tendência a evitar estar sozinho. Se sentem bem em multidões e aglomerações. Já as que pontuam pouco tendem a se sentir tensas em grandes multidões e por isso evitam aglomerações. Não são antissociais nem antipáticas.',
    ),
    'assertividade': _PsychFacetContentOverride(
      label: 'Assertividade',
      description:
          'Gostam de assumir o comando e direcionar as atividades dos outros. Tendem a conquistar cargos de liderança e a dominar situações sociais. Já pessoas com baixa pontuação tendem a ser mais quietas e não se incomodam quando outras comandam as atividades em grupo.',
    ),
    'atividade': _PsychFacetContentOverride(
      label: 'Atividade',
      description:
          'Pessoas com estilo de vida acelerado e propensas a estarem ativas. Gostam de estar em movimento e normalmente estão envolvidas em muitas atividades ao mesmo tempo. Pessoas com baixa pontuação seguem um ritmo mais lento e tranquilo, sendo mais relaxadas.',
    ),
    'excitação': _PsychFacetContentOverride(
      label: 'Busca de Sensações',
      description:
          'Alegres e estimuladas. Têm preferência por barulho. Ficam entediadas facilmente, adoram luzes brilhantes e movimento. São mais propensas a se arriscar e viver fortes emoções. Pessoas com baixa pontuação não gostam de barulho e tumulto, e fogem de experiências com emoções intensas.',
    ),
    'emocao_positiva': _PsychFacetContentOverride(
      label: 'Emoções Positivas',
      description:
          'Pessoas alto-astral, bem-humoradas, lidam com as situações com emoções positivas, felicidade, entusiasmo e alegria. Pessoas com baixa pontuação não têm um temperamento tão enérgico e alto-astral.',
    ),
  },
  'neuroticismo': <String, _PsychFacetContentOverride>{
    'ansiedade': _PsychFacetContentOverride(
      label: 'Ansiedade',
      description:
          'Tipo de pessoa que está sempre em alerta. Sente ansiedade e que algo perigoso está prestes a acontecer. É mais propensa a sentir medo e tensão em situações comuns. Pessoas com baixa pontuação em ansiedade geralmente não têm medo, sendo calmas e tranquilas.',
    ),
    'raiva': _PsychFacetContentOverride(
      label: 'Raiva',
      description:
          'Pessoas com alta pontuação nessa categoria se frustram quando as coisas não vão do seu jeito e têm tendência a sentir amargura e raiva. Gostam de ser tratadas de forma justa e se sentem injustiçadas quando enganadas. Pessoas com baixa pontuação dificilmente passam raiva.',
    ),
    'depressao': _PsychFacetContentOverride(
      label: 'Melancolia',
      description:
          'Pontuações altas identificam pessoas que têm dificuldade em iniciar atividades e maior propensão a experimentar sintomas depressivos.',
    ),
    'autoconsciencia': _PsychFacetContentOverride(
      label: 'Autoconsciência',
      description:
          'Pessoas autoconscientes são sensíveis ao que os outros pensam sobre elas. A preocupação com rejeição e ridicularização as deixa com vergonha e desconfortáveis perto de outras pessoas. Sentem-se constrangidas facilmente e frequentemente envergonhadas. O medo de que os outros vão criticá-las ou tirar sarro delas é exagerado e irrealista.',
    ),
    'impulsividade': _PsychFacetContentOverride(
      label: 'Impulsividade',
      description:
          'Pessoas impulsivas são incapazes de controlar desejos ou impulsos. Sentem dificuldade em resistir a vontades. Tendem a satisfazer seus prazeres e buscam recompensas instantâneas em vez de benefícios de longo prazo. Já pessoas pouco impulsivas não experimentam necessidades exageradas ou desejos irresistíveis.',
    ),
    'vulnerabilidade': _PsychFacetContentOverride(
      label: 'Vulnerabilidade',
      description:
          'Pessoas com pontuação alta em vulnerabilidade experimentam pânico, confusão e desamparo quando estão sob pressão ou estresse. Pessoas com baixa pontuação se sentem mais equilibradas, confiantes e com raciocínio claro quando estão estressadas.',
    ),
  },
};

List<_PsychTraitDefinition> get _psychBigFiveCatalog => <_PsychTraitDefinition>[
  for (final trait in _psychBigFiveTraits)
    _PsychTraitDefinition(
      id: trait.id,
      label: _psychTraitContentOverrides[trait.id]?.label ?? trait.label,
      chartLabel:
          _psychTraitContentOverrides[trait.id]?.chartLabel ?? trait.chartLabel,
      description:
          _psychTraitContentOverrides[trait.id]?.description ??
          trait.description,
      color: trait.color,
      facets: <_PsychFacetDefinition>[
        for (final facet in trait.facets)
          _PsychFacetDefinition(
            id: facet.id,
            label:
                _psychFacetContentOverrides[trait.id]?[facet.id]?.label ??
                facet.label,
            description:
                _psychFacetContentOverrides[trait.id]?[facet.id]?.description ??
                facet.description,
          ),
      ],
    ),
];

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

class _PreferenceLevelDefinition {
  final String id;
  final String label;
  final Color color;
  final IconData icon;

  const _PreferenceLevelDefinition({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _PreferenceCategoryDefinition {
  final String id;
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  const _PreferenceCategoryDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}

const List<_PreferenceLevelDefinition> _preferenceLevels =
    <_PreferenceLevelDefinition>[
      _PreferenceLevelDefinition(
        id: 'favoritos',
        label: 'Favoritos',
        color: Color(0xFFC9413E),
        icon: Icons.star_rounded,
      ),
      _PreferenceLevelDefinition(
        id: 'ama',
        label: 'Ama',
        color: Color(0xFFE5792E),
        icon: Icons.star_rounded,
      ),
      _PreferenceLevelDefinition(
        id: 'gosta',
        label: 'Gosta',
        color: Color(0xFFF0A94B),
        icon: Icons.stars_rounded,
      ),
      _PreferenceLevelDefinition(
        id: 'tolera',
        label: 'Tolera',
        color: Color(0xFFE4C84A),
        icon: Icons.star_half_rounded,
      ),
      _PreferenceLevelDefinition(
        id: 'odeia',
        label: 'Odeia',
        color: Color(0xFF5E9D78),
        icon: Icons.star_border_rounded,
      ),
    ];

const List<_PreferenceCategoryDefinition>
_preferenceCategories = <_PreferenceCategoryDefinition>[
  _PreferenceCategoryDefinition(
    id: 'gastronomia',
    label: 'Gastronomia',
    description: 'Comidas, bebidas, temperos e iguarias em geral.',
    color: Color(0xFFB47B38),
    icon: Icons.restaurant_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'artes_midia',
    label: 'Artes e mídia',
    description:
        'Música, literatura, cinema, pintura e outras expressões culturais.',
    color: Color(0xFF8B5FBF),
    icon: Icons.movie_filter_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'sensacoes',
    label: 'Sensações',
    description:
        'Percepções subjetivas evocadas por cheiros, sons, climas, atmosferas, etc.',
    color: Color(0xFF4F8FB8),
    icon: Icons.spa_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'atividades',
    label: 'Atividades',
    description:
        'Basicamente qualquer verbo que não seja um fenômeno da natureza e que seja realizável pelo personagem.',
    color: Color(0xFFC65B6A),
    icon: Icons.directions_run_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'estetica',
    label: 'Estética',
    description:
        'Aspecto visual de objetos, moda, arquitetura, design e formas materiais.',
    color: Color(0xFFD35E9F),
    icon: Icons.palette_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'comportamento',
    label: 'Comportamento',
    description: 'Atitudes, hábitos e modos de agir das pessoas.',
    color: Color(0xFF6F6AB8),
    icon: Icons.forum_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'natureza',
    label: 'Natureza',
    description: 'Animais, plantas, paisagens e fenômenos naturais.',
    color: Color(0xFF5E9D78),
    icon: Icons.local_florist_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'criacoes',
    label: 'Criações',
    description:
        'Invenções, tecnologias, veículos, áreas de conhecimento e sistemas.',
    color: Color(0xFF5B8A8E),
    icon: Icons.construction_rounded,
  ),
  _PreferenceCategoryDefinition(
    id: 'miscelanea',
    label: 'Miscelânea',
    description: 'Itens soltos que não se encaixam nas categorias acima.',
    color: Color(0xFF7E6676),
    icon: Icons.category_rounded,
  ),
];

// ignore: unused_element
class _LegacyPsychPreferenceMatrixCard extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final String Function(String levelId, String categoryId) valueFor;
  final void Function(String levelId, String categoryId, String value)
  onChanged;

  const _LegacyPsychPreferenceMatrixCard({
    required this.accentColor,
    required this.avatarColor,
    required this.valueFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
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
          _PsychSectionTitle(
            accentColor: accentColor,
            icon: Icons.favorite_border_rounded,
            title: 'Gostos e aversões',
            subtitle: 'organizado por predileção e categoria',
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _PreferenceHeatmapPainter(
                accentColor: accentColor,
                values: {
                  for (final level in _preferenceLevels)
                    for (final category in _preferenceCategories)
                      '${level.id}::${category.id}': valueFor(
                        level.id,
                        category.id,
                      ),
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final category in _preferenceCategories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 172,
                      child: _PreferenceCategoryColumn(
                        accentColor: accentColor,
                        category: category,
                        valueFor: valueFor,
                        onChanged: onChanged,
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
}

class _PreferenceCategoryColumn extends StatelessWidget {
  final Color accentColor;
  final _PreferenceCategoryDefinition category;
  final String Function(String levelId, String categoryId) valueFor;
  final void Function(String levelId, String categoryId, String value)
  onChanged;

  const _PreferenceCategoryColumn({
    required this.accentColor,
    required this.category,
    required this.valueFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: category.color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 14, color: category.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B262C),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final level in _preferenceLevels) ...[
            TextFormField(
              key: ValueKey('preference-${level.id}-${category.id}'),
              initialValue: valueFor(level.id, category.id),
              minLines: 1,
              maxLines: 2,
              onChanged: (value) => onChanged(level.id, category.id, value),
              style: const TextStyle(
                color: Color(0xFF514752),
                fontSize: 10.6,
                height: 1.2,
              ),
              decoration: InputDecoration(
                labelText: level.label,
                labelStyle: TextStyle(
                  color: level.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.74),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: level.color.withValues(alpha: 0.18),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: level.color.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _PreferenceHeatmapPainter extends CustomPainter {
  final Color accentColor;
  final Map<String, String> values;

  const _PreferenceHeatmapPainter({
    required this.accentColor,
    required this.values,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 58.0;
    const topPad = 20.0;
    final cellWidth = (size.width - leftPad - 4) / _preferenceCategories.length;
    final cellHeight = (size.height - topPad - 4) / _preferenceLevels.length;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var row = 0; row < _preferenceLevels.length; row += 1) {
      final level = _preferenceLevels[row];
      textPainter.text = TextSpan(
        text: level.label,
        style: const TextStyle(
          color: Color(0xFF4C414A),
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      );
      textPainter.layout(maxWidth: leftPad - 8);
      textPainter.paint(
        canvas,
        Offset(0, topPad + row * cellHeight + (cellHeight - 10) / 2),
      );

      for (var column = 0; column < _preferenceCategories.length; column += 1) {
        final category = _preferenceCategories[column];
        final hasValue =
            values['${level.id}::${category.id}']?.trim().isNotEmpty == true;
        final rect = Rect.fromLTWH(
          leftPad + column * cellWidth,
          topPad + row * cellHeight,
          max(2, cellWidth - 3),
          max(2, cellHeight - 3),
        );
        final paint = Paint()
          ..color = hasValue
              ? level.color.withValues(alpha: 0.72)
              : accentColor.withValues(alpha: 0.08);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      }
    }

    for (var column = 0; column < _preferenceCategories.length; column += 1) {
      final label = _preferenceCategories[column].label.split(' ').first;
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF6B6068),
          fontSize: 8.2,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout(maxWidth: cellWidth);
      textPainter.paint(canvas, Offset(leftPad + column * cellWidth, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _PreferenceHeatmapPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.accentColor != accentColor;
  }
}

class _PreferenceMatrixItem {
  final String id;
  final String label;
  final String opinion;
  final String levelId;
  final String categoryId;

  const _PreferenceMatrixItem({
    required this.id,
    required this.label,
    this.opinion = '',
    required this.levelId,
    required this.categoryId,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'opinion': opinion,
    'levelId': levelId,
    'categoryId': categoryId,
  };

  factory _PreferenceMatrixItem.fromJson(Map<String, Object?> json) {
    return _PreferenceMatrixItem(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      opinion: json['opinion'] as String? ?? '',
      levelId: json['levelId'] as String? ?? _preferenceLevels.first.id,
      categoryId:
          json['categoryId'] as String? ?? _preferenceCategories.first.id,
    );
  }

  _PreferenceMatrixItem copyWith({
    String? id,
    String? label,
    String? opinion,
    String? levelId,
    String? categoryId,
  }) {
    return _PreferenceMatrixItem(
      id: id ?? this.id,
      label: label ?? this.label,
      opinion: opinion ?? this.opinion,
      levelId: levelId ?? this.levelId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class _PsychPreferenceMatrixCard extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final List<_PreferenceMatrixItem> items;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final ValueChanged<String> onDeleteItem;

  const _PsychPreferenceMatrixCard({
    required this.accentColor,
    required this.avatarColor,
    required this.items,
    required this.onUpsertItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
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
          _PsychSectionTitle(
            accentColor: accentColor,
            icon: Icons.favorite_border_rounded,
            title: 'Gostos e aversões',
            subtitle:
                'Nomeie um conceito, organize-o por predileção e categoria e atribua à ele um comentário diegético.',
            subtitleMaxLines: 3,
          ),
          const SizedBox(height: 10),
          _PreferenceMatrixComposer(
            accentColor: accentColor,
            onAddItem: onUpsertItem,
          ),
          const SizedBox(height: 12),
          _PreferenceMatrixGrid(
            accentColor: accentColor,
            avatarColor: avatarColor,
            items: items,
            onUpsertItem: onUpsertItem,
            onDeleteItem: onDeleteItem,
          ),
        ],
      ),
    );
  }
}

class _PreferenceMatrixComposer extends StatefulWidget {
  final Color accentColor;
  final ValueChanged<_PreferenceMatrixItem> onAddItem;

  const _PreferenceMatrixComposer({
    required this.accentColor,
    required this.onAddItem,
  });

  @override
  State<_PreferenceMatrixComposer> createState() =>
      _PreferenceMatrixComposerState();
}

class _PreferenceMatrixComposerState extends State<_PreferenceMatrixComposer> {
  late final TextEditingController _controller;
  late final TextEditingController _commentController;
  String _selectedLevelId = _preferenceLevels[2].id;
  String _selectedCategoryId = _preferenceCategories.first.id;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addItem() {
    final label = _controller.text.trim();
    if (label.isEmpty) return;

    widget.onAddItem(
      _PreferenceMatrixItem(
        id: 'pref-${DateTime.now().microsecondsSinceEpoch}',
        label: label,
        opinion: _commentController.text.trim(),
        levelId: _selectedLevelId,
        categoryId: _selectedCategoryId,
      ),
    );
    _controller.clear();
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: widget.accentColor.withValues(alpha: 0.14)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.68),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 1,
                onSubmitted: (_) => _addItem(),
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Nome do item. Qualquer conceito serve. "Arroz" para gastronomia ou "Pessoas que andam devagar" para comportamento, por exemplo...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8F8990),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.68),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
                  ),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(
                      color: widget.accentColor,
                      width: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 11.2,
                  height: 1.25,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Um comentário diegético do personagem sobre isso. Como se ele tivesse sido perguntado sobre e respondesse isso, ignorando complexidade contextual.',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8F8990),
                    fontSize: 10.8,
                    fontStyle: FontStyle.italic,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.58),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: inputBorder.copyWith(
                    borderSide: BorderSide(
                      color: widget.accentColor,
                      width: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _PreferenceDropdown<String>(
                      value: _selectedLevelId,
                      items: [
                        for (final level in _preferenceLevels)
                          DropdownMenuItem<String>(
                            value: level.id,
                            child: Row(
                              children: [
                                _PreferenceLevelIcon(
                                  level: level,
                                  color: const Color(0xFF625862),
                                  size: 13,
                                ),
                                const SizedBox(width: 6),
                                Expanded(child: Text(level.label)),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedLevelId = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PreferenceCategoryDropdown(
                      value: _selectedCategoryId,
                      accentColor: widget.accentColor,
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: FilledButton(
                      onPressed: _addItem,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: widget.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Icon(Icons.add_rounded, size: 20),
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

class _PreferenceDropdown<T> extends StatelessWidget {
  final T value;
  final IconData? icon;
  final Widget? leading;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PreferenceDropdown({
    required this.value,
    this.icon,
    this.leading,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final leadingWidget =
        leading ??
        (icon == null
            ? null
            : Icon(icon, size: 14, color: const Color(0xFF625862)));

    return Container(
      height: 42,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
      ),
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            const SizedBox(width: 6),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                items: items,
                onChanged: onChanged,
                style: const TextStyle(
                  color: Color(0xFF2B262C),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceLevelIcon extends StatelessWidget {
  final _PreferenceLevelDefinition level;
  final Color color;
  final double size;

  const _PreferenceLevelIcon({
    required this.level,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (level.id != 'favoritos') {
      return Icon(level.icon, size: size, color: color);
    }

    return SizedBox(
      width: size * 2.15,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: size * 0.12,
            child: Icon(Icons.star_rounded, size: size * 0.72, color: color),
          ),
          Positioned(
            left: size * 0.65,
            top: 0,
            child: Icon(Icons.star_rounded, size: size, color: color),
          ),
          Positioned(
            right: 0,
            top: size * 0.12,
            child: Icon(Icons.star_rounded, size: size * 0.72, color: color),
          ),
        ],
      ),
    );
  }
}

class _PreferenceCategoryDropdown extends StatefulWidget {
  final String value;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _PreferenceCategoryDropdown({
    required this.value,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<_PreferenceCategoryDropdown> createState() =>
      _PreferenceCategoryDropdownState();
}

class _PreferenceCategoryDropdownState
    extends State<_PreferenceCategoryDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _detailsEntry;

  @override
  void dispose() {
    _detailsEntry?.remove();
    super.dispose();
  }

  void _hideDetails() {
    _detailsEntry?.remove();
    _detailsEntry = null;
    if (mounted) setState(() {});
  }

  void _toggleDetails() {
    if (_detailsEntry != null) {
      _hideDetails();
      return;
    }

    final category = _preferenceCategoryFor(widget.value);
    _detailsEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideDetails,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 6),
              child: UnconstrainedBox(
                alignment: Alignment.topRight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 248,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            category.color.withValues(alpha: 0.06),
                            Colors.white.withValues(alpha: 0.72),
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.16),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              category.icon,
                              size: 15,
                              color: category.color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.description,
                                style: const TextStyle(
                                  color: Color(0xFF514752),
                                  fontSize: 11,
                                  height: 1.28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_detailsEntry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final category = _preferenceCategoryFor(widget.value);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 42,
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: category.color.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.value,
                  isExpanded: true,
                  isDense: true,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
                  items: [
                    for (final item in _preferenceCategories)
                      DropdownMenuItem<String>(
                        value: item.id,
                        child: Row(
                          children: [
                            Icon(item.icon, size: 13, color: item.color),
                            const SizedBox(width: 6),
                            Expanded(child: Text(item.label)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (nextValue) {
                    if (nextValue == null) return;
                    _hideDetails();
                    widget.onChanged(nextValue);
                  },
                  style: const TextStyle(
                    color: Color(0xFF2B262C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Tooltip(
              message: 'Detalhes da categoria',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleDetails,
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    width: 30,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _detailsEntry == null
                          ? Colors.white.withValues(alpha: 0.42)
                          : category.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _detailsEntry == null
                            ? Colors.white.withValues(alpha: 0.58)
                            : category.color.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: category.color,
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

enum _PreferenceOrganizationMode { predilection, category }

class _PreferenceMatrixGrid extends StatefulWidget {
  final Color accentColor;
  final Color avatarColor;
  final List<_PreferenceMatrixItem> items;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final ValueChanged<String> onDeleteItem;

  const _PreferenceMatrixGrid({
    required this.accentColor,
    required this.avatarColor,
    required this.items,
    required this.onUpsertItem,
    required this.onDeleteItem,
  });

  @override
  State<_PreferenceMatrixGrid> createState() => _PreferenceMatrixGridState();
}

class _PreferenceMatrixGridState extends State<_PreferenceMatrixGrid> {
  _PreferenceOrganizationMode _organizationMode =
      _PreferenceOrganizationMode.predilection;
  final Set<String> _selectedCategoryFilterIds = <String>{};
  final Set<String> _selectedLevelFilterIds = <String>{};

  List<_PreferenceMatrixItem> get _filteredItems {
    return widget.items
        .where((item) {
          final categoryMatches =
              _selectedCategoryFilterIds.isEmpty ||
              _selectedCategoryFilterIds.contains(item.categoryId);
          final levelMatches =
              _selectedLevelFilterIds.isEmpty ||
              _selectedLevelFilterIds.contains(item.levelId);
          return categoryMatches && levelMatches;
        })
        .toList(growable: false);
  }

  void _toggleCategoryFilter(String categoryId) {
    setState(() {
      if (!_selectedCategoryFilterIds.add(categoryId)) {
        _selectedCategoryFilterIds.remove(categoryId);
      }
    });
  }

  void _toggleLevelFilter(String levelId) {
    setState(() {
      if (!_selectedLevelFilterIds.add(levelId)) {
        _selectedLevelFilterIds.remove(levelId);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryFilterIds.clear();
      _selectedLevelFilterIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreferenceOrganizationToolbar(
          accentColor: widget.accentColor,
          mode: _organizationMode,
          selectedCategoryIds: _selectedCategoryFilterIds,
          selectedLevelIds: _selectedLevelFilterIds,
          onModeChanged: (mode) => setState(() => _organizationMode = mode),
          onCategoryFilterToggled: _toggleCategoryFilter,
          onLevelFilterToggled: _toggleLevelFilter,
          onClearFilters:
              _selectedCategoryFilterIds.isEmpty &&
                  _selectedLevelFilterIds.isEmpty
              ? null
              : _clearFilters,
        ),
        const SizedBox(height: 8),
        _PreferenceVerticalOverview(
          accentColor: widget.accentColor,
          avatarColor: widget.avatarColor,
          items: filteredItems,
          organizationMode: _organizationMode,
          onUpsertItem: widget.onUpsertItem,
          onDeleteItem: widget.onDeleteItem,
        ),
      ],
    );
  }
}

class _PreferenceOrganizationToolbar extends StatefulWidget {
  final Color accentColor;
  final _PreferenceOrganizationMode mode;
  final Set<String> selectedCategoryIds;
  final Set<String> selectedLevelIds;
  final ValueChanged<_PreferenceOrganizationMode> onModeChanged;
  final ValueChanged<String> onCategoryFilterToggled;
  final ValueChanged<String> onLevelFilterToggled;
  final VoidCallback? onClearFilters;

  const _PreferenceOrganizationToolbar({
    required this.accentColor,
    required this.mode,
    required this.selectedCategoryIds,
    required this.selectedLevelIds,
    required this.onModeChanged,
    required this.onCategoryFilterToggled,
    required this.onLevelFilterToggled,
    required this.onClearFilters,
  });

  @override
  State<_PreferenceOrganizationToolbar> createState() =>
      _PreferenceOrganizationToolbarState();
}

class _PreferenceOrganizationToolbarState
    extends State<_PreferenceOrganizationToolbar> {
  bool _filtersExpanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedFilterCount =
        widget.selectedCategoryIds.length + widget.selectedLevelIds.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.66)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PreferenceModeButton(
                      label: 'Predileção',
                      icon: Icons.swap_vert_rounded,
                      selected:
                          widget.mode ==
                          _PreferenceOrganizationMode.predilection,
                      accentColor: widget.accentColor,
                      onTap: () => widget.onModeChanged(
                        _PreferenceOrganizationMode.predilection,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _PreferenceModeButton(
                      label: 'Categoria',
                      icon: Icons.category_rounded,
                      selected:
                          widget.mode == _PreferenceOrganizationMode.category,
                      accentColor: widget.accentColor,
                      onTap: () => widget.onModeChanged(
                        _PreferenceOrganizationMode.category,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: selectedFilterCount == 0
                          ? Colors.white.withValues(alpha: 0.4)
                          : widget.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedFilterCount == 0
                            ? Colors.white.withValues(alpha: 0.58)
                            : widget.accentColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_outlined,
                          size: 15,
                          color: Color(0xFF625862),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedFilterCount == 0
                                ? 'Filtros'
                                : 'Filtros ($selectedFilterCount)',
                            style: const TextStyle(
                              color: Color(0xFF514752),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (widget.onClearFilters != null)
                          IconButton(
                            onPressed: widget.onClearFilters,
                            tooltip: 'Limpar filtros',
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            color: const Color(0xFF625862),
                          ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 150),
                          turns: _filtersExpanded ? 0.5 : 0,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF625862),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Column(
                    children: [
                      _PreferenceFilterSection(
                        title: 'Predileção',
                        icon: Icons.star_rounded,
                        accentColor: widget.accentColor,
                        children: [
                          for (final level in _preferenceLevels)
                            _PreferenceFilterChip(
                              label: level.label,
                              icon: level.icon,
                              leading: _PreferenceLevelIcon(
                                level: level,
                                color: level.color,
                                size: 11,
                              ),
                              color: level.color,
                              selected: widget.selectedLevelIds.contains(
                                level.id,
                              ),
                              tooltip: 'Exibir ${level.label}',
                              onTap: () =>
                                  widget.onLevelFilterToggled(level.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _PreferenceFilterSection(
                        title: 'Categoria',
                        icon: Icons.category_rounded,
                        accentColor: widget.accentColor,
                        children: [
                          for (final category in _preferenceCategories)
                            _PreferenceFilterChip(
                              label: category.label,
                              icon: category.icon,
                              color: category.color,
                              selected: widget.selectedCategoryIds.contains(
                                category.id,
                              ),
                              tooltip: category.description,
                              onTap: () =>
                                  widget.onCategoryFilterToggled(category.id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _filtersExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 160),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferenceFilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  const _PreferenceFilterSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: accentColor),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _PreferenceModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _PreferenceModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.26)
                  : Colors.white.withValues(alpha: 0.58),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? accentColor : const Color(0xFF625862),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? accentColor : const Color(0xFF514752),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
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

class _PreferenceFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget? leading;
  final Color color;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  const _PreferenceFilterChip({
    required this.label,
    required this.icon,
    this.leading,
    required this.color,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            constraints: const BoxConstraints(minWidth: 74),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.54),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? color.withValues(alpha: 0.32)
                    : Colors.white.withValues(alpha: 0.68),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading ?? Icon(icon, size: 11, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? _darkenCharacterDialogColor(color, 0.18)
                        : const Color(0xFF514752),
                    fontSize: 9.7,
                    fontWeight: FontWeight.w800,
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

class _PreferenceVerticalOverview extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final List<_PreferenceMatrixItem> items;
  final _PreferenceOrganizationMode organizationMode;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final ValueChanged<String> onDeleteItem;

  const _PreferenceVerticalOverview({
    required this.accentColor,
    required this.avatarColor,
    required this.items,
    required this.organizationMode,
    required this.onUpsertItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          avatarColor.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.58),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (organizationMode == _PreferenceOrganizationMode.predilection)
            for (final level in _preferenceLevels) ...[
              _PreferenceTierRow(
                level: level,
                items: items
                    .where((item) => item.levelId == level.id)
                    .toList(growable: false),
                onUpsertItem: onUpsertItem,
                onDeleteItem: onDeleteItem,
              ),
              const SizedBox(height: 6),
            ]
          else
            for (final category in _preferenceCategories) ...[
              _PreferenceCategoryTierRow(
                category: category,
                items: items
                    .where((item) => item.categoryId == category.id)
                    .toList(growable: false),
                onUpsertItem: onUpsertItem,
                onDeleteItem: onDeleteItem,
              ),
              const SizedBox(height: 6),
            ],
        ],
      ),
    );
  }
}

class _PreferenceTierRow extends StatelessWidget {
  final _PreferenceLevelDefinition level;
  final List<_PreferenceMatrixItem> items;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final ValueChanged<String> onDeleteItem;

  const _PreferenceTierRow({
    required this.level,
    required this.items,
    required this.onUpsertItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final sortedItems = items.toList(growable: false)
      ..sort((left, right) {
        final categoryCompare = _preferenceCategoryIndex(
          left.categoryId,
        ).compareTo(_preferenceCategoryIndex(right.categoryId));
        if (categoryCompare != 0) return categoryCompare;
        return left.label.toLowerCase().compareTo(right.label.toLowerCase());
      });

    return DragTarget<_PreferenceMatrixItem>(
      onWillAcceptWithDetails: (details) => details.data.levelId != level.id,
      onAcceptWithDetails: (details) {
        onUpsertItem(details.data.copyWith(levelId: level.id), rebuild: true);
      },
      builder: (context, candidateItems, rejectedItems) {
        final isHovering = candidateItems.isNotEmpty;
        final fillAlpha = isHovering
            ? 0.32
            : (0.14 + sortedItems.length * 0.025).clamp(0.14, 0.28);

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              constraints: const BoxConstraints(minHeight: 54),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isHovering ? 0.54 : 0.42),
                    Color.alphaBlend(
                      level.color.withValues(alpha: isHovering ? 0.1 : 0.05),
                      Colors.white.withValues(alpha: 0.28),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHovering
                      ? level.color.withValues(alpha: 0.34)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 0.85,
                ),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(
                      alpha: isHovering ? 0.13 : 0.06,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      width: 72,
                      constraints: const BoxConstraints(minHeight: 54),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: level.color.withValues(alpha: fillAlpha),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _preferenceLevelShortLabel(level.id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _darkenCharacterDialogColor(
                                level.color,
                                0.25,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _PreferenceLevelIcon(
                            level: level,
                            color: level.color,
                            size: 13,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sortedItems.length}',
                            style: TextStyle(
                              color: _darkenCharacterDialogColor(
                                level.color,
                                0.18,
                              ),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: sortedItems.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sem itens',
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.38),
                                    fontSize: 10.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  for (final item in sortedItems)
                                    _PreferenceTierItemChip(
                                      item: item,
                                      color: level.color,
                                      onUpsertItem: onUpsertItem,
                                      onDelete: () => onDeleteItem(item.id),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreferenceCategoryTierRow extends StatelessWidget {
  final _PreferenceCategoryDefinition category;
  final List<_PreferenceMatrixItem> items;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final ValueChanged<String> onDeleteItem;

  const _PreferenceCategoryTierRow({
    required this.category,
    required this.items,
    required this.onUpsertItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final sortedItems = items.toList(growable: false)
      ..sort((left, right) {
        final levelCompare = _preferenceLevelIndex(
          left.levelId,
        ).compareTo(_preferenceLevelIndex(right.levelId));
        if (levelCompare != 0) return levelCompare;
        return left.label.toLowerCase().compareTo(right.label.toLowerCase());
      });

    return DragTarget<_PreferenceMatrixItem>(
      onWillAcceptWithDetails: (details) =>
          details.data.categoryId != category.id,
      onAcceptWithDetails: (details) {
        onUpsertItem(
          details.data.copyWith(categoryId: category.id),
          rebuild: true,
        );
      },
      builder: (context, candidateItems, rejectedItems) {
        final isHovering = candidateItems.isNotEmpty;
        final fillAlpha = isHovering
            ? 0.32
            : (0.12 + sortedItems.length * 0.025).clamp(0.12, 0.26);

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              constraints: const BoxConstraints(minHeight: 54),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isHovering ? 0.54 : 0.42),
                    Color.alphaBlend(
                      category.color.withValues(alpha: isHovering ? 0.1 : 0.05),
                      Colors.white.withValues(alpha: 0.28),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHovering
                      ? category.color.withValues(alpha: 0.34)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 0.85,
                ),
                boxShadow: [
                  BoxShadow(
                    color: category.color.withValues(
                      alpha: isHovering ? 0.13 : 0.06,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Tooltip(
                      message: category.description,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 130),
                        width: 96,
                        constraints: const BoxConstraints(minHeight: 54),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: fillAlpha),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(14),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 15,
                              color: category.color,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              category.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _darkenCharacterDialogColor(
                                  category.color,
                                  0.25,
                                ),
                                fontSize: 10,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sortedItems.length}',
                              style: TextStyle(
                                color: _darkenCharacterDialogColor(
                                  category.color,
                                  0.16,
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: sortedItems.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sem itens',
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.38),
                                    fontSize: 10.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  for (final item in sortedItems)
                                    _PreferenceTierItemChip(
                                      item: item,
                                      color: _preferenceLevelFor(
                                        item.levelId,
                                      ).color,
                                      leadingLevel: _preferenceLevelFor(
                                        item.levelId,
                                      ),
                                      onUpsertItem: onUpsertItem,
                                      onDelete: () => onDeleteItem(item.id),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreferenceTierItemChip extends StatelessWidget {
  final _PreferenceMatrixItem item;
  final Color color;
  final _PreferenceLevelDefinition? leadingLevel;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onUpsertItem;
  final VoidCallback onDelete;

  const _PreferenceTierItemChip({
    required this.item,
    required this.color,
    this.leadingLevel,
    required this.onUpsertItem,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLevel = leadingLevel;

    return Draggable<_PreferenceMatrixItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _PreferenceTierItemChipSurface(
          item: item,
          color: color,
          leadingLevel: resolvedLevel,
          elevated: true,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.34,
        child: _PreferenceTierItemChipSurface(
          item: item,
          color: color,
          leadingLevel: resolvedLevel,
        ),
      ),
      child: Builder(
        builder: (chipContext) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPreferenceItemTooltipBubble(
                context: chipContext,
                item: item,
                color: color,
                onUpsertItem: onUpsertItem,
                onDelete: onDelete,
              ),
              borderRadius: BorderRadius.circular(10),
              child: _PreferenceTierItemChipSurface(
                item: item,
                color: color,
                leadingLevel: resolvedLevel,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreferenceTierItemChipSurface extends StatelessWidget {
  final _PreferenceMatrixItem item;
  final Color color;
  final _PreferenceLevelDefinition? leadingLevel;
  final bool elevated;

  const _PreferenceTierItemChipSurface({
    required this.item,
    required this.color,
    required this.leadingLevel,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = _preferenceCategoryFor(item.categoryId);
    final opinion = item.opinion.trim();

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.fromLTRB(7, 5, 8, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: elevated ? 0.92 : 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: elevated ? 0.18 : 0.08),
            blurRadius: elevated ? 16 : 10,
            offset: Offset(0, elevated ? 6 : 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingLevel == null)
            Icon(category.icon, size: 12, color: category.color)
          else
            _PreferenceLevelIcon(level: leadingLevel!, color: color, size: 12),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3F3740),
                fontSize: 10.3,
                height: 1.08,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (opinion.isNotEmpty) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 10,
              color: color.withValues(alpha: 0.72),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _showPreferenceItemTooltipBubble({
  required BuildContext context,
  required _PreferenceMatrixItem item,
  required Color color,
  required void Function(_PreferenceMatrixItem item, {bool rebuild})
  onUpsertItem,
  required VoidCallback onDelete,
}) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    return Future<void>.value();
  }

  final anchorRect =
      renderObject.localToGlobal(Offset.zero) & renderObject.size;
  final category = _preferenceCategoryFor(item.categoryId);
  final level = _preferenceLevelFor(item.levelId);
  final comment = item.opinion.trim();
  final commentText = comment.isEmpty ? 'Sem comentario.' : '"$comment"';
  final estimatedHeight = comment.isEmpty
      ? 126.0
      : comment.length > 90
      ? 190.0
      : 146.0;

  return showAnchoredInfoBubbleDialog(
    context: context,
    anchorRect: anchorRect,
    width: 280,
    estimatedHeight: estimatedHeight,
    child: Builder(
      builder: (bubbleContext) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        size: 15,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF2B262C),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${level.label} - ${category.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _darkenCharacterDialogColor(color, 0.16),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(bubbleContext).pop();
                        _showPreferenceItemEditorDialog(
                          context: context,
                          item: item,
                          accentColor: color,
                          onUpsertItem: onUpsertItem,
                        );
                      },
                      tooltip: 'Editar item',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      color: color,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(bubbleContext).pop();
                        onDelete();
                      },
                      tooltip: 'Excluir item',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      color: const Color(0xFF8A5364),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: color.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    commentText,
                    style: const TextStyle(
                      color: Color(0xFF514752),
                      fontSize: 11.5,
                      height: 1.32,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.48),
                    fontSize: 10.3,
                    height: 1.24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
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
            borderRadius: BorderRadius.circular(17),
            blurSigma: 14,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.76),
                  Color.alphaBlend(
                    color.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.52),
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 0.85,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.34),
                  blurRadius: 10,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.36),
                width: 0.7,
              ),
            ),
            arrowColor: Colors.white.withValues(alpha: 0.68),
            child: child,
          );
        },
  );
}

Future<void> _showPreferenceItemEditorDialog({
  required BuildContext context,
  required _PreferenceMatrixItem item,
  required Color accentColor,
  required void Function(_PreferenceMatrixItem item, {bool rebuild})
  onUpsertItem,
}) {
  final titleController = TextEditingController(text: item.label);
  final commentController = TextEditingController(text: item.opinion);
  var levelId = item.levelId;
  var categoryId = item.categoryId;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Editar item',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final inputBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentColor.withValues(alpha: 0.14)),
      );

      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                void save() {
                  final label = titleController.text.trim();
                  if (label.isEmpty) return;
                  onUpsertItem(
                    item.copyWith(
                      label: label,
                      opinion: commentController.text.trim(),
                      levelId: levelId,
                      categoryId: categoryId,
                    ),
                    rebuild: true,
                  );
                  Navigator.of(dialogContext).pop();
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.78),
                              Color.alphaBlend(
                                accentColor.withValues(alpha: 0.07),
                                Colors.white.withValues(alpha: 0.54),
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.76),
                            width: 0.85,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 17,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 7),
                                const Expanded(
                                  child: Text(
                                    'Editar gosto',
                                    style: TextStyle(
                                      color: Color(0xFF2B262C),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  tooltip: 'Fechar',
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  color: const Color(0xFF625862),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: titleController,
                              minLines: 1,
                              maxLines: 1,
                              onSubmitted: (_) => save(),
                              style: const TextStyle(
                                color: Color(0xFF514752),
                                fontSize: 12.2,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nome do item',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.62),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: inputBorder,
                                enabledBorder: inputBorder,
                                focusedBorder: inputBorder.copyWith(
                                  borderSide: BorderSide(
                                    color: accentColor,
                                    width: 1.1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _PreferenceDropdown<String>(
                                    value: levelId,
                                    items: [
                                      for (final level in _preferenceLevels)
                                        DropdownMenuItem<String>(
                                          value: level.id,
                                          child: Row(
                                            children: [
                                              _PreferenceLevelIcon(
                                                level: level,
                                                color: const Color(0xFF625862),
                                                size: 13,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(level.label),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setDialogState(() => levelId = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PreferenceDropdown<String>(
                                    value: categoryId,
                                    items: [
                                      for (final category
                                          in _preferenceCategories)
                                        DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Row(
                                            children: [
                                              Icon(
                                                category.icon,
                                                size: 13,
                                                color: category.color,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(category.label),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setDialogState(() => categoryId = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: commentController,
                              minLines: 2,
                              maxLines: 5,
                              style: const TextStyle(
                                color: Color(0xFF514752),
                                fontSize: 11.4,
                                height: 1.3,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Comentario do personagem',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.58),
                                contentPadding: const EdgeInsets.all(10),
                                border: inputBorder,
                                enabledBorder: inputBorder,
                                focusedBorder: inputBorder.copyWith(
                                  borderSide: BorderSide(
                                    color: accentColor,
                                    width: 1.1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: save,
                                style: FilledButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.check_rounded, size: 17),
                                label: const Text('Salvar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  ).whenComplete(() {
    titleController.dispose();
    commentController.dispose();
  });
}

// ignore: unused_element
Future<void> _showPreferenceItemBubble({
  required BuildContext context,
  required _PreferenceMatrixItem item,
  required Color color,
  required VoidCallback onDelete,
}) {
  final category = _preferenceCategoryFor(item.categoryId);
  final level = _preferenceLevels.firstWhere(
    (level) => level.id == item.levelId,
    orElse: () => _preferenceLevels[2],
  );
  final comment = item.opinion.trim();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.78),
                      width: 0.85,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                              child: Icon(
                                category.icon,
                                size: 17,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF2B262C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${level.label} · ${category.label}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _darkenCharacterDialogColor(
                                        color,
                                        0.16,
                                      ),
                                      fontSize: 10.8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Fechar',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: const Color(0xFF625862),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            comment.isEmpty ? 'Sem comentário.' : comment,
                            style: TextStyle(
                              color: const Color(0xFF514752),
                              fontSize: 12,
                              height: 1.35,
                              fontStyle: comment.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.48),
                                  fontSize: 10.5,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onDelete();
                              },
                              tooltip: 'Excluir item',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              color: const Color(0xFF8A5364),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

// ignore: unused_element
class _PreferenceOverviewRow extends StatelessWidget {
  final _PreferenceCategoryDefinition category;
  final List<_PreferenceMatrixItem> items;

  const _PreferenceOverviewRow({required this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Row(
              children: [
                Icon(category.icon, size: 13, color: const Color(0xFF625862)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF3F3740),
                      fontSize: 10.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final level in _preferenceLevels)
            Expanded(
              child: _PreferenceOverviewCountCell(
                level: level,
                category: category,
                count: items.where((item) => item.levelId == level.id).length,
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceOverviewCountCell extends StatelessWidget {
  final _PreferenceLevelDefinition level;
  final _PreferenceCategoryDefinition category;
  final int count;

  const _PreferenceOverviewCountCell({
    required this.level,
    required this.category,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = count > 0;

    return Tooltip(
      message: '${category.label} / ${level.label}: $count',
      child: Container(
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: hasItems ? 0.46 : 0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: level.color.withValues(alpha: hasItems ? 0.28 : 0.1),
          ),
        ),
        child: Text(
          count == 0 ? '' : '$count',
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _darkenCharacterDialogColor(level.color, 0.25),
            fontSize: 10.2,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceEmptyState extends StatelessWidget {
  final Color accentColor;

  const _PreferenceEmptyState({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.1)),
      ),
      child: Text(
        'Nenhum item criado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.5),
          fontSize: 11.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceItemEditorCard extends StatefulWidget {
  final Color accentColor;
  final _PreferenceMatrixItem item;
  final void Function(_PreferenceMatrixItem item, {bool rebuild}) onChanged;
  final VoidCallback onDelete;

  const _PreferenceItemEditorCard({
    required this.accentColor,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_PreferenceItemEditorCard> createState() =>
      _PreferenceItemEditorCardState();
}

class _PreferenceItemEditorCardState extends State<_PreferenceItemEditorCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _opinionController;
  late String _levelId;
  late String _categoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.label);
    _opinionController = TextEditingController(text: widget.item.opinion);
    _levelId = widget.item.levelId;
    _categoryId = widget.item.categoryId;
  }

  @override
  void didUpdateWidget(covariant _PreferenceItemEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _syncText(_titleController, widget.item.label);
      _syncText(_opinionController, widget.item.opinion);
      _levelId = widget.item.levelId;
      _categoryId = widget.item.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _opinionController.dispose();
    super.dispose();
  }

  void _syncText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }

  void _emit({bool rebuild = false}) {
    widget.onChanged(
      widget.item.copyWith(
        label: _titleController.text,
        opinion: _opinionController.text,
        levelId: _levelId,
        categoryId: _categoryId,
      ),
      rebuild: rebuild,
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = _preferenceLevels.firstWhere(
      (entry) => entry.id == _levelId,
      orElse: () => _preferenceLevels[2],
    );
    final category = _preferenceCategories.firstWhere(
      (entry) => entry.id == _categoryId,
      orElse: () => _preferenceCategories.first,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: level.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, size: 15, color: level.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  onChanged: (_) => _emit(),
                  style: const TextStyle(
                    color: Color(0xFF2B262C),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Item',
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                tooltip: 'Excluir item',
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: const Color(0xFF7E6676),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PreferenceDropdown<String>(
                  value: _levelId,
                  items: [
                    for (final item in _preferenceLevels)
                      DropdownMenuItem<String>(
                        value: item.id,
                        child: Row(
                          children: [
                            _PreferenceLevelIcon(
                              level: item,
                              color: const Color(0xFF625862),
                              size: 13,
                            ),
                            const SizedBox(width: 6),
                            Expanded(child: Text(item.label)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _levelId = value);
                    _emit(rebuild: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PreferenceDropdown<String>(
                  value: _categoryId,
                  icon: category.icon,
                  items: [
                    for (final item in _preferenceCategories)
                      DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _categoryId = value);
                    _emit(rebuild: true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _opinionController,
            minLines: 2,
            maxLines: 5,
            onChanged: (_) => _emit(),
            style: const TextStyle(
              color: Color(0xFF514752),
              fontSize: 11.4,
              height: 1.3,
            ),
            decoration: InputDecoration(
              hintText: 'Articule a opinião do personagem sobre este item.',
              hintStyle: const TextStyle(
                color: Color(0xFF8F8990),
                fontSize: 10.8,
                fontStyle: FontStyle.italic,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.72),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.accentColor.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.accentColor.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.accentColor, width: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceCategoryHeader extends StatelessWidget {
  final _PreferenceCategoryDefinition category;
  final double width;
  final Color accentColor;

  const _PreferenceCategoryHeader({
    required this.category,
    required this.width,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: accentColor.withValues(alpha: 0.08)),
          bottom: BorderSide(color: accentColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, size: 13, color: accentColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              category.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2B262C),
                fontSize: 10.2,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceLevelHeader extends StatelessWidget {
  final _PreferenceLevelDefinition level;
  final double width;

  const _PreferenceLevelHeader({required this.level, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 54),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: level.color.withValues(alpha: 0.08)),
          bottom: BorderSide(color: level.color.withValues(alpha: 0.1)),
        ),
      ),
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          level.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _darkenCharacterDialogColor(level.color, 0.2),
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _PreferenceMatrixCell extends StatelessWidget {
  final double width;
  final _PreferenceLevelDefinition level;
  final List<_PreferenceMatrixItem> items;
  final ValueChanged<String> onDeleteItem;

  const _PreferenceMatrixCell({
    required this.width,
    required this.level,
    required this.items,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: hasItems
            ? level.color.withValues(alpha: 0.09)
            : Colors.white.withValues(alpha: 0.32),
        border: Border(
          left: BorderSide(color: level.color.withValues(alpha: 0.06)),
          top: BorderSide(color: level.color.withValues(alpha: 0.05)),
          bottom: BorderSide(color: level.color.withValues(alpha: 0.08)),
        ),
      ),
      child: hasItems
          ? SingleChildScrollView(
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final item in items)
                    _PreferenceItemChip(
                      item: item,
                      color: level.color,
                      onDelete: () => onDeleteItem(item.id),
                    ),
                ],
              ),
            )
          : Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: level.color.withValues(alpha: 0.13),
                  ),
                ),
              ),
            ),
    );
  }
}

// ignore: unused_element
class _PreferenceItemChip extends StatelessWidget {
  final _PreferenceMatrixItem item;
  final Color color;
  final VoidCallback onDelete;

  const _PreferenceItemChip({
    required this.item,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.fromLTRB(8, 5, 4, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3F3740),
                fontSize: 10.3,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.close_rounded,
              size: 13,
              color: color.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

String _preferenceLevelShortLabel(String levelId) {
  switch (levelId) {
    case 'favoritos':
      return 'Fav.';
    case 'ama':
      return 'Ama';
    case 'gosta':
      return 'Gosta';
    case 'tolera':
      return 'Tol.';
    case 'odeia':
      return 'Odeia';
    default:
      return levelId;
  }
}

int _preferenceLevelIndex(String levelId) {
  final index = _preferenceLevels.indexWhere((level) => level.id == levelId);
  return index == -1 ? _preferenceLevels.length : index;
}

_PreferenceLevelDefinition _preferenceLevelFor(String levelId) {
  return _preferenceLevels.firstWhere(
    (level) => level.id == levelId,
    orElse: () => _preferenceLevels[2],
  );
}

int _preferenceCategoryIndex(String categoryId) {
  final index = _preferenceCategories.indexWhere(
    (category) => category.id == categoryId,
  );
  return index == -1 ? _preferenceCategories.length : index;
}

_PreferenceCategoryDefinition _preferenceCategoryFor(String categoryId) {
  return _preferenceCategories.firstWhere(
    (category) => category.id == categoryId,
    orElse: () => _preferenceCategories.last,
  );
}

class _RelationshipTypeDefinition {
  final String id;
  final String label;
  final Color color;

  const _RelationshipTypeDefinition({
    required this.id,
    required this.label,
    required this.color,
  });
}

const List<_RelationshipTypeDefinition> _relationshipTypes =
    <_RelationshipTypeDefinition>[
      _RelationshipTypeDefinition(
        id: 'aliada',
        label: 'Aliada',
        color: Color(0xFF5E9D78),
      ),
      _RelationshipTypeDefinition(
        id: 'afeto',
        label: 'Afeto',
        color: Color(0xFFE07388),
      ),
      _RelationshipTypeDefinition(
        id: 'conflito',
        label: 'Conflito',
        color: Color(0xFFC65B6A),
      ),
      _RelationshipTypeDefinition(
        id: 'familia',
        label: 'Família',
        color: Color(0xFFB47B38),
      ),
      _RelationshipTypeDefinition(
        id: 'neutra',
        label: 'Neutra',
        color: Color(0xFF7E6676),
      ),
    ];

class _CharacterRelationshipDiagramCard extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final String characterName;
  final List<CharacterListItem> characters;
  final String Function(CharacterListItem character) typeFor;
  final double Function(CharacterListItem character) intensityFor;
  final String Function(CharacterListItem character) notesFor;
  final void Function(CharacterListItem character, String typeId) onTypeChanged;
  final void Function(CharacterListItem character, double intensity)
  onIntensityChanged;
  final void Function(CharacterListItem character, String notes) onNotesChanged;

  const _CharacterRelationshipDiagramCard({
    required this.accentColor,
    required this.avatarColor,
    required this.characterName,
    required this.characters,
    required this.typeFor,
    required this.intensityFor,
    required this.notesFor,
    required this.onTypeChanged,
    required this.onIntensityChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.62),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
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
          _PsychSectionTitle(
            accentColor: accentColor,
            icon: Icons.hub_rounded,
            title: 'Relações',
            subtitle: 'diagrama entre personagens existentes',
          ),
          const SizedBox(height: 10),
          if (characters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Crie mais personagens neste projeto para montar o diagrama.',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.52),
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 230,
              child: CustomPaint(
                painter: _RelationshipDiagramPainter(
                  accentColor: accentColor,
                  avatarColor: avatarColor,
                  characterName: characterName,
                  characters: characters,
                  typeFor: typeFor,
                  intensityFor: intensityFor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (final character in characters) ...[
              _RelationshipEditorRow(
                accentColor: accentColor,
                character: character,
                selectedTypeId: typeFor(character),
                intensity: intensityFor(character),
                notes: notesFor(character),
                onTypeChanged: (typeId) => onTypeChanged(character, typeId),
                onIntensityChanged: (value) =>
                    onIntensityChanged(character, value),
                onNotesChanged: (value) => onNotesChanged(character, value),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _RelationshipEditorRow extends StatelessWidget {
  final Color accentColor;
  final CharacterListItem character;
  final String selectedTypeId;
  final double intensity;
  final String notes;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<String> onNotesChanged;

  const _RelationshipEditorRow({
    required this.accentColor,
    required this.character,
    required this.selectedTypeId,
    required this.intensity,
    required this.notes,
    required this.onTypeChanged,
    required this.onIntensityChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedType = _relationshipTypes.firstWhere(
      (type) => type.id == selectedTypeId,
      orElse: () => _relationshipTypes.last,
    );

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selectedType.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: character.data.avatarColor.withValues(
                  alpha: 0.18,
                ),
                child: Icon(
                  character.data.icon,
                  size: 14,
                  color: character.data.avatarColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  character.data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B262C),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType.id,
                  isDense: true,
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    for (final type in _relationshipTypes)
                      DropdownMenuItem<String>(
                        value: type.id,
                        child: Text(type.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onTypeChanged(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Intensidade',
                style: TextStyle(
                  color: Color(0xFF625862),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Slider(
                  value: intensity.clamp(0.0, 10.0).toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: selectedType.color,
                  onChanged: onIntensityChanged,
                ),
              ),
              SizedBox(
                width: 24,
                child: Text(
                  intensity.toStringAsFixed(0),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF2B262C),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            key: ValueKey('relationship-notes-${character.id}'),
            initialValue: notes,
            minLines: 1,
            maxLines: 3,
            onChanged: onNotesChanged,
            style: const TextStyle(
              color: Color(0xFF514752),
              fontSize: 11,
              height: 1.25,
            ),
            decoration: InputDecoration(
              hintText: 'Notas da relação',
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.7),
              contentPadding: const EdgeInsets.all(9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: accentColor.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipDiagramPainter extends CustomPainter {
  final Color accentColor;
  final Color avatarColor;
  final String characterName;
  final List<CharacterListItem> characters;
  final String Function(CharacterListItem character) typeFor;
  final double Function(CharacterListItem character) intensityFor;

  const _RelationshipDiagramPainter({
    required this.accentColor,
    required this.avatarColor,
    required this.characterName,
    required this.characters,
    required this.typeFor,
    required this.intensityFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.34;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (var index = 0; index < characters.length; index += 1) {
      final character = characters[index];
      final angle = -pi / 2 + (2 * pi * index / characters.length);
      final point = center + Offset(cos(angle), sin(angle)) * radius;
      final type = _relationshipTypes.firstWhere(
        (item) => item.id == typeFor(character),
        orElse: () => _relationshipTypes.last,
      );
      final intensity = intensityFor(character).clamp(0.0, 10.0);
      canvas.drawLine(
        center,
        point,
        Paint()
          ..color = type.color.withValues(alpha: 0.18 + intensity * 0.055)
          ..strokeWidth = 1.2 + intensity * 0.24
          ..strokeCap = StrokeCap.round,
      );
      _drawNode(
        canvas: canvas,
        center: point,
        radius: 25,
        color: type.color,
        label: character.data.name,
        textPainter: textPainter,
      );
    }

    _drawNode(
      canvas: canvas,
      center: center,
      radius: 34,
      color: Color.alphaBlend(accentColor.withValues(alpha: 0.45), avatarColor),
      label: characterName,
      textPainter: textPainter,
      emphasized: true,
    );
  }

  void _drawNode({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
    required String label,
    required TextPainter textPainter,
    bool emphasized = false,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: 0.82),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = emphasized ? 2.2 : 1.4
        ..color = color.withValues(alpha: 0.72),
    );
    textPainter.text = TextSpan(
      text: label.split(' ').first,
      style: TextStyle(
        color: const Color(0xFF2B262C),
        fontSize: emphasized ? 11 : 9.5,
        fontWeight: FontWeight.w800,
      ),
    );
    textPainter.layout(maxWidth: radius * 1.65);
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _RelationshipDiagramPainter oldDelegate) {
    return true;
  }
}

class _PsychSectionTitle extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final int subtitleMaxLines;

  const _PsychSectionTitle({
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: accentColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2B262C),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.52),
                  fontSize: 10.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
