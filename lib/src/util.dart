import 'package:cc_theme_settings_parser/src/parserstate.dart';

String last(String str, [int count = 1]) {
  if (str.length < count) count = str.length - 1;

  return str.substring(str.length - count);
}

String popLast(String str, [int count = 1]) {
  if (str.length < count) count = str.length;

  return str.substring(0, str.length - count);
}

void popLastWorkingStack(ParserState state, [int count = 1]) {
  state.workingStack = popLast(state.workingStack, count);
}
