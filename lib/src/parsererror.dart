import 'package:cc_theme_settings_parser/src/parserstate.dart';

class _Pos {
  final int line;
  final int col;

  _Pos(this.line, this.col);
}

List<int> _calculateLineCounts(final String str) =>
    List.from(str.split("\n").map((s) => s.length));

_Pos _calculatePos(final List<int> lineCounts, final int rawPos) {
  var line = 0;
  var col = 0;
  var pos = rawPos;
  while (pos > 0) {
    if (lineCounts[line] < pos) {
      pos -= lineCounts[line];
      line++;
    } else {
      col = pos;
      pos = 0;
    }
  }

  return _Pos(line, col);
}

class ParserError extends Error {
  final String msg;
  final ParserState state;

  int get rawPos => state.pos;

  _Pos get pos => _calculatePos(_calculateLineCounts(state.input), rawPos);

  int get lineNum => pos.line;
  int get colNum => pos.col;

  ParserError(this.msg, this.state);
}
