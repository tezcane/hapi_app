import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';
import 'package:rxdart/subjects.dart' as rxsub;
import 'package:timezone/timezone.dart'; //hide LocationDatabase; TODO use?

final rxsub.BehaviorSubject<NotificationClass>
    didReceiveLocalNotificationSubject =
    rxsub.BehaviorSubject<NotificationClass>();
final rxsub.BehaviorSubject<String?> notificationSubject =
    rxsub.BehaviorSubject<String?>();

class NotificationClass {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  NotificationClass(this.id, this.title, this.body, this.payload);
}

class NotificationController extends GetxHapi {
  static NotificationController get to => Get.find(); // A.K.A. cQstA

  final Map<ZR, bool> _playAthan = {};
  bool playAthan(ZR zR) => _playAthan[zR]!;
  bool playBeep(ZR zR) => _playBeep[zR]!;
  bool vibrate(ZR zR) => _vibrate[zR]!;
  final Map<ZR, bool> _playBeep = {};
  final Map<ZR, bool> _vibrate = {};

  @override
  void onInit() {
    _initNotificationsLibrary();

    for (ZR zR in ZR.values) {
      bool dVal = true; // default value
      if (zR == ZR.Duha || zR == ZR.Layl) dVal = false;
      _playAthan[zR] = s.rd('playAthan${zR.name}') ?? dVal;
      _playBeep[zR] = s.rd('playBeep${zR.name}') ?? !dVal;
      _vibrate[zR] = s.rd('vibrate${zR.name}') ?? true;
    }

    super.onInit();
  }

  _initNotificationsLibrary() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) async {
          didReceiveLocalNotificationSubject.add(
            NotificationClass(id, title, body, payload),
          );
        });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        l.d('notification payload: ' + payload);
        notificationSubject.add(payload);
      }
    });

    // TODO test
    notificationSubject.stream.listen((String? payload) async {
      ZR zR = ZR.values[int.parse(payload!)];
      l.d('initNotificationStreamReader: got zR=' + zR.name);
    });
  }

  togglePlayAthan(ZR zR) async {
    _playAthan[zR] = !_playAthan[zR]!;
    s.wr('playAthan${zR.name}', _playAthan[zR]);
    if (_playAthan[zR]!) {
      _playBeep[zR] = false; // both can't be true
      s.wr('playBeep${zR.name}', _playBeep[zR]);
    }
    resetNotifications();
    updateOnThread1Ms();
  }

  togglePlayBeep(ZR zR) async {
    _playBeep[zR] = !_playBeep[zR]!;
    s.wr('playBeep${zR.name}', _playBeep[zR]);
    if (_playBeep[zR]!) {
      _playAthan[zR] = false; // both can't be true
      s.wr('playAthan${zR.name}', _playAthan[zR]);
    }
    resetNotifications();
    updateOnThread1Ms();
  }

  toggleVibrate(ZR zR) async {
    _vibrate[zR] = !_vibrate[zR]!;
    s.wr('vibrate${zR.name}', _vibrate[zR]);
    resetNotifications();
    updateOnThread1Ms();
  }

  /// Clears all previous notifications and sets next 7 days of notifications
  resetNotifications() async {
    await FlutterLocalNotificationsPlugin().cancelAll(); //cancel all

    int zRLen = ZR.values.length;
    Athan athan = ZamanController.to.athan!; // start from current athan
    for (int day = 0; day < 7; day++) {
      for (ZR zR in ZR.values) {
        int id = zR.index + (zRLen * day);
        await _scheduleSalahNotification(athan, zR, id);
      }
      // generate next day athan values
      athan = ZamanController.to.generateNewAthan(
          TimeController.to.currDayDate.add(Duration(days: day + 1)));
    }
  }

  _scheduleSalahNotification(Athan athan, ZR zR, int id) async {
    if (!_playAthan[zR]! && !_playBeep[zR]! && !_vibrate[zR]!) {
      await FlutterLocalNotificationsPlugin().cancel(id);
      l.w('NotificationController:scheduleSalahNotification: zR ${zR.name} (id=$id) has no notifications');
      return;
    }

    DateTime salahTime = athan.getZamanRowTime(zR);
    // TZDateTime scheduledTime = (await TimeController.to.now())
    //     .add(const Duration(seconds: 1)) as TZDateTime;
    TZDateTime scheduledTime =
        TZDateTime.from(salahTime, TimeController.to.tzLoc);

    if (salahTime.isBefore(await TimeController.to.now())) {
      l.w('NotificationController:scheduleSalahNotification: zR ${zR.name} (id=$id) time ($salahTime) has expired, not setting notification');
      return;
    } else {
      l.d('NotificationController:scheduleSalahNotification: zR ${zR.name} (id=$id) time ($salahTime) being scheduled');
    }

    String body = 'Salah Time';

    var androidSpecifics = AndroidNotificationDetails(
      // ID must be unique for all combinations to work, thus t/f added below:
      '${zR.name} (id=$id) Athan=${_playAthan[zR]!}, Beep=${_playBeep[zR]!}, vibrate=${_vibrate[zR]!}', // Notification ID
      '${zR.name} Salah Notification', // notification channel
      channelDescription: 'hapi Salah Notification',
      priority: Priority.max,
      importance: Importance.high,
      styleInformation: BigTextStyleInformation(body),
      when: scheduledTime.millisecondsSinceEpoch,
      playSound: _playAthan[zR]! || _playBeep[zR]!,
      sound: _playAthan[zR]!
          ? RawResourceAndroidNotificationSound(
              zR == ZR.Fajr ? 'athan_fajr' : 'athan')
          : null,
      enableVibration: _vibrate[zR]!,
      enableLights: true,
      //color: // TODO
    );

    var iOSSpecifics = const IOSNotificationDetails(); // TODO

    var platformChannelSpecifics =
        NotificationDetails(android: androidSpecifics, iOS: iOSSpecifics);

    // This finally schedules the notification
    await FlutterLocalNotificationsPlugin().zonedSchedule(
      id, // int id
      zR.name, // title
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      payload: zR.index.toString(), // so we can get notification type back
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
