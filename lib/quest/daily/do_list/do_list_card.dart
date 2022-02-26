import 'package:flutter/material.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';
import 'package:hapi/services/database.dart';

class DoListCard extends StatelessWidget {
  final DoListModel doList;

  const DoListCard({required this.doList});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                doList.content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Checkbox(
              value: doList.done,
              onChanged: (newValue) {
                Database().updateDoList(doList.questId, newValue as bool);
              },
            ),
          ],
        ),
      ),
    );
  }
}
