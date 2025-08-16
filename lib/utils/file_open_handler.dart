import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FileOpenHandler {
  static const platform = MethodChannel('cn.leo/fileOpen');

  static Future<void> setupFileOpenListener(Function(String) handleOpenedFile) async {
    platform.setMethodCallHandler((call) async {
      try {
        if (call.method == 'openFile') {
          if (call.arguments is String) {
            final String filePath = call.arguments;
            if (filePath.isNotEmpty) {
              handleOpenedFile(filePath);
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error handling file open: $e');
        }
      }
    });
  }
}