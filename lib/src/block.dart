import 'package:cc_theme_settings_parser/src/setting.dart';

/// Represents a css selector and style block, with some settings inside
class Block {
  Block(this.selector);

  final String selector;
  List<Setting> settings = [];
}
