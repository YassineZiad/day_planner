import 'package:day_planner/components/task_component.dart';
import 'package:day_planner/dialogs/calendar_dialog.dart';
import 'package:day_planner/models/note.dart';
import 'package:day_planner/models/task.dart';
import 'package:day_planner/repositories/note_repository.dart';
import 'package:day_planner/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configs/theme_config.dart';
import '../dialogs/event_dialog.dart';


class NotesContainer extends StatefulWidget {

  final DateTime day;
  final List<Task> normalTasks;
  final List<Task> priorityTasks;
  final Function getEvents;

  const NotesContainer({
    super.key,
    required this.day,
    required this.normalTasks,
    required this.priorityTasks,
    required this.getEvents
  });

  @override
  _NotesContainerState createState() => _NotesContainerState();
}

class _NotesContainerState extends State<NotesContainer> {

  late bool _firstBuild;

  static TextEditingController noteController = TextEditingController();

  late bool _noteChanged;
  late String _noteBackup;

  @override
  void initState() {
    super.initState();
    _firstBuild = true;

    initContent();
  }

  void initContent() {
    NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(widget.day)).then((value) =>
    {
      if (value != null) {
        noteController.text = value.text
      } else {
        noteController.text = ""
      }
    });

    _noteBackup = noteController.text;
    _noteChanged = false;
  }

  static Future<bool> isNoteNew(DateTime day) async {
    Note? n = await NoteRepository.getNote(DateFormat('yyyy-MM-dd').format(day));
    return n == null;
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = 20;

    if (!_noteChanged) {
      initContent();
    }

    return Container(
        margin: const EdgeInsets.only(left:30, top: 60),
        width: MediaQuery.of(context).size.width / 3,
        //decoration: const BoxDecoration(border: Border(top: BorderSide(), left: BorderSide(), right: BorderSide(), bottom: BorderSide())),
        child: Column(children: [

          // Ajout Tâche
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Ajouter un évènement"),
                  onPressed: () async {
                    EventDialog(create: true, day: widget.day).show(context).then((v) => widget.getEvents());
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text("Ajouter une tâche"),
                  onPressed: () async {
                    Task t = Task(label: "Nouvelle Tâche", done: false, priority: false, day: DateFormat('yyyy-MM-dd').format(widget.day));
                    t = await TaskRepository.createTask(t);
                    setState(() {
                      widget.normalTasks.add(t);
                      _firstBuild = false;
                    });
                  },
                )
              ],
            ),
          ),

          // TACHES PRIORITAIRES
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.priority_high),
                    Text("\t TACHES PRIORITAIRES",
                      style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start
                      ),
                  ],
                ),
              ])
          ),
          for (Task priorityTask in widget.priorityTasks) TaskComponent(task: priorityTask),
          DragTarget<Task>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).extension<Palette>()!.secondary,
                child: const Center(
                  child: Icon(Icons.move_down),
                ),
              );
            },
            onAcceptWithDetails: (DragTargetDetails<Task> details) async {
              // PASSAGE DE NORMAL A PRIORITAIRE
              Task t = details.data;
              if (!t.priority) {
                t.priority = true;
                bool b = await TaskRepository.updateTask(t);
                setState(() {
                  if (b) {
                    widget.normalTasks.remove(details.data);
                    widget.priorityTasks.add(details.data);
                  }
                });
              }
            },
          ),

          // TACHES NORMALES
          Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.task),
                    Text("\t TACHES A EFFECTUER",
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start),
                  ],
                ),
              ])),
          for (Task normalTask in widget.normalTasks) TaskComponent(task: normalTask),
          DragTarget<Task>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return Container(
                height: 25,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).extension<Palette>()!.secondary,
                child: const Center(
                  child: Icon(Icons.move_down),
                ),
              );
            },
            onAcceptWithDetails: (DragTargetDetails<Task> details) async {
              // PASSAGE DE PRIORITAIRE A NORMAL
              Task t = details.data;
              if (t.priority) {
                t.priority = false;
                bool b = await TaskRepository.updateTask(t);
                if (b) {
                  setState(() {
                    widget.priorityTasks.remove(details.data);
                    widget.normalTasks.add(details.data);
                  });
                }
              }
            },
          ),

          const Padding(padding: EdgeInsets.only(bottom: 20)),
          // Suppression Tâche
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Expanded(child: DragTarget<Task>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return Container(
                      height: 50,
                      color: Theme.of(context).extension<Palette>()!.secondary,
                      child: const Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Envoyer à un autre jour"), Icon(Icons.calendar_month)])
                      ),
                    );
                  },
                  onAcceptWithDetails: (DragTargetDetails<Task> details) async {
                    Task t = details.data;
                    DateTime? pickedDate = await showDialog<DateTime>(
                        context: context,
                        builder: (context) => CalendarDialog(date: widget.day)
                    );

                    if (pickedDate != null) {
                      t.day = DateFormat('yyyy-MM-dd').format(pickedDate);
                      bool b = await TaskRepository.updateTask(t);
                      setState(() {
                        details.data.priority && b ? widget.priorityTasks.remove(details.data) : widget.normalTasks.remove(details.data);
                      });
                    }

                  },
                )),
                Expanded(child: DragTarget<Task>(
                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                    return Container(
                      height: 50,
                      color: Theme.of(context).extension<Palette>()!.cancelled,
                      child: const Center(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Supprimer"), Icon(Icons.delete_sweep)]),
                      ),
                    );
                  },
                  onAcceptWithDetails: (DragTargetDetails<Task> details) async {
                    bool b = await TaskRepository.deleteTask(details.data);
                    setState(() {
                      details.data.priority && b ? widget.priorityTasks.remove(details.data) : widget.normalTasks.remove(details.data);
                    });
                  },
                ))
              ],
            ),
          ),


          // NOTES
          Padding(
              padding: const EdgeInsets.only(top: 50, left: 20),
              child: Column(children: [
                Row(
                  children: [
                    const Icon(Icons.notes),
                    Text("\t NOTES",
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start
                    )
                  ],
                ),
                TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: noteController,
                    onTap: () => _noteBackup = noteController.text,
                    onChanged: (v) {
                      setState(() {
                        _noteChanged = true;
                        _firstBuild = false;
                      });
                    }
                ),
                Visibility(
                    visible: _noteChanged,
                    child: Row(
                      children: [
                        TextButton.icon(
                          label: const Text("Sauvegarder"),
                          icon: const Icon(Icons.save),
                          onPressed: () async {
                            bool isNew = await isNoteNew(widget.day);
                            if (noteController.text.isNotEmpty) {
                              Note n = Note(day: DateFormat('yyyy-MM-dd').format(widget.day), text: noteController.text);
                              isNew ? NoteRepository.createNote(n) : NoteRepository.updateNote(n);
                            } else {
                              if (!isNew) {
                                NoteRepository.deleteNote(DateFormat('yyyy-MM-dd').format(widget.day));
                              }
                            }

                            setState(() {
                              _firstBuild = false;
                              _noteChanged = false;
                            });
                          },
                        ),
                        TextButton.icon(
                          label: const Text("Annuler"),
                          icon: const Icon(Icons.undo),
                          onPressed: () {
                            setState(() {
                              _firstBuild = false;
                              noteController.text = _noteBackup;
                              _noteChanged = false;
                            });
                          },
                        )
                      ],
                    )
                )
              ]
              )
          ),
        ])
    );
  }

}