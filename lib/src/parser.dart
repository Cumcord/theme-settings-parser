import 'dart:html';

import 'package:cc_theme_settings_parser/src/block.dart';
import 'package:cc_theme_settings_parser/src/constants.dart';

/* 
css code, with associated mode annotated with <>

<toplevel>


/* cc:stuff <topcomment> */
.selector <selector> .more-selecting {
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
  // if a comment is not `/* cc:settings */` then we return to toplevel.
  selector,
  block,
  blockcomment,
  // blocks that aren't marked with cc:settings
  unimportantblock,
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

  /// spicy stuff now! last selector read by Mode.aftertopcomment
  String _lastSelector = "";

  /// last property read by Mode.block, used to parse settings later on
  String _lastProp = "";

  /// Used by modes like Mode.string and Mode.blockcomment to return back
  Mode _lastMode = Mode.toplevel;

  /// parsed blocks go here, read your output out of this prop!!!
  Map<String, Block> blocks = {};

  void _resetStack() {
    _workingStack = "";
  }

  /// advances the parser one character, returns false if EOF else true
  bool advance() {
    if (pos >= input.length) {
      // points past end of input, so EOF
      return false;
    }

    final currentChar = input[pos];
    pos++;
    _workingStack += currentChar;

    // used to allow _mode to be modified but still set _lastMode right later
    final thisModeTmp = _mode;

    switch (_mode) {
      case Mode.toplevel:
        if (_workingStack.endsWith(COMMENT_START)) {
          _mode = Mode.topcomment;
          // when we enter a comment at top level,
          // we shouldnt need to remember anything before.
          _resetStack();
          return true;
        }

        break;

      case Mode.topcomment:
        if (_workingStack.endsWith(COMMENT_END)) {
          if (_workingStack == BLOCK_MARKER) {
            _mode = Mode.selector;
            _resetStack();
          } else {
            _mode = Mode.toplevel;
            // this comment was worthless, so discard it
            // the stack should only contain our comment in this mode.
            _resetStack();
          }
        }
        break;

      case Mode.selector:
        if (currentChar == BLOCK_MARKER) {
          _mode = Mode.block;
          _lastSelector = popLast(_workingStack);
          _resetStack();
        }
        break;

      case Mode.block:
        // TODO: WOOOOOO OH BOY FUN
        break;

      case Mode.unimportantblock:
        if (_workingStack.endsWith(COMMENT_START)) {
          _mode = Mode.blockcomment;
          _resetStack();
        } else if (currentChar == "'") {
          _mode = Mode.string;
          _stringIsDouble = false;
          _resetStack();
        } else if (currentChar == '"') {
          _mode = Mode.string;
          _stringIsDouble = true;
          _resetStack();
        } else if (_workingStack.endsWith(BLOCK_END)) {
          _mode = Mode.toplevel;
          _resetStack();
        }
        break;

      case Mode.blockcomment:
        if (_workingStack.endsWith(COMMENT_END)) {
          if (_lastMode == Mode.block) {
            // TODO: handle creating settings! Exciting!!!!
          } else {
            _mode = _lastMode;
            _resetStack();
          }
        }
        break;

      case Mode.string:
        final lastTwo = last(_workingStack, 2);
        if (((lastTwo[1] == '"' && !_stringIsDouble) ||
                (lastTwo[1] == "'" && _stringIsDouble)) &&
            lastTwo[0] == '\\') {
          _mode = _lastMode;
          _lastString = _workingStack;
          _resetStack();
        }
        break;
    }

    _lastMode = thisModeTmp;

    return true;
  }
}

String last(String str, [int count = 1]) {
  if (str.length < count) count = str.length - 1;

  return str.substring(str.length - count);
}

String popLast(String str, [int count = 1]) {
  if (str.length < count) count = str.length;

  return str.substring(0, str.length - count);
}
