@JS("themesettings")
library cc_theme_settings_parser;

import 'package:cc_theme_settings_parser/src/parser.dart';
import 'package:js/js.dart';

export 'src/parser.dart';

@JS("getParser")
external set _getParser(Function _f);

@JS()
external Parser getParser();

void main() {
  _getParser = allowInterop((String text) => Parser(text));
}
