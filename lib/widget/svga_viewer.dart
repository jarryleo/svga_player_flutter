import 'package:svga_viewer/svgaplayer/player.dart';
import 'package:svga_viewer/viewmodel/svga_view_model.dart';

import '../includes.dart';

class SvgaViewer extends StatelessWidget {
  /// 动画控制器
  final SVGAAnimationController animationController;
  final SvgaViewerModel model;

  const SvgaViewer(
      {super.key, required this.animationController, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: model,
        builder: (context, child) {
          return Stack(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: model.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: SVGAImage(
                    animationController,
                    fit: model.boxFit,
                    clearsAfterStop: false,
                    allowDrawingOverflow: model.allowOverflow,
                    preferredSize: Size(model.containerWidth, model.containerHeight),
                  ),
                ),
              ),
              if (model.isLoading) const CircularProgressIndicator(),
            ],
          );
        });
  }
}
