import '../includes.dart';
import 'file_item.dart';

class SvgaFileListModel extends ChangeNotifier {
  final List<FileItem> _list = [];

  List<FileItem> get list => _list;

  void add(FileItem item) {
    _list.removeWhere((old) => old.path == item.path);
    _list.insert(0,item);
    notifyListeners();
  }

  void addAll(List<FileItem> items) {
    _list.removeWhere((old) => items.any((newItem) => newItem.path == old.path));
    _list.insertAll(0, items);
    notifyListeners();
  }

  void remove(FileItem item) {
    _list.remove(item);
    notifyListeners();
  }

  void clear() {
    _list.clear();
    notifyListeners();
  }
}
