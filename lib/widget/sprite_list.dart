import 'package:flutter/material.dart';
import 'sprite_info.dart';

class SpriteInfoList extends StatefulWidget {
  final List<SpriteInfo> spriteInfos;
  final Function(bool,SpriteInfo spriteInfo)? onHighlightChanged;
  final Function(SpriteInfo spriteInfo)? onClearPressed;
  final Function(SpriteInfo spriteInfo)? onApplyPressed;

  const SpriteInfoList({
    super.key,
    required this.spriteInfos,
    this.onHighlightChanged,
    this.onClearPressed,
    this.onApplyPressed,
  });

  @override
  _SpriteInfoListState createState() => _SpriteInfoListState();
}


class _SpriteInfoListState extends State<SpriteInfoList> {
  int _expandedIndex = -1; // 当前展开的条目索引，-1表示没有展开的条目

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.spriteInfos.length,
      itemBuilder: (context, index) {
        final spriteInfo = widget.spriteInfos[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              // 如果点击的是已展开的条目，则收起它；否则展开新条目并收起其他条目
              _expandedIndex = _expandedIndex == index ? -1 : index;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SpriteInfoWidget(
              key: ValueKey(spriteInfo.name), // 为每个widget提供唯一key
              spriteInfo: spriteInfo,
              isExpanded: _expandedIndex == index,
              onHighlightChanged: (highlight) {
                widget.onHighlightChanged?.call( highlight, spriteInfo);
              },
              onClearPressed: () {
                widget.onClearPressed?.call(spriteInfo);
              },
              onApplyPressed: () {
                widget.onApplyPressed?.call(spriteInfo);
              },
            ),
          ),
        );
      },
    );
  }
}
