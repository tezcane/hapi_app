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

  final Map<Z, bool> _playAthan = {};
  final Map<Z, bool> _playBeep = {};
  final Map<Z, bool> _vibrate = {};
  bool playAthan(Z z) => _playAthan[z]!;
  bool playBeep(Z z) => _playBeep[z]!;
  bool vibrate(Z z) => _vibrate[z]!;

  @override
  void onInit() {
    _initNotificationsLibrary();

    for (Z z in zRows) {
      bool defaultVal = true;
      if (z == Z.Duha || z == Z.Middle_of_Night || z == Z.Last_3rd_of_Night) {
        defaultVal = false;
      }
      _playAthan[z] = s.rd('playAthan${z.name}') ?? defaultVal;
      _playBeep[z] = s.rd('playBeep${z.name}') ?? defaultVal;
      _vibrate[z] = s.rd('vibrate${z.name}') ?? defaultVal;
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

    // TODO test, needed, works?
    /// When user clicks on a notification we want to start app (if not started)
    /// and navigate to where the notification originates from.
    notificationSubject.stream.listen((String? payload) async {
      try {
        Z z = zRows[int.parse(payload!) % zRows.length - 1];
        l.d('NotificationController:_initNotificationsLibrary: got Z=${z.name}');
      } catch (e) {
        l.e('NotificationController:_initNotificationsLibrary: got expected a ZRow index offset but got "$payload", error="$e"');
      }
    });
  }

  String get trValNotificationTitle => at('at.{0} Updated', ['a.Isharet']);

  togglePlayAthan(Z z) async {
    _playAthan[z] = !_playAthan[z]!;
    s.wr('playAthan${z.name}', _playAthan[z]);

    if (_playAthan[z]!) {
      showSnackBar(trValNotificationTitle, at('at.{0} on', ['a.Athan']));
      _playBeep[z] = false; // both can't be true
      s.wr('playBeep${z.name}', _playBeep[z]);
    } else {
      showSnackBar(trValNotificationTitle, at('at.{0} off', ['a.Athan']));
    }
    resetNotifications();
    updateOnThread1Ms();
  }

  togglePlayBeep(Z z) async {
    _playBeep[z] = !_playBeep[z]!;
    s.wr('playBeep${z.name}', _playBeep[z]);
    if (_playBeep[z]!) {
      showSnackBar(trValNotificationTitle, 'i.Default sound on');
      _playAthan[z] = false; // both can't be true
      s.wr('playAthan${z.name}', _playAthan[z]);
    } else {
      showSnackBar(trValNotificationTitle, 'i.Default sound off');
    }
    resetNotifications();
    updateOnThread1Ms();
  }

  toggleVibrate(Z z) async {
    _vibrate[z] = !_vibrate[z]!;
    s.wr('vibrate${z.name}', _vibrate[z]);
    if (_vibrate[z]!) {
      showSnackBar(trValNotificationTitle, 'i.Vibration on');
    } else {
      showSnackBar(trValNotificationTitle, 'i.Vibration off');
    }
    resetNotifications();
    updateOnThread1Ms();
  }

  /// Clears all previous notifications and sets next 3 days of notifications
  resetNotifications() async {
    await FlutterLocalNotificationsPlugin().cancelAll(); //cancel all

    Athan athan = ZamanController.to.athan!; // start from current athan
    Z currZ = ZamanController.to.currZ;

    for (int day = 0; day < 3; day++) {
      if (day > 0) {
        athan = ZamanController.to.generateNewAthan(
          TimeController.to.currDayDate.add(Duration(days: day)),
        );
      }

      int zRowIdx = 0;
      for (Z z in zRows) {
        int id = zRowIdx++ + (zRows.length * day); // zRowIdx++, so id=0 first

        await _scheduleSalahNotification(athan, z, id);

        /// stop exactly 3 days from now
        if (day == 2 && currZ == z) return;
      }
    }
  }

  _scheduleSalahNotification(Athan athan, Z z, int id) async {
    if (!_playAthan[z]! && !_playBeep[z]! && !_vibrate[z]!) {
      await FlutterLocalNotificationsPlugin().cancel(id);
      l.w('NotificationController:scheduleSalahNotification: z ${z.name} (id=$id) has no notifications');
      return;
    }

    DateTime salahTime = athan.getZamanRowTime(z);
    // TZDateTime scheduledTime = (await TimeController.to.now())
    //     .add(const Duration(seconds: 1)) as TZDateTime;
    TZDateTime scheduledTime =
        TZDateTime.from(salahTime, TimeController.to.tzLoc);

    String uniqueId =
        'id=$id, time=$salahTime, z=${z.name}, athan=${_playAthan[z]!}, beep=${_playBeep[z]!}, vibrate=${_vibrate[z]!}';
    if (salahTime.isBefore(await TimeController.to.now())) {
      l.w('NotificationController:scheduleSalahNotification: Time expired, skip: "$uniqueId"');
      return;
    }

    String body = 'Salah Time';

    var androidSpecifics = AndroidNotificationDetails(
      // ID must be unique for all combinations to work, thus t/f added below:
      uniqueId,
      '${z.name} Salah Notification', // notification channel
      channelDescription: 'hapi Salah Notification',
      priority: Priority.max,
      importance: Importance.high,
      styleInformation: BigTextStyleInformation(body),
      when: scheduledTime.millisecondsSinceEpoch,
      playSound: _playAthan[z]! || _playBeep[z]!,
      sound: _playAthan[z]!
          ? RawResourceAndroidNotificationSound(
              z == Z.Fajr ? 'athan_fajr' : 'athan')
          : null,
      enableVibration: _vibrate[z]!,
      enableLights: true,
      //color: // TODO
    );

    var iOSSpecifics = const IOSNotificationDetails(); // TODO

    var platformChannelSpecifics =
        NotificationDetails(android: androidSpecifics, iOS: iOSSpecifics);

    // This finally schedules the notification
    await FlutterLocalNotificationsPlugin().zonedSchedule(
      id, // int id
      z.name, // title
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      payload: z.index.toString(), // so we can get notification type back
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    l.d('NotificationController:scheduleSalahNotification: Scheduled: "$uniqueId"');
  }
}
