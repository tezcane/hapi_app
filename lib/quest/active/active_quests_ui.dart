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
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';
import 'package:hapi/quest/active/sun_mover/quest_ring.dart';
import 'package:hapi/quest/active/sun_mover/sun_ring.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ActiveQuestsUI extends StatelessWidget {
  const ActiveQuestsUI();

  @override
  Widget build(BuildContext context) {
    // Use builder here, since we need to make sure athan is set for all widgets
    return GetBuilder<ActiveQuestsController>(builder: (c) {
      // if not initialized yet, wait for UI before building
      if (ZamanController.to.athan == null) return Container();

      // can make const, but we need to refresh all UIs on updates here
      return CustomScrollView(
        slivers: <Widget>[
          _SlidingAppBar(c),

          SalahRow(c, Z.Fajr),
          SalahRow(c, Z.Duha),
          SalahRow(c, Z.Dhuhr),
          SalahRow(c, Z.Asr),
          SalahRow(c, Z.Maghrib),
          SalahRow(c, Z.Isha),
          SalahRow(c, Z.Middle_of_Night),
          SalahRow(c, Z.Last_3rd_of_Night),

          // ignore: prefer_const_constructors
          _SlivSunRings(),

          /// Use to make scrolling of active salah always pin when scrolling up.
          const SliverFillRemaining(), // Sun can scroll up and compress times
        ],
      );
    });
  }
}

class _SlidingAppBar extends StatelessWidget {
  const _SlidingAppBar(this.aqC);
  final ActiveQuestsController aqC;

  @override
  Widget build(BuildContext context) {
    final Color countdownBackgroundColor = cs(context);

    final TextStyle ts1 = TextStyle(
      fontSize: 22,
      letterSpacing: 3,
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = Colors.black,
    );
    const TextStyle ts2 = TextStyle(
      fontSize: 22,
      letterSpacing: 3,
      fontWeight: FontWeight.bold,
      color: Colors.white70,
    );

    return SliverAppBar(
      backgroundColor: countdownBackgroundColor,
      expandedHeight: 175.0,
      collapsedHeight: 56.0, // any smaller is exception
      snap: true,
      floating: true, // allows picture to dragged out after fully compact
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.all(12.0),
        title: Tooltip(
          // This is handled in ZamanController, but when a quest is updated, it
          // triggers ActiveQuestsController.update() so this is safe and better
          // to keep here (ZamanController refreshes every second so don't do
          // extra work if we don't have to:
          message: ZamanController.to.trValTimeToNextZamanTooltip,
          // Here is the ActiveQuest countdown timer
          child: GetBuilder<ZamanController>(builder: (zc) {
            String trValTime = zc.trValTimeToNextZaman;
            return Stack(
              children: [
                Text(trValTime, style: ts1), // text border
                Text(trValTime, style: ts2), // text inside
              ],
            );
          }),
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
                if (index == aqC.swiperImageIdx) // if pinned show icon
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
              aqC.swiperImageIdx != -1 ? aqC.swiperImageIdx : aqC.swiperLastIdx,
          autoplay: aqC.swiperAutoPlayEnabled,
          onTap: (swipePicIdx) => aqC.toggleSwiperAutoPlayEnabled(swipePicIdx),
          autoplayDelay: 10000, // ms to show picture
          duration: 1250, // ms to transition/animate to new picture
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
  const SalahRow(this.aqC, this.z);
  final ActiveQuestsController aqC;
  final Z z;

  static const TS tsFard = TS(AppThemes.ajr2Uncommon);
  static const TS tsMuak = TS(AppThemes.ajr4Epic);
  static const TS tsNafl = TS(AppThemes.ajr5Legendary);

  @override
  Widget build(BuildContext context) {
    final double w1 = w(context) / 6;
    final Color bg = cb(context);
    final TextStyle textStyle = Theme.of(context).textTheme.headline6!;

    return ZamanController.to.isSalahRowPinned(z) && aqC.showSalahActions
        ? MultiSliver(
            // salah row is pinned under headers
            children: [
              _Sliv(_getSalahRowHeaders(aqC, textStyle, w1, bg)),
              _Sliv(_getSalahRowActions(aqC, w1, bg)),
              _Sliv(_getSalahRowResults(), minHeight: 2, maxHeight: 2),
            ],
          )
        : SliverStack(
            // salah row not pinned, shrink it into the salah header
            children: [
              // add separator/quest completion indicator on bottom, folds 1st
              _Sliv(
                // Start salah separator at end to give overlap effect
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _getSalahRowResults(),
                ),
                minHeight: aqC.showSalahResults ? (_Sliv.slivH) + 2 : 2,
                maxHeight: (_Sliv.slivH * 2) + 2, // so UI gets overlap effect
              ),
              // salah actions folds second
              _Sliv(
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _getSalahRowActions(aqC, w1, bg),
                ),
                maxHeight: _Sliv.slivH * 2, // so UI gets overlap effect
              ),
              // top of stack, header hides all but sun on edges, is static
              _Sliv(_getSalahRowHeaders(aqC, textStyle, w1, bg)),
            ],
          );
  }

  Widget _getSalahRowHeaders(
    ActiveQuestsController aqC,
    TextStyle textStyle,
    double w1,
    Color bg,
  ) {
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
              label: // rare "a." does an "at" translation TODO
                  at('a.{0} Isharet', [z == Z.Duha ? Z.Ishraq.trKey : z.trKey]),
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.togglePlayAthan(z),
              backgroundColor: c.playAthan(z) ? cSound : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: Icons.cell_tower_outlined,
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.togglePlayBeep(z),
              backgroundColor: c.playBeep(z) ? cSound : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: c.playBeep(z)
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_none_outlined,
              autoClose: false,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => c.toggleVibrate(z),
              backgroundColor: c.vibrate(z) ? cVibrate : bg,
              foregroundColor: AppThemes.ldTextColor,
              icon: c.vibrate(z)
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
        child: _getSalahRowHeader(aqC, textStyle, w1, bg),
      );
    });
  }

  void handlePinnedHeaderTapped() {
    // cycles through Show pinned actions -> hide both -> show results
    if (aqC.showSalahActions) {
      // if actions showing, hide both
      aqC.showSalahActions = false;
      aqC.showSalahResults = false;
    } else if (!aqC.showSalahActions && !aqC.showSalahResults) {
      // if both hidden, show results
      aqC.showSalahResults = true;
    } else if (aqC.showSalahResults) {
      // if results showing, hide and show actions again
      aqC.showSalahResults = false;
      aqC.showSalahActions = true;
    }
  }

  Widget _getSalahRowHeader(
    ActiveQuestsController aqC,
    TextStyle textStyle,
    double w1,
    Color bg,
  ) {
    // highlight if row is pinned (all actions in row are within same time).
    bool isBold = ZamanController.to.isSalahRowPinned(z);

    // But if Duha and Maghrib, their times are split over multiple rows:
    if (isBold) {
      if (z == Z.Duha && ZamanController.to.currZ == Z.Duha) {
        isBold = true;
      } else if (z == Z.Maghrib && ZamanController.to.currZ == Z.Maghrib) {
        isBold = true;
      }
    }

    // Used to shift header center text to the left a little
    const double headerShiftLeftPad = 8;

    // used to give Middle/Last 3rd of night more space.
    double extraHeaderPad = 0; //barely hides "3" of maghrib fard
    if (z == Z.Middle_of_Night || z == Z.Last_3rd_of_Night) extraHeaderPad = w1;

    return InkWell(
      onTap: isBold
          ? () => handlePinnedHeaderTapped()
          : null, // reserved, we can do something when non active rows tapped
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // left side of duha and maghrib header transparent for slide up
              color: z == Z.Duha || z == Z.Maghrib ? Colors.transparent : bg,
              width: (w1 * 1.5) - extraHeaderPad - headerShiftLeftPad,
              height: _Sliv.slivH, // fills gaps
            ),
            Container(
              height: _Sliv.slivH, // needed
              color: bg, // middle Zaman name always colored
              child: Center(
                // Center needed to make fit height work
                child: T(
                  z.trKey,
                  textStyle.copyWith(
                    color: isBold ? textStyle.color : AppThemes.ldTextColor,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                  alignment: LanguageController.to.centerRight,
                  w: (w1 * 1.5) - 2 + extraHeaderPad, // - 2 for center divider
                  h: 23, // tuned to find best value in all cases
                ),
              ),
            ),
            Container(color: bg, width: 4), // middle spacer always colored
            Container(
              height: _Sliv.slivH, // needed
              color: bg, // middle athan time always colored
              child: Center(
                // Center needed to make fit height work
                child: T(
                  TimeController.trValTime(
                    ZamanController.to.athan!.getZamanRowTime(z),
                    ActiveQuestsController.to.show12HourClock,
                    ActiveQuestsController.to.showSecPrecision,
                  ),
                  textStyle.copyWith(
                    color: isBold ? textStyle.color : AppThemes.ldTextColor,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                  alignment: LanguageController.to.centerLeft,
                  w: (w1 * 1.5) - 2, // - 2 for center divider
                  h: 23, // tuned to find best value in all cases
                  trVal: true,
                ),
              ),
            ),
            Container(
              // make right side of duha transparent for action slide up
              color: z == Z.Duha || z == Z.Last_3rd_of_Night
                  ? Colors.transparent
                  : bg,
              width: (w1 * 1.5) + headerShiftLeftPad,
              height: _Sliv.slivH, // fills gaps
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSalahRowActions(ActiveQuestsController aqC, double w1, Color bg) {
    switch (z) {
      case (Z.Fajr):
        return _actionsFajr(w1);
      case (Z.Duha):
        return _actionsDuha(w1);
      case (Z.Dhuhr):
        return _actionsDhuhr(aqC.showJummahOnFriday);
      case (Z.Asr):
        return _actionsAsr();
      case (Z.Maghrib):
        return _actionsMaghrib();
      case (Z.Isha):
        return _actionsIsha();
      case (Z.Middle_of_Night):
        return _actionsMiddleOfNight(w1);
      case (Z.Last_3rd_of_Night):
        return _actionsLastThirdOfNight(w1, bg);
      default:
        return l.e('_getSalahRowActions: unexpected Z given: $z');
    }
  }

  Widget _actionsFajr(double w1) {
    double w2 = w1 * 2;
    return Row(
      children: [
        _Cell(T(cni(2), tsMuak, trVal: true), z, QUEST.FAJR_MUAKB),
        _Cell(T(cni(2), tsFard, trVal: true), z, QUEST.FAJR_FARD),
        _Cell(T('a.Adhkar As-Sabah', tsN, w: w2), z, QUEST.MORNING_ADHKAR,
            flex: 2),
        _Cell(const _IconThikr(), z, QUEST.FAJR_THIKR),
        _Cell(const _IconDua(), z, QUEST.FAJR_DUA),
      ],
    );
  }

  Widget _actionsDuha(double w1) {
    double w_4 = (w1 * 6) / 4;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cell(
          _KarahatSunCell(
            _IconSunUpDn(
              ZamanController.to.isCurrQuest(z, QUEST.KARAHAT_SUNRISE),
              true,
            ),
            QUEST.KARAHAT_SUNRISE,
            Z.Shuruq, // Sunrise
            ZamanController.to.athan!.sunrise,
            true, // align left
          ),
          z,
          QUEST.KARAHAT_SUNRISE,
        ),
        _Cell(T('a.Ishraq', tsN, w: w_4), z, QUEST.DUHA_ISHRAQ),
        _Cell(T(Z.Duha.trKey, tsN, w: w_4), z, QUEST.DUHA_DUHA),
        _Cell(
          _KarahatSunCell(
            const Icon(
              Icons.brightness_7_outlined,
              color: Colors.yellowAccent,
              size: 30,
            ),
            QUEST.KARAHAT_ISTIWA,
            Z.Istiwa, // Zawal/Zenith
            ZamanController.to.athan!.istiwa,
            false, // align right
          ),
          z,
          QUEST.KARAHAT_ISTIWA,
        ),
      ],
    );
  }

  Widget _actionsDhuhr(bool showJummahOnFriday) {
    String fardRk = cni(4); // fard rakat
    String muakAf = cni(2); // muakaddah after
    if (TimeController.to.isFriday() && showJummahOnFriday) {
      fardRk = cni(2);
      muakAf = cni(6);
    }

    return Row(
      children: [
        _Cell(T(cni(4), tsMuak, trVal: true), z, QUEST.DHUHR_MUAKB),
        _Cell(T(fardRk, tsFard, trVal: true), z, QUEST.DHUHR_FARD),
        _Cell(T(muakAf, tsMuak, trVal: true), z, QUEST.DHUHR_MUAKA),
        _Cell(T(cni(2), tsNafl, trVal: true), z, QUEST.DHUHR_NAFLA),
        _Cell(const _IconThikr(), z, QUEST.DHUHR_THIKR),
        _Cell(const _IconDua(), z, QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget _actionsAsr() {
    return Row(
      children: [
        _Cell(T(cni(4), tsNafl, trVal: true), z, QUEST.ASR_NAFLB),
        _Cell(T(cni(4), tsFard, trVal: true), z, QUEST.ASR_FARD),
        _Cell(T('a.Adhkar Al-Masaa', tsN), z, QUEST.EVENING_ADHKAR, flex: 2),
        _Cell(const _IconThikr(), z, QUEST.ASR_THIKR),
        _Cell(const _IconDua(), z, QUEST.ASR_DUA),
      ],
    );
  }

  Widget _actionsMaghrib() {
    return Row(
      children: [
        _Cell(
          _KarahatSunCell(
            _IconSunUpDn(
              ZamanController.to.isCurrQuest(z, QUEST.KARAHAT_SUNSET),
              false,
            ),
            QUEST.KARAHAT_SUNSET,
            Z.Ghurub, // sunset
            ZamanController.to.athan!.sunSetting,
            true, // align left
          ),
          z,
          QUEST.KARAHAT_SUNSET,
          flex: 57, // we need to tune this, so using bigger flex #'s
        ),
        _Cell(
          T(
            cni(3),
            tsFard,
            alignment: LanguageController.to.centerLeft,
            trVal: true,
          ),
          z,
          QUEST.MAGHRIB_FARD,
          flex: 23, // we need to tune this, so using bigger flex #'s
        ),
        _Cell(T(cni(2), tsMuak, trVal: true), z, QUEST.MAGHRIB_MUAKA, flex: 40),
        _Cell(T(cni(2), tsNafl, trVal: true), z, QUEST.MAGHRIB_NAFLA, flex: 40),
        _Cell(const _IconThikr(), z, QUEST.MAGHRIB_THIKR, flex: 40),
        _Cell(const _IconDua(), z, QUEST.MAGHRIB_DUA, flex: 40),
      ],
    );
  }

  Widget _actionsIsha() {
    return Row(
      children: [
        _Cell(T(cni(4), tsNafl, trVal: true), z, QUEST.ISHA_NAFLB),
        _Cell(T(cni(4), tsFard, trVal: true), z, QUEST.ISHA_FARD),
        _Cell(T(cni(2), tsMuak, trVal: true), z, QUEST.ISHA_MUAKA),
        _Cell(T(cni(2), tsNafl, trVal: true), z, QUEST.ISHA_NAFLA),
        _Cell(const _IconThikr(), z, QUEST.ISHA_THIKR),
        _Cell(const _IconDua(), z, QUEST.ISHA_DUA),
      ],
    );
  }

  Widget _actionsMiddleOfNight(double w1) {
    double w4 = w1 * 4;

    String trKeyQiyam =
        TimeController.to.isMonthRamadan ? 'a.Taraweeh' : 'a.Qiyam';

    return Row(
      children: [
        _Cell(T(trKeyQiyam, tsN, w: w4), z, QUEST.LAYL_QIYAM, flex: 4),
        _Cell(const _IconThikr(), z, QUEST.LAYL_THIKR),
        _Cell(const _IconDua(), z, QUEST.LAYL_DUA),
      ],
    );
  }

  Widget _actionsLastThirdOfNight(double w1, Color bg) {
    double w_4 = (w1 * 6) / 4;
    double h_2 = _Sliv.slivH / 2;

    return Row(
      children: [
        _Cell(T('a.Nayam', tsN, w: w_4), z, QUEST.LAYL_SLEEP), // sleep
        _Cell(T('a.Tahajjud', tsN, w: w_4), z, QUEST.LAYL_TAHAJJUD),
        _Cell(T('a.Witr', tsN, w: w_4), z, QUEST.LAYL_WITR),
        Expanded(
          child: Container(
            color: bg, // hides bottom results bar as scrolls up
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                T(
                  at(Z.Fajr_Tomorrow.trKey, [Z.Fajr.trKey]),
                  tsN,
                  w: w_4,
                  h: h_2,
                  trVal: true,
                ),
                T(
                  TimeController.trValTime(
                    ZamanController.to.athan!.fajrTomorrow,
                    ActiveQuestsController.to.show12HourClock,
                    ActiveQuestsController.to.showSecPrecision,
                  ),
                  tsN,
                  w: w_4,
                  h: h_2,
                  trVal: true,
                ),
              ],
            ),
          ),
          flex: 1,
        ),
      ],
    );
  }

  Widget _getSalahRowResults() {
    switch (z) {
      case (Z.Fajr):
        return _resultsFajr();
      case (Z.Duha):
        return _resultsDuha();
      case (Z.Dhuhr):
        return _resultsDhuhr();
      case (Z.Asr):
        return _resultsAsr();
      case (Z.Maghrib):
        return _resultsMaghrib();
      case (Z.Isha):
        return _resultsIsha();
      case (Z.Middle_of_Night):
        return _resultsMiddleOfNight();
      case (Z.Last_3rd_of_Night):
        return _resultsLastThirdOfNight();
      default:
        return l.E('_getSalahRowResults: unexpected Z given: $z');
    }
  }

  Widget _resultsFajr() {
    return Row(
      children: [
        _getResult(QUEST.FAJR_MUAKB),
        _getResult(QUEST.FAJR_FARD),
        _getResult(QUEST.MORNING_ADHKAR, flex: 2),
        _getResult(QUEST.FAJR_THIKR),
        _getResult(QUEST.FAJR_DUA),
      ],
    );
  }

  Widget _resultsDuha() {
    return Row(
      children: [
        _getResult(QUEST.KARAHAT_SUNRISE),
        _getResult(QUEST.DUHA_ISHRAQ),
        _getResult(QUEST.DUHA_DUHA),
        _getResult(QUEST.KARAHAT_ISTIWA),
      ],
    );
  }

  Widget _resultsDhuhr() {
    return Row(
      children: [
        _getResult(QUEST.DHUHR_MUAKB),
        _getResult(QUEST.DHUHR_FARD),
        _getResult(QUEST.DHUHR_MUAKA),
        _getResult(QUEST.DHUHR_NAFLA),
        _getResult(QUEST.DHUHR_THIKR),
        _getResult(QUEST.DHUHR_DUA),
      ],
    );
  }

  Widget _resultsAsr() {
    return Row(
      children: [
        _getResult(QUEST.ASR_NAFLB),
        _getResult(QUEST.ASR_FARD),
        _getResult(QUEST.EVENING_ADHKAR, flex: 2),
        _getResult(QUEST.ASR_THIKR),
        _getResult(QUEST.ASR_DUA),
      ],
    );
  }

  Widget _resultsMaghrib() {
    return Row(
      children: [
        _getResult(QUEST.KARAHAT_SUNSET, flex: 57),
        _getResult(QUEST.MAGHRIB_FARD, flex: 23),
        _getResult(QUEST.MAGHRIB_MUAKA, flex: 40),
        _getResult(QUEST.MAGHRIB_NAFLA, flex: 40),
        _getResult(QUEST.MAGHRIB_THIKR, flex: 40),
        _getResult(QUEST.MAGHRIB_DUA, flex: 40),
      ],
    );
  }

  Widget _resultsIsha() {
    return Row(
      children: [
        _getResult(QUEST.ISHA_NAFLB),
        _getResult(QUEST.ISHA_FARD),
        _getResult(QUEST.ISHA_MUAKA),
        _getResult(QUEST.ISHA_NAFLA),
        _getResult(QUEST.ISHA_THIKR),
        _getResult(QUEST.ISHA_DUA),
      ],
    );
  }

  Widget _resultsMiddleOfNight() {
    return Row(
      children: [
        _getResult(QUEST.LAYL_QIYAM, flex: 4),
        _getResult(QUEST.LAYL_THIKR),
        _getResult(QUEST.LAYL_DUA),
      ],
    );
  }

  Widget _resultsLastThirdOfNight() {
    return Row(
      children: [
        _getResult(QUEST.LAYL_SLEEP),
        _getResult(QUEST.LAYL_TAHAJJUD),
        _getResult(QUEST.LAYL_WITR),
        _getResult(QUEST.LAYL_WITR), // Fajr Tomorrow here, just show Witr twice
      ],
    );
  }

  Widget _getResult(QUEST quest, {int flex = 1}) {
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
class _SlivSunRings extends StatelessWidget {
  const _SlivSunRings();

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
            SunRing(baseDiameter + 4, strokeWidth, colorSlice),
            QuestRing(baseDiameter, strokeWidth / 6, colorSlice),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.widget, this.z, this.quest, {this.flex = 1});
  final Widget widget;
  final Z z;
  final QUEST quest;
  final int flex;

  @override
  Widget build(BuildContext context) {
    bool isCurrQuest = ZamanController.to.isCurrQuest(z, quest);

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
          height: _Sliv.slivH, // for duha/asr sun slide up sticky sliver effect
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
                  : Hero(tag: quest, child: widget),
            ),
          ),
        ),
      ),
    );
  }
}

class _KarahatSunCell extends StatelessWidget {
  const _KarahatSunCell(
    this.sunIcon,
    this.quest,
    this.z,
    this.time,
    this.alignLeft,
  );
  final Widget sunIcon;
  final QUEST quest;
  final Z z;
  final DateTime time;
  final bool alignLeft; // Align sun icon and text left (true) or right (false)

  @override
  Widget build(BuildContext context) {
    double w1p5 = // 1 point 5 -> 1.5x
        ((MediaQuery.of(context).size.width / 6) * 1.5) - _Sliv.slivH - 10;
    double h = 23;
    if (quest == QUEST.KARAHAT_SUNSET) {
      w1p5 -= 5; // give little more gap for "3" of maghrib fard
      h -= 1;
    }

    // highlight Karahat cells when their times are in (header loses highlight)
    bool boldText = ZamanController.to.currZ == z;

    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.end;
    if (alignLeft) mainAxisAlignment = MainAxisAlignment.start;

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (alignLeft) const SizedBox(width: 2), // pad left, very little room
        sunIcon,
        T(
          TimeController.trValTime(
            time,
            ActiveQuestsController.to.show12HourClock,
            ActiveQuestsController.to.showSecPrecision,
          ),
          boldText ? tsB : tsN,
          w: w1p5,
          h: h,
          trVal: true,
          alignment: LanguageController.to.centerLeft, // text sticks to icon
        ),
        if (!alignLeft) const SizedBox(width: 2), // pad right (matches left)
      ],
    );
  }
}

// TODO better icon for sunsetting
class _IconSunUpDn extends StatelessWidget {
  const _IconSunUpDn(this.isCurrQuest, this.isSunrise);
  final bool isCurrQuest;
  final bool isSunrise;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TwoColoredIcon(
          Icons.circle,
          _Sliv.slivH - 5,
          const [Colors.orangeAccent, Colors.red, Colors.transparent],
          isCurrQuest ? cs(context) : cb(context),
          fillPercent: .60,
        ),
        Positioned(
          left: -1.5,
          top: ((_Sliv.slivH - 5) / 4) + .5, // 25% down from center
          child: Icon(
            isSunrise
                ? Icons.arrow_drop_up_outlined // sunrise
                : Icons.arrow_drop_down_outlined, // sunset
            color: AppThemes.ldTextColor,
            size: _Sliv.slivH - 2, // need all space we can get for maghrib fard
          ),
        ),
      ],
    );
  }
}

class _IconThikr extends StatelessWidget {
  const _IconThikr();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _Sliv.slivH,
      height: _Sliv.slivH,
      child: Stack(
        children: const [
          Center(
            child: Icon(
              Icons.favorite_outlined,
              color: Colors.pinkAccent,
              size: 33,
            ),
          ),
          Center(
            child: Icon(
              Icons.psychology_outlined,
              color: Colors.white70,
              size: 21,
            ),
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
    return const TwoColoredIcon(
      Icons.volunteer_activism,
      25,
      [Colors.pinkAccent, Colors.blueAccent, Colors.blueAccent],
      Colors.blueAccent,
      fillPercent: .75,
    );
  }
}
