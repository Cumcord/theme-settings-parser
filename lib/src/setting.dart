class Setting {
  // private constructor
  // we can expose this type but we only want to construct derived classes
  Setting._construct(this.type, this.prop, this.defaultVal);

  /// When used outside of Dart's type system, notably in JS, this is useful.
  final String type;
  String prop;
  String defaultVal;

  Map<String, dynamic> toJson() => {
        'type': type,
        'prop': prop,
        'defaultVal': defaultVal,
      };
}

class DropdownSetting extends Setting {
  List<String> options;

  DropdownSetting(String prop, String defaultVal, this.options)
      : super._construct("dropdown", prop, defaultVal);
}

class ColorPickerSetting extends Setting {
  ColorPickerSetting(String prop, String defaultVal)
      : super._construct("colorpicker", prop, defaultVal);
}

class TextSetting extends Setting {
  TextSetting(String prop, String defaultVal)
      : super._construct("text", prop, defaultVal);
}

class NumSetting extends Setting {
  num defaultV;
  num max;
  num min;
  num step;
  String unit;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'prop': prop,
        'defaultVal': defaultVal,
        'defaultV': defaultV,
        'max': max,
        'min': min,
        'step': step,
        'unit': unit,
      };

  NumSetting(String prop, num defaultV, String unit, num max, num min, num step)
      : this._construct("num", prop, defaultV, unit, max, min, step);

  NumSetting._construct(String type, String prop, this.defaultV, this.unit,
      this.max, this.min, this.step)
      : super._construct(type, prop, defaultV.toString() + unit);
}

class SliderSetting extends NumSetting {
  SliderSetting(
      String prop, num defaultV, String unit, num max, num min, num step)
      : super._construct("slider", prop, defaultV, unit, max, min, step);
}
