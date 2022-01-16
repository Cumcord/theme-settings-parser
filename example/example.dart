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
""";

void main() {
  final parser = Parser(css);
  while (parser.advance()) {}
  final parseResult = parser.blocks;
}
