import 'package:svga_viewer/theme/text_styles.dart';

import '../includes.dart';
import '../svgaplayer/svga_source.dart';
import '../theme/g_colors.dart';
import '../viewmodel/svga_view_model.dart';

class TopBarWidget extends StatefulWidget {
  final SvgaViewerModel model;
  final SVGASource source;

  const TopBarWidget({super.key, required this.model, required this.source});

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) => Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios_new)
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              widget.source.name ?? "",
              style: GTextStyles.titleStyle,
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overflow:'),
                Theme(
                  data: Theme.of(context).copyWith(
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return GColors.mainColor; // 选中时的拇指颜色
                          }
                          return Colors.grey; // 未选中时的拇指颜色
                        },
                      ),
                      trackColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return GColors.mainColor.withValues(alpha: 0.3); // 选中时的轨道颜色
                          }
                          return Colors.grey.withValues(alpha: 0.3); // 未选中时的轨道颜色
                        },
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          return Colors.transparent; // 禁用点击波纹效果
                        },
                      ),
                    ),
                  ),
                  child: Transform.scale(
                    scale: 0.7, // 缩小 Switch 尺寸
                    child: Switch(
                      value: widget.model.allowOverflow,
                      onChanged: (v) {
                        setState(() {
                          widget.model.changeAllowOverflow(v);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Box fit:'),
                const SizedBox(width: 8),
                DropdownButton<BoxFit>(
                  focusColor: Colors.transparent,
                  style: GTextStyles.valueStyle,
                  value: widget.model.boxFit,
                  onChanged: (BoxFit? newValue) {
                    setState(() {
                      widget.model.changeBoxFit(newValue!);
                    });
                  },
                  items: BoxFit.values.map((BoxFit value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value.toString().split('.').last,
                        style: GTextStyles.valueStyle,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            const SizedBox(width: 16),

            Row(children: [
              IconButton(
                  onPressed: () {
                    widget.model.zoomOut();
                  },
                  icon: const Icon(Icons.zoom_out)),
              TextButton(
                child:
                    Text(widget.model.scaleText, style: GTextStyles.valueStyle),
                onPressed: () {
                  widget.model.resetSize();
                },
              ),
              IconButton(
                  onPressed: () {
                    widget.model.zoomIn();
                  },
                  icon: const Icon(Icons.zoom_in)),
            ])
          ],
        ),
      ),
    );
  }
}
