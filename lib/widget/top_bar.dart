import 'package:svga_viewer/theme/text_styles.dart';

import '../includes.dart';
import '../svgaplayer/svga_source.dart';
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
