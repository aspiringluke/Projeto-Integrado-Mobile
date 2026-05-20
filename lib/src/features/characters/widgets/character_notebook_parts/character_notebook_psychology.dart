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
