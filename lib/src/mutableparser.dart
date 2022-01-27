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
import 'package:cc_theme_settings_parser/src/parsererror.dart';
import 'package:cc_theme_settings_parser/src/parserstate.dart';
import 'package:cc_theme_settings_parser/src/setting.dart';
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
      // we're before a cc: comment (at the very start or after a })
      case Mode.toplevel:
        if (state.workingStack.endsWith(COMMENT_START)) {
          state.mode = Mode.topcomment;
          _resetStack();
        } else if (currentChar == BLOCK_START) {
          state.mode = Mode.unimportantblock;
          _resetStack();
        }
        break;

      // a top level comment, be it cc: or not
      case Mode.topcomment:
        if (state.workingStack.endsWith(COMMENT_END)) {
          popLastWorkingStack(state, 2);
          trimStack(state);

          if (state.workingStack.startsWith(COMMENT_PREFIX) &&
              state.workingStack.substring(COMMENT_PREFIX.length) ==
                  COMMENT_SETTINGS) {
            // cc:settings
            state.mode = Mode.selector;
            _resetStack();
          } else {
            state.mode = Mode.toplevel;
            // this comment was worthless, so discard it :husk:
            _resetStack();
          }
        }
        break;

      // a selector, but only after an applicable cc:settings comment
      case Mode.selector:
        if (currentChar == BLOCK_START) {
          popLastWorkingStack(state);
          trimStack(state);
          state.mode = Mode.block;
          // exciting, time to enter a block that needs proper parsing
          state.lastSelector = minifySelector(state.workingStack);
          _resetStack();
        }
        break;

      // parsing a block that's important
      case Mode.block:
        if (currentChar == PROP_END) {
          popLastWorkingStack(state);
          trimStack(state);
          state.mode = Mode.afterprop;
          state.lastProp = state.workingStack;
          _resetStack();
        } else if (currentChar == BLOCK_END) {
          state.mode = Mode.toplevel;
          _resetStack();
        } else if (state.workingStack.endsWith(COMMENT_START)) {
          popLastWorkingStack(state, COMMENT_START.length);
          state.mode = Mode.blockcomment;
          state.blockCommentReturnStack = state.workingStack;
          _resetStack();
        } else if (currentChar == "'") {
          state.mode = Mode.string;
          state.stringIsDouble = false;
        } else if (currentChar == '"') {
          state.mode = Mode.string;
          state.stringIsDouble = true;
        }
        break;

      /* 
       * after a ;, but before a comment.
       * If a comment is not encountered return to block
       * this is mostly here so blockcomment knows its important
       * by reading lastmode and seeing we came from a prop.
       * Probably the only part of this entire parser that cares about chars:
       * only parses thru " " or "/" to get allow parsing thru to comments
       * else immediately backtracks one char and falls back to block
       */
      case Mode.afterprop:
        if (state.workingStack.endsWith(COMMENT_START)) {
          state.mode = Mode.blockcomment;
          _resetStack();
        } else if (!AFTERPROP_PARSE_CHARS.contains(currentChar)) {
          state.mode = Mode.block;
          state.pos--;
          _resetStack();
        }
        break;

      // a block, but one that we dont actually care about
      case Mode.unimportantblock:
        if (state.workingStack.endsWith(COMMENT_START)) {
          state.mode = Mode.blockcomment;
          _resetStack();
        } else if (currentChar == "'") {
          state.mode = Mode.string;
          state.stringIsDouble = false;
        } else if (currentChar == '"') {
          state.mode = Mode.string;
          state.stringIsDouble = true;
        } else if (state.workingStack.endsWith(BLOCK_END)) {
          state.mode = Mode.toplevel;
          _resetStack();
        }
        break;

      // a block comment, this is where we need to finish prop parses :eyes:
      case Mode.blockcomment:
        if (state.workingStack.endsWith(COMMENT_END)) {
          if (state.lastMode == Mode.afterprop) {
            popLastWorkingStack(state, 2);
            trimStack(state);
            if (state.workingStack.startsWith(COMMENT_PREFIX)) {
              // we've found a setting! push to final data structure
              final rawTypeAndProps =
                  state.workingStack.substring(COMMENT_PREFIX.length);

              if (rawTypeAndProps.contains(SETTING_TYPE_PROPS_SEP)) {
                final typeAndProps =
                    rawTypeAndProps.split(SETTING_TYPE_PROPS_SEP);

                final type = typeAndProps[0].trim();
                final props = typeAndProps[1]
                    .split(SETTING_PROPS_SEP)
                    .map((i) => i.trim())
                    .toList();

                if (props.length == 1 || props[0] == "") {
                  throw ParserError(
                      "No props provided where `$SETTING_TYPE_PROPS_SEP` is present",
                      state);
                }

                _addProp(type, props);
              } else {
                _addProp(rawTypeAndProps);
              }
            }
            _resetStack();
            state.mode = Mode.block;
          } else {
            state.mode = state.lastMode;
            state.workingStack = state.blockCommentReturnStack;
            state.blockCommentReturnStack = "";
          }
        }
        break;

      // Strings are unique in that they parse into the stack as it was
      // before switching to that mode. They do not clear the stack after.
      // this mode is just here to force parsing forward until string end
      case Mode.string:
        final lastTwo = last(state.workingStack, 2);

        if (((lastTwo[1] == '"' && state.stringIsDouble) ||
                (lastTwo[1] == "'" && !state.stringIsDouble)) &&
            lastTwo[0] != '\\') {
          state.mode = state.lastMode;
        } else if (lastTwo[1] == "\n" && lastTwo[0] != "\\") {
          throw ParserError(
              "CSS multi line strings must \\ escape the newline", state);
        }
        break;
    }

    // on mode change, update last
    if (state.mode != thisModeTmp) {
      state.lastMode = thisModeTmp;
    }

    return true;
  }

  void _addProp(final String type, [final List<String> props = const []]) {
    if (!state.lastProp.contains(":")) {
      throw ParserError("prop did not contain a `:` character", state);
    }
    final propAndValue = state.lastProp.split(":");
    final propName = propAndValue[0].trim();
    final defaultVal = propAndValue[1].trim();

    Setting setting;
    switch (type) {
      case "text":
        setting = TextSetting(propName, defaultVal);
        break;

      // :SanOHYES:
      //case "colourpicker":
      case "colorpicker":
        setting = ColorPickerSetting(propName, defaultVal);
        break;

      case "dropdown":
        setting = DropdownSetting(propName, defaultVal, props);
        break;

      case "num":
        setting = _parseNum(propName, defaultVal, props, state);
        break;
      case "slider":
        setting = _parseNum(propName, defaultVal, props, state, true);
        break;

      default:
        throw ParserError("unknown setting type: $type", state);
    }

    // final mutated anyway via `add()` dart go brrrrr
    final working = state.blocks[state.lastSelector] ?? [];
    working.add(setting);
    state.blocks[state.lastSelector] = working;
  }
}

NumSetting _parseNum(
    String propName, String defaultVal, List<String> props, ParserState state,
    [bool slider = false]) {
  if (props.length != 3) {
    throw ParserError(
        "3 props must be present for a num: min, max, step", state);
  }

  final min = num.tryParse(props[0]);
  final max = num.tryParse(props[1]);
  final step = num.tryParse(props[2]);
  if (min == null || max == null || step == null) {
    throw ParserError("the props to num must be numbers", state);
  }

  final parsedVal = _parseCssValue(defaultVal, state);

  if (slider) {
    return SliderSetting(
        propName, parsedVal.first, parsedVal.second, max, min, step);
  }

  return NumSetting(
      propName, parsedVal.first, parsedVal.second, max, min, step);
}

Pair<num, String> _parseCssValue(String rawValue, ParserState state) {
  final tryParsedVal = num.tryParse(rawValue);
  if (tryParsedVal != null) {
    return Pair(tryParsedVal, "");
  } else {
    const units = ["px", "rem", "em", "vh", "vw", "%", "ms"];
    for (final unit in units) {
      if (rawValue.endsWith(unit)) {
        final refinedValue = popLast(rawValue, unit.length);
        final parsedValue = num.tryParse(refinedValue);
        if (parsedValue == null) {
          throw ParserError(
              "Value had unit `$unit`, but was not a number", state);
        }
        return Pair(parsedValue, unit);
      }
    }

    throw ParserError(
        "CSS value was neither unitless nor had an acceptable unit", state);
  }
}
