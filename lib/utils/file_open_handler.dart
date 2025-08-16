import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FileOpenHandler {
  static const platform = MethodChannel('cn.leo/fileOpen');

  static Future<void> setupFileOpenListener(Function(List<String>) handleOpenedFiles) async {
    platform.setMethodCallHandler((call) async {
      try {
        if (call.method == 'openFile') {
          if (call.arguments is List) {
            // 处理字符串数组
            final List<dynamic> filePaths = call.arguments;
            final List<String> validFilePaths = [];

            for (var filePath in filePaths) {
              if (filePath is String && filePath.isNotEmpty) {
                validFilePaths.add(filePath);
              }
            }

            if (validFilePaths.isNotEmpty) {
              handleOpenedFiles(validFilePaths);
            }
          } else if (call.arguments is String) {
            // 保持对单个字符串的兼容性
            final String filePath = call.arguments;
            if (filePath.isNotEmpty) {
              handleOpenedFiles([filePath]);
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
