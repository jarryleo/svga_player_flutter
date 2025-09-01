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
    with TickerProviderStateMixin {
  SVGAAnimationController? animationController;
  SvgaViewerModel model = SvgaViewerModel();

  // 在状态类中添加标志
  bool _isLoaded = false;
  bool _isError = false; // 添加错误状态标志

  // 添加动画控制器
  late AnimationController _animationController; // 控制除TopBar外其他组件的动画
  late AnimationController _topBarAnimationController; // 专门控制TopBar的动画
  late Animation<Offset> _topBarSlideAnimation;
  late Animation<Offset> _bottomBarSlideAnimation;
  late Animation<Offset> _leftInfoSlideAnimation;
  late Animation<Offset> _rightSpriteListSlideAnimation;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);

    // 初始化TopBar专用动画控制器
    _topBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 创建TopBar动画（页面加载时立即执行）
    _topBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _topBarAnimationController,
      curve: Curves.easeOut,
    ));

    // 立即启动TopBar动画
    _topBarAnimationController.forward();

    // 初始化其他组件的动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bottomBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _leftInfoSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 添加右侧精灵列表的动画
    _rightSpriteListSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    animationController?.load(widget.source, onSuccess: (e) {
      setState(() {
        model.changeIsLoading(false);
        model.setSize(animationController!.width, animationController!.height);
        _isLoaded = true; // 标记加载完成
      });
      // 加载成功后启动其他组件的动画
      _animationController.forward();
    }, onError: (e) {
      setState(() {
        model.changeIsLoading(false);
        _isError = true; // 标记加载失败
      });
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    _animationController.dispose();
    _topBarAnimationController.dispose(); // 释放TopBar动画控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColors.bodyBg,
      body: Stack(
        children: <Widget>[
          // 根据状态显示不同内容
          if (_isError)
            _buildErrorPage() // 显示错误页面
          else
            SvgaViewer(
              animationController: animationController!,
              model: model,
            ),

          // TopBarWidget 从顶部滑入（始终显示）
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SlideTransition(
              position: _topBarSlideAnimation,
              child: TopBarWidget(
                model: model,
                source: widget.source,
              ),
            ),
          ),

          // 其他组件只在非错误状态下显示，并保持原有的动画逻辑
          if (!_isError) ...[
            // SvgaInfoWidget 从左边滑入
            Positioned(
              left: 10,
              bottom: 80,
              child: SlideTransition(
                position: _leftInfoSlideAnimation,
                child: SvgaInfoWidget(
                  animationController: animationController!,
                  source: widget.source,
                ),
              ),
            ),
            // SvgaControlBar 从底部滑入
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: SlideTransition(
                position: _bottomBarSlideAnimation,
                child: SvgaControlBar(
                  animationController: animationController!,
                  model: model,
                ),
              ),
            ),
            // SpriteInfoList 从右侧滑入
            Positioned(
              right: 0,
              top: 80,
              bottom: 80,
              child: SlideTransition(
                position: _rightSpriteListSlideAnimation,
                child: _buildSpriteInfoList(context),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // 构建错误页面
  Widget _buildErrorPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          const Text(
            '加载失败',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '无法加载SVGA动画文件',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 重新加载
              setState(() {
                _isError = false;
                model.changeIsLoading(true);
              });
              animationController?.load(widget.source, onSuccess: (e) {
                setState(() {
                  model.changeIsLoading(false);
                  model.setSize(
                      animationController!.width, animationController!.height);
                  _isLoaded = true;
                  _isError = false;
                });
                _animationController.forward();
              }, onError: (e) {
                setState(() {
                  model.changeIsLoading(false);
                  _isError = true;
                });
              });
            },
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpriteInfoList(BuildContext context) {
    if (!_isLoaded) {
      // 加载未完成时返回空容器或加载指示器
      return SizedBox(width: 460);
    }
    var list = animationController!.spritesInfo;
    return SizedBox(
      width: 460,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: 230,
              decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: 460,
              padding: const EdgeInsets.all(8),
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
                    //判断是否是url
                    if (imageUrl.startsWith('http')) {
                      dynamicItem.setImageWithUrl(imageUrl, key,
                          transformation: tans);
                    }else{
                      dynamicItem.setImageWithAssert(imageUrl, key,
                          transformation: tans);
                    }
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
                          ),
                        ),
                      ),
                      key,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
