import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/onboard/auth/auth_c.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/daily/daily_quests_c.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';

/// Does database transactions.
class Db {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  // TODO bug here right after sign out sign in:
  // I/flutter (30513): H_INF: TimeC:updateCurrDay: New day set (2022-04-26), prev day was (2022-04-25)
  // E/flutter (30513): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Null check operator used on a null value
  // E/flutter (30513): #0      Db._uid (package:hapi/services/db.dart:12:66)
  // E/flutter (30513): #1      Db._uid (package:hapi/services/db.dart)
  // E/flutter (30513): #2      Db.getActiveQuest (package:hapi/services/db.dart:82:33)
  // E/flutter (30513): #3      ActiveQuestsAjrController.initCurrQuest (package:hapi/quest/active/active_quests_ajr_c.dart:227:38)
  // E/flutter (30513): #4      ZamanController._handleNewDaySetup (package:hapi/quest/active/zaman_c.dart:185:40)
  // E/flutter (30513): <asynchronous suspension>
  // E/flutter (30513): #5      ZamanController.updateZaman (package:hapi/quest/active/zaman_c.dart:102:7)
  // E/flutter (30513): <asynchronous suspension>
  static final String _uid = AuthC.to.firebaseUser.value!.uid;

  // Future<bool> createNewUser(UserModel user) async {
  //   try {
  //     await _firestore.collection('user').document(user.id).setData({
  //       "name': user.name,
  //       'email": user.email,
  //     });
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }
  //
  // Future<UserModel> getUser(String uid) async {
  //   try {
  //     DocumentSnapshot _doc =
  //         await _firestore.collection("user").document(uid).get();
  //
  //     return UserModel.fromDocumentSnapshot(documentSnapshot: _doc);
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  static addDoList(String content) async {
    await _db.collection('questDaily').doc(_uid).collection('doList').add(
      {
        'dateCreated': await TimeC.to.now(),
        'content': content,
        'done': false,
      },
    ).then((_) => DailyQuestsC.to.update());
  }

  static updateDoList(String id, bool newValue) async {
    _db
        .collection('questDaily')
        .doc(_uid)
        .collection('doList')
        .doc(id)
        .update({'done': newValue}).then((_) => DailyQuestsC.to.update());
  }

  /// Stream is a bit much? TODO needed?
  static Stream<List<DoListModel>> doListStream() => _db
          .collection('questDaily')
          .doc(_uid)
          .collection('doList')
          .orderBy('dateCreated', descending: true)
          .snapshots()
          .map(
        (QuerySnapshot query) {
          List<DoListModel> rv = [];
          for (var element in query.docs) {
            var json = element.data() as Map<String, dynamic>;
            json['id'] = element.id; // manually set id, it's not in schema
            rv.add(DoListModel.fromJson(json));
          }
          DailyQuestsC.to.update();
          return rv;
        },
      );

  static setActiveQuest(ActiveQuestModel m) async {
    String path = 'questActive/$_uid/day/${m.day}';

    l.d('setActiveQuest(day=${m.day}, done=${m.done}, skip=${m.skip}, miss=${m.miss})');
    await _db.doc(path).set(m.toJson());
  }

  static Future<ActiveQuestModel?> getActiveQuest(String day) async {
    String path = 'questActive/$_uid/day/$day';
    try {
      return await _db.doc(path).get().then((doc) {
        if (doc.exists) {
          ActiveQuestModel m = ActiveQuestModel.fromJson(doc.data()!);
          l.d('getActiveQuest($path): done=${m.done}, skip=${m.skip}, miss=${m.miss})');
          return m;
        } else {
          l.d('getActiveQuest($path)=null');
          return null;
        }
      });
    } catch (e) {
      // ok to fail here, day not in db yet??
      l.w('getActiveQuest($path) failed, error: $e');
      return null;
    }
  }

  static Future<void> getRelicAjrLevels(List<int> ajrLevels) async {
    String path = 'relic/$_uid';
    try {
      return await _db.doc(path).get().then((doc) {
        if (doc.exists) {
          var json = doc.data()!;
          var map = json['lvl2']; // lvl = ajr level
          if (map != null) {
            for (String key in map.keys) {
              ajrLevels[int.parse(key)] = map[key]; // merge in db values
            }
            l.d('getRelicAjrLevels($path): map length=${map.keys.length}');
          } else {
            l.w('getRelicAjrLevels($path): ajr level map not found in db');
          }
        } else {
          l.w('getRelicAjrLevels($path): empty');
        }
        //return ajrLevels; // not necessary if ajrLevel on caller is same
      });
    } catch (e) {
      // ok to fail here, day not in db yet??
      l.e('getRelicAjrLevels($path) failed, error: $e');
      //return ajrLevels; // not necessary if ajrLevel on caller is same
    }
  }
}
