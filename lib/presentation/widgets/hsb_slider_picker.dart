import 'package:flutter/material.dart';

/// HSB slider picker with Hue, Saturation, and Brightness sliders.
///
/// Uses internal [HSVColor] as source of truth to avoid the hue 360->0
/// round-trip bug that occurs when converting HSV -> Color -> HSV.
class HsbSliderPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const HsbSliderPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<HsbSliderPicker> createState() => _HsbSliderPickerState();
}

class _HsbSliderPickerState extends State<HsbSliderPicker> {
  late HSVColor _hsv;
  Color? _lastCallbackColor;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.color);
  }

  @override
  void didUpdateWidget(HsbSliderPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync from parent if the color change wasn't an echo of our own callback.
    if (widget.color != _lastCallbackColor) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _updateHsv(HSVColor newHsv) {
    setState(() => _hsv = newHsv);
    final color = newHsv.toColor();
    _lastCallbackColor = color;
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context, 'Hue', '${_hsv.hue.round()}°'),
        _buildHueSlider(),
        const SizedBox(height: 8),
        _buildLabel(context, 'Saturation', '${(_hsv.saturation * 100).round()}%'),
        _buildGradientSlider(
          value: _hsv.saturation,
          onChanged: (v) => _updateHsv(_hsv.withSaturation(v)),
          gradient: LinearGradient(colors: [
            _hsv.withSaturation(0).toColor(),
            _hsv.withSaturation(1).toColor(),
          ]),
        ),
        const SizedBox(height: 8),
        _buildLabel(context, 'Brightness', '${(_hsv.value * 100).round()}%'),
        _buildGradientSlider(
          value: _hsv.value,
          onChanged: (v) => _updateHsv(_hsv.withValue(v)),
          gradient: LinearGradient(colors: [
            _hsv.withValue(0).toColor(),
            _hsv.withValue(1).toColor(),
          ]),
        ),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildHueSlider() {
    return _buildGradientSlider(
      value: _hsv.hue / 360.0,
      onChanged: (v) => _updateHsv(_hsv.withHue(v * 360.0)),
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFF0000), // 0°
          Color(0xFFFFFF00), // 60°
          Color(0xFF00FF00), // 120°
          Color(0xFF00FFFF), // 180°
          Color(0xFF0000FF), // 240°
          Color(0xFFFF00FF), // 300°
          Color(0xFFFF0000), // 360°
        ],
      ),
    );
  }

  Widget _buildGradientSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required LinearGradient gradient,
  }) {
    return SizedBox(
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 0,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
