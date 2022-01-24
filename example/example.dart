import 'package:cc_theme_settings_parser/index.dart';

const css = """
/* a normal comment */
.no-settings-block {
  color: red;
}

/* cc:settings */
.settings
#block {
  margin: 1rem; /* cc:slider: 0,100,20; units: rem,px,% */
  /* fun idea - cc:slider: 0,100,20; units: rem,px,% */
  content: "aaa"; /* cc:text */
  color: red; /* cc:colorpicker */
  background-color: green; /* cc:dropdown: #fbc, green, #ffd */
}

.block::before {
  content: "i escaped\\
the newline";
}
""";

void main() {
  final parser = Parser(css);
  final parseResult = parser.parseToEnd();
}
