import 'package:flutter/material.dart';
import 'package:hapi/components/vertical_scrollable_tabview/rect_getter/rect_getter.dart';
import 'package:hapi/components/vertical_scrollable_tabview/scroll_to_index/scroll_to_index.dart';

/// Detect TabBar Status, isOnTap = is to check TabBar is on Tap or not,
/// isOnTapIndex = is on Tap Index
class VerticalScrollableTabBarStatus {
  static bool isOnTap = false;
  static int isOnTapIndex = 0;

  static void setIndex(int index) {
    VerticalScrollableTabBarStatus.isOnTap = true;
    VerticalScrollableTabBarStatus.isOnTapIndex = index;
  }
}

class VerticalScrollableTabView extends StatefulWidget {
  const VerticalScrollableTabView({
    required this.tabController,
    required this.listItemData,
    required this.eachItemChild,
    required this.slivers,
//  required Axis this.scrollDirection,
  });

  /// TabBar Controller to let widget listening TabBar changed
  final TabController tabController;

  /// Required a List<dynamic> Type，you can put your data that you wanna put in item
  final List<dynamic> listItemData;

  /// A callback that returns listItemData and the index of ListView.Builder
  final Widget Function(dynamic aaa, int index) eachItemChild;

  /// Required SliverAppBar, And TabBar must inside of SliverAppBar, and In the TabBar
  /// onTap: (index) => VerticalScrollableTabBarStatus.setIndex(index);
  final List<Widget> slivers;

  /// TODO Horizontal ScrollDirection
//final Axis axisOrientation;

  @override
  _VerticalScrollableTabViewState createState() =>
      _VerticalScrollableTabViewState();
}

class _VerticalScrollableTabViewState extends State<VerticalScrollableTabView>
    with SingleTickerProviderStateMixin {
  /// Instantiate scroll_to_index
  late AutoScrollController scrollController;

  /// When the animation is started, need to pause onScrollNotification to calculate Rect
  bool pauseRectGetterIndex = false;

  /// Instantiate RectGetter
  final listViewKey = RectGetter.createGlobalKey();

  /// To save the item's Rect
  Map<int, dynamic> itemsKeys = {};

  @override
  void initState() {
    scrollController = AutoScrollController(); // must init first

    widget.tabController.addListener(() {
      if (VerticalScrollableTabBarStatus.isOnTap) {
        animateAndScrollTo(VerticalScrollableTabBarStatus.isOnTapIndex);
        VerticalScrollableTabBarStatus.isOnTap = false;
      }
    });

    // call at init since the above listener requires UI to be touched to run
    if (VerticalScrollableTabBarStatus.isOnTap) {
      animateAndScrollTo(VerticalScrollableTabBarStatus.isOnTapIndex);
      VerticalScrollableTabBarStatus.isOnTap = false;
    }

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RectGetter(
      key: listViewKey,
      child: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [...widget.slivers, buildVerticalSliverList()],
        ),
        onNotification: onScrollNotification,
      ),
    );
  }

  /// TODO Horizontal sliding area
  // Widget buildScrollView() {
  //   return ListView.builder(
  //     controller: widget.scrollController,
  //     itemCount: widget.listItemData.length,
  //     /// TODO Horizontal ScrollDirection
  //     // scrollDirection: widget.axisOrientation,
  //     itemBuilder: (BuildContext context, int index) {
  //       /// Initial Key of itemKeys
  //       /// 初始化 itemKeys 的 key
  //       itemsKeys[index] = RectGetter.createGlobalKey();
  //       return buildItem(index);
  //     },
  //   );
  // }

  SliverList buildVerticalSliverList() {
    return SliverList(
      delegate: SliverChildListDelegate(
        List.generate(
          widget.listItemData.length,
          (index) {
            itemsKeys[index] = RectGetter.createGlobalKey();
            return buildItem(index);
          },
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    dynamic category = widget.listItemData[index];
    return RectGetter(
      /// when announce GlobalKey，we can use RectGetter.getRectFromKey(key) to get Rect
      key: itemsKeys[index],
      child: AutoScrollTag(
        key: ValueKey(index),
        index: index,
        controller: scrollController,
        child: widget.eachItemChild(category, index),
      ),
    );
  }

  /// Animation Function for tabBarListener
  /// This need to put inside TabBar onTap, but in this case we put inside tabBarListener
  void animateAndScrollTo(int index) async {
    pauseRectGetterIndex = true;
    widget.tabController.animateTo(index);
    scrollController
        .scrollToIndex(
          index,
          preferPosition: AutoScrollPosition.begin,
        )
        .then(
          (value) => pauseRectGetterIndex = false,
        );
  }

  /// onScrollNotification of NotificationListener
  /// true means that the current notification is consumed and the notification
  /// will not be delivered to the upper-level NotificationListener, and if
  /// false, the notification will be delivered to the upper-level
  /// NotificationListener.
  bool onScrollNotification(ScrollNotification notification) {
    // if (pauseRectGetterIndex) return true;

    // /// get tabBar index
    // int lastTabIndex = widget.tabController.length - 1;

    // List<int> visibleItems = getVisibleItemsIndex();

    // /// define what is reachLastTabIndex
    // bool reachLastTabIndex = visibleItems.isNotEmpty &&
    //     visibleItems.length <= 2 &&
    //     visibleItems.last == lastTabIndex;

    // /// if reachLastTabIndex, then scroll to last index
    // if (reachLastTabIndex) {
    //   widget.tabController.animateTo(lastTabIndex);
    // } else {
    //   // Get the median value of item in the screen. Example: The middle of 2,3,4 is 3
    //   // Find the product of a list of numbers
    //   int sumIndex = visibleItems.reduce((value, element) => value + element);
    //   // 5 ~/ 2 = 2  => Result is an int
    //   int middleIndex = sumIndex ~/ visibleItems.length;
    //   if (widget.tabController.index != middleIndex) {
    //     widget.tabController.animateTo(middleIndex);
    //   }
    // }
    List<int> visibleItems = getVisibleItemsIndex();
    widget.tabController.animateTo(visibleItems[0]);
    return false;
  }

  /// getVisibleItemsIndex on Screen
  List<int> getVisibleItemsIndex() {
    // get ListView Rect
    Rect? rect = RectGetter.getRectFromKey(listViewKey);
    List<int> items = [];
    if (rect == null) return items;

    /// TODO Horizontal ScrollDirection
    // bool isHoriontalScroll = widget.axisOrientation == Axis.horizontal;
    bool isHoriontalScroll = false;
    itemsKeys.forEach((index, key) {
      Rect? itemRect = RectGetter.getRectFromKey(key);
      if (itemRect == null) return;
      // The larger the y-axis seat, the lower the representative if the
      // coordinates above the item are larger than the coordinates below the
      // listView, it means that it is not on the screen.
      //
      // bottom meaning => The offset of the bottom edge of this widget from the y axis.
      // top meaning => The offset of the top edge of this widget from the y axis.
      //Change offset based on AxisOrientation [horizontal] [vertical]
      switch (isHoriontalScroll) {
        case true:
          if (itemRect.left > rect.right) return;
          // If the coordinates below the item are smaller than the coordinates
          // above the listView, it means that it is not on the screen.
          if (itemRect.right < rect.left) return;
          break;
        default:
          if (itemRect.top > rect.bottom) return;
          // If the coordinates below the item are smaller than the coordinates
          // above the listView, it means that it is not on the screen.
          if (itemRect.bottom <
              rect.top +
                  MediaQuery.of(context).viewPadding.top +
                  kToolbarHeight +
                  56) {
            return;
          }
      }

      items.add(index);
    });
    return items;
  }
}
