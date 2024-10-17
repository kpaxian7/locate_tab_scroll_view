import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locate_tab_scroll_view/locate_tab_scroll_container.dart';

typedef GestureDetectionCallback = bool Function(double v);

class LocateTabWidget extends StatefulWidget {
  final Widget child;

  const LocateTabWidget({required this.child, super.key});

  @override
  State<LocateTabWidget> createState() => _LocateTabWidgetState();
}

class _LocateTabWidgetState extends State<LocateTabWidget> {
  GlobalKey containerKey = GlobalKey();

  LocateTabScrollContainerState? get _scrollContainerState {
    return context.findAncestorStateOfType<LocateTabScrollContainerState>();
  }

  bool isGestureClickOnTabWidgetArea(double clickDy) {
    RenderBox? box =
        containerKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? globalOffset = box?.localToGlobal(Offset.zero);

    double height = box?.size.height ?? 0.0;
    double dx = globalOffset?.dx ?? 0.0;
    double dy = globalOffset?.dy ?? 0.0;

    return clickDy > dy && clickDy < dy + height;
  }

  @override
  void didUpdateWidget(covariant LocateTabWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollContainerState
        ?.registerGestureListener(isGestureClickOnTabWidgetArea);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        key: containerKey,
        child: widget.child,
      ),
    );
  }
}
