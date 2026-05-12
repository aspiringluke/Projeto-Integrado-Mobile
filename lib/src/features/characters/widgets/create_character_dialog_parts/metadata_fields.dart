part of '../create_character_dialog.dart';

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
      hintText: 'Nome do personagem.',
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
      hintText: 'Apelido, nome de guerra ou nome público.',
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
              ? 'Peso, altura, frase, títulos e ocupações.'
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
                      hintText: 'Lema curto ou frase marcante.',
                      accentColor: accentColor,
                      icon: Icons.format_quote_rounded,
                      maxLines: 2,
                      fieldHeight: 82,
                    ),
                    const SizedBox(height: 10),
                    _CharacterCompactField(
                      label: 'Formações e ocupações',
                      controller: formationsController,
                      hintText: 'Estudo, ofício, cargo ou função social.',
                      focusedColor: accentColor,
                      icon: Icons.work_outline_rounded,
                      maxLines: 3,
                      fieldHeight: 90,
                    ),
                    const SizedBox(height: 10),
                    _CharacterCompactField(
                      label: 'Títulos',
                      controller: titlesController,
                      hintText: 'Honrarias, patentes ou nomes cerimoniais.',
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
        label: 'Função',
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
