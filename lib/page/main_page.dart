import 'dart:io';

import 'package:flutter/material.dart';
import 'package:svga_player_flutter/svgaplayer/svga_source.dart';
import 'package:svga_player_flutter/widget/drag_file.dart';

import 'svga_viewer.dart';

class FileItem {
  final String name;
  final String path;

  FileItem({required this.name, required this.path});
}

class MainPage extends StatefulWidget {
  final List<FileItem> _list = [];

  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SVGA Viewer by Jarry Leo')),
      body: DragFile(
        content: widget._list.isEmpty
            ? const Center(child: Text('Svga File drop here ~'))
            : ListView.separated(
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
      // 添加悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUrlDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _goToSample(context, FileItem file) {
    var route = MaterialPageRoute(builder: (context) {
      String name = file.name;
      String path = file.path;
      SVGASource source;
      if (path.toLowerCase().startsWith(RegExp(r'https?://')) ||
          path.toLowerCase().startsWith(RegExp(r'blob:'))) {
        source = SVGASource.network(name, path);
      } else {
        source = SVGASource.file(name, File(path));
      }
      return SVGAViewerPage(source: source);
    });
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).push(route);
  }

  // 显示添加URL对话框
  void _showAddUrlDialog(BuildContext context) {
    TextEditingController urlController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Input svga url'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      hintText: 'please input svga url~',
                      labelText: 'URL',
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String url = urlController.text.trim();
                    if (url.isEmpty) {
                      setState(() {
                        errorMessage = 'url can not be empty';
                      });
                      return;
                    }

                    // 简单验证URL格式
                    if (!url.toLowerCase().startsWith(RegExp(r'https?://'))) {
                      setState(() {
                        errorMessage = 'Please enter a valid URL address';
                      });
                      return;
                    }

                    // 添加新项目到列表
                    setState(() {
                      // 移除重复的项目
                      widget._list.removeWhere((item) => item.path == url);
                      // 添加新项目到列表开头
                      widget._list.insert(
                        0,
                        FileItem(
                          name: url.split('/').last,
                          path: url,
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                    // 自动跳转到新添加的项目
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (widget._list.isNotEmpty) {
                        _goToSample(context, widget._list.first);
                      }
                    });
                  },
                  child: const Text('open'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
