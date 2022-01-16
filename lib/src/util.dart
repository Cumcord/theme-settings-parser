String last(String str, [int count = 1]) {
  if (str.length < count) count = str.length - 1;

  return str.substring(str.length - count);
}

String popLast(String str, [int count = 1]) {
  if (str.length < count) count = str.length;

  return str.substring(0, str.length - count);
}
