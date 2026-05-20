import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../shared/utils/rect_from_context.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../models/characters_models.dart';
import '../utils/characters_utils.dart';

class CharacterTimeField extends StatelessWidget {
  final Color accentColor;
  final CharacterDateEntry dateEntry;
  final VoidCallback onTapClock;

  const CharacterTimeField({
    super.key,
    required this.accentColor,
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
              fillColor: accentColor.withValues(alpha: 0.16),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  accentColor.withValues(alpha: 0.18),
                  _lightenCharacterAccent(
                    accentColor,
                    0.24,
                  ).withValues(alpha: 0.12),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
              child: Text(
                '${dateEntry.label}: ${formatDateTime(dateEntry.value)}, ${formatRelativePhrase(dateEntry.value)}.',
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
              fillColor: accentColor.withValues(alpha: 0.42),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  _lightenCharacterAccent(
                    accentColor,
                    0.18,
                  ).withValues(alpha: 0.52),
                  accentColor.withValues(alpha: 0.42),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
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

class MiniGlassButton extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? fillColor;

  const MiniGlassButton({
    super.key,
    required this.accentColor,
    required this.icon,
    required this.onTap,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFillColor = fillColor ?? accentColor.withValues(alpha: 0.22);

    return GlassCircleButton(
      diameter: 34,
      onTap: onTap,
      blurSigma: 8,
      fillColor: resolvedFillColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.58),
          accentColor.withValues(alpha: 0.22),
          _lightenCharacterAccent(accentColor, 0.22).withValues(alpha: 0.18),
        ],
      ),
      borderColor: Colors.white.withValues(alpha: 0.8),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.14),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
      child: Icon(icon, color: const Color(0xFF544959), size: 17),
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
        gradient:
            gradient ??
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
        border: Border.all(color: borderColor, width: borderWidth),
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

    return content;
  }
}

class CharacterQuoteStrip extends StatelessWidget {
  final Color accentColor;
  final TextEditingController controller;
  final bool isEditing;
  final String hintText;
  final bool showHintText;
  final String? tooltipText;

  const CharacterQuoteStrip({
    super.key,
    required this.accentColor,
    required this.controller,
    required this.isEditing,
    this.hintText = 'Frase de efeito do personagem',
    this.showHintText = true,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
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
          accentColor.withValues(alpha: 0.12),
          _lightenCharacterAccent(accentColor, 0.22).withValues(alpha: 0.08),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border(
                right: BorderSide(
                  color: accentColor.withValues(alpha: 0.3),
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
                      hintText: showHintText ? hintText : null,
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
                : CharacterMarkdownText(
                    data: '"${controller.text}"',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          if ((tooltipText ?? '').trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Theme(
              data: tooltipTheme,
              child: Tooltip(
                message: tooltipText!,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.black.withValues(alpha: 0.42),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

class CharacterMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const CharacterMarkdownText({
    super.key,
    required this.data,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedData = sanitizeCharacterMarkdown(data);
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
