file_utils
==========

File utils is a collection of the helper classes for file system.

Includes the following helpers:

- [FileList]
- [FilePath]
- [FileUtils]

**FileList**

Intelligent search of files with reduced amount of operations of disk access.

**FileUtils**

The collection of the helper methods for file system.

Includes the following methods:

- basename
- chdir
- dirempty
- dirname
- getcwd
- glob
- mkdir
- move
- rename
- rm
- rmdir
- symlink
- testfile
- touch
- uptodate

**FilePath**

The collection of the helper methods for file path.

Includes the following methods:

- expand

---

Examples of `FileList`:

```dart
import "dart:io";
import "package:file_utils/file_utils.dart";

void main() {
  // Find "unittest" packages in "pub cache"
  var pubCache = getPubCachePath();
  // Find "CHANGELOG" in "pub cache"
  if (pubCache != null) {
    var mask = "**/CHANGELOG*";
    var directory = new Directory(pubCache);
    var files = new FileList(directory, mask, caseSensitive: false);
    if (!files.isEmpty) {
      var list = files.toList();
      var length = list.length;
      print("Found $length 'CHANGELOG' files");
      for (var file in files) {
        print(file);
      }
    }
  }
}

String getPubCachePath() {
  var result = Platform.environment["PUB_CACHE"];
  if (result != null) {
    return result;
  }

  if (Platform.isWindows) {
    result = FilePath.expand(r"$APPDATA/Pub/Cache");
  } else {
    result = FilePath.expand("~/.pub-cache");
  }

  return result;
}
```

Examples of `FilePath`:

```dart
import "dart:io";
import "package:file_utils/file_utils.dart";

void main() {
  // Directories in home directory, include hidden
  var home = FilePath.expand("~");
  var directory = new Directory(home);
  var mask = "~/{.*,*}/";
  var files = new FileList(directory, mask);
  if (!files.isEmpty) {
    var list = files.toList();
    var length = list.length;
    print("Found $length directories in $home");
    for (var file in files) {
      print(file);
    }
  }
}
```

Examples of `FileUtils`:

```dart
import "dart:io";
import "package:file_utils/file_utils.dart";

void main() {
  // basename
  print("basename:");
  var path = FileUtils.getcwd();
  var name = FileUtils.basename(path);
  print("path: $path");
  print("name: $name");
  print("=============");

  // chdir
  print("chdir:");
  var save = FileUtils.getcwd();
  print("cwd: $save");

  FileUtils.chdir("..");
  path = FileUtils.getcwd();
  print("cwd: $path");

  FileUtils.chdir("~");
  path = FileUtils.getcwd();
  print("cwd: $path");

  FileUtils.chdir(save);
  path = FileUtils.getcwd();
  print("cwd: $path");
  print("=============");

  // dirempty
  print("dirempty:");

  var empty = FileUtils.dirempty(".");
  print("path: .");
  print("empty: $empty");

  FileUtils.mkdir(["temp"]);
  empty = FileUtils.dirempty("temp");
  print("path: temp");
  print("empty: $empty");
  FileUtils.rmdir(["temp"]);
  print("=============");

  // dirname
  print("dirname:");
  path = FileUtils.getcwd();
  name = FileUtils.dirname(path);
  print("path: $path");
  print("name: $name");
  print("=============");

  // getcwd
  print("getcwd:");
  path = FileUtils.getcwd();
  print("cwd: $path");
  print("=============");

  // glob
  print("glob:");
  save = FileUtils.getcwd();
  FileUtils.chdir("..");
  var dirs = FileUtils.glob("*/");
  dirs = dirs.map((e) => FileUtils.basename(e));
  print("glob: $dirs");
  FileUtils.chdir(save);
  print("=============");

  // mkdir
  print("mkdir:");
  FileUtils.mkdir(["temp"]);
  FileUtils.chdir("temp");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp"]);
  print("=============");

  // move
  print("move:");
  FileUtils.mkdir(["temp1", "temp2"]);
  FileUtils.touch(["temp1/file.txt"]);
  FileUtils.move(["temp1/*.txt"], "temp2");

  var files = FileUtils.glob("temp1/*.txt");
  files = files.map((e) => FileUtils.basename(e));
  print("path: temp1");
  print("files: $files");

  files = FileUtils.glob("temp2/*.txt");
  files = files.map((e) => FileUtils.basename(e));
  print("path: temp2");
  print("files: $files");

  FileUtils.rm(["temp1", "temp2"], recursive: true);
  print("=============");

  // rename
  print("rename:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.rename("temp1", "temp2");
  FileUtils.chdir("temp2");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp2"]);
  print("=============");

  // rm
  print("rm:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.chdir("temp1");
  FileUtils.touch(["temp1/file.txt"]);
  path = FileUtils.chdir("..");
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");

  // rmdir
  print("rmdir:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.chdir("temp1");
  FileUtils.chdir("..");
  FileUtils.rmdir(["temp1"]);
  print("=============");

  // symlink
  print("symlink:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.symlink("temp1", "temp2");
  FileUtils.chdir("temp2");
  path = FileUtils.getcwd();
  print("cwd: $path");
  FileUtils.chdir("..");
  FileUtils.rm(["temp1", "temp2"], recursive: true);
  print("=============");

  // testfile
  print("testfile:");
  FileUtils.mkdir(["temp1"]);
  var exists = FileUtils.testfile("temp1", "directory");
  print("path: temp1");
  print("exists: $exists");
  FileUtils.rmdir(["temp1"]);
  print("=============");

  // touch
  print("touch:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.touch(["temp1/file1.txt"]);
  exists = FileUtils.testfile("temp1/file1.txt", "file");
  print("path: temp1/file1.txt");
  print("exists: $exists");
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");

  // uptodate
  print("uptodate:");
  FileUtils.mkdir(["temp1"]);
  FileUtils.touch(["temp1/file1.txt"]);
  print("wait...");
  sleep(new Duration(milliseconds: 1000));
  FileUtils.touch(["temp1/file2.txt"]);
  var uptodate = FileUtils.uptodate("temp1/file1.txt", ["temp1/file2.txt"]);
  print("path: temp1/file1.txt");
  print("uptodate: $uptodate");
  FileUtils.rm(["temp1"], recursive: true);
  print("=============");
}
```

[FileList]: https://github.com/mezoni/file_utils/blob/master/lib/src/file_list.dart
[FilePath]: https://github.com/mezoni/file_utils/blob/master/lib/src/file_path.dart
[FileUtils]: https://github.com/mezoni/file_utils/blob/master/lib/src/file_utils.dart
