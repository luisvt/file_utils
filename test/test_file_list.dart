import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:path/path.dart" as pathos;
import "package:unittest/unittest.dart";

void main() {
  testAbsolute();
  testCrossing();
  testOnlyDirectory();
  testRelative();
  testTilde();
}

void testAbsolute() {
  var mask = "lib/src/*.dart";
  var path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);
  mask = path + "/" +  mask;

  // Path "/home/user/dart/globbing"
  // Mask "/home/user/dart/globbing/lib/src/*.dart"

  // Absolute mask on Windows should be corrected because the "\" character
  // used as an escape character.
  if (Platform.isWindows) {
    mask = mask.replaceAll("\\", "/");
  }

  var files = new FileList(new Directory(path), mask);
  var expected = ["file_list.dart", "file_path.dart", "file_utils.dart"];
  var result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);
  path = pathos.rootPrefix(path);
  // Mask "/home/user/dart/globbing/lib/src/*.dart"
  files = new FileList(new Directory(path), mask);
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);
}

void testCrossing() {
  var mask = "**/unittest.dart";
  var path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);

  // Relative with crossing, starts with crossing
  // Path "/home/user/dart/globbing"
  // Mask "**/unittest.dart"
  var files = new FileList(new Directory(path), mask);
  // "globbing/packages/unittest/unittest.dart"
  // "globbing/example/packages/unittest/unittest.dart"
  // "globbing/test/packages/unittest/unittest.dart"
  var expected = ["unittest.dart", "unittest.dart", "unittest.dart"];
  var result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Relative with crossing, starts with non-crossing
  // Path "/home/user/dart/globbing"
  // Mask "test/**/unittest.dart"
  mask = "test/**/unittest.dart";
  files = new FileList(new Directory(path), mask);
  // "globbing/test/packages/unittest/unittest.dart"
  expected = ["unittest.dart"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Relative with crossing, starts with non-crossing, only directory
  // Path "/home/user/dart/globbing"
  // Mask "lib/**/"
  mask = "lib/**/";
  files = new FileList(new Directory(path), mask);
  // "globbing/lib/src"
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Absolute with crossing, starts with non-crossing
  // Path "/home/user/dart/globbing"
  // Mask "/home/user/dart/globbing/test/**/unittest.dart"
  mask = "test/**/unittest.dart";
  mask = path + "/" +  mask;
  files = new FileList(new Directory(path), mask);
  // "globbing/test/packages/unittest/unittest.dart"
  expected = ["unittest.dart"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Absolute with crossing, starts with non-crossing, only directory
  // Path "/home/user/dart/globbing"
  // Mask "/home/user/dart/globbing/lib/**/"
  mask = "lib/**/";
  mask = path + "/" +  mask;
  files = new FileList(new Directory(path), mask);
  // "globbing/test/packages/unittest/unittest.dart"
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);
}

void testOnlyDirectory() {
  var mask = "*/";
  var path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);

  // Path "/home/user/dart/globbing"
  // Mask "*/"
  // Relative
  var files = new FileList(new Directory(path), mask);
  var expected = ["example", "lib", "packages", "test"];
  var result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Path "/home/user/dart/globbing/lib"
  // Mask "**/"
  // Relative with crossing
  mask = "**/";
  path = path + "/" + "lib";
  files = new FileList(new Directory(path), mask);
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Path "/home/user/dart/globbing"
  // Mask "/home/user/dart/globbing/*/"
  // Absolute
  path = FileUtils.dirname(path);
  mask = path + "/*/";
  files = new FileList(new Directory(path), mask);
  expected = ["example", "lib", "packages", "test"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Path "/home/user/dart/globbing/lib"
  // Mask "/home/user/dart/globbing/lib/**/"
  // Absolute
  path = path + "/" + "lib";
  mask = path + "/**/";
  files = new FileList(new Directory(path), mask);
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);
}

void testRelative() {
  var mask = "lib/src/*.dart";
  var path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);

  // Path "/home/user/dart/globbing"
  // Mask "lib/src/*.dart"
  var files = new FileList(new Directory(path), mask);
  var expected = ["file_list.dart", "file_path.dart", "file_utils.dart"];
  var result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Asterisk, only dierctory
  mask = "lib/*/";
  path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);

  // Path "/home/user/dart/globbing"
  // Mask "lib/*/"
  files = new FileList(new Directory(path), mask);
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);

  // Strict, only dierctory
  mask = "lib/src/";
  path = Platform.script.toFilePath();
  path = FileUtils.fullpath(path);
  path = FileUtils.dirname(path);
  path = FileUtils.dirname(path);

  // Path "/home/user/dart/globbing"
  // Mask "lib/src/"
  files = new FileList(new Directory(path), mask);
  expected = ["src"];
  result = <String>[];
  for (var file in files) {
    result.add(FileUtils.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: mask);
}


void testTilde() {
  var mask = "~/*/";

  // Path "/"
  // Mask "~/*/"
  var home = FilePath.expand("~");
  if (home != null) {
    var files = new FileList(new Directory(home), mask);
    var result = !files.isEmpty;
    expect(result, true, reason: mask);
  }
}
