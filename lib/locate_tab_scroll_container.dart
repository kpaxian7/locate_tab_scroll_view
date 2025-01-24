import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:locate_tab_scroll_view/locate_tab_scroll_view.dart';

class LocateTabScrollContainer extends StatefulWidget {
  /// TabBar controller
  final TabController tabController;

  /// header widgets的 [GlobalKey] 集合
  final List<GlobalKey> headerWidgetsKey;

  /// TabBar widget的 [GlobalKey]
  final GlobalKey tabWidgetKey;

  /// body widgets的 [GlobalKey] 集合
  final List<GlobalKey> bodyWidgetsKey;

  /// 包裹的child，需要是 [CustomScrollView]
  final CustomScrollView child;

  /// ScrollView滑动时TabBar的重定向时的滑动时间，默认值为200ms
  final Duration tabLocateDuration;

  /// TabBar点击时ScrollView的重定向时的滑动时间，默认值为200ms
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
  TabController? _tabController;
  ScrollController? _scrollController;

  ScrollController? get scrollController {
    _scrollController ??=
        widget.child.controller ?? PrimaryScrollController.maybeOf(context);
    return _scrollController;
  }

  /// body widgets偏移量阶梯List，在初始化时 和 每次滑动事件开始时计算记录
  List<double> widgetsOffsetList = [];

  /// 标志位，是否是用户主动点击了TabBar的Item
  bool tabTapByManual = false;

  /// 标志位，是否忽略TabBar重定位
  /// 当滑动开始时，根据[tabTapByManual]来决定是否需要忽略本次滑动时TabBar的重定位
  bool ignoreTabRelocate = false;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    _tabController?.addListener(() {
      if (widget.tabController.indexIsChanging == false) {
        int clickIndex = widget.tabController.index;
        _tabClicked(clickIndex);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assembleWidgetsOffset();
    });
  }

  /// 记录body widgets的偏移量阶梯
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

  void _tabClicked(int index) {
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

    double maxScrollExtent = scrollController?.position.maxScrollExtent ?? 0.0;
    if (toOffset > maxScrollExtent) {
      toOffset = maxScrollExtent;
    }

    scrollController?.animateTo(toOffset,
        duration: widget.scrollViewLocateDuration, curve: Curves.linear);
  }

  /// 当垂直滑动事件收到后，判断是否是用户手动点击的
  /// 如果是，则打开标志位，禁止在滑动过程中再次重定位TabBar
  /// 如果不是，则关闭标志位，允许在滑动过程中再次重定位TabBar
  void _scrollStartReceived() {
    ignoreTabRelocate = tabTapByManual;
    tabTapByManual = false;
  }

  /// 接收到滑动事件
  void _scrollUpdateReceived() {
    if (ignoreTabRelocate) {
      return;
    }
    double scrollViewOffset = scrollController?.offset ?? 0.0;

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

    _tabController?.animateTo(toIndex, duration: widget.tabLocateDuration);
  }

  bool _scrollNotificationReceived(Notification notification) {
    if (notification is! ScrollNotification) {
      return false;
    }
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _scrollStartReceived();
      _assembleWidgetsOffset();
    } else if (notification is ScrollUpdateNotification) {
      _scrollUpdateReceived();
    }
    return false;
  }

  /// 由Widget树中的child-[LocateTabWidget]中onTap事件中调用
  void tabTapManual(int index) {
    tabTapByManual = true;
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
