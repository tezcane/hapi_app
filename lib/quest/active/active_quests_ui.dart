import 'dart:math' as math;

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/painting.dart'; TODO needed?
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/athan/TOD.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:im_animations/im_animations.dart';

final Color colorSalahBottom = Colors.grey.shade800;

class ActiveQuestsUI extends StatelessWidget {
  static const double SALAH_ACTIONS_HEIGHT = 62;

  static const TS tsAppBar = TS(9.5, Colors.white70);
  static const TS tsAppBarTime = TS(24.0, Colors.white70);

  static const Color textColor = Colors.white70;
  static const TS tsWhite = TS(17.0, Colors.white70);
  static const TS tsFard = TS(17.0, Colors.red);
  static const TS tsMuak = TS(17.0, Colors.green);
  static final TS tsNafl = TS(17.0, Colors.amber.shade700);
  static const TS tsDuha = TS(17.0, Colors.yellow);
  static const TS tsIshr = TS(17.0, Colors.white70);
  static const TS tsQyam = TS(17.0, Colors.white70);
  static const TS tsThjd = TS(17.0, Colors.white70);
  static const TS tsWitr = TS(17.0, Colors.pinkAccent);

  static final FlipCardController cflipCardFajr = FlipCardController();
  static final FlipCardController cflipCardDhuhr = FlipCardController();
  static final FlipCardController cflipCardLayl = FlipCardController();

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
                              Text(c.tod!.currTOD.name(), style: tsAppBar),
                              Text(' ends', style: tsAppBar),
                              const SizedBox(width: 1),
                              const Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white70, size: 12),
                              const SizedBox(width: 5),
                            ],
                          ),
                          Row(
                            children: [
                              Text(c.tod!.nextTOD.name(), style: tsAppBar),
                              Text(' in', style: tsAppBar),
                              const SizedBox(width: 1),
                              const Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white70, size: 12),
                              const SizedBox(width: 5),
                            ],
                          ),
                        ],
                      ),
                      GetX<ZamanController>(builder: (ZamanController c) {
                        // TODO should use GetBuilder instead of GetX?
                        return Row(
                          children: [
                            Text(c.timeToNextZaman, style: tsAppBarTime),
                          ],
                        );
                      }),
                    ],
                  ),
                  //if (c.showSunnahKeys) SizedBox(height: 1),
                  const SizedBox(height: 5.5),
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
                                style: tsAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: tsAppBar,
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
                                style: tsAppBar,
                              ),
                              Text(
                                'Rakat',
                                textAlign: TextAlign.center,
                                style: tsAppBar,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(flex: 100, child: Text('')),
                        Expanded(
                          flex: 1900,
                          child: Column(
                            children: [
                              Text(
                                'After',
                                textAlign: TextAlign.center,
                                style: tsAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: tsAppBar,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(flex: 400, child: Text('')),
                      ],
                    )
                ],
              ),
            ),
            Expanded(
              flex: c.showSunnahKeys ? 1600 : 0,
              child: c.showSunnahKeys
                  ? const ShowSunnahSettings(
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
    if (ActiveQuestsController.to.show12HourClock) {
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

      if (ActiveQuestsController.to.show12HourClock) {
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

  /// Needed for FlipCard on fajr_tomorrow and dhur/jummah.
  /// Note: returns GetBuilder.
  GetBuilder<ActiveQuestsController> rowNoActionFlipCard({
    required final String fardRkt,
    required final TOD tod,
    required final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    required String muakBef,
    String muakAft = '',
    String naflAft = '',
    required final bool isJummahMode,
    required FlipCardController flipCardController,
  }) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        muakBef = c.showSunnahMuak ? muakBef : '';
        muakAft = c.showSunnahMuak ? muakAft : '';
        naflAft = c.showSunnahNafl ? naflAft : '';

        return Column(
          children: [
            /// First row is title of salah, with times, etc.
            salahHeader(
              tod,
              false,
              c,
              isJummahMode,
              salahTimeStart,
              tod == TOD.Fajr_Tomorrow ? salahTimeEnd : null,
              flipCardController,
            ),
            Expanded(
              child: Row(
                children: [
                  /// 1 of 4. sunnah before fard column item:
                  Cell(P.S, T(muakBef, tsMuak), false, QUEST.NONE, dis: true),

                  /// 2 of 4. fard column item:
                  Cell(P.C, T(fardRkt, tsFard), false, QUEST.NONE, dis: true),

                  /// 3 of 4. sunnah after fard column items:
                  Cell(P.C, T(muakAft, tsMuak), false, QUEST.NONE, dis: true),
                  Cell(P.C, T(naflAft, tsNafl), false, QUEST.NONE, dis: true),

                  /// 4 of 4. Thikr and Dua after fard:
                  const Cell(P.C, IconThikr(), false, QUEST.NONE, dis: true),
                  const Cell(P.E, IconDua(), false, QUEST.NONE, dis: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  GetBuilder<ActiveQuestsController> rowFajr(final bool pinned) {
    String muakBef = '2';
    String fardRkt = '2';

    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        muakBef = c.showSunnahMuak ? muakBef : '';

        return Column(
          children: [
            /// First row is title of salah, with times, etc.
            salahHeader(
              TOD.Fajr,
              pinned,
              c,
              false,
              c.tod!.fajr,
              !c.showSunnahDuha ? c.tod!.sunrise : null,
              cflipCardFajr,
            ),
            Expanded(
              child: Row(
                children: [
                  /// 1 of 4. sunnah before fard column item:
                  Cell(P.S, T(muakBef, tsMuak), pinned, QUEST.FAJR_MUAKB),

                  /// 2 of 4. fard column item:
                  Cell(P.C, T(fardRkt, tsFard), pinned, QUEST.FAJR_FARD),

                  /// 3 of 4. Sunnah after fard column items:
                  Cell(P.C, const T('', tsMuak), pinned, QUEST.NONE),
                  Cell(P.C, T('', tsNafl), pinned, QUEST.NONE),

                  /// 4 of 4. Thikr and Dua after fard:
                  Cell(P.C, const IconThikr(), pinned, QUEST.FAJR_THIKR),
                  Cell(P.E, const IconDua(), pinned, QUEST.FAJR_DUA),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SliverPersistentHeader rowDuha(ActiveQuestsController c, bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: Column(
          children: [
            /// First row is title with times, etc.
            salahHeader(TOD.Duha, pinned, c, false, c.tod!.sunrise, null, null),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Cell(
                    P.S,
                    SunCell(
                      const IconSunrise(),
                      'Morning Adhkar',
                      c.tod!.sunrise,
                      c.tod!.ishraq,
                    ),
                    pinned,
                    QUEST.KERAHAT_ADHKAR_SUNRISE,
                    flex: 2000,
                  ),
                  Cell(P.C, T('Ishraq', tsIshr), pinned, QUEST.DUHA_ISHRAQ),
                  Cell(P.C, T('Duha', tsDuha), pinned, QUEST.DUHA_DUHA),
                  Cell(
                    P.E,
                    SunCell(
                      const IconSunBright(),
                      "Zawal",
                      c.tod!.zawal,
                      c.tod!.dhuhr,
                    ),
                    pinned,
                    QUEST.KERAHAT_ADHKAR_ZAWAL,
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

  /// Note: returns GetBuilder since has FlipCard()
  GetBuilder<ActiveQuestsController> rowDhuhr(
    final bool pinned, {
    required String fardRkt,
    required String muakAft,
    required final bool isJummahMode,
  }) {
    String muakBef = '4';
    String naflAft = '2';

    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        muakBef = c.showSunnahMuak ? muakBef : '';
        muakAft = c.showSunnahMuak ? muakAft : '';
        naflAft = c.showSunnahNafl ? naflAft : '';

        return Column(
          children: [
            /// First row is title of salah, with times, etc.
            salahHeader(
              TOD.Dhuhr,
              pinned,
              c,
              isJummahMode,
              c.tod!.dhuhr,
              null,
              cflipCardDhuhr,
            ),
            Expanded(
              child: Row(
                children: [
                  /// 1 of 4. sunnah before fard column item:
                  Cell(P.S, T(muakBef, tsMuak), pinned, QUEST.DHUHR_MUAKB),

                  /// 2 of 4. fard column item:
                  Cell(P.C, T(fardRkt, tsFard), pinned, QUEST.DHUHR_FARD),

                  /// 3 of 4. Option 2: sunnah after fard column items:
                  Cell(P.C, T(muakAft, tsMuak), pinned, QUEST.DHUHR_MUAKA),
                  Cell(P.C, T(naflAft, tsNafl), pinned, QUEST.DHUHR_NAFLA),

                  /// 4 of 4. Thikr and Dua after fard:
                  Cell(P.C, const IconThikr(), pinned, QUEST.DHUHR_THIKR),
                  Cell(P.E, const IconDua(), pinned, QUEST.DHUHR_DUA),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SliverPersistentHeader rowAsr(final bool pinned) {
    String naflBef = '4';
    String fardRkt = '4';

    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<ActiveQuestsController>(
          builder: (c) {
            naflBef = c.showSunnahNafl ? naflBef : '';

            return Column(
              children: [
                /// First row is title of salah, with times, etc.
                salahHeader(TOD.Asr, pinned, c, false, c.tod!.asr, null, null),
                Expanded(
                  child: Row(
                    children: [
                      /// 1 of 4. sunnah before fard column item:
                      Cell(P.S, T(naflBef, tsNafl), pinned, QUEST.ASR_NAFLB),

                      /// 2 of 4. fard column item:
                      Cell(P.C, T(fardRkt, tsFard), pinned, QUEST.ASR_FARD),

                      /// 3 of 4. Thikr and Dua after fard:
                      Cell(P.C, const IconThikr(), pinned, QUEST.ASR_THIKR),
                      Cell(P.C, const IconDua(), pinned, QUEST.ASR_DUA),

                      /// 4 of 4. Evening adhkar
                      Cell(
                        P.E,
                        SunCell(const IconSunset(), 'Evening Adhkar',
                            c.tod!.sunSetting, c.tod!.maghrib),
                        pinned,
                        QUEST.KERAHAT_ADHKAR_SUNSET,
                        flex: 2000,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverPersistentHeader rowMaghrib(final bool pinned) {
    String fardRkt = '3';
    String muakAft = '2';
    String naflAft = '2';

    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<ActiveQuestsController>(
          builder: (c) {
            muakAft = c.showSunnahMuak ? muakAft : '';
            naflAft = c.showSunnahNafl ? naflAft : '';

            return Column(
              children: [
                /// First row is title of salah, with times, etc.
                salahHeader(
                    TOD.Maghrib, pinned, c, false, c.tod!.maghrib, null, null),
                Expanded(
                  child: Row(
                    children: [
                      /// 1 of 4. sunnah before fard column item:
                      Cell(P.S, const T('', tsWhite), pinned, QUEST.NONE),

                      /// 2 of 4. fard column item:
                      Cell(P.C, T(fardRkt, tsFard), pinned, QUEST.MAGHRIB_FARD),

                      /// 3 of 4. Option 2: sunnah after fard column items:
                      Cell(
                          P.C, T(muakAft, tsMuak), pinned, QUEST.MAGHRIB_MUAKA),
                      Cell(
                          P.C, T(naflAft, tsNafl), pinned, QUEST.MAGHRIB_NAFLA),

                      /// 4 of 4. Thikr and Dua after fard:
                      Cell(P.C, const IconThikr(), pinned, QUEST.MAGHRIB_THIKR),
                      Cell(P.E, const IconDua(), pinned, QUEST.MAGHRIB_DUA),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverPersistentHeader rowIsha(final bool pinned) {
    String naflBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<ActiveQuestsController>(
          builder: (c) {
            naflBef = c.showSunnahNafl ? naflBef : '';
            muakAft = c.showSunnahMuak ? muakAft : '';
            naflAft = c.showSunnahNafl ? naflAft : '';

            return Column(
              children: [
                /// First row is title of salah, with times, etc.
                salahHeader(
                    TOD.Isha, pinned, c, false, c.tod!.isha, null, null),
                Expanded(
                  child: Row(
                    children: [
                      /// 1 of 4. sunnah before fard column item:
                      Cell(P.S, T(naflBef, tsNafl), pinned, QUEST.ISHA_NAFLB),

                      /// 2 of 4. fard column item:
                      Cell(P.C, T(fardRkt, tsFard), pinned, QUEST.ISHA_FARD),

                      /// 3 of 4. Option 1: sunnah after fard column items:
                      Cell(P.C, T(muakAft, tsMuak), pinned, QUEST.ISHA_MUAKA),
                      Cell(P.C, T(naflAft, tsNafl), pinned, QUEST.ISHA_NAFLA),

                      /// 4 of 4. Thikr and Dua after fard:
                      Cell(P.C, const IconThikr(), pinned, QUEST.ISHA_THIKR),
                      Cell(P.E, const IconDua(), pinned, QUEST.ISHA_DUA),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  GetBuilder rowLayl(TOD tod, bool pinned, bool dis) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          children: [
            /// First row is title with times, etc.
            salahHeader(
              tod,
              pinned,
              c,
              false,
              tod == TOD.Last_1__3_of_Night
                  ? c.tod!.last3rdOfNight
                  : c.tod!.middleOfNight,
              null,
              cflipCardLayl,
            ),
            Expanded(
              child: Row(
                children: [
                  Cell(P.S, T('Qiyam', tsQyam), pinned, QUEST.LAYL_QIYAM,
                      dis: dis),

                  /// Thikr and Dua before bed:
                  Cell(P.C, const IconThikr(), pinned, QUEST.LAYL_THIKR,
                      dis: dis),
                  Cell(P.C, const IconDua(), pinned, QUEST.LAYL_DUA, dis: dis),
                  Cell(P.C, T('Sleep', tsWhite), pinned, QUEST.LAYL_SLEEP,
                      dis: dis),

                  /// Tahhajud and Witr after waking up
                  Cell(P.C, T('Tahajjud', tsThjd), pinned, QUEST.LAYL_TAHAJJUD,
                      dis: dis),
                  Cell(P.E, T('Witr', tsWitr), pinned, QUEST.LAYL_WITR,
                      dis: dis),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Used to hide salah section slivers scrolling up into top picture.
  SliverPersistentHeader sliverSpaceHeader(bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: Get.theme.backgroundColor,
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

  bool isPinned(TOD tod, List<TOD>? tods) {
    TOD currTOD = ActiveQuestsController.to.tod!.currTOD;
    bool pinned = tod == currTOD;
    if (!pinned) {
      if (tods != null) {
        for (TOD prayer in tods) {
          if (prayer == currTOD) {
            return true;
          }
        }
      }
    }
    return pinned;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      if (c.tod == null) {
        return Container(); // TODO show spinner?
      }

      final bool pinnedFajr = isPinned(TOD.Fajr, [TOD.Fajr_Tomorrow]);
      final bool pinnedDuha = c.showSunnahDuha &&
          isPinned(
              TOD.Kerahat_Sunrise, [TOD.Ishraq, TOD.Duha, TOD.Kerahat_Zawal]);
      final bool pinnedDuhr = isPinned(TOD.Dhuhr, null);
      final bool pinnedAsr = isPinned(TOD.Asr, [TOD.Kerahat_Sun_Setting]);
      final bool pinnedMaghrib = isPinned(TOD.Maghrib, null);
      final bool pinnedIsha = isPinned(TOD.Isha, null);
      final bool pinnedLayl = c.showSunnahLayl &&
          ActiveQuestsAjrController.to.isIshaIbadahComplete &&
          isPinned(TOD.Isha, [TOD.Middle_of_Night, TOD.Last_1__3_of_Night]);

      return Container(
        color: Get.theme.backgroundColor,
        child: CustomScrollView(
          slivers: <Widget>[
            /// Show Top App Bar
            SliverAppBar(
              backgroundColor: AppThemes.logoText,
              expandedHeight: 195.0,
              collapsedHeight: c.showSunnahKeys ? 90.0 : 56,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.all(7.0),
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

            /// Show rest of sliver list
            /// Fajr:
            SliverPersistentHeader(
              pinned: pinnedFajr,
              delegate: _SliverAppBarDelegate(
                minHeight: SALAH_ACTIONS_HEIGHT,
                maxHeight: SALAH_ACTIONS_HEIGHT,
                child: FlipCard(
                  flipOnTouch: false,
                  controller: cflipCardFajr,
                  direction: FlipDirection.HORIZONTAL,
                  front: rowFajr(pinnedFajr),
                  back: rowNoActionFlipCard(
                    fardRkt: '2',
                    tod: TOD.Fajr_Tomorrow,
                    salahTimeStart: c.tod!.fajrTomorrow,
                    salahTimeEnd: c.tod!.sunriseTomorrow,
                    muakBef: '2',
                    isJummahMode: false,
                    flipCardController: cflipCardFajr,
                  ),
                ),
              ),
            ),
            sliverSpaceHeader(pinnedFajr),

            /// Duha:
            if (c.showSunnahDuha) rowDuha(c, pinnedDuha),
            if (c.showSunnahDuha) sliverSpaceHeader(pinnedDuha),

            /// Dhuhr/Jummah:
            c.isFriday() && c.showJummahOnFriday
                ? SliverPersistentHeader(
                    pinned: pinnedDuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false,
                        controller: cflipCardDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        // Jummah Mode:
                        front: rowDhuhr(pinnedDuhr,
                            fardRkt: '2', muakAft: '6', isJummahMode: true),
                        back: rowNoActionFlipCard(
                          fardRkt: '4',
                          tod: TOD.Dhuhr,
                          salahTimeStart: c.tod!.dhuhr,
                          muakBef: '4',
                          muakAft: '2',
                          naflAft: '2',
                          isJummahMode: false,
                          flipCardController: cflipCardDhuhr,
                        ),
                      ),
                    ),
                  )
                : SliverPersistentHeader(
                    pinned: pinnedDuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false,
                        controller: cflipCardDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        front: rowDhuhr(
                          pinnedDuhr,
                          fardRkt: '4',
                          muakAft: '2',
                          isJummahMode: false,
                        ),
                        back: rowNoActionFlipCard(
                          fardRkt: '2', // Jummah Mode
                          tod: TOD.Dhuhr,
                          salahTimeStart: c.tod!.dhuhr,
                          muakBef: '4',
                          muakAft: '6',
                          naflAft: '2',
                          isJummahMode: true,
                          flipCardController: cflipCardDhuhr,
                        ),
                      ),
                    ),
                  ),
            sliverSpaceHeader(pinnedDuhr),

            /// Asr:
            rowAsr(pinnedAsr),
            sliverSpaceHeader(pinnedAsr),

            /// Maghrib:
            rowMaghrib(pinnedMaghrib),
            sliverSpaceHeader(pinnedMaghrib),

            /// Isha:
            rowIsha(pinnedIsha),
            sliverSpaceHeader(pinnedIsha),

            /// Layl Ibadah:
            if (c.showSunnahLayl)
              c.showLast3rdOfNight
                  ? SliverPersistentHeader(
                      pinned: pinnedLayl,
                      delegate: _SliverAppBarDelegate(
                        minHeight: SALAH_ACTIONS_HEIGHT,
                        maxHeight: SALAH_ACTIONS_HEIGHT,
                        child: FlipCard(
                          flipOnTouch: false,
                          controller: cflipCardLayl,
                          direction: FlipDirection.HORIZONTAL,
                          front: rowLayl(
                              TOD.Last_1__3_of_Night, pinnedLayl, false),
                          back: rowLayl(TOD.Middle_of_Night, false, true),
                        ),
                      ),
                    )
                  : SliverPersistentHeader(
                      pinned: pinnedLayl,
                      delegate: _SliverAppBarDelegate(
                        minHeight: SALAH_ACTIONS_HEIGHT,
                        maxHeight: SALAH_ACTIONS_HEIGHT,
                        child: FlipCard(
                          flipOnTouch: false,
                          controller: cflipCardLayl,
                          direction: FlipDirection.HORIZONTAL,
                          front:
                              rowLayl(TOD.Middle_of_Night, pinnedLayl, false),
                          back: rowLayl(TOD.Last_1__3_of_Night, false, true),
                        ),
                      ),
                    ),
            if (c.showSunnahLayl) sliverSpaceHeader(pinnedLayl),

            /// Fillers:
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
    final TOD tod,
    final bool pinned,
    final ActiveQuestsController c,
    final bool isJummahMode,
    final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final FlipCardController? flipCardController,
  ) {
    return Expanded(
      child: Container(
        color: Get.theme.backgroundColor, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: Container(
            color: pinned && ((!isJummahMode) || (isJummahMode && c.isFriday()))
                ? AppThemes.selected
                : AppThemes.unselected,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (flipCardController != null)
                  InkWell(
                    child: Transform.rotate(
                      angle: 1.5708, // <- radian = 90 degrees
                      child: const Icon(Icons.swap_vert_outlined,
                          size: 21, color: Colors.white38),
                    ),
                    onTap: () => c.toggleFlipCard(flipCardController),
                  ),
                Text(
                  isJummahMode ? 'Jummah' : tod.name(),
                  style: const TS(20.0, textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      getTimeRange(salahTimeStart, salahTimeEnd),
                      style: tsWhite,
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () {
                        c.toggleSalahAlarm(tod);
                      },
                      child: const Icon(
                        Icons.alarm_outlined, // TODO
                        size: 20,
                        color: Colors.white70,
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
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

/// T = Text Widget
class T extends StatelessWidget {
  const T(this._text, this._textStyle);

  final String _text;
  final TS _textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(_text, style: _textStyle);
  }
}

// P = CELL PLACEMENT
enum P {
  S, // START
  C, // CENTER
  E, // END
}

class Cell extends StatelessWidget {
  const Cell(this._cellPlacement, this._widget, this._pinned, this._quest,
      {this.flex = 1000, this.dis = false});

  final P _cellPlacement; // true = start, false = center, null = end
  final Widget _widget;
  final bool _pinned;
  final QUEST _quest;
  final int flex;
  final bool dis;

  @override
  Widget build(BuildContext context) {
    final ActionWidget _actionWidget = ActionWidget(
      isActive: _pinned,
      quest: _quest,
      dis: dis,
      widget: _widget,
    );

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => MenuController.to
            .pushSubPage(SubPage.ACTIVE_QUEST_ACTION, arguments: {
          'quest': _quest,
          'widget': _widget,
          'pinned': _pinned,
        }),
        child: Container(
          color: Get.theme.backgroundColor, // hide scroll of items behind
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(_cellPlacement == P.S ? 15.0 : 0),
              bottomRight: Radius.circular(_cellPlacement == P.E ? 15.0 : 0),
            ),
            child: Container(
              color: colorSalahBottom,
              child: Stack(
                children: [
                  _actionWidget,
                  if (ActiveQuestsAjrController.to.isDone(_quest))
                    const Center(
                      child: Icon(Icons.check_outlined,
                          size: 30, color: Colors.green),
                    ),
                  if (ActiveQuestsAjrController.to.isSkip(_quest))
                    const Center(
                      child: Icon(Icons.redo_outlined,
                          size: 20, color: Colors.red),
                    ),
                  if (ActiveQuestsAjrController.to.isMiss(_quest))
                    const Center(
                      child: Icon(Icons.close_outlined,
                          size: 20, color: Colors.red),
                    ),
                ],
              ),
              //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    Key? key,
    required bool isActive,
    required QUEST quest,
    required this.dis,
    required Widget widget,
  })  : _pinned = isActive,
        _quest = quest,
        _widget = widget,
        super(key: key);

  final bool _pinned;
  final QUEST _quest;
  final bool dis;
  final Widget _widget;

  @override
  Widget build(BuildContext context) {
    return Center(
        // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
        child: _pinned && ActiveQuestsAjrController.to.isQuestActive(_quest)
            ? HeartBeat(
                beatsPerMinute: 60,
                child: dis || _quest == QUEST.NONE
                    ? _widget
                    : Hero(tag: _quest, child: _widget),
              )
            : dis || _quest == QUEST.NONE
                ? _widget
                : Hero(tag: _quest, child: _widget));
  }
}

class SunCell extends StatelessWidget {
  const SunCell(this._sunIcon, this._label, this._time1, this._time2);

  final Widget _sunIcon;
  final String _label;
  final DateTime _time1;
  final DateTime? _time2;

  static const TS _tsAdhkar =
      TS(11.0, Colors.white70, fontWeight: FontWeight.normal);

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
            const SizedBox(width: 3),
            Text(
              ActiveQuestsUI.getTimeRange(_time1, _time2),
              style: _tsAdhkar,
            ),
          ],
        ),
        if (_label != '') Text(_label, style: _tsAdhkar),
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
        Transform.rotate(angle: 4.71239, child: const IconSun()),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: colorSalahBottom,
            height: 10,
            width: 20,
            //child: SizedBox(height: 10),
          ),
        ),
        const Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_up_outlined,
              color: Colors.white38, size: 16),
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
        Transform.rotate(angle: 4.71239, child: const IconSun()),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: colorSalahBottom,
            height: 10,
            width: 20,
          ),
        ),
        const Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_down_outlined,
              color: Colors.white38, size: 16),
        )
      ],
    );
  }
}

class IconSun extends StatelessWidget {
  const IconSun();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.orange,
      size: 18,
    );
  }
}

class IconSunBright extends StatelessWidget {
  const IconSunBright();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.yellow,
      size: 18,
    );
  }
}

class IconThikr extends StatelessWidget {
  const IconThikr();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: const [
          Center(
            child: Icon(Icons.favorite_outlined, color: Colors.grey, size: 33),
          ),
          Center(
            child: Icon(Icons.psychology_outlined,
                color: Colors.white38, size: 21),
          ),
        ],
      ),
    );
  }
}

class IconDua extends StatelessWidget {
  const IconDua();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.volunteer_activism, color: Colors.grey, size: 25);
  }
}

/// TS = TextStyle - helper class to make init code shorter
class TS extends TextStyle {
  const TS(
    double fontSize,
    Color color, {
    FontWeight fontWeight = FontWeight.bold,
  }) : super(fontSize: fontSize, color: color, fontWeight: fontWeight);
}
