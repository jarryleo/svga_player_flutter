import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:svga_player_flutter/svgaplayer/player.dart';
import 'package:svga_player_flutter/svgaplayer/proto/svga.pb.dart';
import 'package:svga_player_flutter/svgaplayer/svga_source.dart';
import 'package:svga_player_flutter/svgaplayer/utils.dart';

import '../widget/sprite_list.dart';

class SVGAViewerPage extends StatefulWidget {
  final SVGASource source;

  final void Function(MovieEntity entity)? dynamicCallback;

  const SVGAViewerPage({Key? key, required this.source, this.dynamicCallback})
      : super(key: key);

  @override
  _SVGAViewerPageState createState() => _SVGAViewerPageState();
}

class _SVGAViewerPageState extends State<SVGAViewerPage>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;
  bool isLoading = true;
  Color backgroundColor = Colors.transparent;
  bool allowOverflow = true;
  bool showBorder = false;

  // Canvaskit need FilterQuality.high
  FilterQuality filterQuality = kIsWeb ? FilterQuality.high : FilterQuality.low;
  BoxFit fit = BoxFit.contain;
  late double containerWidth;
  late double containerHeight;
  bool hideOptions = false;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerWidth = math.min(
        animationController?.width.roundToDouble() ?? 350, MediaQuery.of(context).size.width.roundToDouble());
    containerHeight = math.min(
        animationController?.height.roundToDouble() ?? 350, MediaQuery.of(context).size.height.roundToDouble());
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  void _loadAnimation() async {
    // FIXME: may throw error on loading
    final videoItem = await loadVideoItem(widget.source);
    if (widget.dynamicCallback != null) {
      widget.dynamicCallback!(videoItem);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
        animationController?.videoItem = videoItem;
        containerWidth = math.min(animationController?.width.roundToDouble() ?? 350,
            MediaQuery.of(context).size.width.roundToDouble());
        containerHeight = math.min(animationController?.height.roundToDouble() ?? 350,
            MediaQuery.of(context).size.height.roundToDouble());
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
      appBar: AppBar(title: Text(widget.source.name ?? "")),
      body: Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(8.0),
              child: Text("Source: ${widget.source.toString()}",
                  style: Theme.of(context).textTheme.titleSmall)),
          if (isLoading) const LinearProgressIndicator(),
          Center(
            child: ColoredBox(
              color: backgroundColor,
              child: SVGAImage(
                animationController!,
                fit: fit,
                clearsAfterStop: false,
                allowDrawingOverflow: allowOverflow,
                showBorder: showBorder,
                filterQuality: filterQuality,
                preferredSize: Size(containerWidth, containerHeight),
              ),
            ),
          ),
          Positioned(bottom: 0, child: _buildOptions(context)),
          Positioned(
            right: 0,
            top: 50,
            bottom: 150,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSpriteListVisible ? 520 : 20,
              // 500 for list + 20 for button
              onEnd: () {
                // 动画结束时更新 shouldShowSpriteList 的值
                if (mounted) {
                  setState(() {
                    _shouldShowSpriteList = _isSpriteListVisible;
                  });
                }
              },
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSpriteListVisible = !_isSpriteListVisible;
                        // 当隐藏列表时立即设置为 false
                        if (!_isSpriteListVisible) {
                          _shouldShowSpriteList = false;
                        }
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      child: Icon(
                        _isSpriteListVisible
                            ? Icons.arrow_right
                            : Icons.arrow_left,
                        size: 20,
                      ),
                    ),
                  ),
                  if (_shouldShowSpriteList) _buildSpriteInfoList(context),
                ],
              ),
            ),
          ),
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

  bool _isSpriteListVisible = false;
  bool _shouldShowSpriteList = false;

  Widget _buildSpriteInfoList(BuildContext context) {
    var list = animationController!.spritesInfo;
    return Container(
      width: 500,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(8),
        ),
      ),
      child: SpriteInfoList(
        spriteInfos: list,
        onHighlightChanged: (highlight, spriteInfo) {
          //todo 高亮
        },
        onClearPressed: (spriteInfo) {
          var videoItem = animationController?.videoItem;
          var dynamicEntity = videoItem?.dynamicItem;
          if (dynamicEntity == null) {
            return;
          }
          dynamicEntity.dynamicImages.remove(spriteInfo.name);
          dynamicEntity.dynamicText.remove(spriteInfo.name);
        },
        onApplyPressed: (spriteInfo) {
          var dynamicItem = animationController?.videoItem?.dynamicItem;
          if (dynamicItem == null) {
            return;
          }
          var key = spriteInfo.name;
          //设置占位图
          var imageUrl = spriteInfo.imagePath ?? "";
          if (imageUrl.isNotEmpty) {
            dynamicItem.setImageWithUrl(imageUrl, key);
          }
          //设置文本
          var string = spriteInfo.text ?? "";
          var fontSize = spriteInfo.textSize ?? 14;
          var textColor = spriteInfo.textColor ?? Colors.white;
          if (string.isNotEmpty) {
            dynamicItem.setText(
                TextPainter(
                    text: TextSpan(
                        text: string,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ))),
                key);
          }
        },
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 8),
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
                          setState(() {});
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
                    int size = animationController!.fileSize;
                    String format = formatFileSize(size);
                    return Text('FileSize: $format ($size)');
                  }),
              const SizedBox(height: 8),
              AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) {
                    int size = animationController!.memory;
                    String format = formatFileSize(size);
                    return Text('Memory: $format ($size)');
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
                  const Text('Show Border'),
                  const SizedBox(width: 8),
                  Switch(
                    value: showBorder,
                    onChanged: (v) {
                      setState(() {
                        showBorder = v;
                      });
                    },
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
              Text(
                  'Original size: (${animationController!.width} x ${animationController!.height})'),
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
              const SizedBox(width: 8),
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
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}
