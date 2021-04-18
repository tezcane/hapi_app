import 'package:flutter/material.dart';
import 'package:hapi/models/task_model.dart';
import 'package:hapi/services/database.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({required this.task})
      : super(key: null); // TODO was passed in above

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
                task.content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Checkbox(
              value: task.done,
              onChanged: (newValue) {
                Database().updateTask(task.taskId, newValue as bool);
              },
            ),
          ],
        ),
      ),
    );
  }
}
