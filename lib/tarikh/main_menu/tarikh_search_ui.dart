import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/search_widget.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

class TarikhSearchUI extends StatefulWidget {
  const TarikhSearchUI({Key? key}) : super(key: key);

  @override
  _TarikhSearchUIState createState() => _TarikhSearchUIState();
}

class _TarikhSearchUIState extends State<TarikhSearchUI> {
  /// The [List] of search results that is displayed when searching.
  List<TimelineEntry> _searchResults = []; // was List<TimelineEntry>();

  /// This is passed to the SearchWidget so we can handle text edits and display the search results on the main menu.
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // TODO not used, can move out
  Timer? _searchTimer;

  /// Used to scroll to bottom of list view whenever page is rebuilt
  ScrollController _scrollController = ScrollController();

  bool scrollToEnd = false;

  initState() {
    _searchResults = getSortedSearchResults(''); // init list on page

    _searchTextController.addListener(() => _updateSearch());

    //_searchFocusNode.addListener(() => setState(() => _updateSearch()));

    // Enable to have keyboard pop up on page init:
    //_searchFocusNode.requestFocus();

    super.initState();
  }

  /// If query is blank it returns all results
  List<TimelineEntry> getSortedSearchResults(String query) {
    List<TimelineEntry> searchResult =
        SearchManager.init().performSearch(query).toList();

    /// Sort by starting time, so the search list is always displayed in ascending order.
    searchResult.sort((TimelineEntry a, TimelineEntry b) {
      return a.start!.compareTo(b.start!);
    });

    return searchResult;
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) {
      return;
    }

    var scrollPosition = _scrollController.position;

    if (scrollPosition.maxScrollExtent > scrollPosition.minScrollExtent) {
      _scrollController.animateTo(
        scrollPosition.maxScrollExtent,
        duration: new Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  /// Used by the [_searchTextController] to properly update the state of this widget,
  /// and consequently the layout of the current view.
  _updateSearch() {
    // cancelSearch:
    if (_searchTimer != null && _searchTimer!.isActive) {
      /// Remove old timer.
      _searchTimer!.cancel();
      _searchTimer = null;
    }

    String query = _searchTextController.text.trim().toLowerCase();

    /// Perform search.
    /// A [Timer] is used to prevent unnecessary searches while the user is typing.
    _searchTimer = Timer(Duration(milliseconds: query.isEmpty ? 0 : 350), () {
      setState(() {
        _searchResults = getSortedSearchResults(query);
      });
    });
  }

  void _tapSearchResult(TimelineEntry entry) {
    cMenu.pushSubPage(SubPage.TARIKH_TIMELINE, arguments: {
      'focusItem': MenuItemData.fromEntry(entry),
      'timeline': cTrkh.timeline,
    });
  }

  void _onLayoutDone(_) {
    if (scrollToEnd) {
      _scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    double heightPadding = 0;

    // TODO TUNE THIS, BUT IT WORKS WELL:
    if (_searchResults.length < 10) {
      heightPadding = MediaQuery.of(context).size.height - 150;
      scrollToEnd = true;
    } else {
      scrollToEnd = false;
    }

    // TODO Can delete this old hack:
    //Timer(Duration(milliseconds: 200), () => _scrollToEnd());
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback(_onLayoutDone);
    }

    return FabSubPage(
      subPage: SubPage.TARIKH_SEARCH,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Colors.white.withOpacity(0.0),
          padding:
              EdgeInsets.only(left: 20, top: 16.0, bottom: 16.0, right: 85),
          child: SearchWidget(_searchFocusNode, _searchTextController),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _searchResults.length + 1,
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 0),
                itemBuilder: (BuildContext context, int idx) {
                  if (idx == 0) {
                    return SizedBox(height: heightPadding);
                  } else {
                    return RepaintBoundary(
                      child: ThumbnailDetailWidget(
                        _searchResults[idx - 1],
                        hasDivider: idx != 1,
                        tapSearchResult: _tapSearchResult,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
