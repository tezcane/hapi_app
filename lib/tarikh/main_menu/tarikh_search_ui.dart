import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/search_widget.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

class TarikhSearchUI extends StatefulWidget {
  const TarikhSearchUI();

  @override
  _TarikhSearchUIState createState() => _TarikhSearchUIState();
}

class _TarikhSearchUIState extends State<TarikhSearchUI> {
  /// The [List] of search results that is displayed when searching.
  List<TimelineEntry> _searchResults = [];

  /// This is passed to the SearchWidget so we can handle text edits and display
  /// the search results on the main menu.
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;

  /// Used to scroll to bottom of list view whenever page is rebuilt
  final ScrollController _scrollController = ScrollController();

  bool scrollToEnd = false;
  bool initialized = false;

  @override
  initState() {
    // init list search on page
    String lastHistorySearch = s.rd('lastHistorySearch') ?? '';
    _searchTextController.text = lastHistorySearch;
    _updateSearch();

    _searchTextController.addListener(() => _updateSearch());

    // Enable to have keyboard pop up on page init:
    //_searchFocusNode.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    // if keyboard showed, must hide status/bottom bar:
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    //_searchResults = [];
    cancelSearch();
    _searchFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// If query is blank it returns all results
  List<TimelineEntry> getSortedSearchResults(String query) {
    List<TimelineEntry> searchResult =
        SearchManager.init().performSearch(query).toList();

    /// Sort by starting time, so the search list is always displayed in ascending order.
    searchResult.sort((TimelineEntry a, TimelineEntry b) {
      return a.startMs.compareTo(b.startMs);
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void cancelSearch() {
    if (_searchTimer != null && _searchTimer!.isActive) {
      /// Remove old timer.
      _searchTimer!.cancel();
      _searchTimer = null;
    }
  }

  /// Used by the [_searchTextController] to properly update the state of this widget,
  /// and consequently the layout of the current view.
  _updateSearch() {
    cancelSearch();

    String query = _searchTextController.text.trim().toLowerCase();

    /// Perform search.
    /// A [Timer] is used to prevent unnecessary searches while the user is typing.
    _searchTimer = Timer(Duration(milliseconds: query.isEmpty ? 0 : 350), () {
      s.wr('lastHistorySearch', _searchTextController.text);
      List<TimelineEntry> searchResults = getSortedSearchResults(query);
      setState(() {
        _searchResults = searchResults;
      });
    });
  }

  void _tapSearchResult(TimelineEntry entry) {
    MenuItemData item = MenuItemData.fromEntry(entry);
    MenuController.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'entry': entry},
    );
  }

  void _onLayoutDone(_) {
    if (scrollToEnd) {
      _scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TarikhController>(builder: (c) {
      if (c.isTimelineInitDone && !initialized) {
        initialized = true;
        _updateSearch(); // needed for init
      }

      double heightPadding = 0;

      // TODO TUNE THIS, BUT IT WORKS WELL:
      if (_searchResults.length < 10) {
        heightPadding = MediaQuery.of(context).size.height - 150;
        scrollToEnd = true;
      } else {
        scrollToEnd = false;
      }

      WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);

      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(
              left: 20, top: 16.0, bottom: 16.0, right: 85),
          child: SearchWidget(_searchFocusNode, _searchTextController),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _searchResults.length + 1,
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
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
      );
    });
  }
}
