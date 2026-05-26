import 'package:flutter/material.dart';

import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../projects/models/project_tag_data.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_fields.dart';

class ExpandedCharacterBody extends StatelessWidget {
  final Color accentColor;
  final CharacterCardData data;
  final CharacterDateEntry dateEntry;
  final bool isEditing;
  final String birthdayLabel;
  final String heightLabel;
  final String weightLabel;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final ZodiacSignData signData;
  final TextEditingController synopsisController;
  final ScrollController synopsisScrollController;
  final TextEditingController quoteController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onCycleDateType;
  final ValueChanged<Rect> onTapSign;
  final VoidCallback onTapBirthday;
  final VoidCallback onTapHeightUnit;
  final VoidCallback onTapWeightUnit;
  final VoidCallback onCommitHeight;
  final VoidCallback onCommitWeight;
  final VoidCallback onToggleEditing;

  const ExpandedCharacterBody({
    super.key,
    required this.accentColor,
    required this.data,
    required this.dateEntry,
    required this.isEditing,
    required this.birthdayLabel,
    required this.heightLabel,
    required this.weightLabel,
    required this.heightUnit,
    required this.weightUnit,
    required this.signData,
    required this.synopsisController,
    required this.synopsisScrollController,
    required this.quoteController,
    required this.heightController,
    required this.weightController,
    required this.onCycleDateType,
    required this.onTapSign,
    required this.onTapBirthday,
    required this.onTapHeightUnit,
    required this.onTapWeightUnit,
    required this.onCommitHeight,
    required this.onCommitWeight,
    required this.onToggleEditing,
  });

  List<Widget> _buildTagRow() {
    final tags = <Widget>[];
    if (data.genderTag.isNotEmpty) {
      tags.add(
        OutlinedTagPill(label: data.genderTag, color: projectTagColorAt(0)),
      );
    }
    if (data.sexualityTag.isNotEmpty) {
      tags.add(
        OutlinedTagPill(label: data.sexualityTag, color: projectTagColorAt(1)),
      );
    }
    if (data.ethnicityTag.isNotEmpty) {
      tags.add(
        OutlinedTagPill(label: data.ethnicityTag, color: projectTagColorAt(2)),
      );
    }
    if (data.functionTag.isNotEmpty) {
      tags.add(
        OutlinedTagPill(label: data.functionTag, color: projectTagColorAt(3)),
      );
    }
    if (tags.isEmpty) {
      return const [
        OutlinedTagPill(
          label: 'Nenhuma tag selecionada',
          color: Color(0xFF6A6167),
        ),
      ];
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CharacterTimeField(
                  accentColor: accentColor,
                  dateEntry: dateEntry,
                  onTapClock: onCycleDateType,
                ),
              ),
              const SizedBox(width: 12),
              MiniGlassButton(
                accentColor: accentColor,
                icon: isEditing ? Icons.check_rounded : Icons.edit_outlined,
                onTap: onToggleEditing,
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditableSynopsisPanel(
            controller: synopsisController,
            scrollController: synopsisScrollController,
            isEditing: isEditing,
            focusedBorderColor: accentColor,
            placeholderText: synopsisPlaceholderText,
            textStyle: const TextStyle(
              color: Color(0xFF8F8990),
              fontSize: 11,
              height: 1.35,
            ),
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
            placeholderStyle: const TextStyle(
              color: Color(0xFF8F8990),
              fontSize: 11,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
            viewerBuilder: (context, text, style) {
              return CharacterMarkdownText(data: text, style: style);
            },
          ),
          const SizedBox(height: 12),
          CharacterQuoteStrip(
            accentColor: accentColor,
            controller: quoteController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final birthdayField = CharacterBirthdayField(
                accentColor: accentColor,
                birthdayLabel: birthdayLabel,
                signData: signData,
                isEditing: isEditing,
                onTapBirthday: onTapBirthday,
                onTapSign: onTapSign,
              );
              final heightField = CharacterHeightField(
                accentColor: accentColor,
                heightLabel: heightLabel,
                unitLabel: heightUnitCompactLabel(heightUnit),
                controller: heightController,
                isEditing: isEditing,
                onTapUnit: onTapHeightUnit,
                onCommitHeight: onCommitHeight,
              );
              final weightField = CharacterWeightField(
                accentColor: accentColor,
                weightLabel: weightLabel,
                unitLabel: weightUnitCompactLabel(weightUnit),
                controller: weightController,
                isEditing: isEditing,
                onTapUnit: onTapWeightUnit,
                onCommitWeight: onCommitWeight,
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  children: [
                    birthdayField,
                    const SizedBox(height: 8),
                    heightField,
                    const SizedBox(height: 8),
                    weightField,
                  ],
                );
              }

              if (constraints.maxWidth < 460) {
                return Column(
                  children: [
                    birthdayField,
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: heightField),
                        const SizedBox(width: 8),
                        Expanded(child: weightField),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: birthdayField),
                  const SizedBox(width: 8),
                  Expanded(child: heightField),
                  const SizedBox(width: 8),
                  Expanded(child: weightField),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _buildTagRow()),
        ],
      ),
    );
  }
}
