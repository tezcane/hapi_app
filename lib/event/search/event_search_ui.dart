import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/search/search_manager.dart';
import 'package:hapi/event/search/search_widget.dart';
import 'package:hapi/event/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

class EventSearchUI extends StatefulWidget {
  const EventSearchUI(this.navPage);
  final NavPage navPage;

  @override
  _EventSearchUIState createState() => _EventSearchUIState();
}

class _EventSearchUIState extends State<EventSearchUI> {
  /// The [List] of search results that is displayed when searching.
  List<Event> _searchResults = [];

  /// This is passed to the SearchWidget so we can handle text edits and display
  /// the search results on the main menu.
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;

  /// Used to scroll to bottom of list view whenever page is rebuilt
  final ScrollController _scrollController = ScrollController();

  bool scrollToEnd = false;
  bool initNeeded = true;

  @override
  initState() {
    // init list search on page
    String lastSearch = s.rd('lastSearch${widget.navPage.name}') ?? '';
    _searchTextController.text = lastSearch;
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
    _cancelSearch();
    _searchFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  /// If query is blank it returns all results
  List<Event> _getSortedSearchResults(String query) {
    List<Event> searchResult =
        SearchManager.init().performSearch(widget.navPage, query).toList();

    // Sort by starting time, so results are displayed in ascending order
    searchResult.sort((Event a, Event b) {
      return a.start.compareTo(b.start);
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

  void _cancelSearch() {
    if (_searchTimer != null && _searchTimer!.isActive) {
      /// Remove old timer.
      _searchTimer!.cancel();
      _searchTimer = null;
    }
  }

  /// Used by the [_searchTextController] to properly update the state of this widget,
  /// and consequently the layout of the current view.
  _updateSearch() {
    _cancelSearch();

    String query = _searchTextController.text.trim().toLowerCase();

    /// Perform search.
    /// A [Timer] is used to prevent unnecessary searches while the user is typing.
    _searchTimer = Timer(Duration(milliseconds: query.isEmpty ? 0 : 350), () {
      s.wr('lastSearch${widget.navPage.name}', _searchTextController.text);
      List<Event> searchResults = _getSortedSearchResults(query);
      setState(() {
        _searchResults = searchResults;
      });
    });
  }

  void _onLayoutDone(_) {
    if (scrollToEnd) {
      _scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TarikhC>(builder: (c) {
      if (c.isTimelineInitDone && initNeeded) {
        initNeeded = false;
        _updateSearch(); // needed for init
      }

      if (initNeeded) {
        return const Center(child: T('بِسْمِ ٱللَّٰهِ', tsN, tv: true));
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
          //TODO RTL ok?
          padding: const EdgeInsets.only(
            left: 20,
            top: 16.0,
            bottom: 16.0,
            right: 85,
          ),
          child: SearchWidget(
            widget.navPage,
            _searchFocusNode,
            _searchTextController,
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _searchResults.length + 1,
                itemBuilder: (BuildContext context, int idx) {
                  if (idx == 0) {
                    return SizedBox(height: heightPadding);
                  } else {
                    return RepaintBoundary(
                      // NOTE: Can't do hero animation from EventFavoriteUI and
                      //       EventSearchUI as event can be on both.
                      child: ThumbnailDetailWidget(
                        widget.navPage,
                        _searchResults[idx - 1],
                        hasDivider: idx != 1,
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
