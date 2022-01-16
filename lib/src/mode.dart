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
