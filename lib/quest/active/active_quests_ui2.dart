/*
import 'dart:math' as math;

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/components/grow_shrink_alert.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/active_quests_settings_ui.dart';
import 'package:hapi/quest/active/athan/tod.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class ActiveQuestsUI2 extends StatelessWidget {
  static const TS tsAppBar = TS(9.5, Colors.white70);
  static const TS tsAppBarTime = TS(24.0, Colors.white70);

  // TODO don't use white for all, Theme.of(context).textTheme.headline6!:
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
  // void toggleFlipCard(FlipCardController flipCardController) {
  //   flipCardController.toggleCard();
  //   update();
  // }

  final double minAppBarHeight = 56;

  Widget salahAppBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GetBuilder<ZamanController>(builder: (c) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(c.currTOD.niceName, style: tsAppBar),
                            Text(' ends', style: tsAppBar),
                            const SizedBox(width: 1),
                            const Icon(Icons.arrow_right_alt_rounded,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 5),
                          ],
                        ),
                        Row(
                          children: [
                            Text(c.nextTOD.niceName, style: tsAppBar),
                            Text(' in', style: tsAppBar),
                            const SizedBox(width: 1),
                            const Icon(Icons.arrow_right_alt_rounded,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ],
                    ),
                    Text(c.timeToNextZaman, style: tsAppBarTime),
                  ],
                );
              }),
              //if (c.showSunnahKeys) SizedBox(height: 1),
              const SizedBox(height: 5.5),
              GetBuilder<ActiveQuestsController>(
                builder: (c) => !c.showSunnahKeys
                    ? Row()
                    : Row(
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
                      ),
              )
            ],
          ),
        ),
        GetBuilder<ActiveQuestsController>(
          builder: (c) => Expanded(
            flex: c.showSunnahKeys ? 1600 : 0, // if hidden, give room back
            child: c.showSunnahKeys
                ? const ShowSunnahSettings(
                    btnHeight: 19,
                    btnGap: 0,
                    fontSize: 9,
                    lrPadding: 0,
                  )
                : const Text(''),
          ),
        ),
      ],
    );
  }

  static String getTime(DateTime? time) {
    return getTimeRange(time, null);
  }

  static String getTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) {
      return '-';
    }

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
  rowNoActionFlipCard(
    ActiveQuestsController c, {
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
    muakBef = c.showSunnahMuak ? muakBef : '';
    muakAft = c.showSunnahMuak ? muakAft : '';
    naflAft = c.showSunnahNafl ? naflAft : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(
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
              _Cell(T(muakBef, tsMuak), false, tod, QUEST.NONE, dis: true),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), false, tod, QUEST.NONE, dis: true),

              /// 3 of 4. sunnah after fard column items:
              _Cell(T(muakAft, tsMuak), false, tod, QUEST.NONE, dis: true),
              _Cell(T(naflAft, tsNafl), false, tod, QUEST.NONE, dis: true),

              /// 4 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), false, tod, QUEST.NONE, dis: true),
              _Cell(const _IconDua(), false, tod, QUEST.NONE, dis: true),
            ],
          ),
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Column rowFajr(ActiveQuestsController c, final bool pinned) {
    TOD tod = TOD.Fajr;
    String muakBef = '2';
    String fardRkt = '2';

    muakBef = c.showSunnahMuak ? muakBef : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(
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
              _Cell(T(muakBef, tsMuak), pinned, tod, QUEST.FAJR_MUAKB),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), pinned, tod, QUEST.FAJR_FARD),

              /// 3 of 4. Sunnah after fard column items:
              _Cell(T('', tsMuak), pinned, tod, QUEST.NONE),
              _Cell(T('', tsNafl), pinned, tod, QUEST.NONE),

              /// 4 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), pinned, tod, QUEST.FAJR_THIKR),
              _Cell(const _IconDua(), pinned, tod, QUEST.FAJR_DUA),
            ],
          ),
        ),
      ],
    );
  }

  Column rowDuha(ActiveQuestsController c, final bool pinned) {
    TOD tod = TOD.Duha;

    return Column(
      children: [
        /// First row is title with times, etc.
        _SalahHeader(TOD.Duha, pinned, c, false, c.tod!.sunrise, null, null),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Cell(
                _SunCell(
                  _IconSunrise(pinned),
                  'Morning Adhkar',
                  c.tod!.sunrise,
                  c.tod!.ishraq,
                ),
                pinned,
                tod,
                QUEST.KARAHAT_ADHKAR_SUNRISE,
                flex: 2000,
              ),
              _Cell(T('Ishraq', tsIshr), pinned, tod, QUEST.DUHA_ISHRAQ),
              _Cell(T('Duha', tsDuha), pinned, tod, QUEST.DUHA_DUHA),
              _Cell(
                _SunCell(
                  const _IconSunBright(),
                  'Istiwa',
                  c.tod!.istiwa,
                  c.tod!.dhuhr,
                ),
                pinned,
                tod,
                QUEST.KARAHAT_ADHKAR_ISTIWA,
                flex: 2000,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Column rowDhuhr(
    ActiveQuestsController c,
    final bool pinned, {
    required String fardRkt,
    required String muakAft,
    required final bool isJummahMode,
  }) {
    TOD tod = TOD.Dhuhr;

    String muakBef = '4';
    String naflAft = '2';

    muakBef = c.showSunnahMuak ? muakBef : '';
    muakAft = c.showSunnahMuak ? muakAft : '';
    naflAft = c.showSunnahNafl ? naflAft : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(
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
              _Cell(T(muakBef, tsMuak), pinned, tod, QUEST.DHUHR_MUAKB),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), pinned, tod, QUEST.DHUHR_FARD),

              /// 3 of 4. Option 2: sunnah after fard column items:
              _Cell(T(muakAft, tsMuak), pinned, tod, QUEST.DHUHR_MUAKA),
              _Cell(T(naflAft, tsNafl), pinned, tod, QUEST.DHUHR_NAFLA),

              /// 4 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), pinned, tod, QUEST.DHUHR_THIKR),
              _Cell(const _IconDua(), pinned, tod, QUEST.DHUHR_DUA),
            ],
          ),
        ),
      ],
    );
  }

  Column rowAsr(ActiveQuestsController c, final bool pinned) {
    TOD tod = TOD.Asr;

    String naflBef = '4';
    String fardRkt = '4';

    naflBef = c.showSunnahNafl ? naflBef : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(TOD.Asr, pinned, c, false, c.tod!.asr, null, null),
        Expanded(
          child: Row(
            children: [
              /// 1 of 4. sunnah before fard column item:
              _Cell(T(naflBef, tsNafl), pinned, tod, QUEST.ASR_NAFLB),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), pinned, tod, QUEST.ASR_FARD),

              /// 3 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), pinned, tod, QUEST.ASR_THIKR),
              _Cell(const _IconDua(), pinned, tod, QUEST.ASR_DUA),

              /// 4 of 4. Evening adhkar
              _Cell(
                  _SunCell(_IconSunset(pinned), 'Evening Adhkar',
                      c.tod!.sunSetting, c.tod!.maghrib),
                  pinned,
                  tod,
                  QUEST.KARAHAT_ADHKAR_SUNSET,
                  flex: 2000),
            ],
          ),
        ),
      ],
    );
  }

  Column rowMaghrib(ActiveQuestsController c, final bool pinned) {
    TOD tod = TOD.Maghrib;

    String fardRkt = '3';
    String muakAft = '2';
    String naflAft = '2';

    muakAft = c.showSunnahMuak ? muakAft : '';
    naflAft = c.showSunnahNafl ? naflAft : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(TOD.Maghrib, pinned, c, false, c.tod!.maghrib, null, null),
        Expanded(
          child: Row(
            children: [
              /// 1 of 4. sunnah before fard column item:
              _Cell(const T('', tsWhite), pinned, tod, QUEST.NONE),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), pinned, tod, QUEST.MAGHRIB_FARD),

              /// 3 of 4. Option 2: sunnah after fard column items:
              _Cell(T(muakAft, tsMuak), pinned, tod, QUEST.MAGHRIB_MUAKA),
              _Cell(T(naflAft, tsNafl), pinned, tod, QUEST.MAGHRIB_NAFLA),

              /// 4 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), pinned, tod, QUEST.MAGHRIB_THIKR),
              _Cell(const _IconDua(), pinned, tod, QUEST.MAGHRIB_DUA),
            ],
          ),
        ),
      ],
    );
  }

  Column rowIsha(ActiveQuestsController c, final bool pinned) {
    TOD tod = TOD.Isha;

    String naflBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    naflBef = c.showSunnahNafl ? naflBef : '';
    muakAft = c.showSunnahMuak ? muakAft : '';
    naflAft = c.showSunnahNafl ? naflAft : '';

    return Column(
      children: [
        /// First row is title of salah, with times, etc.
        _SalahHeader(TOD.Isha, pinned, c, false, c.tod!.isha, null, null),
        Expanded(
          child: Row(
            children: [
              /// 1 of 4. sunnah before fard column item:
              _Cell(T(naflBef, tsNafl), pinned, tod, QUEST.ISHA_NAFLB),

              /// 2 of 4. fard column item:
              _Cell(T(fardRkt, tsFard), pinned, tod, QUEST.ISHA_FARD),

              /// 3 of 4. Option 1: sunnah after fard column items:
              _Cell(T(muakAft, tsMuak), pinned, tod, QUEST.ISHA_MUAKA),
              _Cell(T(naflAft, tsNafl), pinned, tod, QUEST.ISHA_NAFLA),

              /// 4 of 4. Thikr and Dua after fard:
              _Cell(const _IconThikr(), pinned, tod, QUEST.ISHA_THIKR),
              _Cell(const _IconDua(), pinned, tod, QUEST.ISHA_DUA),
            ],
          ),
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  GetBuilder rowLayl(TOD tod, bool pinned, bool dis) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          children: [
            /// First row is title with times, etc.
            _SalahHeader(
              tod,
              pinned,
              c,
              false,
              tod == TOD.Night__3
                  ? c.tod!.last3rdOfNight
                  : c.tod!.middleOfNight,
              null,
              cflipCardLayl,
            ),
            Expanded(
              child: Row(
                children: [
                  _Cell(T('Qiyam', tsQyam), pinned, tod, QUEST.LAYL_QIYAM,
                      dis: dis),

                  /// Thikr and Dua before bed:
                  _Cell(const _IconThikr(), pinned, tod, QUEST.LAYL_THIKR,
                      dis: dis),
                  _Cell(const _IconDua(), pinned, tod, QUEST.LAYL_DUA,
                      dis: dis),
                  _Cell(T('Sleep', tsWhite), pinned, tod, QUEST.LAYL_SLEEP,
                      dis: dis),

                  /// Tahhajud and Witr after waking up
                  _Cell(T('Tahajjud', tsThjd), pinned, tod, QUEST.LAYL_TAHAJJUD,
                      dis: dis),
                  _Cell(T('Witr', tsWitr), pinned, tod, QUEST.LAYL_WITR,
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
      delegate: const _SliverAppBarDelegate(
        minHeight: 5.0, // should match padding size for nice look
        maxHeight: 5.0,
        child: SizedBox(),
      ),
    );
  }

  /// Use to make scrolling of active salah always pin when scrolling up.
  SliverPersistentHeader sliverSpaceHeaderFiller(BuildContext context) {
    final double height = // hide behind here
        MediaQuery.of(context).size.height - minAppBarHeight;
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: height,
        maxHeight: height,
        child: const SizedBox(),
      ),
    );
  }

  /// Iterate through given TODs and see if it matches the current TOD.
  bool isPinned(List<TOD> tods) {
    TOD currTOD = ZamanController.to.currTOD;
    for (TOD tod in tods) {
      if (tod == currTOD) {
        return true;
      }
    }

    return false; // this time of day is not
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      if (c.tod == null) {
        return Container(); // TODO show spinner?
      }

      final bool pinnedFajr = isPinned([TOD.Fajr, TOD.Fajr_Tomorrow]);
      final bool pinnedDuha = c.showSunnahDuha &&
          isPinned(
              [TOD.Karahat_Sunrise, TOD.Ishraq, TOD.Duha, TOD.Karahat_Istiwa]);
      final bool pinnedDuhr = isPinned([TOD.Dhuhr]);
      final bool pinnedAsr = isPinned([TOD.Asr, TOD.Karahat_Sun_Setting]);
      final bool pinnedMaghrib = isPinned([TOD.Maghrib]);
      final bool pinnedIsha = isPinned([TOD.Isha]);
      final bool pinnedLayl = c.showSunnahLayl &&
          ActiveQuestsAjrController.to.isIshaIbadahComplete &&
          isPinned([TOD.Isha, TOD.Night__2, TOD.Night__3]);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5), // match sliver gap
        child: CustomScrollView(
          slivers: <Widget>[
            /// Show Top App Bar
            SliverAppBar(
              backgroundColor: Colors.grey.shade800, // logoText/unselected
              expandedHeight: 175.0,
              collapsedHeight: c.showSunnahKeys ? 90.0 : minAppBarHeight,
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
            _Sliv(
              FlipCard(
                flipOnTouch: false,
                controller: cflipCardFajr,
                direction: FlipDirection.HORIZONTAL,
                front: rowFajr(c, pinnedFajr),
                back: rowNoActionFlipCard(
                  c,
                  fardRkt: '2',
                  tod: TOD.Fajr_Tomorrow,
                  salahTimeStart: c.tod!.fajrTomorrow,
                  salahTimeEnd: c.tod!.sunriseTomorrow,
                  muakBef: '2',
                  isJummahMode: false,
                  flipCardController: cflipCardFajr,
                ),
              ),
              pinnedFajr,
            ),
            sliverSpaceHeader(pinnedFajr),

            /// Duha:
            if (c.showSunnahDuha) _Sliv(rowDuha(c, pinnedDuha), pinnedDuha),
            if (c.showSunnahDuha) sliverSpaceHeader(pinnedDuha),

            /// Dhuhr/Jummah:
            _Sliv(
              c.isFriday() && c.showJummahOnFriday
                  ? FlipCard(
                      flipOnTouch: false,
                      controller: cflipCardDhuhr,
                      direction: FlipDirection.HORIZONTAL,
                      // Jummah Mode:
                      front: rowDhuhr(c, pinnedDuhr,
                          fardRkt: '2', muakAft: '6', isJummahMode: true),
                      back: rowNoActionFlipCard(
                        c,
                        fardRkt: '4',
                        tod: TOD.Dhuhr,
                        salahTimeStart: c.tod!.dhuhr,
                        muakBef: '4',
                        muakAft: '2',
                        naflAft: '2',
                        isJummahMode: false,
                        flipCardController: cflipCardDhuhr,
                      ),
                    )
                  : FlipCard(
                      flipOnTouch: false,
                      controller: cflipCardDhuhr,
                      direction: FlipDirection.HORIZONTAL,
                      front: rowDhuhr(c, pinnedDuhr,
                          fardRkt: '4', muakAft: '2', isJummahMode: false),
                      back: rowNoActionFlipCard(
                        c,
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
              pinnedDuhr,
            ),
            sliverSpaceHeader(pinnedDuhr),

            /// Asr:
            _Sliv(rowAsr(c, pinnedAsr), pinnedAsr),
            sliverSpaceHeader(pinnedAsr),

            /// Maghrib:
            _Sliv(rowMaghrib(c, pinnedMaghrib), pinnedMaghrib),
            sliverSpaceHeader(pinnedMaghrib),

            /// Isha:
            _Sliv(rowIsha(c, pinnedIsha), pinnedIsha),
            sliverSpaceHeader(pinnedIsha),

            /// Layl Ibadah:
            if (c.showSunnahLayl)
              _Sliv(
                c.showLast3rdOfNight
                    ? FlipCard(
                        flipOnTouch: false,
                        controller: cflipCardLayl,
                        direction: FlipDirection.HORIZONTAL,
                        front: rowLayl(TOD.Night__3, pinnedLayl, false),
                        back: rowLayl(TOD.Night__2, false, true),
                      )
                    : FlipCard(
                        flipOnTouch: false,
                        controller: cflipCardLayl,
                        direction: FlipDirection.HORIZONTAL,
                        front: rowLayl(TOD.Night__2, pinnedLayl, false),
                        back: rowLayl(TOD.Night__3, false, true),
                      ),
                pinnedLayl,
              ),
            if (c.showSunnahLayl) sliverSpaceHeader(pinnedLayl),

            /// Fillers:
            sliverSpaceHeader(true),
            sliverSpaceHeaderFiller(context), // height of the page
          ],
        ),
      );
    });
  }
}

class _SalahHeader extends StatelessWidget {
  const _SalahHeader(
    this.tod,
    this.pinned,
    this.c,
    this.isJummahMode,
    this.salahTimeStart,
    this.salahTimeEnd,
    this.flipCardController,
  );

  final TOD tod;
  final bool pinned;
  final ActiveQuestsController c;
  final bool isJummahMode;
  final DateTime salahTimeStart;
  final DateTime? salahTimeEnd;
  final FlipCardController? flipCardController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        child: Container(
          color: pinned && ((!isJummahMode) || (isJummahMode && c.isFriday()))
              ? Theme.of(context).scaffoldBackgroundColor
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
                  onTap: () => c.toggleFlipCard(flipCardController!),
                ),
              const SizedBox(width: 10),
              Text(
                isJummahMode ? 'Jummah' : tod.niceName,
                style: TS(20.0, Theme.of(context).textTheme.headline6!.color!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    ActiveQuestsUI2.getTimeRange(salahTimeStart, salahTimeEnd),
                    style: Theme.of(context).textTheme.headline6!,
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

/// Used to Fill in the gaps that were between the salah row cells. Also, adds a
/// border for nicer looks and returns a SliverPersistentHeader.
class _Sliv extends StatelessWidget {
  const _Sliv(this.widget, this.pinned);

  final Widget widget;
  final bool pinned;

  @override
  SliverPersistentHeader build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: 64,
        maxHeight: 64,
        child: Container(
          decoration: BoxDecoration(
            color: pinned
                ? Theme.of(context).scaffoldBackgroundColor
                : AppThemes.unselected,
            border: Border.all(
              // selects entire salah row if pinned
              color: pinned ? AppThemes.selected : Colors.grey.shade800,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          child: widget,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
    this._widget,
    this._pinned,
    this._tod,
    this._quest, {
    this.flex = 1000,
    this.dis = false,
  });

  final Widget _widget;
  final bool _pinned;
  final TOD _tod;
  final QUEST _quest;
  final int flex;

  /// used to prevent any actions on FlipCard
  final bool dis;

  @override
  Widget build(BuildContext context) {
    final _ActionWidget _actionWidget = _ActionWidget(
      isActive: _pinned,
      tod: _tod,
      quest: _quest,
      dis: dis,
      widget: _widget,
    );

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => MenuController.to
            .pushSubPage(SubPage.Active_Quest_Action, arguments: {
          'tod': _tod,
          'quest': _quest,
          'widget': _widget,
          'pinned': _pinned,
        }),
        child: Container(
          decoration: BoxDecoration(
            // color: _pinned
            //     ? Theme.of(context).scaffoldBackgroundColor
            //     : AppThemes.unselected,
            border: // selects container around the current active quest
                _pinned && ActiveQuestsAjrController.to.isQuestActive(_quest)
                    ? Border.all(color: AppThemes.logoText)
                    : null,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Stack(
            children: [
              _actionWidget,
              if (ActiveQuestsAjrController.to.isDone(_quest))
                const Center(
                  child:
                      Icon(Icons.check_outlined, size: 30, color: Colors.green),
                ),
              if (ActiveQuestsAjrController.to.isSkip(_quest))
                const Center(
                  child: Icon(Icons.redo_outlined, size: 20, color: Colors.red),
                ),
              if (ActiveQuestsAjrController.to.isMiss(_quest))
                const Center(
                  child:
                      Icon(Icons.close_outlined, size: 20, color: Colors.red),
                ),
            ],
          ),
          //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
        ),
      ),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  const _ActionWidget({
    Key? key,
    required bool isActive,
    required TOD tod,
    required QUEST quest,
    required this.dis,
    required Widget widget,
  })  : _pinned = isActive,
        _tod = tod,
        _quest = quest,
        _widget = widget,
        super(key: key);

  final bool _pinned;
  final TOD _tod;
  final QUEST _quest;
  final bool dis;
  final Widget _widget;

  @override
  Widget build(BuildContext context) {
    GrowShrinkAlert? growShrinkAlert;
    if (_pinned && ActiveQuestsAjrController.to.isQuestActive(_quest)) {
      growShrinkAlert = GrowShrinkAlert(
        dis || _quest == QUEST.NONE
            ? _widget
            : Hero(tag: _quest, child: _widget),
      );
    }
    return Center(
      child: growShrinkAlert ??
          (dis || _quest == QUEST.NONE
              ? _widget
              : Hero(tag: _quest, child: _widget)),
    );
  }
}

class _SunCell extends StatelessWidget {
  const _SunCell(this._sunIcon, this._label, this._time1, this._time2);

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
              ActiveQuestsUI2.getTimeRange(_time1, _time2),
              style: _tsAdhkar,
            ),
          ],
        ),
        if (_label != '') Text(_label, style: _tsAdhkar),
      ],
    );
  }
}

class _IconSunrise extends StatelessWidget {
  const _IconSunrise(this.pinned);

  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(angle: 4.71239, child: const _IconSun()),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: pinned
                ? Theme.of(context).scaffoldBackgroundColor
                : AppThemes.unselected,
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

class _IconSunset extends StatelessWidget {
  const _IconSunset(this.pinned);

  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(angle: 4.71239, child: const _IconSun()),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: pinned
                ? Theme.of(context).scaffoldBackgroundColor
                : AppThemes.unselected,
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

class _IconSun extends StatelessWidget {
  const _IconSun();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.orange,
      size: 18,
    );
  }
}

class _IconSunBright extends StatelessWidget {
  const _IconSunBright();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.yellow,
      size: 18,
    );
  }
}

class _IconThikr extends StatelessWidget {
  const _IconThikr();

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

class _IconDua extends StatelessWidget {
  const _IconDua();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.volunteer_activism, color: Colors.grey, size: 25);
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

/// TS = TextStyle - helper class to make init code shorter
class TS extends TextStyle {
  const TS(
    double fontSize,
    Color color, {
    FontWeight fontWeight = FontWeight.bold,
  }) : super(fontSize: fontSize, color: color, fontWeight: fontWeight);
}
*/
