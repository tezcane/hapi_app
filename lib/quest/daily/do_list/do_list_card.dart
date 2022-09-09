import 'package:flutter/material.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/quest/daily/do_list/do_list_model.dart';
import 'package:hapi/service/db.dart';

class DoListCard extends StatelessWidget {
  final DoListModel doList;

  const DoListCard({required this.doList});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            Transform.scale(
              scale: doList.done ? 2.5 : 1.3,
              child: Checkbox(
                value: doList.done,
                checkColor: AppThemes.checkComplete,
                activeColor: Colors.transparent,
                onChanged: (newValue) =>
                    Db.updateDoList(doList.id, newValue as bool),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
