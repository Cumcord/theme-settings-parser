import 'package:cc_theme_settings_parser/src/block.dart';
import 'package:cc_theme_settings_parser/src/constants.dart';

/* 
css code, with associated mode annotated with <>

<toplevel>

/* cc:stuff <topcomment> */
.selector <aftertopcomment> .more-selecting {
  <block>
  prop: "val <string>"; /* <blockcomment> */
  <block>
  prop2: 5rem; /* <blockcomment> */
  <block>
}

<toplevel>

/* yeah this is a comment <topcomment> */

<toplevel>

*/

enum Mode {
  toplevel,
  topcomment,
  // aftertopcomment is for between comments and blocks (it captures selectors)
  // if a comment does not begin with `/* cc:` then we just return to toplevel.
  aftertopcomment,
  block,
  blockcomment,
  string,
}

/// Parses thru CSS for settings.
class Parser {
  Parser(this.input);

  /// The input CSS.
  final String input;

  /// Where we are in the input.
  int pos = 0;

  /// stack to dump chars into until action needed; cleared between modes
  String _workingStack = "";

  /// what part of the css were in; use to specialise parsing behaviour
  Mode _mode = Mode.toplevel;

  /// used by Mode.string to know when to end the string and when to require \
  bool _stringIsDouble = false;

  /// stores the last stack of Mode.string
  String _lastString = "";

  /// stores the last stack of Mode.topcomment
  String _lastTopComment = "";

  /// spicy stuff now! last selector read by Mode.aftertopcomment
  String _lastSelector = "";

  /// parsed blocks go here, read your output out of this prop!!!
  Map<String, Block> blocks = {};

  /// advances the parser one character, returns false if EOF else true
  bool advance() {
    if (pos >= input.length) {
      // points past end of input, so EOF
      return false;
    }

    final currentChar = input[pos];
    pos++;
    _workingStack += currentChar;

    switch (_mode) {
      case Mode.toplevel:
        if (last(_workingStack, 3) == COMMENT_START) {
          _workingStack = popLast(_workingStack, 3);
          _mode = Mode.topcomment;
          // when we enter a comment at top level,
          // we shouldnt need to remember anything before.
          _workingStack = "";
          return true;
        }
        break;

      case Mode.topcomment:
        if (last(_workingStack, 3) == COMMENT_END) {
          _workingStack = popLast(_workingStack, 3);

          if (_workingStack == BLOCK_MARKER) {
            _mode = Mode.aftertopcomment;
            // save the comment contents for later, as theyll be needed!
            _lastTopComment = _workingStack;
            _workingStack = "";
          } else {
            _mode = Mode.toplevel;
            // this comment was worthless, so discard it
            // the stack should only contain our comment in this mode.
            _workingStack = "";
          }

          return true;
        }
        break;

      case Mode.aftertopcomment:
        break;

      case Mode.block:
        break;

      case Mode.blockcomment:
        break;
      case Mode.string:
        final lastTwo = last(_workingStack, 2);
        if (((lastTwo[1] == '"' && !_stringIsDouble) ||
                (lastTwo[1] == "'" && _stringIsDouble)) &&
            lastTwo[0] == '\\') {
          _mode = Mode.block;
          return true;
        }
        break;
    }

    return true;
  }
}

String last(String str, [int count = 1]) {
  return str.substring(str.length - count);
}

String popLast(String str, [int count = 1]) {
  return str.substring(0, str.length - count);
}
