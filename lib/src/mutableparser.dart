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

import 'package:cc_theme_settings_parser/src/constants.dart';
import 'package:cc_theme_settings_parser/src/mode.dart';
import 'package:cc_theme_settings_parser/src/parserstate.dart';
import 'package:cc_theme_settings_parser/src/util.dart';

/// ONLY USE FOR DEBUGGING, USE `Parser` INSTEAD
class MutableParser {
  MutableParser(this.state);

  ParserState state;

  void _resetStack() {
    state.workingStack = "";
  }

  bool advance() {
    if (state.pos >= state.input.length) {
      // points past end of input, so EOF
      return false;
    }

    final currentChar = state.input[state.pos];
    state.pos++;
    state.workingStack += currentChar;

    // used to allow _mode to be modified but still set _lastMode right later
    final thisModeTmp = state.mode;

    switch (state.mode) {
      case Mode.toplevel:
        if (state.workingStack.endsWith(COMMENT_START)) {
          state.mode = Mode.topcomment;
          // when we enter a comment at top level,
          // we shouldnt need to remember anything before.
          _resetStack();
          return true;
        }

        break;

      case Mode.topcomment:
        if (state.workingStack.endsWith(COMMENT_END)) {
          if (state.workingStack == BLOCK_MARKER) {
            state.mode = Mode.selector;
            _resetStack();
          } else {
            state.mode = Mode.toplevel;
            // this comment was worthless, so discard it
            // the stack should only contain our comment in this mode.
            _resetStack();
          }
        }
        break;

      case Mode.selector:
        if (currentChar == BLOCK_MARKER) {
          state.mode = Mode.block;
          state.lastSelector = popLast(state.workingStack);
          _resetStack();
        }
        break;

      case Mode.block:
        // TODO: WOOOOOO OH BOY FUN
        break;

      case Mode.unimportantblock:
        if (state.workingStack.endsWith(COMMENT_START)) {
          state.mode = Mode.blockcomment;
          _resetStack();
        } else if (currentChar == "'") {
          state.mode = Mode.string;
          state.stringIsDouble = false;
          _resetStack();
        } else if (currentChar == '"') {
          state.mode = Mode.string;
          state.stringIsDouble = true;
          _resetStack();
        } else if (state.workingStack.endsWith(BLOCK_END)) {
          state.mode = Mode.toplevel;
          _resetStack();
        }
        break;

      case Mode.blockcomment:
        if (state.workingStack.endsWith(COMMENT_END)) {
          if (state.lastMode == Mode.block) {
            // TODO: handle creating settings! Exciting!!!!
          } else {
            state.mode = state.lastMode;
            _resetStack();
          }
        }
        break;

      case Mode.string:
        final lastTwo = last(state.workingStack, 2);
        if (((lastTwo[1] == '"' && !state.stringIsDouble) ||
                (lastTwo[1] == "'" && state.stringIsDouble)) &&
            lastTwo[0] == '\\') {
          state.mode = state.lastMode;
          state.lastString = state.workingStack;
          _resetStack();
        }
        break;
    }

    state.lastMode = thisModeTmp;

    return true;
  }
}
