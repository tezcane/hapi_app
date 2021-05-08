import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';
import 'package:hapi/menu/fab_nav_page.dart';

/// The Main Page of the Timeline App.
///
/// This Widget lays out the search bar at the top of the page,
/// the three card-sections for accessing the main events on the Timeline,
/// and it'll provide on the bottom three links for quick access to your Favorites,
/// a Share Menu and the About Page.
class TarikhMenuUI extends StatefulWidget {
  TarikhMenuUI({Key? key}) : super(key: key);

  @override
  _TarikhMenuUIState createState() => _TarikhMenuUIState();
}

class _TarikhMenuUIState extends State<TarikhMenuUI> {
  /// 2. Section Animations:
  /// Each card section contains a Flare animation that's playing in the background.
  /// These animations are paused when they're not visible anymore (e.g. when search is visible instead),
  /// and are played again once they're back in view.
  bool _isSectionActive = true;

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator], and by providing the [item] as
  /// a parameter to the [TarikhTimelineUI] constructor, this widget will know
  /// where to scroll to.
  navigateToTimeline(MenuItemData item) {
    _pauseSection();

    cMenu.pushSubPage(SubPage.TARIKH_TIMELINE, arguments: {'focusItem': item});

    //_restoreSection(null); // TODO working? was below:

    // Navigator.of(context)
    //     .push(MaterialPageRoute(
    //       builder: (BuildContext context) =>
    //           TarikhTimelineUI(item, BlocProvider.getTimeline(context)),
    //     ))
    //     .then(_restoreSection); // <- TODO how to do this with Getx?
  }

  // TODO BUG anytime we go two menu deep away from here,
  //    animation does not resume on return
  // TODO what is v below:
  //_restoreSection(v) => setState(() => _isSectionActive = true);
  _pauseSection() => setState(() => _isSectionActive = false);

  initState() {
    /// The [_menu] loads a JSON file that's stored in the assets folder.
    /// This asset provides all the necessary information for the cards,
    /// such as labels, background colors, the background Flare animation asset,
    /// and for each element in the expanded card, the relative position on the [Timeline].
    _menu.loadFromBundle('assets/tarikh/menu.json').then((bool success) {
      if (success) setState(() {}); // Load the menu.
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tail = [];

    tail
      ..addAll(_menu.sections
          .map<Widget>(
            (MenuSectionData section) => Container(
              margin: EdgeInsets.only(top: 20.0),
              child: MenuSection(
                section.label!,
                section.backgroundColor!,
                section.textColor!,
                section.items,
                navigateToTimeline,
                _isSectionActive,
                assetId: section.assetId!,
              ),
            ),
          )
          .toList(growable: false))
      ..add(
        Container(
          margin: EdgeInsets.only(top: 40.0, bottom: 22),
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
              heroTag: SubPage.TARIKH_FAVORITE,
              onPressed: () {
                setState(() {
                  _pauseSection();
                  cMenu.pushSubPage(SubPage.TARIKH_FAVORITE);
                  // TODO working?:
                  //_restoreSection(null);
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              //backgroundColor: Colors.green,
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
                heroTag: SubPage.TARIKH_SEARCH,
                onPressed: () {
                  setState(() {
                    _pauseSection();
                    cMenu.pushSubPage(SubPage.TARIKH_SEARCH);
                    // TODO working?:
                    //_restoreSection(null);
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                //backgroundColor: Colors.green,
                child: const Icon(Icons.search_outlined, size: 36.0),
              ),
            ),
          ),
        ),
        body: FabNavPage(
          navPage: NavPage.TARIKH,
          columnWidget: Column(),
          bottomWidget: HapiShare(),
          foregroundPage: Container(
            color: background, //AppThemes.logoBackground, //background,
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
