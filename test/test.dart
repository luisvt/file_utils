import "dart:io";
import "package:file_utils/file_utils.dart";
import "package:path/path.dart" as pathos;
import "package:unittest/unittest.dart";

void main() {
  testBasename();
  testChdir();
  testDirEmpty();
  testDirname();
  testGetcwd();
  testGlob();
  testRemove();
  testRemoveDir();
  testSymlink();
  testTestfile();
  testTouch();
  testUptodate();
}

void testBasename() {
  var subject = "FileUtils.basename()";

  //
  if (Platform.isWindows) {
    testBasenameOnWindows();
  } else {
    testBasenameOnPosix();
  }

  //
  var tests = <List<String>>[];
  tests.add(["stdio.h", ".h", "stdio"]);
  tests.add(["stdio.h", ".cpp", "stdio.h"]);
  tests.add(["dir/file.name.ext", "ame.ext", "file.n"]);
  for (var test in tests) {
    var source = test[0];
    var suffix = test[1];
    var expected = test[2];
    var result = FileUtils.basename(source, suffix: suffix);
    expect(result, expected, reason:
        "$subject, source '$source', expected '$expected', got '$result'");
  }
}

void testBasenameOnPosix() {
  var subject = "FileUtils.basename()";

  //
  var tests = <List<String>>[];
  tests.add(["/", ""]);
  tests.add(["//", ""]);
  tests.add(["/1", "1"]);
  tests.add(["/1/", "1"]);
  tests.add(["/1//", "1"]);
  tests.add(["/1//2", "2"]);
  tests.add(["/1//2/", "2"]);
  tests.add(["/1//2//", "2"]);
  tests.add([".", "."]);
  tests.add(["", ""]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.basename(source);
    expect(result, expected, reason:
        "$subject, source '$source', expected '$expected', got '$result'");
  }
}

void testBasenameOnWindows() {
  var subject = "FileUtils.basename()";

  //
  var tests = <List<String>>[];
  tests.add([r"c:\", ""]);
  tests.add([r"c:\\", ""]);
  tests.add([r"\", ""]);
  // TODO:
  //tests.add([r"\\", ""]);
  tests.add([r"c:\1", "1"]);
  tests.add([r"c:\1\", "1"]);
  tests.add([r"c:\1\2", "2"]);
  tests.add([r"c:\1\2\", "2"]);
  tests.add([".", "."]);
  tests.add(["", ""]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.basename(source);
    expect(result, expected, reason:
        "$subject, source '$source', expected '$expected', got '$result'");
  }
}

void testChdir() {
  var subject = "FileUtils.chdir()";

  // Change directory to "."
  var source = ".";
  var expected = "test";
  FileUtils.chdir(source);
  var path = FileUtils.getcwd();
  var result = FileUtils.basename(path);
  expect(result, expected, reason: "$subject, '$source'");

  // Change directory to ".."
  source = "..";
  expected = "file_utils";
  FileUtils.chdir(source);
  path = FileUtils.getcwd();
  result = FileUtils.basename(path);
  expect(result, expected, reason: "$subject, '$source'");

  // Change directory to "test"
  source = "test";
  expected = "test";
  FileUtils.chdir(source);
  path = FileUtils.getcwd();
  result = FileUtils.basename(path);
  expect(result, expected, reason: "$subject, '$source'");
}

void testDirEmpty() {
  var subject = "FileUtils.dirEmpty()";

  // Empty directory
  FileUtils.rm(["dir"], recursive: true);
  FileUtils.mkdir(["dir"]);
  var result = FileUtils.dirempty("dir");
  expect(result, true, reason: "$subject, empty directory");

  // Non-empty directory
  FileUtils.mkdir(["dir/dir"]);
  result = FileUtils.dirempty("dir");
  expect(result, false, reason: "$subject, non-empty directory");

  // Non-exists directory
  FileUtils.rm(["dir"], recursive: true);
  result = FileUtils.dirempty("dir");
  expect(result, false, reason: "$subject, non-exists directory");
}

void testDirname() {
  var subject = "FileUtils.dirname()";

  //
  if (Platform.isWindows) {
    testDirnameWindows();
  } else {
    testDirnamePosix();
  }
}

void testDirnamePosix() {
  var subject = "FileUtils.dirname()";

  //
  var tests = <List<String>>[];
  tests.add(["/", "/"]);
  tests.add(["", "."]);
  tests.add(["1", "."]);
  tests.add(["1/", "."]);
  tests.add(["/1", "/"]);
  tests.add(["1/2", "1"]);
  tests.add(["1///2", "1"]);
  tests.add(["/1//2/", "/1"]);
  tests.add(["/1//2//", "/1"]);
  tests.add([".", "."]);
  tests.add(["", "."]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.dirname(source);
    expect(result, expected, reason:
        "$subject, source '$source', expected '$expected', got '$result'");
  }
}

void testDirnameWindows() {
  //
  var subject = "FileUtils.dirname()";

  //
  var tests = <List<String>>[];
  tests.add([r"C:\", r"C:/"]);
  tests.add([r"", "."]);
  tests.add([r"1", "."]);
  tests.add([r"1\", "."]);
  tests.add([r"\1", r"/"]);
  tests.add([r"1\2", "1"]);
  tests.add([r"1\\2", "1"]);
  tests.add([r"\1\2\", r"/1"]);
  tests.add([r"\1\\2\\", r"/1"]);
  tests.add([r"C:\1", r"C:/"]);
  tests.add([r"C:\1\2\", r"C:/1"]);
  tests.add([r"C:\1\2\\", r"C:/1"]);

  tests.add([".", "."]);
  tests.add(["", "."]);
  for (var test in tests) {
    var source = test[0];
    var expected = test[1];
    var result = FileUtils.dirname(source);
    expect(result, expected, reason:
        "$subject, source '$source', expected '$expected', got '$result'");
  }
}

void testGetcwd() {
  var subject = "FileUtils.getcwd()";

  // Get current directory
  var result = FileUtils.getcwd();
  result = FileUtils.basename(result);
  expect(result, "test", reason: subject);
}

void testGlob() {
  var subject = "FileUtils.glob()";

  // *.dart
  // Relative
  var files = FileUtils.glob("*.dart");
  var expected = ["test.dart"];
  var result = [];
  for (var file in files) {
    result.add(pathos.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: subject);

  // /home/user/dart/file_utils/test/*.dart
  // Absolute
  var path = FileUtils.dirname(Platform.script.toFilePath());
  var mask = path + "/*.dart";
  files = FileUtils.glob(mask);
  expected = ["test.dart"];
  result = [];
  for (var file in files) {
    result.add(pathos.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: subject);
}

void testRemove() {
  var subject = "FileUtils.rm()";

  // Remove file
  FileUtils.rm(["file"]);
  FileUtils.touch(["file"]);
  var result = FileUtils.rm(["file"]);
  expect(result, true, reason: "$subject, file");

  // Remove directory
  FileUtils.rm(["dir"], recursive: true);
  FileUtils.mkdir(["dir"]);
  result = FileUtils.rm(["dir"]);
  expect(result, false, reason: "$subject, directory");

  // Remove empty directory
  result = FileUtils.rm(["dir"], directory: true);
  expect(result, true, reason: "$subject, empty directory");

  // Remove non empty directory
  FileUtils.mkdir(["dir"]);
  FileUtils.touch(["dir/file"]);
  result = FileUtils.rm(["dir"], directory: true);
  expect(result, false, reason: "$subject, non empty directory");
  result = FileUtils.rm(["dir"], recursive: true);
  expect(result, true, reason: "$subject, non empty directory");

  // Remove non exists file
  result = FileUtils.rm(["non-exist"]);
  expect(result, false, reason: "$subject, non exists file");
  result = FileUtils.rm(["non-exist"], directory: true);
  expect(result, false, reason: "$subject, non exists file");
  result = FileUtils.rm(["non-exist"], recursive: true);
  expect(result, false, reason: "$subject, non exists file");
}

void testRemoveDir() {
  var subject = "FileUtils.rmdir()";

  // Remove file
  FileUtils.rm(["file"]);
  FileUtils.touch(["file"]);
  var result = FileUtils.rmdir(["file"]);
  expect(result, false, reason: "$subject, file");
  FileUtils.rm(["file"]);

  // Remove empty directory
  FileUtils.rm(["dir"], recursive: true);
  FileUtils.mkdir(["dir"]);
  result = FileUtils.rmdir(["dir"]);
  expect(result, true, reason: "$subject, empty directory");

  // Remove directory with file
  FileUtils.mkdir(["dir"]);
  FileUtils.touch(["dir/file"]);
  result = FileUtils.rmdir(["dir"]);
  expect(result, false, reason: "$subject, directory with file");
  FileUtils.rm(["dir/file"]);

  // Remove directory with only directory
  FileUtils.mkdir(["dir/dir"]);
  result = FileUtils.rmdir(["dir"], parents: true);
  expect(result, true, reason: "$subject, directory with only directory");
  FileUtils.rm(["dir"], recursive: true);

  // Remove non exists
  result = FileUtils.rmdir(["non-exists"]);
  expect(result, false, reason: "$subject, non exists");
}

void testSymlink() {
  var subject = "FileUtils.symlink()";

  if (Platform.isWindows) {
    testSymlinkOnWindows();
  } else {
    testSymlinkOnPosix();
  }
}

void testSymlinkOnPosix() {
  var subject = "FileUtils.symlink()";

  // Create symlink to file
  var target = "file";
  var link = "file.link";
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);
  FileUtils.touch([target]);
  var result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to file");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // File exists
  result = FileUtils.testfile(link, "file");
  expect(result, true, reason: "$subject, file exists");
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);

  // Create symlink to directory
  target = "dir";
  link = "dir.link";
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);
  FileUtils.mkdir([target]);
  result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to directory");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // Directory exists
  result = FileUtils.testfile(link, "directory");
  expect(result, true, reason: "$subject, directory exists");
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);
}

void testSymlinkOnWindows() {
  var subject = "FileUtils.symlink()";

  // Create symlink to directory
  var target = "dir";
  var link = "dir.link";
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);
  FileUtils.mkdir([target]);
  var result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to directory");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // Directory exists
  result = FileUtils.testfile(link, "directory");
  expect(result, true, reason: "$subject, directory exists");
  FileUtils.rm([target], recursive: true);
  FileUtils.rm([link], recursive: true);
}

void testTestfile() {
  var subject = "FileUtils.test()";

  // Test file
  var source = Platform.script.toFilePath();
  source = FileUtils.basename(source);
  var result = FileUtils.testfile(source, "file");
  expect(result, true, reason: "$subject, 'file'");
  result = FileUtils.testfile(source, "exists");
  expect(result, true, reason: "$subject, 'exists'");

  // Test directory
  source = Platform.script.toFilePath();
  source = FileUtils.dirname(source);
  result = FileUtils.testfile(source, "directory");
  expect(result, true, reason: "$subject, 'directory'");
  result = FileUtils.testfile(source, "exists");
  expect(result, true, reason: "$subject, 'exists'");

  // Test link
  source = "dir";
  var link = "dir.link";
  FileUtils.rm([source], recursive: true);
  FileUtils.mkdir([source]);
  FileUtils.symlink(source, link);
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, 'link'");
  FileUtils.rm([source], recursive: true);
  FileUtils.rm([link], recursive: true);
}

void testTouch() {
  var subject = "FileUtils.touch()";

  // Touch non exists bad file, create: true
  var dir = "dir";
  var file = "file";
  var path = "$dir/$file";
  FileUtils.rm([dir], recursive: true);
  var result = FileUtils.touch([path]);
  expect(result, false, reason: "$subject, non exists bad file");
  result = FileUtils.testfile(path, file);
  expect(result, false, reason: "$subject, non exists bad file");

  // Touch non exists good file, create: true
  FileUtils.mkdir([dir]);
  result = FileUtils.touch([path]);
  expect(result, true, reason: "$subject, non exists good file");
  result = FileUtils.testfile(path, file);
  expect(result, true, reason: "$subject, non exists good file");

  // Touch non exists bad file, create: false
  FileUtils.rm([dir], recursive: true);
  result = FileUtils.touch([path], create: false);
  expect(result, true, reason: "$subject, non exists bad file");
  result = FileUtils.testfile(path, file);
  expect(result, false, reason: "$subject, non exists bad file");

  // Touch non exists good file, create: false
  FileUtils.mkdir([dir]);
  result = FileUtils.touch([path], create: false);
  expect(result, true, reason: "$subject, non exists good file");
  result = FileUtils.testfile(path, file);
  expect(result, false, reason: "$subject, non exists good file");
  FileUtils.rm([dir], recursive: true);

  // Touch in subdirectory
  dir = "test";
  path = "$dir/$file";
  FileUtils.touch([file]);
  FileUtils.chdir("..");
  var stat1 = FileStat.statSync(path);
  // https://code.google.com/p/dart/issues/detail?id=18442
  wait(1000);
  FileUtils.touch([path]);
  var stat2 = FileStat.statSync(path);
  result = stat2.modified.compareTo(stat1.modified) > 0;
  expect(result, true, reason: "$subject, in subdirectory");
  FileUtils.chdir(dir);

  // Touch in current directory
  stat1 = FileStat.statSync(file);
  // https://code.google.com/p/dart/issues/detail?id=18442
  wait(1000);
  FileUtils.touch([file]);
  stat2 = FileStat.statSync(file);
  result = stat2.modified.compareTo(stat1.modified) > 0;
  expect(result, true, reason: "$subject, in current directory");

  FileUtils.rm([file]);
}

void testUptodate() {
  var subject = "FileUtils.uptodate()";

  // Non-existent file
  FileUtils.rm(["file1"]);
  var result = FileUtils.uptodate("file1");
  expect(result, false, reason: "$subject, non-existent");

  // Existent file
  FileUtils.touch(["file1"]);
  result = FileUtils.uptodate("file1");
  expect(result, true, reason: "$subject, existent file");

  // Existent and non-existent
  wait(1000);
  result = FileUtils.uptodate("file1", ["file2"]);
  expect(result, true, reason: "$subject, existent and non-existent");

  // Older and newer
  wait(1000);
  FileUtils.touch(["file2"]);
  result = FileUtils.uptodate("file1", ["file2"]);
  expect(result, false, reason: "$subject, older and newer");

  FileUtils.rm(["file1", "file2"]);
}

void wait(int milliseconds) {
  var sw = new Stopwatch();
  sw.start();
  while (sw.elapsedMilliseconds < milliseconds);
  sw.stop();
}
