@JS()
library cc_theme_settings_parser;

import 'dart:convert';

import 'package:cc_theme_settings_parser/src/mode.dart';
import 'package:cc_theme_settings_parser/src/parser.dart';
import 'package:cc_theme_settings_parser/src/parsererror.dart';
import 'package:js/js.dart';

export 'src/parser.dart';

@JS("parseThemeSettings")
external set _parseThemeSettings(Function _f);

@JS()
external Object? eval(String code);

Object? jsonErrorToEncodable(dynamic obj) {
  if (obj is Mode) {
    return obj.toString();
  }
  return obj.toJson();
}

String jsParse(String raw) {
  try {
    return jsonEncode(Parser(raw).parseToEnd());
  } catch (e) {
    if (e is ParserError) {
      final jsonError = jsonEncode(e, toEncodable: jsonErrorToEncodable)
          .replaceAll("\\", "\\\\")
          .replaceAll('`', '\\`');
      eval("throw JSON.parse(`$jsonError`)");
    }

    rethrow;
  }
}

void main() {
  _parseThemeSettings = allowInterop(jsParse);
  eval("""const oldParseThemeSettings = parseThemeSettings;
      window.parseThemeSettings = (raw) => JSON.parse(oldParseThemeSettings(raw))""");
}
