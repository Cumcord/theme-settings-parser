import 'package:cc_theme_settings_parser/index.dart';

const css = """
/* a normal comment */
.no-settings-block {
  color: red;
}

/* cc:settings */
.settings
#block {
  margin: 1rem;
}

/* for fun, here's a parser error */
.block::before {
  content: "i didnt escape
the newline";
}
""";

void main() {
  final parser = Parser(css);
  final parseResult = parser.parseToEnd();
}
