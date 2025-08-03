import 'package:flutter/material.dart';
import 'package:svga_player_flutter/utils/platform_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'page/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (PlatFormUtils.isDesktop()) {
    // Must add this line.
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 700),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: HomeScreen());
  }
}
