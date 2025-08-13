import 'package:svga_viewer/svgaplayer/svgaplayer_flutter.dart';
import 'package:svga_viewer/theme/g_colors.dart';
import 'package:svga_viewer/theme/text_styles.dart';

import '../includes.dart';
import '../viewmodel/svga_view_model.dart';

/// 动画控制条
class SvgaControlBar extends StatefulWidget {
  /// 动画控制器
  final SVGAAnimationController animationController;
  final SvgaViewerModel model;

  const SvgaControlBar(
      {super.key, required this.animationController, required this.model});

  @override
  State<SvgaControlBar> createState() => _SvgaControlBarState();
}

class _SvgaControlBarState extends State<SvgaControlBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          showValueIndicator: ShowValueIndicator.always,
          trackHeight: 2,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6, pressedElevation: 4),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(width: 16),
          //播放暂停按钮
          IconButton.outlined(
            iconSize: 24,
            onPressed: () {
              if (widget.animationController.isAnimating == true) {
                widget.animationController.stop();
              } else {
                _playAnimation();
              }
              setState(() {});
            },
            icon: Icon(widget.animationController.isAnimating
                ? Icons.pause
                : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          //进度条
          AnimatedBuilder(
              animation: widget.animationController,
              builder: (context, child) {
                return Slider(
                  min: 0,
                  max: widget.animationController.frames.toDouble(),
                  value: widget.animationController.currentFrame.toDouble(),
                  label: '${widget.animationController.currentFrame}',
                  onChanged: (v) {
                    if (widget.animationController.isAnimating == true) {
                      widget.animationController.stop();
                      setState(() {});
                    }
                    widget.animationController.value =
                        v / widget.animationController.frames;
                  },
                );
              }),
          const SizedBox(width: 8),
          //进度文本和帧数
          AnimatedBuilder(
              animation: widget.animationController,
              builder: (context, child) {
                var current = widget.animationController.currentFrame + 1;
                var total = widget.animationController.frames;
                var fps = widget.animationController.fps;
                return Text(
                  '$current/$total (FPS:$fps)',
                  style: GTextStyles.contentStyle,
                );
              }),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overflow:'),
              const SizedBox(width: 8),
              Switch(
                value: widget.model.allowOverflow,
                onChanged: (v) {
                  setState(() {
                    widget.model.changeAllowOverflow(v);
                  });
                },
              )
            ],
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Box fit:'),
              const SizedBox(width: 8),
              DropdownButton<BoxFit>(
                value: widget.model.boxFit,
                onChanged: (BoxFit? newValue) {
                  setState(() {
                    widget.model.changeBoxFit(newValue!);
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
          //工作区颜色选择
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              GColors.bodyBg,
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
                        widget.model.changeBackgroundColor(e);
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: ShapeDecoration(
                        color: e,
                        shape: CircleBorder(
                          side: widget.model.backgroundColor == e
                              ? const BorderSide(
                                  color: Colors.grey,
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
        ]),
      ),
    );
  }

  void _playAnimation() {
    if (widget.animationController.isCompleted == true) {
      widget.animationController.reset();
    }
    widget.animationController.repeat(); // or animationController.forward();
  }
}
