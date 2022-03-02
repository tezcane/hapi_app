import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hapi/controllers/time_controller.dart';
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
      await _db
          .collection("user")
          .doc(uid)
          .collection("quest/daily/doList")
          .add({
        'dateCreated': await TimeController.to.now(),
        'content': content,
        'done': false,
      }).then((_) => DailyQuestsController.to.update());
    } catch (e) {
      // TODO display error to user
      print(e);
      rethrow;
    }
  }

  Future<void> updateDoList(String id, bool newValue) async {
    try {
      String uid = AuthController.to.firebaseUser.value!.uid;

      _db
          .collection("user")
          .doc(uid)
          .collection("quest/daily/doList")
          .doc(id)
          .update({"done": newValue}).then(
              (_) => DailyQuestsController.to.update());
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
        .collection("quest/daily/doList")
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<DoListModel> rv = [];
      for (var element in query.docs) {
        var doList = element.data() as Map<String, dynamic>;
        doList['id'] = element.id; // manually set id since not in schema here
        rv.add(DoListModel.fromJson(doList));
      }
      DailyQuestsController.to.update();
      return rv;
    });
  }
}
