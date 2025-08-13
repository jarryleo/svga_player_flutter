import 'package:svga_viewer/theme/text_styles.dart';

import '../includes.dart';
import '../svgaplayer/player.dart';
import '../svgaplayer/svga_source.dart';
import '../svgaplayer/utils.dart';

class SvgaInfoWidget extends StatelessWidget {
  final SVGAAnimationController animationController;
  final SVGASource source;

  const SvgaInfoWidget(
      {super.key, required this.animationController, required this.source});

  @override
  Widget build(BuildContext context) {
    String fileName = source.name ?? "";
    String path = source.source;
    int fileSize = animationController.fileSize;
    String filsSizeText = formatFileSize(fileSize);
    var width = animationController.width;
    var height = animationController.height;
    var fps = animationController.fps;
    var duration = animationController.duration;
    var frameCount = animationController.frames;
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("文件信息", style: GTextStyles.titleStyle),
          const SizedBox(height: 8),
          _buildInfoItem("文件名", fileName),
          _buildInfoItem("大小", filsSizeText),
          _buildInfoItem("路径", path),
          const SizedBox(height: 16),
          const Text("动画属性", style: GTextStyles.titleStyle),
          const SizedBox(height: 8),
          _buildInfoItem("宽度", width.toString()),
          _buildInfoItem("高度", height.toString()),
          _buildInfoItem("帧率", fps.toString()),
          _buildInfoItem("时长", duration.toString()),
          _buildInfoItem("帧数", frameCount.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GTextStyles.contentStyle),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              content,
              style: GTextStyles.valueStyle,
              maxLines: 3,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
