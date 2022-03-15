import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/helpers/keep_alive_page.dart';
import 'package:hapi/menu/menu_controller.dart';

class BottomBarMenu extends StatefulWidget {
  const BottomBarMenu(
      this.navPage, this.bottomBarItemList, this.aliveMainWidgets);
  final NavPage navPage;
  final List<BottomBarItem> bottomBarItemList;
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
      bottomNavigationBar: Row(
        children: [
          BottomBar(
            // Disable to turn off bottom bar view, so menu blends to page:
            //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedIndex: _currentPage,
            showActiveBackgroundColor: true,
            onTap: (newIdx) {
              if (newIdx == _currentPage) {
                return; // already on this index, don't do anything
              }
              //_pageController.jumpToPage(newIdx); <-boring, use animation:
              _pageController.animateToPage(
                newIdx,
                //curve: Curves.easeInOut,
                //curve: Curves.elasticOut,
                curve: newIdx > _currentPage
                    ? Curves.easeInOut // move right
                    : Curves.elasticOut, // move left
                duration: const Duration(milliseconds: 650),
              );
              NavPageController.to.setLastIdx(widget.navPage, newIdx);
              setState(() => _currentPage = newIdx);
            },
            itemPadding:
                const EdgeInsets.only(top: 5, bottom: 5, left: 16, right: 16),
            items: widget.bottomBarItemList,
          ),
          //const SizedBox(), not needed Row is using MainAxis.start
        ],
      ),
    );
  }
}

class BBItem extends BottomBarItem {
  BBItem(
    this.navPage,
    this.mainWidget,
    this.settingsWidget,
    Color color,
    IconData iconData,
    String title,
    String tooltip, {
    bool useHapiLogoFont = true,
  }) : super(
          activeColor: color,
          icon: Tooltip(
            message: tooltip,
            child: iconData == Icons.brightness_3_outlined // hapi crescent logo
                ? Transform.rotate(
                    angle: 2.8, // Rotates crescent
                    child: Icon(iconData, size: 30.0))
                : Icon(iconData, size: 30.0),
          ),
          title: Tooltip(
            message: tooltip,
            child: Container(
              // magic fixed the BBItems on the page finally... TODO will cut i18n text
              constraints: const BoxConstraints(
                minWidth: 60, // Tune this
                maxWidth: 60,
              ),
              child: Center(
                child: Text(
                  title,
                  style: useHapiLogoFont || title == 'hapi'
                      ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lobster',
                          fontSize: 17)
                      : const TextStyle(fontSize: 17),
                ),
              ),
            ),
          ),
        );

  final NavPage navPage;
  final Widget mainWidget;
  final Widget? settingsWidget;

  Widget get aliveMainWidget => KeepAlivePage(child: mainWidget);
}
