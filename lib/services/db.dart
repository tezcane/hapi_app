import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/active/active_quest_model.dart';
import 'package:hapi/quest/daily/daily_quests_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';

/// Does database transactions.
class Db {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _uid = AuthController.to.firebaseUser.value!.uid;

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
        'dateCreated': await TimeController.to.now(),
        'content': content,
        'done': false,
      },
    ).then((_) => DailyQuestsController.to.update());
  }

  static updateDoList(String id, bool newValue) async {
    _db.collection('questDaily').doc(_uid).collection('doList').doc(id).update(
        {'done': newValue}).then((_) => DailyQuestsController.to.update());
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
            var doList = element.data() as Map<String, dynamic>;
            doList['id'] = element.id; // manually set id, it's not in schema
            rv.add(DoListModel.fromJson(doList));
          }
          DailyQuestsController.to.update();
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
      // ok to fail here, day not in db yet
      l.w('getActiveQuest($path) failed, error: $e');
      return null;
    }
  }
}
