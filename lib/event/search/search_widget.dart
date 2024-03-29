import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

/// Draws the search bar on top of the menu.
class SearchWidget extends StatelessWidget {
  const SearchWidget(
    this.navPage,
    this._searchFocusNode,
    this._searchController,
  );
  final NavPage navPage;

  /// These two fields are passed down from the [EventSearchUI] in order to
  /// control the state of this widget depending on the users' inputs.
  final FocusNode _searchFocusNode;
  final TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {
    /// Custom implementation of the Cupertino Search bar:
    /// a rounded rectangle with the search prefix icon on the left and the
    /// cancel icon on the right only when the widget is focused.
    /// The [TextField] displays a hint when no text has been input,
    /// and it updates the [_searchController] so that the [TarikhSearchUI] can
    /// update the list of results underneath this widget.
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30.0),
      ),
      height: 56.0,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textAlign: TextAlign.center, // align UI & better for arabic support
        decoration: InputDecoration(
            hintText: at('at.{0} Search', [navPage.tkIsimA]),
            prefixIcon: const Icon(Icons.search, size: 30),
            suffixIcon: _searchFocusNode.hasFocus
                ? Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 30.0),
                      onPressed: () {
                        // clear text then bring down keyboard
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                    ),
                  )
                : Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 30.0),
                      onPressed: () {
                        // clear text then bring up keyboard
                        _searchController.clear();
                        _searchFocusNode.requestFocus();
                      },
                    ),
                  ),
            border: InputBorder.none),
        style: const TextStyle(fontSize: 20.0),
      ),
    );
  }
}
