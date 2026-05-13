part of '../create_character_dialog.dart';

class _CreateCharacterActionsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _CreateCharacterActionsRow({
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF514752),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDF6EB8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Criar personagem'),
          ),
        ),
      ],
    );
  }
}

class _CharacterFieldPrefix extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final double? width;

  const _CharacterFieldPrefix({
    required this.icon,
    required this.label,
    required this.accentColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? _characterDialogPrefixWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: const Color(0xFF171419)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFF3A3339),
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            Container(
              width: 1.2,
              height: 18,
              margin: const EdgeInsets.only(left: 8),
              color: accentColor.withValues(alpha: 0.76),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _buildCharacterDialogFieldDecoration({
  required String hintText,
  required Color focusedColor,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
  BoxConstraints? constraints,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
  );

  return InputDecoration(
    hintText: hintText,
    hintMaxLines: 4,
    prefixIcon: prefixIcon,
    prefixIconConstraints: prefixIcon == null
        ? null
        : const BoxConstraints(minWidth: 0, minHeight: 0),
    hintStyle: const TextStyle(
      color: Color(0xFF8E838B),
      fontSize: 12.5,
      fontStyle: FontStyle.italic,
      height: 1.3,
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.56),
    isDense: true,
    constraints: constraints,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: focusedColor, width: 1.1),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
    ),
  );
}

BoxDecoration _buildCharacterDialogSurfaceDecoration({
  required Color accentColor,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
  bool selected = false,
}) {
  final tint = selected
      ? accentColor
      : _lightenCharacterDialogColor(accentColor, 0.06);

  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.44),
    borderRadius: borderRadius,
    border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.7),
        tint.withValues(alpha: selected ? 0.16 : 0.1),
        _lightenCharacterDialogColor(accentColor, 0.22).withValues(alpha: 0.08),
      ],
      stops: const [0, 0.58, 1],
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

Color _lightenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darkenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
