import 'package:flutter/material.dart';

import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';
import 'character_fields.dart';

class ExpandedCharacterBody extends StatelessWidget {
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
  final ValueChanged<Rect> onTapAge;
  final VoidCallback onTapBirthday;
  final VoidCallback onTapHeightUnit;
  final VoidCallback onTapWeightUnit;
  final VoidCallback onCommitHeight;
  final VoidCallback onCommitWeight;
  final VoidCallback onToggleEditing;

  const ExpandedCharacterBody({
    super.key,
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
    required this.onTapAge,
    required this.onTapBirthday,
    required this.onTapHeightUnit,
    required this.onTapWeightUnit,
    required this.onCommitHeight,
    required this.onCommitWeight,
    required this.onToggleEditing,
  });

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
                  dateEntry: dateEntry,
                  onTapClock: onCycleDateType,
                ),
              ),
              const SizedBox(width: 12),
              MiniGlassButton(
                icon: isEditing ? Icons.check_rounded : Icons.edit_outlined,
                onTap: onToggleEditing,
                fillColor: Colors.white.withValues(alpha: 0.34),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditableSynopsisPanel(
            controller: synopsisController,
            scrollController: synopsisScrollController,
            isEditing: isEditing,
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
              return CharacterMarkdownText(
                data: text,
                style: style,
              );
            },
          ),
          const SizedBox(height: 12),
          CharacterQuoteStrip(
            controller: quoteController,
            isEditing: isEditing,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CharacterBirthdayField(
                  birthdayLabel: birthdayLabel,
                  signData: signData,
                  isEditing: isEditing,
                  onTapAge: onTapAge,
                  onTapBirthday: onTapBirthday,
                  onTapSign: onTapSign,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CharacterHeightField(
                  heightLabel: heightLabel,
                  unitLabel: heightUnitCompactLabel(heightUnit),
                  controller: heightController,
                  isEditing: isEditing,
                  onTapUnit: onTapHeightUnit,
                  onCommitHeight: onCommitHeight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CharacterWeightField(
                  weightLabel: weightLabel,
                  unitLabel: weightUnitCompactLabel(weightUnit),
                  controller: weightController,
                  isEditing: isEditing,
                  onTapUnit: onTapWeightUnit,
                  onCommitWeight: onCommitWeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              OutlinedTagPill(label: 'Tag 1', color: Color(0xFFEB76AE)),
              SizedBox(width: 8),
              OutlinedTagPill(label: 'Tag 2', color: Color(0xFF8EAFF1)),
            ],
          ),
        ],
      ),
    );
  }
}
