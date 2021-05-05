import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/blocs/bloc_provider.dart';
import 'package:hapi/tarikh/main_menu/collapsible.dart';

import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/search_widget.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
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
  /// State is maintained for two reasons:
  ///
  /// 1. Search Functionality:
  /// When the search bar is tapped, the Widget view is filled with all the
  /// search info -- i.e. the [ListView] containing all the results.
  bool _isSearching = false;

  /// 2. Section Animations:
  /// Each card section contains a Flare animation that's playing in the background.
  /// These animations are paused when they're not visible anymore (e.g. when search is visible instead),
  /// and are played again once they're back in view.
  bool _isSectionActive = true;

  /// The [List] of search results that is displayed when searching.
  List<TimelineEntry> _searchResults = []; // was List<TimelineEntry>();

  /// [MenuData] is a wrapper object for the data of each Card section.
  /// This data is loaded from the asset bundle during [initState()]
  final MenuData _menu = MenuData();

  /// This is passed to the SearchWidget so we can handle text edits and display the search results on the main menu.
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;

  cancelSearch() {
    if (_searchTimer != null && _searchTimer!.isActive) {
      /// Remove old timer.
      _searchTimer!.cancel();
      _searchTimer = null;
    }
  }

  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [Navigator], and by providing the [item] as
  /// a parameter to the [TarikhTimelineUI] constructor, this widget will know
  /// where to scroll to.
  navigateToTimeline(MenuItemData item) {
    _pauseSection();

    cMenu.pushSubPage(SubPage.TARIKH_TIMELINE, arguments: {
      'focusItem': item,
      'timeline': BlocProvider.getTimeline(context),
    });

    _restoreSection(null); // TODO working? was below:
    // Navigator.of(context)
    //     .push(MaterialPageRoute(
    //       builder: (BuildContext context) =>
    //           TarikhTimelineUI(item, BlocProvider.getTimeline(context)),
    //     ))
    //     .then(_restoreSection);
  }

  // TODO what is v below:
  _restoreSection(v) => setState(() => _isSectionActive = true);
  _pauseSection() => setState(() => _isSectionActive = false);

  /// Used by the [_searchTextController] to properly update the state of this widget,
  /// and consequently the layout of the current view.
  updateSearch() {
    cancelSearch();
    if (!_isSearching) {
      setState(() {
        _searchResults = []; // was List<TimelineEntry>();
      });
      return;
    }
    String txt = _searchTextController.text.trim().toLowerCase();

    /// Perform search.
    ///
    /// A [Timer] is used to prevent unnecessary searches while the user is typing.
    _searchTimer = Timer(Duration(milliseconds: txt.isEmpty ? 0 : 350), () {
      Set<TimelineEntry> res = SearchManager.init().performSearch(txt)!;
      setState(() {
        _searchResults = res.toList();
      });
    });
  }

  initState() {
    super.initState();

    /// The [_menu] loads a JSON file that's stored in the assets folder.
    /// This asset provides all the necessary information for the cards,
    /// such as labels, background colors, the background Flare animation asset,
    /// and for each element in the expanded card, the relative position on the [Timeline].
    _menu.loadFromBundle('assets/tarikh/menu.json').then((bool success) {
      if (success) setState(() {}); // Load the menu.
    });

    _searchTextController.addListener(() {
      updateSearch();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
        updateSearch();
      });
    });
  }

  /// A [WillPopScope] widget wraps the menu, so that before dismissing the whole app,
  /// search will be popped first. Otherwise the app will proceed as usual.
  Future<bool> _popSearch() {
    if (_isSearching) {
      setState(() {
        _searchFocusNode.unfocus();
        _searchTextController.clear();
        _isSearching = false;
      });
      return Future(() => false);
    } else {
      Get.back(); // Navigator.of(context).pop(true);
      return Future(() => true);
    }
  }

  void _tapSearchResult(TimelineEntry entry) {
    navigateToTimeline(MenuItemData.fromEntry(entry));
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;

    List<Widget> tail = [];

    /// Check the current state before creating the layout for the menu (i.e. [tail]).
    ///
    /// If the app is searching, lay out the results.
    /// Otherwise, insert the menu information with all the various sections.
    if (_isSearching) {
      for (int i = 0; i < _searchResults.length; i++) {
        tail.add(RepaintBoundary(
            child: ThumbnailDetailWidget(_searchResults[i],
                hasDivider: i != 0, tapSearchResult: _tapSearchResult)));
      }
    } else {
      tail
        ..addAll(_menu.sections
            .map<Widget>((MenuSectionData section) => Container(
                margin: EdgeInsets.only(top: 20.0),
                child: MenuSection(
                  section.label!,
                  section.backgroundColor!,
                  section.textColor!,
                  section.items,
                  navigateToTimeline,
                  _isSectionActive,
                  assetId: section.assetId!,
                )))
            .toList(growable: false))
        ..add(
          Container(
            margin: EdgeInsets.only(top: 40.0, bottom: 22),
            height: 1.0,
            color: const Color.fromRGBO(151, 151, 151, 0.29),
          ),
        )
        ..add(
          FlatButton(
            onPressed: () {
              _pauseSection();
              cMenu.pushSubPage(SubPage.TARIKH_FAVORITE);
              _restoreSection(null); // TODO working?
            },
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15.5),
                  child: Image.asset('assets/tarikh/heart_icon.png',
                      height: 20.0,
                      width: 20.0,
                      color: Colors.black.withOpacity(0.65)),
                ),
                Text(
                  'Your Favorites',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'RobotoMedium',
                      color: Colors.black.withOpacity(0.65)),
                )
              ],
            ),
          ),
        );
    }

    /// Wrap the menu in a [WillPopScope] to properly handle a pop event while searching.
    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    /// This will contain a [Column] with a [Collapsible] header on top, and a [tail]
    /// that's built according with the state of this widget.
    return FabNavPage(
      navIdx: NavPage.TARIKH.index,
      columnWidget: Column(),
      bottomWidget: HapiShare(),
      // TODO move to FabNavPage?:
      foregroundPage: WillPopScope(
        onWillPop: _popSearch,
        child: Container(
          color: background,
          child: Padding(
            padding: EdgeInsets.only(top: devicePadding.top),
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                        Collapsible(
                          isCollapsed: _isSearching,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Tarikh',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: darkText
                                        .withOpacity(darkText.opacity * 0.75),
                                    fontSize: 34.0,
                                    fontFamily: 'RobotoMedium'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 22.0),
                          child: SearchWidget(
                              _searchFocusNode, _searchTextController),
                        )
                      ] +
                      tail),
            ),
          ),
        ),
      ),
    );
  }
}
