import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/daily/daily_quests_controller.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';

class Database {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Future<bool> createNewUser(UserModel user) async {
  //   try {
  //     await _firestore.collection("user").document(user.id).setData({
  //       "name": user.name,
  //       "email": user.email,
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

  Future<void> addDoList(String content, String uid) async {
    try {
      await _db.collection("user").doc(uid).collection("quest").add({
        'dateCreated': Timestamp.now(),
        'content': content,
        'done': false,
      }).then((_) => DailyQuestsController.to.update());
    } catch (e) {
      // TODO display error to user
      print(e);
      rethrow;
    }
  }

  /// Stream is a bit much? TODO needed?
  Stream<List<DoListModel>> doListStream(String uid) {
    return _db
        .collection("user")
        .doc(uid)
        .collection("quest")
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<DoListModel> retVal = [];
      for (var element in query.docs) {
        retVal.add(DoListModel.fromMap(
            element.id, element.data() as Map<dynamic, dynamic>));
      }
      DailyQuestsController.to.update();
      return retVal;
    });
  }

  Future<void> updateDoList(String questId, bool newValue) async {
    try {
      String uid = AuthController.to.firebaseUser.value!.uid;

      _db.collection("user").doc(uid).collection("quest").doc(questId).update(
          {"done": newValue}).then((_) => DailyQuestsController.to.update());
    } catch (e) {
      // TODO display error to user
      print(e);
      rethrow;
    }
  }
}
