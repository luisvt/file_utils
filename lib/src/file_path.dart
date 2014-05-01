part of file_utils;

class FilePath {
  static final bool _isWindows = Platform.isWindows;

  /**
   * Returns the expanded [path].
   *
   * Expands the following parts:
   *  - Environment variables (IEEE Std 1003.1-2001), eg. $HOME/dart-sdk/pub
   *  - Home directory of the current user, eg ~/dart-sdk/pub
   */
  static String expand(String path) {
    if (path == null || path.isEmpty) {
      return path;
    }

    path = _expand(path);
    if (path[0] != "~") {
      return path;
    }

    String home;
    if (_isWindows) {
      var drive = Platform.environment["HOMEDRIVE"];
      var path = Platform.environment["HOMEPATH"];
      if (drive != null && !drive.isEmpty && path != null && !path.isEmpty) {
        home = drive + path;
      } else {
        home = Platform.environment["USERPROFILE"];
        if (home == null || home.isEmpty) {
          home = Platform.environment["USERPROFILE"];
        }
      }

    } else {
      home = Platform.environment["HOME"];
    }

    if (home == null || home.isEmpty) {
      return path;
    }

    if (home.endsWith("/") || home.endsWith("\\")) {
      home = home.substring(0, home.length - 1);
    }

    if (path == "~" || path == "~/") {
      return home;
    }

    if (path.startsWith("~/")) {
      return home + "/" + path.substring(2);
    }

    return path;
  }

  static String _expand(String path) {
    var sb = new StringBuffer();
    var length = path.length;
    for (var i = 0; i < length; i++) {
      var s = path[i];
      switch (s) {
        case "\$":
          if (i + 1 < length) {
            var pos = i + 1;
            var c = path.codeUnitAt(pos);
            if ((c >= 65 && c <= 90) || c == 95) {
              while (true) {
                if (pos == length) {
                  break;
                }

                var c = path.codeUnitAt(pos);
                if ((c >= 65 && c <= 90) || (c >= 48 && c <= 57) || c == 95) {
                  pos++;
                  continue;
                }

                break;
              }
            }

            if (pos > i + 1) {
              var key = path.substring(i + 1, pos);
              var value = Platform.environment[key];
              if (value == null) {
                value = "";
              }

              sb.write(value);
              i = pos - 1;
            } else {
              sb.write(s);
            }

          } else {
            sb.write(s);
          }

          break;
        case "[":
          sb.write(s);
          if (i + 1 < length) {
            s = path[++i];
            sb.write(s);
            while (true) {
              if (i == length) {
                break;
              }

              s = path[++i];
              sb.write(s);
              if (s == "]") {
                break;
              }
            }
          }

          break;
        default:
          sb.write(s);
          break;
      }
    }

    return sb.toString();
  }
}
