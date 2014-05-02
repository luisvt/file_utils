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
  testMakeDir();
  testMove();
  testPathName();
  testRemove();
  testRemoveDir();
  testRename();
  testSymlink();
  testTestfile();
  testTouch();
  testUptodate();
}

void clean() {
  FileUtils.rm(["file*", "dir*"], recursive: true);
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

  // Change directory to "~"
  var restore = FileUtils.getcwd();
  result = FileUtils.chdir("~");
  expect(result, true, reason: "$subject, '~'");
  FileUtils.chdir(restore);

  // Change directory to "~/"
  restore = FileUtils.getcwd();
  result = FileUtils.chdir("~/");
  expect(result, true, reason: "$subject, '~/'");
  FileUtils.chdir(restore);

  // Change to subdirectory of "~"
  restore = FileUtils.getcwd();
  FileUtils.chdir("~/");
  var home = FileUtils.getcwd();
  var mask = pathos.join(home, "*/");
  var dirs = FileUtils.glob(mask);
  for (var dir in dirs) {
    var name = FileUtils.basename(dir);
    var path = "~/$name";
    result = FileUtils.chdir(path);
    expect(result, true, reason: "$subject, '$path'");
    FileUtils.chdir("..");
  }

  FileUtils.chdir(restore);
}

void testDirEmpty() {
  var subject = "FileUtils.dirEmpty()";

  // Clean
  clean();

  // Empty directory
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

  // Clean
  clean();
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
  var expected = ["test_file_list.dart", "test_file_path.dart",
      "test_file_utils.dart"];
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
  result = [];
  for (var file in files) {
    result.add(pathos.basename(file));
  }

  result.sort((a, b) => a.compareTo(b));
  expect(result, expected, reason: subject);

  // ~/*/
  // Home
  mask = "~/*/";
  files = FileUtils.glob(mask);
  result = !files.isEmpty;
  expect(result, true, reason: subject);
}

void testMakeDir() {
  var subject = "FileUtils.mkdir()";

  // Clean
  clean();

  // Make dir
  var result = FileUtils.mkdir(["dir1"]);
  expect(result, true, reason: "$subject, move files");

  // Clean
  clean();
}

void testMove() {
  var subject = "FileUtils.move()";

  // Clean
  clean();

  // Move files
  FileUtils.mkdir(["dir1", "dir2"]);
  FileUtils.touch(["dir1/file1.txt", "dir1/file2.txt"]);
  var result = FileUtils.move(["dir1/*.txt"], "dir2");
  expect(result, true, reason: "$subject, move files");
  result = FileUtils.dirempty("dir1");
  expect(result, true, reason: "$subject, move files");
  result = FileUtils.dirempty("dir2");
  expect(result, false, reason: "$subject, move files");

  // Clean
  clean();
}

void testPathName() {
  var subject = "FileUtils.pathname()";

  // Clean
  clean();

  // '.'
  var result = FileUtils.pathname(".");
  var expected = FileUtils.getcwd();
  expect(result, expected, reason: "$subject, '.'");

  // './'
  result = FileUtils.pathname("./");
  expected = FileUtils.getcwd();
  expect(result, expected, reason: "$subject, './'");

  // './test'
  result = FileUtils.pathname("./test");
  expected = FileUtils.getcwd() + "/test";
  expect(result, expected, reason: "$subject, './test'");

  // '.test'
  result = FileUtils.pathname(".test");
  expected = ".test";
  expect(result, expected, reason: "$subject, '.test'");

  // '..'
  result = FileUtils.pathname("..");
  var save = FileUtils.getcwd();
  FileUtils.chdir("..");
  expected = FileUtils.getcwd();
  FileUtils.chdir(save);
  expect(result, expected, reason: "$subject, '..'");

  // '../'
  result = FileUtils.pathname("../");
  save = FileUtils.getcwd();
  FileUtils.chdir("..");
  expected = FileUtils.getcwd();
  FileUtils.chdir(save);
  expect(result, expected, reason: "$subject, '../'");

  // '../test'
  result = FileUtils.pathname("../test");
  save = FileUtils.getcwd();
  FileUtils.chdir("..");
  expected = FileUtils.getcwd() + "/test";
  FileUtils.chdir(save);
  expect(result, expected, reason: "$subject, '../test'");

  // '..test'
  result = FileUtils.pathname("..test");
  expected = "..test";
  expect(result, expected, reason: "$subject, '..test'");

  // '~'
  result = FileUtils.pathname("~");
  expected = FilePath.expand("~");
  expect(result, expected, reason: "$subject, '~'");

  // Clean
  clean();
}

void testRemove() {
  var subject = "FileUtils.rm()";

  // Clean
  clean();

  // Remove file
  FileUtils.touch(["file"]);
  var result = FileUtils.rm(["file"]);
  expect(result, true, reason: "$subject, file");

  // Remove directory
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
  result = FileUtils.rm(["non-exist"], force: true);
  expect(result, true, reason: "$subject, non exists file");

  // Clean
  clean();
}

void testRemoveDir() {
  var subject = "FileUtils.rmdir()";

  // Clean
  clean();

  // Remove file
  FileUtils.touch(["file"]);
  var result = FileUtils.rmdir(["file"]);
  expect(result, false, reason: "$subject, file");
  FileUtils.rm(["file"]);

  // Remove empty directory
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

  // Clean
  clean();
}

void testRename() {
  var subject = "FileUtils.rename()";

  // Clean
  clean();

  // Rename file
  FileUtils.touch(["file1"]);
  var result = FileUtils.rename("file1", "file2");
  expect(result, true, reason: "$subject, rename file");
  result = FileUtils.testfile("file1", "file");
  expect(result, false, reason: "$subject, rename file");
  result = FileUtils.testfile("file2", "file");
  expect(result, true, reason: "$subject, rename file");

  // Clean
  clean();

  // Move file
  FileUtils.touch(["file1"]);
  FileUtils.mkdir(["dir"]);
  result = FileUtils.rename("file1", "dir/file");
  expect(result, true, reason: "$subject, move file");
  result = FileUtils.testfile("file", "file");
  expect(result, false, reason: "$subject, rename file");
  result = FileUtils.testfile("dir/file", "file");
  expect(result, true, reason: "$subject, rename file");


  // Clean
  clean();

  // Move directory
  FileUtils.mkdir(["dir1"]);
  FileUtils.mkdir(["dir2"]);
  FileUtils.touch(["dir1/file1"]);
  result = FileUtils.rename("dir1", "dir2/dir3");
  expect(result, true, reason: "$subject, move director");
  result = FileUtils.testfile("dir2/dir3", "directory");
  expect(result, true, reason: "$subject, rename director");
  result = FileUtils.testfile("dir2/dir3/file1", "file");
  expect(result, true, reason: "$subject, rename director");
  result = FileUtils.testfile("dir1", "directory");
  expect(result, false, reason: "$subject, rename file");
  FileUtils.rm(["dir2"], recursive: true);

  // Clean
  clean();

  // TODO: test move link
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

  // Clean
  clean();

  // Create symlink to file
  var target = "file";
  var link = "file.link";
  FileUtils.touch([target]);
  var result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to file");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // File exists
  result = FileUtils.testfile(link, "file");
  expect(result, true, reason: "$subject, file exists");

  // Clean
  clean();

  // Create symlink to directory
  target = "dir";
  link = "dir.link";
  FileUtils.mkdir([target]);
  result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to directory");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // Directory exists
  result = FileUtils.testfile(link, "directory");
  expect(result, true, reason: "$subject, directory exists");

  // Clean
  clean();
}

void testSymlinkOnWindows() {
  var subject = "FileUtils.symlink()";

  // Clean
  clean();

  // Create symlink to directory
  var target = "dir";
  var link = "dir.link";
  FileUtils.mkdir([target]);
  var result = FileUtils.symlink(target, link);
  expect(result, true, reason: "$subject, create symlink to directory");

  // Symlink exists
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, symlink exists");

  // Directory exists
  result = FileUtils.testfile(link, "directory");
  expect(result, true, reason: "$subject, directory exists");

  // Clean
  clean();
}

void testTestfile() {
  var subject = "FileUtils.test()";

  // Clean
  clean();

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
  FileUtils.mkdir([source]);
  FileUtils.symlink(source, link);
  result = FileUtils.testfile(link, "link");
  expect(result, true, reason: "$subject, 'link'");

  // Clean
  clean();
}

void testTouch() {
  var subject = "FileUtils.touch()";

  // Clean
  clean();

  // Touch non exists bad file, create: true
  var dir = "dir";
  var file = "file";
  var path = "$dir/$file";
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

  // Clean
  clean();

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

  // Clean
  clean();
}

void testUptodate() {
  var subject = "FileUtils.uptodate()";

  // Clean
  clean();

  // Non-existent file
  var result = FileUtils.uptodate("file1");
  expect(result, false, reason: "$subject, non-existent");

  // Existent file
  FileUtils.touch(["file1"]);
  result = FileUtils.uptodate("file1");
  expect(result, true, reason: "$subject, existent file");

  // Existent and non-existent
  result = FileUtils.uptodate("file1", ["file2"]);
  expect(result, true, reason: "$subject, existent and non-existent");

  // Older and newer
  wait(1000);
  FileUtils.touch(["file2"]);
  result = FileUtils.uptodate("file1", ["file2"]);
  expect(result, false, reason: "$subject, older and newer");

  // Clean
  clean();
}

void wait(int milliseconds) {
  var sw = new Stopwatch();
  sw.start();
  while (sw.elapsedMilliseconds < milliseconds);
  sw.stop();
}
