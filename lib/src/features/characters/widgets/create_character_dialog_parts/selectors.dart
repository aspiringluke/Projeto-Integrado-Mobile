part of '../create_character_dialog.dart';

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
                          : 'Selecionar ou criar',
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

class _CharacterBirthdayDraftField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final ZodiacSignData signData;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onTapSign;

  const _CharacterBirthdayDraftField({
    required this.label,
    required this.valueLabel,
    required this.signData,
    required this.accentColor,
    required this.onTap,
    required this.onTapSign,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          padding: const EdgeInsets.only(right: 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _CharacterFieldPrefix(
                icon: Icons.cake_outlined,
                label: label,
                accentColor: accentColor,
              ),
              Expanded(
                child: Text(
                  valueLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.68),
                    fontSize: 11.8,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CharacterSignBadge(
                accentColor: accentColor,
                signData: signData,
                onTap: onTapSign,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterDisclosureTile extends StatelessWidget {
  final String title;
  final String summary;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onTap;

  const _CharacterDisclosureTile({
    required this.title,
    required this.summary,
    required this.accentColor,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: _buildCharacterDialogSurfaceDecoration(
            accentColor: accentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E838B),
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              MiniGlassButton(
                accentColor: accentColor,
                icon: isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterSignBadge extends StatelessWidget {
  final Color accentColor;
  final ZodiacSignData signData;
  final VoidCallback? onTap;

  const _CharacterSignBadge({
    required this.accentColor,
    required this.signData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.62),
            _lightenCharacterDialogColor(
              accentColor,
              0.16,
            ).withValues(alpha: 0.24),
            accentColor.withValues(alpha: 0.28),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            signData.symbol,
            style: TextStyle(
              color: _darkenCharacterDialogColor(accentColor, 0.24),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            signData.name,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.54),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: content,
      ),
    );
  }
}

class _CharacterUnitPillButton extends StatelessWidget {
  final Color accentColor;
  final String label;
  final VoidCallback onTap;

  const _CharacterUnitPillButton({
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
        child: Ink(
          width: _characterDialogMeasureUnitWidth,
          height: _characterDialogMeasureControlHeight,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.64),
                _lightenCharacterDialogColor(
                  accentColor,
                  0.18,
                ).withValues(alpha: 0.3),
                accentColor.withValues(alpha: 0.28),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _darkenCharacterDialogColor(accentColor, 0.22),
                    fontSize: 9.4,
                    height: 1,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: 12,
                color: _darkenCharacterDialogColor(accentColor, 0.18),
              ),
            ],
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
    final foregroundColor = isSelected
        ? _darkenCharacterDialogColor(accentColor, 0.24)
        : const Color(0xFF3A3339);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.46)
                  : Colors.white.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                signData.symbol,
                style: TextStyle(
                  color: _darkenCharacterDialogColor(accentColor, 0.2),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                signData.name,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: _darkenCharacterDialogColor(accentColor, 0.16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogSelectOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DialogSelectOption({
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
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFFDF6EB8)
                      : const Color(0xFF544959),
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
                  data: const CupertinoThemeData(brightness: Brightness.light),
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

class _CharacterTagEmptyState extends StatelessWidget {
  final Color accentColor;

  const _CharacterTagEmptyState({required this.accentColor});

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

class _CharacterTagOptionButton extends StatelessWidget {
  final ProjectTagData tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterTagOptionButton({
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

class _CharacterCenteredMenuFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _CharacterCenteredMenuFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.58),
              width: 0.9,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C262C),
                ),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
