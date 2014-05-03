import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:unittest/unittest.dart";

void main() {
  testExpand();
  testName();
}

void testExpand() {
  String key;
  String value;
  if(Platform.isWindows) {
    key = r"$HOMEDRIVE$HOMEPATH";
    value = Platform.environment["HOMEDRIVE"];
    value += Platform.environment["HOMEPATH"];
  } else {
    key = r"$HOME";
    value = Platform.environment["HOME"];
  }

  value = FileUtils.fullpath(value);

  // $key
  var path = "$key";
  var result = FilePath.expand(path);
  var expected = value;
  expect(result, expected, reason: path);

  // $key/1
  path = "$key/1";
  result = FilePath.expand(path);
  expected = "$value/1";
  expect(result, expected, reason: path);

  // []$key]1
  path = "[]$key]1";
  result = FilePath.expand(path);
  expected = "[]$key]1";
  expect(result, expected, reason: path);

  // []$key]/1
  path = "[]$key]/1";
  result = FilePath.expand(path);
  expected = "[]$key]/1";
  expect(result, expected, reason: path);

  // [$key]$key/1
  path = "[$key]$key/1";
  result = FilePath.expand(path);
  expected = "[$key]$value/1";
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
  path = "${key}lower/1";
  var home = FilePath.expand("~");
  result = FilePath.expand(path);
  expected = "${home}lower/1";
  expect(result, expected, reason: path);
}

void testName() {
  var subject = "FilePath.name()";

  // .
  var path = ".";
  var result = FilePath.fullname(path);
  var current = FileUtils.getcwd();
  var expected = current;
  expect(result, expected, reason: "$subject, $path");

  // ..
  path = "..";
  result = FilePath.fullname(path);
  current = FileUtils.getcwd();
  expected = FileUtils.dirname(current);
  expect(result, expected, reason: "$subject, $path");

  // ./dir1
  path = "./dir1";
  result = FilePath.fullname(path);
  current = FileUtils.getcwd();
  expected = current + "/dir1";
  expect(result, expected, reason: "$subject, $path");

  // ./dir1/../../dir1
  path = "./dir1/../../dir1";
  result = FilePath.fullname(path);
  current = FileUtils.getcwd();
  expected = FileUtils.dirname(current) + "/dir1";
  expect(result, expected, reason: "$subject, $path");
}
