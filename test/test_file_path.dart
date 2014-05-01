import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:unittest/unittest.dart";

void main() {
  testExpand();
}

void testExpand() {
  String key;
  if(Platform.isWindows) {
    key = "HOMEPATH";
  } else {
    key = "HOME";
  }

  var value = Platform.environment[key];

  // $key
  var path = "\$${key}";
  var result = FilePath.expand(path);
  var expected = value;
  expect(result, expected, reason: path);

  // $key/1
  path = "\$${key}/1";
  result = FilePath.expand(path);
  expected = "$value/1";
  expect(result, expected, reason: path);

  // []$key]1
  path = "[]\$${key}]1";
  result = FilePath.expand(path);
  expected = "[]\$$key]1";
  expect(result, expected, reason: path);

  // []$key]/1
  path = "[]\$${key}]/1";
  result = FilePath.expand(path);
  expected = "[]\$$key]/1";
  expect(result, expected, reason: path);

  // [$key]$key/1
  path = "[\$${key}]\$$key/1";
  result = FilePath.expand(path);
  expected = "[\$$key]$value/1";
  expect(result, expected, reason: path);

  // $1
  path = "\$/1";
  result = FilePath.expand(path);
  expected = "\$/1";
  expect(result, expected, reason: path);

  // $/1
  path = "\$/1";
  result = FilePath.expand(path);
  expected = "\$/1";
  expect(result, expected, reason: path);

  // $lower_case/1
  path = "\$lower_case/1";
  result = FilePath.expand(path);
  expected = "\$lower_case/1";
  expect(result, expected, reason: path);

  // $1START_WITH_DIGIT/1
  path = "\$1START_WITH_DIGIT/1";
  result = FilePath.expand(path);
  expected = "\$1START_WITH_DIGIT/1";
  expect(result, expected, reason: path);

  // $HOMElower/1
  path = "\$${key}lower/1";
  var home = FilePath.expand("~");
  result = FilePath.expand(path);
  expected = "${home}lower/1";
  expect(result, expected, reason: path);
}