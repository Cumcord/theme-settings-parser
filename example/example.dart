import 'package:cc_theme_settings_parser/index.dart';

const css = """
/* a normal comment */
.no-settings-block {
  color: red;
}

/* cc:settings */
.settings
#block {
  margin: 1rem;            /* cc:slider: 0,100,20 */
  content: "aaa";          /* cc:text */
  color: red;              /* cc:colorpicker */
  background-color: green; /* cc:dropdown: #fbc, green, #ffd */
}

.block::before {
  /* should be ignored */
  font-size: 50px; /* cc:num: 15, 75, 5.674 */

  content: "i escaped\\
the newline";
}

/* cc:settings */
.block::after {
  color: white; /* test a normal comment */

  font-size: 50px; /* cc:num: 15, 75, 5.674 */
}
""";

void main() {
  final parser = Parser(css);
  final parseResult = parser.parseToEnd();
  print(parseResult);
}
