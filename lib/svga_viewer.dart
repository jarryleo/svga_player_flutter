import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:svga_player_flutter/svgaplayer/parser.dart';
import 'package:svga_player_flutter/svgaplayer/player.dart';
import 'package:svga_player_flutter/svgaplayer/proto/svga.pb.dart';
import 'package:svga_player_flutter/svgaplayer/utils.dart';

class SVGASampleScreen extends StatefulWidget {
  final String? name;
  final String image;
  final void Function(MovieEntity entity)? dynamicCallback;

  const SVGASampleScreen(
      {Key? key, required this.image, this.name, this.dynamicCallback})
      : super(key: key);

  @override
  _SVGASampleScreenState createState() => _SVGASampleScreenState();
}

class _SVGASampleScreenState extends State<SVGASampleScreen>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;
  bool isLoading = true;
  Color backgroundColor = Colors.transparent;
  bool allowOverflow = true;

  // Canvaskit need FilterQuality.high
  FilterQuality filterQuality = kIsWeb ? FilterQuality.high : FilterQuality.low;
  BoxFit fit = BoxFit.contain;
  late double containerWidth;
  late double containerHeight;
  bool hideOptions = false;

  @override
  void initState() {
    super.initState();
    this.animationController = SVGAAnimationController(vsync: this);
    this._loadAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerWidth = math.min(350, MediaQuery.of(context).size.width);
    containerHeight = math.min(350, MediaQuery.of(context).size.height);
  }

  @override
  void dispose() {
    this.animationController?.dispose();
    this.animationController = null;
    super.dispose();
  }

  void _loadAnimation() async {
    // FIXME: may throw error on loading
    final videoItem = await _loadVideoItem(widget.image);
    if (widget.dynamicCallback != null) {
      widget.dynamicCallback!(videoItem);
    }
    if (mounted) {
      setState(() {
        this.isLoading = false;
        this.animationController?.videoItem = videoItem;
        _playAnimation();
      });
    }
  }

  void _playAnimation() {
    if (animationController?.isCompleted == true) {
      animationController?.reset();
    }
    animationController?.repeat(); // or animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name ?? "")),
      body: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Text("Url: ${widget.image}",
                  style: Theme.of(context).textTheme.subtitle2)),
          if (isLoading) const LinearProgressIndicator(),
          Center(
            child: ColoredBox(
              color: backgroundColor,
              child: SVGAImage(
                this.animationController!,
                fit: fit,
                clearsAfterStop: false,
                allowDrawingOverflow: allowOverflow,
                filterQuality: filterQuality,
                preferredSize: Size(containerWidth, containerHeight),
              ),
            ),
          ),
          Positioned(bottom: 10, child: _buildOptions(context)),
        ],
      ),
      floatingActionButton: isLoading || animationController!.videoItem == null
          ? null
          : FloatingActionButton.extended(
              label: Text(animationController!.isAnimating ? "Pause" : "Play"),
              icon: Icon(animationController!.isAnimating
                  ? Icons.pause
                  : Icons.play_arrow),
              onPressed: () {
                if (animationController?.isAnimating == true) {
                  animationController?.stop();
                } else {
                  _playAnimation();
                }
                setState(() {});
              }),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.black12,
      padding: const EdgeInsets.all(8.0),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          showValueIndicator: ShowValueIndicator.always,
          trackHeight: 2,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6, pressedElevation: 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
                onPressed: () {
                  setState(() {
                    hideOptions = !hideOptions;
                  });
                },
                icon: hideOptions
                    ? const Icon(Icons.arrow_drop_up)
                    : const Icon(Icons.arrow_drop_down),
                label: Text(hideOptions ? 'Show options' : 'Hide options')),
            AnimatedBuilder(
                animation: animationController!,
                builder: (context, child) {
                  return Text(
                      'Current frame: ${animationController!.currentFrame + 1}/${animationController!.frames} (FPS:${animationController!.fps})');
                }),
            if (!hideOptions) ...[
              AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) {
                    return Slider(
                      min: 0,
                      max: animationController!.frames.toDouble(),
                      value: animationController!.currentFrame.toDouble(),
                      label: '${animationController!.currentFrame}',
                      onChanged: (v) {
                        if (animationController?.isAnimating == true) {
                          animationController?.stop();
                        }
                        animationController?.value =
                            v / animationController!.frames;
                      },
                    );
                  }),
              const SizedBox(height: 8),
              AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) {
                    int size = animationController!.memory;
                    String format = formatFileSize(size);
                    return Text('memory: $format ($size)');
                  }),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Image filter quality'),
                  DropdownButton<FilterQuality>(
                    value: filterQuality,
                    onChanged: (FilterQuality? newValue) {
                      setState(() {
                        filterQuality = newValue!;
                      });
                    },
                    items: FilterQuality.values.map((FilterQuality value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Allow drawing overflow'),
                  const SizedBox(width: 8),
                  Switch(
                    value: allowOverflow,
                    onChanged: (v) {
                      setState(() {
                        allowOverflow = v;
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text('Original size: (${animationController!.width} x ${animationController!.height})'),
              const SizedBox(height: 8),
              Text('Container options: ($containerWidth x $containerHeight)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' width:'),
                  Slider(
                    min: 100,
                    max: MediaQuery.of(context).size.width.roundToDouble(),
                    value: containerWidth,
                    label: '$containerWidth',
                    onChanged: (v) {
                      setState(() {
                        containerWidth = v.truncateToDouble();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' height:'),
                  Slider(
                    min: 100,
                    max: MediaQuery.of(context).size.height.roundToDouble(),
                    label: '$containerHeight',
                    value: containerHeight,
                    onChanged: (v) {
                      setState(() {
                        containerHeight = v.truncateToDouble();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' box fit: '),
                  const SizedBox(width: 8),
                  DropdownButton<BoxFit>(
                    value: fit,
                    onChanged: (BoxFit? newValue) {
                      setState(() {
                        fit = newValue!;
                      });
                    },
                    items: BoxFit.values.map((BoxFit value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Colors.transparent,
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.black,
                ]
                    .map(
                      (e) => GestureDetector(
                        onTap: () {
                          setState(() {
                            backgroundColor = e;
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: ShapeDecoration(
                            color: e,
                            shape: CircleBorder(
                              side: backgroundColor == e
                                  ? const BorderSide(
                                      color: Colors.white,
                                      width: 3,
                                    )
                                  : const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future _loadVideoItem(String image) {
  Future Function(String) decoder;
  if (image.startsWith(RegExp(r'https?://'))) {
    decoder = SVGAParser.shared.decodeFromURL;
  } else {
    decoder = SVGAParser.shared.decodeFromAssets;
  }
  return decoder(image);
}
