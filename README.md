# 一个支持`CustomScrollView`和`TabBar`锚点联动的组件

## 效果预览
<img alt="Sample" height="560" src="https://raw.githubusercontent.com/kpaxian7/locate_tab_scroll_view/refs/heads/main/sample_gif.gif" width="270">

## 使用方式
仓库提供了`LocateTabScrollContainer` 和 `LocateTabWidget`组件

#### `LocateTabScrollContainer`
将你的`CustomScrollView`作为child传入`LocateTabScrollContainer`，并且提供一些必要的组件`GlobalKey`和`controller`

#### `LocateTabWidget`
其中你的`TabBar`需要使用`LocateTabWidget`来代替，其属性与`TabBar`本身完全相同，只是我们需要截取其中的`onTap`事件以便实现该功能


## 代码
```dart
class MainTestPage extends StatefulWidget {
  const MainTestPage({super.key});

  @override
  State<MainTestPage> createState() => _MainTestPageState();
}

class _MainTestPageState extends State<MainTestPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  GlobalKey headerKey0 = GlobalKey();
  GlobalKey headerKey1 = GlobalKey();
  GlobalKey tabWidgetKey = GlobalKey();
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
        title: const Text("AppBar"),
      ),
      body: LocateTabScrollContainer(
        tabController: tabController,
        headerWidgetsKey: [headerKey0, headerKey1],
        tabWidgetKey: tabWidgetKey,
        bodyWidgetsKey: [
          bodyKey0,
          bodyKey1,
          bodyKey2,
          bodyKey3,
          bodyKey4,
        ],
        tabLocateDuration: const Duration(milliseconds: 1000),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              key: headerKey0,
              child: Container(
                height: 100,
                color: Colors.cyan,
                child: const Center(
                  child: Text("我是Header widget0"),
                ),
              ),
            ),
            SliverToBoxAdapter(
              key: headerKey1,
              child: Container(
                height: 100,
                color: Colors.deepPurpleAccent,
                child: const Center(
                  child: Text("我是Header widget1"),
                ),
              ),
            ),
            SliverPersistentHeader(
              key: tabWidgetKey,
              delegate: SimpleSliverHeaderDelegate.fixedHeight(
                  height: 100,
                  child: Container(
                    color: Colors.white,
                    child: LocateTabWidget(
                      controller: tabController,
                      tabs: const [
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
              child: const RandomHeightContainer(
                color: Colors.yellowAccent,
                child: Text("Item0"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey1,
              child: const RandomHeightContainer(
                color: Colors.green,
                child: Text("Item1"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey2,
              child: const RandomHeightContainer(
                color: Colors.blueAccent,
                child: Text("Item2"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey3,
              child: const RandomHeightContainer(
                color: Colors.redAccent,
                child: Text("Item3"),
              ),
            ),
            SliverToBoxAdapter(
              key: bodyKey4,
              child: const RandomHeightContainer(
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

```