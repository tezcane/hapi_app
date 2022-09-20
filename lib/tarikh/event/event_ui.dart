import 'package:flare_flutter/flare_actor.dart' show FlareActor;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_widget.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

/// This widget will paint the event page.
/// It stores a reference to the [Event] that contains the relevant information.
class EventUI extends StatefulWidget {
  EventUI() {
    eventType = Get.arguments['eventType'];
    trKeyTitleAtInit = Get.arguments['trKeyTitleAtInit'];
  }
  late final EVENT_TYPE eventType;
  late final String trKeyTitleAtInit;

  @override
  _EventUIState createState() => _EventUIState();
}

/// The [State] for the [EventUI] will change based on the [_event]
/// parameter that's used to build it.
/// It is stateful because we rely on some information like the title, subtitle, and the event
/// contents to change when a new event is displayed. Moreover the [FlareWidget]s that are used
/// on this page (i.e. the top [EventWidget] the favorite button) rely on life-cycle parameters.
class _EventUIState extends State<EventUI> {
  late final Map<String, Event> _eventMap;
  late Event _event;
  late int _eventIdx; // TODO asdf

  late final TimeBtn _btnUp;
  late final TimeBtn _btnDn;

  late final List<Event> _favs = TarikhC.to.eventFavorites;

  /// The information for the current page.
  String _trValTitle = '';
  String _trValSubTitle = '';
  String _trValArticleMarkdown = '';

  /// This page uses the `flutter_markdown` package, and thus needs its styles to be defined
  /// with a custom objects. This is created in [initState()].
  late MarkdownStyleSheet _markdownStyleSheet;

  /// Whether the [FlareActor] favorite button is active or not.
  /// Triggers a Flare animation upon change.
  bool _isFavorite = false;

  /// This parameter helps control the Newton animations.
  /// Test it out yourself! =)
  Offset? _interactOffset;

  /// Set up the markdown style and the local field variables for this page.
  @override
  initState() {
    super.initState();

    _eventMap = TarikhC.to.getEventMap(widget.eventType);

    _btnUp = TimeBtn('', '', '', null);
    _btnDn = TimeBtn('', '', '', null);

    initEvent(widget.trKeyTitleAtInit);
  }

  initEvent(String trKeyTitle) {
    // eventIdx = newEventIdx; TODO asdf
    _event = _eventMap[trKeyTitle]!;

    TarikhC.to.updateEventBtn(_btnUp, _event.previous);
    TarikhC.to.updateEventBtn(_btnDn, _event.next);

    _trValTitle = a(_event.trKeyTitle);
    _trValSubTitle = _event.trValYearsAgo();

    TextStyle h1 = Get.theme.textTheme.headline4!
        .copyWith(fontSize: 32.0, height: 1.625, fontWeight: FontWeight.bold);
    TextStyle h2 = Get.theme.textTheme.headline5!
        .copyWith(fontSize: 24.0, height: 2, fontWeight: FontWeight.bold);
    TextStyle style =
        Get.theme.textTheme.headline6!.copyWith(fontSize: 17.0, height: 1.5);
    TextStyle strong = Get.theme.textTheme.headline6!
        .copyWith(fontSize: 17.0, height: 1.5, fontWeight: FontWeight.bold);
    TextStyle em = Get.theme.textTheme.headline6!
        .copyWith(fontSize: 17.0, height: 1.5, fontStyle: FontStyle.italic);
    _markdownStyleSheet = MarkdownStyleSheet(
      a: style,
      p: style,
      code: style,
      h1: h1,
      h2: h2,
      h3: style,
      h4: style,
      h5: style,
      h6: style,
      em: em,
      strong: strong,
      blockquote: style,
      img: style,
      blockSpacing: 20.0,
      listIndent: 20.0,
      blockquotePadding: const EdgeInsets.all(20.0),
    );
    loadMarkdown();
  }

  /// Load the markdown file from the assets and set the contents of the page to its value.
  void loadMarkdown() async {
    String trValArticleMarkdown =
        await LanguageC.to.trValArticle(_event.type, _event.trKeyTitle);
    setState(() => _trValArticleMarkdown = trValArticleMarkdown); // refresh UI
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// It uses the [BlocProvider] to find out if this element is part of the favorites, to have the icon properly set up.
  /// A [SingleChildScrollView] contains a [Column] that lays out the [EventWidget] on top, and the [MarkdownBody]
  /// right below it.
  /// A [GestureDetector] is used to control the [EventWidget], if it allows it (...try Newton!)
  @override
  Widget build(BuildContext context) {
    bool isFav = _favs.any((Event e) => e.trKeyTitle == _event.trKeyTitle);

    const double fabWidth = 71; // 56 + 15
    const double middleButtonsGap = 5;
    final double w2 = (w(context) - (fabWidth * 2) - middleButtonsGap) / 2;
    const double height = 160;

    return FabSubPage(
      subPage: SubPage.Event_UI,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: GetBuilder<TarikhC>(builder: (c) {
          String trValUpTitle1 = '';
          String trValUpTitle2 = _btnUp.trValTitle;
          List<String> btnUpList = trValUpTitle2.split('\n');
          if (btnUpList.length == 2) {
            trValUpTitle1 = btnUpList[0];
            trValUpTitle2 = btnUpList[1];
          }

          String trValDnTitle1 = '';
          String trValDnTitle2 = _btnDn.trValTitle;
          List<String> btnDnList = trValDnTitle2.split('\n');
          if (btnDnList.length == 2) {
            trValDnTitle1 = btnDnList[0];
            trValDnTitle2 = btnDnList[1];
          }

          return Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: height,
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Column dummy to easily vertical align up/down fabs:
                  SizedBox(
                    width: fabWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.eventType == EVENT_TYPE.Relic)
                            FloatingActionButton(
                              tooltip: 'i.Upgrade Relic'.tr,
                              onPressed: () {
                                // TODO asdf
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child:
                                  const Icon(Icons.start_outlined, size: 36.0),
                            ),
                          T('', tsR, w: w2, h: 17),
                          const SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: w2,
                        child: _btnUp.event == null
                            ? Container()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  T(
                                    trValUpTitle1,
                                    tsR,
                                    w: w2,
                                    h: 18,
                                    trVal: true,
                                  ),
                                  T(
                                    trValUpTitle2,
                                    tsR,
                                    w: w2,
                                    h: 18,
                                    trVal: true,
                                  ),
                                  FloatingActionButton(
                                    tooltip:
                                        widget.eventType == EVENT_TYPE.Relic
                                            ? 'i.See previous relic'.tr
                                            : 'i.Navigate to past'.tr,
                                    heroTag: 'btnUp',
                                    onPressed: () =>
                                        initEvent(_btnUp.event!.trKeyTitle),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    child: const Icon(
                                      Icons.arrow_upward_outlined,
                                      size: 30.0,
                                    ),
                                  ),
                                  T(
                                    _btnUp.trValTimeUntil,
                                    tsR,
                                    w: w2,
                                    h: 17,
                                    trVal: true,
                                  ),
                                  const SizedBox(height: 1),
                                ],
                              ),
                      ),
                      const SizedBox(width: middleButtonsGap),
                      SizedBox(
                        width: w2,
                        child: _btnDn.event == null
                            ? Container()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  T(
                                    trValDnTitle1,
                                    tsR,
                                    w: w2,
                                    h: 18,
                                    trVal: true,
                                  ),
                                  T(
                                    trValDnTitle2,
                                    tsR,
                                    w: w2,
                                    h: 18,
                                    trVal: true,
                                  ),
                                  FloatingActionButton(
                                    tooltip:
                                        widget.eventType == EVENT_TYPE.Relic
                                            ? 'i.See next relic'.tr
                                            : 'i.Navigate to future'.tr,
                                    heroTag: 'btnDn',
                                    onPressed: () =>
                                        initEvent(_btnDn.event!.trKeyTitle),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    child: const Icon(
                                      Icons.arrow_downward_outlined,
                                      size: 30.0,
                                    ),
                                  ),
                                  T(
                                    _btnDn.trValTimeUntil,
                                    tsR,
                                    w: w2,
                                    h: 17,
                                    trVal: true,
                                  ),
                                  const SizedBox(height: 1),
                                ],
                              ),
                      ),
                    ],
                  ),
                  // const SizedBox(width: rightFabWidth), // menu fab
                ],
              ),
            ),
          );
        }),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //Container(height: devicePadding.top),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onPanStart: (DragStartDetails details) {
                            setState(() {
                              _interactOffset = details.globalPosition;
                            });
                          },
                          onPanUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _interactOffset = details.globalPosition;
                            });
                          },
                          onPanEnd: (DragEndDetails details) {
                            setState(() {
                              _interactOffset = null;
                            });
                          },
                          child: Hero(
                            tag: _event.trKeyTitle,
                            child: SizedBox(
                              height: 280,
                              child: EventWidget(
                                isActive: true,
                                event: _event,
                                interactOffset: _interactOffset,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _trValTitle,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 25.0,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      _trValSubTitle,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: Transform.translate(
                                  offset: const Offset(15.0, 0.0),
                                  child: Container(
                                    height: 60.0,
                                    width: 60.0,
                                    padding: const EdgeInsets.all(15.0),

                                    /// Check out the widget at:
                                    /// https://www.2dimensions.com/a/pollux/files/flare/heart-simple/preview
                                    child: FlareActor(
                                      'assets/tarikh/flare/Favorite.flr',
                                      animation:
                                          isFav ? 'Favorite' : 'Unfavorite',
                                      shouldClip: false,
                                      color: Colors.pinkAccent,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _isFavorite = !_isFavorite;
                                  });
                                  if (_isFavorite) {
                                    TarikhC.to.addFavorite(_event);
                                  } else {
                                    TarikhC.to.removeFavorite(_event);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        MarkdownBody(
                          data: _trValArticleMarkdown,
                          styleSheet: _markdownStyleSheet,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
