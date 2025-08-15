import 'package:flutter/material.dart';
import 'package:svga_viewer/svgaplayer/sprite_info.dart';

import 'sprite_item.dart';

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

class _SpriteInfoListState extends State<SpriteInfoList>
    with TickerProviderStateMixin {
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
    if (_expandedIndex != -1 && _filteredSpriteInfos.length <= _expandedIndex ||
        (_filteredSpriteInfos.isNotEmpty &&
            _expandedIndex < widget.spriteInfos.length &&
            !_filteredSpriteInfos
                .contains(widget.spriteInfos[_expandedIndex]))) {
      _expandedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 1,
              child: Padding(
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
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredSpriteInfos.length,
            itemBuilder: (context, index) {
              final spriteInfo = _filteredSpriteInfos[index];
              return MouseRegion(
                child: AnimatedSpriteItem(
                  spriteInfo: spriteInfo,
                  expandedIndex: _expandedIndex,
                  originalIndex: widget.spriteInfos.indexOf(spriteInfo),
                  onTap: () {
                    setState(() {
                      final originalIndex =
                          widget.spriteInfos.indexOf(spriteInfo);
                      _expandedIndex =
                          _expandedIndex == originalIndex ? -1 : originalIndex;
                    });
                  },
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
              );
            },
          ),
        ),
      ],
    );
  }
}

class AnimatedSpriteItem extends StatefulWidget {
  final SpriteInfo spriteInfo;
  final int expandedIndex;
  final int originalIndex;
  final VoidCallback onTap;
  final Function(bool) onHighlightChanged;
  final VoidCallback onClearPressed;
  final VoidCallback onApplyPressed;

  const AnimatedSpriteItem({
    super.key,
    required this.spriteInfo,
    required this.expandedIndex,
    required this.originalIndex,
    required this.onTap,
    required this.onHighlightChanged,
    required this.onClearPressed,
    required this.onApplyPressed,
  });

  @override
  _AnimatedSpriteItemState createState() => _AnimatedSpriteItemState();
}

class _AnimatedSpriteItemState extends State<AnimatedSpriteItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(_isHovered) {
          widget.onTap();
        }
      },
      child: MouseRegion(
        onEnter: (event) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = event.localPosition;
            final width = renderBox.size.width;
            if (position.dx > width / 2) {
              setState(() {
                _isHovered = true;
              });
              _controller.forward();
            }
          }
        },
        onHover: (event) {
          if (_isHovered) {
            return;
          }
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = event.localPosition;
            final width = renderBox.size.width;

            if (position.dx > width / 2) {
              setState(() {
                _isHovered = true;
              });
              _controller.forward();
            }
          }
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
          _controller.reverse();
        },
        child: SlideTransition(
          position: _offsetAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white70 : Colors.transparent,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SpriteInfoItemWidget(
              key: ValueKey(widget.spriteInfo.name),
              spriteInfo: widget.spriteInfo,
              isExpanded: widget.originalIndex == widget.expandedIndex,
              onHighlightChanged: widget.onHighlightChanged,
              onClearPressed: widget.onClearPressed,
              onApplyPressed: widget.onApplyPressed,
            ),
          ),
        ),
      ),
    );
  }
}
