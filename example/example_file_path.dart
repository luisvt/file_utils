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
