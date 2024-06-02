import 'package:day_planner/models/task.dart';
import 'package:flutter/material.dart';

class TaskDialog {

  Task? task;

  TaskDialog(this.task);

  static final _taskFormKey = GlobalKey<FormState>();
  static TextEditingController summaryController = TextEditingController();

  String getDialogTitle() {
    return task == null ? "Nouvelle tâche" : "Envoyer la tâche à un autre jour";
  }

  Future<void> show(BuildContext context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(getDialogTitle()),
            children: [
              Form(
                key: _taskFormKey,
                child: Column(
                  children: [
                    TextFormField()
                  ],
                ),
              )
            ],
          );
        }
    );
  }
}