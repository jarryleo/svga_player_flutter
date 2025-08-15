import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:svga_viewer/utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatFormUtils.isDesktop()) {
    // Must add this line.
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(900, 600),
      center: true,
      skipTaskbar: false,
      title: "SVGA Viewer (by: Jarry Leo)",
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  // 解析命令行参数
  final parser = ArgParser();
  final results = parser.parse(args);
  String filePath = args.firstWhere((element) => element.endsWith(".svga"), orElse: () => '');
  if (filePath.isEmpty && results.rest.isNotEmpty) {
    filePath = results.rest.first;
  }
  runApp(MainApp(initialFile: filePath));
}
