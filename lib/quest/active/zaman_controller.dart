import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/controllers/location_controller.dart';
import 'package:hapi/controllers/notification_controller.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/calculation_params.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/sun_ring.dart';
import 'package:timezone/timezone.dart' show TZDateTime;

/// Controls Islamic Times Of Day, e.g. Fajr, Duha, Sunset/Maghrib, etc. that
/// many pages rely on for the current time.
class ZamanController extends GetxHapi {
  static ZamanController get to => Get.find();

  Z _currZ = Z.Dhuhr;
  Z _nextZ = Z.Asr;
  Z get currZ => _currZ;
  Z get nextZ => _nextZ;

  /// nextZ or nextZTooltip Timestamp used to calculate countdown timer on UI.
  DateTime _nextZTime = DUMMY_TIME1;
  String trValTimeToNextZaman = '-';
  String trValTimeToNextZamanTooltip = '-';
  Z? currZTooltip = Z.Dhuhr; // may be null if in edge case
  Z nextZTooltip = Z.Asr;
  DateTime nextZTooltipTime = DUMMY_TIME1;

  int _secsSinceFajr = 0;
  int get secsSinceFajr => _secsSinceFajr;

  bool _forceSalahRecalculation = false;

  /// Allows athan recalculation, plus active quests and other UI updates.
  void forceSalahRecalculation() => _forceSalahRecalculation = true;

  Athan? _athan;
  Athan? get athan => _athan;

  bool get isInitialized => _athan != null;

  /// used to detect hijri day changes at maghrib time
  int _curDayOfWeek = -1;

  CalculationParams _getCalculationParams() {
    var calcMethod =
        CalcMethod.values[ActiveQuestsController.to.salahCalcMethod];

    // TODO give user way to change HighLatitudeRule, SalahAdjust, karahat times, etc.
    int karahatSunRisingSecs = 20 * 60;
    int karahatSunIstiwaSecs = 10 * 60;
    int karahatSunSettingSecs = 20 * 60;
    return CalculationParams(
      calcMethod.params,
      karahatSunRisingSecs,
      karahatSunIstiwaSecs,
      karahatSunSettingSecs,
      HighLatitudeRule.MiddleOfTheNight,
    );
  }

  Athan generateNewAthan(DateTime day) {
    return Athan(
      _getCalculationParams(),
      day,
      LocationController.to.lastKnownCord,
      TimeController.to.tzLoc,
      ActiveQuestsController.to.showSecPrecision,
    );
  }

  /// Does init for app items then calls itself again on more init needed or
  /// _zamanCountdownTimer() to start next countdown timer.
  updateZaman() async {
    Athan athan;

    if (_forceSalahRecalculation) {
      l.d('ZamanController:updateZaman: forceSalahRecalculation was called.');
      athan = generateNewAthan(TimeController.to.currDayDate);
      SunRing.colorSliceInitialized = false; // force sun ring to redraw
    } else {
      if (isInitialized) {
        athan = _athan!; // don't calculate athan each time
      } else {
        athan = generateNewAthan(TimeController.to.currDayDate); // first init
      }
    }

    DateTime now = await TimeController.to.now();
    Z currZ = athan.getCurrZaman(now);
    l.d('ZamanController:updateZaman: starting - currZ=$currZ, now=$now');

    // check if we are still on the same day
    if (currZ == Z.Fajr_Tomorrow) {
      await _handleNewDaySetup();
      return;
    }

    // Safe to now set/flush missed quests and do other quest setup:
    await ActiveQuestsAjrController.to.initCurrQuest(currZ, !isInitialized);

    _currZ = currZ; // now safe as currZ can't be Z.Fajr_Tomorrow.
    _nextZ = Z.values[currZ.index + 1];
    _nextZTime = athan.getZamanTime(_nextZ)[0] as DateTime;
    l.d('ZamanController:updateZaman: _nextZ=$_nextZ, _nextZTime=$_nextZTime');

    // Now all init is done, set athan value (needed for init to prevent NPE)
    _athan = athan;
    _curDayOfWeek = now.day;

    if (_currZ == Z.Maghrib || _forceSalahRecalculation || !isInitialized) {
      await TimeController.to.updateDaysOfWeek(); // sunset = new hijri day
    }

    if (_forceSalahRecalculation) {
      _forceSalahRecalculation = false; // here finally clear this flag
      NotificationController.to.resetNotifications(); // _athan updated so reset
    }

    // Needed first when isha quests done but middle of night not begun yet
    if (_currZ.index < Z.Isha.index) {
      _updateTooltip(_currZ, _nextZ);
    } else {
      handleTooltipUpdate(now);
    }

    // Always refresh ActiveQuestsController as _currZ is updated and multiple
    // UI's watch for this (e.g. ActiveQuestsUI and ActiveQuestActionsUI.
    // Must update the ActiveQuestsController here after athan is updated.
    // Fixes bug where forceSalahRecalculation = true set in
    // ActiveQuestsController, it's update() was called before athan updated.
    ActiveQuestsController.to.update(); // even needed at app init to show UI

    _zamanCountdownTimer();
  }

  /// Loop counts down until zaman is over or forceSalahRecalculation called
  _zamanCountdownTimer() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      DateTime now = await TimeController.to.now();
      Duration timeToNextZaman = _nextZTime.difference(
        TZDateTime.from(now, TimeController.to.tzLoc),
      );

      _secsSinceFajr = now
          .difference(TZDateTime.from(_athan!.fajr, TimeController.to.tzLoc))
          .inSeconds;

      // we must track gregorian day switches to update DAY_OF_WEEK values
      if (_curDayOfWeek != now.day) {
        l.d('ZamanController:_zamanCountdownTimer: _curDayOfWeek($_curDayOfWeek) != now.day($now.day)');
        _curDayOfWeek = now.day;
        TimeController.to.update();
      }

      if (_forceSalahRecalculation) {
        l.d('ZamanController:_zamanCountdownTimer: forceSalahRecalculation was called.');
        updateZaman();
        return; // quits while loop, starts again in updateZaman()
      } else if (timeToNextZaman.inSeconds <= 0) {
        l.d('ZamanController:_zamanCountdownTimer: This zaman $currZ is over, going to next zaman $nextZ.');
        // just in case, give a little time for nextZ to come in.
        await Future.delayed(const Duration(milliseconds: 16));
        updateZaman();
        return; // quits while loop, starts again in updateZaman()
      } else {
        if (timeToNextZaman.inSeconds % 60 == 0) {
          // heartbeat prints once a minute to show thread is alive
          l.i('ZamanController:_zamanCountdownTimer: Next Zaman Timer Minute Tick: ${timeToNextZaman.inSeconds} '
              'secs left (${timeToNextZaman.inSeconds / 60} minutes)');
        }

        if (nextZ != nextZTooltip) {
          timeToNextZaman = nextZTooltipTime.difference(
            TZDateTime.from(now, TimeController.to.tzLoc),
          );
        }

        // Displayed in Active Quest UI within ZamanController builder:
        trValTimeToNextZaman =
            TimeController.trValDurationToTime(timeToNextZaman);

        update(); // only time ZamanController is updated
      }
    }
  }

  _handleNewDaySetup() async {
    l.d('ZamanController:_handleNewDaySetup: New day is being setup.');
    if (isInitialized) {
      // flush any missed quests
      await ActiveQuestsAjrController.to.initCurrQuest(Z.Fajr_Tomorrow, true);
      await TimeController.to.updateTime(); // otherwise we just did it at init
    }

    await TimeController.to.updateCurrDay();

    // Load or init this next day quests, Z.Fajr so just reads from DB since
    // we don't know real Z time yet.
    await ActiveQuestsAjrController.to.initCurrQuest(Z.Fajr, true);

    forceSalahRecalculation(); // time to update _athan

    // now, currZ won't equal Z.Fajr_Tomorrow as currDay updated
    updateZaman();
  }

  _updateTooltip(Z? cTooltip, Z nTooltip) {
    currZTooltip = cTooltip;
    nextZTooltip = nTooltip;
    nextZTooltipTime = _athan!.getZamanTime(nextZTooltip)[0] as DateTime;
    l.d('ZamanController:_updateTooltip: updating to currZT=$currZTooltip, nextZT=$nextZTooltip, nextZTTime=$nextZTooltipTime');

    if (cTooltip != null) {
      if (nextZ.index != currZ.index + 1) {
        l.w('ZamanController:_updateTooltip: potential logic issue: (nextZ($nextZ)!=currZ($currZ)+1 when updating tooltip - currZTooltip=$currZTooltip, nextZTooltip=$nextZTooltip, nextZTooltipTime=$nextZTooltipTime');
      }
      trValTimeToNextZamanTooltip = at(
        // {0}:{1}:{2} until "{3}" ends and "{4}" begins
        'at.aqCountdownTimer',
        ['a.Saat', 'a.Daqayiq', 'a.Thawani', cTooltip.trKey, nTooltip.trKey],
      );
    } else {
      if (nextZ.index == currZ.index + 1) {
        l.w('ZamanController:_updateTooltip: potential logic issue: (nextZ($nextZ)==currZ($currZ)+1 when updating tooltip - currZTooltip=$currZTooltip, nextZTooltip=$nextZTooltip, nextZTooltipTime=$nextZTooltipTime');
      }
      trValTimeToNextZamanTooltip = at(
        // {0}:{1}:{2} until "{3}" begins
        'at.aqCountdownTimerLayl',
        ['a.Saat', 'a.Daqayiq', 'a.Thawani', nTooltip.trKey],
      );
    }
  }

  /// Isha, Middle of Night and Last 3rd of night can all share the same time
  /// period span, so we need special logic to allow this. With this, the UI
  /// maintains the proper and relevant information on the
  /// _zamanCountdownTimer(). It does this because the user is going through
  /// the quests.
  handleTooltipUpdate(DateTime? now) {
    Z? cTooltip = currZTooltip; // c = current
    Z nTooltip = nextZTooltip; // n = next
    if (isLaylSalahRowPinned(Z.Middle_of_Night)) {
      now ??= TimeController.to.now2();
      if (now.isBefore(_athan!.middleOfNight)) {
        // still isha time, so count down to Last_3rd_of_Night
        cTooltip = null;
        nTooltip = Z.Last_3rd_of_Night;
      } else if (now.isBefore(_athan!.last3rdOfNight)) {
        // still middle of night, so count down to Last_3rd_of_Night
        cTooltip = Z.Middle_of_Night; // we can show MON!
        nTooltip = Z.Last_3rd_of_Night;
      } else if (now.isAfter(_athan!.last3rdOfNight)) {
        // last 3rd of night time, so count down to Fajr_Tomorrow
        cTooltip = null;
        nTooltip = Z.Fajr_Tomorrow;
      }
    } else if (isLaylSalahRowPinned(Z.Last_3rd_of_Night)) {
      now ??= TimeController.to.now2();
      nTooltip = Z.Fajr_Tomorrow;
      if (now.isBefore(_athan!.last3rdOfNight)) {
        // still isha or middle of night, so count down to Fajr_Tomorrow
        cTooltip = null;
      } else {
        // last 3rd of night time, so count down to Fajr_Tomorrow
        cTooltip = Z.Last_3rd_of_Night;
      }
    }

    // nothing to do
    if (cTooltip == currZTooltip && nTooltip == nextZTooltip) return;

    _updateTooltip(cTooltip, nTooltip);
  }

  bool isCurrQuest(Z z, QUEST quest) =>
      isSalahRowPinned(z) && ActiveQuestsAjrController.to.isQuestActive(quest);

  /// Check if given Z is currently pinned to UI. Pinned does not mean all
  /// quests for that row are active. It also does not meant that it should be
  /// highlighted on UI as there are special cases on Duha and Maghrib to
  /// bold/highlight karahat cells instead of the header.
  bool isSalahRowPinned(Z z) {
    List<Z> zs = [z];

    switch (z) {
      case Z.Fajr:
        break;
      case Z.Duha:
        zs = [Z.Shuruq, Z.Ishraq, Z.Duha, Z.Istiwa];
        break;
      case Z.Dhuhr:
        break;
      case Z.Asr:
        // if asr ibadah not done, asr active- we have until sunset to complete
        if (!ActiveQuestsAjrController.to.isAsrComplete) zs.add(Z.Ghurub);
        break;
      case Z.Maghrib:
        // if asr ibadah done, pin maghrib row which has Karahat time there
        if (ActiveQuestsAjrController.to.isAsrComplete) zs.add(Z.Ghurub);
        break;
      case Z.Isha:
        // if isha ibadah done, then we move to Layl times right away, we don't
        // wait for currZ to equal Z.Middle/Last 3rd of Night.
        if (ActiveQuestsAjrController.to.isIshaComplete) zs.clear();
        break;
      case Z.Middle_of_Night:
      case Z.Last_3rd_of_Night:
        return isLaylSalahRowPinned(z);
      default:
        l.E('Invalid Zaman "$z" given when in isSalahRowPinned()');
        return false;
    }

    for (Z z in zs) {
      if (z == _currZ) return true; // zaman is active
    }

    return false; // zaman inactive
  }

  /// Break this out from isSalahRowPinned() to optimize since called so much.
  bool isLaylSalahRowPinned(Z z) {
    if (!ActiveQuestsAjrController.to.isIshaComplete) return false;

    switch (z) {
      case Z.Middle_of_Night:
        if (ActiveQuestsAjrController.to.isMiddleOfNightComplete) return false;
        break;
      case Z.Last_3rd_of_Night:
        if (!ActiveQuestsAjrController.to.isMiddleOfNightComplete) return false;
        break;
      default:
        l.E('Invalid Zaman "$z" given when in isLaylSalahRowPinned()');
        return false;
    }

    // return true if currZ is Isha, Middle_of_Night or Last_3rd_of_Night
    return currZ == Z.Isha ||
        currZ == Z.Middle_of_Night ||
        currZ == Z.Last_3rd_of_Night;
  }
}
