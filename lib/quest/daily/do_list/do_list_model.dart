import 'package:cloud_firestore/cloud_firestore.dart';

class DoListModel {
  String questId;
  //QUEST questType;
  String content;
  Timestamp dateCreated;
  Timestamp? dateStart;
  Timestamp? dateEnd;
  Timestamp? dateDone;
  bool done;

  DoListModel(
      {required this.questId,
      //required this.questType,
      required this.content,
      required this.dateCreated,
      required this.dateStart,
      required this.dateEnd,
      required this.dateDone,
      required this.done});

  factory DoListModel.fromMap(String questId, Map data) {
    return DoListModel(
      questId: questId,
      //questType: data['quest'] ?? QUEST.USER_CUSTOM,
      content: data['content'],
      dateCreated: data['dateCreated'],
      dateStart: data['dateStart'],
      dateEnd: data['dateEnd'],
      dateDone: data['dateDone'],
      done: data['done'],
    );
  }
}
