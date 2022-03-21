import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/components/alerts/bounce_alert.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/tod.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class ActiveQuestsUI extends StatelessWidget {
  static const TS tsAppBar = TS(Colors.white70);

  // TODO don't use white for all, Theme.of(context).textTheme.headline6!:
  static const TS tsFard = TS(Colors.red);
  static const TS tsMuak = TS(Colors.green);
  static final TS tsNafl = TS(Colors.amber.shade700);
  static const TS tsText = TS(Colors.grey); // Duha and Layl color

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
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Container(
                    color: Colors.grey.shade800.withOpacity(.20),
                    child: T(c.timeToNextZaman, tsAppBar, width: 85),
                  ),
                );
                // return Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     // Column(
                //     //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     //   crossAxisAlignment: CrossAxisAlignment.end,
                //     //   children: [
                //     //     Row(
                //     //       children: [
                //     //         T(c.currTOD.niceName, tsAppBar, width: 25),
                //     //         T(' ends', tsAppBar, width: 25),
                //     //         const SizedBox(width: 1),
                //     //         const Icon(Icons.arrow_right_alt_rounded,
                //     //             color: Colors.white70, size: 12),
                //     //         //const SizedBox(width: 5),
                //     //       ],
                //     //     ),
                //     //     Row(
                //     //       children: [
                //     //         T(c.nextTOD.niceName, tsAppBar, width: 25),
                //     //         T(' in', tsAppBar, width: 25),
                //     //         const SizedBox(width: 1),
                //     //         const Icon(Icons.arrow_right_alt_rounded,
                //     //             color: Colors.white70, size: 12),
                //     //         //const SizedBox(width: 5),
                //     //       ],
                //     //     ),
                //     //   ],
                //     // ),
                //     Text(c.timeToNextZaman, style: tsAppBarTime),
                //   ],
                // );
              }),
            ],
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

  /// Note: returns GetBuilder since has FlipCard()
  Widget rowFajr(final bool isActive) {
    TOD tod = TOD.Fajr;
    String muakBef = '2';
    String fardRkt = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(muakBef, tsMuak), isActive, tod, QUEST.FAJR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, tod, QUEST.FAJR_FARD),
        // 3 of 4. Sunnah after fard column items:
        _Cell(T('', tsMuak), isActive, tod, QUEST.NONE),
        _Cell(T('', tsNafl), isActive, tod, QUEST.NONE),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, tod, QUEST.FAJR_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.FAJR_DUA),
      ],
    );
  }

  Widget rowDuha(ActiveQuestsController c, bool isActive, double screenWidth) {
    TOD tod = TOD.Duha;

    double w = (screenWidth / 6) - 10; // - 10 because too big on screen
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cell(
          _SunCell(
              _IconSunrise(), 'Morning Adhkar', c.tod!.sunrise, c.tod!.ishraq),
          isActive,
          tod,
          QUEST.KERAHAT_ADHKAR_SUNRISE,
          flex: 2000,
        ),
        _Cell(T('Ishraq', tsText, width: w), isActive, tod, QUEST.DUHA_ISHRAQ),
        _Cell(T('Duha', tsText, width: w), isActive, tod, QUEST.DUHA_DUHA),
        _Cell(
          _SunCell(_IconSunBright(), 'Zawal', c.tod!.zawal, c.tod!.dhuhr),
          isActive,
          tod,
          QUEST.KERAHAT_ADHKAR_ZAWAL,
          flex: 2000,
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget rowDhuhr(bool isActive, bool isJummah) {
    TOD tod = TOD.Dhuhr;

    String muakBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    if (isJummah) {
      fardRkt = '2';
      muakAft = '6';
    }

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(muakBef, tsMuak), isActive, tod, QUEST.DHUHR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, tod, QUEST.DHUHR_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, tod, QUEST.DHUHR_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, tod, QUEST.DHUHR_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, tod, QUEST.DHUHR_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget rowAsr(ActiveQuestsController c, final bool isActive) {
    TOD tod = TOD.Asr;

    String naflBef = '4';
    String fardRkt = '4';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, tod, QUEST.ASR_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, tod, QUEST.ASR_FARD),
        // 3 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, tod, QUEST.ASR_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.ASR_DUA),
        // 4 of 4. Evening adhkar
        _Cell(
            _SunCell(_IconSunset(), 'Evening Adhkar', c.tod!.sunSetting,
                c.tod!.maghrib),
            isActive,
            tod,
            QUEST.KERAHAT_ADHKAR_SUNSET,
            flex: 2000),
      ],
    );
  }

  Widget rowMaghrib(final bool isActive) {
    TOD tod = TOD.Maghrib;

    String fardRkt = '3';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(const T('', TS(Colors.transparent)), isActive, tod, QUEST.NONE),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, tod, QUEST.MAGHRIB_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, tod, QUEST.MAGHRIB_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, tod, QUEST.MAGHRIB_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, tod, QUEST.MAGHRIB_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.MAGHRIB_DUA),
      ],
    );
  }

  Widget rowIsha(final bool isActive) {
    TOD tod = TOD.Isha;

    String naflBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, tod, QUEST.ISHA_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, tod, QUEST.ISHA_FARD),
        // 3 of 4. Option 1: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, tod, QUEST.ISHA_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, tod, QUEST.ISHA_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, tod, QUEST.ISHA_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.ISHA_DUA),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget rowLayl(TOD tod, bool isActive, double width) {
    double w = (width / 6) - 10; // - 10 because too big on screen

    return Row(
      children: [
        _Cell(T('Qiyam', tsText, width: w), isActive, tod, QUEST.LAYL_QIYAM),

        // Thikr and Dua before bed:
        _Cell(_IconThikr(), isActive, tod, QUEST.LAYL_THIKR),
        _Cell(_IconDua(), isActive, tod, QUEST.LAYL_DUA),
        _Cell(T('Sleep', tsText, width: w), isActive, tod, QUEST.LAYL_SLEEP),

        // Tahhajud and Witr after waking up
        _Cell(T('Tahajjud', tsText, width: width / 6), isActive, tod,
            QUEST.LAYL_TAHAJJUD),
        _Cell(T('Witr', tsText, width: w), isActive, tod, QUEST.LAYL_WITR),
      ],
    );
  }

  /// Use to make scrolling of active salah always pin when scrolling up.
  SliverPersistentHeader sliverSpaceHeaderFiller(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return SliverPersistentHeader(
      pinned: false,
      delegate: _SliverAppBarDelegate(
        minHeight: height,
        maxHeight: height,
        child: const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      if (c.tod == null) return Container(); // not initialized yet

      double w = MediaQuery.of(context).size.width;

      bool isIshaDone = ActiveQuestsAjrController.to.isIshaIbadahComplete;

      final bool isActiveFajr = c.isSalahRowActive(TOD.Fajr);
      final bool isActiveDuha = c.isSalahRowActive(TOD.Duha);
      final bool isActiveDhhr = c.isSalahRowActive(TOD.Dhuhr);
      final bool isActiveAasr = c.isSalahRowActive(TOD.Asr);
      final bool isActiveMgrb = c.isSalahRowActive(TOD.Maghrib);
      final bool isActiveIsha = !isIshaDone && c.isSalahRowActive(TOD.Isha);
      final bool isActiveLayl = isIshaDone && c.isSalahRowActive(TOD.Night__3);

      TOD laylTOD = TOD.Night__3;
      DateTime laylDate = c.tod!.last3rdOfNight;
      if (!c.showLast3rdOfNight) {
        laylTOD = TOD.Night__2;
        laylDate = c.tod!.middleOfNight;
      }

      final bool isJ = c.isFriday() && c.showJummahOnFriday; // is Jummah

      return CustomScrollView(
        slivers: <Widget>[
          /// Show Top App Bar
          SliverAppBar(
            backgroundColor: Colors.grey.shade800,
            expandedHeight: 175.0,
            collapsedHeight: 90.0,
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.all(7.0),
              title: salahAppBar(),
              background: Swiper(
                itemCount: 3, //TODO add more images
                itemBuilder: (BuildContext context, int index) => Image.asset(
                  'assets/images/quests/active$index.jpg',
                  fit: BoxFit.cover,
                ),
                autoplay: true,
                autoplayDelay: 10000,
              ),
            ),
          ),

          _Sliv(true, _SalahHeader(TOD.Fajr, isActiveFajr, c.tod!.fajr)),
          _Sliv(isActiveFajr && c.showActiveSalah, rowFajr(isActiveFajr)),

          _Sliv(true, _SalahHeader(TOD.Duha, isActiveDuha, c.tod!.sunrise)),
          _Sliv(isActiveDuha && c.showActiveSalah, rowDuha(c, isActiveDuha, w)),

          _Sliv(true,
              _SalahHeader(TOD.Dhuhr, isActiveDhhr, c.tod!.dhuhr, isJ: isJ)),
          _Sliv(isActiveDhhr && c.showActiveSalah, rowDhuhr(isActiveDhhr, isJ)),

          _Sliv(true, _SalahHeader(TOD.Asr, isActiveAasr, c.tod!.asr)),
          _Sliv(isActiveAasr && c.showActiveSalah, rowAsr(c, isActiveAasr)),

          _Sliv(true, _SalahHeader(TOD.Maghrib, isActiveMgrb, c.tod!.maghrib)),
          _Sliv(isActiveMgrb && c.showActiveSalah, rowMaghrib(isActiveMgrb)),

          _Sliv(true, _SalahHeader(TOD.Isha, isActiveIsha, c.tod!.isha)),
          _Sliv(isActiveIsha && c.showActiveSalah, rowIsha(isActiveIsha)),

          _Sliv(true, _SalahHeader(laylTOD, isActiveLayl, laylDate)),
          _Sliv(isActiveLayl && c.showActiveSalah,
              rowLayl(laylTOD, isActiveLayl, w)),

          /// Fillers:
          sliverSpaceHeaderFiller(context), // height of the page
        ],
      );
    });
  }
}

class _SalahHeader extends StatelessWidget {
  const _SalahHeader(
    this.tod,
    this.isActive,
    this.salahTimeStart, {
    this.isJ = false, // isJummah
  });

  final TOD tod;
  final bool isActive;
  final DateTime salahTimeStart;
  final bool isJ;

  @override
  Widget build(BuildContext context) {
    final ActiveQuestsController c = ActiveQuestsController.to;

    return InkWell(
      onTap: isActive ? () => c.toggleShowActiveSalah() : null,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            T(
              ActiveQuestsUI.getTimeRange(salahTimeStart, null),
              TS(
                isActive
                    ? Theme.of(context).textTheme.headline6!.color!
                    : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              alignment: Alignment.centerRight,
            ),
            const SizedBox(width: 10),
            T(
              isJ ? 'Jummah' : tod.niceName,
              Theme.of(context).textTheme.headline6!.copyWith(
                    color: isActive
                        ? Theme.of(context).textTheme.headline6!.color
                        : Colors.grey.shade500,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
              alignment: Alignment.centerLeft,
            ),
          ],
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
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: child,
      ),
    );
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
  const _Sliv(this.pinned, this.widget);

  static const double sliverHeight = 32.0;
  final bool pinned;
  final Widget widget;

  @override
  SliverPersistentHeader build(BuildContext context) {
    return SliverPersistentHeader(
      floating: false,
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: sliverHeight,
        maxHeight: sliverHeight,
        child: widget,
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
    this._widget,
    this._isActive,
    this._tod,
    this._quest, {
    this.flex = 1000,
  });

  final Widget _widget;
  final bool _isActive;
  final TOD _tod;
  final QUEST _quest;
  final int flex;

  @override
  Widget build(BuildContext context) {
    bool isCurrQuest =
        _isActive && ActiveQuestsAjrController.to.isQuestActive(_quest);

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => MenuController.to
            .pushSubPage(SubPage.Active_Quest_Action, arguments: {
          'tod': _tod,
          'quest': _quest,
          'widget': _widget,
          'isActive': _isActive,
        }),
        child: isCurrQuest
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: AppThemes.logoText),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: BounceAlert(
                        _quest == QUEST.NONE
                            ? _widget
                            : Hero(tag: _quest, child: _widget),
                      ),
                    ),
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
              )
            : Stack(
                children: [
                  Center(
                    child: _quest == QUEST.NONE
                        ? _widget
                        : Hero(tag: _quest, child: _widget),
                  ),
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
      ),
    );
  }
}

class _SunCell extends StatelessWidget {
  const _SunCell(this._sunIcon, this._label, this._time1, this._time2);

  final Widget _sunIcon;
  final String _label;
  final DateTime _time1;
  final DateTime? _time2;

  static const TS _tsAdhkar = TS(Colors.white70, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sunIcon,
          Column(
            children: [
              T(
                _label,
                _tsAdhkar,
                width: (w / 3) - 38, // 38= 30 icon + 6 L/R padding + 2 selected
                height: (_Sliv.sliverHeight / 2) - 1, // /2 sliv h + 1 selected
              ),
              T(
                ActiveQuestsUI.getTimeRange(_time1, _time2),
                _tsAdhkar,
                width: (w / 3) - 38, // /3 = 1/3 screen (2 of 6 cells)
                height: _Sliv.sliverHeight / 2 - 1, // /2 sliv h + 1 selected
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconSunrise extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _IconSun(),
        Positioned(
          top: _Sliv.sliverHeight / 2,
          child: Container(
            color: Theme.of(context).backgroundColor,
            height: _Sliv.sliverHeight / 2,
            width: 30,
          ),
        ),
        const Positioned(
          top: (_Sliv.sliverHeight / 4) + 2,
          child: Icon(
            Icons.arrow_drop_up_outlined,
            color: Colors.white38,
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _IconSunset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _IconSun(),
        Positioned(
          top: _Sliv.sliverHeight / 2,
          child: Container(
            color: Theme.of(context).backgroundColor,
            height: _Sliv.sliverHeight / 2,
            width: 30,
          ),
        ),
        const Positioned(
          top: (_Sliv.sliverHeight / 4) + 2,
          child: Icon(
            Icons.arrow_drop_down_outlined,
            color: Colors.white38,
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _IconSun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.orangeAccent,
      size: 30,
    );
  }
}

class _IconSunBright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.brightness_7_outlined,
      color: Colors.yellow,
      size: 30,
    );
  }
}

class _IconThikr extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.volunteer_activism, color: Colors.grey, size: 25);
  }
}
