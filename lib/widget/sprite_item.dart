import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svga_viewer/svgaplayer/sprite_info.dart';
import 'package:svga_viewer/svgaplayer/transformation/ImageTransformation.dart';
import 'package:svga_viewer/theme/text_styles.dart';
import 'package:svga_viewer/utils/snack_bar.dart';

import '../svgaplayer/transformation/CircleImageTransformation.dart';
import '../svgaplayer/utils.dart';

// 修改 SpriteInfoWidget 类，添加新的回调函数参数
class SpriteInfoItemWidget extends StatefulWidget {
  final SpriteInfo spriteInfo;
  final bool isExpanded;
  final Function(bool)? onHighlightChanged;
  final Function()? onClearPressed;
  final Function()? onApplyPressed;

  const SpriteInfoItemWidget({
    super.key,
    required this.spriteInfo,
    this.isExpanded = false,
    this.onHighlightChanged,
    this.onClearPressed,
    this.onApplyPressed,
  });

  @override
  _SpriteInfoItemWidgetState createState() => _SpriteInfoItemWidgetState();
}

class _SpriteInfoItemWidgetState extends State<SpriteInfoItemWidget> {
  // 文字相关控制器和变量
  final TextEditingController _textController = TextEditingController();

  // 图片相关控制器和变量
  TextEditingController _imageUrlController = TextEditingController();

  // 预设图片
  final List<String> _imagePathOptions = [
    'assets/icon/ic_app.png',
  ];

  //图片裁剪 'Original', 'Circle'
  final Map<String, ImageTransformation?> imageTransformations = {
    "Original": null,
    "Circle": CircleImageTransformation(),
  };
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
    _isHighlighted = widget.spriteInfo.isHighlight ?? false;
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
              content: SizedBox(
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
                    Slider(
                      value: widget.spriteInfo.textSize?.toDouble() ?? 16.0,
                      min: 5.0,
                      max: 100.0,
                      divisions: 95,
                      label: '${widget.spriteInfo.textSize?.toInt() ?? 16}',
                      onChanged: (double value) {
                        setState(() {
                          widget.spriteInfo.textSize = value;
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '文字',
                        style: TextStyle(
                          fontSize: widget.spriteInfo.textSize ?? 16.0,
                          color: widget.spriteInfo.textColor ?? Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onApplyPressed?.call();
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

    return AnimatedSize(
      alignment: Alignment.topLeft,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：显示名称
          Text(
            'key: ${widget.spriteInfo.name} , size: $width x $height , memory: $format',
            style: GTextStyles.contentStyle,
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
                      width: 55,
                      child: Text('Text:', style: GTextStyles.titleStyle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42.0,
                        child: TextField(
                          controller: _textController,
                          style: GTextStyles.valueStyle,
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
                    const SizedBox(width: 14),
                    ElevatedButton(
                      onPressed: _showTextStyleDialog,
                      child: const Text(
                        'Choose Style',
                      ),
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
                      width: 55,
                      child: Text('Image:', style: GTextStyles.titleStyle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42.0,
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return _imagePathOptions;
                            }
                            return _imagePathOptions.where((String option) {
                              return option.contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _imageUrlController.text = selection;
                              widget.spriteInfo.imagePath = selection;
                            });
                          },
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            _imageUrlController = textEditingController;
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              style: GTextStyles.valueStyle,
                              onChanged: (text) {
                                setState(() {
                                  widget.spriteInfo.imagePath = text;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'input image url here',
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Shape:', style: GTextStyles.titleStyle),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedShape,
                      style: GTextStyles.valueStyle,
                      items: imageTransformations.keys
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
                            widget.spriteInfo.imageTransformation =
                                imageTransformations[newValue];
                            widget.onApplyPressed?.call();
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
                              widget.spriteInfo.isHighlight = _isHighlighted;
                            });
                            // 反馈到控件外部
                            widget.onHighlightChanged?.call(_isHighlighted);
                          },
                        ),
                        const Text('highlight', style: GTextStyles.titleStyle),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        var key = widget.spriteInfo.name;
                        //复制到剪切板
                        Clipboard.setData(ClipboardData(text: key));
                        //提示复制成功
                        showToast(context, "copied!");
                      },
                      child: const Text('Copy Key'),
                    ),
                    const SizedBox(width: 10),
                    // 中间清除按钮
                    ElevatedButton(
                      onPressed: () {
                        // 清除文本和图片输入
                        setState(() {
                          _textController.clear();
                          _imageUrlController.clear();
                          _isHighlighted = false;
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
      ),
    );
  }
}
