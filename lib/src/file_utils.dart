part of file_utils;

class FileUtils {
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

    if (Platform.isWindows) {
      name = name.replaceAll("\\", "/");
    }

    var segments = pathos.split(name);
    if (segments.length == 1) {
      if (pathos.isAbsolute(name)) {
        return pathos.rootPrefix(name);
      } else {
        return ".";
      }
    }

    var result = pathos.dirname(name);
    return result;
  }

  /**
   * Returns the path of the current directory.
   */
  static String getcwd() {
    return Directory.current.path;
  }

  /**
   * Returns a list of files which match the specified glob [pattern].
   */
  static List<String> glob(String pattern, {bool caseSensitive}) {
    var isAbsolute = pathos.isAbsolute(pattern);
    Directory directory;
    if (isAbsolute) {
      var path = pathos.rootPrefix(pattern);
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
    for (var name in files) {
      name = name.toString();
      if (name.isEmpty) {
        result = false;
        continue;
      }

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
        if (isDirectory && (!directory && !recursive)) {
          result = false;
        } else {
          try {
            entity.deleteSync(recursive: recursive);
          } catch (e) {
            result = false;
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

    if (Platform.isWindows) {
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

      if (Platform.isWindows) {
        if(!_touchOnWindows(file, create)) {
          result = false;
        }

      } else {
        if(!_touchOnPosix(file, create)) {
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
    if(name == null || name.isEmpty) {
      return false;
    }

    var stat = FileStat.statSync(name);
    if(stat.type == FileSystemEntityType.NOT_FOUND) {
      return false;
    }

    if(other == null) {
      return true;
    }

    var date = stat.modified;
    for(var name in other) {
      var stat = FileStat.statSync(name);
      if(stat.type != FileSystemEntityType.NOT_FOUND) {
        if(date.compareTo(stat.modified) < 0) {
          return false;
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
