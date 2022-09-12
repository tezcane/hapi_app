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
    final String path = 'questActive/$_uid/day/$day';
    final String func = 'getActiveQuest($path)';
    try {
      return await _db.doc(path).get().then((doc) {
        if (doc.exists) {
          ActiveQuestModel m = ActiveQuestModel.fromJson(doc.data()!);
          l.d('$func: done=${m.done}, skip=${m.skip}, miss=${m.miss})');
          return m;
        } else {
          l.d('$func: doc does not exist');
          return null;
        }
      });
    } catch (e) {
      l.w('$func failed, error: $e'); // TODO ok to fail here??
      return null;
    }
  }

  /// DB stores Map<'int relicType.index', Map<'int relicId', int ajrLevel>>.
  /// Using '' quotes above since firestore only allows string keys, not ints.
  static Future<void> getRelicAjrLevels(List<Map<int, int>> ajrLevels) async {
    final String path = 'relic/$_uid';
    final String func = 'getRelicAjrLevels($path)';
    try {
      return await _db.doc(path).get().then((doc) {
        if (doc.exists) {
          var json = doc.data()!;

          for (int typeIdx = 0; typeIdx < ajrLevels.length; typeIdx++) {
            var dbTypeMap = json['$typeIdx'];
            if (dbTypeMap == null) {
              l.d('$func: ajr level map not found in db, typeIdx=$typeIdx');
              continue;
            }

            Map<int, int> relicIdMap = ajrLevels[typeIdx];
            for (String key in dbTypeMap.keys) {
              relicIdMap[int.parse(key)] = dbTypeMap[key]; // merge in db vals
            }
          }
        } else {
          return l.d('$func: doc does not exist');
        }
        //return ajrLevels; // not necessary if ajrLevel on caller is same
      });
    } catch (e) {
      return l.e('$func failed, error: $e'); // TODO ok to fail here??
    }
  }
}
