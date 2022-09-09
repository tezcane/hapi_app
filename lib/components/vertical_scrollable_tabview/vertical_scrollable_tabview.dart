import 'package:flutter/material.dart';
import 'package:hapi/components/vertical_scrollable_tabview/rect_getter/rect_getter.dart';
import 'package:hapi/components/vertical_scrollable_tabview/scroll_to_index/scroll_to_index.dart';
import 'package:hapi/relic/relic_controller.dart';
import 'package:hapi/relic/relics_ui.dart';

class VerticalScrollableTabView extends StatefulWidget {
  const VerticalScrollableTabView({
    required this.relicTab,
    required this.tabController,
    required this.scrollController,
    required this.listItemData,
    required this.eachItemChild,
    required this.slivers,
//  required Axis this.scrollDirection,
  });

  final RELIC_TAB relicTab;

  /// TabBar Controller to let widget listening TabBar changed
  final TabController tabController;

  final AutoScrollController scrollController;

  /// Required a List<dynamic> Type，you can put your data that you wanna put in item
  final List<dynamic> listItemData;

  /// A callback that returns listItemData and the index of ListView.Builder
  final Widget Function(dynamic aaa, int index) eachItemChild;

  /// Required SliverAppBar, And TabBar must inside of SliverAppBar, and In the TabBar
  final List<Widget> slivers;

  /// TODO Horizontal ScrollDirection
//final Axis axisOrientation;

  @override
  VerticalScrollableTabViewState createState() =>
      VerticalScrollableTabViewState();
}

class VerticalScrollableTabViewState extends State<VerticalScrollableTabView>
    with SingleTickerProviderStateMixin {
  /// Instantiate RectGetter
  final listViewKey = RectGetter.createGlobalKey();

  /// To save the item's Rect
  Map<int, dynamic> itemsKeys = {};

  int lastSelectedTabIdx = -1;

  @override
  Widget build(BuildContext context) {
    return RectGetter(
      key: listViewKey,
      child: NotificationListener<ScrollNotification>(
        child: CustomScrollView(
          controller: widget.scrollController,
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
        controller: widget.scrollController,
        child: widget.eachItemChild(category, index),
      ),
    );
  }

  /// onScrollNotification of NotificationListener
  bool onScrollNotification(ScrollNotification notification) {
    List<int> visibleItems = getVisibleItemsIndex();
    int newIdx = visibleItems[0];

    widget.tabController.animateTo(newIdx);

    if (lastSelectedTabIdx != newIdx) {
      lastSelectedTabIdx = newIdx;
      RelicController.to.setLastSelectedTab(widget.relicTab, newIdx);
    }

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
