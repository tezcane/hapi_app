import 'dart:math' as math;

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/athan/Zaman.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:im_animations/im_animations.dart';

class ActiveQuestsUI extends StatelessWidget {
  static const double SALAH_ACTIONS_HEIGHT = 62;

  static const TextStyle textStyleAppBar =
      const TextStyle(fontSize: 9.5, color: Colors.white);
  static const TextStyle textStyleAppBarTime =
      const TextStyle(fontSize: 24.0, color: Colors.white);

  static const Color textColor = Colors.white;
  static const TextStyle textStyleWhite = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle textStyleFard = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.red);
  static const TextStyle textStyleMuak = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.green);
  static final TextStyle textStyleNafl = TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      color: Colors.amber.shade700);
  static final TextStyle textStyleDuha = TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      color: Colors.yellow.shade300);

  static final TextStyle textStyleQiyam = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.cyan.shade300);
  static final TextStyle textStyleTahajjud = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.blue.shade100);
  static const TextStyle textStyleWitr = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.pinkAccent);

  static final FlipCardController flipCardControllerFajr = FlipCardController();
  static final FlipCardController flipCardControllerDhuhr =
      FlipCardController();
  static final FlipCardController flipCardControllerLayl = FlipCardController();

  GetBuilder salahAppBar() {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(c.prayerTimes!.currZaman.name(),
                                  style: textStyleAppBar),
                              Text(' ends', style: textStyleAppBar),
                              SizedBox(width: 1),
                              Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 5),
                            ],
                          ),
                          Row(
                            children: [
                              Text(c.prayerTimes!.nextZaman.name(),
                                  style: textStyleAppBar),
                              Text(' in', style: textStyleAppBar),
                              SizedBox(width: 1),
                              Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 5),
                            ],
                          ),
                        ],
                      ),
                      GetX<ZamanController>(builder: (ZamanController c) {
                        return Row(
                          children: [
                            Text(c.timeToNextZaman, style: textStyleAppBarTime),
                          ],
                        );
                      }),
                    ],
                  ),
                  //if (c.showSunnahKeys) SizedBox(height: 1),
                  SizedBox(height: 5.5),
                  if (c.showSunnahKeys)
                    Row(
                      children: [
                        Expanded(
                          flex: 1000,
                          child: Column(
                            children: [
                              Text(
                                'Before',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1000,
                          child: Column(
                            children: [
                              Text(
                                'Fard',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Rakat',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 100, child: const Text('')),
                        Expanded(
                          flex: 1900,
                          child: Column(
                            children: [
                              Text(
                                'After',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 400, child: const Text('')),
                      ],
                    )
                ],
              ),
            ),
            Expanded(
              flex: c.showSunnahKeys ? 1600 : 0,
              child: c.showSunnahKeys
                  ? ShowSunnahSettings(
                      btnHeight: 19,
                      btnGap: 0,
                      fontSize: 9,
                      lrPadding: 0,
                    )
                  : const Text(''),
            ),
          ],
        );
      },
    );
  }

  static String getTime(DateTime? time) {
    return getTimeRange(time, null);
  }

  static String getTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) {
      return '-';
    }

    //"${d.year.toString()}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} ${d.hour.toString()}-${d.minute.toString()}";

    int startHour = startTime.hour;
    int startMinute = startTime.minute;
    String startAmPm = '';
    if (cQstA.show12HourClock) {
      if (startHour >= 12) {
        startHour -= 12;
        startAmPm = ' PM';
      } else {
        startAmPm = ' AM';
      }
      if (startHour == 0) {
        startHour = 12;
      }
    }

    String endTimeString = '';
    if (endTime != null) {
      int endHour = endTime.hour;
      int endMinute = endTime.minute;
      String endAmPm = '';

      if (cQstA.show12HourClock) {
        if (endHour >= 12) {
          endHour -= 12;
          endAmPm = ' PM';
        } else {
          endAmPm = ' AM';
        }
        if (endHour == 0) {
          endHour = 12;
        }

        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}$endAmPm';

        if (startAmPm == endAmPm) {
          startAmPm = ''; // if AM/PM are same, don't show twice
        }
      } else {
        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}';
      }
    }

    return '${startHour.toString()}:${startMinute.toString().padLeft(2, '0')}$startAmPm$endTimeString';
  }

  /// Used by Asr, Maghrib, Isha (All but fajr/dhur is passed in here).
  /// Note: returns SliverPersistentHeader.
  SliverPersistentHeader actionsSalah({
    required final String rakatFard,
    required final Zaman zaman,
    required final bool pinned,
    required final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
  }) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: actionsSalahRow(
          rakatFard: rakatFard,
          zaman: zaman,
          pinned: pinned,
          salahTimeStart: salahTimeStart,
          salahTimeEnd: salahTimeEnd,
          rakatMuakBefore: rakatMuakBefore,
          rakatMuakAfter: rakatMuakAfter,
          rakatNaflBefore: rakatNaflBefore,
          rakatNaflAfter: rakatNaflAfter,
          isJummahMode: false,
        ),
      ),
    );
  }

  /// Needed so fajr/fajr_tomorrow and dhur/jummah can use FlipCard().
  /// Note: returns GetBuilder.
  GetBuilder<ActiveQuestsController> actionsSalahRow({
    required final String rakatFard,
    required final Zaman zaman,
    required final bool pinned,
    required final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
    required final bool isJummahMode,
    final FlipCardController? flipCardController,
  }) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          children: [
            ///
            /// First row is title of salah, with times, etc.
            ///
            salahHeader(
              zaman,
              pinned,
              c,
              isJummahMode,
              salahTimeStart,
              !c.showSunnahDuha || zaman == Zaman.Fajr_Tomorrow
                  ? salahTimeEnd
                  : null,
              flipCardController,
            ),
            Expanded(
              child: Row(
                children: [
                  ///
                  /// 1 of 4. sunnah before fard column items:
                  ///
                  if (rakatMuakBefore != '')
                    SalahActionCellStart(
                      c.showSunnahMuak ? rakatMuakBefore : '',
                      textStyleMuak,
                      pinned,
                    ),
                  if (rakatNaflBefore != '')
                    SalahActionCellStart(
                      c.showSunnahNafl ? rakatNaflBefore : '',
                      textStyleNafl,
                      pinned,
                    ),
                  if (zaman == Zaman.Maghrib)
                    SalahActionCellStart(
                      '',
                      textStyleNafl,
                      false,
                    ),

                  ///
                  /// 2 of 4. fard column item:
                  ///
                  SalahActionCellCenter(
                    rakatFard,
                    textStyleFard,
                    pinned,
                  ),

                  ///
                  /// 3 of 4. Option 1: sunnah after fard column items:
                  ///
                  if (zaman == Zaman.Asr)
                    SalahActionCellCenterWidget(
                      IconThikr(),
                      pinned,
                    ),
                  if (zaman == Zaman.Asr)
                    SalahActionCellCenterWidget(
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 25,
                      ),
                      pinned,
                    ),

                  ///
                  /// 3 of 4. Option 2: sunnah after fard column items:
                  ///
                  if (zaman == Zaman.Asr)
                    SalahActionCellEndWidget(
                      SunCell(IconSunset(), 'Evening Adhkar',
                          c.prayerTimes!.sunSetting, c.prayerTimes!.maghrib),
                      pinned,
                      flex: 2000,
                    ),

                  if (zaman != Zaman.Asr)
                    SalahActionCellCenter(
                      c.showSunnahMuak ? rakatMuakAfter : '',
                      textStyleMuak,
                      pinned,
                    ),
                  if (zaman != Zaman.Asr)
                    SalahActionCellCenter(
                      c.showSunnahNafl ? rakatNaflAfter : '',
                      textStyleNafl,
                      pinned,
                    ),

                  ///
                  /// 4 of 4. Thikr and Dua after fard:
                  ///
                  if (zaman != Zaman.Asr)
                    SalahActionCellCenterWidget(
                      IconThikr(),
                      pinned,
                    ),
                  if (zaman != Zaman.Asr)
                    SalahActionCellEndWidget(
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 25,
                      ),
                      pinned,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SliverPersistentHeader actionsDuha(ActiveQuestsController c, bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: Column(
          children: [
            ///
            /// First row is title with times, etc.
            ///
            salahHeader(
              Zaman.Duha,
              pinned,
              c,
              false,
              c.prayerTimes!.sunrise,
              null,
              null,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SalahActionCellStartWidget(
                    SunCell(
                      IconSunrise(),
                      'Morning Adhkar',
                      c.prayerTimes!.sunrise,
                      c.prayerTimes!.duha,
                    ),
                    pinned,
                    flex: 2000,
                  ),
                  SalahActionCellCenter(
                    'Ishraq',
                    textStyleDuha,
                    pinned,
                  ),
                  SalahActionCellCenter(
                    'Duha',
                    textStyleDuha,
                    pinned,
                  ),
                  SalahActionCellEndWidget(
                    SunCell(
                      Icon(
                        Icons.brightness_7_outlined,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      "Zawal",
                      c.prayerTimes!.zawal,
                      c.prayerTimes!.dhuhr,
                    ),
                    pinned,
                    flex: 2000,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionsLaylIbadah(Zaman zaman, bool pinned) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          children: [
            ///
            /// First row is title with times, etc.
            ///
            salahHeader(
              zaman,
              pinned,
              c,
              false,
              zaman == Zaman.Last_1__3_of_Night
                  ? c.prayerTimes!.last3rdOfNight
                  : c.prayerTimes!.middleOfNight,
              null,
              flipCardControllerLayl,
            ),
            Expanded(
              child: Row(
                children: [
                  SalahActionCellStart('Qiyam', textStyleQiyam, pinned),

                  ///
                  /// Thikr and Dua before bed:
                  ///
                  SalahActionCellCenterWidget(IconThikr(), pinned),
                  SalahActionCellCenterWidget(
                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.white,
                      size: 25,
                    ),
                    pinned,
                  ),
                  SalahActionCellCenter('Sleep', textStyleWhite, pinned),

                  ///
                  /// Tahhajud and Witr after waking up
                  ///
                  SalahActionCellCenter('Tahajjud', textStyleTahajjud, pinned),
                  SalahActionCellEnd('Witr', textStyleWitr, pinned),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool isPinned(Zaman zaman, List<Zaman>? zamans) {
    Zaman currPrayerName = cQstA.prayerTimes!.currZaman;
    bool pinned = zaman == currPrayerName;
    if (!pinned) {
      if (zamans != null) {
        for (Zaman prayer in zamans) {
          if (prayer == currPrayerName) {
            return true;
          }
        }
      }
    }
    return pinned;
  }

  SliverPersistentHeader sliverSpaceHeader(bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: AppThemes.logoBackground,
        ),
      ),
    );
  }

  /// Use to make scrolling of active salah always pin when scrolling up.
  SliverPersistentHeader sliverSpaceHeaderFiller() {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: 100.0,
        maxHeight: 100.0,
        child: Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      if (c.prayerTimes == null) {
        return Container(); // TODO show spinner
      }
      return Container(
        color: AppThemes.logoBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.lightBlue.shade900,
              expandedHeight: 260.0,
              collapsedHeight: c.showSunnahKeys ? 90.0 : 56,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.all(7.0),
                title: salahAppBar(),
                background: Swiper(
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) => Image.asset(
                    'assets/images/quests/active$index.jpg',
                    //TODO add more images
                    fit: BoxFit.cover,
                  ),
                  autoplay: true,
                  autoplayDelay: 10000,
                ),
              ),
            ),
            sliverSpaceHeader(true),
            SliverPersistentHeader(
              pinned: isPinned(Zaman.Fajr, [Zaman.Fajr_Tomorrow]),
              delegate: _SliverAppBarDelegate(
                minHeight: SALAH_ACTIONS_HEIGHT,
                maxHeight: SALAH_ACTIONS_HEIGHT,
                child: FlipCard(
                  flipOnTouch: false,
                  controller: flipCardControllerFajr,
                  direction: FlipDirection.HORIZONTAL,
                  front: actionsSalahRow(
                    rakatFard: '2',
                    zaman: Zaman.Fajr,
                    pinned: isPinned(Zaman.Fajr, null),
                    salahTimeStart: c.prayerTimes!.fajr,
                    salahTimeEnd: c.prayerTimes!.sunrise,
                    rakatMuakBefore: '2',
                    isJummahMode: false,
                    flipCardController: flipCardControllerFajr,
                  ),
                  back: actionsSalahRow(
                    rakatFard: '2',
                    zaman: Zaman.Fajr_Tomorrow,
                    pinned: isPinned(Zaman.Fajr_Tomorrow, null),
                    salahTimeStart: c.prayerTimes!.fajrTomorrow,
                    salahTimeEnd: c.prayerTimes!.sunriseTomorrow,
                    rakatMuakBefore: '2',
                    isJummahMode: false,
                    flipCardController: flipCardControllerFajr,
                  ),
                ),
              ),
            ),
            sliverSpaceHeader(isPinned(Zaman.Fajr, [Zaman.Fajr_Tomorrow])),
            if (c.showSunnahDuha)
              actionsDuha(
                c,
                isPinned(
                  Zaman.Sunrise,
                  [Zaman.Ishraq, Zaman.Duha, Zaman.Zawal],
                ),
              ),
            if (c.showSunnahDuha)
              sliverSpaceHeader(
                isPinned(
                  Zaman.Sunrise,
                  [Zaman.Ishraq, Zaman.Duha, Zaman.Zawal],
                ),
              ),
            c.isFriday() && c.showJummahOnFriday
                ? SliverPersistentHeader(
                    pinned: isPinned(Zaman.Dhuhr, null),
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false,
                        controller: flipCardControllerDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        front: actionsSalahRow(
                          rakatFard: '2', // Jummah Mode
                          zaman: Zaman.Dhuhr,
                          pinned: isPinned(Zaman.Dhuhr, null),
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '6',
                          rakatNaflAfter: '2',
                          isJummahMode: true,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                        back: actionsSalahRow(
                          rakatFard: '4',
                          zaman: Zaman.Dhuhr,
                          pinned: isPinned(Zaman.Dhuhr, null),
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '2',
                          rakatNaflAfter: '2',
                          isJummahMode: false,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                      ),
                    ),
                  )
                : SliverPersistentHeader(
                    pinned: isPinned(Zaman.Dhuhr, null),
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false,
                        controller: flipCardControllerDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        front: actionsSalahRow(
                          rakatFard: '4',
                          zaman: Zaman.Dhuhr,
                          pinned: isPinned(Zaman.Dhuhr, null),
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '2',
                          rakatNaflAfter: '2',
                          isJummahMode: false,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                        back: actionsSalahRow(
                          rakatFard: '2', // Jummah Mode
                          zaman: Zaman.Dhuhr,
                          pinned: isPinned(Zaman.Dhuhr, null),
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '6',
                          rakatNaflAfter: '2',
                          isJummahMode: true,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                      ),
                    ),
                  ),
            sliverSpaceHeader(isPinned(Zaman.Dhuhr, null)),
            actionsSalah(
              rakatFard: '4',
              zaman: Zaman.Asr,
              pinned: isPinned(Zaman.Asr, [Zaman.Sun_Setting]),
              salahTimeStart: c.prayerTimes!.asr,
              rakatNaflBefore: '4',
            ),
            sliverSpaceHeader(isPinned(Zaman.Asr, [Zaman.Sun_Setting])),
            actionsSalah(
              rakatFard: '3',
              zaman: Zaman.Maghrib,
              pinned: isPinned(Zaman.Maghrib, null),
              salahTimeStart: c.prayerTimes!.maghrib,
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            sliverSpaceHeader(isPinned(Zaman.Maghrib, null)),
            actionsSalah(
              rakatFard: '4',
              pinned: isPinned(Zaman.Isha, null),
              zaman: Zaman.Isha,
              salahTimeStart: c.prayerTimes!.isha,
              rakatNaflBefore: '4',
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            sliverSpaceHeader(isPinned(Zaman.Isha, null)),
            if (c.showSunnahLayl)
              c.showLast3rdOfNight
                  ? SliverPersistentHeader(
                      pinned: cAjrA.isIshaIbadahComplete &&
                          isPinned(
                            Zaman.Isha,
                            [Zaman.Middle_of_Night, Zaman.Last_1__3_of_Night],
                          ),
                      delegate: _SliverAppBarDelegate(
                        minHeight: SALAH_ACTIONS_HEIGHT,
                        maxHeight: SALAH_ACTIONS_HEIGHT,
                        child: FlipCard(
                          flipOnTouch: false,
                          controller: flipCardControllerLayl,
                          direction: FlipDirection.HORIZONTAL,
                          front: actionsLaylIbadah(
                            Zaman.Last_1__3_of_Night,
                            cAjrA.isIshaIbadahComplete &&
                                isPinned(
                                  Zaman.Isha,
                                  [
                                    Zaman.Middle_of_Night,
                                    Zaman.Last_1__3_of_Night
                                  ],
                                ),
                          ),
                          back: actionsLaylIbadah(
                            Zaman.Middle_of_Night,
                            cAjrA.isIshaIbadahComplete &&
                                isPinned(
                                  Zaman.Isha,
                                  [
                                    Zaman.Middle_of_Night,
                                    Zaman.Last_1__3_of_Night
                                  ],
                                ),
                          ),
                        ),
                      ),
                    )
                  : SliverPersistentHeader(
                      pinned: isPinned(Zaman.Dhuhr, null),
                      delegate: _SliverAppBarDelegate(
                        minHeight: SALAH_ACTIONS_HEIGHT,
                        maxHeight: SALAH_ACTIONS_HEIGHT,
                        child: FlipCard(
                          flipOnTouch: false,
                          controller: flipCardControllerLayl,
                          direction: FlipDirection.HORIZONTAL,
                          front: actionsLaylIbadah(
                            Zaman.Middle_of_Night,
                            cAjrA.isIshaIbadahComplete &&
                                isPinned(
                                  Zaman.Isha,
                                  [
                                    Zaman.Middle_of_Night,
                                    Zaman.Last_1__3_of_Night
                                  ],
                                ),
                          ),
                          back: actionsLaylIbadah(
                            Zaman.Last_1__3_of_Night,
                            cAjrA.isIshaIbadahComplete &&
                                isPinned(
                                  Zaman.Isha,
                                  [
                                    Zaman.Middle_of_Night,
                                    Zaman.Last_1__3_of_Night
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ),
            if (c.showSunnahLayl)
              sliverSpaceHeader(
                cAjrA.isIshaIbadahComplete &&
                    isPinned(
                      Zaman.Isha,
                      [Zaman.Middle_of_Night, Zaman.Last_1__3_of_Night],
                    ),
              ),
            sliverSpaceHeader(true),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
            sliverSpaceHeaderFiller(),
          ],
        ),
      );
    });
  }

  Expanded salahHeader(
    final Zaman zaman,
    final bool pinned,
    final ActiveQuestsController c,
    final bool isJummahMode,
    final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final FlipCardController? flipCardController,
  ) {
    return Expanded(
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: pinned && ((!isJummahMode) || (isJummahMode && c.isFriday()))
                ? Color(0xFF268E0D)
                : Colors.lightBlue.shade600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (flipCardController != null)
                  InkWell(
                    child: Transform.rotate(
                      angle: 1.5708, // <- radian = 90 degrees
                      child: Icon(Icons.swap_vert_outlined),
                    ),
                    onTap: () => c.toggleFlipCard(flipCardController),
                  ),
                Text(
                  isJummahMode ? 'Jummah' : zaman.name(),
                  style: const TextStyle(
                      color: textColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      getTimeRange(salahTimeStart, salahTimeEnd),
                      style: textStyleWhite,
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () {
                        c.toggleSalahAlarm(zaman);
                      },
                      child: Icon(
                        Icons.alarm_outlined, // TODO
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class SalahActionCellStart extends StatelessWidget {
  const SalahActionCellStart(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: Text(_text, style: _textStyle),
                      )
                    : Text(_text, style: _textStyle)),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellStartWidget extends StatelessWidget {
  const SalahActionCellStartWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: _widget,
                      )
                    : _widget),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellCenter extends StatelessWidget {
  const SalahActionCellCenter(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
            child: _isActive
                ? HeartBeat(
                    beatsPerMinute: 60,
                    child: Text(_text, style: _textStyle),
                  )
                : Text(_text, style: _textStyle)),
      ),
    );
  }
}

class SalahActionCellCenterWidget extends StatelessWidget {
  const SalahActionCellCenterWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
            child: _isActive
                ? HeartBeat(
                    beatsPerMinute: 60,
                    child: _widget,
                  )
                : _widget),
      ),
    );
  }
}

class SalahActionCellEnd extends StatelessWidget {
  const SalahActionCellEnd(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: Text(_text, style: _textStyle),
                      )
                    : Text(_text, style: _textStyle)),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellEndWidget extends StatelessWidget {
  const SalahActionCellEndWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: _widget,
                      )
                    : _widget),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class IconThikr extends StatelessWidget {
  const IconThikr();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Text('Thikr', style: actionTextStyle),
        Center(
          child: Icon(
            Icons.favorite_outlined,
            color: Colors.red,
            size: 33,
          ),
        ),
        Center(
          child: Icon(
            Icons.psychology_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
      ],
    );
  }
}

class IconSunrise extends StatelessWidget {
  const IconSunrise();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          //angle: 1.5708,
          angle: 4.71239,
          child: Icon(
            Icons.brightness_medium_outlined,
            color: Colors.yellow,
            size: 18,
          ),
        ),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: Colors.grey.shade800,
            height: 10,
            width: 20,
            //child: SizedBox(height: 10),
          ),
        ),
        Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_up_outlined,
              color: Colors.yellow, size: 16),
        )
      ],
    );
  }
}

class IconSunset extends StatelessWidget {
  const IconSunset();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          //angle: 1.5708,
          angle: 4.71239,
          child: Icon(
            Icons.brightness_medium_outlined,
            color: Colors.yellow,
            size: 18,
          ),
        ),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: Colors.grey.shade800,
            height: 10,
            width: 20,
            //child: SizedBox(height: 10),
          ),
        ),
        Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_down_outlined,
              color: Colors.yellow, size: 16),
        )
      ],
    );
  }
}

class SunCell extends StatelessWidget {
  const SunCell(this._sunIcon, this._label, this._time1, this._time2);

  final Widget _sunIcon;
  final String _label;
  final DateTime _time1;
  final DateTime? _time2;

  static const TextStyle _textStyleAdhkar = const TextStyle(
      color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sunIcon,
            SizedBox(width: 3),
            Text(
              ActiveQuestsUI.getTimeRange(_time1, _time2),
              style: _textStyleAdhkar,
            ),
          ],
        ),
        if (_label != '') Text(_label, style: _textStyleAdhkar),
      ],
    );
  }
}
