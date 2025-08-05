import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class DragFile extends StatefulWidget {
  final Widget? content;
  final void Function(List<DropItem>)? onDragDone;

  const DragFile({Key? key, this.content, this.onDragDone}) : super(key: key);

  @override
  _DragFileState createState() => _DragFileState();
}

class _DragFileState extends State<DragFile> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          widget.onDragDone?.call(detail.files);
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
        child: _dragging
            ? const Center(child: Text("Drop here~"))
            : widget.content,
      ),
    );
  }
}
