part of '../character_fields.dart';

class CharacterBirthdayField extends StatelessWidget {
  final Color accentColor;
  final String birthdayLabel;
  final ZodiacSignData signData;
  final bool isEditing;
  final VoidCallback onTapBirthday;
  final ValueChanged<Rect> onTapSign;

  const CharacterBirthdayField({
    super.key,
    required this.accentColor,
    required this.birthdayLabel,
    required this.signData,
    required this.isEditing,
    required this.onTapBirthday,
    required this.onTapSign,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isEditing ? onTapBirthday : null,
              child: _CharacterPillSurface(
                radius: 999,
                padding: const EdgeInsets.only(left: 12, right: 52),
                fillColor: Colors.white.withValues(alpha: 0.42),
                borderColor: Colors.white.withValues(alpha: 0.62),
                child: Row(
                  children: [
                    Icon(
                      isEditing
                          ? Icons.edit_calendar_outlined
                          : Icons.cake_outlined,
                      size: 18,
                      color: const Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: accentColor.withValues(alpha: 0.84),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          birthdayLabel,
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.68),
                            fontSize: 11,
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
          Positioned(
            right: 3,
            top: 5,
            bottom: 5,
            child: _CharacterSignButton(
              accentColor: accentColor,
              signData: signData,
              onTap: onTapSign,
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterHeightField extends StatelessWidget {
  final Color accentColor;
  final String heightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitHeight;

  const CharacterHeightField({
    super.key,
    required this.accentColor,
    required this.heightLabel,
    required this.unitLabel,
    required this.controller,
    required this.isEditing,
    required this.onTapUnit,
    required this.onCommitHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: _CharacterPillSurface(
                radius: 999,
                padding: const EdgeInsets.only(left: 12, right: 74),
                fillColor: Colors.white.withValues(alpha: 0.42),
                borderColor: Colors.white.withValues(alpha: 0.62),
                child: Row(
                  children: [
                    const Icon(
                      Icons.straighten_rounded,
                      size: 18,
                      color: Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: accentColor.withValues(alpha: 0.84),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              minLines: 1,
                              maxLines: 1,
                              onSubmitted: (_) => onCommitHeight(),
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                                onCommitHeight();
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Altura',
                              ),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              heightLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: _CharacterUnitButton(
              accentColor: accentColor,
              label: unitLabel,
              onTap: onTapUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterWeightField extends StatelessWidget {
  final Color accentColor;
  final String weightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitWeight;

  const CharacterWeightField({
    super.key,
    required this.accentColor,
    required this.weightLabel,
    required this.unitLabel,
    required this.controller,
    required this.isEditing,
    required this.onTapUnit,
    required this.onCommitWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: _CharacterPillSurface(
                radius: 999,
                padding: const EdgeInsets.only(left: 12, right: 54),
                fillColor: Colors.white.withValues(alpha: 0.42),
                borderColor: Colors.white.withValues(alpha: 0.62),
                child: Row(
                  children: [
                    const Icon(
                      Icons.balance_outlined,
                      size: 18,
                      color: Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: accentColor.withValues(alpha: 0.84),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              minLines: 1,
                              maxLines: 1,
                              onSubmitted: (_) => onCommitWeight(),
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                                onCommitWeight();
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Peso',
                              ),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              weightLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.68),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            bottom: 4,
            child: _CharacterUnitButton(
              accentColor: accentColor,
              label: unitLabel,
              onTap: onTapUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterSignButton extends StatelessWidget {
  final Color accentColor;
  final ZodiacSignData signData;
  final ValueChanged<Rect> onTap;

  const _CharacterSignButton({
    required this.accentColor,
    required this.signData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (buttonContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(rectFromContext(buttonContext)),
            borderRadius: BorderRadius.circular(999),
            child: _CharacterPillSurface(
              radius: 999,
              width: 40,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              fillColor: accentColor.withValues(alpha: 0.3),
              borderColor: Colors.white.withValues(alpha: 0.82),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.62),
                  _lightenCharacterAccent(
                    accentColor,
                    0.18,
                  ).withValues(alpha: 0.4),
                  accentColor.withValues(alpha: 0.32),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    signData.symbol,
                    style: TextStyle(
                      fontSize: 11,
                      height: 0.9,
                      color: _darkenCharacterAccent(accentColor, 0.24),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        signData.name,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.5),
                          fontSize: 6.6,
                          height: 0.9,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CharacterUnitButton extends StatelessWidget {
  final Color accentColor;
  final String label;
  final VoidCallback onTap;

  const _CharacterUnitButton({
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
        child: _CharacterPillSurface(
          radius: 999,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          fillColor: accentColor.withValues(alpha: 0.24),
          borderColor: Colors.white.withValues(alpha: 0.82),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.64),
              _lightenCharacterAccent(accentColor, 0.18).withValues(alpha: 0.3),
              accentColor.withValues(alpha: 0.28),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: _darkenCharacterAccent(accentColor, 0.24),
                      fontSize: 8.8,
                      height: 0.9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 12,
                    color: _darkenCharacterAccent(accentColor, 0.18),
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

Color _lightenCharacterAccent(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darkenCharacterAccent(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
