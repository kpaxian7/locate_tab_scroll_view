import 'package:flutter/material.dart';
import 'package:locate_tab_scroll_view/locate_tab_scroll_container.dart';
import 'package:locate_tab_scroll_view_example/random_height_container.dart';
import 'package:locate_tab_scroll_view_example/simple_sliver_header_delegate.dart';

void main() {
  runApp(const MaterialApp(
    home: MainTestPage(),
  ));
}

class MainTestPage extends StatefulWidget {
  const MainTestPage({super.key});

  @override
  State<MainTestPage> createState() => _MainTestPageState();
}

class _MainTestPageState extends State<MainTestPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  GlobalKey headerKey0 = GlobalKey();
  GlobalKey bodyKey0 = GlobalKey();
  GlobalKey bodyKey1 = GlobalKey();
  GlobalKey bodyKey2 = GlobalKey();
  GlobalKey bodyKey3 = GlobalKey();
  GlobalKey bodyKey4 = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TestPage"),
      ),
      body: LocateTabScrollContainer(
        tabController: tabController,
        headerWidgetsKey: [headerKey0],
        bodyWidgetsKey: [
          bodyKey0,
          bodyKey1,
          bodyKey2,
          bodyKey3,
          bodyKey4,
        ],
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              key: headerKey0,
              child: Container(
                height: 100,
                color: Colors.cyan,
                child: const Text("我是Header widget"),
              ),
            ),
            SliverPersistentHeader(
              delegate: SimpleSliverHeaderDelegate.fixedHeight(
                  height: 100,
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: tabController,
                      tabs: [
                        Tab(
                          text: "tab0",
                        ),
                        Tab(
                          text: "tab1",
                        ),
                        Tab(
                          text: "tab2",
                        ),
                        Tab(
                          text: "tab3",
                        ),
                        Tab(
                          text: "tab4",
                        ),
                      ],
                    ),
                  )),
              pinned: true,
            ),
            SliverToBoxAdapter(
              key: bodyKey0,
              child: RandomHeightContainer(
                color: Colors.yellowAccent,
                child: Text("Item0"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey1,
              child: RandomHeightContainer(
                color: Colors.green,
                child: Text("Item1"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey2,
              child: RandomHeightContainer(
                color: Colors.blueAccent,
                child: Text("Item2"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey3,
              child: RandomHeightContainer(
                color: Colors.redAccent,
                child: Text("Item3"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey4,
              child: RandomHeightContainer(
                color: Colors.orange,
                child: Text("Item4"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
