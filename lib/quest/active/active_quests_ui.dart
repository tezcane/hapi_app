import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/components/alerts/bounce_alert.dart';
import 'package:hapi/components/half_filled_icon.dart';
import 'package:hapi/components/seperator.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/quest_ring.dart';
import 'package:hapi/quest/active/sun_mover/sun_ring.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:sliver_tools/sliver_tools.dart';

const Color tsTextColor = Color(0xFF7F8B88);
const TS tsText = TS(tsTextColor); // Duha and Layl color

class ActiveQuestsUI extends StatelessWidget {
  static const TS tsAppBar = TS(Colors.white70);

  static String getTime(DateTime? time) {
    return getTimeRange(time, null);
  }

  static String getTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) return '-';

    int startHour = startTime.hour;
    String startAmPm = '';
    if (ActiveQuestsController.to.show12HourClock) {
      if (startHour >= 12) {
        startHour -= 12;
        startAmPm = ' PM';
      } else {
        startAmPm = ' AM';
      }
      if (startHour == 0) startHour = 12;
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
        if (endHour == 0) endHour = 12;

        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}$endAmPm';

        // if AM/PM are same, don't show twice
        if (startAmPm == endAmPm) startAmPm = '';
      } else {
        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}';
      }
    }

    // pad hour and minutes so looks good on UI
    String hour = startHour.toString();
    if (startHour < 10) hour = '  $hour'; // NOTE: double space to align

    int startMinute = startTime.minute;
    String minutes = startMinute.toString();
    if (startMinute < 10) minutes = '0$minutes'; // pad so looks good on UI

    return '$hour:$minutes$startAmPm$endTimeString';
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

          SalahRow(athan, c, Z.Fajr),
          SalahRow(athan, c, Z.Duha),
          SalahRow(athan, c, Z.Dhuhr),
          if (c.salahAsrSafe) SalahRow(athan, c, Z.Asr_Later),
          if (!c.salahAsrSafe) SalahRow(athan, c, Z.Asr_Earlier),
          SalahRow(athan, c, Z.Maghrib),
          SalahRow(athan, c, Z.Isha),
          if (c.last3rdOfNight) SalahRow(athan, c, Z.Night__3),
          if (!c.last3rdOfNight) SalahRow(athan, c, Z.Night__2),

          /// Use to make scrolling of active salah always pin when scrolling up.
          const SliverFillRemaining(), // allow SunMover to scroll down

          /// Now show sun movement
          _SlivSunMover(athan),

          /// Use to make scrolling of active salah always pin when scrolling up.
          const SliverFillRemaining(), // allow SunMover to scroll up
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
/// sunrise and karahat zawal and for duha and karahat sunsetting for asr.
class SalahRow extends StatelessWidget {
  SalahRow(this.athan, this.c, this.z);

  final Athan athan;
  final ActiveQuestsController c;
  final Z z;

  late final double width;
  late final Color bg;
  late final TextStyle textStyle;

  late bool isActive;

  // TODO don't use white for all, Theme.of(context).textTheme.headline6!:
  static const TS tsFard = TS(Colors.green);
  static const TS tsMuak = TS(Colors.purple);
  static const TS tsNafl = TS(Colors.orangeAccent);

  @override
  Widget build(BuildContext context) {
    width = w(context);
    bg = cb(context);
    textStyle = Theme.of(context).textTheme.headline6!;

    // special logic for isha and layl, to know when to highlight layl or not:
    isActive = ZamanController.to.isSalahRowActive(z);
    if (z == Z.Isha) {
      isActive &= !ActiveQuestsAjrController.to.isIshaIbadahComplete;
    } else if (z == Z.Night__3 || z == Z.Night__2) {
      isActive &= ActiveQuestsAjrController.to.isIshaIbadahComplete;
    }

    return isActive && c.showActiveSalah // salah row is pinned under header
        ? MultiSliver(children: [
            _Sliv(_getSalahHeader()),
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
              _Sliv(_getSalahHeader()),
            ],
          );
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
              color: z == Z.Duha ? Colors.transparent : bg,
              width: (w6 * 2),
              height: _Sliv.slivH, // fills gaps
            ),
            Container(
              height: _Sliv.slivH, // needed
              color: bg, // middle Zaman name always colored
              child: Center(
                // Center needed to make fit height work
                child: T(
                  z.niceName(shortenAsrName: true),
                  textStyle.copyWith(
                    color: isActive ? textStyle.color : tsTextColor,
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
                    color: isActive ? textStyle.color : tsTextColor,
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
              color: z == Z.Duha || z == Z.Asr_Later || z == Z.Asr_Earlier
                  ? Colors.transparent
                  : bg,
              width: (w6 * 2),
              height: _Sliv.slivH, // fills gaps
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSalahActions() {
    switch (z) {
      case (Z.Fajr):
        return _actionsFajr();
      case (Z.Duha):
        return _actionsDuha();
      case (Z.Dhuhr):
        return _actionsDhuhr();
      case (Z.Asr_Later):
      case (Z.Asr_Earlier):
        return _actionsAsr();
      case (Z.Maghrib):
        return _actionsMaghrib();
      case (Z.Isha):
        return _actionsIsha();
      case (Z.Night__3):
      case (Z.Night__2):
        return _actionsLayl();
      default:
        String e = 'SunRow: unexpected zaman given: "$z"';
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
        _Cell(T(muakBef, tsMuak), isActive, QUEST.FAJR_MUAKB),
        // 2 of 4. fard column item:
        _Cell(T(fardRkt, tsFard), isActive, QUEST.FAJR_FARD),
        // 3 of 4. Sunnah after fard column items:
        _Cell(const T('', tsMuak), isActive, QUEST.NONE),
        _Cell(const T('', tsNafl), isActive, QUEST.NONE),
        // 4 of 4. Thikr and Dua after fard:
        _Cell(_IconThikr(), isActive, QUEST.FAJR_THIKR),
        _Cell(_IconDua(), isActive, QUEST.FAJR_DUA),
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
          QUEST.KARAHAT_ADHKAR_SUNRISE,
          flex: 2000,
        ),
        _Cell(T('Ishraq', tsText, w: w6), isActive, QUEST.DUHA_ISHRAQ),
        _Cell(T('Duha', tsText, w: w6), isActive, QUEST.DUHA_DUHA),
        _Cell(
          _SunCell(
            const Icon(Icons.brightness_7_outlined,
                color: Colors.yellowAccent, size: 30),
            Z.Karahat_Zawal.niceName(),
            athan.zawal,
            athan.dhuhr,
            false, // align right
          ),
          isActive,
          QUEST.KARAHAT_ADHKAR_ZAWAL,
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

  Widget _actionsAsr() {
    String naflBef = '4';
    String fardRkt = '4';

    final bool isCurrQuest = isActive &&
        ActiveQuestsAjrController.to.isQuestActive(QUEST.KARAHAT_ADHKAR_SUNSET);
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
            _IconSunUpDn(isCurrQuest, false),
            Z.Karahat_Evening_Adhkar.niceName(),
            athan.sunSetting,
            athan.maghrib,
            false, // align right
          ),
          isActive,
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

  Widget _actionsIsha() {
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
  Widget _actionsLayl() {
    double w6 = width / 6;

    return Row(
      children: [
        _Cell(T('Qiyam', tsText, w: w6 - 10), isActive, QUEST.LAYL_QIYAM),

        // Thikr and Dua before bed:
        _Cell(_IconThikr(), isActive, QUEST.LAYL_THIKR),
        _Cell(_IconDua(), isActive, QUEST.LAYL_DUA),
        _Cell(T('Sleep', tsText, w: w6 - 10), isActive, QUEST.LAYL_SLEEP),

        // Tahajjud and Witr after waking up, no -10 on Tahajjud, it's small
        _Cell(T('Tahajjud', tsText, w: w6), isActive, QUEST.LAYL_TAHAJJUD),
        _Cell(T('Witr', tsText, w: w6 - 10), isActive, QUEST.LAYL_WITR),
      ],
    );
  }

  Widget _getSalahResults() {
    switch (z) {
      case (Z.Fajr):
        return _resultsFajr();
      case (Z.Duha):
        return _resultsDuha();
      case (Z.Dhuhr):
        return _resultsDhuhr();
      case (Z.Asr_Later):
      case (Z.Asr_Earlier):
        return _resultsAsr();
      case (Z.Maghrib):
        return _resultsMaghrib();
      case (Z.Isha):
        return _resultsIsha();
      case (Z.Night__3):
      case (Z.Night__2):
        return _resultsLayl();
      default:
        String e = 'SunRow: unexpected zaman given: "$z"';
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
        _getResult(QUEST.KARAHAT_ADHKAR_ZAWAL),
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
    if (ActiveQuestsAjrController.to.isDone(quest)) {
      color1 = Colors.green;
    } else if (ActiveQuestsAjrController.to.isSkip(quest)) {
      color1 = Colors.yellow.shade600;
    } else if (ActiveQuestsAjrController.to.isMiss(quest)) {
      color1 = Colors.red;
    } else {
      // it's currently active or time hasn't come yet
      color1 = Colors.grey;
    }

    // Row required flexible for some reason (ended up needing flex anyway):
    return Flexible(
      flex: flex,
      child: Separator(.5, .5, .5, topColor: color1, bottomColor: color1),
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
    final double width = diameter + strokeWidth;
    return SliverPersistentHeader(
      floating: false,
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: width,
        maxHeight: width,
        child: Stack(
          children: [
            QuestRing(athan, diameter - (strokeWidth / 2), strokeWidth / 6),
            SunRing(athan, diameter - (strokeWidth / 2) + 4, strokeWidth),
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
    this.quest, {
    this.flex = 1000,
  });

  final Widget widget;
  final bool isActive;
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
              h: h2 - 1,
            ),
            T(
              ActiveQuestsUI.getTimeRange(_time1, _time2),
              tsText,
              w: w3 - 40, // 40 = 32 icon + 2 selected + 6 sun shift
              h: h2 - 1, // - 1 selected for red selection around
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
            color: tsTextColor,
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
