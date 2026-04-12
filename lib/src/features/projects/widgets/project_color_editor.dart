import 'package:flutter/material.dart';

class ProjectColorEditor extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final HSLColor hslColor;
  final bool useSolidCoverPreview;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<double> onLightnessChanged;

  const ProjectColorEditor({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.hslColor,
    this.useSolidCoverPreview = false,
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
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 38,
          decoration: BoxDecoration(
            gradient: useSolidCoverPreview
                ? _buildCoverPreviewGradient(color)
                : _buildAccentPreviewGradient(color),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(height: 8),
        _ColorSliderField(
          label: 'Matiz',
          value: hslColor.hue,
          min: 0,
          max: 360,
          gradient: _buildHueGradient(),
          onChanged: onHueChanged,
        ),
        _ColorSliderField(
          label: 'Saturacao',
          value: hslColor.saturation,
          min: 0,
          max: 1,
          gradient: _buildSaturationGradient(hslColor),
          onChanged: onSaturationChanged,
        ),
        _ColorSliderField(
          label: 'Luminosidade',
          value: hslColor.lightness,
          min: 0,
          max: 1,
          gradient: _buildLightnessGradient(hslColor),
          onChanged: onLightnessChanged,
        ),
      ],
    );
  }
}

LinearGradient _buildCoverPreviewGradient(Color coverColor) {
  return LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.white.withValues(alpha: 0.96),
      Color.alphaBlend(
        coverColor.withValues(alpha: 0.28),
        const Color(0xFFF7F0F4),
      ),
      coverColor,
    ],
    stops: const [0.0, 0.56, 1.0],
  );
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

LinearGradient _buildHueGradient() {
  return const LinearGradient(
    colors: [
      Color(0xFFFF6B8B),
      Color(0xFFFFA65A),
      Color(0xFFF3DE67),
      Color(0xFF74D680),
      Color(0xFF5EC8E5),
      Color(0xFF7C88FF),
      Color(0xFFC676E8),
      Color(0xFFFF6B8B),
    ],
  );
}

LinearGradient _buildSaturationGradient(HSLColor color) {
  return LinearGradient(
    colors: [
      color.withSaturation(0).toColor(),
      color.withSaturation(1).toColor(),
    ],
  );
}

LinearGradient _buildLightnessGradient(HSLColor color) {
  return LinearGradient(
    colors: [
      Colors.white,
      color.withLightness(0.5).toColor(),
      Colors.black,
    ],
  );
}

class _ColorSliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  const _ColorSliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.gradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const thumbRadius = 8.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              max == 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1),
              style: const TextStyle(color: Color(0xFF7A7079), fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbRadius),
                  child: Center(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 0.9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 18,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: const Color(0xFFDF6EB8),
                  overlayColor: const Color(0xFFDF6EB8).withValues(alpha: 0.14),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: thumbRadius,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
