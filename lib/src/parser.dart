@JS()
library cc_theme_settings_parser;

import 'package:cc_theme_settings_parser/src/mutableparser.dart';
import 'package:cc_theme_settings_parser/src/parserstate.dart';
import 'package:cc_theme_settings_parser/src/setting.dart';
import 'package:js/js.dart';

/// Parses thru CSS for settings.
class Parser {
  // this errors because it doesnt know for sure that _mutParser is assigned to
  // without analysing the control flow etc etc etc, which dart doesnt do
  // the statically typed alternative below provably ALWAYS inits _mutParser
  /* Parser(String input) {
    _mutParser = MutableParser(ParserState(input));
  } */

  Parser._typeCheckerLimitationBypass(this._mutParser);

  Parser(String input)
      : this._typeCheckerLimitationBypass(
            MutableParser(ParserState(input.replaceAll("\r\n", "\n"))));

  MutableParser _mutParser;

  ParserState get state => _mutParser.state;

  /// parses to end, and returns the parsed blocks
  Map<String, List<Setting>> parseToEnd() {
    while (_mutParser.advance()) {}
    return _mutParser.state.blocks;
  }

  /// advances the parser one character, returns false if EOF else true
  bool advance() => _mutParser.advance();
}
