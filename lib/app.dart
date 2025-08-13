import 'package:svga_viewer/page/main_page.dart';

import 'includes.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: MainPage(),
    );
  }
}
