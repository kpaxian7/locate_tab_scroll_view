import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:locate_tab_scroll_view/locate_tab_widget.dart';

class LocateTabScrollContainer extends StatefulWidget {
  final TabController tabController;
  final List<GlobalKey> headerWidgetsKey;
  final GlobalKey tabWidgetKey;
  final List<GlobalKey> bodyWidgetsKey;
  final CustomScrollView child;

  final Duration tabLocateDuration;
  final Duration scrollViewLocateDuration;

  const LocateTabScrollContainer({
    required this.tabController,
    required this.headerWidgetsKey,
    required this.tabWidgetKey,
    required this.bodyWidgetsKey,
    required this.child,
    this.tabLocateDuration = const Duration(milliseconds: 200),
    this.scrollViewLocateDuration = const Duration(milliseconds: 200),
    super.key,
  }) : assert(tabController.length == bodyWidgetsKey.length,
            "The indicator length must be the same as the number of body widgets!");

  @override
  State<LocateTabScrollContainer> createState() =>
      LocateTabScrollContainerState();
}

class LocateTabScrollContainerState extends State<LocateTabScrollContainer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScrollController? _scrollController;
  List<double> widgetsOffsetList = [];

  // bool gestureInTabWidget = false;

  GestureDetectionCallback? gestureDetection;

  bool tabTapByManual = false;
  bool ignoreTabRelocate = false;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assembleWidgetsOffset();
    });
    widget.tabController.addListener(_tabControllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant LocateTabScrollContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController =
        widget.child.controller ?? PrimaryScrollController.maybeOf(context);
  }

  void _assembleWidgetsOffset() {
    widgetsOffsetList.clear();
    // header offset
    double topWidgetsHeight = 0.0;
    for (GlobalKey key in widget.headerWidgetsKey) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        topWidgetsHeight += renderObject.child?.size.height ?? 0.0;
      }
    }
    widgetsOffsetList.add(topWidgetsHeight);

    // body offset
    double bottomWidgetsHeight = 0.0;

    for (GlobalKey key in widget.bodyWidgetsKey) {
      RenderObject? renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderSliverToBoxAdapter) {
        bottomWidgetsHeight += renderObject.child?.size.height ?? 0.0;
        widgetsOffsetList.add(topWidgetsHeight + bottomWidgetsHeight);
      }
    }
  }

  /// tab index changed
  void _tabControllerListener() {
    // print("tab 变化了！！！！indexIsChanging = ${widget.tabController.indexIsChanging}");
    if (widget.tabController.indexIsChanging == false) {
      // print("确定tab了!!!");
      int clickIndex = widget.tabController.index;
      _tabClicked(clickIndex);
      // } else {
      //   // 如果index开始变化的时候是滑动过程中，那么下一次index change不允许进行scrollView定位
      //   if (scrolling) {
      //     ignoreTabIndexing = true;
      //   }
      //   // print("_tabControllerListener index changing");
    }
  }

  void _scrollViewUpdating() {
    print(
        "_scrollViewUpdating, ignoreTabRelocate = $ignoreTabRelocate");
    if (ignoreTabRelocate) {
      return;
    }
    double scrollViewOffset = _scrollController?.offset ?? 0.0;

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

    _tabController.animateTo(toIndex, duration: widget.tabLocateDuration);
  }

  bool _scrollNotificationReceived(Notification notification) {
    // String scrollNotificationType = "unknown";
    // if (notification is ScrollStartNotification) {
    //   scrollNotificationType = "start";
    // } else if (notification is ScrollUpdateNotification) {
    //   scrollNotificationType = "updating";
    // } else if (notification is ScrollEndNotification) {
    //   scrollNotificationType = "end";
    // }
    //
    // bool needIgnore = notification is ScrollNotification &&
    //     notification.metrics.axis == Axis.horizontal;
    // Axis? axis;
    // if (notification is ScrollNotification) {
    //   axis = notification.metrics.axis;
    // }
    // print("收到事件::::[$notification], axis:::[$axis], 需要忽略吗?:::[$needIgnore]");

    // if (notification is UserScrollNotification) {
    //   print("用户主动滑动！！！！");
    // }

    if (notification is! ScrollNotification) {
      return false;
    }
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      scrollStartReceived();
      _assembleWidgetsOffset();
    } else if (notification is ScrollUpdateNotification) {
      _scrollViewUpdating();
    } else if (notification is ScrollEndNotification) {}
    return false;
  }

  void _tabClicked(int index) {
    print("触发了Tab定位的事件！！");
    if (!tabTapByManual) {
      return;
    }

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

    double toOffset = topWidgetsHeight + bottomWidgetsHeight;

    double maxScrollExtent = _scrollController?.position.maxScrollExtent ?? 0.0;
    if (toOffset > maxScrollExtent) {
      toOffset = maxScrollExtent;
    }

    _scrollController?.animateTo(toOffset,
        duration: widget.scrollViewLocateDuration, curve: Curves.linear);
  }

  bool checkTouchInTabWidgetArea(DragDownDetails tapDown) {
    bool isTouchInTabArea = false;
    GlobalKey headerLastWidgetKey = widget.headerWidgetsKey.last;
    GlobalKey bodyFirstWidgetKey = widget.bodyWidgetsKey.first;

    RenderObject? headerLastRenderObject =
        headerLastWidgetKey.currentContext?.findRenderObject();
    RenderObject? bodyFirstRenderObject =
        bodyFirstWidgetKey.currentContext?.findRenderObject();

    Offset? headerLastRenderPosition;
    if (headerLastRenderObject is RenderSliverToBoxAdapter) {
      headerLastRenderPosition =
          headerLastRenderObject.child?.localToGlobal(Offset.zero);
    }

    Offset? bodyFirstRenderPosition;
    if (bodyFirstRenderObject is RenderSliverToBoxAdapter) {
      bodyFirstRenderPosition =
          bodyFirstRenderObject.child?.localToGlobal(Offset.zero);
    }

    if (headerLastRenderPosition != null && bodyFirstRenderPosition != null) {
      isTouchInTabArea =
          tapDown.globalPosition.dy > headerLastRenderPosition.dy &&
              tapDown.globalPosition.dy < bodyFirstRenderPosition.dy;
    }
    return isTouchInTabArea;
  }

  registerGestureListener(GestureDetectionCallback valueChanged) {
    gestureDetection = valueChanged;
  }

  tabTapManual(int index) {
    print("用户主动点击了TabItem，记录标志位");
    tabTapByManual = true;
  }

  /// 当垂直滑动事件收到后，判断是否是用户手动点击的
  /// 如果是，则打开标志位，禁止在滑动过程中再次重定位TabBar
  /// 如果不是，则关闭标志位，允许在滑动过程中再次重定位TabBar
  scrollStartReceived() {
    ignoreTabRelocate = tabTapByManual;
    tabTapByManual = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (e) {
        print("outer onPanDown");
        bool res = gestureDetection?.call(e.globalPosition.dy) ?? false;
        // gestureInTabWidget = res;
        // print("点击在tab内吗？ res = $res");
      },
      onPanEnd: (e) {
        // print("outer onPanEnd");
      },
      onPanCancel: () {
        // print("outer onPanCancel");
      },
      onTapUp: (e) {
        // print("outer onTap up");
      },
      child: NotificationListener(
          onNotification: (Notification notification) {
            return _scrollNotificationReceived(notification);
          },
          child: widget.child),
    );
  }
}
