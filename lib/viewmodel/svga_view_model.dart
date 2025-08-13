import '../includes.dart';
import '../theme/g_colors.dart';

class SvgaViewerModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _allowOverflow = true;
  bool get allowOverflow => _allowOverflow;

  double _width = 350;
  double get width => _width;

  double _height = 350;
  double get height => _height;

  double _containerWidth = 350;
  double get containerWidth => _containerWidth;

  double _containerHeight = 350;
  double get containerHeight => _containerHeight;

  double _scale = 1;
  double get scale => _scale;

  Color _backgroundColor = GColors.lightBlue;
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

  void setSize(double width, double height) {
    _width = width;
    _height = height;
    resetSize();
  }

  void changeContainerSize(double width, double height) {
    _containerWidth = width;
    _containerHeight = height;
    notifyListeners();
  }

  void zoomIn() {
    _scale += 0.1;
    if (_scale > 2) {
      _scale = 2;
    }
    _containerHeight = _width * _scale;
    _containerWidth = _height * _scale;
    notifyListeners();
  }

  void zoomOut() {
    _scale -= 0.1;
    if (_scale < 0.1) {
      _scale = 0.1;
    }
    _containerHeight = _width * _scale;
    _containerWidth = _height * _scale;
    notifyListeners();
  }

  void resetSize() {
    _containerWidth = _width;
    _containerHeight = _height;
    _scale = 1;
    notifyListeners();
  }

  void changeIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  String get scaleText {
    return '${(_scale * 100).toInt()}%';
  }
}
