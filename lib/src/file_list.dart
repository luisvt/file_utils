part of file_utils;

class FileList extends Object with ListMixin<String> {
  static final bool _isWindows = Platform.isWindows;

  final Directory directory;

  List<String> _files;

  String _pattern;

  FileList(this.directory, String pattern, {bool caseSensitive}) {
    if (directory == null) {
      throw new ArgumentError("directory: $directory");
    }

    if (pattern == null) {
      throw new ArgumentError("pattern: $pattern");
    }

    if (caseSensitive == null) {
      if (_isWindows) {
        caseSensitive = false;
      } else {
        caseSensitive = true;
      }
    }

    _pattern = FilePath.expand(pattern);
    _files = _getFiles();
  }

  /**
   * Returns the length.
   */
  int get length {
    return _files.length;
  }

  /**
   * Sets the length;
   */
  void set length(int length) {
    throw new UnsupportedError("length=");
  }

  String operator [](int index) {
    return _files[index];
  }

  void operator []=(int index, String value) {
    throw new UnsupportedError("[]=");
  }

  bool _exists(String path) {
    return FileStat.statSync(path).type != FileSystemEntityType.NOT_FOUND;
  }

  List<String> _getFiles() {
    var lister = new GlobLister(_pattern, exists: _exists, isDirectory:
        _isDirectory, isWindows: _isWindows, list: _list);
    return lister.list(directory.path);
  }

  bool _isDirectory(String path) {
    return FileStat.statSync(path).type == FileSystemEntityType.DIRECTORY;
  }

  List<String> _list(String path, bool followLinks) {
    List<String> result;
    try {
      result = new Directory(path).listSync(followLinks: followLinks).map((e) =>
          e.path).toList();
    } catch (e) {
      result = new List<String>();
    }

    return result;
  }
}
