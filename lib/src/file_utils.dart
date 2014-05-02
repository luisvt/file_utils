part of file_utils;

class FileUtils {
  static final bool _isWindows = Platform.isWindows;

  /**
   * Removes any leading directory components from [name].
   *
   * If [suffix] is specified and it is identical to the end of [name], it is
   * removed from [name] as well.
   *
   * If [name] is null returns null.
   */
  static String basename(String name, {String suffix}) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return "";
    }

    var segments = pathos.split(name);
    if (pathos.isAbsolute(name)) {
      if (segments.length == 1) {
        return "";
      }
    }

    var result = segments.last;
    if (suffix != null && !suffix.isEmpty) {
      var index = result.lastIndexOf(suffix);
      if (index != -1) {
        result = result.substring(0, index);
      }
    }

    return result;
  }

  /**
   * Changes the current directory to [name]. Returns true if the operation was
   * successful; otherwise false.
   */
  static bool chdir(String name) {
    if (name == null || name.isEmpty) {
      return false;
    }

    name = FilePath.expand(name);
    var directory = new Directory(name);
    if (!directory.existsSync()) {
      return false;
    }

    try {
      Directory.current = directory;
    } catch (e) {
      return false;
    }

    return true;
  }

  /**
   * Returns true if directory is empty; otherwise false;
   */
  static bool dirempty(String name) {
    if (name == null) {
      return false;
    }

    name = FilePath.expand(name);
    var directory = new Directory(name);
    if (!directory.existsSync()) {
      return false;
    }

    return directory.listSync().length == 0;
  }

  /**
   * Returns [name] with its trailing component removed.
   *
   * If [name] does not contains the component separators returns '.' (meaning
   * the current directory).
   *
   * If [name] is null returns null.
   */
  static String dirname(String name) {
    if (name == null) {
      return null;
    }

    if (name.isEmpty) {
      return ".";
    }

    var segments = pathos.split(name);
    if (segments.length == 1) {
      if (pathos.isAbsolute(name)) {
        var rootPrefix = pathos.rootPrefix(name);
        if (_isWindows) {
          rootPrefix = rootPrefix.replaceAll("\\", "/");
        }

        return rootPrefix;
      } else {
        return ".";
      }
    }

    var result = pathos.dirname(name);
    if (_isWindows) {
      result = result.replaceAll("\\", "/");
    }

    return result;
  }

  /**
   * Returns the path of the current directory.
   */
  static String getcwd() {
    var path = Directory.current.path;
    if (_isWindows) {
      path = path.replaceAll("\\", "/");
    }

    return path;
  }

  /**
   * Returns a list of files which match the specified glob [pattern].
   */
  static List<String> glob(String pattern, {bool caseSensitive}) {
    if (pattern == null) {
      return null;
    }

    var isHome = false;
    if (pattern == "~") {
      isHome = true;
    } else if (pattern.startsWith("~/")) {
      isHome = true;
    }

    Directory directory;
    if (isHome) {
      var path = FilePath.expand("~");
      directory = new Directory(path);
    } else if (pathos.isAbsolute(pattern)) {
      // TODO: temporarily because slow to compile regex
      // Create fast glob parser
      var glob = new Glob(pattern);
      var parts = [];
      var segments = glob.segments;
      var length = segments.length;
      for (var i = 1; i < length; i++) {
        var segment = glob.segments[i];
        if (segment.strict) {
          parts.add(segment);
        } else {
          break;
        }
      }

      var path = segments.first.pattern + parts.join("/");
      directory = new Directory(path);
    } else {
      directory = Directory.current;
    }

    return new FileList(directory, pattern, caseSensitive: caseSensitive);
  }
  /**
   * Creates listed directories and returns true if the operation was
   * successful; otherwise false.
   *
   * If listed directories exists returns false.
   *
   * If [recursive] is set to true creates all required subdirectories and
   * returns true if not errors occured.
   */
  static bool mkdir(List<String> names, {bool recursive: false}) {
    if (names == null || names.isEmpty) {
      return false;
    }

    var result = true;
    for (var name in names) {
      name = name.toString();
      name = FilePath.expand(name);
      var directory = new Directory(name);
      var exists = directory.existsSync();
      if (exists) {
        if (!recursive) {
          result = false;
        }
      } else {
        try {
          directory.createSync(recursive: recursive);
        } catch (e) {
          result = false;
        }
      }
    }

    return result;
  }

  /**
   * Moves files [files] to the directory [dir]. Returns true if the operation
   * was successful; otherwise false.
   */
  static bool move(List<String> files, String dir) {
    if (files == null) {
      return false;
    }

    if (dir == null) {
      return false;
    }

    if (!testfile(dir, "directory")) {
      return false;
    }

    var result = true;
    for (var file in files) {
      if (file.isEmpty) {
        result = false;
        continue;
      }

      var list = glob(file);
      if (list.isEmpty) {
        result = false;
        continue;
      }

      for (var name in list) {
        var basename = FileUtils.basename(name);
        if (basename.isEmpty) {
          result = false;
          continue;
        }

        var dest = pathos.join(dir, basename);
        if (!rename(name, dest)) {
          result = false;
        }
      }
    }

    return result;
  }

  /**
   * Returns the full name of the path if possible.
   *
   * Resolves the following values:
   * - Leading '.' character indicating the current directory
   * - Leading '..' character indicating the parent directory
   * - Leading '~' character indicating the home directory
   * - Environment variables in IEEE Std 1003.1-2001 format, eg. $HOME/dart-sdk
   *
   * Useful when you get path name in a format incompatible with POSIX, and
   * intend to use it as part of the wildcard patterns.
   *
   * Do not use this method directly on wildcard patterns because it can deform
   * the patterns.
   */
  static String pathname(String name) {
    if (name.startsWith("..")) {
      var path = Directory.current.parent.path;
      if (name == "..") {
        name = path;
      } else if (name.startsWith("../")) {
        name = pathos.join(path, name.substring(3));
        name = pathos.normalize(name);
      } else {
        name = pathos.normalize(name);
      }

    } else if (name.startsWith(".")) {
      var path = Directory.current.path;
      if (name == ".") {
        name = path;
      } else if (name.startsWith("./")) {
        name = pathos.join(path, name.substring(2));
        name = pathos.normalize(name);
      } else {
        name = pathos.normalize(name);
      }

    } else {
      name = pathos.normalize(name);
    }

    name = FilePath.expand(name);
    if (_isWindows) {
      name = name.replaceAll("\\", "/");
    }

    return name;
  }

  /**
   * Renames or moves [src] to [dest]. Returns true if the operation was
   * successful; otherwise false.
   */
  static bool rename(String src, String dest) {
    if (src == null) {
      return false;
    }

    if (dest == null) {
      return false;
    }

    src = FilePath.expand(src);
    dest = FilePath.expand(dest);
    FileSystemEntity entity;
    switch (FileStat.statSync(src).type) {
      case FileSystemEntityType.DIRECTORY:
        entity = new Directory(src);
        break;
      case FileSystemEntityType.FILE:
        entity = new File(src);
        break;
      case FileSystemEntityType.LINK:
        entity = new Link(src);
        break;
    }

    if (entity == null) {
      return false;
    }

    try {
      entity.renameSync(dest);
    } catch (e) {
      return false;
    }

    return true;
  }

  /**
   * Removes the [files] and returns true if the operation was successful;
   * otherwise false.
   *
   * By default, it does not remove directories.
   *
   * If [directory] is set to true removes the directories if they are empty.
   *
   * If [force] is set to true ignores nonexistent files.
   *
   * If [recursive] is set to true remove the directories and their contents
   * recursively.
   */
  static bool rm(List<String> files, {bool directory: false, bool force:
      false, bool recursive: false}) {
    if (files == null || files.isEmpty) {
      return false;
    }

    var result = true;
    for (var file in files) {
      if (file.isEmpty) {
        if (!force) {
          result = false;
        }

        continue;
      }

      var list = glob(file);
      if (list.isEmpty) {
        if (!force) {
          result = false;
        }

        continue;
      }

      for (var name in list) {
        FileSystemEntity entity;
        var isDirectory = false;
        if (testfile(name, "link")) {
          entity = new Link(name);
        } else if (testfile(name, "file")) {
          entity = new File(name);
        } else if (testfile(name, "directory")) {
          entity = new Directory(name);
          isDirectory = true;
        }

        if (entity == null) {
          if (!force) {
            result = false;
          }
        } else {
          if (isDirectory) {
            if (recursive) {
              try {
                entity.deleteSync(recursive: recursive);
              } catch (e) {
                result = false;
              }
            } else if (directory) {
              result = rmdir([entity.path], parents: true);
            } else {
              result = false;
            }

          } else {
            try {
              entity.deleteSync();
            } catch (e) {
              result = false;
            }
          }
        }
      }
    }

    return result;
  }

  /**
   * Removes empty directories. Returns true if the operation was successful;
   * otherwise false.
   */
  static bool rmdir(List<String> names, {bool parents: false}) {
    Function canDelete;
    canDelete = (String name) {
      var directory = new Directory(name);
      for (var entry in directory.listSync()) {
        if (entry is File) {
          return false;
        } else if (entry is Link) {
          return false;
        } else if (entry is Directory) {
          if (!canDelete(entry.path)) {
            return false;
          }
        } else {
          return false;
        }
      }

      return true;
    };

    if (names == null || names.isEmpty) {
      return false;
    }

    var result = true;
    for (var name in names) {
      name = name.toString();
      if (name.isEmpty) {
        result = false;
        continue;
      }

      var list = glob(name);
      if (list.isEmpty) {
        result = false;
        continue;
      }

      for (var name in list) {
        if (testfile(name, "file")) {
          result = false;
          continue;
        } else if (testfile(name, "link")) {
          result = false;
          continue;
        } else if (!testfile(name, "directory")) {
          result = false;
          continue;
        }

        if (dirempty(name)) {
          try {
            new Directory(name).deleteSync();
          } catch (e) {
            result = false;
          }
        } else {
          if (parents) {
            if (!canDelete(name)) {
              result = false;
            } else {
              try {
                new Directory(name).deleteSync(recursive: true);
              } catch (e) {
                result = false;
              }
            }
          } else {
            result = false;
          }
        }
      }
    }

    return result;
  }

  /**
   * Creates the symbolic [link] to the [target] and returns true if the
   * operation was successful; otherwise false.
   *
   * If [target] does not exists returns false.
   *
   * IMPORTANT:
   * On the Windows platform, this will only work with directories.
   */
  static bool symlink(String target, String link) {
    if (target == null) {
      return false;
    }

    if (link == null) {
      return false;
    }

    target = FilePath.expand(target);
    link = FilePath.expand(link);
    if (_isWindows) {
      if (!testfile(target, "directory")) {
        return false;
      }
    } else {
      if (!testfile(target, "exists")) {
        return false;
      }
    }

    var symlink = new Link(link);
    try {
      symlink.createSync(target);
    } catch (e) {
      return false;
    }

    return true;
  }

  /**
   * Performs specified test on [file] and returns true if success; otherwise
   * returns false;
   *
   * Available test:
   * directory:
   *   [file] exists and is a directory.
   * exists:
   *   [file] exists.
   * file:
   *   [file] exists and is a regular file.
   * link:
   *   [file] exists and is a symbolic link.
   */
  static bool testfile(String file, String test) {
    if (file == null) {
      return false;
    }

    file = FilePath.expand(file);
    switch (test) {
      case "directory":
        return new Directory(file).existsSync();
      case "exists":
        return FileStat.statSync(file) != FileSystemEntityType.NOT_FOUND;
      case "file":
        return new File(file).existsSync();
      case "link":
        return new Link(file).existsSync();
      default:
        return null;
    }
  }


  /**
   * Changes the modification time of the specified [files]. Returns true if the
   * operation was successful; otherwise false.
   *
   * If [create] is set to true creates files that do not exist, reports failure
   * if the files can not be created.
   *
   * If [create] is set to false do not creates files that do not exist and do
   * not reports failure about files that do not exist.
   */
  static bool touch(List<String> files, {bool create: true}) {
    if (files == null || files.isEmpty) {
      return false;
    }

    var result = true;
    for (var file in files) {
      file = file.toString();
      if (file.isEmpty) {
        result = false;
        continue;
      }

      file = FilePath.expand(file);
      if (_isWindows) {
        if (!_touchOnWindows(file, create)) {
          result = false;
        }

      } else {
        if (!_touchOnPosix(file, create)) {
          result = false;
        }
      }
    }

    return result;
  }

  /**
   * Returns true if [name] is newer than all [other]; otherwise false.
   *
   * Non-existent files are older than any file.
   */
  static bool uptodate(String name, [List<String> other]) {
    if (name == null || name.isEmpty) {
      return false;
    }

    name = FilePath.expand(name);
    var stat = FileStat.statSync(name);
    if (stat.type == FileSystemEntityType.NOT_FOUND) {
      return false;
    }

    if (other == null) {
      return true;
    }

    var date = stat.modified;
    for (var name in other) {
      if (name.isEmpty) {
        continue;
      }

      var list = glob(name);
      if (list.isEmpty) {
        continue;
      }

      for (var name in list) {
        var stat = FileStat.statSync(name);
        if (stat.type != FileSystemEntityType.NOT_FOUND) {
          if (date.compareTo(stat.modified) < 0) {
            return false;
          }
        }
      }
    }

    return true;
  }

  static int _shell(String command, List<String> arguments, {String
      workingDirectory}) {
    return Process.runSync(command, arguments, runInShell: true,
        workingDirectory: workingDirectory).exitCode;
  }

  static bool _touchOnPosix(String name, bool create) {
    var arguments = <String>[name];
    if (!create) {
      arguments.add("-c");
    }

    return _shell("touch", arguments) == 0;
  }

  static bool _touchOnWindows(String name, bool create) {
    if (!testfile(name, "file")) {
      if (!create) {
        return true;
      } else {
        var file = new File(name);
        try {
          file.createSync();
          return true;
        } catch (e) {
          if (create) {
            return false;
          } else {
            return true;
          }
        }
      }
    }

    var dirName = dirname(name);
    String workingDirectory;
    if (!dirName.isEmpty) {
      name = basename(name);
      if (pathos.isAbsolute(dirName)) {
        workingDirectory = dirName;
      } else {
        workingDirectory = "${Directory.current.path}\\$dirName";
      }
    }

    return _shell("copy", ["/b", name, "+", ",", ","], workingDirectory:
        workingDirectory) == 0;
  }
}
