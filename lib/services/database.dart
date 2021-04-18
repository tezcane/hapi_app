import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/models/task_model.dart';

class Database {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Future<bool> createNewUser(UserModel user) async {
  //   try {
  //     await _firestore.collection("users").document(user.id).setData({
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
  //         await _firestore.collection("users").document(uid).get();
  //
  //     return UserModel.fromDocumentSnapshot(documentSnapshot: _doc);
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  Future<void> addTask(String content, String uid) async {
    try {
      await _db.collection("users").doc(uid).collection("tasks").add({
        'dateCreated': Timestamp.now(),
        'content': content,
        'done': false,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<TaskModel>> taskStream(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .orderBy("dateCreated", descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<TaskModel> retVal = [];
      query.docs.forEach((element) {
        retVal.add(TaskModel.fromMap(element.id, element.data()));
      });
      return retVal;
    });
  }

  Future<void> updateTask(String taskId, bool newValue) async {
    try {
      String uid = Get.find<AuthController>().firebaseUser.value!.uid;

      _db
          .collection("users")
          .doc(uid)
          .collection("tasks")
          .doc(taskId)
          .update({"done": newValue});
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
