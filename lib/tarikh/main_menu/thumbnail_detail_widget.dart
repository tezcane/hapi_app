import 'package:flutter/material.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

import 'thumbnail.dart';

/// Define a custom function for the callback that's passed into this widget by the [MainMenuWidget].
///
/// This callback allows the [MainMenuWidget] to display the [TarikhTimelineUI] and position it
/// to the right start/end time for the [entry].
typedef TapSearchResultCallback = Function(TimelineEntry entry);

/// This widget lays out nicely the [timelineEntry] provided.
///
/// It shows the [ThumbnailWidget] for that entry on the left, and the label with the date of the entry
/// on its immediate right.
///
/// This widget is used while displaying the search results in the [MainMenuWidget], and in the
/// [FavoritesPage] widget.
class ThumbnailDetailWidget extends StatelessWidget {
  const ThumbnailDetailWidget(this.timelineEntry,
      {this.hasDivider = true, this.tapSearchResult, Key? key})
      : super(key: key);

  final TimelineEntry timelineEntry;

  /// Whether to show a divider line on the bottom of this widget. Defaults to `true`.
  final bool hasDivider;

  /// Callback to navigate to the timeline (see [MainMenuWidget._tapSearchResult()]).
  final TapSearchResultCallback? tapSearchResult;

  /// Use [Material] & [InkWell] to show a Material Design ripple effect on the row.
  /// [InkWell] provides also a callback for custom onTap behavior.
  ///
  /// The widget is laid out with a [Column] that lays out the contents of the entry, and the divider,
  /// and a [Row], which contains the [ThumbnailWidget], and the entry information.
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (tapSearchResult != null) {
              tapSearchResult!(timelineEntry);
            }
          },
          child: Column(
            children: <Widget>[
              hasDivider
                  ? Container(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ThumbnailWidget(timelineEntry),
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.only(left: 17.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timelineEntry.label,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              timelineEntry.formatYearsAgo(),
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ]),
                    ))
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
