import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:svga_viewer/svgaplayer/svga_source.dart';
import 'package:svga_viewer/theme/text_styles.dart';
import 'package:svga_viewer/utils/platform_utils.dart';
import 'package:svga_viewer/viewmodel/file_item.dart';
import 'package:svga_viewer/viewmodel/svga_file_list_model.dart';
import 'package:svga_viewer/widget/drag_file.dart';

import '../theme/g_colors.dart';
import 'view_page.dart';

class MainPage extends StatefulWidget {
  final SvgaFileListModel model = SvgaFileListModel();

  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColors.bodyBg,
      body: Stack(
        children: [
          DragFile(
            content: Container(
              margin: const EdgeInsets.only(top: 80.0),
              child: ListenableBuilder(
                listenable: widget.model,
                builder: (context, child) => widget.model.list.isEmpty
                    ? _buildEmptyWidget(context)
                    : ListView.separated(
                        itemCount: widget.model.list.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(widget.model.list[index].name),
                            titleTextStyle: GTextStyles.titleStyle,
                            subtitle: Text(widget.model.list[index].path),
                            subtitleTextStyle: GTextStyles.contentStyle,
                            onTap: () =>
                                _goToSample(context, widget.model.list[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                widget.model.remove(widget.model.list[index]);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
            onDragDone: (files) {
              widget.model.addAll(files);
              // 使用 WidgetsBinding 确保 setState 完成后再导航
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (widget.model.list.isNotEmpty) {
                  _goToSample(context, widget.model.list.first);
                }
              });
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildMainTopBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTopBar(context) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            const Text(
              'SVGA Viewer',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: () {
                _showAddFileDialog(context);
              },
            ),
            const SizedBox(width: 16.0),
            IconButton(
              icon: const Icon(Icons.add_link),
              onPressed: () {
                _showAddUrlDialog(context);
              },
            ),
          ],
        ),
      );

  Widget _buildEmptyWidget(context) => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 70.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(10.0),
          dashPattern: const [6, 3],
          // 虚线模式：6像素实线，3像素间隔
          strokeWidth: 2,
          color: Colors.grey,
          child: SizedBox(
            height: 300,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Drag SVGA files here',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('or click to browse your computer',
                    style: GTextStyles.contentStyle),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('Browse Files'),
                  onPressed: () => _showAddFileDialog(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: GColors.lightBlue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add SVGA URL'),
                  onPressed: () => _showAddUrlDialog(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: GColors.lightBlue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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

  Future<void> _showAddFileDialog(BuildContext context) async {
    // 选择文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['svga'],
    );
    if (result != null) {
      var list = result.files
          .map((e) => FileItem(name: e.name, path: e.xFile.path))
          .toList();
      widget.model.addAll(list);
      if (list.length == 1) {
        _goToSample(context, list.first);
      }
    }
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
              content: SizedBox(
                width: 400,
                child: Column(
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
                    var item = FileItem(
                      name: url.split('/').last,
                      path: url,
                    );
                    widget.model.add(item);
                    Navigator.of(context).pop();
                    // 自动跳转到新添加的项目
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (widget.model.list.isNotEmpty) {
                        _goToSample(context, widget.model.list.first);
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
