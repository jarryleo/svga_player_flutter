import 'package:flutter/material.dart';
import 'package:svga_viewer/svgaplayer/player.dart';
import 'package:svga_viewer/svgaplayer/proto/svga.pb.dart';
import 'package:svga_viewer/svgaplayer/svga_source.dart';
import 'package:svga_viewer/svgaplayer/utils.dart';
import 'package:svga_viewer/theme/g_colors.dart';
import 'package:svga_viewer/theme/text_styles.dart';
import 'package:svga_viewer/viewmodel/svga_view_model.dart';

import '../widget/sprite_list.dart';
import '../widget/svga_control_bar.dart';
import '../widget/svga_viewer.dart';

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
  SvgaViewerModel model = SvgaViewerModel();
  bool hideOptions = false;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    animationController?.load(widget.source);
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColors.bodyBg,
      appBar: AppBar(title: Text(widget.source.name ?? "")),
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text("Source: ${widget.source.toString()}",
                style: GTextStyles.contentStyle),
          ),
          SvgaViewer(
            animationController: animationController!,
            model: model,
          ),
          Positioned(bottom: 100, child: _buildOptions(context)),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: SvgaControlBar(
              animationController: animationController!,
              model: model,
            ),
          ),
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
          //高亮
          var videoItem = animationController?.videoItem;
          if (videoItem == null) {
            return;
          }
          if (highlight) {
            videoItem.highlights.add(spriteInfo.name);
          } else {
            videoItem.highlights.remove(spriteInfo.name);
          }
        },
        onClearPressed: (spriteInfo) {
          var videoItem = animationController?.videoItem;
          var dynamicEntity = videoItem?.dynamicItem;
          if (dynamicEntity == null) {
            return;
          }
          dynamicEntity.dynamicImages.remove(spriteInfo.name);
          dynamicEntity.dynamicText.remove(spriteInfo.name);
          videoItem?.highlights.clear();
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
            var tans = spriteInfo.imageTransformation;
            dynamicItem.setImageWithUrl(imageUrl, key, transformation: tans);
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
                  const Text('Allow drawing overflow'),
                  const SizedBox(width: 8),
                  Switch(
                    value: model.allowOverflow,
                    onChanged: (v) {
                      model.changeAllowOverflow(v);
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                  'Original size: (${animationController!.width} x ${animationController!.height})'),
              const SizedBox(height: 8),
              Text(
                  'Container options: (${model.containerWidth} x ${model.containerHeight})'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' width:'),
                  Slider(
                    min: 1,
                    max: MediaQuery.of(context).size.width.roundToDouble(),
                    value: model.containerWidth,
                    label: '${model.containerWidth}',
                    onChanged: (v) {
                      model.changeContainerSize(
                          v.truncateToDouble(), model.containerHeight);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(' height:'),
                  Slider(
                    min: 1,
                    max: MediaQuery.of(context).size.height.roundToDouble(),
                    label: '${model.containerHeight}',
                    value: model.containerHeight,
                    onChanged: (v) {
                      model.changeContainerSize(
                          model.containerWidth, v.truncateToDouble());
                    },
                  ),
                ],
              ),


            ],
          ],
        ),
      ),
    );
  }
}
