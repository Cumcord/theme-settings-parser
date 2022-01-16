import 'package:cc_theme_settings_parser/src/block.dart';
import 'package:cc_theme_settings_parser/src/mode.dart';

/// an object containing everything needed to describe the state of a parser
class ParserState {
  ParserState(this.input);

  /// The input CSS.
  final String input;

  /// Where we are in the input.
  int pos = 0;

  /// stack to dump chars into until action needed; cleared between modes
  String workingStack = "";

  /// what part of the css were in; use to specialise parsing behaviour
  Mode mode = Mode.toplevel;

  /// used by Mode.string to know when to end the string and when to require \
  bool stringIsDouble = false;

  /// stores the last stack of Mode.string
  String lastString = "";

  /// spicy stuff now! last selector read by Mode.aftertopcomment
  String lastSelector = "";

  /// last property read by Mode.block, used to parse settings later on
  String lastProp = "";

  /// Used by modes like Mode.string and Mode.blockcomment to return back
  Mode lastMode = Mode.toplevel;

  /// After a comment, it may be necessary to keep the old value of workingStack
  String blockCommentReturnStack = "";

  /// parsed blocks go here, read your output out of this prop!!!
  Map<String, Block> blocks = {};
}
