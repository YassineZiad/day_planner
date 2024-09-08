import 'package:day_planner/models/task.dart';
import 'package:flutter/material.dart';

import '../configs/theme_config.dart';
import '../repositories/task_repository.dart';

/// Widget d'affichage des [Note]
///
/// [Note] display widget
class TaskComponent extends StatefulWidget {

  final Task task;

  const TaskComponent({
    super.key,
    required this.task
  });

  @override
  State<StatefulWidget> createState() => _TaskComponentState();
}

class _TaskComponentState extends State<TaskComponent> {

  TextEditingController controller = TextEditingController();
  bool _isEditable = false;

  @override
  Widget build(BuildContext context) {
    controller.text = widget.task.label;

    return Draggable<Task>(
      dragAnchorStrategy: (draggable, context, position) => Offset(draggable.feedbackOffset.dx + 150, draggable.feedbackOffset.dy + 25),
      data: widget.task,
      childWhenDragging:
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).extension<Palette>()!.secondary,
          child: Center(child: Text(widget.task.label, style: widget.task.done ? const TextStyle(decoration: TextDecoration.lineThrough) : null)),
      ),
      feedback:
        Center(child:
          Container(
            height: 50,
            width: 300,
            color: Theme.of(context).extension<Palette>()!.primary,
            child: const Icon(Icons.task_alt),
          )
        ),
      child:
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).extension<Palette>()!.primary,
          child: GestureDetector(
              onLongPress: () async {
                Task t = widget.task;
                t.done = !widget.task.done;
                bool b = await TaskRepository.updateTask(t);
                if (b) {
                  setState(() {
                    widget.task.done = t.done;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.done ? "Tâche marquée comme terminée" : "Tâche marquée comme non terminée")));
                }
              },
              onTap: () => setState(() {_isEditable = true;}),
              child: AbsorbPointer(
                  absorbing: !_isEditable,
                  child: TextField(
                    style: widget.task.done ? const TextStyle(decoration: TextDecoration.lineThrough, fontStyle: FontStyle.italic) : null,
                    controller: controller,
                    textAlign: TextAlign.center,
                    onEditingComplete: () async {
                      widget.task.label = controller.text;
                      bool b = await TaskRepository.updateTask(widget.task);
                      if (b) {
                        setState(() {
                          _isEditable = false;
                          widget.task.label = controller.text;
                        });
                      }
                      FocusScope.of(context).unfocus();
                    },
                    onTapOutside: (v) => {
                      setState(() {
                        _isEditable = false;
                      }),
                      FocusScope.of(context).unfocus()
                    }
                  ),
              )
          ),
        ),
    );
  }

}