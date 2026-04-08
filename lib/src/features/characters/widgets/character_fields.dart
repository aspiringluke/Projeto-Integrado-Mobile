part of '../pages/characters_section.dart';

class _CharacterTimeField extends StatelessWidget {
  final _CharacterDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _CharacterTimeField({
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    const circleDiameter = 38.0;
    const fieldHeight = 38.0;
    const pillLeftInset = 8.0;

    return SizedBox(
      height: fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: pillLeftInset,
            child: _CharacterPillSurface(
              radius: fieldHeight / 2,
              blurSigma: 9,
              padding: const EdgeInsets.only(left: 40, right: 31),
              fillColor: const Color(0xFFF3EEF3).withValues(alpha: 0.3),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  const Color(0xFFF6EEF3).withValues(alpha: 0.32),
                  const Color(0xFFE3D8E0).withValues(alpha: 0.16),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
              child: Text(
                '${dateEntry.label}: ${_formatDateTime(dateEntry.value)}, ${_formatRelativePhrase(dateEntry.value)}.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GlassCircleButton(
              diameter: circleDiameter,
              onTap: onTapClock,
              blurSigma: 8,
              fillColor: const Color(0xFFF0BEDB).withValues(alpha: 0.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  const Color(0xFFF4D5E6).withValues(alpha: 0.52),
                  const Color(0xFFE8C4D9).withValues(alpha: 0.36),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDF6EB8).withValues(alpha: 0.08),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              child: const Icon(
                Icons.history_rounded,
                size: 19,
                color: Color(0xFF171419),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color fillColor;

  const _MiniGlassButton({
    required this.icon,
    required this.onTap,
    this.fillColor = const Color(0x6BFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      diameter: 34,
      onTap: onTap,
      blurSigma: 8,
      fillColor: fillColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.58),
          Color.alphaBlend(
            const Color(0xFFF7EEF5).withValues(alpha: 0.42),
            fillColor,
          ),
          Color.alphaBlend(
            const Color(0xFFE4D4E1).withValues(alpha: 0.2),
            fillColor,
          ),
        ],
      ),
      borderColor: Colors.white.withValues(alpha: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
      child: Icon(
        icon,
        color: const Color(0xFF544959),
        size: 17,
      ),
    );
  }
}

class _CharacterPillSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final double? width;
  final double? height;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final AlignmentGeometry alignment;

  const _CharacterPillSurface({
    required this.child,
    required this.radius,
    this.width,
    this.height,
    this.blurSigma = 0,
    this.padding = EdgeInsets.zero,
    this.fillColor = const Color(0x6BFFFFFF),
    this.borderColor = const Color(0xAAFFFFFF),
    this.borderWidth = 0.8,
    this.gradient,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.66),
                Color.alphaBlend(
                  const Color(0xFFF6EEF3).withValues(alpha: 0.32),
                  fillColor,
                ),
                Color.alphaBlend(
                  const Color(0xFFE3D8E0).withValues(alpha: 0.18),
                  fillColor,
                ),
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.52],
        ),
      ),
      child: child,
    );

    if (blurSigma <= 0) {
      return content;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}

class _CharacterQuoteStrip extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;

  const _CharacterQuoteStrip({
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return _CharacterPillSurface(
      radius: 999,
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      fillColor: Colors.white.withValues(alpha: 0.34),
      borderColor: Colors.white.withValues(alpha: 0.68),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.56),
          const Color(0xFFF7EEF5).withValues(alpha: 0.28),
          const Color(0xFFE4D4E1).withValues(alpha: 0.16),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.52),
                  width: 0.8,
                ),
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: Color(0xFF171419),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Frase de efeito do personagem',
                      prefixText: '"',
                      suffixText: '"',
                      prefixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : _CharacterMarkdownText(
                    data: '"${controller.text}"',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CharacterBirthdayField extends StatelessWidget {
  final String birthdayLabel;
  final _ZodiacSignData signData;
  final bool isEditing;
  final ValueChanged<Rect> onTapAge;
  final VoidCallback onTapBirthday;
  final ValueChanged<Rect> onTapSign;

  const _CharacterBirthdayField({
    required this.birthdayLabel,
    required this.signData,
    required this.isEditing,
    required this.onTapAge,
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
                      isEditing ? Icons.edit_calendar_outlined : Icons.cake_outlined,
                      size: 18,
                      color: const Color(0xFF171419),
                    ),
                    Container(
                      width: 1.3,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Builder(
                          builder: (textContext) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: isEditing
                                  ? null
                                  : () => onTapAge(_rectFromContext(textContext)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    birthdayLabel,
                                    style: TextStyle(
                                      color: Colors.black.withValues(alpha: 0.68),
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  SizedBox(
                                    width: 34,
                                    height: 2,
                                    child: CustomPaint(
                                      painter: _DashedUnderlinePainter(
                                        color: const Color(0xFF8A828C).withValues(alpha: 0.58),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
              signData: signData,
              onTap: onTapSign,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterHeightField extends StatelessWidget {
  final String heightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitHeight;

  const _CharacterHeightField({
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
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
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
              label: unitLabel,
              onTap: onTapUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterWeightField extends StatelessWidget {
  final String weightLabel;
  final String unitLabel;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onTapUnit;
  final VoidCallback onCommitWeight;

  const _CharacterWeightField({
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
                      color: const Color(0xFFDF6EB8),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textInputAction: TextInputAction.done,
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
  final _ZodiacSignData signData;
  final ValueChanged<Rect> onTap;

  const _CharacterSignButton({
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
            onTap: () => onTap(_rectFromContext(buttonContext)),
            borderRadius: BorderRadius.circular(999),
            child: _CharacterPillSurface(
              radius: 999,
              width: 40,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              fillColor: const Color(0xFFF3D7E6).withValues(alpha: 0.88),
              borderColor: Colors.white.withValues(alpha: 0.82),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    signData.symbol,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 0.9,
                      color: Color(0xFF544959),
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
                          color: Colors.black.withValues(alpha: 0.48),
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

class _ZodiacTraitPill extends StatelessWidget {
  final String label;

  const _ZodiacTraitPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEF3).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CharacterUnitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CharacterUnitButton({
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
          fillColor: const Color(0xFFF0E2EA).withValues(alpha: 0.9),
          borderColor: Colors.white.withValues(alpha: 0.82),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Unidade',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.42),
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
                      color: Colors.black.withValues(alpha: 0.42),
                      fontSize: 8.8,
                      height: 0.9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 12,
                    color: Colors.black.withValues(alpha: 0.38),
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

class _HeightUnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeightUnitOption({
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
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? const Color(0xFFDF6EB8) : const Color(0xFF544959),
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
                  data: const CupertinoThemeData(
                    brightness: Brightness.light,
                  ),
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

class _CharacterMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const _CharacterMarkdownText({
    required this.data,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedData = _sanitizeCharacterMarkdown(data);
    final normalizedData = sanitizedData.trim().isEmpty ? ' ' : sanitizedData;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: style,
      pPadding: EdgeInsets.zero,
      blockSpacing: 0,
      listIndent: 18,
      listBullet: style,
      listBulletPadding: const EdgeInsets.only(right: 6),
      strong: style.copyWith(
        fontWeight: FontWeight.w700,
        fontStyle: style.fontStyle,
      ),
      em: style.copyWith(fontStyle: FontStyle.italic),
      code: style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.transparent,
      ),
      blockquote: style,
      blockquotePadding: EdgeInsets.zero,
      blockquoteDecoration: const BoxDecoration(),
    );

    return MarkdownBody(
      data: normalizedData,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: styleSheet,
    );
  }
}

