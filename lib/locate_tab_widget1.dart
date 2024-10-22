import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locate_tab_scroll_view/locate_tab_scroll_container.dart';

typedef GestureDetectionCallback = bool Function(double v);

class LocateTabWidget1 extends TabBar {
  final ValueChanged<int>? onTabTap;

  LocateTabWidget1({
    super.key,
    required super.tabs,
    super.controller,
    super.isScrollable,
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment,
    super.indicatorWeight,
    super.indicatorPadding,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.dividerHeight,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    super.tabAlignment,
    this.onTabTap,
  }) : super(onTap: (index) {
          if (onTabTap != null) {
            onTabTap.call(index);
          }
          // 这里就可以做自己想做的
        });

  @override
  State<TabBar> createState() {
    return super.createState();
  }

}

class Testtet extends StatelessWidget {
  const Testtet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LocateTabWidget1(
        tabs: [],
      ),
    );
  }
}
