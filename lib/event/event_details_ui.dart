import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:hapi/event/animation_controller/heart_controller.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/et_extension.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_c.dart';
import 'package:hapi/event/event_widget.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/tarikh_c.dart';

/// Show detailed info about an Tarikh/Relic Event and allow it to be added or
/// removed from Tarikh/Relic favorites. If Relics view, show upgrade button.
class EventDetailsUI extends StatefulWidget {
  EventDetailsUI() {
    et = Get.arguments['et'];
    eventMap = Get.arguments['eventMap'];
    saveTag = Get.arguments['saveTag'];
  }
  late final ET et;
  late final Map<String, Event> eventMap;
  late final String saveTag;

  @override
  _EventDetailsUIState createState() => _EventDetailsUIState();
}

/// The [State] for the [EventDetailsUI] will change based on the [_event]
/// parameter that's used to build it.
/// It is stateful because we rely on some information like the title, subtitle, and the event
/// contents to change when a new event is displayed. Moreover the [FlareWidget]s that are used
/// on this page (i.e. the top [EventWidget] the favorite button) rely on life-cycle parameters.
class _EventDetailsUIState extends State<EventDetailsUI> {
  late Event _event;

  late final TimeBtn _btnUp;
  late final TimeBtn _btnDn;

  late final Map<String, Event> _eventMapFav;

  final heartControllerFav = HeartController('Favorite');
  final heartControllerUnfav = HeartController('Unfavorite');

  /// The information for the current page.
  String _tvTitle1 = '';
  String _tvTitle2 = '';
  String _tvYearsAgo = '';
  String _tvArticleMarkdown = '';

  /// This page uses the `flutter_markdown` package, and thus needs its styles to be defined
  /// with a custom objects. This is created in [initState()].
  late MarkdownStyleSheet _markdownStyleSheet;

  /// This parameter helps control the Newton animations.
  /// Test it out yourself! =)
  Offset? _interactOffset;

  /// Set up the markdown style and the local field variables for this page.
  @override
  initState() {
    super.initState();

    _eventMapFav = EventC.to.getEventMapFav(widget.et);

    _btnUp = TimeBtn('', '', '', '', null);
    _btnDn = TimeBtn('', '', '', '', null);

    _initEvent(widget.saveTag);
  }

  // TODO SCROLL TO THE TOP OF SCREEN ON NEW LOAD
  _initEvent(String saveTag) {
    _event = widget.eventMap[saveTag]!;

    _btnUp.event = _event; //need to init here so first updateEventBtn() works
    _btnDn.event = _event;

    _updateEventBtn(_btnUp, _event.previous);
    _updateEventBtn(_btnDn, _event.next);

    _tvTitle1 = _event.tvTitleLine1;
    _tvTitle2 = _event.tvTitleLine2;
    _tvYearsAgo = _event.tvYearsAgo();

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
    String tvArticleMarkdown =
        await LangC.to.tvArticle(_event.et, _event.tkTitle);
    setState(() => _tvArticleMarkdown = tvArticleMarkdown); // refresh UI
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// It uses the [BlocProvider] to find out if this element is part of the favorites, to have the icon properly set up.
  /// A [SingleChildScrollView] contains a [Column] that lays out the [EventWidget] on top, and the [MarkdownBody]
  /// right below it.
  /// A [GestureDetector] is used to control the [EventWidget], if it allows it (...try Newton!)
  @override
  Widget build(BuildContext context) {
    bool isFavorite = _eventMapFav.containsKey(_event.saveTag);
    if (isFavorite) {
      heartControllerFav.showParticles(true);
      heartControllerUnfav.showParticles(true);
    } else {
      heartControllerFav.showParticles(false);
      heartControllerUnfav.showParticles(false);
    }

    final double wScreen = w(context);
    final double whTopAsset = wScreen * .80;

    const double fabWidth = 71; // 56 + 15
    const double middleButtonsGap = 5;
    final double w2 = (wScreen - (fabWidth * 2) - middleButtonsGap) / 2;
    const double height = 160;

    return FabSubPage(
      subPage: SubPage.Event_Details,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: GetBuilder<TarikhC>(builder: (c) {
          return Align(
            alignment: Alignment.bottomLeft,
            child: Directionality(
              textDirection: TextDirection.ltr,
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
                        //TODO RTL ok?
                        padding: const EdgeInsets.only(left: 15),
//                      padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (widget.et.isRelic)
                              FloatingActionButton(
                                tooltip: 'Upgrade Relic'.tr,
                                onPressed: () {
                                  // TODO asdf
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                child: const Icon(
                                  Icons.start_outlined,
                                  size: 36.0,
                                ),
                              ),
                            T('', tsRe, w: w2, h: 17),
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
                                      _btnUp.tvTitleLine1,
                                      tsRe,
                                      w: w2,
                                      h: 18,
                                      tv: true,
                                    ),
                                    if (_btnUp.tvTitleLine2 != '')
                                      T(
                                        _btnUp.tvTitleLine2,
                                        tsRe,
                                        w: w2,
                                        h: 18,
                                        tv: true,
                                      ),
                                    FloatingActionButton(
                                      tooltip: widget.et.isRelic
                                          ? 'See previous relic'.tr
                                          : 'Navigate to past'.tr,
                                      heroTag: 'btnUp',
                                      onPressed: () =>
                                          _initEvent(_btnUp.event!.saveTag),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      child: const Icon(
                                        Icons.arrow_upward_outlined,
                                        size: 30.0,
                                      ),
                                    ),
                                    T(
                                      _btnUp.tvTimeUntil,
                                      tsRe,
                                      w: w2,
                                      h: 17,
                                      tv: true,
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
                                      _btnDn.tvTitleLine1,
                                      tsRe,
                                      w: w2,
                                      h: 18,
                                      tv: true,
                                    ),
                                    if (_btnDn.tvTitleLine2 != '')
                                      T(
                                        _btnDn.tvTitleLine2,
                                        tsRe,
                                        w: w2,
                                        h: 18,
                                        tv: true,
                                      ),
                                    FloatingActionButton(
                                      tooltip: widget.et.isRelic
                                          ? 'See next relic'.tr
                                          : 'Navigate to future'.tr,
                                      heroTag: 'btnDn',
                                      onPressed: () =>
                                          _initEvent(_btnDn.event!.saveTag),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      child: const Icon(
                                        Icons.arrow_downward_outlined,
                                        size: 30.0,
                                      ),
                                    ),
                                    T(
                                      _btnDn.tvTimeUntil,
                                      tsRe,
                                      w: w2,
                                      h: 17,
                                      tv: true,
                                    ),
                                    const SizedBox(height: 1),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // Container(height: devicePadding.top),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
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
                          // child: Hero( TODO
                          //   tag: _event.tkTitle,
                          // Center needed:
                          child: Center(
                            child: SizedBox(
                              height: whTopAsset,
                              width: whTopAsset,
                              child: _event.asset.widget(true, _interactOffset),
                            ),
                          ),
                          // ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    T(
                                      _tvTitle1,
                                      const TextStyle(
                                        fontSize: 25.0,
                                        height: 1.1,
                                      ),
                                      alignment: LangC.to.centerLeft,
                                    ),
                                    if (_tvTitle2 != '')
                                      T(
                                        _tvTitle2,
                                        const TextStyle(
                                          fontSize: 25.0,
                                          height: 1.1,
                                        ),
                                        alignment: LangC.to.centerLeft,
                                      ),
                                    T(
                                      _tvYearsAgo,
                                      const TextStyle(
                                        fontSize: 17.0,
                                        height: 1.5,
                                      ),
                                      alignment: LangC.to.centerLeft,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 55.0,
                                  width: 55.0,
                                  padding: LangC.to.isLTR
                                      ? const EdgeInsets.only(right: 20.0)
                                      : const EdgeInsets.only(left: 20.0),
                                  child: Hero(
                                    tag: Icons.favorite_border_outlined,
                                    child: isFavorite
                                        ? FlareActor(
                                            'assets/tarikh/flare/Favorite.flr',
                                            animation: 'Favorite', // needed
                                            shouldClip: false,
                                            color: Colors.pinkAccent,
                                            controller: heartControllerFav,
                                          )
                                        : FlareActor(
                                            'assets/tarikh/flare/Favorite.flr',
                                            animation: 'Unfavorite', // needed
                                            shouldClip: false,
                                            color: Colors.pinkAccent,
                                            controller: heartControllerUnfav,
                                          ),
                                  ),
                                ),
                                onTap: () {
                                  if (!isFavorite) {
                                    EventC.to.addFavorite(widget.et, _event);
                                  } else {
                                    EventC.to.delFavorite(widget.et, _event);
                                  }
                                  setState(() {});
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
                          data: _tvArticleMarkdown,
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

  void _updateEventBtn(TimeBtn timeBtn, Event? event) {
    String tvTitle1 = '';
    String tvTitle2 = '';
    String tvTimeUntil = '';

    if (event != null) {
      tvTitle1 = event.tvTitleLine1;
      tvTitle2 = event.tvTitleLine2;
      if (event.isTimeLineEvent && timeBtn.event!.isTimeLineEvent) {
        double timeUntilDouble = (event.start - timeBtn.event!.start).abs();
        tvTimeUntil = event.tvYears(timeUntilDouble).toLowerCase();
      }
    }

    timeBtn.event = event;
    timeBtn.tvTitleLine1 = tvTitle1;
    timeBtn.tvTitleLine2 = tvTitle2;
    timeBtn.tvTimeUntil = tvTimeUntil;
  }
}
