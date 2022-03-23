import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/components/alerts/bounce_alert.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

const Color tsTextColor = Colors.grey; // Sun Icon and Text
const TS tsText = TS(tsTextColor); // Duha and Layl color

class ActiveQuestsUI extends StatelessWidget {
  static const TS tsAppBar = TS(Colors.white70);

  // TODO don't use white for all, Theme.of(context).textTheme.headline6!:
  static const TS tsFard = TS(Colors.red);
  static const TS tsMuak = TS(Colors.green);
  static final TS tsNafl = TS(Colors.amber.shade700);

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
    String muakBef = '2';
    String fardRkt = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(muakBef, tsMuak), isActive, QUEST.FAJR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.FAJR_FARD),
        // 3 of 4. Sunnah after fard column items:
        _Cell(T('', tsMuak), isActive, QUEST.NONE),
        _Cell(T('', tsNafl), isActive, QUEST.NONE),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.FAJR_THIKR),
        _Cell(_IconDua(), isActive, QUEST.FAJR_DUA),
      ],
    );
  }

  Widget rowDuha(Athan athan, bool isActive, double screenWidth) {
    double w = (screenWidth / 6) - 10; // - 10 because too big on screen
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cell(
          _SunCell(_IconSunUpDn(isActive, true), 'Morning Adhkar',
              athan.sunrise, athan.ishraq),
          isActive,
          QUEST.KERAHAT_ADHKAR_SUNRISE,
          flex: 2000,
        ),
        _Cell(T('Ishraq', tsText, width: w), isActive, QUEST.DUHA_ISHRAQ),
        _Cell(T('Duha', tsText, width: w), isActive, QUEST.DUHA_DUHA),
        _Cell(
          _SunCell(_IconSunBright(), 'Zawal', athan.zawal, athan.dhuhr),
          isActive,
          QUEST.KERAHAT_ADHKAR_ZAWAL,
          flex: 2000,
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget rowDhuhr(bool isActive, bool isJummah) {
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
        _Cell(T(muakBef, tsMuak), isActive, QUEST.DHUHR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.DHUHR_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, QUEST.DHUHR_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, QUEST.DHUHR_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.DHUHR_THIKR),
        _Cell(_IconDua(), isActive, QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget rowAsr(Athan athan, final bool isActive) {
    String naflBef = '4';
    String fardRkt = '4';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, QUEST.ASR_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.ASR_FARD),
        // 3 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.ASR_THIKR),
        _Cell(_IconDua(), isActive, QUEST.ASR_DUA),
        // 4 of 4. Evening adhkar
        _Cell(
            _SunCell(
              _IconSunUpDn(isActive, false),
              'Evening Adhkar',
              athan.sunSetting,
              athan.maghrib,
            ),
            isActive,
            QUEST.KERAHAT_ADHKAR_SUNSET,
            flex: 2000),
      ],
    );
  }

  Widget rowMaghrib(final bool isActive) {
    String fardRkt = '3';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(const T('', TS(Colors.transparent)), isActive, QUEST.NONE),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.MAGHRIB_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, QUEST.MAGHRIB_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, QUEST.MAGHRIB_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.MAGHRIB_THIKR),
        _Cell(_IconDua(), isActive, QUEST.MAGHRIB_DUA),
      ],
    );
  }

  Widget rowIsha(final bool isActive) {
    String naflBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, QUEST.ISHA_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.ISHA_FARD),
        // 3 of 4. Option 1: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, QUEST.ISHA_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, QUEST.ISHA_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.ISHA_THIKR),
        _Cell(_IconDua(), isActive, QUEST.ISHA_DUA),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget rowLayl(bool isActive, double width) {
    double w = (width / 6) - 10; // - 10 because too big on screen

    return Row(
      children: [
        _Cell(T('Qiyam', tsText, width: w), isActive, QUEST.LAYL_QIYAM),

        // Thikr and Dua before bed:
        _Cell(_IconThikr(), isActive, QUEST.LAYL_THIKR),
        _Cell(_IconDua(), isActive, QUEST.LAYL_DUA),
        _Cell(T('Sleep', tsText, width: w), isActive, QUEST.LAYL_SLEEP),

        // Tahhajud and Witr after waking up
        _Cell(T('Tahajjud', tsText, width: width / 6), isActive,
            QUEST.LAYL_TAHAJJUD),
        _Cell(T('Witr', tsText, width: w), isActive, QUEST.LAYL_WITR),
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
      var zc = ZamanController.to;
      if (zc.athan == null) return Container(); // not initialized yet, return
      final Athan athan = zc.athan!;

      final double w = MediaQuery.of(context).size.width;

      final bool isIshaDone = ActiveQuestsAjrController.to.isIshaIbadahComplete;

      final bool isFajr = zc.isSalahRowActive(Z.Fajr);
      final bool isDuha = zc.isSalahRowActive(Z.Duha);
      final bool isDhhr = zc.isSalahRowActive(Z.Dhuhr);
      final bool isAasr = zc.isSalahRowActive(Z.Asr);
      final bool isMgrb = zc.isSalahRowActive(Z.Maghrib);
      final bool isIsha = zc.isSalahRowActive(Z.Isha) && !isIshaDone;
      final bool isLayl = zc.isSalahRowActive(Z.Night__3) && isIshaDone;

      Z laylZ = Z.Night__3;
      DateTime laylDate = athan.last3rdOfNight;
      if (!c.showLast3rdOfNight) {
        laylZ = Z.Night__2;
        laylDate = athan.middleOfNight;
      }

      final bool isJ = TimeController.to.isFriday() && c.showJummahOnFriday;

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
              title: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Container(
                    color: Colors.grey.shade800.withOpacity(.20),
                    child: GetBuilder<ZamanController>(builder: (c) {
                      return T(c.timeToNextZaman, tsAppBar, width: 85);
                    }),
                  ),
                ),
              ),
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

          _Sliv(true, _SalahHeader(Z.Fajr, isFajr, athan.fajr)),
          _Sliv(isFajr && c.showActiveSalah, rowFajr(isFajr)),

          _Sliv(true, _SalahHeader(Z.Duha, isDuha, athan.sunrise)),
          _Sliv(isDuha && c.showActiveSalah, rowDuha(athan, isDuha, w)),

          _Sliv(true, _SalahHeader(Z.Dhuhr, isDhhr, athan.dhuhr, isJ: isJ)),
          _Sliv(isDhhr && c.showActiveSalah, rowDhuhr(isDhhr, isJ)),

          _Sliv(true, _SalahHeader(Z.Asr, isAasr, athan.asr)),
          _Sliv(isAasr && c.showActiveSalah, rowAsr(athan, isAasr)),

          _Sliv(true, _SalahHeader(Z.Maghrib, isMgrb, athan.maghrib)),
          _Sliv(isMgrb && c.showActiveSalah, rowMaghrib(isMgrb)),

          _Sliv(true, _SalahHeader(Z.Isha, isIsha, athan.isha)),
          _Sliv(isIsha && c.showActiveSalah, rowIsha(isIsha)),

          _Sliv(true, _SalahHeader(laylZ, isLayl, laylDate)),
          _Sliv(isLayl && c.showActiveSalah, rowLayl(isLayl, w)),

          /// Fillers:
          sliverSpaceHeaderFiller(context), // height of the page
        ],
      );
    });
  }
}

class _SalahHeader extends StatelessWidget {
  const _SalahHeader(
    this.z,
    this.isActive,
    this.salahTimeStart, {
    this.isJ = false, // isJummah
  });

  final Z z;
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
              isJ ? 'Jummah' : z.niceName,
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
    this._quest, {
    this.flex = 1000,
  });

  final Widget _widget;
  final bool _isActive;
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
                tsText,
                width: (w / 3) - 38, // 38= 30 icon + 6 L/R padding + 2 selected
                height: (_Sliv.sliverHeight / 2) - 1, // /2 sliv h + 1 selected
              ),
              T(
                ActiveQuestsUI.getTimeRange(_time1, _time2),
                tsText,
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

class _IconSunUpDn extends StatelessWidget {
  const _IconSunUpDn(this.isActive, this.isSunrise);

  final bool isActive;
  final bool isSunrise;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _IconSun(),
        Positioned(
          top: _Sliv.sliverHeight / 2,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10.0), // stay in active border
            ),
            child: Container(
              color: isActive ? cs(context) : cb(context),
              height: _Sliv.sliverHeight / 2,
              width: 30,
            ),
          ),
        ),
        Positioned(
          top: (_Sliv.sliverHeight / 4) + 2,
          child: Icon(
            isSunrise
                ? Icons.arrow_drop_up_outlined
                : Icons.arrow_drop_down_outlined,
            color: tsTextColor,
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
