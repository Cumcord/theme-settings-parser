enum Mode {
  toplevel,
  topcomment,
  // if a comment is not `/* cc:settings */` then we return to toplevel.
  selector,
  block,
  // after a ; - if followed by a comment then to blockcomment and keep parsing
  // else advance to the next prop (Mode.block)
  afterprop,
  blockcomment,
  // blocks that aren't marked with cc:settings
  unimportantblock,
  string,
}
