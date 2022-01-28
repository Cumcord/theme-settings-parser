@JS()
library cc_theme_settings_parser;

import 'package:cc_theme_settings_parser/src/parser.dart';
import 'package:cc_theme_settings_parser/src/setting.dart';
import 'package:js/js.dart';

export 'src/parser.dart';

@JS("ThemeSettingsParser")
class JSParser {
  /* final Parser _parser;

  JSParser(String raw) : this._construct(Parser(raw));

  JSParser._construct(this._parser) {
    _parseToEnd = allowInterop(_parser.parseToEnd);
  }

  @JS('parseToEnd')
  external set _parseToEnd(void Function() f);

  external Map<String, List<Setting>> parseToEnd(); */
  external void test();
}

/* @JS("ThemeSettingsParser")
external JSParser parser; */

@JS("eval")
external Object? JS_EVAL(String code);

void main() {
  JS_EVAL("""
    window.ThemeSettingsParser = class JSParser {
      constructor() {
      }
      test() {console.log('hello, world!')}
    }
  """);
  final parser = JSParser();
  parser.test();
}
