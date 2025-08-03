
import 'package:flutter/material.dart';
import 'package:svga_player_flutter/svga_viewer.dart';
import 'package:svga_player_flutter/svgaplayer/svgaplayer_flutter.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  final samples = const <String>[
    "assets/angel.svga",
    "assets/pin_jump.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/EmptyState.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/HamburgerArrow.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/PinJump.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/TwitterHeart.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/Walkthrough.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/kingset.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/halloween.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/heartbeat.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteBitmap.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteBitmap_1.x.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/matteRect.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/mutiMatte.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/posche.svga",
    "https://cdn.jsdelivr.net/gh/svga/SVGA-Samples@master/rose.svga",
  ].map((e) => [e.split('/').last, e]).toList(growable: false);

  // callback for register dynamicItem
  final dynamicSamples = <String, void Function(MovieEntity entity)>{
    "kingset.svga": (entity) => entity.dynamicItem
      ..setText(
          TextPainter(
              text: const TextSpan(
                  text: "Hello, World!",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ))),
          "banner")
    // ..setImageWithUrl(
    //     "https://github.com/PonyCui/resources/blob/master/svga_replace_avatar.png?raw=true",
    //     "99")
    // ..setDynamicDrawer((canvas, frameIndex) {
    //   canvas.drawRect(Rect.fromLTWH(0, 0, 88, 88),
    //       Paint()..color = Colors.red); // draw by yourself.
    // }, "banner"),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SVGA Flutter Samples')),
      body: ListView.separated(
          itemCount: samples.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(samples[index].first),
                subtitle: Text(samples[index].last),
                onTap: () => _goToSample(context, samples[index]));
          }),
    );
  }

  void _goToSample(context, List<String> sample) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SVGASampleScreen(
          name: sample.first,
          image: sample.last,
          dynamicCallback: dynamicSamples[sample.first]);
    }));
  }
}

