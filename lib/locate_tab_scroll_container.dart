import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LocateTabScrollContainer extends StatefulWidget {
  final TabController tabController;
  final List<GlobalKey> headerWidgetsKey;
  final GlobalKey indicatorWidgetKey;
  final List<GlobalKey> bodyWidgetsKey;
  final CustomScrollView child;

  const LocateTabScrollContainer({
    required this.tabController,
    required this.headerWidgetsKey,
    required this.indicatorWidgetKey,
    required this.bodyWidgetsKey,
    required this.child,
    super.key,
  }) : assert(tabController.length == bodyWidgetsKey.length,
            "The indicator length must be the same as the number of body widgets!");

  @override
  State<LocateTabScrollContainer> createState() =>
      _LocateTabScrollContainerState();
}

class _LocateTabScrollContainerState extends State<LocateTabScrollContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController? _scrollController;
  List<double> widgetsOffsetList = [];

  bool startByScroll = false;
  bool startByTabClick = false;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      assembleWidgetsOffset();
    });
    widget.tabController.addListener(_tabControllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController =
        widget.child.controller ?? PrimaryScrollController.maybeOf(context);
  }

  void assembleWidgetsOffset() {
    /// header
    double topWidgetsHeight = 0.0;
    for (GlobalKey key in widget.headerWidgetsKey) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        topWidgetsHeight += renderObject.child?.size.height ?? 0.0;
      }
    }
    widgetsOffsetList.add(topWidgetsHeight);

    /// body
    double bottomWidgetsHeight = 0.0;

    for (GlobalKey key in widget.bodyWidgetsKey) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        bottomWidgetsHeight += renderObject.child?.size.height ?? 0.0;
        widgetsOffsetList.add(topWidgetsHeight + bottomWidgetsHeight);
      }
    }
  }

  ///
  void _tabControllerListener() {
    if (startByScroll) {
      return;
    }
    if (widget.tabController.indexIsChanging == false) {
      print("tab index changed!, index = ${widget.tabController.index ?? 0}");

      int clickIndex = widget.tabController.index ?? 0;
      _tabClicked(clickIndex);
    }
  }

  void _scrollViewUpdating() {
    if (startByTabClick) {
      return;
    }
    double scrollViewOffset = _scrollController?.offset ?? 0.0;
    print("scrollViewOffset = $scrollViewOffset");
    print("widgetsOffsetList = $widgetsOffsetList");

    int toIndex = -1;
    for (int i = widgetsOffsetList.length - 1; i >= 0; i--) {
      double itemOffset = widgetsOffsetList[i];

      if (scrollViewOffset > itemOffset) {
        toIndex = i;
        break;
      }
    }
    if (toIndex == -1) {
      toIndex = 0;
    }

    print("toIndex = $toIndex");
    _tabController.animateTo(toIndex);
  }

  bool _scrollNotificationReceived(Notification notification) {
    if (notification is ScrollNotification &&
        notification.metrics.axis == Axis.horizontal) {
      return false;
    }
    switch (notification.runtimeType) {
      case ScrollStartNotification:
        print("收到start");
        startByScroll = true;
        break;
      case ScrollUpdateNotification:
        print("收到update");
        // print("收到ScrollUpdateNotification");
        _scrollViewUpdating();
        break;
      case ScrollEndNotification:
        print("收到end");
        startByScroll = false;
        startByTabClick = false;
        break;
    }
    return false;
  }

  void _tabClicked(int index) {
    startByTabClick = true;

    /// header
    double topWidgetsHeight = 0.0;
    for (GlobalKey key in widget.headerWidgetsKey) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        topWidgetsHeight += renderObject.child?.size.height ?? 0.0;
      }
    }

    /// body
    double bottomWidgetsHeight = 0.0;
    List<GlobalKey>? bottomWidgetKeyList =
        widget.bodyWidgetsKey.sublist(0, index);
    for (GlobalKey key in bottomWidgetKeyList) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        bottomWidgetsHeight += renderObject.child?.size.height ?? 0.0;
      }
    }

    print("topWidgetsHeight = $topWidgetsHeight");
    print("bottomWidgetsHeight = $bottomWidgetsHeight");
    double toOffset = topWidgetsHeight + bottomWidgetsHeight;
    print("scroll animate to = $toOffset");

    _scrollController?.animateTo(toOffset,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (Notification notification) {
          return _scrollNotificationReceived(notification);
        },
        child: widget.child);
  }
}
