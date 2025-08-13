
import '../includes.dart';

class SvgaViewerModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _allowOverflow = true;
  bool get allowOverflow => _allowOverflow;

  double _containerWidth = 350;
  double get containerWidth => _containerWidth;

  double _containerHeight = 350;
  double get containerHeight => _containerHeight;

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  BoxFit _boxFit = BoxFit.contain;
  BoxFit get boxFit => _boxFit;

  void changeBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void changeBoxFit(BoxFit boxFit) {
    _boxFit = boxFit;
    notifyListeners();
  }

  void changeAllowOverflow(bool allowOverflow) {
    _allowOverflow = allowOverflow;
    notifyListeners();
  }

  void changeContainerSize(double width, double height) {
    _containerWidth = width;
    _containerHeight = height;
    notifyListeners();
  }

  void changeIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

}