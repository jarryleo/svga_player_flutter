import 'package:flutter/material.dart';

import '../svgaplayer/utils.dart';

class SpriteInfo {
  final String name;
  int? width;
  int? height;
  int? memory;
  String? text;
  Color? textColor;
  double? textSize;
  String? imagePath;

  SpriteInfo({
    required this.name,
    this.width,
    this.height,
    this.memory,
    this.text,
    this.textColor,
    this.textSize,
    this.imagePath,
  });
}

// 修改 SpriteInfoWidget 类，添加新的回调函数参数
class SpriteInfoWidget extends StatefulWidget {
  final SpriteInfo spriteInfo;
  final bool isExpanded;
  final Function(bool)? onHighlightChanged;
  final Function()? onClearPressed;
  final Function()? onApplyPressed;

  const SpriteInfoWidget({
    super.key,
    required this.spriteInfo,
    this.isExpanded = false,
    this.onHighlightChanged,
    this.onClearPressed,
    this.onApplyPressed,
  });

  @override
  _SpriteInfoWidgetState createState() => _SpriteInfoWidgetState();
}

class _SpriteInfoWidgetState extends State<SpriteInfoWidget> {
  // 文字相关控制器和变量
  final TextEditingController _textController = TextEditingController();

  // 图片相关控制器和变量
  final TextEditingController _imageUrlController = TextEditingController();
  String _selectedShape = 'Original';

  // 新增高亮状态变量
  bool _isHighlighted = false;

  // 颜色选项列表
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  // 字体大小选项列表
  final List<double> _sizeOptions = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 24.0];

  @override
  void initState() {
    super.initState();
    // 初始化控制器值
    _textController.text = widget.spriteInfo.text ?? '';
    _imageUrlController.text = widget.spriteInfo.imagePath ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // 显示文字样式选择弹窗
  void _showTextStyleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Text Style'),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color:'),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.spriteInfo.textColor = color;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 40,
                              height: 40,
                              color: color,
                              child: widget.spriteInfo.textColor == color
                                  ? Icon(Icons.check,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Font Size:'),
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _sizeOptions.map((size) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.spriteInfo.textSize = size;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: widget.spriteInfo.textSize == size
                                        ? Colors.blue
                                        : Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                size.toString(),
                                style: TextStyle(fontSize: size),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = widget.spriteInfo.memory ?? 0;
    var width = widget.spriteInfo.width ?? 0;
    var height = widget.spriteInfo.height ?? 0;
    String format = formatFileSize(size);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第一行：显示名称
        Text(
          'key: ${widget.spriteInfo.name}, size: $width x $height , memory: $format ($size)',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        // 第二行：文字输入相关
        if (widget.isExpanded) const SizedBox(height: 10),
        if (widget.isExpanded)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: const ValueKey('textRow'),
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 45,
                    child: Text('Text:'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42.0,
                      child: TextField(
                        controller: _textController,
                        onChanged: (text) {
                          setState(() {
                            widget.spriteInfo.text = text;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'input dynamic text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _showTextStyleDialog,
                    child: const Text('Choose Style'),
                  ),
                ],
              ),
            ),
          ),

        // 第三行：图片输入相关
        if (widget.isExpanded)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: const ValueKey('imageRow'),
              child: Row(
                children: [
                  const SizedBox(
                    width: 45,
                    child: Text('Image:'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 42.0, // 设置您需要的固定高度
                      child: TextField(
                        controller: _imageUrlController,
                        onChanged: (text) {
                          setState(() {
                            widget.spriteInfo.imagePath = text;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'input image url here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Shape:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedShape,
                    items: <String>['Original', 'Circle']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedShape = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

        // 第四行：新增功能行
        if (widget.isExpanded)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: const ValueKey('actionRow'),
              margin: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  // 左侧勾选框
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _isHighlighted,
                        onChanged: (bool? value) {
                          setState(() {
                            _isHighlighted = value ?? false;
                          });
                          // 反馈到控件外部
                          widget.onHighlightChanged?.call(_isHighlighted);
                        },
                      ),
                      const Text('highlight'),
                    ],
                  ),
                  const Spacer(),
                  // 中间清除按钮
                  ElevatedButton(
                    onPressed: () {
                      // 清除文本和图片输入
                      setState(() {
                        _textController.clear();
                        _imageUrlController.clear();
                        widget.spriteInfo.text = null;
                        widget.spriteInfo.imagePath = null;
                      });
                      // 反馈到控件外部
                      widget.onClearPressed?.call();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 10),
                  // 右侧应用按钮
                  ElevatedButton(
                    onPressed: () {
                      // 反馈到控件外部
                      widget.onApplyPressed?.call();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
