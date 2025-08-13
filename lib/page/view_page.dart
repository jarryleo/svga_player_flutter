import 'package:flutter/material.dart';
import 'package:svga_viewer/svgaplayer/player.dart';
import 'package:svga_viewer/svgaplayer/svga_source.dart';
import 'package:svga_viewer/theme/g_colors.dart';
import 'package:svga_viewer/viewmodel/svga_view_model.dart';
import 'package:svga_viewer/widget/svga_info.dart';
import 'package:svga_viewer/widget/top_bar.dart';

import '../widget/sprite_list.dart';
import '../widget/svga_control_bar.dart';
import '../widget/svga_viewer.dart';

class SVGAViewerPage extends StatefulWidget {
  final SVGASource source;

  const SVGAViewerPage({Key? key, required this.source}) : super(key: key);

  @override
  _SVGAViewerPageState createState() => _SVGAViewerPageState();
}

class _SVGAViewerPageState extends State<SVGAViewerPage>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;
  SvgaViewerModel model = SvgaViewerModel();

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    animationController?.load(widget.source,onSuccess: (e){
      setState(() {
        model.changeIsLoading(false);
        model.setSize(animationController!.width, animationController!.height);
      });
    });
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
      body: Stack(
        children: <Widget>[
          SvgaViewer(
            animationController: animationController!,
            model: model,
          ),
          Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: TopBarWidget(
                model: model,
              )),
          Positioned(
              left: 10,
              bottom: 80,
              child: SvgaInfoWidget(
                animationController: animationController!,
                source: widget.source,
              )),
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
            top: 80,
            bottom: 80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isSpriteListVisible ? 480 : 20,
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
                        color: Colors.white70,
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
      width: 460,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white70,
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
                  ),
                ),
              ),
              key,
            );
          }
        },
      ),
    );
  }
}
