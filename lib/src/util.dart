import 'package:cc_theme_settings_parser/index.dart';
import 'package:cc_theme_settings_parser/src/parserstate.dart';

/// returns the last [count] characters of [str]
String last(String str, [int count = 1]) {
  if (str.length < count) count = str.length - 1;

  return str.substring(str.length - count);
}

/// returns all but the last [count] characters of [str]
String popLast(String str, [int count = 1]) {
  if (str.length < count) count = str.length;

  return str.substring(0, str.length - count);
}

/// removes the last [count] characters from the stack
void popLastWorkingStack(ParserState state, [int count = 1]) {
  state.workingStack = popLast(state.workingStack, count);
}

/// trims whitespace off the start and end of the stack
void trimStack(ParserState state) {
  state.workingStack = state.workingStack.trim();
}

/// the selector be minified doe
String minifySelector(String selector) {
  while (selector.contains("\n")) {
    selector = selector.replaceAll("\n", " ");
  }

  while (selector.contains("  ")) {
    selector = selector.replaceAll("  ", " ");
  }

  selector = selector.replaceAll(" > ", ">");

  return selector;
}
