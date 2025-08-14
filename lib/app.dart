import 'package:svga_viewer/page/main_page.dart';

import 'includes.dart';

class MainApp extends StatelessWidget {
  final String? initialFile;

  const MainApp({super.key, this.initialFile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: MainPage(initialFile: initialFile),
    );
  }
}
