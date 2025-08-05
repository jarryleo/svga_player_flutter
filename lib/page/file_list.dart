import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:svga_player_flutter/svgaplayer/svga_source.dart';
import 'package:svga_player_flutter/widget/drag_file.dart';

import 'svga_viewer.dart';

class FileList extends StatefulWidget {
  final List<DropItem> _list = [];

  FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVGA Viewer by Jarry Leo')),
      body: DragFile(
        content: widget._list.isEmpty ? const Center(child: Text('Svga File drop here ~')) : ListView.separated(
            itemCount: widget._list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(widget._list[index].name),
                  subtitle: Text(widget._list[index].path),
                  onTap: () => _goToSample(context, widget._list[index]));
            }),
        onDragDone: (detail) {
          setState(() {
            // 移除重复的项目
            for (var newItem in detail.reversed) {
              widget._list.removeWhere((item) => item.path == newItem.path);
            }
            // 将新项目插入到列表开头
            widget._list.insertAll(0, detail);

            // 使用 WidgetsBinding 确保 setState 完成后再导航
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget._list.isNotEmpty) {
                _goToSample(context, widget._list.first);
              }
            });
          });
        },
      ),
    );
  }

  void _goToSample(context, DropItem sample) {
    var route = MaterialPageRoute(
        builder: (context) {
          String name = sample.name;
          String path = sample.path;
          SVGASource source;
          if (path.toLowerCase().startsWith(RegExp(r'https?://')) ||
              path.toLowerCase().startsWith(RegExp(r'blob:'))) {
            source = SVGASource.network(name, path);
          } else {
            source = SVGASource.file(name, File(path));
          }
          return SVGAViewerPage(source: source);
        });
    if(Navigator.of(context).canPop()){
      Navigator.of(context).pop();
    }
    Navigator.of(context).push(route);
  }
}
