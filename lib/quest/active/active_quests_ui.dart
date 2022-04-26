import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/components/alerts/bounce_alert.dart';
import 'package:hapi/components/seperator.dart';
import 'package:hapi/components/two_colored_icon.dart';
import 'package:hapi/controllers/notification_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';
import 'package:hapi/quest/active/sun_mover/quest_ring.dart';
import 'package:hapi/quest/active/sun_mover/sun_ring.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:sliver_tools/sliver_tools.dart';

/// used in multiple classes, shorten here
const TS tsText = TS(AppThemes.ldTextColor);

class ActiveQuestsUI extends StatelessWidget {
  static const TS tsAppBar = TS(Colors.white70);

  static String getTime(DateTime? time) => getTimeRange(time, null);
  static String getTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) return '-'; // still initializing

    int startHour = startTime.hour;
    String startAmPm = '';
    if (ActiveQuestsController.to.show12HourClock) {
      if (startHour >= 12) {
        startHour -= 12;
        startAmPm = 'P';
      } else {
        startAmPm = 'A';
      }
      if (startHour == 0) startHour = 12;
    }

    String endTimeString = '';
    if (endTime != null) {
      int endHour = endTime.hour;
      int endMinute = endTime.minute;
      String endAmPm = '';

      String minutes = endMinute.toString();
      if (endMinute < 10) minutes = '0$minutes'; // pad so looks good on UI

      String seconds = '';
      if (ActiveQuestsController.to.showSecPrecision) {
        int secs = endTime.second;
        seconds = secs.toString();
        if (secs < 10) {
          seconds = ':0$seconds';
        } else {
          seconds = ':$seconds';
        }
      }

      if (ActiveQuestsController.to.show12HourClock) {
        if (endHour >= 12) {
          endHour -= 12;
          endAmPm = 'P';
        } else {
          endAmPm = 'A';
        }
        if (endHour == 0) endHour = 12;

        endTimeString = '-${endHour.toString()}:$minutes$seconds$endAmPm';

        // if AM/PM are same, don't show twice
        if (startAmPm == endAmPm) startAmPm = '';
      } else {
        endTimeString = '-${endHour.toString()}:$minutes$seconds';
      }
    }

    // pad hour and minutes so looks good on UI
    String hour = startHour.toString();
    if (startHour < 10) hour = '  $hour'; // NOTE: double space to align

    int startMinute = startTime.minute;
    String minutes = startMinute.toString();
    if (startMinute < 10) minutes = '0$minutes'; // pad so looks good on UI

    String seconds = '';
    if (ActiveQuestsController.to.showSecPrecision) {
      int secs = startTime.second;
      seconds = secs.toString();
      if (secs < 10) {
        seconds = ':0$seconds';
      } else {
        seconds = ':$seconds';
      }
    }

    return '$hour:$minutes$seconds$startAmPm$endTimeString';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      l.d('ActiveQuestsUI.build()');
      ZamanController zc = ZamanController.to;
      if (zc.athan == null) return Container(); // not initialized yet, return
      final Athan athan = zc.athan!;

      final Color sc = cs(context);

      return CustomScrollView(
        slivers: <Widget>[
          /// Show Top App Bar
          SliverAppBar(
            backgroundColor: sc,
            expandedHeight: 175.0,
            collapsedHeight: 56.0, // any smaller is exception
            snap: true,
            floating: true, // allows picture to dragged out after fully compact
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.all(12.0),
              title: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: Container(
                  color: sc.withOpacity(.20),
                  child: Tooltip(
                    message: 'Time (hours:minutes:seconds) until ' +
                        ZamanController.to.currZ.niceName() +
                        ' ends and ' +
                        ZamanController.to.nextZ.niceName() +
                        ' begins',
                    child: GetBuilder<ZamanController>(builder: (c) {
                      return T(c.timeToNextZaman, tsAppBar, w: 90, h: 30);
                    }),
                  ),
                ),
              ),
              background: Swiper(
                itemCount: 3, // TODO add more images
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/quests/active$index.jpg',
                          fit: BoxFit.cover, // .fill will stretch image
                        ),
                      ),
                      if (index == c.swiperImageIdx) // if pinned show icon
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.play_arrow),
                          ),
                        )
                    ],
                  );
                },
                index:
                    c.swiperImageIdx != -1 ? c.swiperImageIdx : c.swiperLastIdx,
                autoplay: c.swiperAutoPlayEnabled,
                onTap: (idx) => c.toggleSwiperAutoPlayEnabled(idx),
                autoplayDelay: 10000, // ms to show picture
                duration: 1250, // ms to transition/animate to new picture
              ),
            ),
          ),

          SalahRow(athan, c, ZR.Fajr, Z.Fajr),
          SalahRow(athan, c, ZR.Duha, Z.Duha),
          SalahRow(athan, c, ZR.Dhuhr, Z.Dhuhr),
          if (c.salahAsrSafe) SalahRow(athan, c, ZR.Asr, Z.Asr_Later),
          if (!c.salahAsrSafe) SalahRow(athan, c, ZR.Asr, Z.Asr_Earlier),
          SalahRow(athan, c, ZR.Maghrib, Z.Maghrib),
          SalahRow(athan, c, ZR.Isha, Z.Isha),
          if (c.last3rdOfNight) SalahRow(athan, c, ZR.Layl, Z.Layl__3),
          if (!c.last3rdOfNight) SalahRow(athan, c, ZR.Layl, Z.Layl__2),

          /// Use to make scrolling of active salah always pin when scrolling up.
          /// Still expands height but have no scroll
          const SliverFillRemaining(hasScrollBody: false),

          _SlivSunMover(athan),

          /// Use to make scrolling of active salah always pin when scrolling up.
          const SliverFillRemaining(), // Sun can scroll up and compress times
        ],
      );
    });
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
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      SizedBox.expand(child: Container(child: child));

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || // these are needed or won't update
      minHeight != oldDelegate.minHeight ||
      child != oldDelegate.child;
}

/// Sliver Header used for both header and it's child (salah actions)
class _Sliv extends StatelessWidget {
  const _Sliv(
    this.widget, {
    this.minHeight = _Sliv.slivH,
    this.maxHeight = _Sliv.slivH,
    this.pinned = true,
  });

  final Widget widget;
  final double minHeight;
  final double maxHeight;
  final bool pinned;

  static const double slivH = 32.0;

  @override
  SliverPersistentHeader build(BuildContext context) {
    return SliverPersistentHeader(
      floating: false,
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        child: widget,
      ),
    );
  }
}

/// SunRow is used to display the other times for a salah row, i.e. karahat
/// sunrise and karahat istiwa and for duha and karahat sunsetting for asr.
class SalahRow extends StatelessWidget {
  SalahRow(this.athan, this.c, this.zR, this.z);

  final Athan athan;
  final ActiveQuestsController c;
  final ZR zR;
  final Z z;

  late final double width;
  late final Color bg;
  late final TextStyle textStyle;
  late final bool isActive;

  static const TS tsFard = TS(AppThemes.ajr2Uncommon);
  static const TS tsMuak = TS(AppThemes.ajr4Epic);
  static const TS tsNafl = TS(AppThemes.ajr5Legendary);

  @override
  Widget build(BuildContext context) {
    width = w(context);
    bg = cb(context);
    textStyle = Theme.of(context).textTheme.headline6!;

    isActive = ZamanController.to.isSalahRowActive(z);
    return isActive && c.showActiveSalah // salah row is pinned under header
        ? MultiSliver(children: [
            _Sliv(_getSlidableHeader()),
            _Sliv(_getSalahActions()),
            _Sliv(_getSalahResults(), minHeight: 2, maxHeight: 2),
          ])
        // salah row not pinned, shrink it into the salah header
        : SliverStack(
            children: [
              // add separator/quest completion indicator on bottom, folds 1st
              _Sliv(
                // Start salah separator at end to give overlap effect
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _getSalahResults(),
                ),
                minHeight: c.showSalahResults ? (_Sliv.slivH) + 2 : 2,
                maxHeight: (_Sliv.slivH * 2) + 2, // so UI gets overlap effect
              ),
              // salah actions folds second
              _Sliv(
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _getSalahActions(),
                ),
                maxHeight: _Sliv.slivH * 2, // so UI gets overlap effect
              ),
              // top of stack, header hides all but sun on edges, is static
              _Sliv(_getSlidableHeader()),
            ],
          );
  }

  Widget _getSlidableHeader() {
    const Color cSound = Colors.greenAccent;
    const Color cVibrate = Colors.lightBlueAccent;

    return GetBuilder<NotificationController>(builder: (c) {
      return Slidable(
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          extentRatio: 1,
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              flex: 4,
              onPressed: null,
              backgroundColor: bg,
              foregroundColor: AppThemes.ldTextColor,
              label: '${zR == ZR.Duha ? 'Ishraq' : zR.name} Notifications',
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.togglePlayAthan(zR),
              backgroundColor: c.playAthan(zR) ? cSound : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: Icons.cell_tower_outlined,
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.togglePlayBeep(zR),
              backgroundColor: c.playBeep(zR) ? cSound : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: c.playBeep(zR)
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_outlined,
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.toggleVibrate(zR),
              backgroundColor: c.vibrate(zR) ? cVibrate : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: c.vibrate(zR)
                  ? Icons.vibration_rounded
                  : Icons.smartphone_outlined,
              autoClose: false,
            ),
            const SlidableAction(
              flex: 1,
              onPressed: null,
              backgroundColor: AppThemes.logoText,
              foregroundColor: Colors.white,
              icon: Icons.close,
              autoClose: true,
            ),
          ],
        ),
        child: _getSalahHeader(),
      );
    });
  }

  Widget _getSalahHeader() {
    final double w6 = width / 6;

    return InkWell(
      onTap: isActive
          ? () => c.toggleShowActiveSalah()
          : () => c.toggleShowSalahResults(),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: zR == ZR.Duha ? Colors.transparent : bg,
              width: (w6 * 2),
              height: _Sliv.slivH, // fills gaps
            ),
            Container(
              height: _Sliv.slivH, // needed
              color: bg, // middle Zaman name always colored
              child: Center(
                // Center needed to make fit height work
                child: T(
                  zR.name,
                  textStyle.copyWith(
                    color: isActive ? textStyle.color : AppThemes.ldTextColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  alignment: Alignment.centerLeft,
                  w: w6 - // Note below uses + for below
                      // if 12h time gets > width, else 24h name gets > width:
                      (ActiveQuestsController.to.show12HourClock ? 8 : -3),
                  h: 23, // tuned to find best value in all cases
                ),
              ),
            ),
            // middle spacer always colored
            Container(color: bg, width: 1),
            Container(
              height: _Sliv.slivH, // needed
              color: bg, // middle athan time always colored
              child: Center(
                // Center needed to make fit height work
                child: T(
                  ActiveQuestsUI.getTime(athan.getStartTime(z)),
                  textStyle.copyWith(
                    color: isActive ? textStyle.color : AppThemes.ldTextColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  alignment: ActiveQuestsController.to.show12HourClock
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  w: w6 -
                      1 // -1 for middle divider
                      + // if 24h name gets > width, else name gets > width:
                      (ActiveQuestsController.to.show12HourClock ? 8 : -3),
                  h: 23, // tuned to find best value in all cases
                ),
              ),
            ),
            Container(
              color: zR == ZR.Duha || zR == ZR.Asr ? Colors.transparent : bg,
              width: (w6 * 2),
              height: _Sliv.slivH, // fills gaps
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSalahActions() {
    switch (zR) {
      case (ZR.Fajr):
        return _actionsFajr();
      case (ZR.Duha):
        return _actionsDuha();
      case (ZR.Dhuhr):
        return _actionsDhuhr();
      case (ZR.Asr):
        return _actionsAsr();
      case (ZR.Maghrib):
        return _actionsMaghrib();
      case (ZR.Isha):
        return _actionsIsha();
      case (ZR.Layl):
        return _actionsLayl();
      default:
        String e = 'SunRow: unexpected zaman given: "$zR"';
        l.e(e);
        throw e;
    }
  }

  Widget _actionsFajr() {
    String muakBef = '2';
    String fardRkt = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(muakBef, tsMuak), isActive, z, QUEST.FAJR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, z, QUEST.FAJR_FARD),
        // 3 of 4. Sunnah after fard column items:
        _Cell(const T('', tsMuak), isActive, z, QUEST.NONE),
        _Cell(const T('', tsNafl), isActive, z, QUEST.NONE),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, z, QUEST.FAJR_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.FAJR_DUA),
      ],
    );
  }

  Widget _actionsDuha() {
    double w6 = (width / 6) - 10; // - 10 because too big on screen
    final bool isCurrQuest = isActive &&
        ActiveQuestsAjrController.to
            .isQuestActive(QUEST.KARAHAT_ADHKAR_SUNRISE);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cell(
          _SunCell(
            _IconSunUpDn(isCurrQuest, true),
            Z.Karahat_Morning_Adhkar.niceName(),
            athan.sunrise,
            athan.ishraq,
            true, // align left
          ),
          isActive,
          z,
          QUEST.KARAHAT_ADHKAR_SUNRISE,
          flex: 2000,
        ),
        _Cell(T('Ishraq', tsText, w: w6), isActive, z, QUEST.DUHA_ISHRAQ),
        _Cell(T('Duha', tsText, w: w6), isActive, z, QUEST.DUHA_DUHA),
        _Cell(
          _SunCell(
            const Icon(Icons.brightness_7_outlined,
                color: Colors.yellowAccent, size: 30),
            Z.Karahat_Istiwa.niceName(),
            athan.istiwa,
            athan.dhuhr,
            false, // align right
          ),
          isActive,
          z,
          QUEST.KARAHAT_ADHKAR_ISTIWA,
          flex: 2000,
        ),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget _actionsDhuhr() {
    String muakBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    if (TimeController.to.isFriday() && c.showJummahOnFriday) {
      fardRkt = '2';
      muakAft = '6';
    }

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(muakBef, tsMuak), isActive, z, QUEST.DHUHR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, z, QUEST.DHUHR_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, z, QUEST.DHUHR_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, z, QUEST.DHUHR_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, z, QUEST.DHUHR_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget _actionsAsr() {
    String naflBef = '4';
    String fardRkt = '4';

    final bool isCurrQuest = isActive &&
        ActiveQuestsAjrController.to.isQuestActive(QUEST.KARAHAT_ADHKAR_SUNSET);
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, z, QUEST.ASR_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, z, QUEST.ASR_FARD),
        // 3 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, z, QUEST.ASR_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.ASR_DUA),
        // 4 of 4. Evening adhkar
        _Cell(
          _SunCell(
            _IconSunUpDn(isCurrQuest, false),
            Z.Karahat_Evening_Adhkar.niceName(),
            athan.sunSetting,
            athan.maghrib,
            false, // align right
          ),
          isActive,
          z,
          QUEST.KARAHAT_ADHKAR_SUNSET,
          flex: 2000,
        ),
      ],
    );
  }

  Widget _actionsMaghrib() {
    String fardRkt = '3';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(const T('', TS(Colors.transparent)), isActive, z, QUEST.NONE),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, z, QUEST.MAGHRIB_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, z, QUEST.MAGHRIB_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, z, QUEST.MAGHRIB_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, z, QUEST.MAGHRIB_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.MAGHRIB_DUA),
      ],
    );
  }

  Widget _actionsIsha() {
    String naflBef = '4';
    String fardRkt = '4';
    String muakAft = '2';
    String naflAft = '2';

    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _Cell(T(naflBef, tsNafl), isActive, z, QUEST.ISHA_NAFLB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, z, QUEST.ISHA_FARD),
        // 3 of 4. Option 1: sunnah after fard column items:
        _Cell(T(muakAft, tsMuak), isActive, z, QUEST.ISHA_MUAKA),
        _Cell(T(naflAft, tsNafl), isActive, z, QUEST.ISHA_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, z, QUEST.ISHA_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.ISHA_DUA),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget _actionsLayl() {
    double w6 = width / 6;

    return Row(
      children: [
        _Cell(T('Qiyam', tsText, w: w6 - 10), isActive, z, QUEST.LAYL_QIYAM),

        // Thikr and Dua before bed:
        _Cell(_IconThikr(), isActive, z, QUEST.LAYL_THIKR),
        _Cell(_IconDua(), isActive, z, QUEST.LAYL_DUA),
        _Cell(T('Sleep', tsText, w: w6 - 10), isActive, z, QUEST.LAYL_SLEEP),

        // Tahajjud and Witr after waking up, no -10 on Tahajjud, it's small
        _Cell(T('Tahajjud', tsText, w: w6), isActive, z, QUEST.LAYL_TAHAJJUD),
        _Cell(T('Witr', tsText, w: w6 - 10), isActive, z, QUEST.LAYL_WITR),
      ],
    );
  }

  Widget _getSalahResults() {
    switch (zR) {
      case (ZR.Fajr):
        return _resultsFajr();
      case (ZR.Duha):
        return _resultsDuha();
      case (ZR.Dhuhr):
        return _resultsDhuhr();
      case (ZR.Asr):
        return _resultsAsr();
      case (ZR.Maghrib):
        return _resultsMaghrib();
      case (ZR.Isha):
        return _resultsIsha();
      case (ZR.Layl):
        return _resultsLayl();
      default:
        String e = '_getSalahResults: unexpected zaman given: "$zR"';
        l.e(e);
        throw e;
    }
  }

  Widget _resultsFajr() {
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _getResult(QUEST.FAJR_MUAKB),
        // 2 of 4. fard column item:
        _getResult(QUEST.FAJR_FARD, flex: 3000),
        // 3 of 4. Sunnah after fard column items:
        //_getResult(QUEST.NONE),
        //_getResult(QUEST.NONE),
        // 4 of 4. Thikr and Dua after fard:
        _getResult(QUEST.FAJR_THIKR),
        _getResult(QUEST.FAJR_DUA),
      ],
    );
  }

  Widget _resultsDuha() {
    return Row(
      children: [
        _getResult(QUEST.KARAHAT_ADHKAR_SUNRISE),
        _getResult(QUEST.DUHA_ISHRAQ),
        _getResult(QUEST.DUHA_DUHA),
        _getResult(QUEST.KARAHAT_ADHKAR_ISTIWA),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget _resultsDhuhr() {
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _getResult(QUEST.DHUHR_MUAKB),
        // 2 of 4. fard column item:
        _getResult(QUEST.DHUHR_FARD),
        // 3 of 4. Option 2: sunnah after fard column items:
        _getResult(QUEST.DHUHR_MUAKA),
        _getResult(QUEST.DHUHR_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _getResult(QUEST.DHUHR_THIKR),
        _getResult(QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget _resultsAsr() {
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _getResult(QUEST.ASR_NAFLB),
        // 2 of 4. fard column item:
        _getResult(QUEST.ASR_FARD),
        // 3 of 4. Thikr and Dua after fard:
        _getResult(QUEST.ASR_THIKR),
        _getResult(QUEST.ASR_DUA),
        // 4 of 4. Evening adhkar
        _getResult(QUEST.KARAHAT_ADHKAR_SUNSET, flex: 2000),
      ],
    );
  }

  Widget _resultsMaghrib() {
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        //_getResult(QUEST.NONE),
        // 2 of 4. fard column item:
        _getResult(QUEST.MAGHRIB_FARD, flex: 2000),
        // 3 of 4. Option 2: sunnah after fard column items:
        _getResult(QUEST.MAGHRIB_MUAKA),
        _getResult(QUEST.MAGHRIB_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _getResult(QUEST.MAGHRIB_THIKR),
        _getResult(QUEST.MAGHRIB_DUA),
      ],
    );
  }

  Widget _resultsIsha() {
    return Row(
      children: [
        // 1 of 4. sunnah before fard column item:
        _getResult(QUEST.ISHA_NAFLB),
        // 2 of 4. fard column item:
        _getResult(QUEST.ISHA_FARD),
        // 3 of 4. Option 1: sunnah after fard column items:
        _getResult(QUEST.ISHA_MUAKA),
        _getResult(QUEST.ISHA_NAFLA),
        // 4 of 4. Thikr and Dua after fard:
        _getResult(QUEST.ISHA_THIKR),
        _getResult(QUEST.ISHA_DUA),
      ],
    );
  }

  /// Note: returns GetBuilder since has FlipCard()
  Widget _resultsLayl() {
    return Row(
      children: [
        _getResult(QUEST.LAYL_QIYAM),

        // Thikr and Dua before bed:
        _getResult(QUEST.LAYL_THIKR),
        _getResult(QUEST.LAYL_DUA),
        _getResult(QUEST.LAYL_SLEEP),

        // Tahajjud and Witr after waking up, no -10 on Tahajjud, it's small
        _getResult(QUEST.LAYL_TAHAJJUD),
        _getResult(QUEST.LAYL_WITR),
      ],
    );
  }

  Widget _getResult(QUEST quest, {int flex = 1000}) {
    Color color1;
    Color color2;
    if (ActiveQuestsAjrController.to.isDone(quest)) {
      color1 = AppThemes.ajr2Uncommon;
      color2 = AppThemes.ajr2Uncommon;
//  } else if (ActiveQuestsAjrController.to.isSkip(quest)) {
    } else if (ActiveQuestsAjrController.to.isMiss(quest)) {
      color1 = AppThemes.ajr0Missed;
      color2 = AppThemes.ajr0Missed;
    } else {
      color1 = Colors.transparent; // it's skipped/not active yet
      color2 = AppThemes.ajr1Common;
    }

    // Row required flexible for some reason (ended up needing flex anyway):
    return Flexible(
      flex: flex,
      child: Separator(.5, .5, .5, topColor: color1, bottomColor: color2),
    );
  }
}

/// Used to Fill in the gaps that were between the salah row cells. Also, adds a
/// border for nicer looks and returns a SliverPersistentHeader.
class _SlivSunMover extends StatelessWidget {
  const _SlivSunMover(this.athan);

  final Athan athan;

  @override
  SliverPersistentHeader build(BuildContext context) {
    const double strokeWidth = 14;
    final double diameter = w(context) / GR;
    final double uiWidth = diameter + strokeWidth;

    /// due to paint weirdness, we must massage circle values
    final double baseDiameter = diameter - (strokeWidth / 2);

    Map<Z, ColorSlice> colorSlice = {};
    return SliverPersistentHeader(
      floating: false,
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: uiWidth,
        maxHeight: uiWidth,
        child: Stack(
          children: [
            SunRing(athan, baseDiameter + 4, strokeWidth, colorSlice),
            QuestRing(baseDiameter, strokeWidth / 6, colorSlice),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(
    this.widget,
    this.isActive,
    this.z,
    this.quest, {
    this.flex = 1000,
  });

  final Widget widget;
  final bool isActive;
  final Z z;
  final QUEST quest;
  final int flex;

  @override
  Widget build(BuildContext context) {
    bool isCurrQuest =
        isActive && ActiveQuestsAjrController.to.isQuestActive(quest);

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => MenuController.to
            .pushSubPage(SubPage.Active_Quest_Action, arguments: {
          'z': z,
          'quest': quest,
          'widget': widget,
          'isCurrQuest': isCurrQuest,
        }),
        child: Container(
          height: 32, // for duha/asr sun slide up sticky sliver effect
          width: w(context),
          color: cb(context), // fill in around border radius with bg color
          child: Container(
            // if current quest, draw red border and change color
            decoration: isCurrQuest
                ? BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(color: AppThemes.logoText),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  )
                : null,
            child: Center(
              // makes text size controllable in T()
              child: isCurrQuest
                  ? BounceAlert(Hero(tag: quest, child: widget))
                  : quest == QUEST.NONE // UI has 1+, can't hero tag
                      ? widget
                      : Hero(tag: quest, child: widget),
            ),
          ),
        ),
      ),
    );
  }
}

class _SunCell extends StatelessWidget {
  const _SunCell(
    this._sunIcon,
    this._label,
    this._time1,
    this._time2,
    this.alignLeft,
  );

  final Widget _sunIcon;
  final String _label;
  final DateTime _time1;
  final DateTime _time2;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final double w3 = MediaQuery.of(context).size.width / 3; // /3= 2 of 6 cells
    const double h2 = _Sliv.slivH / 2; // /2 = half a sliver size

    return Row(
      mainAxisAlignment:
          alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        _sunIcon,
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            T(
              _label,
              tsText,
              w: w3 - 40,
              h: h2 - 2, // a little extra needed for borders
            ),
            T(
              ActiveQuestsUI.getTimeRange(_time1, _time2),
              tsText,
              w: w3 - 40, // 40 = 32 icon + 2 selected + 6 sun shift
              h: h2 - 2,
            ),
          ],
        ),
      ],
    );
  }
}

class _IconSunUpDn extends StatelessWidget {
  const _IconSunUpDn(this.isCurrQuest, this.isSunrise);

  final bool isCurrQuest;
  final bool isSunrise;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // needed for positioned to work on sun icon:
        const SizedBox(width: _Sliv.slivH + 6, height: _Sliv.slivH),
        Positioned(
          left: 6,
          child: TwoColoredIcon(
            Icons.circle,
            _Sliv.slivH,
            const [Colors.orangeAccent, Colors.red, Colors.transparent],
            isCurrQuest ? cs(context) : cb(context),
            fillPercent: .60,
          ),
        ),
        Positioned(
          left: 6,
          top: (_Sliv.slivH / 4) + 2, // 25% down from center
          child: Icon(
            isSunrise
                ? Icons.arrow_drop_up_outlined // sunrise
                : Icons.arrow_drop_down_outlined, // sunset
            color: AppThemes.ldTextColor,
            size: _Sliv.slivH,
          ),
        ),
      ],
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
            child: Icon(Icons.favorite_outlined,
                color: Colors.pinkAccent, size: 33),
          ),
          Center(
            child: Icon(Icons.psychology_outlined,
                color: Colors.white70, size: 21),
          ),
        ],
      ),
    );
  }
}

class _IconDua extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      //const Icon(Icons.volunteer_activism, color: Colors.blueAccent, size: 25);
      const TwoColoredIcon(
        Icons.volunteer_activism,
        25,
        [Colors.pinkAccent, Colors.blueAccent, Colors.blueAccent],
        Colors.blueAccent,
        fillPercent: .75,
      );
}
