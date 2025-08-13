import '../includes.dart';
import '../theme/g_colors.dart';

class SvgaViewerModel extends ChangeNotifier {
  static const double defaultSize = 350;

  bool _isLoading = true;

  bool get isLoading => _isLoading;

  bool _allowOverflow = true;

  bool get allowOverflow => _allowOverflow;

  double _width = defaultSize;

  double get width => _width;

  double _height = defaultSize;

  double get height => _height;

  double _containerWidth = defaultSize;

  double get containerWidth => _containerWidth;

  double _containerHeight = defaultSize;

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
    var ratio = width / height;
    if (ratio > 1) {
      _containerWidth = defaultSize;
      _containerHeight = defaultSize / ratio;
      _scale = defaultSize / _width;
    } else {
      _containerHeight = defaultSize;
      _containerWidth = defaultSize * ratio;
      _scale = defaultSize / _height;
    }
    notifyListeners();
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
    _containerWidth = _width * _scale;
    _containerHeight = _height * _scale;
    notifyListeners();
  }

  void zoomOut() {
    _scale -= 0.1;
    if (_scale < 0.1) {
      _scale = 0.1;
    }
    _containerWidth = _width * _scale;
    _containerHeight = _height * _scale;
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
