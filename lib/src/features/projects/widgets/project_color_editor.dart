import 'package:flutter/material.dart';

class ProjectColorEditor extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final HSLColor hslColor;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<double> onLightnessChanged;

  const ProjectColorEditor({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.hslColor,
    required this.onHueChanged,
    required this.onSaturationChanged,
    required this.onLightnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3A3339),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF6A6167),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: _buildAccentPreviewGradient(color),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(height: 10),
        _ColorSliderField(
          label: 'Matiz',
          value: hslColor.hue,
          min: 0,
          max: 360,
          onChanged: onHueChanged,
        ),
        _ColorSliderField(
          label: 'Saturacao',
          value: hslColor.saturation,
          min: 0,
          max: 1,
          onChanged: onSaturationChanged,
        ),
        _ColorSliderField(
          label: 'Luminosidade',
          value: hslColor.lightness,
          min: 0,
          max: 1,
          onChanged: onLightnessChanged,
        ),
      ],
    );
  }
}

class _ColorSliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ColorSliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              max == 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1),
              style: const TextStyle(color: Color(0xFF7A7079), fontSize: 12),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: const Color(0xFFDF6EB8),
          inactiveColor: const Color(0xFFE4D4DE),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

LinearGradient _buildAccentPreviewGradient(Color accentColor) {
  final hsl = HSLColor.fromColor(accentColor);
  final lighter = hsl
      .withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0))
      .toColor();

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        lighter.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.82),
      ),
      Colors.white.withValues(alpha: 0.78),
      Color.alphaBlend(
        accentColor.withValues(alpha: 0.2),
        const Color(0xFFF9F1F5),
      ),
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}
