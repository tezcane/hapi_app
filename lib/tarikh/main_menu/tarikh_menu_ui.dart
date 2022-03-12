import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

/// The Main Page of the Timeline App.
///
/// This Widget lays out the search bar at the top of the page,
/// the three card-sections for accessing the main events on the Timeline,
/// and it'll provide on the bottom three links for quick access to your Favorites,
/// a Share Menu and the About Page.
class TarikhMenuUI extends StatefulWidget {
  const TarikhMenuUI({Key? key}) : super(key: key);

  @override
  _TarikhMenuUIState createState() => _TarikhMenuUIState();
}

class _TarikhMenuUIState extends State<TarikhMenuUI> {
  /// 2. Section Animations:
  /// Each card section contains a Flare animation that's playing in the
  /// background. These animations are paused when they're not visible anymore
  /// (e.g. when search is visible instead), and are played again once they're
  /// back in view.
  //bool _isSectionActive = TarikhController.to.isSectionActive;

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator], and by providing the [item] as
  /// a parameter to the [TarikhTimelineUI] constructor, this widget will know
  /// where to scroll to.
  navigateToTimeline(MenuItemData item) {
    TarikhController.to.pauseMenuSection();

    MenuController.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'entry': null}, // null= up/dn btns not set
    );
  }

  @override
  initState() {
    //print('tarikh init state 1, isAppInitDone=${cMain.isAppInitDone}');

    /// The [_menu] loads a JSON file that's stored in the assets folder.
    /// This asset provides all the necessary information for the cards,
    /// such as labels, background colors, the background Flare animation asset,
    /// and for each element in the expanded card, the relative position on the [Timeline].
    _menu.loadFromBundle('assets/tarikh/menu.json').then((bool success) {
      //print('tarikh init state 2, isAppInitDone=${cMain.isAppInitDone}');
      if (success) setState(() {}); // Load the menu.
    }); // TODO bug here on hot reload breaks auto rotate

    super.initState();
  }

  // prob need to do something here to avoid hot reload issue
  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tail = [];

    tail
      ..addAll(_menu.menuSectionDataList
          .map<Widget>(
            (MenuSectionData section) => Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: GetBuilder<TarikhController>(builder: (c) {
                return MenuSection(
                  section.label,
                  section.backgroundColor,
                  section.textColor,
                  section.items,
                  navigateToTimeline,
                  c.isSectionActive,
                  assetId: section.assetId,
                );
              }),
            ),
          )
          .toList(growable: false))
      // add some space under the final vignette so FABs don't interfere
      ..add(
        /// this is the little line that shows under the vignettes
        Container(
          margin: const EdgeInsets.only(top: 40.0, bottom: 22),
          height: 1.0,
          color: const Color.fromRGBO(151, 151, 151, 0.29),
        ),
      );

    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    return Scaffold(
      floatingActionButton: GetBuilder<MenuController>(
        builder: (c) => Visibility(
          visible: !c.isMenuShowing(),
          //maintainAnimation: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 75.0),
            child: FloatingActionButton(
              tooltip: 'View your favorites',
              heroTag: SubPage.Tarikh_Favorite,
              onPressed: () {
                setState(() {
                  TarikhController.to.pauseMenuSection();
                  MenuController.to.pushSubPage(SubPage.Tarikh_Favorite);
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              child: const Icon(Icons.favorite_border_outlined, size: 36.0),
            ),
          ),
        ),
      ),
      body: Scaffold(
        floatingActionButton: GetBuilder<MenuController>(
          builder: (c) => Visibility(
            visible: !c.isMenuShowing(),
            child: Padding(
              padding: const EdgeInsets.only(right: 150.0),
              child: FloatingActionButton(
                tooltip: 'Search history',
                heroTag: SubPage.Tarikh_Search,
                onPressed: () {
                  setState(() {
                    TarikhController.to.pauseMenuSection();
                    MenuController.to.pushSubPage(SubPage.Tarikh_Search);
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(Icons.search_outlined, size: 36.0),
              ),
            ),
          ),
        ),
        body: FabNavPage(
          navPage: NavPage.Tarikh,
          settingsWidget: null,
          bottomWidget: HapiShareUI(),
          foregroundPage: Container(
            color: Theme.of(context).backgroundColor,
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: tail,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
