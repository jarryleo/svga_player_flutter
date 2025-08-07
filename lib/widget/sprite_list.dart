import 'package:flutter/material.dart';
import 'sprite_info.dart';

class SpriteInfoList extends StatefulWidget {
  final List<SpriteInfo> spriteInfos;
  final Function(bool, SpriteInfo spriteInfo)? onHighlightChanged;
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
  int _expandedIndex = -1;
  final TextEditingController _searchController = TextEditingController();
  List<SpriteInfo> _filteredSpriteInfos = [];

  @override
  void initState() {
    super.initState();
    _filteredSpriteInfos = widget.spriteInfos;
    _searchController.addListener(_filterSprites);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSprites);
    _searchController.dispose();
    super.dispose();
  }

  void _filterSprites() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSpriteInfos = widget.spriteInfos;
      });
    } else {
      setState(() {
        _filteredSpriteInfos = widget.spriteInfos
            .where((sprite) => sprite.name.toLowerCase().contains(query))
            .toList();
      });
    }

    // 如果当前展开的项不再显示在结果中，则重置展开索引
    if (_expandedIndex != -1 &&
        _filteredSpriteInfos.length <= _expandedIndex ||
        (_filteredSpriteInfos.isNotEmpty &&
            _expandedIndex < widget.spriteInfos.length &&
            !_filteredSpriteInfos.contains(widget.spriteInfos[_expandedIndex]))) {
      _expandedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search for key',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredSpriteInfos.length,
            itemBuilder: (context, index) {
              final spriteInfo = _filteredSpriteInfos[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // 需要找到在原始列表中的索引
                    final originalIndex = widget.spriteInfos.indexOf(spriteInfo);
                    _expandedIndex = _expandedIndex == originalIndex ? -1 : originalIndex;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SpriteInfoWidget(
                    key: ValueKey(spriteInfo.name),
                    spriteInfo: spriteInfo,
                    isExpanded: widget.spriteInfos.indexOf(spriteInfo) == _expandedIndex,
                    onHighlightChanged: (highlight) {
                      widget.onHighlightChanged?.call(highlight, spriteInfo);
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
          ),
        ),
      ],
    );
  }
}
