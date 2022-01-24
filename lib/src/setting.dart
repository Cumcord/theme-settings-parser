class Setting {
  // private constructor
  // we can expose this type but we only want to construct derived classes
  Setting._construct(this.type, this.prop, this.defaultVal);

  /// When used outside of Dart's type system, notably in JS, this is useful.
  final String type;
  String prop;
  String defaultVal;
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

  NumSetting(
      String prop, this.defaultV, this.unit, this.max, this.min, this.step)
      : super._construct("numentry", prop, defaultV.toString() + unit);
}

class SliderSetting extends NumSetting {
  SliderSetting(
      String prop, num defaultV, String unit, num max, num min, num step)
      : super(prop, defaultV, unit, max, min, step);
}
