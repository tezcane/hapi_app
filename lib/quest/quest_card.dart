import 'package:flutter/material.dart';
import 'package:hapi/quest/quest_model.dart';
import 'package:hapi/services/database.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;

  const QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                quest.content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Checkbox(
              value: quest.done,
              onChanged: (newValue) {
                Database().updateQuest(quest.questId, newValue as bool);
              },
            ),
          ],
        ),
      ),
    );
  }
}
