class Setting {
  // private constructor
  // we can expose this type but we only want to construct derived classes
  Setting._construct(this.type, this.prop, this.defaultVal);

  final String type;
  String prop;
  String defaultVal;
}

class Dropdown extends Setting {
  List<String> options;

  Dropdown(String prop, String defaultVal, this.options)
      : super._construct("dropdown", prop, defaultVal);
}

class ColorPicker extends Setting {
  ColorPicker(String prop, String defaultVal)
      : super._construct("colorpicker", prop, defaultVal);
}

class Text extends Setting {
  Text(String prop, String defaultVal)
      : super._construct("text", prop, defaultVal);
}

class NumEntry extends Setting {
  num? max;
  num? min;
  num step = 1;
  List<String> units;

  NumEntry(String prop, String defaultVal, this.max, this.min, this.units)
      : super._construct("numentry", prop, defaultVal);
}

class SliderEntry extends NumEntry {
  SliderEntry(
      String prop, String defaultVal, num? max, num? min, List<String> units)
      : super(prop, defaultVal, max, min, units);
}
