import 'package:flutter/material.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/menu/bottom_bar.dart';
import 'package:hapi/menu/menu_controller.dart';

class BottomBarMenu extends StatefulWidget {
  const BottomBarMenu(this.navPage, this.bottomBarItems, this.aliveMainWidgets);
  final NavPage navPage;
  final List<BottomBarItem> bottomBarItems;
  final List<Widget> aliveMainWidgets;

  @override
  State<BottomBarMenu> createState() => _BottomBarMenuState();
}

class _BottomBarMenuState extends State<BottomBarMenu> {
  late int _currentPage;
  late PageController _pageController;
  bool initNeeded = true;

  @override
  Widget build(BuildContext context) {
    if (initNeeded) {
      _currentPage = NavPageController.to.getLastIdx(widget.navPage);
      _pageController = PageController(initialPage: _currentPage);
      initNeeded = false;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: PageView(
        controller: _pageController,
        children: widget.aliveMainWidgets,
        onPageChanged: (newIdx) {
          NavPageController.to.setLastIdx(widget.navPage, newIdx);
          setState(() => _currentPage = newIdx);
        },
      ),
      bottomNavigationBar: BottomBar(
        // Disable to turn off bottom bar view, so menu blends to page:
        //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedIndex: _currentPage,
        items: widget.bottomBarItems,
        height: 40,
        showActiveBackgroundColor: true,
        onTap: (newIdx) {
          // already on this index, don't do anything
          if (newIdx == _currentPage) return;

          //_pageController.jumpToPage(newIdx); <-boring, use animation:
          _pageController.animateToPage(
            newIdx,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 750),
          );

          // animateToPage triggers onPageChanged above, don't need this:
          //NavPageController.to.setLastIdx(widget.navPage, newIdx);
          //setState(() => _currentPage = newIdx);
        },
      ),
    );
  }
}
