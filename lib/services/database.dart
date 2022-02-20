import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/quest/quest_model.dart';

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

  Future<void> addQuest(String content, String uid) async {
    try {
      await _db.collection("user").doc(uid).collection("quest").add({
        'dateCreated': Timestamp.now(),
        'content': content,
        'done': false,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<QuestModel>> questStream(String uid) {
    return _db
        .collection("user")
        .doc(uid)
        .collection("quest")
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<QuestModel> retVal = [];
      query.docs.forEach((element) {
        retVal.add(QuestModel.fromMap(
            element.id, element.data() as Map<dynamic, dynamic>));
      });
      return retVal;
    });
  }

  Future<void> updateQuest(String questId, bool newValue) async {
    try {
      String uid = Get.find<AuthController>().firebaseUser.value!.uid;

      _db
          .collection("user")
          .doc(uid)
          .collection("quest")
          .doc(questId)
          .update({"done": newValue});
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
